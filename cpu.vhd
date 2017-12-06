library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
		touch_btn : in std_logic_vector(5 downto 0);	-- 4-manual clk, 5-rst
		clk_in : in std_logic;	-- 50M clock
		opt, dvi_en : in std_logic;	-- clock option; display output enable

		-- UART serial
		uart_dataready : in std_logic;	-- data ready
		uart_tbre : in std_logic;	-- data-to-send buffered
		uart_tsre : in std_logic;	-- data sent
		uart_rdn : inout std_logic;	-- read enable
		uart_wrn : inout std_logic;	-- write enable

		-- RAM1: only used for serial port
		base_ram_ce_n : out std_logic;	-- chip enable
		base_ram_we_n : out std_logic;	-- write enable
		base_ram_oe_n : out std_logic;	-- output enable
		base_ram_data : inout std_logic_vector(31 downto 0);	-- data bus
		base_ram_addr : out std_logic_vector(19 downto 0);	-- address bus

		-- RAM2
		ext_ram_ce_n : out std_logic;
		ext_ram_we_n : out std_logic;
		ext_ram_oe_n : out std_logic;
		ext_ram_data : inout std_logic_vector(31 downto 0);
		ext_ram_addr : out std_logic_vector(19 downto 0);
		
		-- leds 15-0: led; 31-16: 7-segment displays
		leds : out std_logic_vector(31 downto 0);
		
		-- DVI video
		video_hsync, video_vsync : out std_logic;	-- sync signals
		video_pixel : OUT std_logic_vector(7 DOWNTO 0);
		video_clk : OUT std_logic;
		video_de : out std_logic := '0';	-- always '0'

		-- flash
		flash_a : out std_logic_vector(22 downto 0);	-- flash address bus
		flash_data : inout std_logic_vector(15 downto 0);	-- flash data bus
		
		flash_byte_n : out std_logic;	-- flash op mode; always '1'
		flash_vpen : out std_logic;	-- flash write protection; always '1'
		flash_rp_n : out std_logic;	-- power transition; always '1'
		flash_ce_n : out std_logic;	-- flash chip enable (active low)
		flash_oe_n : out std_logic;	-- flash output enable
		flash_we_n : out std_logic	-- flash write enable
	);

end cpu;

