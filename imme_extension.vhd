library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity imme_extension is
	port(
		imme_in : in std_logic_vector(10 downto 0);
		imme_select : in std_logic_vector(2 downto 0);
		
		imme_out : out std_logic_vector(15 downto 0)
	);
end imme_extension;
architecture Behavioral of imme_extension is
	shared variable sign : std_logic;
	shared variable tmpOut : std_logic_vector(15 downto 0);
begin
	process(imme_in, imme_select)
	begin
		case imme_select is
			when "001" => sign := imme_in(3); --3-0
			when "010" => sign := imme_in(4); --4-0
			when "011" => sign := imme_in(4);--4-2
			when "100" => sign := imme_in(7);--7-0
			when "101" => sign := '0'; --7-0
			when "110" => sign := imme_in(10);--sign extend 10-0
			when others => 
		end case;
		tmpOut := (others => sign);
		
		case imme_select is
			when "110" =>
				imme_out <= tmpOut(15 downto 11) & imme_in(10 downto 0);
			when "101" =>
				imme_out <= tmpOut(15 downto 8) & imme_in(7 downto 0);
			when "100" =>
				imme_out <= tmpOut(15 downto 8) & imme_in(7 downto 0);
			when "011" =>
				imme_out <= tmpOut(15 downto 3) & imme_in(4 downto 2);
			when "010" =>
				imme_out <= tmpOut(15 downto 5) & imme_in(4 downto 0);
			when "001" =>
				imme_out <= tmpOut(15 downto 4) & imme_in(3 downto 0);
			when others =>
		end case;
	end process;
end Behavioral;

