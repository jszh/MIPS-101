library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC_MUX_add is
	port(
		PC_addOne : in std_logic_vector(15 downto 0);
		IF_ID_imme : in std_logic_vector(15 downto 0);
		IF_ID_PC : in std_logic_vector(15 downto 0);
		Asrc_out : in std_logic_vector(15 downto 0);
		
		Jump : in std_logic;	-- Jump signal
		BranchJudge : in std_logic;		-- from branch_judge
		PC_Rollback : in std_logic;		-- SW数据冲突时，PC需要回退到SW下一条指令①的地址，而当前的PC+1是③的地址，所以此时PC_out = PC_addOne - 2;
		
		PC_out : out std_logic_vector(15 downto 0)
	);
end PC_MUX_add;

architecture Behavioral of PC_MUX_add is
begin
	process(PC_addOne, ID_EX_imme, Asrc_out, Jump, BranchJudge)
	begin
		if (BranchJudge = '1' and Jump = '0') then
			PC_out <= ID_EX_imme + ID_EX_PC;
		elsif (Jump = '1' and BranchJudge = '0') then
			PC_out <= Asrc_out;
		elsif (Jump = '0' and BranchJudge = '0') then
			if (PC_Rollback = '1') then
				PC_out <= PC_addOne - "0000000000000010";	--PC_out = PC_addOne - 2;
			elsif (PC_Rollback = '0') then
				PC_out <= PC_addOne;
			end if;
		end if;
	
	end process;
end Behavioral;

