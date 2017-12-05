library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity memory is
	port(
		clk, rst : in std_logic;  --ʱ��
		
		--RAM1�����ڣ�
		data_ready : in std_logic;		--����׼���ź�??='1'��ʾ���ڵ�������׼���ã������ڳɹ�������ʾ������data??
		tbre : in std_logic;				--��???���ݱ�??
		tsre : in std_logic;				--���ݷ�???��ϱ�־��tsre and tbre = '1'ʱд�������
		wrn : out std_logic;				--д���ڣ���ʼ��Ϊ'1'������Ϊ'0'����RAM1data���ã�����Ϊ'1'д��??
		rdn : out std_logic;				--�����ڣ���ʼ��Ϊ'1'����RAM1data��Ϊ"ZZ..Z"??--��data_ready='1'�����rdn��Ϊ'0'���ɶ����ڣ�����������RAM1data�ϣ�
		
		--RAM2��IM+DM??
		MemRead, MemWrite : in std_logic;			--���ƶ���дDM���źţ�='1'����??Ҫ����д
		
		WriteData : in std_logic_vector(15 downto 0);		--д�ڴ�ʱ��Ҫд��DM��IM����??		
		address : in std_logic_vector(15 downto 0);		--��DM/дDM/дIMʱ����ַ����
		PC_out : in std_logic_vector(15 downto 0);		--��IMʱ����ַ����
		PC_MUX_out : in std_logic_vector(15 downto 0);	
		PC_Keep : in std_logic;
		
		ReadData : out std_logic_vector(15 downto 0);	--��DMʱ��������������/�����Ĵ���״??
		ReadIns : out std_logic_vector(15 downto 0);		--��IMʱ��������ָ??
		
		ram1_addr, ram2_addr : out std_logic_vector(19 downto 0);	--RAM1 RAM2��ַ����
		ram1_data, ram2_data : inout std_logic_vector(31 downto 0);	--RAM1 RAM2��������
		
		ram2addr_output : out std_logic_vector(17 downto 0);
		
		ram1_en, ram1_oe, ram1_we : out std_logic;		--RAM1ʹ�� ��ʹ?? дʹ??  ='1'��ֹ����Զ��??'1'
		
		ram2_en, ram2_oe, ram2_we : out std_logic;		--RAM2ʹ�� ��ʹ?? дʹ�ܣ�='1'��ֹ����Զ��??'0'
		
		memory_state : out std_logic_vector(1 downto 0);
		flash_state_out : out std_logic_vector(2 downto 0);
		
		flash_finished : out std_logic := '0';
		
		--Flash
		flash_addr : out std_logic_vector(22 downto 0);		--flash��ַ??
		flash_data : inout std_logic_vector(15 downto 0);	--flash����??
		
		flash_byte : out std_logic := '1';	--flash����ģʽ����??'1'
		flash_vpen : out std_logic := '1';	--flashд����������'1'
		flash_rp : out std_logic := '1';		--'1'��ʾflash��������??'1'
		flash_ce : out std_logic := '0';		--flashʹ��
		flash_oe : out std_logic := '1';		--flash��ʹ�ܣ�'0'��Ч��ÿ�ζ���������'1'
		flash_we : out std_logic := '1'		--flashдʹ??
	);
end memory;

architecture Behavioral of memory is

	signal state : std_logic_vector(1 downto 0) := "00";	--�ô桢���ڲ�����״???
	signal rflag : std_logic := '0';		--rflag='1'����Ѵ��������ߣ�ram1_data���ø��裬���ڽ�ʡ״̬�Ŀ���
	
	signal flash_finished_tmp : std_logic := '0';
	signal flash_state : std_logic_vector(2 downto 0) := "001";
	signal current_addr : std_logic_vector(15 downto 0) := (others => '0');	--flash��ǰҪ���ĵ�??
	signal ram2_load_addr : std_logic_vector(15 downto 0) := (others => '0');
	shared variable cnt : integer := 0;	--��������50Mʱ��Ƶ��??1M
	
