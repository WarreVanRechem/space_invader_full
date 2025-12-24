library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_game_logic_controller is
end tb_game_logic_controller;

architecture sim of tb_game_logic_controller is
    -- Component Declaration
    component game_logic_controller
        Port (
            clk                : in  STD_LOGIC;
            reset              : in  STD_LOGIC;
            player_x           : in  integer range 0 to 639;
            enemy_alive        : in  STD_LOGIC_VECTOR(0 to 4);
            eb_x               : in  integer range 0 to 639;
            eb_y               : in  integer range 0 to 479;
            eb_active          : in  STD_LOGIC;
            shoot_trigger      : out STD_LOGIC;
            collision_detected : out STD_LOGIC;
            player_lives       : out integer range 0 to 4;
            game_over          : out STD_LOGIC;
            game_won           : out STD_LOGIC
        );
    end component;

    -- Signalen
    signal clk                : STD_LOGIC := '0';
    signal reset              : STD_LOGIC := '0';
    signal player_x           : integer := 300;
    signal enemy_alive        : STD_LOGIC_VECTOR(0 to 4) := "11111";
    signal eb_x               : integer := 0;
    signal eb_y               : integer := 0;
    signal eb_active          : STD_LOGIC := '0';
    
    signal shoot_trigger      : STD_LOGIC;
    signal collision_detected : STD_LOGIC;
    signal p_lives            : integer;
    signal g_over             : STD_LOGIC;
    signal g_won              : STD_LOGIC;

    constant clk_period : time := 40 ns; -- 25 MHz
begin
    -- Instantiatie van de UUT
    uut: game_logic_controller port map (
        clk => clk, reset => reset, player_x => player_x,
        enemy_alive => enemy_alive, eb_x => eb_x, eb_y => eb_y,
        eb_active => eb_active, shoot_trigger => shoot_trigger,
        collision_detected => collision_detected, player_lives => p_lives,
        game_over => g_over, game_won => g_won
    );

    -- Klok proces
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Stimulus proces
    stim_proc: process
    begin
        -- Initialisatie
        reset <= '1'; wait for 100 ns;
        reset <= '0'; wait for 100 ns;

        -- Test 1: Controleer startconditie (3 levens)
        wait for 20 ms;
        
        -- Test 2: Simuleer botsing (Vijandelijke kogel raakt speler op x=300, y=440)
        eb_x <= 310; -- Midden van kogel binnen player range
        eb_y <= 440; -- Hoogte van de speler
        eb_active <= '1';
        wait for 20 ms; -- Wacht op 60Hz update
        eb_active <= '0';
        
        -- Test 3: Simuleer winnen (Alle vijanden dood)
        wait for 40 ms;
        enemy_alive <= "00000";
        wait for 20 ms;

        wait;
    end process;
end sim;