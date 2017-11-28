library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cpu is
	port(
		rst : in std_logic; --reset
		clk_hand : in std_logic; --ʱ��Դ  Ĭ��Ϊ50M  ����ͨ���޸İ󶨹ܽ����ı�
		clk_50 : in std_logic;
		opt : in std_logic;	--ѡ������ʱ�ӣ�Ϊ�ֶ�����50M��
		
		
		--����
		dataReady : in std_logic;   
		tbre : in std_logic;
		tsre : in std_logic;
		rdn : inout std_logic;
		wrn : inout std_logic;
		
		--RAM1  �������
		ram1En : out std_logic;
		ram1We : out std_logic;
		ram1Oe : out std_logic;
		ram1Data : inout std_logic_vector(15 downto 0);
		ram1Addr : out std_logic_vector(17 downto 0);
		
		--RAM2 ��ų����ָ��
		ram2En : out std_logic;
		ram2We : out std_logic;
		ram2Oe : out std_logic;
		ram2Data : inout std_logic_vector(15 downto 0);
		ram2Addr : out std_logic_vector(17 downto 0);
		
		--debug digit1��digit2��ʾPCֵ��led��ʾ��ǰָ��ı���
		digit1 : out std_logic_vector(6 downto 0);	--7λ�����1
		digit2 : out std_logic_vector(6 downto 0);	--7λ�����2
		led : out std_logic_vector(15 downto 0);
		
		hs,vs : out std_logic;
		redOut, greenOut, blueOut : out std_logic_vector(2 downto 0);
	
		--Flash
		flashAddr : out std_logic_vector(22 downto 0);		--flash��ַ��
		flashData : inout std_logic_vector(15 downto 0);	--flash������
		
		flashByte : out std_logic;	--flash����ģʽ������'1'
		flashVpen : out std_logic;	--flashд����������'1'
		flashRp : out std_logic;	--'1'��ʾflash����������'1'
		flashCe : out std_logic;	--flashʹ��
		flashOe : out std_logic;	--flash��ʹ�ܣ�'0'��Ч��ÿ�ζ���������'1'
		flashWe : out std_logic		--flashдʹ��
	);
			
end cpu;

