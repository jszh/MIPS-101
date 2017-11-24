library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MemoryUnit is
	port(
		clk, rst : in std_logic;  --时钟
		
		--RAM1（串口）
		data_ready : in std_logic;		--数据准备信号，='1'表示串口的数据已准备好（读串口成功，可显示读到的data）
		tbre : in std_logic;				--发送数据标志
		tsre : in std_logic;				--数据发送完毕标志，tsre and tbre = '1'时写串口完毕
		wrn : out std_logic;				--写串口，初始化为'1'，先置为'0'并把RAM1data赋好，再置为'1'写串口
		rdn : out std_logic;				--读串口，初始化为'1'并将RAM1data赋为"ZZ..Z"，
												--若data_ready='1'，则把rdn置为'0'即可读串口（读出数据在RAM1data上）
		
		--RAM2（IM+DM）
		mem_read, mem_write : in std_logic;			--控制读，写DM的信号，='1'代表需要读，写
		
		write_data : in std_logic_vector(15 downto 0);		--写内存时，要写入DM或IM的数据		
		address : in std_logic_vector(15 downto 0);		--读DM/写DM/写IM时，地址输入
		pc_out : in std_logic_vector(15 downto 0);		--读IM时，地址输入
		pc_mux_out : in std_logic_vector(15 downto 0);	
		pc_keep : in std_logic;
		
		read_data : out std_logic_vector(15 downto 0);	--读DM时，读出来的数据/读出的串口状态
		read_ins : out std_logic_vector(15 downto 0);		--读IM时，出来的指令
		
		ram1_addr, ram2_addr : out std_logic_vector(17 downto 0); 	--RAM1 RAM2地址总线
		ram1_data, ram2_data : inout std_logic_vector(15 downto 0);--RAM1 RAM2数据总线
		
		ram2addr_output : out std_logic_vector(17 downto 0);
		
		ram1_en, ram1_oe, ram1_we : out std_logic;		--RAM1使能 读使能 写使能  ='1'禁止，永远等于'1'
		
		ram2_en, ram2_oe, ram2_we : out std_logic;		--RAM2使能 读使能 写使能，='1'禁止，永远等于'0'
		
		memory_state : out std_logic_vector(1 downto 0);
		falsh_stateout : out std_logic_vector(2 downto 0);
		
		flash_finished : out std_logic := '0';
		
		--Flash
		flash_addr : out std_logic_vector(22 downto 0);		--flash地址线
		flash_data : inout std_logic_vector(15 downto 0);	--flash数据线
		
		flash_byte : out std_logic := '1';	--flash操作模式，常置'1'
		flash_vpen : out std_logic := '1';	--flash写保护，常置'1'
		flash_rp : out std_logic := '1';		--'1'表示flash工作，常置'1'
		flash_ce : out std_logic := '0';		--flash使能
		flash_oe : out std_logic := '1';		--flash读使能，'0'有效，每次读操作后置'1'
		flash_we : out std_logic := '1'		--flash写使能
		
		
		
	);
end MemoryUnit;

architecture Behavioral of MemoryUnit is

	signal state : std_logic_vector(1 downto 0) := "00";	--访存、串口操作的状态
	signal rflag : std_logic := '0';		--rflag='1'代表把串口数据线（ram1_data）置高阻，用于节省状态的控制
	
	signal flash_finished : std_logic := '0';
	signal flash_state : std_logic_vector(2 downto 0) := "001";
	signal current_addr : std_logic_vector(15 downto 0) := (others => '0');	--flash当前要读的地址
	shared variable cnt : integer := 0;	--用于削弱50M时钟频率至1M
	
