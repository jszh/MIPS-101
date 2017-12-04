library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity DVI is
	port(
		clk_in : in std_logic; -- must 50M Clock
		rst : in std_logic;

		-- registers
		RegPC : in std_logic_vector(15 downto 0);
		RegR0 : in std_logic_vector(15 downto 0);
		RegR1 : in std_logic_vector(15 downto 0);
		RegR2 : in std_logic_vector(15 downto 0);
		RegR3 : in std_logic_vector(15 downto 0);
		RegR4 : in std_logic_vector(15 downto 0);
		RegR5 : in std_logic_vector(15 downto 0);
		RegR6 : in std_logic_vector(15 downto 0);
		RegR7 : in std_logic_vector(15 downto 0);
		RegSP : in std_logic_vector(15 downto 0);
		RegIH : in std_logic_vector(15 downto 0);
		RegT : in std_logic_vector(15 downto 0);
		RegRA : in std_logic_vector(15 downto 0);
		
		-- common ports
		video_vsync : out std_logic:= '0';
		video_hsync : out std_logic:= '0';
		video_pixel : out std_logic_vector(7 downto 0);
		video_clk : out std_logic;
		video_de : out std_logic := '0'
	);
end DVI;

architecture Behavioral of DVI is
	signal clk : std_logic; -- div 50M to 25M
	signal OnOff : std_logic;
	signal vector_x : std_logic_vector(9 downto 0);		--X 10b 640
	signal vector_y : std_logic_vector(8 downto 0);		--Y 9b 480
	signal r0 : std_logic_vector(2 downto 0);
	signal g0 : std_logic_vector(2 downto 0);
	signal b0 : std_logic_vector(1 downto 0);
	signal hs1 : std_logic;
	signal vs1 : std_logic;
	
	signal char : std_logic_vector(7 downto 0) := "00000000";
	signal pr : std_logic_vector(0 DOWNTO 0);
	signal char_addr : std_logic_vector(14 downto 0);
	signal caddr : std_logic_vector(10 downto 0);
	type matrix IS array (15 downto 0) of std_logic_vector (15 downto 0);
		signal zero : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000011111100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
	
		signal one : matrix := (
			 "0000000000000000",
			 "0000000000000000",
			 "0000000110000000",
			 "0000001010000000",
			 "0000000010000000",
			 "0000000010000000",
			 "0000000010000000",
			 "0000000010000000",
			 "0000000010000000",
			 "0000000010000000",
			 "0000011111110000",
			 "0000000000000000",
			 "0000000000000000",
			 "0000000000000000",
			 "0000000000000000",
			 "0000000000000000"
		);
		signal symbolr : matrix := (
		  "0000000000000000",
		  "0000000000000000",
		  "0000000011111000",
		  "0000000010000100",
		  "0000000010000100",
		  "0000000010001000",
		  "0000000011110000",
		  "0000000010100000",
		  "0000000010010000",
		  "0000000010001000",
		  "0000000010000100",
		  "0000000010000010",
		  "0000000000000000",
		  "0000000000000000",
		  "0000000000000000",
		  "0000000000000000"
		);
		signal two : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000011111100000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000011111100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal three : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000011111100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000011111100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal four : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000011111100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal five : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111100000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000011111100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000011111100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal six : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111100000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000011111100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000011111100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal seven : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symboli : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000000011110000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000011110000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symbolh : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000011111100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symbolt : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000001111111100",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000001100000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symbols : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000000011110000",
			"0000000110011000",
			"0000000100001000",
			"0000000010000000",
			"0000000001000000",
			"0000000000100000",
			"0000000000010000",
			"0000000100011000",
			"0000000110001000",
			"0000000011110000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symbolp : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000011111000000",
			"0000010000100000",
			"0000010000100000",
			"0000010000100000",
			"0000011111000000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symbolp2 : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000000111110000",
			"0000000100001000",
			"0000000100001000",
			"0000000100001000",
			"0000000111110000",
			"0000000100000000",
			"0000000100000000",
			"0000000100000000",
			"0000000100000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
		signal symbola : matrix := (
					"0000000000000000",
					"0000000000000000",
					"0000000000000000",
					"0000000010000000",
					"0000000101000000",
					"0000001000100000",
					"0000010000010000",
					"0000111111111000",
					"0000100000001000",
					"0000100000001000",
					"0000100000001000",
					"0000000000000000",
					"0000000000000000",
					"0000000000000000",
					"0000000000000000",
					"0000000000000000"
				);
		signal symbolr2 : matrix := (
			  "0000000000000000",
			  "0000000000000000",
			  "0000000011111000",
			  "0000000010000100",
			  "0000000010000100",
			  "0000000010001000",
			  "0000000011110000",
			  "0000000010100000",
			  "0000000010010000",
			  "0000000010001000",
			  "0000000010000100",
			  "0000000010000010",
			  "0000000000000000",
			  "0000000000000000",
			  "0000000000000000",
			  "0000000000000000"
			);	
		signal symbolc : matrix := (
			"0000000000000000",
			"0000000000000000",
			"0000001111000000",
			"0000011000100000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000010000000000",
			"0000011000100000",
			"0000001111000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0000000000000000"
		);