architecture Behavioral of cpu is
	
	component fontRom
		port (
				clka : in std_logic;
				addra : in std_logic_vector(10 downto 0);
				douta : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component digit
		port (
				clka : in std_logic;
				addra : in std_logic_vector(14 downto 0);
				douta : out std_logic_vector(23 downto 0)
			);
	end component;
	
-- 	component VGA_Controller
-- 		port (
-- 	--VGA Side
-- 		hs,vs	: out std_logic;		--��ͬ������ͬ���ź�
-- 		oRed	: out std_logic_vector (2 downto 0);
-- 		oGreen	: out std_logic_vector (2 downto 0);
-- 		oBlue	: out std_logic_vector (2 downto 0);
-- 	--RAM side
-- --		R,G,B	: in  std_logic_vector (9 downto 0);
-- --		addr	: out std_logic_vector (18 downto 0);
-- 	-- data
-- 		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
-- 	-- font rom
-- 		romAddr : out std_logic_vector(10 downto 0);
-- 		romData : in std_logic_vector(7 downto 0);
-- 	-- pc
-- 		PC : in std_logic_vector(15 downto 0);
-- 		CM : in std_logic_vector(15 downto 0);
-- 		Tdata : in std_logic_vector(15 downto 0);
-- 		SPdata : in std_logic_vector(15 downto 0);
-- 		IHdata : in std_logic_vector(15 downto 0);
-- 		RAdata : in std_logic_vector(15 downto 0);
-- 	--Control Signals
-- 		reset	: in  std_logic;
-- 		CLK_in : in std_logic			--100Mʱ������
-- 	);	
-- 	end component;
	
	component memory
	port(
		clk, rst : in std_logic;  --ʱ��
		
		--RAM1�����ڣ�
		data_ready : in std_logic;		--����׼���źţ�='1'��ʾ���ڵ�������׼���ã������ڳɹ�������ʾ������data��
		tbre : in std_logic;			--�������ݱ�־
		tsre : in std_logic;			--���ݷ�����ϱ�־��tsre and tbre = '1'ʱд�������
		wrn : out std_logic;			--д���ڣ���ʼ��Ϊ'1'������Ϊ'0'����RAM1data���ã�����Ϊ'1'д����
		rdn : out std_logic;			--�����ڣ���ʼ��Ϊ'1'����RAM1data��Ϊ"ZZ..Z"��
										--��data_ready='1'�����rdn��Ϊ'0'���ɶ����ڣ�����������RAM1data�ϣ�
		
		--RAM2��IM+DM��
		mem_read, mem_write : in std_logic;	--���ƶ���дDM���źţ�'1'������Ҫ����д
		
		write_data : in std_logic_vector(15 downto 0);	--д�ڴ�ʱ��Ҫд��DM��IM������		
		address : in std_logic_vector(15 downto 0);		--��DM/дDM/дIMʱ����ַ����
		pc_out : in std_logic_vector(15 downto 0);		--��IMʱ����ַ����
		pc_mux_out : in std_logic_vector(15 downto 0);	
		pc_Keep : in std_logic;
		
		read_data : out std_logic_vector(15 downto 0);	--��DMʱ��������������/�����Ĵ���״̬
		read_ins : out std_logic_vector(15 downto 0);	--��IMʱ��������ָ��
		
		ram1_addr, ram2_addr : out std_logic_vector(17 downto 0); --RAM1 RAM2��ַ����
		ram1_data, ram2_data : inout std_logic_vector(15 downto 0);	--RAM1 RAM2��������
		
		ram2addr_output : out std_logic_vector(17 downto 0);
		
		ram1_en, ram1_oe, ram1_we : out std_logic;		--RAM1ʹ�� ��ʹ�� дʹ��  ='1'��ֹ����Զ����'1'
		
		ram2_en, ram2_oe, ram2_we : out std_logic;		--RAM2ʹ�� ��ʹ�� дʹ�ܣ�='1'��ֹ����Զ����'0'
		
		memory_state : out std_logic_vector(1 downto 0);
		falsh_stateout : out std_logic_vector(2 downto 0);
		
		flash_finished : out std_logic := '0';
		
		--Flash
		flash_addr : out std_logic_vector(22 downto 0);		--flash��ַ��
		flash_data : inout std_logic_vector(15 downto 0);	--flash������
		
		flash_byte : out std_logic := '1';	--flash����ģʽ������'1'
		flash_vpen : out std_logic := '1';	--flashд����������'1'
		flash_rp : out std_logic := '1';		--'1'��ʾflash����������'1'
		flash_ce : out std_logic := '0';		--flashʹ��
		flash_oe : out std_logic := '1';		--flash��ʹ�ܣ�'0'��Ч��ÿ�ζ���������'1'
		flash_we : out std_logic := '1'		--flashдʹ��
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
		ALUSrc : in std_logic;	-- choose imme / reg, from Controller
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

		BJsrc_out : out std_logic_vector(15 downto 0)	-- output
	);
	end component;


	component branch_judge
	port(
		Branch     :  in std_logic_vector(2 downto 0);
		Data       :  in std_logic_vector(15 downto 0);
		BranchJudge : out std_logic
	);
	end component;


	--�������п����źŵĿ�����
	component controller
	port(	
		command_in : in std_logic_vector(15 downto 0);
		rst : in std_logic;
		controller_out :  out std_logic_vector(23 downto 0)  --controller_out �����п����źż�����һ����ʵ��
		--extend(3) reg1_select(3) reg2_select(2) regwrite(1)  --9
		--jump(1) alusrc(1) aluop(4) regdst(3) memread(1)      --10
		--memwrite(1) branch(3) memtoreg(1)                    --5
	);
	end component;
	
	--ѡ����PC�ĵ�Ԫ
	component PC_MUX
	port(
		PC_addOne : in std_logic_vector(15 downto 0);	 --PC+1
		ID_EX_imme : in std_logic_vector(15 downto 0);  --���ڼ���Branch��ת��PCֵ=IdEXEimme+ID_EX_PC
		ID_EX_PC : in std_logic_vector(15 downto 0);	 --���ڼ���Branch��ת��PCֵ=IdEXEimme+ID_EX_PC
		AsrcOut : in std_logic_vector(15 downto 0);	 --����JRָ���ת��ַΪASrcOut
		
		jump : in std_logic;					--jump�����ܿ�����Controller�������ź�
		BranchJudge : in std_logic;		--����ALU�����Ŀ����źţ���ʾB����ת�ɹ�
		PC_Rollback : in std_logic;			--SW���ݳ�ͻʱ��PC��Ҫ���˵�SW��һ��ָ��ٵĵ�ַ��
													--����ǰ��PC+1�Ǣ۵ĵ�ַ�����Դ�ʱPC_out = PC_addOne - 2;
		
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
	
	
	--EX/MEM�׶μĴ���
	component reg_EX_MEM
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;
		--��������
		rdIn : in std_logic_vector(3 downto 0);
		MUX_MFPC_in : in std_logic_vector(15 downto 0);
		readData2In : in std_logic_vector(15 downto 0); --��SW���д�ڴ�
		--�ź�����
		regWriteIn : in std_logic;
		memReadIn : in std_logic;
		memWriteIn : in std_logic;
		memToRegIn : in std_logic;

		--�������
		Rd_out : out std_logic_vector(3 downto 0);
		ALUresultOut : out std_logic_vector(15 downto 0);
		readData2Out : out std_logic_vector(15 downto 0); --��SW���д�ڴ�
		--�ź����
		regWriteOut : out std_logic;
		memReadOut : out std_logic;
		memWriteOut : out std_logic;
		memToRegOut : out std_logic
	);
	end component;
	
	-- Forwarding unit
	-- 	IF - EX/MEM
	-- 	ID - EX/MEM
	component forwarding_unit
	port(
		IF_ID_Rs: in std_logic_vector(3 downto 0);

		ID_EX_Rs : in std_logic_vector(3 downto 0);
		ID_EX_Rt : in std_logic_vector(3 downto 0);

		EX_MEM_Rd : in std_logic_vector(3 downto 0);
		MEM_WB_Rd : in std_logic_vector(3 downto 0);
		
		ID_EX_MemWrite : in std_logic;

		ForwardA : out std_logic_vector(1 downto 0);
		ForwardB : out std_logic_vector(1 downto 0);
		ForwardSW : out std_logic_vector(1 downto 0);
		ForwardEq : out std_logic_vector(1 downto 0)
	);
	end component;
	
	-- Hazard detection unit
	-- 	ID/MEM hazard
	-- 	branch related hazard
	component hazard_detection
	port(
		ID_EX_Rd : in std_logic_vector(3 downto 0);
		ID_EX_MemRead : in std_logic;
		ID_EX_ALUop: in std_logic_vector(3 downto 0);
		EX_MEM_Rd: in std_logic_vector(3 downto 0);
		EX_MEM_MemRead: in std_logic;
		
		ReadReg1 : in std_logic_vector(3 downto 0);
		ReadReg2 : in std_logic_vector(3 downto 0);

		Branch : in std_logic_vector(2 downto 0);
		
		PC_Keep : out std_logic;
		IF_ID_Keep : out std_logic;
		ID_EX_Flush : out std_logic
	);
	end component;
	
	--ID/EX�׶μĴ���
	component reg_ID_EX
	port(
		clk : in std_logic;
		rst : in std_logic;
		flash_finished : in std_logic;
		LW_ID_EX_Flush : in std_logic;		--LW���ݳ�ͻ��
		Branch_IdExFlush : in std_logic;	--��תʱ��
		Jump_IdExFlush : in std_logic;	--JR��תʱ��
		SW_ID_EX_Flush : in std_logic;		--SW�ṹ��ͻ��
		
		PC_in : in std_logic_vector(15 downto 0);
		rdIn : in std_logic_vector(3 downto 0);		--Ŀ�ļĴ�����"0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1110"-û��Ŀ�ļĴ���
		Reg1In : in std_logic_vector(3 downto 0);		--Դ�Ĵ���1��"0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1111"-û��Դ�Ĵ���1
		Reg2In : in std_logic_vector(3 downto 0);		--Դ�Ĵ���2��"0xxx"-R0~R7,"1111"-û��Դ�Ĵ���2
		ALUSrcBIn : in std_logic;							--�����ź�ALUSrcB��'0'-Reg2,'1'-imme
		ReadData1In : in std_logic_vector(15 downto 0);	--Դ�Ĵ���1��ֵ
		ReadData2In : in std_logic_vector(15 downto 0);	--Դ�Ĵ���2��ֵ
		imme_in : in std_logic_vector(15 downto 0);		--��չ���������
		
		MFPC_in : in std_logic;
		regWriteIn : in std_logic;
		memWriteIn : in std_logic;
		memReadIn : in std_logic;
		memToRegIn : in std_logic;
		jumpIn : in std_logic;
		ALUOpIn : in std_logic_vector(3 downto 0);		--Controller���ɵĿ����ź�
		
	
		PC_out : out std_logic_vector(15 downto 0);
		Rd_out : out std_logic_vector(3 downto 0);
		Reg1Out : out std_logic_vector(3 downto 0);
		Reg2Out : out std_logic_vector(3 downto 0);
		ALUSrcBOut : out std_logic;
		ReadData1Out : out std_logic_vector(15 downto 0);
		ReadData2Out : out std_logic_vector(15 downto 0);			
		imme_out : out std_logic_vector(15 downto 0);
		
		MFPC_out : out std_logic;
		regWriteOut : out std_logic;
		memWriteOut : out std_logic;
		memReadOut : out std_logic;
		memToRegOut : out std_logic;
		jumpOut : out std_logic;
		ALUOpOut : out std_logic_vector(3 downto 0)
	);
	end component;
	
	--IF/ID�׶μĴ���
	component reg_IF_ID
	port(
		rst : in std_logic;
		clk : in std_logic;
		flash_finished : in std_logic;
		command_in : in std_logic_vector(15 downto 0);
		PC_in : in std_logic_vector(15 downto 0); 
		IF_ID_Keep : in std_logic;		--LW���ݳ�ͻ��
		BJ_IF_ID_Flush : in std_logic;	-- branch_judge �ṹ��ͻ
		Branch_IF_ID_Flush : in std_logic;		--��תʱ��
		Jump_IF_ID_Flush : in std_logic;		--JR��תʱ��
		SW_IF_ID_Flush : in std_logic;			--SW�ṹ��ͻ��
		
		Rs : out std_logic_vector(2 downto 0);		--Command[10:8]
		Rt : out std_logic_vector(2 downto 0);		--Command[7:5]
		Rd : out std_logic_vector(2 downto 0);		--Command[4:2]
		imme_10_0 : out std_logic_vector(10 downto 0);	--Command[10:0]
		command_out : out std_logic_vector(15 downto 0);
		PC_out : out std_logic_vector(15 downto 0)  --PC+1����MFPCָ���EXE��
	);
	end component;
	
	--��������չ��Ԫ
	component imme_extension
	port(
		 imme_in : in std_logic_vector(10 downto 0);
		 imme_select : in std_logic_vector(2 downto 0); -- expansion type, from controller
		 imme_out : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--MEM/WB�׶μĴ���
	component reg_MEM_WB
		port(
			clk : in std_logic;
			rst : in std_logic;
			flash_finished : in std_logic;
			--����
			readMemDataIn : in std_logic_vector(15 downto 0);	--DataMemoRt����������
			ALUresultIn : in std_logic_vector(15 downto 0);		--ALU�ļ�����
			rdIn : in std_logic_vector(3 downto 0);				--Ŀ�ļĴ���
			--�����ź�
			regWriteIn : in std_logic;		--�Ƿ�Ҫд��
			memToRegIn : in std_logic;		--д��ʱѡ��readMemDataIn��'1'������ALUresultIn��'0'��
			
			data_to_write : out std_logic_vector(15 downto 0);		--д�ص�����
			Rd_out : out std_logic_vector(3 downto 0);				--Ŀ�ļĴ�����"0xxx"-R0~R7,"1000"-SP,"1001"-IH,"1010"-T,"1110"-û��Ŀ�ļĴ���
			regWriteOut : out std_logic								--�Ƿ�Ҫд��
		);
	end component;
	
	-- PC++
	component PC_adder
	port(
		adder_in : in std_logic_vector(15 downto 0);
		adder_out : out std_logic_vector(15 downto 0)
	);
	end component;
	
	--PC�Ĵ���
	component PC_reg
	port(
		rst,clk : in std_logic;
		flash_finished : in std_logic;
		PC_Keep : in std_logic;		--��hazard_detection�����Ŀ����ź�
		PC_in : in std_logic_vector(15 downto 0);		--ȡPC_MUX�����ֵ��ѡ������PCֵ��
		PC_out : out std_logic_vector(15 downto 0)		--�͸�IMȥȡָ��PC
	);
	end component;
	
	--Դ�Ĵ���1ѡ����
	component MUX_Reg1
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);	--R0~R7�е�һ��
		
		reg1_select : in std_logic_vector(2 downto 0);	-- control signal
		
		reg1_out : out std_logic_vector(3 downto 0)	--"0XXX"����R0~R7��"1000"=SP,"1001"=IH, "1010"=T, "1111"=û��
	);
	end component;
	
	--Դ�Ĵ���2ѡ����
	component MUX_Reg2
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);	--R0~R7�е�һ��
		
		reg2_select : in std_logic;	-- contorl signal
		
		reg2_out : out std_logic_vector(3 downto 0)	--"0XXX"����R0~R7, "1111"=û��
	);
	end component;
	
	--Ŀ�ļĴ���ѡ����
	component MUX_Rd
	port(
		Rs : in std_logic_vector(2 downto 0);
		Rt : in std_logic_vector(2 downto 0);
		Rd : in std_logic_vector(2 downto 0);		-- one of R0 .. R7
			
		RegDst : in std_logic_vector(2 downto 0);	-- from controller
			
		Rd_out : out std_logic_vector(3 downto 0)	--"0XXX": R0~R7; "1000"=SP,"1001"=IH, "1010"=T, "1110"=n/a
	);
	end component;


	component Registers
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		read_reg1 : in std_logic_vector(3 downto 0);  --"0XXX"����R0~R7 "1000"=SP,"1001"=IH, "1010"=T "1011"=RA "1100"=PC
		read_reg2 : in std_logic_vector(3 downto 0);  --"0XXX"����R0~R7  "1000"=RA
		
		dst_reg : in std_logic_vector(3 downto 0);	  --��WB�׶δ��أ�Ŀ�ļĴ���
		WriteData : in std_logic_vector(15 downto 0);  --��WB�׶δ��أ�дĿ�ļĴ���������
		RegWrite : in std_logic;					--��WB�׶δ��أ�RegWrite��дĿ�ļĴ����������ź�
		
		flash_finished : in std_logic;
		
		r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out : out std_logic_vector(15 downto 0);
		
		ReadData1 : out std_logic_vector(15 downto 0); --�����ļĴ���1������
		ReadData2 : out std_logic_vector(15 downto 0); --�����ļĴ���2������
		data_T, data_SP, data_IH, data_RA : out std_logic_vector(15 downto 0);
		reg_state : out std_logic_Vector(1 downto 0)
	);
	end component;
	
	--SWдָ���ڴ� �ṹ��ͻ
	component structural_conflict
	port(
		ID_EX_MemWrite : in std_logic;
		ALU_rst_addr : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		
		IF_ID_Flush : out std_logic;
		ID_EX_Flush : out std_logic;
		PC_Rollback : out std_logic
	);
	end component;
	
	component MUX_WriteData
	port(
		ForwardSW : in std_logic_vector(1 downto 0);
		ReadData2 : in std_logic_vector(15 downto 0);
		EX_MEM_ALUresult : in std_logic_vector(15 downto 0);	
		MEM_WB_result : in std_logic_vector(15 downto 0);	
		WriteData_out : out std_logic_vector(15 downto 0)
	);
	end component;

	component dcm 
		port ( CLKIN_IN   : in    std_logic; 
				 RST_IN     : in    std_logic; 
				 CLKFX_OUT  : out   std_logic; 
				 CLK0_OUT   : out   std_logic; 
				 CLK2X_OUT  : out   std_logic; 
				 LOCKED_OUT : out   std_logic
		);
	end component; 
	
	
	--���µ�signal���ǡ�ȫ�ֱ���������������component��out
	
	--dcm
	signal CLKFX_OUT : std_logic;
	signal CLK0_OUT : std_logic;
	signal CLK2X_OUT : std_logic;
	signal LOCKED_OUT : std_logic;
	
	--clock
	signal clk : std_logic;
	signal clk_3 : std_logic;
	signal clk_registers : std_logic;
	
	--PC_reg
	signal PC_out : std_logic_vector(15 downto 0); 
	
	--PC_adder
	signal PC_addOne : std_logic_vector(15 downto 0);
	
	--reg_IF_ID
	signal Rs, Rt, Rd :std_logic_vector(2 downto 0);
	signal imme_10_0 : std_logic_vector(10 downto 0);
	signal IF_ID_cmd, IF_ID_PC : std_logic_vector(15 downto 0);
	
	--MUX_Rd
	signal Rd_choice : std_logic_vector(3 downto 0);
	
	--controller
	signal controller_out : std_logic_vector(20 downto 0);
	
	--Registers
	signal ReadData1, ReadData2 : std_logic_vector(15 downto 0);
	signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0);
	signal data_T, data_SP, data_IH, dataRA : std_logic_vector(15 downto 0);
	signal reg_state : std_logic_vector(1 downto 0);
	
	--ImmExtend
	signal extended_imme : std_logic_vector(15 downto 0);
	
	--reg_ID_EX
	signal ID_EX_PC : std_logic_vector(15 downto 0);
	signal ID_EX_Rd : std_logic_vector(3 downto 0);
	signal ID_EX_Reg1, ID_EX_Reg2 : std_logic_vector(3 downto 0);
	signal ID_EX_ALUsrc : std_logic;
	signal ID_EX_ReadData1, ID_EX_ReadData2 : std_logic_vector(15 downto 0);
	signal ID_EX_imme : std_logic_vector(15 downto 0);
	signal ID_EX_RegWrite, ID_EX_MemWrite, ID_EX_MemRead, ID_EX_MemToReg : std_logic;
	signal ID_EX_MFPC, ID_EX_JR : std_logic;
	signal ID_EX_ALUop : std_logic_vector(3 downto 0);
	
	--reg_EX_MEM
	signal EX_MEM_Rd : std_logic_vector(3 downto 0);
	signal EX_MEM_ReadData2 : std_logic_vector(15 downto 0);
	signal EX_MEM_ALUresult : std_logic_vector(15 downto 0);	--����MUX_MFPCѡ���Ľ��
	
	signal EX_MEM_RegWrite : std_logic;
	signal EX_MEM_Read, EX_MEM_Write, EX_MEM_MemToReg: std_logic;
	
	--forwarding_unit
	signal ForwardA, ForwardB, ForwardSW, ForwardBJ : std_logic_vector(1 downto 0);
	
	--reg_MEM_WB
	signal Rd_to_write : std_logic_vector(3 downto 0);
	signal data_to_write : std_logic_vector(15 downto 0);
	signal MEM_WB_RegWrite : std_logic;
	
	--MUX_A
	signal MUX_A_out : std_logic_vector(15 downto 0);
	
	--MUX_B
	signal MUX_B_out : std_logic_vector(15 downto 0);
	
	--MUX_BJ
	signal BJsrc_out : std_logic_vector(15 downto 0);

	--branch_judge
	signal BranchJudge : std_logic;

	--ALU
	signal ALUresult : std_logic_vector(15 downto 0);
	
	--PC_MUX
	signal PC_MUX_out : std_logic_vector(15 downto 0);
	
	
	--hazard_detection
	signal PC_Keep : std_logic;
	signal IF_ID_Keep : std_logic;
	signal BJ_IF_ID_Flush : std_logic;
	signal LW_ID_EX_Flush : std_logic;
	
	
	--memory ����һ�󲿷ֶ�����cpu��port�����֣�
	signal DM_data_out : std_logic_vector(15 downto 0);
	signal IM_instruction_out : std_logic_vector(15 downto 0);
	signal MemoryState : std_logic_vector(1 downto 0);
	signal FlashState_out : std_logic_vector(2 downto 0);
		
	--SWдָ���ڴ棨�ṹ��ͻ��
	signal SW_IF_ID_Flush : std_logic;
	signal SW_ID_EX_Flush : std_logic;
	signal PC_Rollback : std_logic;
	
	--MUX_Reg1��2Mux��signal��
	signal MUX_Reg1_out : std_logic_vector(3 downto 0);
	signal MUX_Reg2_out : std_logic_vector(3 downto 0);
	
	--MUX_MFPC 
	signal MUX_MFPC_out : std_logic_vector(15 downto 0);
	
	--digit rom
