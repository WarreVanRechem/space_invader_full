library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_logic_controller is
    Port (
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        
        -- Inputs voor logica
        player_x      : in  integer range 0 to 639;
        enemy_alive   : in  STD_LOGIC_VECTOR(0 to 4);
        eb_x          : in  integer range 0 to 639;
        eb_y          : in  integer range 0 to 479;
        eb_active     : in  STD_LOGIC;

        -- Outputs
        shoot_trigger      : out STD_LOGIC; -- Zegt tegen bullet controller: SCHIET
        collision_detected : out STD_LOGIC; -- Zegt tegen bullet controller: VERDWIJN
        player_lives       : out integer range 0 to 4;
        game_over          : out STD_LOGIC
    );
end game_logic_controller;

architecture Behavioral of game_logic_controller is
    signal lives_reg     : integer range 0 to 4 := 4;
    signal game_over_reg : STD_LOGIC := '0';

    -- Player Hitbox instellingen (pas aan indien nodig)
    constant PLAYER_Y_MIN : integer := 420;
    constant PLAYER_Y_MAX : integer := 470;
    constant PLAYER_W     : integer := 40;
    constant BULLET_W     : integer := 4; -- Matcht met jouw bullet width

begin
    player_lives <= lives_reg;
    game_over    <= game_over_reg;

    -- PROCESS 1: Shoot Timer (Elke 1.5 seconde een trigger)
    process(clk, reset)
        variable counter : integer range 0 to 37500000 := 0;
    begin
        if reset = '1' then
            counter := 0;
            shoot_trigger <= '0';
        elsif rising_edge(clk) then
            shoot_trigger <= '0'; -- Puls is standaard laag
            
            if game_over_reg = '0' then
                if counter = 37500000 then -- 1.5s bij 25MHz
                    counter := 0;
                    -- Alleen schieten als er nog vijanden zijn
                    if unsigned(enemy_alive) /= 0 then
                        shoot_trigger <= '1';
                    end if;
                else
                    counter := counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- PROCESS 2: Collision Detection
    process(clk, reset)
    begin
        if reset = '1' then
            lives_reg <= 4;
            game_over_reg <= '0';
            collision_detected <= '0';
        elsif rising_edge(clk) then
            collision_detected <= '0'; -- Reset signaal

            if game_over_reg = '0' and eb_active = '1' then
                -- Check Y bereik
                if (eb_y >= PLAYER_Y_MIN) and (eb_y <= PLAYER_Y_MAX) then
                    -- Check X bereik (Player X tot Player X + Breedte)
                    if (eb_x + BULLET_W >= player_x) and (eb_x <= player_x + PLAYER_W) then
                        
                        -- RAAK!
                        collision_detected <= '1'; -- Dit signaal killt de kogel in de andere controller
                        
                        if lives_reg > 0 then
                            lives_reg <= lives_reg - 1;
                        end if;

                        if lives_reg = 1 then -- Was 1, wordt nu 0
                            game_over_reg <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;