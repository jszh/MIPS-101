library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity JumpAdder is
	port(   
		IFIDIn : in std_logic_vector(15 downto 0);
		immeIn : in std_logic_vector(15 downto 0);
		resOut : out std_logic_vector(15 downto 0)
	);
end JumpAdder;

architecture Behavioral of JumpAdder is

begin

	process(IFIDIn, immeIn)
	begin
		resOut <= IFIDIn + immeIn;
	end process;

end Behavioral;