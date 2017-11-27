library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registers is
	port(
			clk : in std_logic;
			rst : in std_logic;
			
			read_reg1 : in std_logic_vector(3 downto 0);  --"0XXX"代表R0~R7 "1000"=SP,"1001"=IH, "1010"=T "1011"=RA "1100"=PC
			read_reg2 : in std_logic_vector(3 downto 0);  --"0XXX"代表R0~R7  "1000"=RA
			
			write_reg : in std_logic_vector(3 downto 0);	  --由WB阶段传回：目的寄存器
			write_data : in std_logic_vector(15 downto 0);  --由WB阶段传回：写目的寄存器的数据
			reg_write : in std_logic;					--由WB阶段传回：reg_write（写目的寄存器）控制信号
			
			flashFinished : in std_logic;
			
			r0_out, r1_out, r2_out,r3_out,r4_out,r5_out,r6_out,r7_out : out std_logic_vector(15 downto 0);
			
			read_data1 : out std_logic_vector(15 downto 0); --读出的寄存器1的数据
			read_data2 : out std_logic_vector(15 downto 0); --读出的寄存器2的数据
			data_T, data_SP, data_IH, data_RA : out std_logic_vector(15 downto 0);
			reg_state : out std_logic_Vector(1 downto 0)
			
	);
end Registers;

architecture Behavioral of Registers is

	signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0);
	signal T, SP, IH, RA : std_logic_vector(15 downto 0);
	
	signal state : std_logic_vector(1 downto 0) := "00";

begin
	process(clk, rst)
	begin
		if (rst = '0') then
			r0 <= (others => '0');
			r1 <= (others => '0');
			r2 <= (others => '0');
			r3 <= (others => '0');
			r4 <= (others => '0');
			r5 <= (others => '0');
			r6 <= (others => '0');
			r7 <= (others => '0');
			T <= (others => '0');
			IH <= (others => '0');			
			SP <= (others => '0');
			RA <= (others => '0');
			state <= "00";
			
		elsif (clk'event and clk = '1') then
			
			if flashFinished = '1' then  --指令加载完成
			
				case state is
					
					when "00" =>						
						state <= "01";
						
					when "01" =>
						state <= "10";
				
					when "10" =>						--写回
						if (reg_write = '1') then 
							case write_reg is 
								when "0000" => r0 <= write_data;
								when "0001" => r1 <= write_data;
								when "0010" => r2 <= write_data;
								when "0011" => r3 <= write_data;
								when "0100" => r4 <= write_data;
								when "0101" => r5 <= write_data;
								when "0110" => r6 <= write_data;
								when "0111" => r7 <= write_data;
								when "1000" => SP <= write_data;
								when "1001" => IH <= write_data;
								when "1010" => T <= write_data;
								when "1011" => RA <= write_data;
								when others =>
							end case;
						end if;
						
						state <= "00";

					
					when others =>
						state <= "00";
					
				end case;
				
			end if;
		end if;
	end process;
	
	
	process(read_reg1, read_reg2, r0, r1, r2, r3,r4,r5,r6,r7,SP,IH,T,RA)
	begin
		case read_reg1 is 
			when "0000" => read_data1 <= r0;
			when "0001" => read_data1 <= r1;
			when "0010" => read_data1 <= r2;
			when "0011" => read_data1 <= r3;
			when "0100" => read_data1 <= r4;
			when "0101" => read_data1 <= r5;
			when "0110" => read_data1 <= r6;
			when "0111" => read_data1 <= r7;
			when "1000" => read_data1 <= SP;
			when "1001" => read_data1 <= IH;
			when "1010" => read_data1 <= T;
			when others =>
		end case;
		
		case read_reg2 is
			when "0000" => read_data2 <= r0;
			when "0001" => read_data2 <= r1;
			when "0010" => read_data2 <= r2;
			when "0011" => read_data2 <= r3;
			when "0100" => read_data2 <= r4;
			when "0101" => read_data2 <= r5;
			when "0110" => read_data2 <= r6;
			when "0111" => read_data2 <= r7;
			when "1000" => read_data2 <= RA;
			when others =>
		end case;
		
	end process;
	
	
	
	data_SP <= SP;
	data_IH <= IH;
	data_T <= T;
	data_RA <= RA;
	
	r0_out <= r0;
	r1_out <= r1;
	r2_out <= r2;
	r3_out <= r3;
	r4_out <= r4;
	r5_out <= r5;
	r6_out <= r6;
	r7_out <= r7;
	
	reg_state <= state;
	
end Behavioral;