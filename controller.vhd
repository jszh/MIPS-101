library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
	port(	
		command_in : in std_logic_vector(15 downto 0);
		rst : in std_logic;
		controller_out :  out std_logic_vector(23 downto 0);  --controller_out 将所有控制信号集中在??个中实现
		--extend(3) reg1_select(3) reg2_select(2) regwrite(1)  --9
		--jump(1) alusrc(1) aluop(4) regdst(3) memread(1)      --10
		--memwrite(1) branch(3) memtoreg(1)                    --5
		MFPC_out : out std_logic
	);
end controller;

architecture Behavioral of controller is

begin
	process(rst, command_in)
	begin 
		if (rst = '1') then
			controller_out <= (others => '0');
		else
			if (command_in(15 downto 11) = "11101" and command_in(7 downto 0) = "01000000") then	--MFPC
				MFPC_out <= '1';
			else
				MFPC_out <= '0';
			end if;

			case command_in(15 downto 11) is
				when "00001" =>		--NOP
					controller_out <= "000000000000000000000000";
				when "00010" =>		--B  todo 这里没有控制信号
					controller_out <= "110000000000000000001000";
				when "00100" =>		--BEQZ
					controller_out <= "100001000000000000000010";
				when "00101" =>		--BNEZ
					controller_out <= "100001000000000000000100";
				when "00110" =>
					if (command_in(1 downto 0) = "00") then 	--SLL
						controller_out <= "011010001010110001000001";
					elsif (command_in(1 downto 0) = "11") then --SRA
						controller_out <= "011010001011000001000001";
					end if;
				when "01000" =>		--ADDIU3
					controller_out <= "001001001010001010000001";
				when "01001" =>		--ADDIU
					controller_out <= "100001001010001001000001";
				when "01100" =>
					if (command_in(10 downto 8) = "011") then	 --ADDSP
						controller_out <= "100100001010001101000001";
					elsif (command_in(10 downto 8) = "000") then--BTEQZ
						controller_out <= "100011000000000000000110";
					elsif (command_in(10 downto 8) = "100") then--MTSP
						controller_out <= "000010001001011101000001";
					elsif (command_in(10 downto 8) = "010") then --SW_RS
						controller_out <= "100100110010001000010000";
					end if;
				when "01101" =>		--LI
					controller_out <= "101000001011100001000001";
				when "01110" =>		--CMPI
					controller_out <= "100001001011001100000001";
				when "01111" =>		--MOVE
					controller_out <= "000001011001100001000001";
				when "10010" =>		--LW_SP
					controller_out <= "100100001010001001100000";
				when "10011" =>		--LW
					controller_out <= "010001001010001010100000";
				when "11010" =>		--SW_SP
					controller_out <= "100100100010001000010000";
				when "11011" =>		--SW
					controller_out <= "010001010010001000010000";
				when "11100" =>
					if (command_in(1 downto 0) = "01") then		--ADDU
						controller_out <= "000001011000001011000001";
					elsif (command_in(1 downto 0) = "11") then --SUBU
						controller_out <= "000001011000010011000001";
					end if;
				when "11101" =>
					if (command_in(4 downto 0) = "01100") then		--AND
						controller_out <= "000001011000011001000001";
					elsif (command_in(4 downto 0) = "01101") then --OR
						controller_out <= "000001011000100001000001";
					elsif (command_in(4 downto 0) = "01010") then --CMP
						controller_out <= "000001011001001100000001";
					elsif (command_in(4 downto 0) = "00110") then --SRLV
						controller_out <= "000010101000111010000001";
					elsif (command_in(4 downto 0) = "00011") then --SLTU
						controller_out <= "000001011001010100000001";
					elsif (command_in(7 downto 0) = "00000000") then --JR
						controller_out <= "000001000100000111000000";
					elsif (command_in(7 downto 0) = "01000000") then --MFPC
						controller_out <= "000000001001011001000001";
					end if;
				when "11110" =>
					if (command_in(7 downto 0) = "00000000") then 	--MFIH
						controller_out <= "000101001001011001000001";
					elsif (command_in(7 downto 0) = "00000001") then --MTIH
						controller_out <= "000001001001011110000001";
					end if;
				when others =>			--Error, skip
					controller_out <= "000000000000000000000000";
			end case;
		end if;
	end process;
		
end Behavioral;
