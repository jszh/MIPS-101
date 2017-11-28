library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity structural_conflict is	-- MEM / IM conflict
	port(
		ID_EX_MemWrite : in std_logic;
		ALU_rst_addr : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		
		IF_ID_flush : out std_logic;
		ID_EX_flush : out std_logic;
		PC_rollback : out std_logic
	);
end structural_conflict;

architecture Behavioral of structural_conflict is
begin
	process(ID_EX_MemWrite, ALU_rst_addr)
	begin
		if (ID_EX_MemWrite = '1' and 
			 ALU_rst_addr <= x"7FFF" and ALU_rst_addr >= x"4000") then	-- write IM
			IF_ID_flush <= '1';
			ID_EX_flush <= '1';
			PC_rollback <= '1';
		else
			IF_ID_flush <= '0';
			ID_EX_flush <= '0';
			PC_rollback <= '0';
		end if;
	end process;
end Behavioral;

