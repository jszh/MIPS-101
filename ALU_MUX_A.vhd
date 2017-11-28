library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_A is
	port(
		ForwardA : in std_logic_vector(1 downto 0);	-- forwarding control
		ReadData1 : in std_logic_vector(15 downto 0);	-- ReadData selection
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- EX/MEM forwarding
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- MEM/WB forwarding

		Asrc_out : out std_logic_vector(15 downto 0)	-- output
	);
end MUX_A;

architecture Behavioral of MUX_A is

begin
	process (ForwardA, ReadData1, EX_MEM_result, MEM_WB_result)
	begin
		case ForwardA is
			when "00" =>
				Asrc_out <= ReadData1;
			when "01" =>
				Asrc_out <= EX_MEM_result;
			when "10" =>
				Asrc_out <= MEM_WB_result;
			when others =>
		end case;
	end process;
end Behavioral;
