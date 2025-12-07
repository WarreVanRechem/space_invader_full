library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity enemy_controller is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        enemy_hit   : in  STD_LOGIC_VECTOR(0 to 4);
        enemy_x     : out STD_LOGIC_VECTOR(0 to 49);
        enemy_y     : out integer range 0 to 479;      -- NIEUW
        enemy_alive : out STD_LOGIC_VECTOR(0 to 4)
    );
end enemy_controller;

architecture Behavioral of enemy_controller is
    constant ENEMY_WIDTH : integer := 24;
    type enemy_x_array is array (0 to 4) of integer range 0 to 639;
    signal ex : enemy_x_array := (100, 200, 300, 400, 500);
    signal ey : integer range 0 to 479 := 80;
    signal alive : STD_LOGIC_VECTOR(0 to 4) := (others => '1');
    signal direction : STD_LOGIC := '1'; -- '1' = rechts
    signal move_counter : unsigned(21 downto 0) := (others => '0');
    signal down_counter : unsigned(25 downto 0) := (others => '0');
begin
    process(clk, reset)
        variable temp_ex : enemy_x_array;
        variable need_change : STD_LOGIC := '0';
    begin
        if reset = '1' then
            ex <= (100, 200, 300, 400, 500);
            ey <= 80;
            alive <= (others => '1');
            direction <= '1';
            move_counter <= (others => '0');
            down_counter <= (others => '0');
        elsif rising_edge(clk) then
            -- Hit afhandelen
            for i in 0 to 4 loop
                if enemy_hit(i) = '1' then
                    alive(i) <= '0';
                end if;
            end loop;

            move_counter <= move_counter + 1;
            down_counter <= down_counter + 1;

            -- Zijwaartse beweging (~60 Hz)
            if move_counter = 416667 then
                move_counter <= (others => '0');
                temp_ex := ex;
                need_change := '0';

                for i in 0 to 4 loop
                    if alive(i) = '1' then
                        if direction = '1' and temp_ex(i) >= 639 - ENEMY_WIDTH then
                            need_change := '1';
                        elsif direction = '0' and temp_ex(i) <= 0 then
                            need_change := '1';
                        end if;
                    end if;
                end loop;

                if need_change = '1' then
                    direction <= not direction;
                    ey <= ey + 16;  -- klassiek: zakken bij kant raken
                else
                    for i in 0 to 4 loop
                        if alive(i) = '1' then
                            if direction = '1' then
                                temp_ex(i) := temp_ex(i) + 1;
                            else
                                temp_ex(i) := temp_ex(i) - 1;
                            end if;
                        end if;
                    end loop;
                end if;
                ex <= temp_ex;
            end if;

            -- Extra langzaam zakken (elke ~2 sec)
            if down_counter = 50_000_000 then
                down_counter <= (others => '0');
                ey <= ey + 4;
            end if;
        end if;
    end process;

    -- Output x-posities
    gen_out: for i in 0 to 4 generate
        enemy_x(i*10 to i*10+9) <= std_logic_vector(to_unsigned(ex(i), 10));
    end generate;

    enemy_y     <= ey;
    enemy_alive <= alive;
end Behavioral;