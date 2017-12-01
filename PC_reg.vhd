library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_reg is
	port(
		rst, clk : in std_logic;
		flash_finished : in std_logic;
		PC_keep : in std_logic;
		PC_in : in std_logic_vector(15 downto 0);
		PC_out : out std_logic_vector(15 downto 0)
	);
end PC_reg;

architecture Behavioral of PC_reg is

begin
	process(clk,rst)
	begin
		if (rst = '1') then 
			PC_out <= "1111111111111111";
		elsif clk'event and clk = '1'then
			if flash_finished = '1' then
				if PC_keep = '0' then
					PC_out <= PC_in;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

