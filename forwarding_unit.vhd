library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forwarding_unit is
	port(
		IF_ID_Rs: in std_logic_vector(3 downto 0);

		ID_EX_Rs : in std_logic_vector(3 downto 0);
		ID_EX_Rt : in std_logic_vector(3 downto 0);

		EX_MEM_Rd : in std_logic_vector(3 downto 0);
		MEM_WB_Rd : in std_logic_vector(3 downto 0);
		
		ID_EX_MemWrite : in std_logic;

		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0);
		ForwardSW : out std_logic_vector(1 downto 0);
		ForwardEq : out std_logic_vector(1 downto 0)
	);
end forwarding_unit;

architecture Behavioral of forwarding_unit is
begin
	process(EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rs, ID_EX_Rt, ID_EX_MemWrite)
	begin
		-- MUX_A
		if (ID_EX_Rs = EX_MEM_Rd) then	-- EX hazard
			ForwardA <= "01";
		elsif (ID_EX_Rs = MEM_WB_Rd and MEM_WB_Rd /= "0000") then	-- MEM hazard
			ForwardA <= "10";
		else	-- No hazard
			ForwardA <= "00";
		end if;
		
		-- MUX_B
		if (ID_EX_Rt = EX_MEM_Rd) then	-- EX hazard
			ForwardB <= "01";
		elsif (ID_EX_Rt = MEM_WB_Rd and MEM_WB_Rd /= "0000") then	-- MEM hazard
			ForwardB <= "10";
		else	-- No hazard
			ForwardB <= "00";
		end if;
		
		-- MUX_SW
		if (ID_EX_MemWrite = '1') then	-- SW
			if (ID_EX_Rt = EX_MEM_Rd) then	-- EX hazard
				ForwardSW <= "01";
			elsif (ID_EX_Rt = MEM_WB_Rd and MEM_WB_Rd /= "0000") then	-- MEM hazard
				ForwardSW <= "10";
			else	-- No hazard
				ForwardSW <= "00";
			end if;
		else
			ForwardSW <= "00";
		end if;

		-- MUX_Eq
		if (Branch >= "001" and Branch <= "011")	-- Conditional branch
			if (IF_ID_Rs = EX_MEM_Rd) then -- EX hazard
				ForwardEq <= "01";
			elsif (IF_ID_Rs = MEM_WB_Rd and MEM_WB_Rd /= "0000") then	-- MEM hazard
				ForwardEq <= "10";
			else
				ForwardEq <= "00";
			end if;
		else
			ForwardEq <= "00";
		end if;
		
	end process;

end Behavioral;
