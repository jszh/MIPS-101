----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:00:32 11/22/2016 
-- Design Name: 
-- Module Name:    StructConflictUnit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity StructConflictUnit is
	--SWдָ���ڴ� �ṹ��ͻ
	port(
		IdExMemWrite : in std_logic;
		ALUResultAsAddr : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		
		IfIdFlush : out std_logic;		--IF/ID�����¸�ʱ�ӵ���ʱ����
		IdExFlush : out std_logic;		--ID/EX�����¸�ʱ�ӵ���ʱ����
		PCRollback : out std_logic		--PCMux��ѡ��PC
	);
end StructConflictUnit;

architecture Behavioral of StructConflictUnit is

begin
	process(IdExMemWrite, ALUResultAsAddr)
	begin
		if (IdExMemWrite = '1' and 
			 ALUResultAsAddr <= x"7FFF" and ALUResultAsAddr >= x"4000") then	--���SW��ҪдIM����IMû��
			IfIdFlush <= '1';
			IdExFlush <= '1';
			PCRollback <= '1';
		else
			IfIdFlush <= '0';
			IdExFlush <= '0';
			PCRollback <= '0';
		end if;
	end process;
end Behavioral;

