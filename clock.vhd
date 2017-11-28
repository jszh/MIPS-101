----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:13:31 11/22/2016 
-- Design Name: 
-- Module Name:    clock - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock is
    Port ( 
			rst : in STD_LOGIC;
			clk : in  STD_LOGIC;
		   
			clkout :out STD_LOGIC;
         clk1 : out  STD_LOGIC;
			clk2 : out STD_LOGIC
			 );
end clock;

architecture Behavioral of clock is
	signal count:natural range 0 to 3 := 0;
	
begin
	process (clk,rst)
		begin
			clkout <= clk;
			if (rst = '0') then
				clkout <= '0';
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
