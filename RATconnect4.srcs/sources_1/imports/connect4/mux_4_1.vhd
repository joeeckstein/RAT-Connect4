--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le

-- VHDL description of the 4x1 MUX with a 10-bit input/output and a 2-bit select (Used with Program Counter)
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_4_1 is
	Port (	IN_0	: in STD_LOGIC_VECTOR (9 downto 0);
			IN_1	: in STD_LOGIC_VECTOR (9 downto 0);
			IN_2	: in STD_LOGIC_VECTOR (9 downto 0);
			IN_3	: in STD_LOGIC_VECTOR (9 downto 0);
			MUX_OUT : out STD_LOGIC_VECTOR (9 downto 0);
			SEL		: in STD_LOGIC_VECTOR (1 downto 0));
end MUX_4_1;

architecture Behavioral of MUX_4_1 is
begin
	process(SEL, IN_0, IN_1, IN_2, IN_3)
	begin
		case SEL is
			when "00"	=> MUX_OUT <= IN_0;
			when "01"	=> MUX_OUT <= IN_1;
			when "10"	=> MUX_OUT <= IN_2;
			when others => MUX_OUT <= IN_3;
		end case;
	end process;
end Behavioral;

--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- VHDL description of the 4x1 MUX with a 8-bit input/output and a 2-bit select (Used with the register file)
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX7_4_1 is
	Port (	IN_0	: in STD_LOGIC_VECTOR (7 downto 0);
			IN_1	: in STD_LOGIC_VECTOR (7 downto 0);
			IN_2	: in STD_LOGIC_VECTOR (7 downto 0);
			IN_3	: in STD_LOGIC_VECTOR (7 downto 0);
			MUX_OUT : out STD_LOGIC_VECTOR (7 downto 0);
			SEL		: in STD_LOGIC_VECTOR (1 downto 0));
end MUX7_4_1;

architecture Behavioral of MUX7_4_1 is
begin
	process(SEL, IN_0, IN_1, IN_2, IN_3)
	begin
		case SEL is
			when "00"	=> MUX_OUT <= IN_0;
			when "01"	=> MUX_OUT <= IN_1;
			when "10"	=> MUX_OUT <= IN_2;
			when others => MUX_OUT <= IN_3;
		end case;
	end process;
end Behavioral;

