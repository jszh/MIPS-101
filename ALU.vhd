library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ALU is
	port(
		Asrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		Bsrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		ALUop		  :  in STD_LOGIC_VECTOR(3 downto 0);
		ALUresult  :  out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; -- Ä¬ÈÏÉèÎªÈ«0
		branchJudge : out std_logic
	);
end ALU;

architecture Behavioral of ALU is
	shared variable tmp : std_logic_vector(15 downto 0);
	shared variable zero : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(Asrc , Bsrc , ALUop)
	begin
		case ALUop is 
			when "0001" => --  ADD
				ALUresult <= Asrc + Bsrc;
				branchJudge <= '0';
			when "0010" => --  SUB
				ALUresult <= Asrc - Bsrc; -- A-B
				branchJudge <= '0';
			when "0011" => --  AND
				ALUresult <= Asrc and Bsrc;
				branchJudge <= '0';
			when "0100" => --  OR
				ALUresult <= Asrc or Bsrc;
				branchJudge <= '0';
			when "0101" => -- NEG
				ALUresult <= zero - Asrc;
				branchJudge <= '0';
			when "0110" => --SLL
				tmp := Asrc(15 downto 0);
				if (Bsrc = zero) then 
					ALUresult(15 downto 0) <= to_stdlogicvector(to_bitvector(tmp) sll 8);--left 8
				else 
					ALUresult <= to_stdlogicvector(to_bitvector(Asrc) sll conv_integer(Bsrc));
				end if;
				branchJudge <= '0';
			

			when "0111" => --SRLV
				ALUresult <= to_stdlogicvector(to_bitvector(Asrc) srl conv_integer(Bsrc));
				branchJudge <= '0';
			when "1000" => --SRA
				tmp := Asrc(15 downto 0);
				if (Bsrc = zero) then 
					ALUresult(15 downto 0) <= to_stdlogicvector(to_bitvector(tmp) sra 8);--left 8
				else 
					ALUresult <= to_stdlogicvector(to_bitvector(Asrc) sra conv_integer(Bsrc));
				end if;
				branchJudge <= '0';
			when "1001" => --CMP
				if (Asrc = Bsrc) then 
					ALUresult <= "0000000000000000";
				else 
					ALUresult <= "0000000000000001";
				end if;
				branchJudge <= '0';
			when "1010" =>-- SLTU
				if(Asrc >= Bsrc) then
					ALUresult <= "0000000000000000";
				else 
					ALUresult <= "0000000000000001";
				end if;
				branchJudge <= '0';
			
			when "1011" => --OUTPUTA
				ALUresult <= Asrc;
			when "1100" => --OUTPUTB
				ALUresult <= Bsrc;

				
			when others => ALUresult <= "0000000000000000";
				branchJudge <= '0';
		end case;
	end process;

end Behavioral;
