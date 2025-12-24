library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Een testbench entiteit is altijd leeg
entity tb_space_invaders is
end tb_space_invaders;

architecture sim of tb_space_invaders is

    -- 1. Component Declaration: De entiteit die we willen testen (jouw top-level)
    component space_invaders
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            btn_left  : in  STD_LOGIC;
            btn_right : in  STD_LOGIC;
            btn_shoot : in  STD_LOGIC;
            hsync     : out STD_LOGIC;
            vsync     : out STD_LOGIC;
            vga_r     : out STD_LOGIC_VECTOR(3 downto 0);
            vga_g     : out STD_LOGIC_VECTOR(3 downto 0);
            vga_b     : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- 2. Interne signalen om de UUT aan te sturen
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal btn_left  : STD_LOGIC := '0';
    signal btn_right : STD_LOGIC := '0';
    signal btn_shoot : STD_LOGIC := '0';

    -- Outputs van de UUT
    signal hsync     : STD_LOGIC;
    signal vsync     : STD_LOGIC;
    signal vga_r     : STD_LOGIC_VECTOR(3 downto 0);
    signal vga_g     : STD_LOGIC_VECTOR(3 downto 0);
    signal vga_b     : STD_LOGIC_VECTOR(3 downto 0);

    -- Klok periode definitie (100 MHz)
    constant clk_period : time := 10 ns;

begin

    -- 3. Instantiatie van de Unit Under Test (UUT)
    uut: space_invaders
        port map (
            clk       => clk,
            reset     => reset,
            btn_left  => btn_left,
            btn_right => btn_right,
            btn_shoot => btn_shoot,
            hsync     => hsync,
            vsync     => vsync,
            vga_r     => vga_r,
            vga_g     => vga_g,
            vga_b     => vga_b
        );

    -- 4. Klok generatie proces: blijft oneindig doorlopen
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Stimulus proces: hier simuleren we de acties van de gebruiker
    stim_proc: process
    begin
        -- Start met een reset
        report "Initialisatie: Systeem resetten...";
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        
        -- Wacht tot de interne Clock Wizard 'locked' is
        -- In simulatie duurt dit vaak kort, maar we wachten voor de zekerheid
        wait for 2 us;

        -- Test: Beweeg naar rechts
        report "Actie: Button Right indrukken";
        btn_right <= '1';
        wait for 50 us; -- We houden de knop lang genoeg vast voor de debouncer
        btn_right <= '0';
        wait for 20 us;

        -- Test: Schieten
        report "Actie: Button Shoot indrukken";
        btn_shoot <= '1';
        wait for 50 us;
        btn_shoot <= '0';
        wait for 20 us;

        -- Test: Beweeg naar links
        report "Actie: Button Left indrukken";
        btn_left <= '1';
        wait for 50 us;
        btn_left <= '0';

        -- Laat de simulatie een tijdje lopen om VGA signalen te zien
        report "Simulatie loopt door... Bekijk de VGA signalen in de wave viewer.";
        wait for 1 ms; 

        report "Simulatie succesvol afgerond!";
        wait; -- Stopt het proces (voorkomt oneindige loop)
    end process;

end sim;