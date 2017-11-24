library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux_Reg2 is
	--源寄存器2选择器
	port(
		rx : in std_logic_vector(2 downto 0);
		ry : in std_logic_vector(2 downto 0);			--R0~R7中的一个
		
		reg2_select : in std_logic;							--由总控制器Controller生成的控制信号
		
		reg2_selected : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7, "1111"=没有
	);
end Mux_Reg2;

architecture Behavioral of Mux_Reg2 is

begin
	process(rx, ry, reg2_select)
	begin
		case reg2_select is
			when '0' =>			--rx
				reg2_selected <= '0' & rx;
			when '1' =>			--ry
				reg2_selected <= '0' & ry;
			when others =>		--No reg2_select（不需要源寄存器2）
				reg2_selected <= "1111";
		end case;
	end process;
end Behavioral;
