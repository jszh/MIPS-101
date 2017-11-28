library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux_Reg1 is  ----源寄存器1选择器
	port(
		rx : in std_logic_vector(2 downto 0);
		ry : in std_logic_vector(2 downto 0);				--R0~R7中的一个
		
		reg1_select : in std_logic_vector(2 downto 0);		--由总控制器Controller生成的控制信号
		
		reg1_selected : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7，"1000"=SP,"1001"=IH, "1010"=T, "1111"=没有
	);
end Mux_Reg1;

architecture Behavioral of Mux_Reg1 is

begin
	process(rx, ry, reg1_select)
	begin
		case reg1_select is
			when "001" =>		--rx
				reg1_selected <= '0' & rx;
			when "010" =>		--ry
				reg1_selected <= '0' & ry;
			when "011" =>		--T
				reg1_selected <= "1010";
			when "100" =>		--SP
				reg1_selected <= "1000";
			when "101" =>		--IH
				reg1_selected <= "1001";
			when "110" =>       --RA
				reg1_selected <= "1011";
			when "111" =>       --PC
				reg1_selected <= "1100";
			when others =>		--No reg1_select（不需要寄存器1）
				reg1_selected <= "1111";
		end case;
	end process;
end Behavioral;