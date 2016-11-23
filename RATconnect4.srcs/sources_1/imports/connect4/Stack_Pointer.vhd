--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- Stack Pointer
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Stack_Pointer is
	Port ( LD     : in  STD_LOGIC;
		   RST    : in  STD_LOGIC;
		   IN_sp  : in  STD_LOGIC_VECTOR (7 downto 0);
		   CLK    : in  STD_LOGIC;
		   OUT_sp : out STD_LOGIC_VECTOR (7 downto 0));
end Stack_Pointer;

architecture Behavioral of Stack_Pointer is

	signal pointer : STD_LOGIC_VECTOR (7 downto 0);

begin
	process(CLK, RST)
	begin
		if(RST = '0') then
			if (rising_edge(CLK)) then
				if (LD = '1') then
					pointer <= IN_sp;
				else
					null;
				end if;
			end if;
		else
			pointer <= x"00";
		end if;
	end process;
	
	OUT_sp <= pointer;


end Behavioral;