begin
	process(clk, rst)
	begin
	
		if (rst = '1') then  --rst被按下
			ram2_oe <= '1';  --读写使能置否  读写锁存置否
			ram2_we <= '1';
			wrn <= '1';
			rdn <= '1';
			rflag <= '0';  --todo  不是很懂
			
			ram1_addr <= (others => '0'); 
			ram2_addr <= (others => '0'); 
			
			read_data <= (others => '0');
			read_ins <= (others => '0');
			
			state <= "00";			
			flash_state <= "001";   
			current_addr <= (others => '0');
			
		elsif (clk'event and clk = '1') then 
			if (flash_finished = '1') then			--从flash载入kernel指令到ram2已完成
				flash_byte <= '1';
				flash_vpen <= '1';
				flash_rp <= '1';
				flash_ce <= '1';	--禁止flash
				ram1_en <= '1';
				ram1_oe <= '1';
				ram1_we <= '1';
				ram1_addr(17 downto 0) <= (others => '0');
				ram2_en <= '0';
				ram2_addr(17 downto 16) <= "00";
				ram2_oe <= '1';
				ram2_we <= '1';
				wrn <= '1';
				rdn <= '1';
				
				case state is 
						
					when "00" =>		--准备读指令
						if pc_keep = '0' then
							ram2_addr(15 downto 0) <= pc_mux_out;
						elsif pc_keep = '1' then
							ram2_addr(15 downto 0) <= pc_out;
						end if;
						ram2_data <= (others => 'Z');
						wrn <= '1';
						rdn <= '1';
						ram2_oe <= '0';
						state <= "01";
						
					when "01" =>		--读出指令，准备读/写 串口/内存
						ram2_oe <= '1';
						read_ins <= ram2_data;
						if (mem_write = '1') then	--如果要写
							rflag <= '0';
							if (address = x"BF00") then 	--准备写串口
								ram1_data(7 downto 0) <= write_data(7 downto 0);
								wrn <= '0';
							else							--准备写内存
								ram2_addr(15 downto 0) <= address;
								ram2_data <= write_data;
								ram2_we <= '0';
							end if;
						elsif (mem_read = '1') then	--如果要读
							if (address = x"BF01") then 	--准备读串口状态
								read_data(15 downto 2) <= (others => '0');
								read_data(1) <= data_ready;
								read_data(0) <= tsre and tbre;
								if (rflag = '0') then	--读串口状态时意味着接下来可能要读/写串口数据
									ram1_data <= (others => 'Z');	--故预先把ram1_data置为高阻
									rflag <= '1';	--如果接下来要读，则可直接把rdn置'0'，省一个状态；要写，则rflag='0'，正常走写串口的流程
								end if;	
							elsif (address = x"BF00") then	--准备读串口数据
								rflag <= '0';
								rdn <= '0';
							else							--准备读内存
								ram2_data <= (others => 'Z');
								ram2_addr(15 downto 0) <= address;
								ram2_oe <= '0';
							end if;
						end if;	
						state <= "10";
						
					when "10" =>		--读/写 串口/内存
						if(mem_write = '1') then		--写
							if (address = x"BF00") then		--写串口
								wrn <= '1';
							else							--写内存
								ram2_we <= '1';
							end if;
						elsif(mem_read = '1') then	--读
							if (address = x"BF01") then		--读串口状态（已读出）
								null;
							elsif (address = x"BF00") then 	--读串口数据
								rdn <= '1';
								read_data(15 downto 8) <= (others => '0');
								read_data(7 downto 0) <= ram1_data(7 downto 0);
							else							--读内存
								ram2_oe <= '1';
								read_data <= ram2_data;
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
						
						
						when "001" =>		--WE置0
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
							flash_oe <= '1';
							ram2_we <= '0';
							ram2_addr <= "00" & current_addr;
							ram2addr_output <= "00" & current_addr;	--调试
							ram2_data <= flash_data;
							flash_state <= "110";
						
						when "110" =>
							ram2_we <= '1';
							current_addr <= current_addr + '1';
							flash_state <= "001";
						
							
						when others =>
							flash_state <= "001";
						
					end case;
					
					if (current_addr > x"0249") then
						flash_finished <= '1';
					end if;
				else 
					if (cnt < 1000) then
						cnt := cnt + 1;
					end if;
				end if;	--cnt 
				
			end if;	--flash finished or not
			
		end if;	--rst/clk_raise
		
	end process;
	
	
	memory_state <= state;
	flash_finished <= flash_finished;
	falsh_stateout <= flash_state;
	
	
end Behavioral;

