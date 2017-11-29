library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_B is
	port(
		ForwardB : in std_logic_vector(1 downto 0);
		ALUSrc : in std_logic;	-- choose imme / reg, from Controller
		ReadData2 : in std_logic_vector(15 downto 0);
		imme : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- prev instruction
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- prev prev instruction

		Bsrc_out : out std_logic_vector(15 downto 0)	-- output
	);	
end MUX_B;

architecture Behavioral of MUX_B is
	
begin
	process (ForwardB, ALUSrc, ReadData2, imme, EX_MEM_result, MEM_WB_result)
	begin
		if (ALUSrc = '1') then
			Bsrc_out <= imme;
		else
			case ForwardB is
				when "00" =>
					Bsrc_out <= ReadData2;
				when "01" =>
					Bsrc_out <= EX_MEM_result;
				when "10" =>
					Bsrc_out <= MEM_WB_result;
				when others =>
			end case;
		end if;

	end process;

end Behavioral;

