library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_BJ is
	-- Branch judge input: ReadData1 or forwarding?
	port(
		ForwardBJ : in std_logic_vector(1 downto 0);	-- forwarding control
		ReadData1 : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- EX/MEM forwarding
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- MEM/WB forwarding

		MUX_BJ_out : out std_logic_vector(15 downto 0)	-- output
	);
end MUX_BJ;

architecture Behavioral of MUX_BJ is

begin
	process (ForwardBJ, ReadData1, EX_MEM_result, MEM_WB_result)
	begin
		case ForwardBJ is
			when "00" =>
				MUX_BJ_out <= ReadData1;
			when "01" =>
				MUX_BJ_out <= EX_MEM_result;
			when "10" =>
				MUX_BJ_out <= MEM_WB_result;
			when others =>
		end case;
	end process;
end Behavioral;