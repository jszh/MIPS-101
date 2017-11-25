library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
	port(	
		commandIn : in std_logic_vector(15 downto 0);
		rst : in std_logic;
		controllerOut :  out std_logic_vector(20 downto 0)  --controllerout 将所有控制信号集中在一个中实现
		-- RegWrite(1) RegDst(3) ReadReg1(3) ReadReg2(1) 
		-- immeSelect(3) ALUSrcB(1) ALUOp(4) 
		-- MemRead(1) MemWrite(1) MemToReg(1) jump(1) MFPC(1)
	);
end Controller;

architecture Behavioral of Controller is

begin
	process(rst, commandIn)
	begin
		if (rst = '0') then
			controllerOut <= (others => '0');
		else
			case commandIn(15 downto 11) is
				when "00001" =>		--NOP
					controllerOut <= "000000000000000000000";
				when "00010" =>		--B
					controllerOut <= "000000001100101000000";
				when "00100" =>		--BEQZ
					controllerOut <= "000000101010100100000";
				when "00101" =>		--BNEZ
					controllerOut <= "000000101010101100000";
				when "00110" =>
					if (commandIn(1 downto 0) = "00") then 	--SLL
						controllerOut <= "100101000111011000000";
					elsif (commandIn(1 downto 0) = "11") then --SRA
						controllerOut <= "100101000111011100000";
					end if;
				when "01000" =>		--ADDIU3
					controllerOut <= "101000100011000100000";
				when "01001" =>		--ADDIU
					controllerOut <= "100100101011000100000";
				when "01100" =>
					if (commandIn(10 downto 8) = "011") then	 --ADDSP
						controllerOut <= "110110001011000100000";
					elsif (commandIn(10 downto 8) = "000") then--BTEQZ
						controllerOut <= "000001101010100100000";
					elsif (commandIn(10 downto 8) = "100") then--MTSP
						controllerOut <= "110101000000111000000";
					end if;
				when "01101" =>		--LI
					controllerOut <= "100100001001111100000";
				when "01110" =>		--CMPI
					controllerOut <= "110000101011100000000";
				when "01111" =>		--MOVE
					controllerOut <= "100101000000111000000";
				when "10010" =>		--LW_SP
					controllerOut <= "100110001011000110100";
				when "10011" =>		--LW
					controllerOut <= "101000100101000110100";
				when "11010" =>		--SW_SP
					controllerOut <= "000010001011000101000";
				when "11011" =>		--SW
					controllerOut <= "000000110101000101000";
				when "11100" =>
					if (commandIn(1 downto 0) = "01") then		--ADDU
						controllerOut <= "101100110000000100000";
					elsif (commandIn(1 downto 0) = "11") then --SUBU
						controllerOut <= "101100110000001000000";
					end if;
				when "11101" =>
					if (commandIn(4 downto 0) = "01100") then		--AND
						controllerOut <= "100100110000001100000";
					elsif (commandIn(4 downto 0) = "01101") then --OR
						controllerOut <= "100100110000010000000";
					elsif (commandIn(4 downto 0) = "01010") then --CMP
						controllerOut <= "110000110000100000000";
					elsif (commandIn(4 downto 0) = "00100") then --SLLV
						controllerOut <= "101001000000110000000";
					elsif (commandIn(4 downto 0) = "00111") then --SRAV
						controllerOut <= "101001000000110100000";
					elsif (commandIn(4 downto 0) = "01011") then --NEG
						controllerOut <= "100101000000010100000";
					elsif (commandIn(7 downto 0) = "00000000") then --JR
						controllerOut <= "000000100000000000010";
					elsif (commandIn(7 downto 0) = "01000000") then --MFPC
						controllerOut <= "100100000000000000001";
					end if;
				when "11110" =>
					if (commandIn(7 downto 0) = "00000000") then 	--MFIH
						controllerOut <= "100110100000111000000";
					elsif (commandIn(7 downto 0) = "00000001") then --MTIH
						controllerOut <= "111000100000111000000";
					end if;
				when others =>			--Error
					controllerOut <= "000000000000000000000";
			end case;
		end if;
	end process;
		
end Behavioral;
