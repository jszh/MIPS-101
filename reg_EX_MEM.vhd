library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_EX_MEM is
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		flashFinished : in std_logic;

		--数据输入
		rdIn : in std_logic_vector(3 downto 0);
		MFPCMuxIn : in std_logic_vector(15 downto 0);
		readData2In : in std_logic_vector(15 downto 0); --供SW语句写内存
		--信号输入
		regWriteIn : in std_logic;
		memReadIn : in std_logic;
		memWriteIn : in std_logic;
		memToRegIn : in std_logic;

		--数据输出
		rdOut : out std_logic_vector(3 downto 0);
		ALUResultOut : out std_logic_vector(15 downto 0);
		readData2Out : out std_logic_vector(15 downto 0); --供SW语句写内存
		--信号输出
		regWriteOut : out std_logic;
		memReadOut : out std_logic;
		memWriteOut : out std_logic;
		memToRegOut : out std_logic
	);
end reg_EX_MEM;

architecture Behavioral of reg_EX_MEM is

begin
	process(rst, clk)
	begin
		if (rst = '0') then
			rdOut <= "1110";
			ALUResultOut <= (others => '0');
			readData2Out <= (others => '0');
			
			regWriteOut <= '0';
			memReadOut <= '0';
			memWriteOut <= '0';
			memToRegOut <= '0';

		elsif (clk'event and clk = '1') then
		if(flashFinished = '1') then
			rdOut <= rdIn;
			ALUResultOut <= MFPCMuxIn;
			readData2Out <= readData2In;
			
			regWriteOut <= regWriteIn;
			memReadOut <= memReadIn;
			memWriteOut <= memWriteIn;
			memToRegOut <= memToRegIn;
		end if;
		end if;
	end process;
end Behavioral;

