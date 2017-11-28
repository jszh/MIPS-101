library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_IF_ID is
	port(
		rst : in std_logic;
		clk : in std_logic;
		flashFinished : in std_logic;
		commandIn : in std_logic_vector(15 downto 0);
		PCIn : in std_logic_vector(15 downto 0); 
		IfIdKeep : in std_logic;		--LW数据冲突用
		Branch_IfIdFlush : in std_logic;		--跳转时用
		Jump_IfIdFlush : in std_logic;		--JR跳转时用
		SW_IfIdFlush : in std_logic;			--SW结构冲突用
		
		rx : out std_logic_vector(2 downto 0);		--Command[10:8]
		ry : out std_logic_vector(2 downto 0);		--Command[7:5]
		rz : out std_logic_vector(2 downto 0);		--Command[4:2]
		imme_10_0 : out std_logic_vector(10 downto 0);	--Command[10:0]
		commandOut : out std_logic_vector(15 downto 0);
		PCOut : out std_logic_vector(15 downto 0)  --PC+1用于MFPC指令的EXE段
	);
end reg_IF_ID;

architecture Behavioral of reg_IF_ID is
	signal tmpRx : std_logic_vector(2 downto 0);
	signal tmpRy : std_logic_vector(2 downto 0);
	signal tmpRz : std_logic_vector(2 downto 0);
	signal tmpImme : std_logic_vector(10 downto 0);
	signal tmpCommand : std_logic_vector(15 downto 0);
	signal tmpPC : std_logic_vector(15 downto 0);
	
begin
	rx <= tmpRx;
	ry <= tmpRy;
	rz <= tmpRz;
	imme_10_0 <= tmpImme;
	commandOut <= tmpCommand;
	PCOut <= tmpPC;
	process(rst, clk)
	begin 
		if (rst = '0') then	--遇到重置信号，直接清零
			tmpRx 		<= (others => '0');
			tmpRy 		<= (others => '0');
			tmpRz 		<= (others => '0');
			tmpImme 		<= (others => '0');
			tmpCommand 	<= (others => '0');
			tmpPC 		<= (others => '0');
		elsif (clk'event and clk = '1') then 
			if flashFinished = '1' then
				if (IfIdKeep = '1') then 
					null;
				elsif (SW_IfIdFlush = '1' or Branch_IfIdFlush = '1' or Jump_IfIdFlush = '1') then --IfIdFlush该不该放在时钟上升沿？？该不该放在IfIdKeep之后？？
					tmpRx 		<= (others => '0');
					tmpRy 		<= (others => '0');
					tmpRz 		<= (others => '0');
					tmpImme 		<= (others => '0');
					tmpCommand 	<= (others => '0');
					tmpPC 		<= (others => '0');
				else
					tmpRx 		<= commandIn(10 downto 8);
					tmpRy 		<= commandIn(7 downto 5);
					tmpRz 		<= commandIn(4 downto 2);
					tmpImme 		<= commandIn(10 downto 0);
					tmpCommand	<= commandIn;
					tmpPC 		<= PCIn;
				
				end if;
			end if;
		end if;
	end process;
	

end Behavioral;

