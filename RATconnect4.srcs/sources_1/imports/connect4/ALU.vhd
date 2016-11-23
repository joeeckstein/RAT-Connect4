--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- ALU
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
	Port ( 
		   A	  : in	STD_LOGIC_VECTOR (7 downto 0);
		   B	  : in	STD_LOGIC_VECTOR (7 downto 0);
		   C_IN	  : in	STD_LOGIC;
		   SEL	  : in	STD_LOGIC_VECTOR (3 downto 0);
		   SUM	  : out STD_LOGIC_VECTOR (7 downto 0);
		   C_FLAG : out STD_LOGIC;
		   Z_FLAG : out STD_LOGIC
		  );
end ALU;

architecture Behavioral of ALU is
	signal out_sig : STD_LOGIC_VECTOR (8 downto 0);
begin
	selector: process (A,B,C_IN,SEL)
	begin
		case SEL is
			when x"0" => out_sig <= '0'	 & A + B;				 --ADD
			when x"1" => out_sig <= '0'	 & A + B + C_IN;		 --ADDC
			when x"2" => out_sig <= '0'	 & A - B;				 --SUB
			when x"3" => out_sig <= '0'	 & A - B - C_IN;		 --SUBC
			when x"4" => out_sig <= '0'	 & A - B;				 --CMP
			when x"5" => out_sig <= '0'	 & (A AND B);			 --AND
			when x"6" => out_sig <= '0'	 & (A OR B);			 --OR
			when x"7" => out_sig <= '0'	 & (A XOR B);			 --EXOR
			when x"8" => out_sig <= '0'	 & (A AND B);			 --TEST
			when x"9" => out_sig <=	 A	 & C_IN;				 --LSL
			when x"A" => out_sig <= A(0) & C_IN & A(7 downto 1); --LSR
			when x"B" => out_sig <=	 A	 & A(7);				 --ROTL
			when x"C" => out_sig <= A(0) & A(0) & A(7 downto 1); --ROTR
			when x"D" => out_sig <= A(0) & A(7) & A(7 downto 1); --ASR
			when x"E" => out_sig <= '0'	 & B;					 --MOV
			when others => out_sig <= "ZZZZZZZZZ";
		end case;
	end process;
	SUM	   <= out_sig(7 downto 0);
	Z_FLAG <= '1' when out_sig(7 downto 0) = x"00" else '0';
	C_FLAG <= out_sig(8);
end Behavioral;
