library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_Reg1 is  ----源寄存器1选择器
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);	--R0~R7中的一个
		
		reg1_select : in std_logic_vector(2 downto 0);	-- control signal
		
		reg1_out : out std_logic_vector(3 downto 0)	--"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1111"=没有
	);
end MUX_Reg1;

architecture Behavioral of MUX_Reg1 is

begin
	process(Rs, Rt, reg1_select)
	begin
		case reg1_select is
			when "001" =>		--Rs
				reg1_out <= '0' & Rs;
			when "010" =>		--Rt
				reg1_out <= '0' & Rt;
			when "011" =>		--T
				reg1_out <= "1010";
			when "100" =>		--SP
				reg1_out <= "1000";
			when "101" =>		--IH
				reg1_out <= "1001";
			when others =>		--No reg1_select（不需要寄存器1）
				reg1_out <= "1111";
		end case;
	end process;
end Behavioral;