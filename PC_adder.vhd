library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity PC_adder is
	port(
		adder_in : in std_logic_vector(15 downto 0);
		adder_out : out std_logic_vector(15 downto 0)
	);
end PC_adder;

architecture Behavioral of PC_adder is
begin
	process (adder_in)
	begin
		adder_out <= adder_in + 1;
	end process;
end Behavioral;