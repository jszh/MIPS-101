library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock is
    Port (
		rst : in STD_LOGIC;
		clk : in  STD_LOGIC;
		
		clk_out :out STD_LOGIC;
		clk1 : out  STD_LOGIC;
		clk2 : out STD_LOGIC
	);
end clock;

architecture Behavioral of clock is
	signal count:natural range 0 to 3 := 0;

begin
	process (clk,rst)
	begin
		clk_out <= clk;
		if (rst = '0') then
			clk_out <= '0';
			clk1 <= '0';
			clk2 <= '0';
			count <= 0;
		elsif (clk'event and clk='1') then
			case count is
				when 0 =>
					clk1 <= '1';
					clk2 <= '0';
				when 1 =>
					clk1 <= '0';
					clk2 <= '1';
				when others =>
					clk1 <= '0';
					clk2 <= '0';
			end case;
			
			if(count = 2) then
				count <= 0;
			else 
				count <= count + 1;
			end if;
			
		end if;

	end process;
end Behavioral;
