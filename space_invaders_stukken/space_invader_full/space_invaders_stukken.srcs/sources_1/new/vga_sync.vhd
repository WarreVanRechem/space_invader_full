----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2025 14:26:08
-- Design Name: 
-- Module Name: vga_sync - Behavioral
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

entity vga_sync is
  Port ( 
        clk : in STD_LOGIC;
        clr : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        hc : out STD_LOGIC_VECTOR(9 downto 0);
        vc : out STD_LOGIC_VECTOR(9 downto 0);
        vidon : out STD_LOGIC
        );
end vga_sync;

architecture Behavioral of vga_sync is
    constant HD: integer := 640;
    constant HF: integer := 16;
    constant HB: integer := 48;
    constant HR: integer := 96;
    constant HT: integer := HD + HF + HB +HR - 1;
    
    constant VD: integer := 480;
    constant VF: integer := 10;
    constant VB: integer := 33;
    constant VR: integer := 2;
    constant VT: integer := VD + VF + VB + VR - 1;
    
    signal hcount: integer range 0 to HT := 0;
    signal vcount: integer range 0 to VT := 0;
begin
    process(clk, clr)
    begin
        if clr = '1' then
            hcount <= 0;
            vcount <= 0;
        elsif rising_edge(clk) then
            if hcount = HT then
                hcount <= 0;
                if vcount = VT then 
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
                end if;
            else
                hcount <= hcount + 1;
            end if;
        end if;
    end process;
    hsync <= '0' when (hcount >= HD + HF) and (hcount <= HD + HF + HR -1) else '1';
    vsync <= '0' when (vcount >= VD + VF) and (vcount <= VD + VF + VR - 1) else '1';
    vidon <= '1' when (hcount < HD) and (vcount < VD) else '0';
    
    hc <= std_logic_vector(to_unsigned(hcount, 10));
    vc <= std_logic_vector(to_unsigned(vcount, 10));
end Behavioral;
