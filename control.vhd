library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control is
	port(	
		commandIn : in std_logic_vector(15 downto 0);
		rst : in std_logic;
		control_out :  out std_logic_vector(23 downto 0)  --control_out 将所有控制信号集中在一个中实现
		--extend(3) reg1_select(3) reg2_select(2) regwrite(1)  --9
		--jump(1) alusrc(1) aluop(4) regdst(3) memread(1)      --10
		--memwrite(1) branch(3) memtoreg(1)                    --5
	);
end control;

architecture Behavioral of control is

begin
	process(rst, commandIn)
	begin
		if (rst = '0') then
			control_out <= (others => '0');
		else
			case commandIn(15 downto 11) is
				when "00001" =>		--NOP
					control_out <= "000000000000000000000000";
				when "00010" =>		--B  todo 这里没有控制信号
					control_out <= "110110000000000000000000";
				when "00100" =>		--BEQZ
					control_out <= "100110000001100000000000";
				when "00101" =>		--BNEZ
					control_out <= "100110000001100000000000";
				when "00110" =>
					if (commandIn(1 downto 0) = "00") then 	--SLL
						control_out <= "011010001010110001000001";
					elsif (commandIn(1 downto 0) = "11") then --SRA
						control_out <= "011010001011000001000001";
					end if;
				when "01000" =>		--ADDIU3
					control_out <= "001001001010001010000001";
				when "01001" =>		--ADDIU
					control_out <= "100001001010001001000001";
				when "01100" =>
					if (commandIn(10 downto 8) = "011") then	 --ADDSP
						control_out <= "100100001010001101000001";
					elsif (commandIn(10 downto 8) = "000") then--BTEQZ
						control_out <= "100110000001011000000000";
					elsif (commandIn(10 downto 8) = "100") then--MTSP
						control_out <= "000001001001101101000000";
					elsif (commandIn(10 downto 8) = "010") then --SW_RS
						control_out <= "100100100010001000010000";
					end if;
				when "01101" =>		--LI
					control_out <= "101000001010000001000001";
				when "01110" =>		--CMPI
					control_out <= "100001001011001100000001";
				when "01111" =>		--MOVE
					control_out <= "000001011000000001000001";
				when "10010" =>		--LW_SP
					control_out <= "100100001010001001100000";
				when "10011" =>		--LW
					control_out <= "010001001010001010100000";
				when "11010" =>		--SW_SP
					control_out <= "100100000010001000010000";
				when "11011" =>		--SW
					control_out <= "010001010010001000010000";
				when "11100" =>
					if (commandIn(1 downto 0) = "01") then		--ADDU
						control_out <= "000001011000001011000001";
					elsif (commandIn(1 downto 0) = "11") then --SUBU
						control_out <= "000001011000010011000001";
					end if;
				when "11101" =>
					if (commandIn(4 downto 0) = "01100") then		--AND
						control_out <= "000001011000011001000001";
					elsif (commandIn(4 downto 0) = "01101") then --OR
						control_out <= "000001011000100001000001";
					elsif (commandIn(4 downto 0) = "01010") then --CMP
						control_out <= "000001011001001100000001";
					elsif (commandIn(4 downto 0) = "00110") then --SRLV
						control_out <= "000010001000111010000001";
					elsif (commandIn(4 downto 0) = "00011") then --SLTU
						control_out <= "000001011001010100000001";
					elsif (commandIn(7 downto 0) = "00000000") then --JR
						control_out <= "000001000100000111000000";
					elsif (commandIn(7 downto 0) = "01000000") then --MFPC
						control_out <= "000110001001101001000000";
					end if;
				when "11110" =>
					if (commandIn(7 downto 0) = "00000000") then 	--MFIH
						control_out <= "000101001001101001000000";
					elsif (commandIn(7 downto 0) = "00000001") then --MTIH
						control_out <= "000001001001101110000000";
					end if;
				when others =>			--Error
					control_out <= "000000000000000000000000";
			end case;
		end if;
	end process;
		
end Behavioral;
