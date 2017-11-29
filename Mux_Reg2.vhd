library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_Reg2 is
	--源寄存器2选择器
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);			--R0~R7中的一个
		
		reg2_select : in std_logic_vector(1 downto 0);						-- contorl signal
		
		reg2_out : out std_logic_vector(3 downto 0)  --"0XXX"代表R0~R7,"1000"=RA,"1111"=没有
	);
end MUX_Reg2;

architecture Behavioral of MUX_Reg2 is

begin
	process(Rs, Rt, reg2_select)
	begin
		case reg2_select is
			when "01" =>			-- Rt
				reg2_out <= '0' & Rt;
			when "10" =>			-- Rs
				reg2_out <= '0' & Rs;
			when "11" =>		-- RA
				reg2_out <= "1000";
			when others =>		--No reg2_select（不需要源寄存器2）
				reg2_out <= "1111";
		end case;
	end process;
end Behavioral;
