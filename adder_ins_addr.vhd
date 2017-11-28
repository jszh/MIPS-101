library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_ins_addr is
	port(   
		IF_ID_PC_in : in std_logic_vector(15 downto 0);
		imme_in : in std_logic_vector(15 downto 0);
		addr_out : out std_logic_vector(15 downto 0)
	);
end adder_ins_addr;

architecture Behavioral of adder_ins_addr is
begin
	process(IF_ID_PC_in, imme_in)
	begin
		addr_out <= IF_ID_PC_in + imme_in;
	end process;
end Behavioral;
