library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_MFPC is
	port(
		PC_addOne : in std_logic_vector(15 downto 0);	
		ALUresult : in std_logic_vector(15 downto 0);
		MFPC : in std_logic;	-- when '1': out = PC+1
		
		MUX_MFPC_out : out std_logic_vector(15 downto 0)
	);
end MUX_MFPC;

architecture Behavioral of MUX_MFPC is

begin
	process(PC_addOne, ALUresult, MFPC)
	begin
        if (MFPC = '1') then
            MUX_MFPC_out <= PC_addOne;
        else
            MUX_MFPC_out <= ALUresult;
        end if;
	end process;
end Behavioral;
