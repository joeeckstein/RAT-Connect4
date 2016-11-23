--
-- CPE 233-01
-- Brenan Balbido, Joe Eckstein, and Michael Le
-- RAT Top Level Wrapper
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAT_wrapper is
	Port ( LEDS		: out	STD_LOGIC_VECTOR (7 downto 0);
		   VGA_RGB	: out	STD_LOGIC_VECTOR (7 downto 0);
		   Hsync	: out	STD_LOGIC;
		   Vsync	: out	STD_LOGIC;
		   SWITCHES : in	STD_LOGIC_VECTOR (7 downto 0);
		   RST		: in	STD_LOGIC;
		   CLK		: in	STD_LOGIC;
		   INT		: in	STD_LOGIC;
		   an		: out	STD_LOGIC_VECTOR (3 downto 0);
		   seg		: out	STD_LOGIC_VECTOR (7 downto 0));
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   CONSTANT DECODER_IDa : STD_LOGIC_VECTOR (7 downto 0) := X"95";
   CONSTANT DECODER_IDb : STD_LOGIC_VECTOR (7 downto 0) := X"96";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT SSEG_ID		: STD_LOGIC_VECTOR (7 downto 0) := X"81";
   CONSTANT LEDS_ID		: STD_LOGIC_VECTOR (7 downto 0) := X"40";
   CONSTANT VGA_HADDR	: STD_LOGIC_VECTOR (7 downto 0) := X"90";
   CONSTANT VGA_VADDR	: STD_LOGIC_VECTOR (7 downto 0) := X"91";
   CONSTANT VGA_COLOR	: STD_LOGIC_VECTOR (7 downto 0) := X"92";
   CONSTANT COL_ADDR	: STD_LOGIC_VECTOR (7 downto 0) := X"93";
   CONSTANT ROW_ADDR	: STD_LOGIC_VECTOR (7 downto 0) := X"94";
   -------------------------------------------------------------------------------

   -- Declare RAT_CPU ------------------------------------------------------------
   component RAT_CPU 
	   Port ( IN_PORT   : in  STD_LOGIC_VECTOR (7 downto 0);
			  OUT_PORT  : out STD_LOGIC_VECTOR (7 downto 0);
			  PORT_ID   : out STD_LOGIC_VECTOR (7 downto 0);
			  IO_OE	    : out STD_LOGIC;
			  RST	    : in  STD_LOGIC;
			  INT	    : in  STD_LOGIC;
			  CLK	   	: in  STD_LOGIC);
   end component RAT_CPU;
   
   -- Master Clock Divider --------------------------------------------------------
   component clk_div
		Port ( clk		: in  STD_LOGIC;
			   rst		: in  STD_LOGIC;
			   half_clk : out STD_LOGIC);
   end component;
	
	-- Interrupt Button Debounce --------------------------------------------------
	component db_1shot_FSM
	   Port ( A	   		: in  STD_LOGIC;
			  CLK  		: in  STD_LOGIC;
			  A_DB 		: out STD_LOGIC);
	end component;
	
	-- VGA DRIVER ------------------------------------------------------------------
	component vgaDriverBuffer
		Port ( CLK, we 	: in  std_logic;
			   we		: in  std_logic;
			   wa		: in  std_logic_vector (10 downto 0);
			   wd		: in  std_logic_vector (7 downto 0);
			   Rout 	: out std_logic_vector(2 downto 0);
			   Gout 	: out std_logic_vector(2 downto 0);
			   Bout 	: out std_logic_vector(1 downto 0);
			   HS		: out std_logic;
			   VS		: out std_logic;
			  pixelData : out std_logic_vector(7 downto 0)
			   );
	end component;
	
	component sseg_dec
		Port ( ALU_VAL : in  std_logic_vector(7 downto 0); 
				  SIGN : in  std_logic;
				 VALID : in  std_logic;
				   CLK : in  std_logic;
			   DISP_EN : out std_logic_vector(3 downto 0);
			  SEGMENTS : out std_logic_vector(7 downto 0)
			  );
	end component;
	
	component grid_decode
		Port (gridcol  : in	 std_logic_vector(3 downto 0);
			  gridrow  : in	 std_logic_vector(3 downto 0);
			  vgaaddr  : out std_logic_vector(10 downto 0));
	 end component;
	-- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
	signal s_input_port  : std_logic_vector (7 downto 0);
	signal s_output_port : std_logic_vector (7 downto 0);
	signal s_port_id	 : std_logic_vector (7 downto 0);
	signal s_load		 : std_logic;
	signal s_clk		 : std_logic;
	signal s_interrupt	 : std_logic; -- not yet used
   
   signal r_gridcol		 : std_logic_vector (3 downto 0);
   signal r_gridrow		 : std_logic_vector (3 downto 0);
   signal r_vgaaddr		 : std_logic_vector (10 downto 0);
   
	-- VGA Signals --
	signal s_vga_we		 : std_logic;
	signal s_vga_wa		 : std_logic_vector (10 downto 0);
	signal s_vga_wd		 : std_logic_vector (7 downto 0);
	signal r_vgaData	 : std_logic_vector (7 downto 0);
	
	-- Register definitions for output devices ------------------------------------
	signal r_LEDS		 : std_logic_vector (7 downto 0); 
	signal r_SSEG		 : std_logic_vector (7 downto 0);
	-------------------------------------------------------------------------------

