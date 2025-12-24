library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench entiteit voor de debouncer [cite: 552]
entity tb_debouncer is
end tb_debouncer;

architecture sim of tb_debouncer is

    -- 1. Component Declaration: Moet exact overeenkomen met de debouncer module [cite: 552-558]
    component debouncer
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            btn_in  : in  STD_LOGIC;
            btn_out : out STD_LOGIC
        );
    end component;

    -- 2. Interne signalen voor de simulatie [cite: 574-577]
    signal clk     : STD_LOGIC := '0';
    signal reset   : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;

    -- Klok periode: 25 MHz = 40 ns per cycle
    constant clk_period : time := 40 ns;

begin

    -- 3. Instantiatie van de Unit Under Test (UUT)
    uut: debouncer
        port map (
            clk     => clk,
            reset   => reset,
            btn_in  => btn_in,
            btn_out => btn_out
        );

    -- 4. Klok generatie proces
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Stimulus proces: bootst de fysieke knopdruk na
    stim_proc: process
    begin
        -- Stap A: Initialisatie en Reset [cite: 600]
        report "Start simulatie: Resetten van de debouncer";
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- Stap B: Simuleer het indrukken van de knop
        report "Actie: btn_in wordt hoog. Wachten op de 10ms debounce tijd...";
        btn_in <= '1';
        
        -- CRUCIAAL: Omdat de teller in de VHDL op 250.000 staat[cite: 614], 
        -- moeten we langer dan 10 ms wachten (bijv. 12 ms) om de btn_out te zien springen.
        wait for 12 ms; 
        
        -- Nu zou btn_out op '1' moeten staan in de wave viewer.

        -- Stap C: De knop weer loslaten
        report "Actie: btn_in wordt laag.";
        btn_in <= '0';
        wait for 12 ms; -- Ook hier weer 10ms+ wachten voor de release

        report "Simulatie voltooid. Controleer of btn_out na 10ms hoog werd.";
        wait;
    end process;

end sim;