library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_WriteData is
	port(
		ForwardSW : in std_logic_vector(1 downto 0);
		ReadData2 : in std_logic_vector(15 downto 0);
		EX_MEM_ALUresult : in std_logic_vector(15 downto 0);	
		MEM_WB_result : in std_logic_vector(15 downto 0);	
		WriteData_out : out std_logic_vector(15 downto 0)
	);
end MUX_WriteData;

architecture Behavioral of MUX_WriteData is
begin
	process(MemtoReg,EX_MEM_ALUresult,MEM_WB_result)
	begin
		case MemtoReg is
			when '0' =>
				WriteData_out <= MEM_WB_result;
			when '1' =>
				WriteData_out <= EX_MEM_ALUresult;
			when others =>
		end case;
	end process;
end Behavioral;
