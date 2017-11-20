library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity PCAdder is
	port(   adderIn : in std_logic_vector(15 downto 0);
			adderOut : out std_logic_vector(15 downto 0)
			);
end PCAdder;

architecture Behavioral of PCAdder is

begin

	process(adderIn)
	begin
		adderOut <= adderIn + 1;
	end process;

end Behavioral;