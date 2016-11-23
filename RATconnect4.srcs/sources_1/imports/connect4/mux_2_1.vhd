--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- Definition of the MUX used to select the input to the ALU
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_2_1 is
	Port (	IN_0	: in STD_LOGIC_VECTOR (7 downto 0);
			IN_1	: in STD_LOGIC_VECTOR (7 downto 0);
			MUX_OUT : out STD_LOGIC_VECTOR (7 downto 0);
			SEL		: in STD_LOGIC);
end MUX_2_1;

architecture Behavioral of MUX_2_1 is
begin
	process(SEL, IN_0, IN_1)
	begin
		case SEL is
			when '0'	=> MUX_OUT <= IN_0;
			when others => MUX_OUT <= IN_1;
		end case;
	end process;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FLAG_MUX is
	Port (	IN_0	: in STD_LOGIC;
			IN_1	: in STD_LOGIC;
			MUX_OUT : out STD_LOGIC;
			SEL		: in STD_LOGIC);
end FLAG_MUX;

architecture Behavioral of FLAG_MUX is
begin
	process(SEL, IN_0, IN_1)
	begin
		case SEL is
			when '0'	=> MUX_OUT <= IN_0;
			when others => MUX_OUT <= IN_1;
		end case;
	end process;
end Behavioral;


