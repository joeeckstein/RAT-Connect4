--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- VGA Driver, Adapted from given VGA driver
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGAdrive is
	port ( 	clk 		: in  std_logic;
			red, green  : in  std_logic_vector (2 downto 0);
			blue		: in  std_logic_vector (1 downto 0);
			row, column : out std_logic_vector (9 downto 0);
			Rout, Gout  : out std_logic_vector (2 downto 0);
			Bout		: out std_logic_vector (1 downto 0);
			H, V		: out std_logic);
end VGAdrive;

architecture Behavioral of VGAdrive is
	signal vertical		: std_logic_vector (9 downto 0);
	signal horizontal	: std_logic_vector (9 downto 0);
begin
    process (CLK)
    begin
	-- COUNTERs
	if (rising_edge(CLK)) then
		if (horizontal < 799) then
			horizontal <= horizontal + 1;
		else
			horizontal <= "00" & x"00";
			if (vertical < 524) then
				vertical <= vertical + 1;
			else
				vertical <= "00" & x"00";
			end if;
		end if;
		if ((horizontal >= 662) and (horizontal < 755)) then
			H <= '0';
		else
			H <= '1';
		end if;
		if ((vertical >= 491) and (vertical < 493)) then
			V <= '0';
		else
			V <= '1';
		end if;
		
		if ((vertical <= 479) and (horizontal <= 639)) then
			Rout <= red;
			Gout <= green;
			Bout <= blue;
		else
			Rout <= "000";
			Gout <= "000";
			Bout <= "00";
		end if;
	end if;
	end process;
	row <= vertical;
	column <= horizontal;
end Behavioral;