--	signal digitRomAddr : std_logic_vector(14 downto 0);
--	signal digitRomData : std_logic_vector(23 downto 0);
	
	--font rom
	-- signal fontRomAddr : std_logic_vector(10 downto 0);
	-- signal fontRomData : std_logic_vector(7 downto 0);
	
	--MUX_WriteData
	signal WriteData_out : std_logic_vector(15 downto 0);
	
	signal ram2addr_output : std_logic_vector(17 downto 0);
	signal flash_finished : std_logic;
	
	
	signal clkIn_clock : std_logic;	--����clock.vhd������ʱ��
	signal always_zero : std_logic := '0';	--��Ϊ����ź�
	
begin
	u1 : PC_reg
	port map(
		rst => rst,
		clk => clk_3,
		flash_finished => flash_finished,
		PC_Keep => PC_Keep,
		PC_in => PC_MUX_out,
		PC_out => PC_out
	);
		
	u2 : PC_adder
	port map( 
		adder_in => PC_out,
		adder_out => PC_addOne
	);
		
	u3 : reg_IF_ID
	port map(
		rst => rst,
		clk => clk_3,
		flash_finished => flash_finished,
		command_in => IM_instruction_out,
		PC_in => PC_addOne,
		IF_ID_Keep => IF_ID_Keep,
		BJ_IF_ID_Flush => BJ_IF_ID_Flush,
		Branch_IF_ID_Flush => BranchJudge, 
		Jump_IF_ID_Flush => ID_EX_JR,
		SW_IF_ID_Flush => SW_IF_ID_Flush,
		
		Rs => Rs,
		Rt => Rt,
		Rd => Rd,
		imme_10_0 => imme_10_0,
		command_out => IF_ID_cmd,
		PC_out => IF_ID_PC
	);
		
	u4 : MUX_Rd
	port map(
		Rs => Rs,
		Rt => Rt,
		Rd => Rd,
		
		RegDst => controller_out(8 downto 6),
		Rd_out => Rd_choice
	);
		
	u5 : controller
	port map(	
		command_in => IF_ID_cmd,
		rst => rst,
		controller_out => controller_out
		--im_sel(23-21) reg1_sel(20-18) reg2_sel(17-16) regwrite(15)	--9
		--jump(14) alusrc(13) aluop(12-9) regdst(8-6) memread(5)	--10
		--memwrite(4) branch(3-1) memtoreg(0)						--5
		);
		
	u6 : Registers
	port map(
		clk => clk,
		rst => rst,
		read_reg1 => MUX_Reg1_out,
		read_reg2 => MUX_Reg2_out,
		--����������MEM/WB�μĴ�������Ϊ������д�ضΣ�
		dst_reg => Rd_to_write,
		WriteData => data_to_write,
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
		
	u7 : imme_extension
	port map(
		imme_in => imme_10_0,
		imme_select => controller_out(23 downto 21),
		imme_out => extended_imme
	);
		
	u8 : reg_ID_EX
	port map(
		clk => clk_3,
		rst => rst,
		flash_finished => flash_finished,
		
		LW_ID_EX_Flush => LW_ID_EX_Flush,
		Branch_IdExFlush => BranchJudge,
		Jump_IdExFlush => ID_EX_JR,
		SW_ID_EX_Flush => SW_ID_EX_Flush,
		
		PC_in => IF_ID_PC,
		rdIn => Rd_choice,
		Reg1In => MUX_Reg1_out,
		Reg2In => MUX_Reg2_out,
		ALUSrcBIn => controller_out(9),
		ReadData1In => ReadData1,
		ReadData2In => ReadData2,
		imme_in => extended_imme,
		
		MFPC_in => controller_out(0),
		regWriteIn => controller_out(20),
		memWriteIn => controller_out(3),
		memReadIn => controller_out(4),
		memToRegIn => controller_out(2),
		jumpIn => controller_out(1),
		ALUOpIn => controller_out(8 downto 5),
	
		PC_out => ID_EX_PC,
		Rd_out => ID_EX_Rd,
		Reg1Out => ID_EX_Reg1,
		Reg2Out => ID_EX_Reg2,
		ALUSrcBOut => ID_EX_ALUsrc,
		ReadData1Out => ID_EX_ReadData1,
		ReadData2Out => ID_EX_ReadData2,
		imme_out => ID_EX_imme,
		
		MFPC_out => ID_EX_MFPC,
		regWriteOut => ID_EX_RegWrite,
		memWriteOut => ID_EX_MemWrite,
		memReadOut => ID_EX_MemRead,
		memToRegOut => ID_EX_MemToReg,
		jumpOut => ID_EX_JR,
		ALUOpOut => ID_EX_ALUop
		);
		
	u9 : MUX_A
		port map(
		ForwardA => ForwardA,
		
		ReadData1 => ID_EX_ReadData1,
		EX_MEM_ALUresult => EX_MEM_ALUresult,
		MemWbResult => data_to_write,
		
		AsrcOut => MUX_A_out
		);
		
	u10 : MUX_B
	port map(
		ForwardB => ForwardB,
		ALUSrcB => ID_EX_ALUsrc,
		
		ReadData2 => ID_EX_ReadData2,
		imme => ID_EX_imme,
		EX_MEM_ALUresult => EX_MEM_ALUresult,
		MemWbResult => data_to_write,
		
		BsrcOut => MUX_B_out
		);	
		
	u11 : forwarding_unit
	port map(
		EX_MEM_Rd => EX_MEM_Rd,
		MemWbRd => Rd_to_write,
		
		ID_EX_ALUsrc => ID_EX_ALUsrc,
		ID_EX_MemWrite => ID_EX_MemWrite,
		
		ID_EX_Reg1 => ID_EX_Reg1,
		ID_EX_Reg2 => ID_EX_Reg2,
		
		ForwardA => ForwardA,
		ForwardB => ForWardB,
		ForwardSW => ForWardSW
			
		);
	
	u12 : ALU
	port map(
		Asrc      	=> MUX_A_out,
		Bsrc        => MUX_B_out,
		ALUop		  	=> ID_EX_ALUop,
		
		ALUresult  	=> ALUresult,
		branchJudge => BranchJudge
	);
	
	u13 : reg_EX_MEM
	port map(
		clk => clk_3,
		rst => rst,
		flash_finished => flash_finished,
		
		rdIn => ID_EX_Rd,
		MUX_MFPC_in => MUX_MFPC_out,
		readData2In => WriteData_out,
		
		regWriteIn => ID_EX_RegWrite,
		memReadIn => ID_EX_MemRead,
		memWriteIn => ID_EX_MemWrite,
		memToRegIn => ID_EX_MemToReg,
					
		Rd_out => EX_MEM_Rd,
		ALUresultOut => EX_MEM_ALUresult,
		readData2Out => EX_MEM_ReadData2,
		
		regWriteOut => EX_MEM_RegWrite,
		memReadOut => EX_MEM_Read,
		memWriteOut => EX_MEM_Write,
		memToRegOut => EX_MEM_MemToReg
		);
	
	u14 : reg_MEM_WB
	port map(
		clk => clk_3,
		rst => rst,
		flash_finished => flash_finished,
		
		readMemDataIn => DM_data_out,
		ALUresultIn => EX_MEM_ALUresult,
		rdIn => EX_MEM_Rd,
		
		regWriteIn => EX_MEM_RegWrite,
		memToRegIn => EX_MEM_MemToReg,
		
		data_to_write => data_to_write,
		Rd_out => Rd_to_write,
		regWriteOut => MEM_WB_RegWrite
	);
	
	u15 : hazard_detection
	port map(
		ID_EX_Rd => ID_EX_Rd,
		ID_EX_MemRead => ID_EX_MemRead,
		
		ReadReg1 => MUX_Reg1_out,
		ReadReg2 => MUX_Reg2_out,
		
		PC_Keep => PC_Keep,
		IF_ID_Keep => IF_ID_Keep,
		IdExFlush => LW_ID_EX_Flush
	);
		
	u16 : PC_MUX
	port map( 
		PC_addOne => PC_addOne,
		ID_EX_PC => ID_EX_PC,
		ID_EX_imme => ID_EX_imme,
		AsrcOut => MUX_A_out,
		
		jump => ID_EX_JR,
		BranchJudge => BranchJudge,
		PC_Rollback => PC_Rollback,
		
		PC_out => PC_MUX_out
	);
	
	u17 : memory
		port map( 
		clk => clk,
		rst => rst,
		
		data_ready => dataReady,
		tbre => tbre,
		tsre => tsre,
		wrn => wrn,
		rdn => rdn,
			
		MemRead => EX_MEM_Read,
		MemWrite => EX_MEM_Write,
		
		dataIn => EX_MEM_ReadData2,
		
		ramAddr => EX_MEM_ALUresult,
		PC_out => PC_out,
		PC_MUX_out => PC_MUX_out,
		PC_Keep => PC_Keep,
		dataOut => DM_data_out,
		insOut => IM_instruction_out,
		
		MemoryState => MemoryState,
		FlashState_out => FlashState_out,
		flash_finished => flash_finished,
		
		ram1_addr => ram1Addr,
		ram2_addr => ram2Addr,
		ram1_data => ram1Data,
		ram2_data => ram2Data,
		
		ram2addr_output => ram2addr_output,
		
		ram1_en => ram1En,
		ram1_oe => ram1Oe,
		ram1_we => ram1We,
		ram2_en => ram2En,
		ram2_oe => ram2Oe,
		ram2_we => ram2We,
		
		
		flash_addr => flashAddr,
		flash_data => flashData,
		
		flash_byte => flashByte,
		flash_vpen => flashVpen,
		flash_rp => flashRp,
		flash_ce => flashCe,
		flash_oe => flashOe,
		flash_we => flashWe
	);

	u18 : clock
	port map(
		rst => rst,
		clk => clkIn_clock,
		
		clk_out => clk,
		clk1 => clk_3,
		clk2 => clk_registers
	);
	
	
	u19 : structural_conflict
	port map(
		ID_EX_MemWrite => ID_EX_MemWrite,
		ALUresultAsAddr => ALUresult,
		PC => PC_out,
		
		IfIdFlush => SW_IF_ID_Flush,
		IdExFlush => SW_ID_EX_Flush,
		PC_Rollback => PC_Rollback
	);

	
	
	u20 : MUX_MFPC
	port map(
		PC_addOne => ID_EX_PC,
		ALUresult => ALUresult,
		MFPC => ID_EX_MFPC,
	
		MUX_MFPC_out => MUX_MFPC_out
	);
	
	u21 : MUX_Reg1
	port map(
		Rs => Rs,
		Rt => Rt,
		ReadReg1 => controller_out(16 downto 14),
		
		ReadReg1Out => MUX_Reg1_out
	);
	
	u22 : MUX_Reg2
	port map(
		Rs => Rs,
		Rt => Rt,
		ReadReg2 => controller_out(13),
		
		ReadReg2Out => MUX_Reg2_out

	);
	
-- 	u23 : VGA_Controller
-- 	port map(
-- 	--VGA Side
-- 		hs => hs,
-- 		vs => vs,
-- 		oRed => redOut,
-- 		oGreen => greenOut,
-- 		oBlue	=> blueOut,
-- 	--RAM side
-- --		R,G,B	: in  std_logic_vector (9 downto 0);
-- --		addr	: out std_logic_vector (18 downto 0);
-- 	-- data
-- 		r0 => r0,
-- 		r1 => r1,
-- 		r2 => r2,
-- 		r3 => r3,
-- 		r4 => r4,
-- 		r5 => r5,
-- 		r6 => r6,
-- 		r7 => r7,
-- 	--font rom
-- 		romAddr => fontRomAddr,
-- 		romData => fontRomdata,
-- 	--pc
-- 		PC => PC_out,
-- 		CM => IM_instruction_out,
-- 		Tdata => data_T,
-- 		IHdata => data_IH,
-- 		SPdata => data_SP,
-- 		RAdata => data_RA,
-- 	--Control Signals
-- 		reset	=> rst,
-- 		CLK_in => clk_50
-- 	);

-- originally commented ** start
	--r0 <= "0110101010010111";
	--r1 <= "1011100010100110";
--	u24 : digit
--	port map(
--			clkA => clk_50,
--			addra => digitRomAddr,
--			douta => digitRomData
--	);
-- end ** originally commented
	
	u25 : fontRom
	port map(
		clka => clk_50,
		addra => fontRomAddr,
		douta => fontRomData
	);
	
	u26 : MUX_WriteData 
	port map(
		ForwardSW => ForwardSW,
		
		ReadData2 => ID_EX_ReadData2,
		EX_MEM_ALUresult => EX_MEM_ALUresult,
		MemWbResult => data_to_write,
		
		WriteData_out => WriteData_out
		);
	
	u27 : dcm
	port map( 
		CLKIN_IN   => clk_50,
		RST_IN     => always_zero,
		CLKFX_OUT  => CLKFX_OUT,
		CLK0_OUT   => CLK0_OUT,
		CLK2X_OUT  => CLK2X_OUT,
		LOCKED_OUT => LOCKED_OUT
	);
	
	
	
	process(flashData, MemoryState, FlashState_out, reg_state)
	--process(data_to_write, ForwardA, ForwardSW, Rd_to_write)
	--process(data_to_write, Rd_to_write, MemoryState, reg_state)
	begin
		led(15 downto 14) <= reg_state;
		led(13 downto 12) <= MemoryState;
		led(11 downto 9) <= FlashState_out;
		--led(15 downto 14) <= ForwardA;
		--led(13 downto 12) <= ForwardSW;
		--led(11 downto 8) <= Rd_to_write;
		--led(7 downto 0) <= data_to_write(7 downto 0);
		
		led(8 downto 0) <= (others => '0');
		--led <= flashData;
	end process;
	
	--clk_chooser
	process(CLKFX_OUT, rst, clk_hand)
	begin
		if opt = '1' then
			if rst = '0' then
				clkIn_clock <= '0';
			else
				clkIn_clock <= clk_hand;
			end if;
		else
			if rst = '0' then
				clkIn_clock <= '0';
			else 
				clkIn_clock <= CLKFX_OUT;
			end if;
		end if;
	end process;
	
	
	--jing <= PC_out;
	process(ram2addr_output)
	begin
		case ram2addr_output(7 downto 4) is
			when "0000" => digit1 <= "0111111";--0
			when "0001" => digit1 <= "0000110";--1
			when "0010" => digit1 <= "1011011";--2
			when "0011" => digit1 <= "1001111";--3
			when "0100" => digit1 <= "1100110";--4
			when "0101" => digit1 <= "1101101";--5
			when "0110" => digit1 <= "1111101";--6
			when "0111" => digit1 <= "0000111";--7
			when "1000" => digit1 <= "1111111";--8
			when "1001" => digit1 <= "1101111";--9
			when "1010" => digit1 <= "1110111";--A
			when "1011" => digit1 <= "1111100";--B
			when "1100" => digit1 <= "0111001";--C
			when "1101" => digit1 <= "1011110";--D
			when "1110" => digit1 <= "1111001";--E
			when "1111" => digit1 <= "1110001";--F
			when others => digit1 <= "0000000";
		end case;
		
		case ram2addr_output(3 downto 0) is
			when "0000" => digit2 <= "0111111";--0
			when "0001" => digit2 <= "0000110";--1
			when "0010" => digit2 <= "1011011";--2
			when "0011" => digit2 <= "1001111";--3
			when "0100" => digit2 <= "1100110";--4
			when "0101" => digit2 <= "1101101";--5
			when "0110" => digit2 <= "1111101";--6
			when "0111" => digit2 <= "0000111";--7
			when "1000" => digit2 <= "1111111";--8
			when "1001" => digit2 <= "1101111";--9
			when "1010" => digit2 <= "1110111";--A
			when "1011" => digit2 <= "1111100";--B
			when "1100" => digit2 <= "0111001";--C
			when "1101" => digit2 <= "1011110";--D
			when "1110" => digit2 <= "1111001";--E
			when "1111" => digit2 <= "1110001";--F
			when others => digit2 <= "0000000";
		end case;
	end process;
	--ram1Addr <= (others => '0');
end Behavioral;

