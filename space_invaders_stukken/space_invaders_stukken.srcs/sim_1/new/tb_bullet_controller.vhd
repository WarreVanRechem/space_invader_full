library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bullet_controller is
-- Testbench heeft geen poorten
end tb_bullet_controller;

architecture sim of tb_bullet_controller is
    -- Component Declaration [cite: 985-1017]
    component bullet_controller
        Port (
            clk           : in STD_LOGIC;
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
    end component;

    -- Signalen
    signal clk           : STD_LOGIC := '0';
    signal reset         : STD_LOGIC := '0';
    signal btn_shoot     : STD_LOGIC := '0';
    signal player_x      : integer := 300;
    signal enemy_x       : STD_LOGIC_VECTOR(0 to 49) := (others => '0');
    signal enemy_y       : integer := 100;
    signal enemy_alive   : STD_LOGIC_VECTOR(0 to 4) := "11111";
    
    signal bx, by        : integer;
    signal b_active      : STD_LOGIC;
    signal e_hit         : STD_LOGIC_VECTOR(0 to 4);

    constant clk_period : time := 40 ns; -- 25 MHz
begin
    -- Instantiatie UUT [cite: 392-397]
    uut: bullet_controller port map (
        clk => clk, reset => reset, btn_shoot => btn_shoot,
        player_x => player_x, enemy_x => enemy_x, enemy_y => enemy_y,
        enemy_alive => enemy_alive, bullet_x => bx, bullet_y => by,
        bullet_active => b_active, enemy_hit => e_hit
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
        -- Vijand 0 op positie 300 zetten (voor de botsing)
        enemy_x(0 to 9) <= std_logic_vector(to_unsigned(300, 10));
        
        reset <= '1'; wait for 100 ns;
        reset <= '0'; wait for 100 ns;

        -- Schiet een kogel
        report "Actie: Speler schiet een kogel";
        btn_shoot <= '1';
        wait for 100 us; 
        btn_shoot <= '0';
        
        -- Wacht tot de kogel de vijand raakt op y=100
        -- In de simulatie runnen we dit tot 100ms
        wait for 100 ms;

        wait;
    end process;
end sim;