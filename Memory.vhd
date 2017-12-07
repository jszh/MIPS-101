library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity memory is
	port(
		clk, rst : in std_logic;  --时钟
		
		--RAM1 (serial port access)
		data_ready : in std_logic;		--数据准备信号??='1'表示串口的数据已准备好（读串口成功，可显示读到的data??
		tbre : in std_logic;				--发???数据标??
		tsre : in std_logic;				--数据发???完毕标志，tsre and tbre = '1'时写串口完毕
		wrn : out std_logic;				--写串口，初始化为'1'，先置为'0'并把RAM1data赋好，再置为'1'写串??
		rdn : out std_logic;				--读串口，初始化为'1'并将RAM1data赋为"ZZ..Z"??--若data_ready='1'，则把rdn置为'0'即可读串口（读出数据在RAM1data上）
		
		--RAM2 (IM+DM)
		MemRead, MemWrite : in std_logic;			--控制读，写DM的信号，='1'代表??要读，写
		
		WriteData : in std_logic_vector(15 downto 0);		--写内存时，要写入DM或IM的数??		
		address : in std_logic_vector(15 downto 0);		--读DM/写DM/写IM时，地址输入
		PC_out : in std_logic_vector(15 downto 0);		--读IM时，地址输入
		PC_MUX_out : in std_logic_vector(15 downto 0);	
		PC_Keep : in std_logic;
		
		ReadData : out std_logic_vector(15 downto 0);	--读DM时，读出来的数据/读出的串口状??
		ReadIns : out std_logic_vector(15 downto 0);		--读IM时，出来的指??
		
		ram1_addr, ram2_addr : out std_logic_vector(19 downto 0);	--RAM1 RAM2地址总线
		ram1_data, ram2_data : inout std_logic_vector(31 downto 0);	--RAM1 RAM2数据总线
		
		ram1_en, ram1_oe, ram1_we : out std_logic;		--RAM1使能 读使?? 写使??  ='1'禁止，永远等??'1'
		
		ram2_en, ram2_oe, ram2_we : out std_logic;		--RAM2使能 读使?? 写使能，='1'禁止，永远等??'0'
		
		memory_state : out std_logic_vector(1 downto 0);
		flash_state_out : out std_logic_vector(2 downto 0);
		
		flash_finished : out std_logic := '0';
		
		--Flash
		flash_addr : out std_logic_vector(22 downto 0);		--flash地址??
		flash_data : inout std_logic_vector(15 downto 0);	--flash数据??
		
		flash_byte : out std_logic := '1';	--flash操作模式，常??'1'
		flash_vpen : out std_logic := '1';	--flash写保护，常置'1'
		flash_rp : out std_logic := '1';		--'1'表示flash工作，常??'1'
		flash_ce : out std_logic := '0';		--flash使能
		flash_oe : out std_logic := '1';		--flash读使能，'0'有效，每次读操作后置'1'
		flash_we : out std_logic := '1'		--flash写使??
	);
end memory;

architecture Behavioral of memory is

	signal state : std_logic_vector(1 downto 0) := "00";	--访存、串口操作的状???
	signal rflag : std_logic := '0';		--rflag='1'代表把串口数据线（ram1_data）置高阻，用于节省状态的控制
	
	signal flash_finished_tmp : std_logic := '0';
	signal flash_state : std_logic_vector(2 downto 0) := "001";
	signal current_addr : std_logic_vector(15 downto 0) := (others => '0');	--flash当前要读的地??
	signal ram2_load_addr : std_logic_vector(15 downto 0) := (others => '0');
	shared variable cnt : integer := 0;	--用于削弱50M时钟频率??1M
	shared variable write_wait_count : integer := 0;

	signal FLASH_DATA_LEN : std_logic_vector(15 downto 0) := x"042E";	--data length to load into RAM2
	
