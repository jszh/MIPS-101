library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_MEM_WB is
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;
		--数据
		ReadMemData_in : in std_logic_vector(15 downto 0);	--DataMemory读出的数据
		ALUresult_in : in std_logic_vector(15 downto 0);		--ALU的计算结果
		Rd_in : in std_logic_vector(3 downto 0);				--目的寄存器
		--控制信号
		RegWrite_in : in std_logic;		--是否要写回
		MemToReg_in : in std_logic;		--写回时选择ReadMemData_in（'0'）还是ALUresult_in（'1'）
		
		data_to_WB : out std_logic_vector(15 downto 0);		--写回的数据
		Rd_out : out std_logic_vector(3 downto 0);				--目的寄存器："0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1110"-没有目的寄存器
		RegWrite_out : out std_logic								--是否要写回
	);
end reg_MEM_WB;

architecture Behavioral of reg_MEM_WB is

begin
	process(rst, clk)
	begin
		if (rst = '1') then
			data_to_WB <= (others => '0');
			Rd_out <= "1110";
			RegWrite_out <= '0';
		elsif (clk'event and clk = '1') then
			if (flash_finished = '1') then
				Rd_out <= Rd_in;
				RegWrite_out <= RegWrite_in;
				if (MemToReg_in = '1') then
					data_to_WB <= ALUresult_in;
				elsif (MemToReg_in = '0') then
					data_to_WB <= ReadMemData_in;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

