library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_detection is
	port(
		ID_EX_Rd : in std_logic_vector(3 downto 0);
		ID_EX_MemRead : in std_logic;
		ID_EX_ALUop : in std_logic_vector(3 downto 0);
		ID_EX_MFPC : in std_logic;
		EX_MEM_Rd: in std_logic_vector(3 downto 0);
		EX_MEM_MemRead : in std_logic;
		
		reg1_select : in std_logic_vector(3 downto 0);
		reg2_select : in std_logic_vector(3 downto 0);

		Branch : in std_logic_vector(2 downto 0);
		
		PC_Keep : out std_logic;
		IF_ID_Keep : out std_logic;
		BJ_IF_ID_Flush : out std_logic;
		ID_EX_Flush : out std_logic
	);	
end hazard_detection;

architecture Behavioral of hazard_detection is
begin
	process (ID_EX_Rd, ID_EX_MemRead, ID_EX_ALUop, ID_EX_MFPC, EX_MEM_MemRead, Branch, reg1_select, reg2_select)
	begin
		if ((Branch >= "001" and Branch <= "011") then	-- Conditional branch: BEQZ, BNEZ, BTEQZ
			if (((ID_EX_ALUop /= "0000" or ID_EX_MFPC = '1' or ID_EX_MemRead = '1') and	-- prev ALU operation or MemRead
				reg1_select = ID_EX_Rd) or	-- reg match
				(EX_MEM_MemRead = '1' and EX_MEM_Rd)) then	-- prev prev MemRead and reg match
				PC_Keep <= '1';
				IF_ID_Keep <= '0';
				BJ_IF_ID_Flush <= '1';
				ID_EX_Flush <= '1';
			else
				PC_Keep <= '0';
				IF_ID_Keep <= '0';
				BJ_IF_ID_Flush <= '0';
				ID_EX_Flush <= '0';
			end if;
		else	-- Not a conditional branch instruction
			if ((ID_EX_MemRead = '1') and	-- Load instruction
				(not (reg1_select = "1111" and reg2_select = "1111")) and	-- The next intruction reads from Reg
				(reg1_select = ID_EX_Rd or reg2_select = ID_EX_Rd)) then	-- Hazard: stall the pipeline
				PC_Keep <= '1';
				IF_ID_Keep <= '1';
				BJ_IF_ID_Flush <= '0';
				ID_EX_Flush <= '1';
			else
				PC_Keep <= '0';
				IF_ID_Keep <= '0';
				BJ_IF_ID_Flush <= '0';
				ID_EX_Flush <= '0';
			end if;
		end if;
	end process;
end Behavioral;
