library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_enemy_controller is
end tb_enemy_controller;

architecture sim of tb_enemy_controller is
    component enemy_controller
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            enemy_hit   : in  STD_LOGIC_VECTOR(0 to 4);
            enemy_x     : out STD_LOGIC_VECTOR(0 to 49);
            enemy_y     : out integer range 0 to 479;
            enemy_alive : out STD_LOGIC_VECTOR(0 to 4)
        );
    end component;

    signal clk         : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '0';
    signal enemy_hit   : STD_LOGIC_VECTOR(0 to 4) := (others => '0');
    signal enemy_x     : STD_LOGIC_VECTOR(0 to 49);
    signal enemy_y     : integer;
    signal enemy_alive : STD_LOGIC_VECTOR(0 to 4);

    constant clk_period : time := 40 ns; -- 25 MHz
begin
    uut: enemy_controller port map (
        clk => clk, reset => reset, enemy_hit => enemy_hit,
        enemy_x => enemy_x, enemy_y => enemy_y, enemy_alive => enemy_alive
    );

    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Systeem initialiseren
        reset <= '1'; wait for 100 ns;
        reset <= '0'; wait for 100 ns;

        -- Test 1: Laat de vijanden gedurende enkele frames bewegen
        wait for 40 ms; 

        -- Test 2: Simuleer een treffer op de tweede vijand
        enemy_hit(1) <= '1';
        wait for 100 ns;
        enemy_hit(1) <= '0';
        
        -- Test 3: Wacht op verdere groepsbeweging
        wait for 40 ms;

        wait;
    end process;
end sim;