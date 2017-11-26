library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WriteDataMux is
	port(
		MemtoReg : in std_logic_vector(1 downto 0);
		ExMemALUResult : in std_logic_vector(15 downto 0);	
		MemWbResult : in std_logic_vector(15 downto 0);	
		WriteDataOut : out std_logic_vector(15 downto 0)
	);
end WriteDataMux;

architecture Behavioral of WriteDataMux is

begin
	process(MemtoReg,ExMemALUResult,MemWbResult)
	begin
		case MemtoReg is
			when "0000000000000000" =>
				WriteDataOut <= MemWbResult;
			when "0000000000000001" =>
				WriteDataOut <= ExMemALUResult;
			when others =>
		end case;
	end process;


end Behavioral;

