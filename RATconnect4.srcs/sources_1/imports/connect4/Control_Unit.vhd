--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- RAT CPU Control Unit
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CONTROL is
	Port ( CLK			 : in	STD_LOGIC;
		   C			 : in	STD_LOGIC;
		   Z			 : in	STD_LOGIC;
		   INT			 : in	STD_LOGIC;
		   RST			 : in	STD_LOGIC;
		   OPCODE_HI_5	 : in	STD_LOGIC_VECTOR (4 downto 0);
		   OPCODE_LO_2	 : in	STD_LOGIC_VECTOR (1 downto 0);

		   PC_LD		 : out	STD_LOGIC;
		   PC_INC		 : out	STD_LOGIC;
		   PC_RESET		 : out	STD_LOGIC;
		   PC_OE		 : out	STD_LOGIC;
		   PC_MUX_SEL	 : out	STD_LOGIC_VECTOR (1 downto 0);
		   SP_LD		 : out	STD_LOGIC;
		   SP_MUX_SEL	 : out	STD_LOGIC_VECTOR (1 downto 0);
		   SP_RESET		 : out	STD_LOGIC;
		   RF_WR		 : out	STD_LOGIC;
		   RF_WR_SEL	 : out	STD_LOGIC_VECTOR (1 downto 0);
		   RF_OE		 : out	STD_LOGIC;
		   REG_IMMED_SEL : out	STD_LOGIC;
		   ALU_SEL		 : out	STD_LOGIC_VECTOR (3 downto 0);
		   SCR_WR		 : out	STD_LOGIC;
		   SCR_OE		 : out	STD_LOGIC;
		   SCR_ADDR_SEL	 : out	STD_LOGIC_VECTOR (1 downto 0);
		   C_FLAG_SEL	 : out	STD_LOGIC;
		   C_FLAG_LD	 : out	STD_LOGIC;
		   C_FLAG_SET	 : out	STD_LOGIC;
		   C_FLAG_CLR	 : out	STD_LOGIC;
		   SHAD_C_LD	 : out	STD_LOGIC;
		   Z_FLAG_SEL	 : out	STD_LOGIC;
		   Z_FLAG_LD	 : out	STD_LOGIC;
		   Z_FLAG_SET	 : out	STD_LOGIC;
		   Z_FLAG_CLR	 : out	STD_LOGIC;
		   SHAD_Z_LD	 : out	STD_LOGIC;
		   I_FLAG_SET	 : out	STD_LOGIC;
		   I_FLAG_CLR	 : out	STD_LOGIC;
		   IO_OE		 : out	STD_LOGIC
		   );
end CONTROL;

architecture Behavioral of CONTROL is

	type state_type is (ST_init, ST_fet, ST_exec, ST_interrupt);
		signal PS,NS : state_type;
		
	signal sig_OPCODE_7: std_logic_vector (6 downto 0);
