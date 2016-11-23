--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- Scratchpad
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Scratch_Pad is
	Port ( SCR_ADDR : in    STD_LOGIC_VECTOR (7 downto 0);
		   SCR_OE	: in    STD_LOGIC;
		   SCR_WE	: in    STD_LOGIC;
		   CLK		: in    STD_LOGIC;
		   SCR_DATA : inout STD_LOGIC_VECTOR (9 downto 0));
end Scratch_Pad;

architecture Behavioral of Scratch_Pad is
TYPE memory is array (0 to 255) of std_logic_vector(9 downto 0);
	SIGNAL SCR: memory := (others=>(others=>'0'));
begin

	process(CLK)
	begin
		if (rising_edge(clk)) then
			if (SCR_WE = '1') then
				SCR(conv_integer(SCR_ADDR)) <= SCR_DATA;
			end if;
		end if;
	end process;
	
	SCR_DATA <= SCR(conv_integer(SCR_ADDR)) when SCR_OE = '1'
				and SCR_WE='0' else (others=>'Z');

end Behavioral;
