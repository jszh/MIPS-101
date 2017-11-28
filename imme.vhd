library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity ImmeExtendUnit is
	port(
			 immeIn : in std_logic_vector(10 downto 0);
			 immeSelect : in std_logic_vector(2 downto 0);
			 
			 immeOut : out std_logic_vector(15 downto 0)
		);
end ImmeExtendUnit;
architecture Behavioral of ImmeExtendUnit is
	shared variable sign : std_logic;
	shared variable tmpOut : std_logic_vector(15 downto 0);
begin
	process(immeIn, immeSelect)
	begin
		case immeSelect is
			when "001" => sign := immeIn(3); --3-0
			when "010" => sign := immeIn(4); --4-0
			when "011" => sign := immeIn(4);--4-2
			when "100" => sign := immeIn(7);--7-0
			when "101" => sign := '0'; --7-0
			when "110" => sign := immeIn(10);--sign extend 10-0
			when others => 
		end case;
		tmpOut := (others => sign);
		
		case immeSelect is
			when "110" =>
				immeOut <= tmpOut(15 downto 11) & immeIn(10 downto 0);
			when "101" =>
				immeOut <= tmpOut(15 downto 8) & immeIn(7 downto 0);
			when "100" =>
				immeOut <= tmpOut(15 downto 8) & immeIn(7 downto 0);
			when "011" =>
				immeOut <= tmpOut(15 downto 3) & immeIn(4 downto 2);
			when "010" =>
				immeOut <= tmpOut(15 downto 5) & immeIn(4 downto 0);
			when "001" =>
				immeOut <= tmpOut(15 downto 4) & immeIn(3 downto 0);
			when others =>
		end case;
	end process;
end Behavioral;

