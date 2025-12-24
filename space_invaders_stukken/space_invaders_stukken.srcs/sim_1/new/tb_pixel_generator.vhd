library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pixel_generator is
-- Testbench heeft geen poorten
end tb_pixel_generator;

architecture sim of tb_pixel_generator is
    component pixel_generator
        Port (
            clk, vidon           : in STD_LOGIC;
            hc, vc               : in STD_LOGIC_VECTOR(9 downto 0);
            player_x             : in integer range 0 to 639;
            enemy_x              : in STD_LOGIC_VECTOR(0 to 49);
            enemy_y              : in integer range 0 to 479;
            enemy_alive          : in STD_LOGIC_VECTOR(0 to 4);
            bullet_x, bullet_y   : in integer range 0 to 639;
            bullet_active        : in STD_LOGIC;
            eb_x, eb_y           : in integer range 0 to 639;
            eb_active            : in STD_LOGIC;
            player_lives         : in integer range 0 to 4;
            game_over, game_won  : in STD_LOGIC;
            vga_r, vga_g, vga_b  : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Test signalen
    signal clk           : STD_LOGIC := '0';
    signal vidon         : STD_LOGIC := '0';
    signal hc, vc        : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal enemy_x       : STD_LOGIC_VECTOR(0 to 49) := (others => '0');
    signal enemy_alive   : STD_LOGIC_VECTOR(0 to 4) := "11111";
    signal r, g, b       : STD_LOGIC_VECTOR(3 downto 0);

    constant clk_period : time := 40 ns; -- 25 MHz
begin
    uut: pixel_generator port map (
        clk => clk, vidon => vidon, hc => hc, vc => vc,
        player_x => 300, enemy_x => enemy_x, enemy_y => 100,
        enemy_alive => enemy_alive, bullet_x => 0, bullet_y => 0,
        bullet_active => '0', eb_x => 0, eb_y => 0, eb_active => '0',
        player_lives => 3, game_over => '0', game_won => '0',
        vga_r => r, vga_g => g, vga_b => b
    );

    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Initialisatie
        enemy_x(0 to 9) <= std_logic_vector(to_unsigned(100, 10));
        wait for 100 ns;

        -- TEST 1: Scan over vijand (x=100) met VIDON = '1'
        report "Start Test 1: Active Video";
        vidon <= '1';
        vc <= std_logic_vector(to_unsigned(105, 10)); -- Op de hoogte van de vijand
        for i in 95 to 110 loop
            hc <= std_logic_vector(to_unsigned(i, 10));
            wait for clk_period;
        end loop;

        -- TEST 2: Scan over vijand (x=100) met VIDON = '0' (Blanking)
        report "Start Test 2: Blanking Interval";
        vidon <= '0';
        for i in 95 to 110 loop
            hc <= std_logic_vector(to_unsigned(i, 10));
            wait for clk_period;
        end loop;

        wait;
    end process;
end sim;