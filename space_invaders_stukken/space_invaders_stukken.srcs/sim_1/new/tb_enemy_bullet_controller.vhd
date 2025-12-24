library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_enemy_bullet_controller is
end tb_enemy_bullet_controller;

architecture sim of tb_enemy_bullet_controller is
    component enemy_bullet_controller
        Port (
            clk                : in STD_LOGIC;
            reset              : in STD_LOGIC;
            enemy_alive        : in STD_LOGIC_VECTOR(0 to 4);
            enemy_x            : in STD_LOGIC_VECTOR(0 to 49);
            enemy_y            : in integer range 0 to 479;
            shoot_trigger      : in STD_LOGIC;
            collision_detected : in STD_LOGIC;
            eb_x               : out integer range 0 to 639;
            eb_y               : out integer range 0 to 479;
            eb_active          : out STD_LOGIC
        );
    end component;

    signal clk                : STD_LOGIC := '0';
    signal reset              : STD_LOGIC := '0';
    signal enemy_alive        : STD_LOGIC_VECTOR(0 to 4) := "11111";
    signal enemy_x            : STD_LOGIC_VECTOR(0 to 49) := (others => '0');
    signal enemy_y            : integer := 100;
    signal shoot_trigger      : STD_LOGIC := '0';
    signal collision_detected : STD_LOGIC := '0';
    signal eb_x, eb_y         : integer;
    signal eb_active          : STD_LOGIC;

    constant clk_period : time := 40 ns;
begin
    uut: enemy_bullet_controller port map (
        clk => clk, reset => reset, enemy_alive => enemy_alive,
        enemy_x => enemy_x, enemy_y => enemy_y, shoot_trigger => shoot_trigger,
        collision_detected => collision_detected, eb_x => eb_x, eb_y => eb_y,
        eb_active => eb_active
    );

    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Vijanden positioneren (Alien 2 op x=300)
        enemy_x(20 to 29) <= std_logic_vector(to_unsigned(300, 10));
        reset <= '1'; wait for 100 ns;
        reset <= '0'; wait for 100 ns;

        -- Schot triggeren
        shoot_trigger <= '1';
        wait for 20 ms; 
        shoot_trigger <= '0';
        
        -- Kogel laten zakken
        wait for 100 ms;

        -- Botsing met speler simuleren
        collision_detected <= '1';
        wait for 100 ns;
        collision_detected <= '0';

        wait;
    end process;
end sim;