begin

	memory_state <= state;
	flash_finished <= flash_finished_tmp;
	flash_state_out <= flash_state;

	process(clk, rst)
	begin
	
		if (rst = '1') then  --rst
			ram2_oe <= '1';  --读写使能置否  读写锁存置否
			ram2_we <= '1';
			wrn <= '1';
			rdn <= '1';
			rflag <= '0';
			
			ram1_addr <= (others => '0'); 
			ram2_addr <= (others => '0'); 
			
			ReadData <= (others => '0');
			ReadIns <= (others => '0');
			
			state <= "00";			
			flash_state <= "001";   
			current_addr <= (others => '0');
			flash_addr <= (others => '0');
			ram2_load_addr <= (others => '0');
			
		elsif (clk'event and clk = '1') then 
			if (flash_finished_tmp = '1') then			--从flash载入kernel指令到ram2已完??
				flash_ce <= '1';	--禁止flash
				flash_byte <= '1';
				flash_vpen <= '1';
				flash_rp <= '1';
				
				ram1_en <= '1';		--RAM1: serial access only
				ram1_oe <= '1';
				ram1_we <= '1';
				ram1_addr(19 downto 0) <= (others => '0');
                wrn <= '1';
                rdn <= '1';
				
				ram2_en <= '0';
				ram2_addr(19 downto 16) <= "0000";
				ram2_oe <= '1';
				ram2_we <= '1';
				
				case state is 
						
					when "00" =>		--准备读指??
						if PC_Keep = '0' then
							ram2_addr(15 downto 0) <= PC_MUX_out;
						elsif PC_Keep = '1' then
							ram2_addr(15 downto 0) <= PC_out;
						end if;
						ram2_data <= (others => 'Z');
						wrn <= '1';
						rdn <= '1';
						ram2_oe <= '0';
						state <= "01";
						
					when "01" =>		--读出指令，准备读/?? 串口/内存
						ram2_oe <= '1';
						ReadIns <= ram2_data(15 downto 0);
						if (MemWrite = '1') then	--如果要写
							rflag <= '0';
							if (address = x"BF00") then 	--准备写串??
								ram1_data <= (31 downto 8 => '0') & WriteData(7 downto 0);
								wrn <= '0';
								rdn <= '1';
							else							--准备写内??
								ram2_addr(15 downto 0) <= address;
								ram2_data <= (31 downto 16 => '0') & WriteData;
								ram2_we <= '0';
							end if;
						elsif (MemRead = '1') then	--如果要读
							if (address = x"BF01") then 	--准备读串口状??
								ReadData(15 downto 2) <= (others => '0');
								ReadData(1) <= data_ready;
								
								if (tsre and tbre) = '1' then
									write_wait_count := write_wait_count + 1;
									if write_wait_count >= 1 then
										ReadData(0) <= '1';
										write_wait_count := 0;
									else
										ReadData(0) <= '0';
									end if;
								else
									ReadData(0) <= '0';
									write_wait_count := 0;
								end if;
								
								if (rflag = '0') then	--读串口状态时意味??接下来可能要??/写串口数??
									ram1_data <= (others => 'Z');	--故预先把ram1_data置为高阻
									rflag <= '1';	--如果接下来要读，则可直接rdn='0'，省1个状态；要写，则rflag='0'，正常走写串口的流程
								end if;	
							elsif (address = x"BF00") then	--准备读串口
								rflag <= '0';
								rdn <= '0';
								wrn <= '1';
							else							--准备读内存
								ram2_data <= (others => 'Z');
								ram2_addr(15 downto 0) <= address;
								ram2_oe <= '0';
							end if;
						end if;	
						state <= "10";
						
					when "10" =>		--read/write serial/mem
						if (MemWrite = '1') then		--write
							if (address = x"BF00") then		--写串口
								wrn <= '1';
							else							--写内存
								ram2_we <= '1';
							end if;
						elsif (MemRead = '1') then	--read
							if (address = x"BF01") then		--读串口状态（01中已读出）
								null;
							elsif (address = x"BF00") then 	--读串口
								rdn <= '1';
								ReadData(15 downto 8) <= (others => '0');
								ReadData(7 downto 0) <= ram1_data(7 downto 0);
							else							--读内存
								ram2_oe <= '1';
								ReadData <= ram2_data(15 downto 0);
							end if;
						end if;
						state <= "00";
						
					when others =>
						state <= "00";		
				end case;
				
			else				--从flash载入kernel指令到ram2尚未完成，则继续载入
				if (cnt = 1000) then
					cnt := 0;
					
					case flash_state is		
						when "001" =>		--WE set to 0
							ram2_en <= '0';
							ram2_we <= '0';
							ram2_oe <= '1';
							wrn <= '1';
							rdn <= '1';
							flash_we <= '0';
							flash_oe <= '1';
							
							flash_byte <= '1';
							flash_vpen <= '1';
							flash_rp <= '1';
							flash_ce <= '0';
							
							flash_state <= "010";
							
						when "010" =>
							flash_data <= x"00FF";
							flash_state <= "011";
							
						when "011" =>
							flash_we <= '1';
							flash_state <= "100";
							
						when "100" =>
							flash_addr <= "000000" & current_addr & '0';
							flash_data <= (others => 'Z');
							flash_oe <= '0';
							flash_state <= "101";
							
						when "101" =>
							ram2_we <= '0';
							ram2_addr <= "0000" & ram2_load_addr;
							ram2_data <= (31 downto 16 => '0') & flash_data;
							flash_oe <= '1';
							flash_state <= "110";
						
						when "110" =>
							ram2_we <= '1';
							current_addr <= current_addr + 2;
							ram2_load_addr <= ram2_load_addr + 1;
							flash_state <= "001";
							
						when others =>
							flash_state <= "001";
					end case;
					
					if (current_addr > FLASH_DATA_LEN) then
						flash_finished_tmp <= '1';
					end if;
				else 
					if (cnt < 1000) then
						cnt := cnt + 1;
					end if;
				end if;	--cnt=1000
				
			end if;	--flash
			
		end if;	--rst/clk
		
	end process;
	
end Behavioral;

