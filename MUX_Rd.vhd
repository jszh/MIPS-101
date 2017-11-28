library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_Rd is
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);
		Rd : in std_logic_vector(2 downto 0);		-- one of R0 .. R7
			
		RegDst : in std_logic_vector(2 downto 0);	-- from Controller
			
		rst : out std_logic_vector(3 downto 0)	--"0XXX": R0~R7; "1000"=SP,"1001"=IH, "1010"=T, "1110"=n/a
	);
end MUX_Rd;

architecture Behavioral of MUX_Rd is
begin
	process(Rs, Rt, Rd, RegDst)
	begin
		case RegDst is
			when "001" =>	-- Rs
				rst <= '0' & Rs;
			when "010" =>	-- Rt
				rst <= '0' & Rt;
			when "011" =>	-- Rd
				rst <= '0' & Rd;
			when "100" =>	-- T
				rst <= "1010";
			when "101" =>	-- SP
				rst <= "1000";
			when "110" =>	-- IH
				rst <= "1001";
			when "000" =>	-- PC
				rst <= "1100"
			when "111" =>	-- RA
				rst <= "1011"

			when others =>	-- no Rd
				rst <= "1110";
		end case;
	end process;
end Behavioral;