begin
	-- concatenate the all opcodes into a 7-bit complete opcode for
	-- easy instruction decoding.
	sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

	sync_p: process (CLK, NS, RST)
	begin
		if (RST = '1') then
			PS <= ST_init;
		elsif (rising_edge(CLK)) then 
			PS <= NS;
		end if;
	end process sync_p;


	comb_p: process (sig_OPCODE_7, PS, NS, C, Z, INT)
	begin
	case PS is
	
			-- STATE: the init cycle ------------------------------------
			-- Initialize all control outputs to non-active states and reset the PC and SP to all zeros.
			when ST_init => 
			  NS <= ST_fet;
				
				PC_LD		  <= '0';	PC_MUX_SEL <= "00";	  PC_RESET <= '1';		PC_OE	   <= '0';	PC_INC	  <= '0';
				SP_LD		  <= '0';	SP_MUX_SEL <= "00";	  SP_RESET <= '1';
				RF_WR		  <= '0';	RF_WR_SEL  <= "00";	  RF_OE	   <= '0';	
				REG_IMMED_SEL <= '0';	ALU_SEL	   <= "0000";
				SCR_WR		  <= '0';	SCR_OE	   <= '0';	  SCR_ADDR_SEL <= "00";							
				C_FLAG_SEL	  <= '0';	C_FLAG_LD  <= '0';	  C_FLAG_SET   <= '0';	C_FLAG_CLR <= '1';	SHAD_C_LD <= '0';
				Z_FLAG_SEL	  <= '0';	Z_FLAG_LD  <= '0';	  Z_FLAG_SET   <= '0';	Z_FLAG_CLR <= '1';	SHAD_Z_LD <= '0';
				I_FLAG_SET	  <= '0';	I_FLAG_CLR <= '0'; 
				IO_OE		  <= '0';		
				
			-- STATE: the fetch cycle -----------------------------------
			when ST_fet => 
			  NS <= ST_exec;

				PC_LD		  <= '0';	PC_MUX_SEL <= "00";	  PC_RESET <= '0';		PC_OE	   <= '0';	 PC_INC <= '1';
				SP_LD		  <= '0';	SP_MUX_SEL <= "00";	  SP_RESET <= '0';
				RF_WR		  <= '0';	RF_WR_SEL  <= "00";	  RF_OE	   <= '0';
				REG_IMMED_SEL <= '0';	ALU_SEL	   <= "0000";
				SCR_WR		  <= '0';	SCR_OE	   <= '0';	  SCR_ADDR_SEL <= "00";
				C_FLAG_SEL	  <= '0';	C_FLAG_LD  <= '0';	  C_FLAG_SET   <= '0';	C_FLAG_CLR <= '0';	SHAD_C_LD <= '0';
				Z_FLAG_SEL	  <= '0';	Z_FLAG_LD  <= '0';	  Z_FLAG_SET   <= '0';	Z_FLAG_CLR <= '0';	SHAD_Z_LD <= '0';
				I_FLAG_SET	  <= '0';	I_FLAG_CLR <= '0'; 
				IO_OE		  <= '0';					
				
			-- 3/2/2016 Changed SCR_ADDR_SEL to "11". Hopefully this will work.
			-- STATE: the interrupt cycle
			when ST_interrupt =>
			  NS <= ST_fet;				

				PC_LD		  <= '1';	PC_MUX_SEL <= "10";	  PC_RESET	<= '0';		PC_OE	   <= '1';	   PC_INC <= '0';
				SP_LD		  <= '1';	SP_MUX_SEL <= "10";	  SP_RESET	<= '0';
				RF_WR		  <= '0';	RF_WR_SEL  <= "00";	  RF_OE		<= '0';
				REG_IMMED_SEL <= '0';	ALU_SEL	   <= "0000";
				SCR_WR		  <= '1';	SCR_OE	   <= '0';	  SCR_ADDR_SEL <= "11";
				C_FLAG_SEL	  <= '0';	C_FLAG_LD  <= '0';	  C_FLAG_SET   <= '0';	C_FLAG_CLR <= '0';	   SHAD_C_LD <= '1';
				Z_FLAG_SEL	  <= '0';	Z_FLAG_LD  <= '0';	  Z_FLAG_SET   <= '0';	Z_FLAG_CLR <= '0';	   SHAD_Z_LD <= '1';
				I_FLAG_SET	  <= '0';	I_FLAG_CLR <= '1'; 
				IO_OE		  <= '0';
				
			-- STATE: the execute cycle ---------------------------------
			when ST_exec =>
			   if(INT = '0') then
				  NS <= ST_fet;
			   else
				  NS <= ST_interrupt;
			   end if;
				
				-- Repeat the default block for all variables here, noting that any output values desired to be different
				-- from init values shown below will be assigned in the following case statements for each opcode.
				PC_LD		  <= '0';	PC_MUX_SEL <= "00";	   PC_RESET <= '0';	   PC_OE		<= '0';		 PC_INC <= '0';
				SP_LD		  <= '0';	SP_MUX_SEL	<= "00";   SP_RESET		<= '0';
				RF_WR		  <= '0';	RF_WR_SEL	<= "00";   RF_OE		<= '0';
				REG_IMMED_SEL <= '0';	ALU_SEL		<= "0000";					
				SCR_WR		  <= '0';	SCR_OE		<= '0';	   SCR_ADDR_SEL <= "00";
				C_FLAG_SEL	  <= '0';	C_FLAG_LD	<= '0';	   C_FLAG_SET	<= '0';	 C_FLAG_CLR <= '0';	 SHAD_C_LD <= '0';
				Z_FLAG_SEL	  <= '0';	Z_FLAG_LD	<= '0';	   Z_FLAG_SET	<= '0';	 Z_FLAG_CLR <= '0';	 SHAD_Z_LD <= '0';
				I_FLAG_SET	  <= '0';	I_FLAG_CLR	<= '0'; 
				IO_OE		  <= '0';
				
				
			case sig_OPCODE_7 is
			
					-- ADD reg-reg ------------------
				when "0000100" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- ADD reg-immed ----------------
				when "1010000" | "1010001" | "1010010" | "1010011" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					REG_IMMED_SEL 	<= '1';
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- ADDC reg-reg -----------------
				when "0000101" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0001";
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- ADDC reg-immed ----------------
				when "1010100" | "1010101" | "1010110" | "1010111" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0001";
					REG_IMMED_SEL 	<= '1';
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- AND reg-reg -------------------
				when "0000000" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0101";
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- AND reg-immed -----------------
				when "1000000" | "1000001" | "1000010" | "1000011" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0101";
					REG_IMMED_SEL 	<= '1';
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
						
					-- ASR ---------------------------
				when "0100100" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "1101";
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- BRCC --------------------------
				when "0010101" =>
					if(C = '0') then
						PC_LD 		<= '1';
					else
						null;
					end if;
					
					-- BRCS --------------------------
				when "0010100" =>
					if(C = '1') then
						PC_LD 		<= '1';
					else
						null;
					end if;
					
					-- BREQ --------------------------
				when "0010010" =>
					if(Z = '1') then
						PC_LD 		<= '1';
					else
						null;
					end if;
			
					-- BRN ---------------------------
				when "0010000" =>
					PC_LD			<= '1';
					PC_MUX_SEL		<= "00";
					
					-- BRNE --------------------------
				when "0010011" =>
					if (Z = '0') then
						PC_LD		<= '1';
					else
						null;
					end if;
						
					-- CALL --------------------------
				when "0010001" =>
					PC_OE			<= '1';
					PC_LD			<= '1';
					SP_LD			<= '1';
					SP_MUX_SEL		<= "10";
					SCR_WR			<= '1';
					SCR_ADDR_SEL	<= "11";
					
					-- CLC ---------------------------
				when "0110000" =>
					C_FLAG_CLR		<= '1';
					
					-- CLI ---------------------------
				when "0110101" =>
					I_FLAG_CLR		<= '1';
					
					-- CMP reg-reg -------------------
				when "0001000" =>
					RF_OE			<= '1';
					ALU_SEL			<= x"4";
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					
					-- CMP reg-immed -----------------
				when "1100000" | "1100001" | "1100010" | "1100011" =>
					REG_IMMED_SEL 	<= '1';
					RF_OE			<= '1';
					ALU_SEL			<= x"4";
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					
					-- LD reg-reg --------------------
				when "0001010" =>
					RF_WR			<= '1';
					RF_WR_SEL		<= "01";
					SCR_OE			<= '1';
					
					-- LD reg-immed ------------------
				when "1110000" | "1110001" | "1110010" | "1110011" =>
					RF_WR			<= '1';
					RF_WR_SEL		<= "01";
					SCR_OE			<= '1';
					SCR_ADDR_SEL	<= "01";
					
					-- LSL ---------------------------
				when "0100000" =>
					RF_WR			<= '1';
					RF_OE			<= '1';
					ALU_SEL			<= x"9";
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					
					-- LSR ---------------------------
				when "0100001" =>
					RF_WR			<= '1';
					RF_OE			<= '1';
					ALU_SEL			<= x"A";
					C_FLAG_LD	 	<= '1';
					Z_FLAG_LD	 	<= '1';
					-- EXOR reg-reg ------------------
				when "0000010" =>
					RF_WR		  	<= '1';
					RF_OE		  	<= '1';
					ALU_SEL		  	<= "0111";
					Z_FLAG_LD	  	<= '1';
					
					-- EXOR reg-immed ----------------
				when "1001000" | "1001001" | "1001010" | "1001011" =>	
					RF_WR		  	<= '1';
					RF_OE		  	<= '1';
					ALU_SEL		  	<= "0111";
					REG_IMMED_SEL 	<= '1';
					Z_FLAG_LD	  	<= '1';

					-- IN ----------------------------
				when "1100100" | "1100101" | "1100110" | "1100111" =>
					RF_WR		  	<= '1';
					RF_WR_SEL	  	<= "11";
			   
					-- MOV reg-reg -------------------
				when "0001001" =>
					RF_WR		  	<= '1';
					ALU_SEL		  	<= x"E";
					Z_FLAG_LD	  	<= '1';
			   
					-- MOV reg-immed -----------------
				when "1101100" | "1101101" | "1101110" | "1101111" =>
					RF_WR		  	<= '1';
					ALU_SEL		  	<= x"E";
					REG_IMMED_SEL 	<= '1';
					
					-- OR reg-reg --------------------
				when "0000001"=>
					RF_WR		  	<= '1';
					RF_OE		  	<= '1';
					ALU_SEL		  	<= "0110";
					
					-- OR reg-immed ------------------
				when "1000100" | "1000101" | "1000110" | "1000111" =>
					RF_WR		  	<= '1';
					RF_OE		  	<= '1';
					ALU_SEL		  	<= "0110";
					REG_IMMED_SEL	<= '1';
					
					-- OUT ---------------------------
				when "1101000" | "1101001" | "1101010" | "1101011" =>
					RF_OE		  	<= '1';
					IO_OE		  	<= '1';
				
					-- POP ---------------------------
				when "0100110" =>
					RF_WR		  	<= '1';
					RF_WR_SEL	  	<= "01";
					SP_LD			<= '1';
					SP_MUX_SEL		<= "11";
					SCR_OE			<= '1';
					SCR_ADDR_SEL	<= "10";
					
					-- PUSH --------------------------
				when "0100101"=>
					SP_LD			<= '1';
					SP_MUX_SEL		<= "10";
					SCR_WR			<= '1';
					SCR_ADDR_SEL	<= "11";
					RF_OE			<= '1';
					
					-- RET ---------------------------
				when "0110010"=>
					PC_LD			<= '1';
					PC_MUX_SEL		<= "01";
					SP_MUX_SEL		<= "11";
					SP_LD			<= '1';
					SCR_OE			<= '1';
					SCR_ADDR_SEL	<= "10";
				
					-- RETID -------------------------
				when "0110110" =>
					PC_LD			<= '1';
					PC_MUX_SEL		<= "01";
					SP_MUX_SEL		<= "11";
					SP_LD			<= '1';
					SCR_OE			<= '1';
					SCR_ADDR_SEL	<= "10";
					C_FLAG_SEL		<= '1';
					Z_FLAG_SEL		<= '1';
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					I_FLAG_CLR		<= '1';
							
					-- RETIE -------------------------
				when "0110111" =>
					PC_LD			<= '1';
					PC_MUX_SEL		<= "01";
					SP_MUX_SEL		<= "11";
					SP_LD			 <= '1';
					SCR_OE			<= '1';
					SCR_ADDR_SEL	<= "10";
					C_FLAG_SEL		<= '1';
					Z_FLAG_SEL		<= '1';
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					I_FLAG_SET		<= '1';
										
					-- ROL ---------------------------
				when "0100010"=>
					RF_WR			<= '1';
					RF_OE			<= '1';
					ALU_SEL			<= "1011";
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					
					-- ROR ---------------------------
				when "0100011"=>
					RF_WR			<= '1';
					RF_OE			<= '1';
					ALU_SEL			<= "1010";
					C_FLAG_LD		<= '1';
					Z_FLAG_LD		<= '1';
					
					-- SEC ---------------------------
				when "0110001" =>
					C_FLAG_SET 		<= '1';
					
					-- SEI ---------------------------
				when "0110100" =>
					I_FLAG_SET 		<= '1';
					
					-- ST reg-reg --------------------
				when "0001011" =>
					SCR_WR 			<= '1';
					RF_OE  			<= '1';
					
					-- ST reg-immed ------------------
				when "1110100" | "1110101" | "1110110" | "1110111" =>
					SCR_WR 			<= '1';
					SCR_ADDR_SEL 	<= "01";
					RF_OE  			<= '1';
					
					-- SUB reg-reg -------------------
				when "0000110" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0010";
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- SUB reg-immed -----------------
				when "1011000" | "1011001" | "1011010" | "1011011" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0010";
					REG_IMMED_SEL 	<= '1';
					C_FLAG_LD		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- SUBC reg-reg ------------------
				when "0000111" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL			<= "0011";
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- SUBC reg-immed ----------------
				when "1011100" | "1011101" | "1011110" | "1011111" =>
					RF_WR 			<= '1';
					RF_OE 			<= '1';
					ALU_SEL 		<= "0011";
					REG_IMMED_SEL 	<= '1';
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- TEST --------------------------
				when "0000011" =>
					RF_OE 			<= '1';
					ALU_SEL 		<= "1000";
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
					-- TEST --------------------------
				when "1001100" | "1001101" | "1001110" | "1001111" =>
					ALU_SEL 		<= "1000";
					RF_OE 			<= '1';
					REG_IMMED_SEL 	<= '1';
					C_FLAG_LD 		<= '1';
					Z_FLAG_LD 		<= '1';
					
				  -- WSP -----------------------------
				when "0101000" =>
					RF_OE 			<= '1';
					SP_LD 			<= '1';	

				when others =>		
					-- repeat the default block here to avoid incompletely specified outputs and hence avoid
					-- the problem of inadvertently created latches within the synthesized system.
					PC_LD		  <= '0';	PC_MUX_SEL <= "00";	  PC_RESET <= '0';		PC_OE	   <= '0';	PC_INC	  <= '0';
					SP_LD		  <= '0';	SP_MUX_SEL <= "00";	  SP_RESET <= '0';
					RF_WR		  <= '0';	RF_WR_SEL  <= "00";	  RF_OE	   <= '0';
					REG_IMMED_SEL <= '0';	ALU_SEL	   <= "0000";
					SCR_WR		  <= '0';	SCR_OE	   <= '0';	  SCR_ADDR_SEL <= "00";							
					C_FLAG_SEL	  <= '0';	C_FLAG_LD  <= '0';	  C_FLAG_SET   <= '0';	C_FLAG_CLR <= '0';	SHAD_C_LD <= '0';
					Z_FLAG_SEL	  <= '0';	Z_FLAG_LD  <= '0';	  Z_FLAG_SET   <= '0';	Z_FLAG_CLR <= '0';	SHAD_Z_LD <= '0';
					I_FLAG_SET	  <= '0';	I_FLAG_CLR <= '0'; 
					IO_OE <= '0';		

			end case;

			when others => 
			NS <= ST_fet;
				
			-- repeat the default block here to avoid incompletely specified outputs and hence avoid
			-- the problem of inadvertently created latches within the synthesized system.
				PC_LD		  <= '0';	PC_MUX_SEL <= "00";	  PC_RESET <= '0';		PC_OE	   <= '0';	PC_INC	  <= '0';
				SP_LD		  <= '0';	SP_MUX_SEL <= "00";	  SP_RESET <= '0';
				RF_WR		  <= '0';	RF_WR_SEL  <= "00";	  RF_OE	   <= '0';
				REG_IMMED_SEL <= '0';	ALU_SEL	   <= "0000";
				SCR_WR		  <= '0';	SCR_OE	   <= '0';	  SCR_ADDR_SEL <= "00";
				C_FLAG_SEL	  <= '0';	C_FLAG_LD  <= '0';	  C_FLAG_SET   <= '0';	C_FLAG_CLR <= '0';	SHAD_C_LD <= '0';
				Z_FLAG_SEL	  <= '0';	Z_FLAG_LD  <= '0';	  Z_FLAG_SET   <= '0';	Z_FLAG_CLR <= '0';	SHAD_Z_LD <= '0';
				I_FLAG_SET	  <= '0';	I_FLAG_CLR <= '0';
				IO_OE <= '0';
				 
		end case;
	end process comb_p;
end Behavioral;




