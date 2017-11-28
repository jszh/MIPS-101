library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Equal is
	port(
		Branch     :  in STD_LOGIC_VECTOR(2 downto 0);
		Data       :  in STD_LOGIC_VECTOR(15 downto 0);
		branchJudge : out std_logic
	);
end Equal;

architecture Behavioral of Equal is
	shared variable tmp : std_logic_vector(15 downto 0);
	shared variable zero : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(Branch, Data)
	begin
		case Branch is 
			when "000" => --  No B型跳转指令
				branchJudge <= '0';
			when "001" => --  BEQZ 
				if(Data = zero) then
					branchJudge <= '1';
				else
					branchJudge <= '0';
				end if;
			when "010" => -- BNEZ
				if(Data = zero)
					branchJudge <= '0';
				else 
					branchJudge <= '1';
				end if;
			when "011" => --  BTEQZ
				if(Data = zero) then
					branchJudge <= '1';
				else
					branchJudge <= '0';
				end if;
			when others =>
				branchJudge <= '0';
		end case;
	end process;

end Behavioral;