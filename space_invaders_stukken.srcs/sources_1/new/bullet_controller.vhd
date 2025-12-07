library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bullet_controller is
    Port (
        clk           : in STD_LOGIC; -- 25 MHz clock
        reset         : in STD_LOGIC;
        btn_shoot     : in STD_LOGIC;
        player_x      : in integer range 0 to 639;
        enemy_x       : in STD_LOGIC_VECTOR(0 to 49);
        enemy_y       : in integer range 0 to 479;
        enemy_alive   : in STD_LOGIC_VECTOR(0 to 4);
        bullet_x      : out integer range 0 to 639;
        bullet_y      : out integer range 0 to 479;
        bullet_active : out STD_LOGIC;
        enemy_hit     : out STD_LOGIC_VECTOR(0 to 4)
    );
end bullet_controller;

architecture Behavioral of bullet_controller is
    -- Constanten
    constant BULLET_WIDTH   : integer := 4;
    constant BULLET_HEIGHT  : integer := 8;
    constant BULLET_SPEED   : integer := 4;
    
    constant PLAYER_WIDTH   : integer := 32;
    constant PLAYER_Y       : integer := 440;
    
    -- Pas op: in pixel_generator gebruikten we 16x12 voor de enemy
    constant ENEMY_WIDTH    : integer := 16;
    constant ENEMY_HEIGHT   : integer := 12;

    -- Array om enemy_x makkelijk uit te lezen
    type enemy_x_array is array (0 to 4) of integer range 0 to 639;
    signal ex : enemy_x_array;
    
    -- INTERNE SIGNALEN - HIER ZAT DE FOUT
    -- bx moet tot 639 kunnen gaan (schermbreedte)
    signal bx : integer range 0 to 639 := 0; 
    -- by moet tot 479 kunnen gaan (schermhoogte)
    signal by : integer range 0 to 479 := 0;
    
    signal active           : STD_LOGIC := '0';
    signal hit              : STD_LOGIC_VECTOR(0 to 4) := (others => '0');
    signal move_counter     : unsigned(19 downto 0) := (others => '0');
    
begin
    -- 1. Unpack enemy_x vector naar leesbare integers
    gen_unpack: for i in 0 to 4 generate
        ex(i) <= to_integer(unsigned(enemy_x(i*10 to i*10 + 9)));
    end generate;

    process(clk, reset)
    begin
        if reset = '1' then
            bx <= 0; 
            by <= 0;
            active <= '0'; 
            hit <= (others => '0');
            move_counter <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Reset hit puls
            hit <= (others => '0'); 
            
            -- =============================================================
            -- 60 Hz GAME LOGIC (Bewegen & Schieten)
            -- =============================================================
            if move_counter = 416667 then  -- ~60 Hz bij 25MHz klok
                move_counter <= (others => '0');
                
                -- NIEUWE KOGEL SCHIETEN
                if btn_shoot = '1' and active = '0' then
                    
                    -- BEREKEN STARTPOSITIE (MET BEVEILIGING)
                    -- We willen: player_x + 14. 
                    -- Als player_x > 620 is, zou +14 buiten de 639 range vallen.
                    if player_x > (639 - 20) then
                        bx <= 639 - BULLET_WIDTH; -- Zet hem veilig tegen de rand
                    else
                        bx <= player_x + (PLAYER_WIDTH / 2) - (BULLET_WIDTH / 2);
                    end if;
                    
                    by <= PLAYER_Y - BULLET_HEIGHT;
                    active <= '1';
                    
                -- BESTAANDE KOGEL BEWEGEN
                elsif active = '1' then
                    if by > BULLET_SPEED then
                        by <= by - BULLET_SPEED;
                    else
                        -- Kogel raakt bovenkant scherm
                        by <= 0;
                        active <= '0';
                    end if;
                end if;
                
            else
                move_counter <= move_counter + 1;
            end if;
            
            -- =============================================================
            -- COLLISION CHECK
            -- =============================================================
            if active = '1' then
                for i in 0 to 4 loop
                    if enemy_alive(i) = '1' then
                        -- AABB Collision Logic
                        if (bx + BULLET_WIDTH > ex(i)) and (bx < ex(i) + ENEMY_WIDTH) then
                            if (by + BULLET_HEIGHT > enemy_y) and (by < enemy_y + ENEMY_HEIGHT) then
                                hit(i) <= '1';   
                                active <= '0';   
                                by <= 0;         
                            end if;
                        end if;
                    end if;
                end loop;
            end if;
            
        end if;
    end process;

    -- Output toewijzing
    bullet_x <= bx;
    bullet_y <= by;
    bullet_active <= active;
    enemy_hit <= hit;

end Behavioral;