begin
process(clk_in)
begin
	if(clk_in'event and clk_in = '1') then
		clk <= not clk;
		video_clk <= clk;
	end if;
end process;

process(clk, rst)	-- ???????????? (800)
begin
	if rst = '1' then
		vector_x <= (others => '0');
	elsif clk'event and clk = '1' then
		if vector_x = 799 then
			vector_x <= (others => '0');
		else
			vector_x <= vector_x + 1;
		end if;
	end if;
end process;

process(clk, rst)	-- ?????????? (525)
begin
	if rst = '1' then
		vector_y <= (others => '0');
	elsif clk'event and clk = '1' then
		if vector_x = 799 then
			if vector_y = 524 then
				vector_y <= (others => '0');
			else
				vector_y <= vector_y + 1;
			end if;
		end if;
	end if;
end process;

process(clk, rst) -- ?????????640+????????16??+96??+48???
begin
	if rst='1' then
		hs1 <= '1';
	elsif clk'event and clk='1' then
		if vector_x >= 656 and vector_x < 752 then
			hs1 <= '0';
		else
			hs1 <= '1';
		end if;
	end if;
end process;

process(clk, rst) -- ?????????480+????????10??+2??+33???
begin
	if rst = '1' then
		vs1 <= '1';
	elsif clk'event and clk = '1' then
		if vector_y >= 490 and vector_y < 492 then
			vs1 <= '0';
		else
			vs1 <= '1';
		end if;
	end if;
end process;

process(clk, rst)
begin
	if rst = '1' then
		video_hsync <= '0';
		video_vsync <= '0';
	elsif clk'event and clk = '1' then
		video_hsync <= hs1;
		video_vsync <= vs1;
	end if;
end process;


process(rst, clk_in, vector_x, vector_y)
begin
	OnOff <= '1';
	if rst = '1' then
		OnOff <= '0';
	elsif clk_in'event and clk_in = '1' then
		if vector_x > 639 or vector_y > 479 then
			OnOff <= '0';
			elsif vector_x > 144 and vector_x < 160 then
				if vector_y > 15 and vector_y < 145 then
					if(symbolr((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 144 and vector_y < 161 then
					if(symboli((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 160 and vector_y < 177 then
					if(symbols((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 176 and vector_y < 193 then
					if(symbolt((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 192 and vector_y < 208 then
					if(symbolp2((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 209 and vector_y < 224 then
					if(symbolr2((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				
				else
					OnOff <= '0';
				end if;
			elsif vector_x > 160 and vector_x < 176 then
				if vector_y > 15 and vector_y < 32 then
					if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 32 and vector_y < 49 then
					if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 48 and vector_y < 65 then
					if(two((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 64 and vector_y < 81 then
					if(three((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 80 and vector_y < 97 then
					if(four((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 96 and vector_y < 113 then
					if(five((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 112 and vector_y < 129 then
					if(six((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 128 and vector_y < 145 then
					if(seven((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 144 and vector_y < 161 then
					if(symbolh((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 160 and vector_y < 177 then
					if(symbolp((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				elsif vector_y > 192 and vector_y < 209 then
					if(symbolc((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				
				elsif vector_y > 209 and vector_y < 226 then
					if(symbola((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				else
					OnOff <= '0';
				end if;
			elsif vector_y > 15 and vector_y < 32 and vector_x > 192 and vector_x < 448 then
				if(RegR0(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
					if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				else
					if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				end if;
			elsif vector_y > 32 and vector_y < 49 and vector_x > 192 and vector_x < 448 then
				if(RegR1(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
					if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				else
					if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				end if;
			elsif vector_y > 48 and vector_y < 65 and vector_x > 192 and vector_x < 448 then
				if(RegR2(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
					if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				else
					if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				end if;
			elsif vector_y > 64 and vector_y < 81 and vector_x > 192 and vector_x < 448 then
				if(RegR3(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
					if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				else
					if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
						OnOff <= '1';
					else
						OnOff <= '0';
					end if;
				end if;
		elsif vector_y > 80 and vector_y < 97 and vector_x > 192 and vector_x < 448 then
			if(RegR4(15 - ((conv_integer(vector_x)-192)/16))= '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 96 and vector_y < 113 and vector_x > 192 and vector_x < 448 then
			if(RegR5(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 112 and vector_y < 129 and vector_x > 192 and vector_x < 448 then
			if(RegR6(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 128 and vector_y < 145 and vector_x > 192 and vector_x < 448 then
			if(RegR7(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 144 and vector_y < 161 and vector_x > 192 and vector_x < 448 then
			if(RegIH(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 160 and vector_y < 177 and vector_x > 192 and vector_x < 448 then
			if(RegSP(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 176 and vector_y < 192 and vector_x > 192 and vector_x < 448 then
			if(RegT(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 192 and vector_y < 209 and vector_x > 192 and vector_x < 448 then
			if(RegPC(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
		elsif vector_y > 209 and vector_y < 226 and vector_x > 192 and vector_x < 448 then
			if(RegRA(15 - ((conv_integer(vector_x)-192)/16)) = '0') then
				if(zero((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			else
				if(one((15-conv_integer(vector_y)) mod 16)((15-conv_integer(vector_x)) mod 16) = '1') then
					OnOff <= '1';
				else
					OnOff <= '0';
				end if;
			end if;
	 else
			OnOff <= '0';
	 end if;
	end if;
end process;

process(rst, clk, vector_x, vector_y) -- X, Y ???????
	begin
		
		if rst = '1' then
			r0 <= "000";
			g0 <= "000";
			b0 <= "00";
			video_de <= '0';
			
		elsif clk'event and clk = '1' then
			if vector_x > 639 or vector_y > 479 then
				r0 <= "000";
				g0 <= "000";
				b0 <= "00";
				video_de <= '0';
			else
				video_de <= '1';
				-- play-ground		
				-- play-ground
				
				if OnOff <= '0' then
					r0 <= "111";
					g0 <= "111";
					b0 <= "11";
				else
					r0 <= "000";
					g0 <= "001";
					b0 <= "01";
				end if;
				
				-- play-ground
				-- play-ground
			end if;
		end if;
  end process;

	process(hs1, vs1, r0, g0, b0) -- ??????????
		begin
			if hs1 = '1' and vs1 = '1' then
			video_pixel(7 downto 5) <= r0;
			video_pixel(4 downto 2) <= g0;
			video_pixel(1 downto 0) <= b0; 
			 
			else
				video_pixel(7 downto 5) <= "000";
				video_pixel(4 downto 2) <= "000";
				video_pixel(1 downto 0) <= "00"; 
			end if;
			
			
		end process;

end Behavioral;


