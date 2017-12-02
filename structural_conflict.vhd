library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity structural_conflict is	-- MEM / IM conflict
	port(
		ID_EX_MemWrite : in std_logic;
		ALU_result_addr : in std_logic_vector(15 downto 0);
		
		IF_ID_Flush : out std_logic;
		ID_EX_Flush : out std_logic;
		PC_Rollback : out std_logic
	);
end structural_conflict;

architecture Behavioral of structural_conflict is
begin
	process(ID_EX_MemWrite, ALU_result_addr)
	begin
		if (ID_EX_MemWrite = '1' and 
			 ALU_result_addr <= x"7FFF" and ALU_result_addr >= x"4000") then	-- write IM
			IF_ID_Flush <= '1';
			ID_EX_Flush <= '1';
			PC_Rollback <= '1';
		else
			IF_ID_Flush <= '0';
			ID_EX_Flush <= '0';
			PC_Rollback <= '0';
		end if;
	end process;
end Behavioral;

