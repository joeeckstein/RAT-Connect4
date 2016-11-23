--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein and Michael Le
-- VHDL description of the program counter with the MUX as a port map
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity p_counter is
	Port (	FROM_IMMED	: in STD_LOGIC_VECTOR (9 downto 0);
			FROM_STACK	: in STD_LOGIC_VECTOR (9 downto 0);
			FROM_INTRR	: in STD_LOGIC_VECTOR (9 downto 0);
			PC_MUX_SEL	: in STD_LOGIC_VECTOR (1 downto 0);
			PC_OE		: in STD_LOGIC;
			PC_LD	 	: in STD_LOGIC;
			PC_INC		: in STD_LOGIC;
			RST		 	: in STD_LOGIC;
			CLK		   	: in STD_LOGIC;
			PC_COUNT   	: out STD_LOGIC_VECTOR (9 downto 0);
			PC_TRI	   	: out STD_LOGIC_VECTOR (9 downto 0)
			);
end p_counter;

architecture Behavioral of p_counter is
component MUX_4_1
	Port (	IN_0		: in STD_LOGIC_VECTOR (9 downto 0);
			IN_1		: in STD_LOGIC_VECTOR (9 downto 0);
			IN_2		: in STD_LOGIC_VECTOR (9 downto 0);
			IN_3		: in STD_LOGIC_VECTOR (9 downto 0);
			MUX_OUT 	: out STD_LOGIC_VECTOR (9 downto 0);
			SEL			: in STD_LOGIC_VECTOR (1 downto 0));
end component;

	signal D_IN_SIG 	: STD_LOGIC_VECTOR (9 downto 0);
	signal PC_SIG		: STD_LOGIC_VECTOR (9 downto 0);

begin
input_mux: MUX_4_1
		port map(
		IN_0	=> FROM_IMMED,
		IN_1	=> FROM_STACK,
		IN_2	=> FROM_INTRR,
		IN_3	=> "ZZZZZZZZZZ",
		MUX_OUT => D_IN_SIG,
		SEL		=> PC_MUX_SEL
		);

process(CLK,RST)
	begin
		if (RST = '0') then
			if rising_edge(clk) then
				if (PC_LD = '1') then
					PC_SIG <= D_IN_SIG;
				elsif (PC_INC = '1') then
					PC_SIG <= (PC_SIG + 1);
				end if;
			end if;
		else
			PC_SIG <= "0000000000";
		end if;
end process;

PC_COUNT	<= PC_SIG;
PC_TRI		<= PC_SIG when PC_OE='1' else (others=>'Z');


end Behavioral;
