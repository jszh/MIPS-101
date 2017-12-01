library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_IF_ID is
	port(
		rst : in std_logic;
		clk : in std_logic;
		flash_finished : in std_logic;
		command_in : in std_logic_vector(15 downto 0);
		PC_in : in std_logic_vector(15 downto 0); 
		IF_ID_Keep : in std_logic;		--LW数据冲突用
		BJ_IF_ID_Flush : in std_logic;	-- branch_judge 结构冲突
		Branch_IF_ID_Flush : in std_logic;		--跳转时用
		Jump_IF_ID_Flush : in std_logic;		--JR跳转时用
		SW_IF_ID_Flush : in std_logic;			--SW结构冲突用
		
		Rs : out std_logic_vector(2 downto 0);		--Command[10:8]
		IF_ID_T : out std_logic;	--For branch judge forwarding
		Rt : out std_logic_vector(2 downto 0);		--Command[7:5]
		Rd : out std_logic_vector(2 downto 0);		--Command[4:2]
		imme_10_0 : out std_logic_vector(10 downto 0);	--Command[10:0]
		command_out : out std_logic_vector(15 downto 0);
		PC_out : out std_logic_vector(15 downto 0)  --PC+1用于MFPC指令的EXE段
	);
end reg_IF_ID;

architecture Behavioral of reg_IF_ID is
	signal tmpRs : std_logic_vector(2 downto 0);
	signal tmpT : std_logic;
	signal tmpRt : std_logic_vector(2 downto 0);
	signal tmpRd : std_logic_vector(2 downto 0);
	signal tmpImme : std_logic_vector(10 downto 0);
	signal tmpCommand : std_logic_vector(15 downto 0);
	signal tmpPC : std_logic_vector(15 downto 0);
	
begin
	Rs <= tmpRs;
	Rt <= tmpRt;
	Rd <= tmpRd;
	IF_ID_T <= tmpT;
	imme_10_0 <= tmpImme;
	command_out <= tmpCommand;
	PC_out <= tmpPC;
	process(rst, clk)
	begin 
		if (rst = '1') then	--遇到重置信号，直接清零
			tmpRs		<= (others => '0');
			tmpT		<= '0';
			tmpRt		<= (others => '0');
			tmpRd		<= (others => '0');
			tmpImme		<= (others => '0');
			tmpCommand	<= (others => '0');
			tmpPC		<= (others => '0');
		elsif (clk'event and clk = '1') then 
			if flash_finished = '1' then
				if (IF_ID_Keep = '1') then 
					null;
				elsif (BJ_IF_ID_Flush = '1' or SW_IF_ID_Flush = '1' or Branch_IF_ID_Flush = '1' or Jump_IF_ID_Flush = '1') then -- flush
				--IfIdFlush该不该放在时钟上升沿？？该不该放在IF_ID_Keep之后？？
					tmpRs		<= (others => '0');
					tmpT		<= '0';
					tmpRt		<= (others => '0');
					tmpRd		<= (others => '0');
					tmpImme		<= (others => '0');
					tmpCommand	<= (others => '0');
					tmpPC		<= (others => '0');
				else
					tmpRs		<= command_in(10 downto 8);

					if (command_in(15 downto 11) = "01100") then
						tmpT <= '1';
					else
						tmpT <= '0';
					end if;

					tmpRt		<= command_in(7 downto 5);
					tmpRd		<= command_in(4 downto 2);
					tmpImme		<= command_in(10 downto 0);
					tmpCommand	<= command_in;
					tmpPC		<= PC_in;
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

