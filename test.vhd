library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test is
    port(
        clk_in : in std_logic;
        clk_uart_in : in std_logic;
        touch_btn : in STD_LOGIC_VECTOR(5 downto 0);
        dip_sw : in std_logic_vector(31 downto 0);
        uart_wrn,uart_rdn,uart_tbre,uart_tsre,uart_dataready : in std_logic;
        base_ram_addr : in std_logic_vector(19 downto 0);
        base_ram_be_n : in std_logic_vector(3 downto 0);
        base_ram_data : inout std_logic_vector(31 downto 0);
        base_ram_ce_n,base_ram_oe_n,base_ram_we_n : in std_logic;
        ext_ram_addr : in std_logic_vector(19 downto 0);
        ext_ram_be_n : in std_logic_vector(3 downto 0);
        ext_ram_data : inout std_logic_vector(31 downto 0);
        ext_ram_ce_n,ext_ram_oe_n,ext_ram_we_n : in std_logic;
        

        leds : out std_logic_vector(31 downto 0)
    );
end test;

architecture behavioral of test is
    component ALU
    port
    (
--      Asrc       :  in STD_LOGIC_VECTOR(15 downto 0);
--		Bsrc       :  in STD_LOGIC_VECTOR(15 downto 0);
--		ALUop		  :  in STD_LOGIC_VECTOR(3 downto 0);
--		ALUresult  :  out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
--		branchJudge : out std_logic
		commandIn : in STD_LOGIC_VECTOR(15 downto 0);
		rst : in std_logic;
		control_out :  out std_logic_vector(23 downto 0) 
    );
    end component;
--    signal A : std_logic_vector(15 downto 0);
--    signal B : std_logic_vector(15 downto 0);
--    signal ALUop : std_logic_vector(3 downto 0);
--    signal result : std_logic_vector(15 downto 0);
--    signal branch : std_logic;
	signal Command :std_logic_vector(15 downto 0);
	signal Rs : in std_logic;
	signal Out : std_logic_vector(23 downto 0);
    type state is (s1,s2,s3,s4);
    signal s : state := s1;
begin
    u1 : ALU
    port map(
        Asrc => A,
        Bsrc => B,
        ALUop => ALUop,
        ALUresult => result,
        branchJudge => branch
    );

    process(touch_btn(5),touch_btn(4))
    begin
        if (touch_btn(4) = '1') then
            s <= s1;
        elsif (touch_btn(5)'event and touch_btn(5) = '1') then
            case s is
                when s1 =>
                    A <= dip_sw(31 downto 16);
                    B <= dip_sw(15 downto 0);
                    s <= s2;
                when s2 =>
                    ALUop <= dip_sw(3 downto 0);
                    s <= s3;
                when s3 =>
                    leds(15 downto 0) <= result;
                    leds(23) <= branch;
                    s <= s4;
                when s4 =>
                     leds <= x"00000000";
                     s <= s1;
                when others =>
            end case ;
        end if;    
            
12
    end process;
    
--    process(ALUop)
--    begin
--         case ALUop is
--			when "0000" => digit <= "0111111";--0
--			when "0001" => digit <= "0001001";--1
--			when "0010" => digit <= "1011110";--2
--			when "0011" => digit <= "1011011";--3
--			when "0100" => digit <= "1101001";--4
--			when "0101" => digit <= "1110011";--5
--			when "0110" => digit <= "1110111";--6
--			when "0111" => digit <= "0011001";--7
--			when "1000" => digit <= "1111111";--8
--			when "1001" => digit <= "1111011";--9
--			when "1010" => digit <= "1111101";--A
--			when "1011" => digit <= "1100111";--B
--			when "1100" => digit <= "0110100";--C
--			when "1101" => digit <= "1001111";--D
--			when "1110" => digit <= "1110110";--E
--			when "1111" => digit <= "1110100";--F
--			when others => digit <= "0000000";
--        end case;
--    end process;
end behavioral;
