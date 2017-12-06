library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_SW is
	port(
		ForwardSW : in std_logic_vector(1 downto 0);
		ReadData2 : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	
		MEM_WB_result : in std_logic_vector(15 downto 0);	
		WriteData_out : out std_logic_vector(15 downto 0)
	);
end MUX_SW;

architecture Behavioral of MUX_SW is
begin
	process(ForwardSW, ReadData2, EX_MEM_result, MEM_WB_result)
	begin
		case ForwardSW is
			when "00" =>
				WriteData_out <= ReadData2;
			when "01" =>
				WriteData_out <= EX_MEM_result;
			when "10" =>
                WriteData_out <= MEM_WB_result;
			when others =>
		end case;
	end process;
end Behavioral;
