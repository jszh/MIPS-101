library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_EX_MEM is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		flash_finished : in std_logic;

		--数据输入
		Rd_in : in std_logic_vector(3 downto 0);
		MFPCMux_in : in std_logic_vector(15 downto 0);
		ReadData2_in : in std_logic_vector(15 downto 0); --供SW语句写内存
		--信号输入
		RegWrite_in : in std_logic;
		MemRead_in : in std_logic;
		MemWrite_in : in std_logic;
		MemToReg_in : in std_logic;

		--数据输出
		Rd_out : out std_logic_vector(3 downto 0);
		ALUResult_out : out std_logic_vector(15 downto 0);
		ReadData2_out : out std_logic_vector(15 downto 0); --供SW语句写内存
		--信号输出
		RegWrite_out : out std_logic;
		MemRead_out : out std_logic;
		MemWrite_out : out std_logic;
		MemToReg_out : out std_logic
	);
end reg_EX_MEM;

architecture Behavioral of reg_EX_MEM is

begin
	process(rst, clk)
	begin
		if (rst = '0') then
			Rd_out <= "1110";
			ALUResult_out <= (others => '0');
			ReadData2_out <= (others => '0');
			
			RegWrite_out <= '0';
			MemRead_out <= '0';
			MemWrite_out <= '0';
			MemToReg_out <= '0';

		elsif (clk'event and clk = '1') then
		if(flash_finished = '1') then
			Rd_out <= Rd_in;
			ALUResult_out <= MFPCMux_in;
			ReadData2_out <= ReadData2_in;
			
			RegWrite_out <= RegWrite_in;
			MemRead_out <= MemRead_in;
			MemWrite_out <= MemWrite_in;
			MemToReg_out <= MemToReg_in;
		end if;
		end if;
	end process;
end Behavioral;

