library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_A is
	port(
		ForwardA : in std_logic_vector(1 downto 0);	-- forwarding control
		ReadData1 : in std_logic_vector(15 downto 0);	-- ReadData selection
		EX_MEM_rst : in std_logic_vector(15 downto 0);	-- EX/MEM forwarding
		MEM_WB_rst : in std_logic_vector(15 downto 0);	-- MEM/WB forwarding

		rstA : out std_logic_vector(15 downto 0)	-- output
	);
end MUX_A;

architecture Behavioral of MUX_A is

begin
	process (ForwardA, ReadData1, EX_MEM_rst, MEM_WB_rst)
	begin
		case ForwardA is
			when "00" =>
				rstA <= ReadData1;
			when "01" =>
				rstA <= EX_MEM_rst;
			when "10" =>
				rstA <= MEM_WB_rst;
			when others =>
		end case;
	end process;
end Behavioral;
