library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX_MFPC is
	port(
		PC_addOne : in std_logic_vector(15 downto 0);	
		ALUresult : in std_logic_vector(15 downto 0);
		MFPC : in std_logic;	-- when '1': out = PC+1
		
		MFPC_MUX_out : out std_logic_vector(15 downto 0)
	);
end MUX_MFPC;

architecture Behavioral of MUX_MFPC is

begin
	process(PC_addOne, ALUresult, MFPC)
	begin
		MFPC_MUX_out <= PC_addOne when (MFPC = '1') else ALUresult;
	end process;
end Behavioral;
