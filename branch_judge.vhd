library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity branch_judge is
	port(
		Branch     :  in std_logic_vector(2 downto 0);
		Data       :  in std_logic_vector(15 downto 0);
		BranchJudge : out std_logic
	);
end branch_judge;

architecture Behavioral of branch_judge is
	shared variable tmp : std_logic_vector(15 downto 0);
	shared variable zero : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(Branch, Data)
	begin
		case Branch is 
			when "000" => -- No B型跳转指令
				BranchJudge <= '0';
			when "001" => -- BEQZ 
				if(Data = zero) then
					BranchJudge <= '1';
				else
					BranchJudge <= '0';
				end if;
			when "010" => -- BNEZ
				if(Data = zero)
					BranchJudge <= '0';
				else 
					BranchJudge <= '1';
				end if;
			when "011" => -- BTEQZ
				if(Data = zero) then
					BranchJudge <= '1';
				else
					BranchJudge <= '0';
				end if;
			when others =>
				BranchJudge <= '0';
		end case;
	end process;

end Behavioral;