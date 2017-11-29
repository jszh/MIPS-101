library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_ID_EX is
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;

		LW_ID_EX_Flush : in std_logic;	-- LW data conflict
		Branch_ID_EX_Flush : in std_logic;	-- B
		Jump_ID_EX_Flush : in std_logic;	-- JR
		SW_ID_EX_Flush : in std_logic;	-- SW structural conflict
		
		PC_in : in std_logic_vector(15 downto 0);
		Rd_in : in std_logic_vector(3 downto 0);	--"0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1110"-n/a
		Reg1_in : in std_logic_vector(3 downto 0);	--"0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1011"-RA,"1111"-n/a
		Reg2_in : in std_logic_vector(3 downto 0);	--"0xxx"-R0~R7,"1000"-RA,"1111"-n/a
		ALUSrc_in : in std_logic;	-- '0'-reg, '1'-imme
		ReadData1_in : in std_logic_vector(15 downto 0);	-- Reg1 data
		ReadData2_in : in std_logic_vector(15 downto 0);	-- Reg2 data
		imme_in : in std_logic_vector(15 downto 0);	-- extended immediate
		
		MFPC_in : in std_logic;
		RegWrite_in : in std_logic;
		MemWrite_in : in std_logic;
		MemRead_in : in std_logic;
		MemToReg_in : in std_logic;
		Jump_in : in std_logic;
		Branch_in : in std_logic;
		ALUOp_in : in std_logic_vector(3 downto 0);
		
	
		PC_out : out std_logic_vector(15 downto 0);
		Rd_out : out std_logic_vector(3 downto 0);
		Reg1_out : out std_logic_vector(3 downto 0);
		Reg2_out : out std_logic_vector(3 downto 0);
		ALUSrc_out : out std_logic;
		ReadData1_out : out std_logic_vector(15 downto 0);
		ReadData2_out : out std_logic_vector(15 downto 0);			
		imme_out : out std_logic_vector(15 downto 0);
		
		MFPC_out : out std_logic;
		RegWrite_out : out std_logic;
		MemWrite_out : out std_logic;
		MemRead_out : out std_logic;
		MemToReg_out : out std_logic;
		Jump_out : out std_logic;
		ALUOp_out : out std_logic_vector(3 downto 0)
	);
end reg_ID_EX;

architecture Behavioral of reg_ID_EX is

begin
	process(clk, rst) -- should the flush signals be in the list?
	begin		
		if (rst = '0') then
			PC_out <= (others => '0');
			Rd_out <= "1110";
			Reg1_out <= "1111";
			Reg2_out <= "1111";
			ALUSrc_out <= '0';
			ReadData1_out <= (others => '0');
			ReadData2_out <= (others => '0');
			imme_out <= (others => '0');
			
			MFPC_out <= '0';
			RegWrite_out <= '0';
			MemWrite_out <= '0';
			MemRead_out <= '0';
			MemToReg_out <= '0';
			Jump_out <= '0';
			ALUOp_out <= "0000";
			
		elsif (clk'event and clk = '1') then
		if(flash_finished = '1') then
			if (LW_ID_EX_Flush = '1' or Branch_ID_EX_Flush = '1' or Jump_ID_EX_Flush = '1' or SW_ID_EX_Flush = '1') then
				
				PC_out <= (others => '0');
				Rd_out <= "1110";
				Reg1_out <= "1111";
				Reg2_out <= "1111";
				ALUSrc_out <= '0';
				ReadData1_out <= (others => '0');
				ReadData2_out <= (others => '0');
				imme_out <= (others => '0');
				
				MFPC_out <= '0';
				RegWrite_out <= '0';
				MemWrite_out <= '0';
				MemRead_out <= '0';
				MemToReg_out <= '0';
				Jump_out <= '0';
				ALUOp_out <= "0000";
				
			else
				
				PC_out <= PC_in;
				Rd_out <= Rd_in;
				Reg1_out <= Reg1_in;
				Reg2_out <= Reg2_in;
				ALUSrc_out <= ALUSrc_in;
				ReadData1_out <= ReadData1_in;
				ReadData2_out <= ReadData2_in;
				imme_out <= imme_in;
				
				MFPC_out <= MFPC_in;
				RegWrite_out <= RegWrite_in;
				MemWrite_out <= MemWrite_in;
				MemRead_out <= MemRead_in;
				MemToReg_out <= MemToReg_in;
				Jump_out <= Jump_in;
				ALUOp_out <= ALUOp_in;
			end if;
		end if;
		end if;
	end process;
end Behavioral;