architecture Behavioral of cpu is
	
	component DVI
	port(
		clk_in : in std_logic; -- requires 50M Clock
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
	end component;
	
	-- IM and DM
	component memory
	port(
		clk, rst : in std_logic;
		
		-- RAM1�����ڣ�
		data_ready : in std_logic;		-- ����׼���źţ�='1'��ʾ���ڵ�������׼���ã������ڳɹ�������ʾ������data��
		tbre : in std_logic;			-- �������ݱ�־
		tsre : in std_logic;			-- ���ݷ�����ϱ�־��tsre and tbre = '1'ʱд�������
		wrn : out std_logic;			-- д���ڣ���ʼ��Ϊ'1'������Ϊ'0'����base_ram_data���ã�����Ϊ'1'д����
		rdn : out std_logic;			-- �����ڣ���ʼ��Ϊ'1'����base_ram_data��Ϊ"ZZ..Z"��-- ��data_ready='1'�����rdn��Ϊ'0'���ɶ����ڣ�����������base_ram_data�ϣ�
		
		-- RAM2��IM+DM��
		MemRead, MemWrite : in std_logic;			-- ���ƶ���дDM���źţ�='1'������Ҫ����д
		
		WriteData : in std_logic_vector(15 downto 0);	-- д�ڴ�ʱ��Ҫд��DM��IM������
		address : in std_logic_vector(15 downto 0);		-- ��DM/дDM/дIMʱ����ַ����
		PC_out : in std_logic_vector(15 downto 0);		-- ��IMʱ����ַ����
		PC_MUX_out : in std_logic_vector(15 downto 0);
		PC_Keep : in std_logic;
		
		ReadData : out std_logic_vector(15 downto 0);	-- ��DMʱ��������������/�����Ĵ���״̬
		ReadIns : out std_logic_vector(15 downto 0);	-- ��IMʱ��������ָ��
		
		ram1_addr, ram2_addr : out std_logic_vector(19 downto 0);	-- RAM1 RAM2��ַ����
		ram1_data, ram2_data : inout std_logic_vector(31 downto 0);	-- RAM1 RAM2��������
		
		ram1_en, ram1_oe, ram1_we : out std_logic;		-- RAM1ʹ�� ��ʹ�� дʹ��  ='1'��ֹ����Զ����'1'
		
		ram2_en, ram2_oe, ram2_we : out std_logic;		-- RAM2ʹ�� ��ʹ�� дʹ�ܣ�='1'��ֹ����Զ����'0'
		
		memory_state : out std_logic_vector(1 downto 0);
		flash_state_out : out std_logic_vector(2 downto 0);
		
		flash_finished : out std_logic := '0';
		
		-- Flash
		flash_addr : out std_logic_vector(22 downto 0);
		flash_data : inout std_logic_vector(15 downto 0);
		
		flash_byte : out std_logic := '1';
		flash_vpen : out std_logic := '1';
		flash_rp : out std_logic := '1';
		flash_ce : out std_logic := '0';
		flash_oe : out std_logic := '1';
		flash_we : out std_logic := '1'
	);
	end component;
	

	component clock
	port ( 
		rst : in STD_LOGIC;
		clk : in  STD_LOGIC;
		
		clk_out :out STD_LOGIC;
		clk1 : out  STD_LOGIC;
		clk2 : out STD_LOGIC
	);
	end component;


	component ALU
	port(
		Asrc : in std_logic_vector(15 downto 0);
		Bsrc : in std_logic_vector(15 downto 0);
		ALUop : in std_logic_vector(3 downto 0);
		ALUresult : out std_logic_vector(15 downto 0) := "0000000000000000"
	);
	end component;

	-- ALU MUX A: 1st operator
	component MUX_A
	port(
		ForwardA : in std_logic_vector(1 downto 0);	-- forwarding control
		ReadData1 : in std_logic_vector(15 downto 0);	-- ReadData selection
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- EX/MEM forwarding
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- MEM/WB forwarding

		Asrc_out : out std_logic_vector(15 downto 0)	-- output
	);
	end component;

	-- ALU MUX B: 2nd operator
	component MUX_B
	port(
		ForwardB : in std_logic_vector(1 downto 0);
		ALUsrc : in std_logic;	-- choose imme / reg, from Controller
		ReadData2 : in std_logic_vector(15 downto 0);
		imme : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- prev instruction
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- prev prev instruction
		Bsrc_out : out std_logic_vector(15 downto 0)	-- output
	);	
	end component;


	-- MUX for branch judge
	component MUX_BJ
	port(
		ForwardBJ : in std_logic_vector(1 downto 0);	-- forwarding control
		ReadData1 : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	-- EX/MEM forwarding
		MEM_WB_result : in std_logic_vector(15 downto 0);	-- MEM/WB forwarding

		MUX_BJ_out : out std_logic_vector(15 downto 0)	-- output
	);
	end component;


	component branch_judge
	port(
		Branch     :  in std_logic_vector(2 downto 0);
		Data       :  in std_logic_vector(15 downto 0);
		BranchJudge : out std_logic
	);
	end component;


	-- �������п����źŵĿ�����
	component controller
	port(	
		command_in : in std_logic_vector(15 downto 0);
		rst : in std_logic;
		controller_out :  out std_logic_vector(23 downto 0);	-- controller_out �����п����źż�����һ����ʵ��
		-- extend(3) reg1_select(3) reg2_select(2) regwrite(1)  -- 9
		-- jump(1) ALUsrc(1) ALUop(4) regdst(3) memread(1)      -- 10
		-- memwrite(1) branch(3) memtoreg(1)                    -- 5
		MFPC_out : out std_logic
	);
	end component;

	-- ѡ����PC�ĵ�Ԫ
	component PC_MUX_add
	port(
		PC_addOne : in std_logic_vector(15 downto 0);
		IF_ID_imme : in std_logic_vector(15 downto 0);
		IF_ID_PC : in std_logic_vector(15 downto 0);
		Asrc_out : in std_logic_vector(15 downto 0);
		
		Jump : in std_logic;	-- Jump signal
		BranchJudge : in std_logic;		-- from branch_judge
		PC_Rollback : in std_logic;		-- SW���ݳ�ͻʱ��PC��Ҫ���˵�SW��һ��ָ��ٵĵ�ַ������ǰ��PC+1�Ǣ۵ĵ�ַ�����Դ�ʱPC_out = PC_addOne - 2;
		
		PC_out : out std_logic_vector(15 downto 0)
	);
	end component;

	-- PC+1 for MFPC
	component MUX_MFPC
	port(
		PC_addOne : in std_logic_vector(15 downto 0);	
		ALUresult : in std_logic_vector(15 downto 0);
		MFPC : in std_logic;	-- when '1': out = PC+1
		
		MUX_MFPC_out : out std_logic_vector(15 downto 0)
	);
	end component;


	-- EX/MEM registers
	component reg_EX_MEM
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;
		-- ��������
		Rd_in : in std_logic_vector(3 downto 0);
		MUX_MFPC_in : in std_logic_vector(15 downto 0);
		ReadData2_in : in std_logic_vector(15 downto 0); -- ��SW���д�ڴ�
		-- �ź�����
		RegWrite_in : in std_logic;
		MemRead_in : in std_logic;
		MemWrite_in : in std_logic;
		MemToReg_in : in std_logic;

		-- �������
		Rd_out : out std_logic_vector(3 downto 0);
		ALUresult_out : out std_logic_vector(15 downto 0);
		ReadData2_out : out std_logic_vector(15 downto 0); -- ��SW���д�ڴ�
		-- �ź����
		RegWrite_out : out std_logic;
		MemRead_out : out std_logic;
		MemWrite_out : out std_logic;
		MemToReg_out : out std_logic
	);
	end component;
	
	-- forwarding unit
	--	IF - EX/MEM
	--	ID - EX/MEM
	component forwarding_unit
	port(
		IF_ID_Rs: in std_logic_vector(2 downto 0);
		IF_ID_T : in std_logic;

		ID_EX_Rs : in std_logic_vector(3 downto 0);
		ID_EX_Rt : in std_logic_vector(3 downto 0);

		EX_MEM_Rd : in std_logic_vector(3 downto 0);
		MEM_WB_Rd : in std_logic_vector(3 downto 0);
		
		Branch : in std_logic_vector(2 downto 0);
		ID_EX_MemWrite : in std_logic;

		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0);
		ForwardSW : out std_logic_vector(1 downto 0);
		ForwardBJ : out std_logic_vector(1 downto 0)
	);
	end component;
	
	-- Hazard detection unit
	--	ID/MEM hazard
	--	branch related hazard
	component hazard_detection
	port(
		ID_EX_Rd : in std_logic_vector(3 downto 0);
		ID_EX_MemRead : in std_logic;
		ID_EX_ALUop: in std_logic_vector(3 downto 0);
		ID_EX_MFPC : in std_logic;
		EX_MEM_Rd: in std_logic_vector(3 downto 0);
		EX_MEM_Read: in std_logic;
		
		reg1_select : in std_logic_vector(3 downto 0);
		reg2_select : in std_logic_vector(3 downto 0);

		Branch : in std_logic_vector(2 downto 0);
		
		PC_Keep : out std_logic;
		IF_ID_Keep : out std_logic;
		ID_EX_Flush : out std_logic
	);
	end component;
	
	-- ID/EX registers
	component reg_ID_EX
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;

		LW_ID_EX_Flush : in std_logic;	-- LW data conflict
		Branch_ID_EX_Flush : in std_logic;	-- B
		Jump_ID_EX_Flush : in std_logic;	-- JR
		SW_ID_EX_Flush : in std_logic;	-- SW structural conflict
		
		PC_in : in std_logic_vector(15 downto 0);
		Rd_in : in std_logic_vector(3 downto 0);	-- "0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1110"-n/a
		Reg1_in : in std_logic_vector(3 downto 0);	-- "0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1011"-RA,"1111"-n/a
		Reg2_in : in std_logic_vector(3 downto 0);	-- "0xxx"-R0~R7,"1000"-RA,"1111"-n/a
		ALUsrc_in : in std_logic;	-- '0'-reg, '1'-imme
		ReadData1_in : in std_logic_vector(15 downto 0);	-- Reg1 data
		ReadData2_in : in std_logic_vector(15 downto 0);	-- Reg2 data
		imme_in : in std_logic_vector(15 downto 0);	-- extended immediate
		
		MFPC_in : in std_logic;
		RegWrite_in : in std_logic;
		MemWrite_in : in std_logic;
		MemRead_in : in std_logic;
		MemToReg_in : in std_logic;
		Jump_in : in std_logic;
		-- Branch_in : in std_logic;
		ALUop_in : in std_logic_vector(3 downto 0);
		
	
		PC_out : out std_logic_vector(15 downto 0);
		Rd_out : out std_logic_vector(3 downto 0);
		Reg1_out : out std_logic_vector(3 downto 0);
		Reg2_out : out std_logic_vector(3 downto 0);
		ALUsrc_out : out std_logic;
		ReadData1_out : out std_logic_vector(15 downto 0);
		ReadData2_out : out std_logic_vector(15 downto 0);
		imme_out : out std_logic_vector(15 downto 0);
		
		MFPC_out : out std_logic;
		RegWrite_out : out std_logic;
		MemWrite_out : out std_logic;
		MemRead_out : out std_logic;
		MemToReg_out : out std_logic;
		Jump_out : out std_logic;
		ALUop_out : out std_logic_vector(3 downto 0)
	);
	end component;
	
	-- IF/ID registers
	component reg_IF_ID
	port(
		rst : in std_logic;
		clk : in std_logic;
		flash_finished : in std_logic;
		command_in : in std_logic_vector(15 downto 0);
		PC_in : in std_logic_vector(15 downto 0); 
		IF_ID_Keep : in std_logic;		-- LW���ݳ�ͻ��
		Branch_IF_ID_Flush : in std_logic;		-- ��תʱ��
		Jump_IF_ID_Flush : in std_logic;		-- JR��תʱ��
		SW_IF_ID_Flush : in std_logic;			-- SW�ṹ��ͻ��
		
		Rs : out std_logic_vector(2 downto 0);		-- Command[10:8]
		IF_ID_T : out std_logic;	-- For branch judge forwarding
		Rt : out std_logic_vector(2 downto 0);		-- Command[7:5]
		Rd : out std_logic_vector(2 downto 0);		-- Command[4:2]
		imme_10_0 : out std_logic_vector(10 downto 0);	-- Command[10:0]
		command_out : out std_logic_vector(15 downto 0);
		PC_out : out std_logic_vector(15 downto 0)  -- PC+1����MFPCָ���EXE��
	);
	end component;
	
	-- immediate value extension
	component imme_extension
	port(
		 imme_in : in std_logic_vector(10 downto 0);
		 imme_select : in std_logic_vector(2 downto 0); -- expansion type, from controller
		 imme_out : out std_logic_vector(15 downto 0)
	);
	end component;
	
	-- MEM/WB registers
	component reg_MEM_WB
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;
		-- ����
		ReadMemData_in : in std_logic_vector(15 downto 0);	-- DataMemory����������
		ALUresult_in : in std_logic_vector(15 downto 0);		-- ALU�ļ�����
		Rd_in : in std_logic_vector(3 downto 0);				-- Ŀ�ļĴ���
		-- �����ź�
		RegWrite_in : in std_logic;		-- �Ƿ�Ҫд��
		MemToReg_in : in std_logic;		-- д��ʱѡ��ReadMemData_in��'1'������ALUresult_in��'0'��
		
		data_to_WB : out std_logic_vector(15 downto 0);		-- д�ص�����
		Rd_out : out std_logic_vector(3 downto 0);				-- Ŀ�ļĴ�����"0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1110"-û��Ŀ�ļĴ���
		RegWrite_out : out std_logic								-- �Ƿ�Ҫд��
	);
	end component;
	
	-- PC adder
	component PC_adder
	port(
		adder_in : in std_logic_vector(15 downto 0);
		adder_out : out std_logic_vector(15 downto 0)
	);
	end component;
	
	-- PC register
	component PC_reg
	port(
		rst, clk : in std_logic;
		flash_finished : in std_logic;
		PC_Keep : in std_logic;		-- ��hazard_detection�����Ŀ����ź�
		PC_in : in std_logic_vector(15 downto 0);		-- PC_MUX_add�����ֵ��ѡ��PCֵ��
		PC_out : out std_logic_vector(15 downto 0)		-- �͸�IMȥȡָ��PC
	);
	end component;
	
	-- Reg1 source selector
	component MUX_Reg1
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);	-- R0~R7�е�һ��
		
		reg1_select : in std_logic_vector(2 downto 0);	-- control signal
		
		reg1_out : out std_logic_vector(3 downto 0)	-- "0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1111"=û��
	);
	end component;
	
	-- Reg2 source selector
	component MUX_Reg2
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);	-- R0~R7�е�һ��
		
		reg2_select : in std_logic_vector(1 downto 0);	-- contorl signal
		
		reg2_out : out std_logic_vector(3 downto 0)	-- "0XXX"����R0~R7, "1111"=û��
	);
	end component;
	
	-- Destination reg source selector
	component MUX_Rd
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);
		Rd : in std_logic_vector(2 downto 0);		-- one of R0 .. R7

		RegDst : in std_logic_vector(2 downto 0);	-- from controller

		Rd_out : out std_logic_vector(3 downto 0)	-- "0XXX": R0~R7; "1000"=SP,"1001"=IH, "1010"=T, "1110"=n/a
	);
	end component;


	component registers
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		read_reg1 : in std_logic_vector(3 downto 0);	-- "0XXX"����R0~R7 "1000"=SP,"1001"=IH, "1010"=T "1011"=RA "1100"=PC
		read_reg2 : in std_logic_vector(3 downto 0);	-- "0XXX"����R0~R7  "1000"=RA
		
		dst_reg : in std_logic_vector(3 downto 0);	-- ��WB�׶δ��أ�Ŀ�ļĴ���
		WriteData : in std_logic_vector(15 downto 0);	-- ��WB�׶δ��أ�дĿ�ļĴ���������
		RegWrite : in std_logic;					-- ��WB�׶δ��أ�RegWrite��дĿ�ļĴ����������ź�
		
		flash_finished : in std_logic;
		
		r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out : out std_logic_vector(15 downto 0);
		
		ReadData1 : out std_logic_vector(15 downto 0); -- �����ļĴ���1������
		ReadData2 : out std_logic_vector(15 downto 0); -- �����ļĴ���2������
		data_T, data_SP, data_IH, data_RA : out std_logic_vector(15 downto 0);
		reg_state : out std_logic_vector(1 downto 0)
	);
	end component;
	
	-- SWдָ���ڴ� �ṹ��ͻ
	component structural_conflict
	port(
		ID_EX_MemWrite : in std_logic;
		ALU_result_addr : in std_logic_vector(15 downto 0);
		
		IF_ID_Flush : out std_logic;
		ID_EX_Flush : out std_logic;
		PC_Rollback : out std_logic
	);
	end component;
	
	-- for WriteData input
	component MUX_SW
	port(
		ForwardSW : in std_logic_vector(1 downto 0);
		ReadData2 : in std_logic_vector(15 downto 0);
		EX_MEM_result : in std_logic_vector(15 downto 0);	
		MEM_WB_result : in std_logic_vector(15 downto 0);	
		WriteData_out : out std_logic_vector(15 downto 0)
	);
	end component;
	
	
	-- signals for component connections

	-- cpu
	signal rst, clk_manual : std_logic;
	signal digit1, digit2 : std_logic_vector(7 downto 0);
	
	-- clock	
	signal clkIn_clock : std_logic;	-- main clock
	signal clk : std_logic;
	signal clk_3 : std_logic;
	signal clk_registers : std_logic;
	signal dvi_clk : std_logic;
	
	-- PC_reg
	signal PC_out : std_logic_vector(15 downto 0); 
	
	-- PC_adder
	signal PC_addOne : std_logic_vector(15 downto 0);
	
	-- reg_IF_ID
	signal IF_ID_T : std_logic;
	signal Rs, Rt, Rd : std_logic_vector(2 downto 0);
	signal imme_10_0 : std_logic_vector(10 downto 0);
	signal IF_ID_cmd, IF_ID_PC : std_logic_vector(15 downto 0);
	
	-- MUX_Rd
	signal Rd_choice : std_logic_vector(3 downto 0);
	
	-- controller
	signal controller_out : std_logic_vector(23 downto 0);
	signal MFPC_control : std_logic;
	
	-- MUX_Reg1,2
	signal MUX_Reg1_out : std_logic_vector(3 downto 0);
	signal MUX_Reg2_out : std_logic_vector(3 downto 0);
	
	-- registers
	signal ReadData1, ReadData2 : std_logic_vector(15 downto 0);
	signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0);
	signal data_T, data_SP, data_IH, data_RA : std_logic_vector(15 downto 0);
	signal reg_state : std_logic_vector(1 downto 0);
	
	-- imme_extension
	signal extended_imme : std_logic_vector(15 downto 0);
	
	-- reg_ID_EX
	signal ID_EX_PC : std_logic_vector(15 downto 0);
	signal ID_EX_Rd : std_logic_vector(3 downto 0);
	signal ID_EX_Reg1, ID_EX_Reg2 : std_logic_vector(3 downto 0);
	signal ID_EX_ALUsrc : std_logic;
	signal ID_EX_ReadData1, ID_EX_ReadData2 : std_logic_vector(15 downto 0);
	signal ID_EX_imme : std_logic_vector(15 downto 0);
	signal ID_EX_RegWrite, ID_EX_MemWrite, ID_EX_MemRead, ID_EX_MemToReg : std_logic;
	signal ID_EX_MFPC, ID_EX_JR : std_logic;
	signal ID_EX_ALUop : std_logic_vector(3 downto 0);
	
	-- reg_EX_MEM
	signal EX_MEM_Rd : std_logic_vector(3 downto 0);
	signal EX_MEM_ReadData2 : std_logic_vector(15 downto 0);
	signal EX_MEM_result : std_logic_vector(15 downto 0);	-- ����MUX_MFPCѡ���Ľ��
	
	signal EX_MEM_RegWrite : std_logic;
	signal EX_MEM_Read, EX_MEM_Write, EX_MEM_MemToReg: std_logic;
	
	-- forwarding_unit
	signal ForwardA, ForwardB, ForwardSW, ForwardBJ : std_logic_vector(1 downto 0);
	
	-- reg_MEM_WB
	signal Rd_to_write : std_logic_vector(3 downto 0);
	signal data_to_WB : std_logic_vector(15 downto 0);
	signal MEM_WB_RegWrite : std_logic;

	-- MUX_BJ, branch_judge
	signal MUX_BJ_out : std_logic_vector(15 downto 0);
	signal BranchJudge : std_logic;

	-- ALU
	signal ALUresult : std_logic_vector(15 downto 0);
	
	-- EX stage MUXes
	signal MUX_A_out : std_logic_vector(15 downto 0);
	signal MUX_B_out : std_logic_vector(15 downto 0);
	signal WriteData_out : std_logic_vector(15 downto 0);
	signal MUX_MFPC_out : std_logic_vector(15 downto 0);
	
	-- PC_MUX/adder
	signal PC_MUX_out : std_logic_vector(15 downto 0);
	
	-- hazard_detection
	signal PC_Keep : std_logic;
	signal IF_ID_Keep : std_logic;
	signal LW_ID_EX_Flush : std_logic;
	
	-- memory
	signal DM_data_out : std_logic_vector(15 downto 0);
	signal IM_instruction_out : std_logic_vector(15 downto 0);
	signal memory_state : std_logic_vector(1 downto 0);
	signal flash_state_out : std_logic_vector(2 downto 0);
	signal flash_finished : std_logic := '0';
		
	-- structual_conflict (SW)
	signal SW_IF_ID_Flush : std_logic;
	signal SW_ID_EX_Flush : std_logic;
	signal PC_Rollback : std_logic;


