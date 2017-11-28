library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection is
	port(
		ID_EX_Rd : in std_logic_vector(3 downto 0);
		ID_EX_MemRead : in std_logic;
		ID_EX_ALUop: in std_logic_vector(3 downto 0);
		EX_MEM_Rd: in std_logic_vector(3 downto 0);
		EX_MEM_MemRead: in std_logic;
		
		ReadReg1 : in std_logic_vector(3 downto 0);
		ReadReg2 : in std_logic_vector(3 downto 0);

		Branch : in std_logic_vector(2 downto 0);
		
		PC_Keep : out std_logic;
		IF_ID_Keep : out std_logic;
		ID_EX_FLUSH : out std_logic
	);	
end hazard_detection;

architecture Behavioral of hazard_detection is
begin
	process (ID_EX_Rd, ID_EX_MemRead, ID_EX_ALUop, EX_MEM_MemRead, Branch, ReadReg1, ReadReg2)
	begin
		if ((Branch >= "001" and Branch <= "011") then	-- Conditional branch: BEQZ, BNEZ, BTEQZ
			if (((ID_EX_ALUop /= "0000" or ID_EX_MemRead = '1') and	-- prev ALU operation or MemRead
				ReadReg1 = ID_EX_Rd) or	-- reg match
				(EX_MEM_MemRead = '1' and EX_MEM_Rd)) then	-- prev prev MemRead and reg match
				PC_Keep <= '1';
				IF_ID_Keep <= '1';
				ID_EX_FLUSH <= '1';
			else
				PC_Keep <= '0';
				IF_ID_Keep <= '0';
				ID_EX_FLUSH <= '0';
			end if;
		else	-- Not a conditional branch instruction
			if ((ID_EX_MemRead = '1') and	-- Load instruction
				(not (ReadReg1 = "1111" and ReadReg2 = "1111")) and	-- The next intruction reads from Reg
				(ReadReg1 = ID_EX_Rd or ReadReg2 = ID_EX_Rd)) then	-- Hazard: stall the pipeline
				PC_Keep <= '1';
				IF_ID_Keep <= '1';
				ID_EX_FLUSH <= '1';
			else
				PC_Keep <= '0';
				IF_ID_Keep <= '0';
				ID_EX_FLUSH <= '0';
			end if;
		end if;
	end process;
end Behavioral;