begin
	process(clk, rst)
	begin
	
		if (rst = '1') then  --rst
			ram2_oe <= '1';  --��дʹ���÷�  ��д�����÷�
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
			if (flash_finished_tmp = '1') then			--��flash����kernelָ�ram2����??
				flash_byte <= '1';
				flash_vpen <= '1';
				flash_rp <= '1';
				flash_ce <= '1';	--��ֹflash
				ram1_en <= '1';
				ram1_oe <= '1';
				ram1_we <= '1';
				ram1_addr(19 downto 0) <= (others => '0');
				ram2_en <= '0';
				ram2_addr(19 downto 16) <= "0000";
				ram2_oe <= '1';
				ram2_we <= '1';
				wrn <= '1';
				rdn <= '1';
				
				case state is 
						
					when "00" =>		--׼����ָ??
						if PC_Keep = '0' then
							ram2_addr(15 downto 0) <= PC_MUX_out;
							ram2addr_output <= "00" & PC_MUX_out;
						elsif PC_Keep = '1' then
							ram2_addr(15 downto 0) <= PC_out;
							ram2addr_output <= "00" & PC_out;
						end if;
						ram2_data <= (others => 'Z');
						wrn <= '1';
						rdn <= '1';
						ram2_oe <= '0';
						state <= "01";
						
					when "01" =>		--����ָ�׼����/?? ����/�ڴ�
						ram2_oe <= '1';
						ReadIns <= ram2_data(15 downto 0);
						if (MemWrite = '1') then	--���Ҫд
							rflag <= '0';
							if (address = x"BF00") then 	--׼��д��??
								ram1_data(7 downto 0) <= WriteData(7 downto 0);
								wrn <= '0';
							else							--׼��д��??
								ram2_addr(15 downto 0) <= address;
								ram2_data <= (31 downto 16 => '0') & WriteData;
								ram2_we <= '0';
							end if;
						elsif (MemRead = '1') then	--���Ҫ��
							if (address = x"BF01") then 	--׼��������״??
								ReadData(15 downto 2) <= (others => '0');
								ReadData(1) <= data_ready;
								ReadData(0) <= tsre and tbre;
								if (rflag = '0') then	--������״̬ʱ��ζ??����������Ҫ??/д������??
									ram1_data <= (others => 'Z');	--��Ԥ�Ȱ�ram1_data��Ϊ����
									rflag <= '1';	--���������Ҫ�������ֱ�Ӱ�rdn??'0'��ʡ??��״̬��Ҫд����rflag='0'��������д���ڵ�����
								end if;	
							elsif (address = x"BF00") then	--׼����������??
								rflag <= '0';
								rdn <= '0';
							else							--׼������??
								ram2_data <= (others => 'Z');
								ram2_addr(15 downto 0) <= address;
								ram2_oe <= '0';
							end if;
						end if;	
						state <= "10";
						
					when "10" =>		--??/?? ����/�ڴ�
						if(MemWrite = '1') then		--??
							if (address = x"BF00") then		--д��??
								wrn <= '1';
							else							--д��??
								ram2_we <= '1';
							end if;
						elsif(MemRead = '1') then	--??
							if (address = x"BF01") then		--������״̬���Ѷ�����
								null;
							elsif (address = x"BF00") then 	--��������??
								rdn <= '1';
								ReadData(15 downto 8) <= (others => '0');
								ReadData(7 downto 0) <= ram1_data(7 downto 0);
							else							--����??
								ram2_oe <= '1';
								ReadData <= ram2_data(15 downto 0);
							end if;
						end if;
						state <= "00";
						
					when others =>
						state <= "00";
						
				end case;
				
			else				--��flash����kernelָ�ram2��δ��ɣ����������
				if (cnt = 1000) then
					cnt := 0;
					
					case flash_state is		
						when "001" =>		--WE??0
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
							ram2addr_output <= "00" & ram2_load_addr;	--����
							ram2_data <= (31 downto 16 => '0') & flash_data;
							flash_state <= "110";
						
						when "110" =>
                            flash_oe <= '1';
							ram2_we <= '1';
							current_addr <= current_addr + 2;
							ram2_load_addr <= ram2_load_addr + 1;
							flash_state <= "001";
							
						when others =>
							flash_state <= "001";
						
					end case;
					
					if (current_addr > x"042E") then
						flash_finished_tmp <= '1';
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
	flash_finished <= flash_finished_tmp;
	flash_state_out <= flash_state;
	
	
end Behavioral;