begin
	-- cpu wiring
	rst <= touch_btn(5);
	clk_manual <= touch_btn(4);
	dvi_clk <= clk_in and dvi_en;
	leds(23 downto 16) <= digit1;
	leds(31 downto 24) <= digit2;


	-- clk source
	process(opt, clk_in, rst, clk_manual, flash_finished)
	begin
		if opt = '0' and flash_finished = '1' then
			if rst = '1' then
				clkIn_clock <= '0';
			else
				clkIn_clock <= clk_manual;
			end if;
		else
			if rst = '1' then
				clkIn_clock <= '0';
			else 
				clkIn_clock <= clk_in;	-- ???
			end if;
		end if;
	end process;

	u00 : clock
	port map(
		rst => rst,
		clk => clkIn_clock,
		
		clk_out => clk,
		clk1 => clk_3,
		clk2 => clk_registers
	);


	u10 : PC_reg
	port map(
		rst => rst,
		clk => clk_3,
		flash_finished => flash_finished,
		PC_Keep => PC_Keep,
		PC_in => PC_MUX_out,
		PC_out => PC_out
	);

	u11 : PC_adder
	port map( 
		adder_in => PC_out,
		adder_out => PC_addOne
	);

	u12 : PC_MUX_add
	port map( 
		PC_addOne => PC_addOne,
		IF_ID_PC => IF_ID_PC,
		IF_ID_imme => extended_imme,
		Asrc_out => ReadData1,
		
		Jump => controller_out(14),
		BranchJudge => BranchJudge,
		PC_Rollback => PC_Rollback,
		
		PC_out => PC_MUX_out
	);


	u20 : reg_IF_ID
	port map(
		rst => rst,
		clk => clk_3,
		flash_finished => flash_finished,
		command_in => IM_instruction_out,
		PC_in => PC_addOne,
		IF_ID_Keep => IF_ID_Keep,
		Branch_IF_ID_Flush => BranchJudge, 
		Jump_IF_ID_Flush => controller_out(14),
		SW_IF_ID_Flush => SW_IF_ID_Flush,
		
		Rs => Rs,
		IF_ID_T => IF_ID_T,
		Rt => Rt,
		Rd => Rd,
		imme_10_0 => imme_10_0,
		command_out => IF_ID_cmd,
		PC_out => IF_ID_PC
	);

	u21 : controller
	port map(	
		command_in => IF_ID_cmd,
		rst => rst,
		controller_out => controller_out,
		-- im_sel(23-21) reg1_sel(20-18) reg2_sel(17-16) regwrite(15)	-- 9
		-- jump(14) ALUsrc(13) ALUop(12-9) regdst(8-6) memread(5)	-- 10
		-- memwrite(4) branch(3-1) memtoreg(0)						-- 5
		MFPC_out => MFPC_control
	);

	u22 : MUX_Reg1
	port map(
		Rs => Rs,
		Rt => Rt,
		reg1_select => controller_out(20 downto 18),
		
		reg1_out => MUX_Reg1_out
	);

	u23 : MUX_Reg2
	port map(
		Rs => Rs,
		Rt => Rt,
		reg2_select => controller_out(17 downto 16),
		
		reg2_out => MUX_Reg2_out
	);

	u24 : registers
	port map(
		clk => clk,
		rst => rst,
		read_reg1 => MUX_Reg1_out,
		read_reg2 => MUX_Reg2_out,
		-- from WB stage:
		dst_reg => Rd_to_write,
		WriteData => data_to_WB,
		RegWrite => MEM_WB_RegWrite,
		-- 
		flash_finished => flash_finished,
		
		r0_out => r0,
		r1_out => r1,
		r2_out => r2,
		r3_out => r3,
		r4_out => r4,
		r5_out => r5,
		r6_out => r6,
		r7_out => r7,
		ReadData1 => ReadData1,
		ReadData2 => ReadData2,
		data_T => data_T,
		data_SP => data_SP,
		data_IH => data_IH,
		data_RA => data_RA,
		reg_state => reg_state
	);

	u25 : MUX_BJ
	port map(
		ForwardBJ => ForwardBJ,
		ReadData1 => ReadData1,
		EX_MEM_result => EX_MEM_result,
		MEM_WB_result => data_to_WB,

		MUX_BJ_out => MUX_BJ_out
	);

	u26 : branch_judge
	port map(
		Branch => controller_out(3 downto 1),
		Data => MUX_BJ_out,
		BranchJudge => BranchJudge
	);
		
	u27 : MUX_Rd
	port map(
		Rs => Rs,
		Rt => Rt,
		Rd => Rd,
		
		RegDst => controller_out(8 downto 6),
		Rd_out => Rd_choice
	);
		
	u28 : imme_extension
	port map(
		imme_in => imme_10_0,
		imme_select => controller_out(23 downto 21),
		imme_out => extended_imme
	);


	u30 : reg_ID_EX
	port map(
		clk => clk_3,
		rst => rst,
		flash_finished => flash_finished,
		
		LW_ID_EX_Flush => LW_ID_EX_Flush,
		Branch_ID_EX_Flush => BranchJudge,
		Jump_ID_EX_Flush => ID_EX_JR,
		SW_ID_EX_Flush => SW_ID_EX_Flush,
		
		PC_in => IF_ID_PC,
		Rd_in => Rd_choice,
		Reg1_in => MUX_Reg1_out,
		Reg2_in => MUX_Reg2_out,
		ALUsrc_in => controller_out(13),	-- EX
		ReadData1_in => ReadData1,
		ReadData2_in => ReadData2,
		imme_in => extended_imme,
		
		MFPC_in => MFPC_control,	-- EX
		RegWrite_in => controller_out(15),	
		MemWrite_in => controller_out(4),	-- MEM
		MemRead_in => controller_out(5),	-- MEM
		MemToReg_in => controller_out(0),	-- WB
		Jump_in => controller_out(14),	-- EX
		-- Branch_in => BranchJudge,
		ALUop_in => controller_out(12 downto 9),	-- EX
	
		PC_out => ID_EX_PC,
		Rd_out => ID_EX_Rd,
		Reg1_out => ID_EX_Reg1,
		Reg2_out => ID_EX_Reg2,
		ALUsrc_out => ID_EX_ALUsrc,
		ReadData1_out => ID_EX_ReadData1,
		ReadData2_out => ID_EX_ReadData2,
		imme_out => ID_EX_imme,
		
		MFPC_out => ID_EX_MFPC,
		RegWrite_out => ID_EX_RegWrite,
		MemWrite_out => ID_EX_MemWrite,
		MemRead_out => ID_EX_MemRead,
		MemToReg_out => ID_EX_MemToReg,
		Jump_out => ID_EX_JR,
		ALUop_out => ID_EX_ALUop
	);
		
	u31 : MUX_A
	port map(
		ForwardA => ForwardA,
		
		ReadData1 => ID_EX_ReadData1,
		EX_MEM_result => EX_MEM_result,
		MEM_WB_result => data_to_WB,
		
		Asrc_out => MUX_A_out
	);
		
	u32 : MUX_B
	port map(
		ForwardB => ForwardB,
		ALUsrc => ID_EX_ALUsrc,
		
		ReadData2 => ID_EX_ReadData2,
		imme => ID_EX_imme,
		EX_MEM_result => EX_MEM_result,
		MEM_WB_result => data_to_WB,
		
		Bsrc_out => MUX_B_out
	);
	
	u33 : ALU
	port map(
		Asrc		=> MUX_A_out,
		Bsrc		=> MUX_B_out,
		ALUop		=> ID_EX_ALUop,
		
		ALUresult	=> ALUresult
	);
	
	u34 : MUX_MFPC
	port map(
		PC_addOne => ID_EX_PC,
		ALUresult => ALUresult,
		MFPC => ID_EX_MFPC,
	
		MUX_MFPC_out => MUX_MFPC_out
	);
		
	u35 : MUX_SW
	port map(
		ForwardSW => ForwardSW,
		
		ReadData2 => ID_EX_ReadData2,
		EX_MEM_result => EX_MEM_result,
		MEM_WB_result => data_to_WB,
		
		WriteData_out => WriteData_out
	);


	u40 : reg_EX_MEM
	port map(
		clk => clk_3,
		rst => rst,
		flash_finished => flash_finished,
		
		Rd_in => ID_EX_Rd,
		MUX_MFPC_in => MUX_MFPC_out,
		ReadData2_in => WriteData_out,
		
		RegWrite_in => ID_EX_RegWrite,
		MemRead_in => ID_EX_MemRead,
		MemWrite_in => ID_EX_MemWrite,
		MemToReg_in => ID_EX_MemToReg,
					
		Rd_out => EX_MEM_Rd,
		ALUresult_out => EX_MEM_result,
		ReadData2_out => EX_MEM_ReadData2,
		
		RegWrite_out => EX_MEM_RegWrite,
		MemRead_out => EX_MEM_Read,
		MemWrite_out => EX_MEM_Write,
		MemToReg_out => EX_MEM_MemToReg
	);

	u41 : memory
		port map( 
		clk => clk,
		rst => rst,
		
		data_ready => uart_dataready,
		tbre => uart_tbre,
		tsre => uart_tsre,
		wrn => uart_wrn,
		rdn => uart_rdn,
			
		MemRead => EX_MEM_Read,
		MemWrite => EX_MEM_Write,
		
		WriteData => EX_MEM_ReadData2,
		
		address => EX_MEM_result,
		PC_out => PC_out,
		PC_MUX_out => PC_MUX_out,
		PC_Keep => PC_Keep,

		ReadData => DM_data_out,
		ReadIns => IM_instruction_out,
		
		ram1_addr => base_ram_addr,
		ram2_addr => ext_ram_addr,
		ram1_data => base_ram_data,
		ram2_data => ext_ram_data,
		
		ram1_en => base_ram_ce_n,
		ram1_oe => base_ram_oe_n,
		ram1_we => base_ram_we_n,
		ram2_en => ext_ram_ce_n,
		ram2_oe => ext_ram_oe_n,
		ram2_we => ext_ram_we_n,
		
		memory_state => memory_state,
		flash_state_out => flash_state_out,
		flash_finished => flash_finished,

		flash_addr => flash_a,
		flash_data => flash_data,
		
		flash_byte => flash_byte_n,
		flash_vpen => flash_vpen,
		flash_rp => flash_rp_n,
		flash_ce => flash_ce_n,
		flash_oe => flash_oe_n,
		flash_we => flash_we_n
	);


	u50 : reg_MEM_WB
	port map(
		clk => clk_3,
		rst => rst,
		flash_finished => flash_finished,
		
		ReadMemData_in => DM_data_out,
		ALUresult_in => EX_MEM_result,
		Rd_in => EX_MEM_Rd,
		
		RegWrite_in => EX_MEM_RegWrite,
		MemToReg_in => EX_MEM_MemToReg,
		
		data_to_WB => data_to_WB,
		Rd_out => Rd_to_write,
		RegWrite_out => MEM_WB_RegWrite
	);


	u60 : forwarding_unit
	port map(
		IF_ID_Rs => Rs,
		IF_ID_T => IF_ID_T,

		ID_EX_Rs => ID_EX_Reg1,
		ID_EX_Rt => ID_EX_Reg2,

		EX_MEM_Rd => EX_MEM_Rd,
		MEM_WB_Rd => Rd_to_write,

		Branch => controller_out(3 downto 1),
		ID_EX_MemWrite => ID_EX_MemWrite,
		
		ForwardA => ForwardA,
		ForwardB => ForWardB,
		ForwardSW => ForWardSW,
		ForwardBJ => ForwardBJ
	);
	
	u61 : hazard_detection
	port map(
		ID_EX_Rd => ID_EX_Rd,
		ID_EX_MemRead => ID_EX_MemRead,
		ID_EX_ALUop => ID_EX_ALUop,
		ID_EX_MFPC => ID_EX_MFPC,
		EX_MEM_Rd => EX_MEM_Rd,
		EX_MEM_Read => EX_MEM_Read,
		
		reg1_select => MUX_Reg1_out,
		reg2_select => MUX_Reg2_out,

		Branch => controller_out(3 downto 1),
		
		PC_Keep => PC_Keep,
		IF_ID_Keep => IF_ID_Keep,
		ID_EX_Flush => LW_ID_EX_Flush
	);
	
	u62 : structural_conflict
	port map(
		ID_EX_MemWrite => ID_EX_MemWrite,
		ALU_result_addr => ALUresult,
		
		IF_ID_Flush => SW_IF_ID_Flush,
		ID_EX_Flush => SW_ID_EX_Flush,
		PC_Rollback => PC_Rollback
	);


	u70 : DVI
	port map(
		clk_in => dvi_clk,
		rst => '0',

		-- registers
		RegPC => IM_instruction_out,
		RegR0 => r0,
		RegR1 => MUX_B_out,
		RegR2 => EX_MEM_result,
		RegR3 => data_to_WB,
		RegR4 => r4,
		RegR5 => r5,
		RegR6 => r6,
		RegR7 => r7,
		RegSP => data_SP,
		RegIH => data_IH,
		RegT => data_T,
		RegRA => data_RA,
		
		-- common ports
		video_vsync => video_vsync,
		video_hsync => video_hsync,
		video_pixel => video_pixel,
		video_clk => video_clk,
		video_de => video_de
	);
	
	
	-- leds
	process(EX_MEM_Read, EX_MEM_Write)
	begin
		leds(15 downto 0) <= (0=>EX_MEM_Read, 1=>EX_MEM_Write, others=>'0');
	end process;
	

	-- 7-segment displays
	process(PC_out)
	begin
		case PC_out(3 downto 0) is
			when "0000" => digit1 <= "01111110";	-- 0
			when "0001" => digit1 <= "00010010";	-- 1
			when "0010" => digit1 <= "10111100";	-- 2
			when "0011" => digit1 <= "10110110";	-- 3
			when "0100" => digit1 <= "11010010";	-- 4
			when "0101" => digit1 <= "11100110";	-- 5
			when "0110" => digit1 <= "11101110";	-- 6
			when "0111" => digit1 <= "00110010";	-- 7
			when "1000" => digit1 <= "11111110";	-- 8
			when "1001" => digit1 <= "11110110";	-- 9
			when "1010" => digit1 <= "11111010";	-- A
			when "1011" => digit1 <= "11001110";	-- B
			when "1100" => digit1 <= "01101100";	-- C
			when "1101" => digit1 <= "10011110";	-- D
			when "1110" => digit1 <= "11101100";	-- E
			when "1111" => digit1 <= "11101000";	-- F
			when others => digit1 <= "00000000";
		end case;
		
		case PC_out(7 downto 4) is
			when "0000" => digit2 <= "01111110";	-- 0
			when "0001" => digit2 <= "00010010";	-- 1
			when "0010" => digit2 <= "10111100";	-- 2
			when "0011" => digit2 <= "10110110";	-- 3
			when "0100" => digit2 <= "11010010";	-- 4
			when "0101" => digit2 <= "11100110";	-- 5
			when "0110" => digit2 <= "11101110";	-- 6
			when "0111" => digit2 <= "00110010";	-- 7
			when "1000" => digit2 <= "11111110";	-- 8
			when "1001" => digit2 <= "11110110";	-- 9
			when "1010" => digit2 <= "11111010";	-- A
			when "1011" => digit2 <= "11001110";	-- B
			when "1100" => digit2 <= "01101100";	-- C
			when "1101" => digit2 <= "10011110";	-- D
			when "1110" => digit2 <= "11101100";	-- E
			when "1111" => digit2 <= "11101000";	-- F
			when others => digit2 <= "00000000";
		end case;
	 end process;

end Behavioral;
