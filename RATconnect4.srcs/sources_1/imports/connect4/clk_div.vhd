--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- Main Clock Divider
-- Divides Board Clock by 2
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
	Port ( clk		: in STD_LOGIC;
		   rst		: in STD_LOGIC;
		   half_clk : out STD_LOGIC);
end clk_div;

architecture Behavioral of clk_div is

signal s_cnt : STD_LOGIC := '0';

begin
	process (clk, rst)
	begin
		if (rst = '0') then
			if (rising_edge(clk)) then
				s_cnt <= not s_cnt;
			else
				null;
			end if;
		else
			null;
		end if;
	end process;
	half_clk <= s_cnt;
end Behavioral;
