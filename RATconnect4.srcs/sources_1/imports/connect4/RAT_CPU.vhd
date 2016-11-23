--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- RAT CPU
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_CPU is
	Port ( IN_PORT			 : in  STD_LOGIC_VECTOR (7 downto 0);
		   RST				 : in  STD_LOGIC;
		   CLK				 : in  STD_LOGIC;
		   INT				 : in  STD_LOGIC;
		   OUT_PORT 		 : out STD_LOGIC_VECTOR (7 downto 0);
		   PORT_ID			 : out STD_LOGIC_VECTOR (7 downto 0);
		   IO_OE			 : out STD_LOGIC);
end RAT_CPU;



architecture Behavioral of RAT_CPU is

	component prog_rom	
		port (	  ADDRESS 	 : in std_logic_vector(9 downto 0); 
			  INSTRUCTION 	 : out std_logic_vector(17 downto 0); 
				      CLK 	 : in std_logic);	 
	end component;

	component ALU
		Port ( A	  	  	 : in	STD_LOGIC_VECTOR (7 downto 0);
			   B	  	  	 : in	STD_LOGIC_VECTOR (7 downto 0);
			   C_IN	  	  	 : in	STD_LOGIC;
			   SEL	  	  	 : in	STD_LOGIC_VECTOR(3 downto 0);
			   C_flag 	  	 : out	STD_LOGIC;
			   Z_flag 	  	 : out	STD_LOGIC;
			   SUM	  	  	 : out	STD_LOGIC_VECTOR (7 downto 0));
	end component;

	component CONTROL
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
			   SHAD_Z_LD	 : out	STD_LOGIC;
			   I_FLAG_SET	 : out	STD_LOGIC;
			   I_FLAG_CLR	 : out	STD_LOGIC;
			   IO_OE		 : out	STD_LOGIC);
	end component;

	component RegisterFile 
		Port ( D_IN	  		 : in	STD_LOGIC_VECTOR (7 downto 0);
			   DX_OUT 		 : out	STD_LOGIC_VECTOR (7 downto 0);
			   DY_OUT 		 : out	STD_LOGIC_VECTOR (7 downto 0);
			   ADRX	  		 : in	STD_LOGIC_VECTOR (4 downto 0);
			   ADRY	  		 : in	STD_LOGIC_VECTOR (4 downto 0);
			   DX_OE  		 : in	STD_LOGIC;
			   WE	  		 : in	STD_LOGIC;
			   CLK	  		 : in	STD_LOGIC);
   end component;

	component p_counter 
		Port ( FROM_IMMED 	 : in 	STD_LOGIC_VECTOR (9 downto 0);
			   FROM_STACK 	 : in 	STD_LOGIC_VECTOR (9 downto 0);
			   FROM_INTRR 	 : in 	STD_LOGIC_VECTOR (9 downto 0);
			   PC_MUX_SEL 	 : in 	STD_LOGIC_VECTOR (1 downto 0);
			   PC_OE	  	 : in 	STD_LOGIC;
			   PC_LD	  	 : in 	STD_LOGIC;
			   PC_INC	  	 : in	STD_LOGIC;
			   RST		  	 : in 	STD_LOGIC;
			   CLK		  	 : in 	STD_LOGIC;
			   PC_COUNT	  	 : out 	STD_LOGIC_VECTOR (9 downto 0);
			   PC_TRI	  	 : out 	STD_LOGIC_VECTOR (9 downto 0));
	end component; 
   
	component FlagReg
		Port ( IN_FLAG		 : in  	STD_LOGIC; --flag input
			   LD			 : in  	STD_LOGIC; --load the out_flag with the in_flag value
			   SET			 : in  	STD_LOGIC; --set the flag to '1'
			   CLR			 : in  	STD_LOGIC; --clear the flag to '0'
			   CLK			 : in  	STD_LOGIC; --system clock
			   OUT_FLAG 	 : out 	STD_LOGIC); --flag output
	end component;
	
	component FLAG_MUX
		Port (	IN_0		 : in 	STD_LOGIC;
				IN_1		 : in 	STD_LOGIC;
				MUX_OUT 	 : out 	STD_LOGIC;
				SEL			 : in 	STD_LOGIC);
	end component;
	
	component mux_2_1
		Port (	IN_0	 	 : in 	STD_LOGIC_VECTOR (7 downto 0);
				IN_1		 : in 	STD_LOGIC_VECTOR (7 downto 0);
				MUX_OUT 	 : out 	STD_LOGIC_VECTOR (7 downto 0);
				SEL			 : in 	STD_LOGIC);
	end component;
	
	component MUX7_4_1
		Port (	IN_0		 : in 	STD_LOGIC_VECTOR (7 downto 0);
				IN_1		 : in 	STD_LOGIC_VECTOR (7 downto 0);
				IN_2		 : in 	STD_LOGIC_VECTOR (7 downto 0);
				IN_3		 : in 	STD_LOGIC_VECTOR (7 downto 0);
				MUX_OUT 	 : out 	STD_LOGIC_VECTOR (7 downto 0);
				SEL			 : in 	STD_LOGIC_VECTOR (1 downto 0));
	end component;
	
	component Stack_Pointer
		Port ( LD	  	 	 : in 	STD_LOGIC;
			   RST	  		 : in 	STD_LOGIC;
			   IN_sp  		 : in 	STD_LOGIC_VECTOR (7 downto 0);
			   CLK	  		 : in 	STD_LOGIC;
			   OUT_sp 		 : out 	STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component Scratch_Pad
		Port ( SCR_ADDR 	 : in 	STD_LOGIC_VECTOR (7 downto 0);
			   SCR_OE		 : in 	STD_LOGIC;
			   SCR_WE		 : in 	STD_LOGIC;
			   CLK			 : in 	STD_LOGIC;
			   SCR_DATA 	 : inout STD_LOGIC_VECTOR (9 downto 0));
	end component;

   -- intermediate signals ----------------------------------
	signal s_pc_ld			 : std_logic 					:= '0'; 
	signal s_pc_inc			 : std_logic 					:= '0'; 
	signal s_pc_oe			 : std_logic 					:= '0'; 
	signal s_pc_rst			 : std_logic 					:= '0'; 
	signal s_pc_mux_sel 	 : std_logic_vector(1 downto 0) := "00"; 
	signal s_pc_count		 : std_logic_vector(9 downto 0) := (others => '0');	 
	signal s_inst_reg		 : std_logic_vector(17 downto 0):= (others => '0'); 
   
	signal s_multi_bus		 : std_logic_vector(9 downto 0) := (others => '0'); 
	
	
	-- ALU SIGNALS --
	signal s_y				 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_b			 	 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_alu_result 	 : std_logic_vector(7 downto 0) := (others => '0');
	
	-- Control Unit Signals --
	signal s_reg_immed_sel 	 : std_logic 					:= '0';
	signal s_alu_sel	   	 : std_logic_vector(3 downto 0) := (others => '0');
	
	-- Register File Signals --
	signal s_rf_wr_data 	 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_rf_wr_sel		 : std_logic_vector(1 downto 0) := (others => '0');
	signal s_dx_oe			 : std_logic 					:= '0';
	signal s_rf_wr			 : std_logic 					:= '0';
	
	-- Flag Signals --
	signal s_c_flag 		 : std_logic 					:= '0';
	signal s_c_alu			 : std_logic 					:= '0';
	signal s_c_set			 : std_logic 					:= '0';
	signal s_c_ld			 : std_logic 					:= '0';
	signal s_c_clr			 : std_logic 					:= '0';
	
	signal s_z_flag 		 : std_logic 					:= '0';
	signal s_z_alu			 : std_logic 					:= '0';
	signal s_z_ld			 : std_logic 					:= '0';
	
	signal s_shad_z_sel 	 : std_logic 					:= '0'; --
	signal s_shad_c_sel 	 : std_logic 					:= '0';
	
	signal s_shad_z_ld 	 	 : std_logic 					:= '0';
	signal s_shad_c_ld 	 	 : std_logic 					:= '0';
	
	signal s_shad_z_out 	 : std_logic 					:= '0';
	signal s_shad_c_out 	 : std_logic 					:= '0';
	
	signal s_shad_z_in 		 : std_logic 					:= '0';
	signal s_shad_c_in 		 : std_logic 					:= '0'; --
	
	-- Scratch Pad Signals --
	
	signal s_scr_addr 		 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_scr_wr	  		 : std_logic 					:= '0';
	signal s_scr_oe	  		 : std_logic 					:= '0';
	signal s_sp_in	  		 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_sp_rst	  		 : std_logic 					:= '0';
	signal s_sp_ld	  		 : std_logic 					:= '0';
	signal s_sp_out	  		 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_sp_mux_sel 	 : std_logic_vector(1 downto 0) := (others => '0');
	signal s_sp_minus 		 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_sp_plus  		 : std_logic_vector(7 downto 0) := (others => '0');
	signal s_scr_addr_sel 	 : std_logic_vector(1 downto 0) := (others => '0');
	
   -- helpful aliases ------------------------------------------------------------------
	alias s_ir_immed_bits 	 : std_logic_vector(9 downto 0) is s_inst_reg(12 downto 3); 
	
	-- i flag -------------------------------
	signal s_i_clr			 : std_logic 					:= '0';
	signal s_i_set			 : std_logic 					:= '0';
	signal s_i_flag 		 : std_logic 					:= '0';
	signal s_i_and			 : std_logic 					:= '0';
   
begin

	my_prog_rom: prog_rom  
	port map(	  ADDRESS 	 => s_pc_count, 
			  INSTRUCTION 	 => s_inst_reg, 
					  CLK 	 => CLK); 
					  
	alu_b_mux: mux_2_1
	port map ( IN_0	   		 => s_y,
			   IN_1	   		 => s_inst_reg(7 downto 0),
			   MUX_OUT 		 => s_b,
			   SEL	   		 => s_reg_immed_sel);
			    
	my_alu: ALU
	port map ( A	  		 => s_multi_bus(7 downto 0),
			   B	  		 => s_b,
			   C_IN	  		 => s_c_flag,
			   SEL	  		 => s_alu_sel,
			   C_flag 		 => s_c_alu,
			   Z_flag 		 => s_z_alu,
			   SUM	  		 => s_alu_result);


	control_unit: CONTROL 
	port map ( CLK			 => CLK, 
			   C			 => s_c_flag, 
			   Z			 => s_z_flag, 
			   INT			 => s_i_and, 
			   RST			 => RST, 
			   OPCODE_HI_5	 => s_inst_reg(17 downto 13), 
			   OPCODE_LO_2	 => s_inst_reg(1 downto 0), 
			   
			   PC_LD		 => s_pc_ld, 
			   PC_INC		 => s_pc_inc, 
			   PC_RESET		 => s_pc_rst, 
			   PC_OE		 => s_pc_oe, 
			   PC_MUX_SEL	 => s_pc_mux_sel, 
			   SP_LD		 => s_sp_ld, 
			   SP_MUX_SEL	 => s_sp_mux_sel, 
			   SP_RESET		 => s_sp_rst, 
			   RF_WR		 => s_rf_wr, 
			   RF_WR_SEL	 => s_rf_wr_sel, 
			   RF_OE		 => s_dx_oe, 
			   REG_IMMED_SEL => s_reg_immed_sel, 
			   ALU_SEL		 => s_alu_sel, 
			   SCR_WR		 => s_scr_wr, 
			   SCR_OE		 => s_scr_oe, 
			   SCR_ADDR_SEL	 => s_scr_addr_sel, 
			   C_FLAG_SEL	 => s_shad_c_sel, 
			   C_FLAG_LD	 => s_c_ld, 
			   C_FLAG_SET	 => s_c_set, 
			   C_FLAG_CLR	 => s_c_clr, 
			   SHAD_C_LD	 => s_shad_c_ld, 
			   Z_FLAG_SEL	 => s_shad_z_sel, 
			   Z_FLAG_LD	 => s_z_ld, 
			   SHAD_Z_LD	 => s_shad_z_ld, 
			   I_FLAG_SET	 => s_i_set, 
			   I_FLAG_CLR	 => s_i_clr, 
			   IO_OE		 => IO_OE);
			   

	regfile_mux: MUX7_4_1
	port map ( IN_0	   		 => s_alu_result,
			   IN_1	   		 => s_multi_bus(7 downto 0),
			   IN_2	   		 => "ZZZZZZZZ",
			   IN_3	   		 => IN_PORT,
			   MUX_OUT 		 => s_rf_wr_data,
			   SEL	   		 => s_rf_wr_sel);

	regfile: RegisterFile 
	port map ( D_IN	  		 => s_rf_wr_data,	 
			   DX_OUT 		 => s_multi_bus(7 downto 0),	 
			   DY_OUT 		 => s_y,	 
			   ADRX	  		 => s_inst_reg(12 downto 8),	 
			   ADRY	  		 => s_inst_reg(7 downto 3),	 
			   DX_OE  		 => s_dx_oe,	 
			   WE	  		 => s_rf_wr,	 
			   CLK	  		 => CLK); 

	program_counter: p_counter 
	port map ( RST		  	 => s_pc_rst,
			   CLK		  	 => CLK,
			   PC_LD	  	 => s_pc_ld,
			   PC_OE	  	 => s_pc_oe,
			   PC_INC	  	 => s_pc_inc,
			   FROM_IMMED 	 => s_ir_immed_bits,
			   FROM_STACK 	 => s_multi_bus,
			   FROM_INTRR 	 => "11" & x"FF",
			   PC_MUX_SEL 	 => s_pc_mux_sel,
			   PC_COUNT	  	 => s_pc_count,
			   PC_TRI	  	 => s_multi_bus); 
			   
	c_mux: FLAG_MUX
	port map( IN_0			 => s_c_alu,
			  IN_1			 => s_shad_c_out,
			  MUX_OUT		 => s_shad_c_in,
			  SEL			 => s_shad_c_sel);

	c_reg: FlagReg
	port map( IN_FLAG  		 => s_shad_c_in,
			  LD	   		 => s_c_ld,
			  SET	   		 => s_c_set,
			  CLR	   		 => s_c_clr,
			  CLK	   		 => CLK,
			  OUT_FLAG 		 => s_c_flag);
			  	
	shad_c_reg: FlagReg	
	port map( IN_FLAG  		 => s_c_alu,
			  LD	   		 => s_c_ld,
			  SET	   		 => s_c_set,
			  CLR	   		 => s_c_clr,
			  CLK	   		 => CLK,
			  OUT_FLAG 		 => s_shad_c_out);
			  	
	z_mux: FLAG_MUX	
	port map( IN_0			 => s_z_alu,
			  IN_1			 => s_shad_z_out,
			  MUX_OUT		 => s_shad_z_in,
			  SEL			 => s_shad_z_sel);
			  	
	z_reg: FlagReg	
	port map( IN_FLAG  		 => s_shad_z_in,
			  LD	   		 => s_z_ld,
			  SET	   		 => '0',
			  CLR	   		 => '0',
			  CLK	   		 => CLK,
			  OUT_FLAG 		 => s_z_flag);
			  	
	shad_z_reg: FlagReg	
	port map( IN_FLAG  		 => s_z_alu,
			  LD	  		 => s_z_ld,
			  SET	  		 => '0',
			  CLR	  		 => '0',
			  CLK	  		 => CLK,
			  OUT_FLAG 		 => s_shad_z_out);
			  	
	i_flag: FlagReg	
	port map( IN_FLAG 		 => '0',
			  LD	  		 => '0',
			  SET	  		 => s_i_set,
			  CLR	  		 => s_i_clr,
			  CLK	  		 => CLK,
			  OUT_FLAG 		 => s_i_flag);
			  	
	s_pad: Scratch_Pad	
	port map( SCR_ADDR 		 => s_scr_addr,
			  SCR_OE   		 => s_scr_oe,
			  SCR_WE   		 => s_scr_wr,
			  CLK	   		 => CLK,
			  SCR_DATA 		 => s_multi_bus (9 downto 0));
	
	s_pointer : Stack_Pointer
	port map( LD	 		 => s_sp_ld,
			  RST	 		 => s_sp_rst,
			  IN_sp	 		 => s_sp_in,
			  CLK	 		 => CLK,
			  OUT_sp 		 => s_sp_out);
	
	s_sp_minus <= (s_sp_out - 1);
	s_sp_plus <= (s_sp_out + 1);
	
	point_mux: MUX7_4_1
	port map ( IN_0	   		 => s_multi_bus (7 downto 0),
			   IN_1	   		 => "ZZZZZZZZ",
			   IN_2	   		 => s_sp_minus,
			   IN_3	   		 => s_sp_plus,
			   MUX_OUT 		 => s_sp_in,
			   SEL	   		 => s_sp_mux_sel); 
			   
	s_pad_mux: MUX7_4_1
	port map ( IN_0	   		 => s_y,
			   IN_1	   		 => s_inst_reg (7 downto 0),
			   IN_2	   		 => s_sp_out,
			   IN_3	   		 => s_sp_minus,
			   MUX_OUT 		 => s_scr_addr,
			   SEL	   		 => s_scr_addr_sel);
	
	s_i_and 				 <= (INT and s_i_flag);
	PORT_ID 				 <= s_inst_reg(7 downto 0);
	OUT_PORT 				 <= s_multi_bus(7 downto 0);
	
end Behavioral;

