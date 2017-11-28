library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_B is
	port(
		ForwardB : in std_logic_vector(1 downto 0);
		ALUSrc : in std_logic;	-- choose imme / reg, from Controller
		ReadData2 : in std_logic_vector(15 downto 0);
		imme : in std_logic_vector(15 downto 0);
		EX_MEM_rst : in std_logic_vector(15 downto 0);	-- last instruction
		MEM_WB_rst : in std_logic_vector(15 downto 0);	-- last last instruction
		rstB : out std_logic_vector(15 downto 0)	-- output
	);	
end MUX_B;

architecture Behavioral of MUX_B is
	
begin
	process (ForwardB, ALUSrc, ReadData2, imme, EX_MEM_rst, MEM_WB_rst)
	begin
		if (ALUSrc = '1') then
			rstB <= imme;
		else
			case ForwardB is
				when "00" =>
					rstB <= ReadData2;
				when "01" =>
					rstB <= EX_MEM_rst;
				when "10" =>
					rstB <= MEM_WB_rst;
				when others =>
			end case;
		end if;

	end process;

end Behavioral;

