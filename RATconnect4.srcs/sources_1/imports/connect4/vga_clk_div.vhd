--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- Clock Divider for VGA
-- Adapted from provided VGA Driver
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_clk_div is
    Port ( clk      : in STD_LOGIC;
           clkout   : out STD_LOGIC);
end vga_clk_div;

architecture Behavioral of vga_clk_div is

signal s_cnt : STD_LOGIC := '0';

begin
    process (clk)
    begin
        if (rising_edge(clk)) then
            s_cnt <= not s_cnt;
        else
            null;
        end if;
    end process;
    clkout <= s_cnt;
end Behavioral;
