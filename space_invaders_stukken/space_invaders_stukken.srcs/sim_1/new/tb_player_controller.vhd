library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_player_controller is
end tb_player_controller;

architecture sim of tb_player_controller is
    -- Component Declaration [cite: 850-858]
    component player_controller
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            btn_left  : in  STD_LOGIC;
            btn_right : in  STD_LOGIC;
            player_x  : out integer range 0 to 639
        );
    end component;

    -- Signalen
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal btn_left  : STD_LOGIC := '0';
    signal btn_right : STD_LOGIC := '0';
    signal player_x  : integer;

    constant clk_period : time := 40 ns; -- 25 MHz
begin
    -- Instantiatie UUT [cite: 387-388]
    uut: player_controller port map (clk, reset, btn_left, btn_right, player_x);

    -- Klok proces
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Stimulus proces
    stim_proc: process
    begin
        -- Systeem resetten
        reset <= '1'; wait for 100 ns;
        reset <= '0'; wait for 100 ns;

        -- Test 1: Beweeg naar rechts voor 20 ms
        -- Op 60 Hz (elke 16.6 ms) moet de x-positie veranderen
        report "Actie: Button Right indrukken";
        btn_right <= '1';
        wait for 40 ms; 
        btn_right <= '0';
        
        wait for 1 ms;

        -- Test 2: Beweeg naar links voor 20 ms
        report "Actie: Button Left indrukken";
        btn_left <= '1';
        wait for 40 ms;
        btn_left <= '0';

        wait;
    end process;
end sim;