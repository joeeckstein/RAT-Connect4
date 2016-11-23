--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- Hardware Lookup table to convert game grid coordinates to pixels
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity grid_decode is
	Port ( gridcol : in  std_logic_vector(3 downto 0);
		   gridrow : in  std_logic_vector(3 downto 0);
		   vgaaddr : out std_logic_vector(10 downto 0));
end grid_decode;

architecture Behavioral of grid_decode is
begin
	decoder: process (gridcol, gridrow)
	begin
		if    ((gridcol = X"1") and (gridrow = X"6")) then vgaaddr <= "000" & x"05";
		elsif ((gridcol = X"2") and (gridrow = X"6")) then vgaaddr <= "000" & x"0A";
		elsif ((gridcol = X"3") and (gridrow = X"6")) then vgaaddr <= "000" & x"0F";
		elsif ((gridcol = X"4") and (gridrow = X"6")) then vgaaddr <= "000" & x"14";
		elsif ((gridcol = X"5") and (gridrow = X"6")) then vgaaddr <= "000" & x"19";
		elsif ((gridcol = X"6") and (gridrow = X"6")) then vgaaddr <= "000" & x"1E";
		elsif ((gridcol = X"7") and (gridrow = X"6")) then vgaaddr <= "000" & x"23";
		elsif ((gridcol = X"1") and (gridrow = X"5")) then vgaaddr <= "001" & x"45";
		elsif ((gridcol = X"2") and (gridrow = X"5")) then vgaaddr <= "001" & x"4A";
		elsif ((gridcol = X"3") and (gridrow = X"5")) then vgaaddr <= "001" & x"4F";
		elsif ((gridcol = X"4") and (gridrow = X"5")) then vgaaddr <= "001" & x"54";
		elsif ((gridcol = X"5") and (gridrow = X"5")) then vgaaddr <= "001" & x"59";
		elsif ((gridcol = X"6") and (gridrow = X"5")) then vgaaddr <= "001" & x"5E";
		elsif ((gridcol = X"7") and (gridrow = X"5")) then vgaaddr <= "001" & x"63";
		elsif ((gridcol = X"1") and (gridrow = X"4")) then vgaaddr <= "010" & x"85";
		elsif ((gridcol = X"2") and (gridrow = X"4")) then vgaaddr <= "010" & x"8A";
		elsif ((gridcol = X"3") and (gridrow = X"4")) then vgaaddr <= "010" & x"8F";
		elsif ((gridcol = X"4") and (gridrow = X"4")) then vgaaddr <= "010" & x"94";
		elsif ((gridcol = X"5") and (gridrow = X"4")) then vgaaddr <= "010" & x"99";
		elsif ((gridcol = X"6") and (gridrow = X"4")) then vgaaddr <= "010" & x"9E";
		elsif ((gridcol = X"7") and (gridrow = X"4")) then vgaaddr <= "010" & x"A3";
		elsif ((gridcol = X"1") and (gridrow = X"3")) then vgaaddr <= "011" & x"C5";
		elsif ((gridcol = X"2") and (gridrow = X"3")) then vgaaddr <= "011" & x"CA";
		elsif ((gridcol = X"3") and (gridrow = X"3")) then vgaaddr <= "011" & x"CF";
		elsif ((gridcol = X"4") and (gridrow = X"3")) then vgaaddr <= "011" & x"D4";
		elsif ((gridcol = X"5") and (gridrow = X"3")) then vgaaddr <= "011" & x"D9";
		elsif ((gridcol = X"6") and (gridrow = X"3")) then vgaaddr <= "011" & x"DE";
		elsif ((gridcol = X"7") and (gridrow = X"3")) then vgaaddr <= "011" & x"E3";
		elsif ((gridcol = X"1") and (gridrow = X"2")) then vgaaddr <= "101" & x"05";
		elsif ((gridcol = X"2") and (gridrow = X"2")) then vgaaddr <= "101" & x"0A";
		elsif ((gridcol = X"3") and (gridrow = X"2")) then vgaaddr <= "101" & x"0F";
		elsif ((gridcol = X"4") and (gridrow = X"2")) then vgaaddr <= "101" & x"14";
		elsif ((gridcol = X"5") and (gridrow = X"2")) then vgaaddr <= "101" & x"19";
		elsif ((gridcol = X"6") and (gridrow = X"2")) then vgaaddr <= "101" & x"1E";
		elsif ((gridcol = X"7") and (gridrow = X"2")) then vgaaddr <= "101" & x"23";
		elsif ((gridcol = X"1") and (gridrow = X"1")) then vgaaddr <= "110" & x"45";
		elsif ((gridcol = X"2") and (gridrow = X"1")) then vgaaddr <= "110" & x"4A";
		elsif ((gridcol = X"3") and (gridrow = X"1")) then vgaaddr <= "110" & x"4F";
		elsif ((gridcol = X"4") and (gridrow = X"1")) then vgaaddr <= "110" & x"54";
		elsif ((gridcol = X"5") and (gridrow = X"1")) then vgaaddr <= "110" & x"59";
		elsif ((gridcol = X"6") and (gridrow = X"1")) then vgaaddr <= "110" & x"5E";
		elsif ((gridcol = X"7") and (gridrow = X"1")) then vgaaddr <= "110" & x"63";
		else vgaaddr <= "000" & x"00";
		end if;
	end process;
end Behavioral;