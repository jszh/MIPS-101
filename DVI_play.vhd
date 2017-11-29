library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_play is
	Port(
		-- common port
		clk_in: in std_logic; -- must 50M
		video_clk: out std_logic; -- used to sync
		touch_btn: in std_logic_vector(5 downto 0);
		
		-- vga port
		video_pixel: out std_logic_vector(7 downto 0) := "11111111";
		video_hsync: out std_logic := '0';
		video_vsync: out std_logic := '0';
		video_de: out std_logic := '0';
		
		leds : out std_logic_vector(15 downto 0) := "0000000000000000";
		
		-- fifo memory  note
		--wctrl: in std_logic_vector(0 downto 0); -- 1 is write
		--waddr: in std_logic_vector(10 downto 0);
		--wdata : in std_logic_vector(7 downto 0)
		
		--debug
		dip_sw: in std_logic_vector(31 downto 0)
	);
end VGA_play;

architecture Behavioral of VGA_play is
	signal clk: std_logic; -- div 50M to 25M
	signal vector_x : std_logic_vector(9 downto 0);		--X 10b 640
	signal vector_y : std_logic_vector(8 downto 0);		--Y 9b 480
	signal rgb : std_logic_vector(7 downto 0);
	signal hs1 : std_logic;
	signal vs1 : std_logic;

	component char_mem
		PORT (
			clka : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	end component;
	
	component fifo_mem
		PORT (
			-- a for write
			clka : IN STD_LOGIC;
			-- enable, 1 is write signal
			wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			-- b for read
			clkb : IN STD_LOGIC;
			addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	end component;
	
	signal char: std_logic_vector(7 downto 0) := "00000000";
	signal pr: STD_LOGIC_VECTOR(0 DOWNTO 0);
	signal char_addr: std_logic_vector(14 downto 0);
	signal caddr: std_logic_vector(10 downto 0);
	signal reset: std_logic;
begin
    reset <= touch_btn(4);
	-- waddr <= "0000000" & KEY16_INPUT(11 downto 8);
	-- wdata <= KEY16_INPUT(7 downto 0);
	
	-- debug code
	-- LED_output <= "0000" & KEY16_INPUT(11 downto 8) & KEY16_INPUT(7 downto 0);
	-- mout <= wctrl(0 downto 0);
	
	-- process(hclk)
	-- begin
		-- if(hclk'event and hclk = '1') then
			-- wctrl(0 downto 0) <= not wctrl(0 downto 0);
		-- end if;
	-- end process;

	-- store char  note
	ram: char_mem port map(clka => clk, addra => char_addr, douta => pr);
	
	-- display cache
	cache: fifo_mem port map(
		-- a for write
		clka => clk,
		-- enable, 1 is write signal
		--note
		--wea => wctrl,
		--addra => waddr,
		--dina => wdata,
		
		--debug
		wea => dip_sw(0 downto 0),
		addra => dip_sw(11 downto 1),
		dina => dip_sw(19 downto 12),
		
		-- b for read
		clkb => clk,
		addrb => caddr,
		doutb => char
	);
	
	-- cache addr 5 + 6 = 11
	caddr <= vector_y(8 downto 4) & vector_x(9 downto 4);
	
	-- char acess addr 7 + 4 + 4 = 15
	-- last 2 control the display(x, y)
	-- first char control which char
	char_addr <=  char(6 downto 0) & vector_y(3 downto 0) & vector_x(3 downto 0);

-- -- this is only for debug
-- process(reset, hclk)
-- begin
	-- if reset = '0' then
		-- char <= (others => '0');
	-- elsif hclk'event and hclk = '1' then
		-- char <= char + 1;
	-- end if;
-- end process;

-- 25 MHz Sync
video_clk <= clk;
-- 50 MHz -> 25 MHz
process(clk_in)
begin
	if(clk_in' event and clk_in = '1') then
		clk <= not clk;
		leds(0) <= '1';
	end if;
end process;

process(clk, reset)	-- ???????????? (800)
begin
	if reset = '1' then
		vector_x <= (others => '0');
		leds <= "0000000000000000";
	elsif clk'event and clk = '1' then
		if vector_x = 799 then
			vector_x <= (others => '0');
		else
		    leds(1) <= '1';
			vector_x <= vector_x + 1;
		end if;
	end if;
end process;

process(clk, reset)	-- ?????????? (525)
begin
	if reset = '1' then
		vector_y <= (others => '0');
	elsif clk'event and clk = '1' then
		if vector_x = 799 then
			if vector_y = 524 then
				vector_y <= (others => '0');
			else
			    leds(2) <= '1';
				vector_y <= vector_y + 1;
			end if;
		end if;
	end if;
end process;

process(clk, reset) -- ???????????¨640+????????16??+96??+48????
begin
	if reset='1' then
		hs1 <= '1';
	elsif clk'event and clk='1' then
		if vector_x >= 656 and vector_x < 752 then
			hs1 <= '0';
		else
			hs1 <= '1';
		end if;
	end if;
end process;

process(clk, reset) -- ???????????¨480+????????10??+2??+33????
begin
	if reset = '1' then
		vs1 <= '1';
	elsif clk'event and clk = '1' then
		if vector_y >= 490 and vector_y < 492 then
			vs1 <= '0';
		else
			vs1 <= '1';
		end if;
	end if;
end process;

process(clk, reset)
begin
	if reset = '1' then
		video_hsync <= '0';
		video_vsync <= '0';
	elsif clk'event and clk = '1' then
		video_hsync <= hs1;
		video_vsync <= vs1;
	end if;
end process;

process(reset, clk, vector_x, vector_y) -- X, Y ×?±ê????
begin
	if reset = '1' then
	    video_de <= '0';
		rgb <= "00000000";
	elsif clk'event and clk = '1' then
		if vector_x > 639 or vector_y > 479 then
		      rgb <= "00000000";
		      video_de <= '0';
		else
		    video_de <= '1';
			-- play-ground		
			-- play-ground
			
			--这里注释了，pr是什么东西
			--if pr(0) = '1' then
			--	rgb <= "11111111";
			--else
			--    rgb <= "00000101"; 
			--end if;
			
			if(vector_y < 232)then
			     rgb <= "00000000";
		    elsif(vector_y < 312)then
		         rgb <= "00000010";
		    elsif(vector_y < 472)then
		        rgb <= "00001000";
		    elsif(vector_y < 552)then
		        rgb <= "00100000";
		    else
		        rgb <= "10000000";
		    end if;
			
			-- play-ground
			-- play-ground
		end if;
	end if;
end process;

process(hs1, vs1, rgb) -- ×?????????????
begin
	if hs1 = '1' and vs1 = '1' then
		video_pixel <= rgb;
	else
	   video_pixel <= (others => '0');
	end if;
end process;

end Behavioral;
