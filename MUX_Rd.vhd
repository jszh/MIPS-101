library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_Rd is
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);
		Rd : in std_logic_vector(2 downto 0);		-- one of R0 .. R7
			
		RegDst : in std_logic_vector(2 downto 0);	-- from Controller: 000-n/a,001-Rs,010-Rt,011-Rd,100-T,101-SP,110-IH
			
		Rd_out : out std_logic_vector(3 downto 0)	--"0XXX": R0~R7; "1000"=SP,"1001"=IH, "1010"=T, "1110"=n/a
	);
end MUX_Rd;

architecture Behavioral of MUX_Rd is
begin
	process(Rs, Rt, Rd, RegDst)
	begin
		case RegDst is
			when "001" =>	-- Rs
				Rd_out <= '0' & Rs;
			when "010" =>	-- Rt
				Rd_out <= '0' & Rt;
			when "011" =>	-- Rd
				Rd_out <= '0' & Rd;
			when "100" =>	-- T
				Rd_out <= "1010";
			when "101" =>	-- SP
				Rd_out <= "1000";
			when "110" =>	-- IH
				Rd_out <= "1001";

			when others =>	-- no Rd
				Rd_out <= "1110";
		end case;
	end process;
end Behavioral;
