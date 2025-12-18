----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2025 14:37:45
-- Design Name: 
-- Module Name: debouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
  Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        btn_in : in STD_LOGIC;
        btn_out : out STD_LOGIC
        );
end debouncer;

architecture Behavioral of debouncer is
    signal btn_reg : STD_LOGIC := '0';
    signal counter : unsigned(17 downto 0) := (others => '0');
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            btn_out <= '0';
            btn_reg <= '0';
        elsif rising_edge(clk) then
            if btn_in = btn_reg then
                counter <= (others => '0');
            else
                counter <= counter + 1;
                if counter = 250000 then
                    btn_out <= btn_in;
                    btn_reg <= btn_in;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
