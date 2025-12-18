library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity player_controller is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        btn_left  : in  STD_LOGIC;
        btn_right : in  STD_LOGIC;
        player_x  : out integer range 0 to 639
    );
end player_controller;

architecture Behavioral of player_controller is
    constant SCREEN_WIDTH  : integer := 640;
    constant PLAYER_WIDTH  : integer := 32;
    constant MOVE_SPEED    : integer := 2;
    
    signal x_pos        : integer range 0 to 639 := 300;
    signal move_counter : unsigned(19 downto 0) := (others => '0');

begin
    process(clk, reset)
    begin
        if reset = '1' then
            x_pos <= 300;
            move_counter <= (others => '0');
        elsif rising_edge(clk) then
            if move_counter = 416666 then 
                move_counter <= (others => '0');
                
                if btn_left = '1' and btn_right = '0' then
                    if x_pos >= MOVE_SPEED then
                        x_pos <= x_pos - MOVE_SPEED;
                    else
                        x_pos <= 0;
                    end if;
                elsif btn_right = '1' and btn_left = '0' then
                    if x_pos < (SCREEN_WIDTH - PLAYER_WIDTH - MOVE_SPEED) then
                        x_pos <= x_pos + MOVE_SPEED;
                    else
                        x_pos <= SCREEN_WIDTH - PLAYER_WIDTH;
                    end if;
                end if;
            else
                move_counter <= move_counter + 1;
            end if;
        end if;
    end process;
    player_x <= x_pos;
end Behavioral;