begin

	-- Instantiate RAT_CPU --------------------------------------------------------
	CPU_Wrapper: RAT_CPU
	port map( IN_PORT  	=> s_input_port,
			  OUT_PORT 	=> s_output_port,
			  PORT_ID  	=> s_port_id,
			  RST	   	=> RST,	
			  IO_OE	   	=> s_load,
			  INT	   	=> s_interrupt,
			  CLK	   	=> s_clk);		
				
	-------------------------------------------------------------------------------
	MyClk: clk_div
	port map ( clk		=> CLK,
			   rst		=> RST,
			   half_clk => s_clk);


	grid_vga: grid_decode 
	port map( gridcol 	=> r_gridcol,
			  gridrow 	=> r_gridrow,
			  vgaaddr 	=> r_vgaaddr);
	------------------------------------------------------------------------------- 
	-- MUX for selecting what input to read ---------------------------------------
	-------------------------------------------------------------------------------
	inputs: process(s_port_id, SWITCHES, r_vgaaddr)
	begin
		if (s_port_id = SWITCHES_ID) then
			s_input_port <= SWITCHES;
		elsif (s_port_id = DECODER_IDa) then
			s_input_port <= r_vgaaddr (7 downto 0);
		elsif (s_port_id = DECODER_IDb) then
			s_input_port <= "00000" & r_vgaaddr (10 downto 8);
		else
			s_input_port <= x"00";
		end if;
	end process inputs;
	-------------------------------------------------------------------------------
	
	player_display: sseg_dec
	port map ( ALU_VAL 	=> r_SSEG,
				  SIGN 	=> '0',
				 VALID 	=> '1',
				   CLK 	=> s_clk,
			   DISP_EN 	=> an,
			  SEGMENTS 	=> seg);
	
	my_int_db: db_1shot_FSM
	port map ( A		=> INT,
			   CLK		=> s_clk,
			   A_DB 	=> s_interrupt);

	-------------------------------------------------------------------------------
	-- MUX for updating output registers ------------------------------------------
	-- Register updates depend on rising clock edge and asserted load signal
	-------------------------------------------------------------------------------
	outputs: process(s_clk) 
	begin	
		if (rising_edge(s_clk)) then
			if (s_load = '1') then 
--				-- the register definition for the LEDS
				if (s_port_id = LEDS_ID) then
					r_LEDS <= s_output_port;
				elsif (s_port_id = SSEG_ID) then
					r_SSEG <= s_output_port;
				elsif (s_port_id = VGA_HADDR) then
					s_vga_wa (10 downto 8) <= s_output_port (2 downto 0);
				elsif (s_port_id = VGA_VADDR) then
					s_vga_wa (7 downto 0) <= s_output_port(7 downto 0);
				elsif (s_port_id = VGA_COLOR) then
					s_vga_wd <= s_output_port;
				elsif (s_port_id = COL_ADDR) then
					r_gridcol <= s_output_port (3 downto 0);
				elsif (s_port_id = ROW_ADDR) then
					r_gridrow <= s_output_port (3 downto 0);
				end if;
			end if; 
			if ( s_port_id = VGA_COLOR and (s_output_port /= "ZZZZZZZZ")) then
				s_vga_we <= '1';
			else
				s_vga_we <= '0';
			end if;
		end if;
	end process outputs;
	-------------------------------------------------------------------------------
	
	my_display: vgaDriverBuffer
	port map ( CLK		 => s_clk,
			   we		 => s_vga_we,
			   wa		 => s_vga_wa,
			   wd		 => s_vga_wd,
			   Rout		 => VGA_RGB(7 downto 5),
			   Gout		 => VGA_RGB(4 downto 2),
			   Bout		 => VGA_RGB(1 downto 0),
			   HS		 => Hsync,
			   VS		 => Vsync,
			   pixelData => r_vgaData);
	
	-- Register Interface Assignments ---------------------------------------------
	LEDS 				<= r_LEDS; 

end Behavioral;
