library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PCMux is
	port(
		PCAddOne : in std_logic_vector(15 downto 0);	 
		IdEximme : in std_logic_vector(15 downto 0);  
		IdExPC : in std_logic_vector(15 downto 0);	 
		AsrcOut : in std_logic_vector(15 downto 0);	
		
		jump : in std_logic;					
		BranchJudge : in std_logic;		
		PCRollback : in std_logic;			
		
		PCOut : out std_logic_vector(15 downto 0)
	);
end PCMux;

architecture Behavioral of PCMux is
	
	
begin
	process(PCAddOne, IdEximme, AsrcOut, jump, BranchJudge)
	begin
		if (BranchJudge = '1' and jump = '0') then
			PCOut <= IdEximme + IdExPC;
		elsif (jump = '1' and BranchJudge = '0') then
			PCOut <= AsrcOut;
		elsif (jump = '0' and BranchJudge = '0') then
			if (PCRollback = '1') then
				PCOut <= PCAddOne - "0000000000000010";	--PCOut = PCAddOne - 2;
			elsif (PCRollback = '0') then
				PCOut <= PCAddOne;
			end if;
		end if;
	
	end process;
end Behavioral;

