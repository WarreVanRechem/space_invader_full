library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_logic_controller is
    Port (
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;
        
        -- Inputs
        player_x       : in  integer range 0 to 639;
        enemy_alive    : in  STD_LOGIC_VECTOR(0 to 4);
        eb_x           : in  integer range 0 to 639;
        eb_y           : in  integer range 0 to 479;
        eb_active      : in  STD_LOGIC;

        -- Outputs
        shoot_trigger  : out STD_LOGIC;
        collision_detected : out STD_LOGIC;
        player_lives   : out integer range 0 to 4;
        game_over      : out STD_LOGIC;
        game_won       : out STD_LOGIC 
    );
end game_logic_controller;

architecture Behavioral of game_logic_controller is
    -- Start met 3 levens
    signal lives_reg     : integer range 0 to 15 := 4;
    signal game_over_reg : STD_LOGIC := '0';
    signal game_won_reg  : STD_LOGIC := '0'; 
    
    signal hit_guard     : STD_LOGIC := '0';

    constant PLAYER_Y_MIN : integer := 420;
    constant PLAYER_Y_MAX : integer := 470;
    constant PLAYER_W     : integer := 40;
    constant BULLET_W     : integer := 4;

begin
    player_lives <= lives_reg;
    game_over    <= game_over_reg;
    game_won     <= game_won_reg; 

    -- PROCESS 1: Shoot Timer
    process(clk, reset)
        variable counter : integer range 0 to 37500000 := 0;
    begin
        if reset = '1' then
            counter := 0;
            shoot_trigger <= '0';
        elsif rising_edge(clk) then
            shoot_trigger <= '0';
            
            -- Alleen schieten als spel bezig is en niet gewonnen
            if game_over_reg = '0' and game_won_reg = '0' then
                if counter = 37500000 then 
                    counter := 0;
                    if unsigned(enemy_alive) /= 0 then
                        shoot_trigger <= '1';
                    end if;
                else
                    counter := counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- PROCESS 2: Collision & Win Check
    process(clk, reset)
    begin
        if reset = '1' then
            lives_reg <= 4; 
            game_over_reg <= '0';
            game_won_reg <= '0'; 
            collision_detected <= '0';
            hit_guard <= '0'; 
            
        elsif rising_edge(clk) then
            collision_detected <= '0';

            -- Reset hit guard als kogel weg is
            if eb_active = '0' then
                hit_guard <= '0';
            end if;

            -- *** NIEUW: WIN CONDITIE CHECK ***
            -- Als alle vijanden dood zijn (00000) EN we zijn nog niet Game Over
            if unsigned(enemy_alive) = 0 and game_over_reg = '0' then
                game_won_reg <= '1';
            end if;

            -- Game Logic (Collision) alleen als spel nog bezig is
            if game_over_reg = '0' and game_won_reg = '0' and eb_active = '1' then
                if (eb_y >= PLAYER_Y_MIN) and (eb_y <= PLAYER_Y_MAX) then
                    if (eb_x + BULLET_W >= player_x) and (eb_x <= player_x + PLAYER_W) then
                        
                        collision_detected <= '1'; 
                        
                        if hit_guard = '0' then
                            hit_guard <= '1'; 
                            if lives_reg > 0 then
                                lives_reg <= lives_reg - 1;
                            end if;
                            if lives_reg = 1 then
                                game_over_reg <= '1';
                            end if;
                        end if;
                        
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;