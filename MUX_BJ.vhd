library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_BJ is
	-- Branch judge input: ReadData1 or forwarding?
	port(
		ForwardBJ : in std_logic_vector(1 downto 0);	-- forwarding control
		ReadData1 : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- EX/MEM forwarding
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- MEM/WB forwarding

		BJsrc_out : out std_logic_vector(15 downto 0)	-- output
	);
end MUX_BJ;

architecture Behavioral of MUX_BJ is

begin
	process (ForwardA, ReadData1, EX_MEM_result, MEM_WB_result)
	begin
		case ForwardA is
			when "00" =>
				BJsrc_out <= ReadData1;
			when "01" =>
				BJsrc_out <= EX_MEM_result;
			when "10" =>
				BJsrc_out <= MEM_WB_result;
			when others =>
		end case;
	end process;
end Behavioral;