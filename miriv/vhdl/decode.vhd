library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity decode is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from fetch
		pc_in      : in  pc_type;
		instr      : in  instr_type;

		-- from writeback
		reg_write  : in reg_write_type;

		-- towards next stages
		pc_out     : out pc_type;
		exec_op    : out exec_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;

		-- exceptions
		exc_dec    : out std_logic
	);
end entity;

architecture rtl of decode is

	component regfile is
		port (
			clk              : in  std_logic;
			res_n            : in  std_logic;
			stall            : in  std_logic;
			rdaddr1, rdaddr2 : in  reg_adr_type;
			rddata1, rddata2 : out data_type;
			wraddr           : in  reg_adr_type;
			wrdata           : in  data_type;
			regwrite         : in  std_logic
		);
	end component;
	--internal register for incoming signals
	signal instr_reg : instr_type;
	signal pc_in_reg : pc_type;

	--interface to regfile
	signal regfile_rdaddr1, regfile_rdaddr2 : reg_adr_type;
	signal regfile_rddata1, regfile_rddata2 : data_type;
	signal regfile_wraddr : reg_adr_type;
	signal regfile_wrdata : data_type;
	signal regfile_write : std_logic;

	--opcodes
	constant OPC_BITS : integer := 7;
	constant OPC_LUI : std_logic_vector(OPC_BITS - 1 downto 0) := "0110111";
	constant OPC_AUIPC : std_logic_vector(OPC_BITS - 1 downto 0) := "0010111";
	constant OPC_OP : std_logic_vector(OPC_BITS - 1 downto 0) := "0110011";
	constant OPC_OP_IMM : std_logic_vector(OPC_BITS - 1 downto 0) := "0010011";
	constant OPC_JAL : std_logic_vector(OPC_BITS - 1 downto 0) := "1101111";
	constant OPC_JALR : std_logic_vector(OPC_BITS - 1 downto 0) := "1100111";
	constant OPC_BRANCH : std_logic_vector(OPC_BITS - 1 downto 0) := "1100011";
	constant OPC_STORE : std_logic_vector(OPC_BITS - 1 downto 0) := "0100011";
	constant OPC_LOAD : std_logic_vector(OPC_BITS - 1 downto 0) := "0000011";

	procedure decode_imm_I_type (
	signal instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal imm : out std_logic_vector(DATA_WIDTH-1 downto 0)) is
	begin
		imm(31 downto 11) <= (others => instr(31));
		imm(10 downto 0) <= instr(30 downto 20);
	end procedure;

	procedure decode_imm_B_type (
	signal instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal imm : out std_logic_vector(DATA_WIDTH-1 downto 0)) is
	begin
		imm(31 downto 12) <= (others => instr(31));
		imm(11) <= instr(7);
		imm(10 downto 5) <= instr(30 downto 25);
		imm(4 downto 1) <= instr(11 downto 8);
		imm(0) <= '0';
	end procedure;

	procedure decode_imm_U_type (
	signal instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal imm : out std_logic_vector(DATA_WIDTH-1 downto 0)) is
	begin
		imm(31 downto 12) <= instr(31 downto 12);
		imm(11 downto 0) <= (others => '0');
	end procedure;

	procedure decode_imm_J_type (
	signal instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal imm : out std_logic_vector(DATA_WIDTH-1 downto 0)) is
	begin
		imm(31 downto 20) <= (others => instr(31));
		imm(19 downto 12) <= instr(19 downto 12);
		imm(11) <= instr(20);
		imm(10 downto 1) <= instr(30 downto 21);
		imm(0) <= '0';
	end procedure;

	procedure decode_imm_S_type (
	signal instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal imm : out std_logic_vector(DATA_WIDTH-1 downto 0)) is
	begin
		imm(31 downto 11) <= (others => instr(31));
		imm(10 downto 5) <= instr(30 downto 25);
		imm(4 downto 0) <= instr(11 downto 7);
	end procedure;


	-- ******* meaning of alusrc{1..3} +**************
	-- alusrc1 switches input A of ALU between rs1 (alusrc1 = 0) and PC (alusrc1 = 1)
	-- alusrc2 switchtes input B of ALU between rs2 (alusrc2 = 0) and immediate value (alusrc2 = 1)
	-- alusrc3 switches switches input B of PC-adder between PC (alusrc3 = 0) and rs1 (alusrc3 = 1)
	--					input A of PC-adder is always imm<<1

begin

	regfile_inst : regfile
	port map(
		clk => clk,
		res_n => res_n,
		stall => stall,
		rdaddr1 => regfile_rdaddr1,
		rdaddr2 => regfile_rdaddr2,
		rddata1 => regfile_rddata1,
		rddata2 => regfile_rddata2,
		wraddr => regfile_wraddr,
		wrdata => regfile_wrdata,
		regwrite => regfile_write
	);

	regfile_rdaddr1 <= instr(19 downto 15);
	regfile_rdaddr2 <= instr(24 downto 20);
	regfile_wraddr <= reg_write.reg;
	regfile_wrdata <= reg_write.data;
	regfile_write <= reg_write.write;

	pc_out <= pc_in_reg;


	decode_instr : process(all)
	begin

		--set default values
		exec_op <= EXEC_NOP;
		wb_op <= WB_NOP;
		mem_op <= MEM_NOP;

		exec_op.imm <= (others => '0');
		exec_op.rs1 <= instr_reg(19 downto 15);
		exec_op.rs2 <= instr_reg(24 downto 20);

		-- output of regfile is always forwarded to exec stage
		exec_op.readdata1 <= regfile_rddata1;
		exec_op.readdata2 <= regfile_rddata2;

		-- destination register is propagated to wb stage per default
		wb_op.rd <= instr_reg(11 downto 7);

		exc_dec <= '0';

		case(instr_reg(OPC_BITS-1 downto 0)) is


			when OPC_LUI =>
				--LUI
				exec_op.aluop <= ALU_NOP; -- NOP propagates input B to output
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '1'; -- take immediate value for B input of ALU
				exec_op.alusrc3 <= '0';
				decode_imm_U_type(instr_reg,exec_op.imm);

				mem_op <= MEM_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;


			when OPC_AUIPC =>
				--AUIPC
				exec_op.aluop <= ALU_ADD;
				exec_op.alusrc1 <= '1'; -- choose PC for input A
				exec_op.alusrc2 <= '1'; -- choose imm for input B
				exec_op.alusrc3 <= '0';
				decode_imm_U_type(instr_reg, exec_op.imm);

				mem_op <= MEM_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;

			when OPC_JAL =>
				--JAL
				exec_op.aluop <= ALU_NOP;
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '0'; -- set PC adder to add imm and pc
				decode_imm_J_type(instr_reg, exec_op.imm);

				mem_op.branch <= BR_BR;
				mem_op.mem <= MEMU_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_OPC;

			when OPC_JALR =>
				--JALR
				exec_op.aluop <= ALU_NOP;
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '1'; -- set PC adder to add imm and rs1
				decode_imm_I_type(instr_reg,exec_op.imm);

				mem_op.branch <= BR_BR;
				mem_op.mem <= MEMU_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_OPC;

				if instr_reg(14 downto 12) /= "000" then
					exc_dec <= '1';
				end if;

			when OPC_BRANCH =>
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '0';-- set PC adder to add imm and old pc
				decode_imm_B_type(instr_reg, exec_op.imm);

				mem_op.mem <= MEMU_NOP;

				wb_op <= WB_NOP;

				case instr_reg(14 downto 12) is
					when "000" =>
						--BEQ
						exec_op.aluop <= ALU_SUB;
						-- TODO: ask tutor
						mem_op.branch <= BR_CNDI;

					when "001" =>
						--BNE
						exec_op.aluop <= ALU_SUB;
						mem_op.branch <= BR_CND;

					when "100" =>
						--BLT
						exec_op.aluop <= ALU_SLT;
						mem_op.branch <= BR_CND;

					when "101" =>
						--BGE
						exec_op.aluop <= ALU_SLT;
						mem_op.branch <= BR_CNDI;

					when "110" =>
						--BLTU
						exec_op.aluop <= ALU_SLTU;
						mem_op.branch <= BR_CND;

					when "111" =>
						--BGEU
						exec_op.aluop <= ALU_SLTU;
						mem_op.branch <= BR_CNDI;

					when others =>
						exc_dec <= '1';

				end case;

			when OPC_LOAD =>
				--set alu to use rs1 with imm
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '1';
				exec_op.alusrc3 <= '0'; -- don't care
				exec_op.aluop <= ALU_ADD;
				decode_imm_I_type(instr_reg, exec_op.imm);

				wb_op.write <= '1';
				wb_op.src <= WBS_MEM;

				mem_op.mem.memread <= '1';
				mem_op.mem.memwrite <= '0';
				mem_op.branch <= BR_NOP;

				case instr_reg(14 downto 12) is
					when "000" =>
						--LB
						mem_op.mem.memtype <= MEM_B;
					when "001" =>
					 --LH
						mem_op.mem.memtype <= MEM_H;
					when "010" =>
						--LW
						mem_op.mem.memtype <= MEM_W;
					when "100" =>
						--LBU
						mem_op.mem.memtype <= MEM_BU;
					when "101" =>
						--LHU
						mem_op.mem.memtype <= MEM_HU;
					when others  =>
						exc_dec <= '1';
				end case;

			when OPC_STORE =>
				-- set alu to use rs1 and imm
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '1';
				exec_op.alusrc3 <= '0'; -- don't care
				exec_op.aluop <= ALU_ADD;
				decode_imm_S_type(instr_reg, exec_op.imm);

				wb_op <= WB_NOP;

				mem_op.mem.memwrite <= '1';
				mem_op.mem.memread <= '0';
				mem_op.branch <= BR_NOP;

				case instr_reg(14 downto 12) is
					when "000" =>
						--SB
						mem_op.mem.memtype <= MEM_B;
					when "001" =>
						--SH
						mem_op.mem.memtype <= MEM_H;
					when "010" =>
						--SW
						mem_op.mem.memtype <= MEM_W;
					when others =>
						exc_dec <= '1';
				end case;

			when OPC_OP_IMM =>
				-- set alu to use rs1 and imm
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '1';
				exec_op.alusrc3 <= '0'; -- don't care
				decode_imm_I_type(instr_reg, exec_op.imm);

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;

				mem_op <= MEM_NOP;

				case instr_reg(14 downto 12) is
					when "000" =>
						--ADDI
						exec_op.aluop <= ALU_ADD;
					when "010" =>
						--SLTI
						exec_op.aluop <= ALU_SLT;
					when "011" =>
						--SLTIU
						exec_op.aluop <= ALU_SLTU;
					when "100" =>
						--XORI
						exec_op.aluop <= ALU_XOR;
					when "110" =>
						--ORI
						exec_op.aluop <= ALU_OR;
					when "111" =>
						--ANDI
						exec_op.aluop <= ALU_AND;
					when "001" =>
						--SLLI
						exec_op.aluop <= ALU_SLL;
					when "101" =>
						-- imm[10] corresponds to instr[30]
						-- this bit decides whether the shift is logical or artithmetic
						if instr_reg(30) = '0' then
							--SRLI
							exec_op.aluop <= ALU_SRL;
						else
							--SRAI
							exec_op.aluop <= ALU_SRA;
						end if;

					when others =>
						exc_dec <= '1';

				end case;

			when OPC_OP =>
				-- set alu to use rs1 and rs2
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '0'; -- don't care

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;

				mem_op <= MEM_NOP;

				case instr_reg(14 downto 12) is

					when "000" =>
						if instr_reg(31 downto 25) = "0000000" then
							--ADD
							exec_op.aluop <= ALU_ADD;
						elsif instr_reg(31 downto 25) = "0100000" then
							--SUB
							exec_op.aluop <= ALU_SUB;
						else
							exc_dec <= '1';
						end if;

					when "001" =>
						if instr_reg(31 downto 25) = "0000000" then
							--SLL
							exec_op.aluop <= ALU_SLL;
						else
							exc_dec <= '1';
						end if;

					when "010" =>
						if instr_reg(31 downto 25) = "0000000" then
							--SLT
							exec_op.aluop <= ALU_SLT;
						else
							exc_dec <= '1';
						end if;

					when "011" =>
						if instr_reg(31 downto 25) = "0000000" then
							--SLTU
							exec_op.aluop <= ALU_SLTU;
						else
							exc_dec <= '1';
						end if;

					when "100" =>
						if instr_reg(31 downto 25) = "0000000" then
							--XOR
							exec_op.aluop <= ALU_XOR;
						else
							exc_dec <= '1';
						end if;

					when "101" =>
						if instr_reg(31 downto 25) = "0000000" then
							--SRL
							exec_op.aluop <= ALU_SRL;
						elsif instr_reg(31 downto 25) = "0100000" then
							--SRA
							exec_op.aluop <= ALU_SRA;
						else
							exc_dec <= '1';
						end if;

					when "110" =>
						if instr_reg(31 downto 25) = "0000000" then
							--OR
							exec_op.aluop <= ALU_OR;
						else
							exc_dec <= '1';
						end if;

					when "111" =>
						if instr_reg(31 downto 25) = "0000000" then
							--AND
							exec_op.aluop <= ALU_AND;
						else
							exc_dec <= '1';
						end if;

					when others =>
						exc_dec <= '1';

				end case;

			when "0001111" =>
				-- FENCE
				exec_op <= EXEC_NOP;
				mem_op <= MEM_NOP;
				wb_OP <= WB_NOP;

				if instr_reg(14 downto 12) /= "000" then
					exc_dec <= '1';
				end if;

			when others =>
				exc_dec <= '1';

		end case;

	end process;

	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			instr_reg <= NOP_INST;
			pc_in_reg <= ZERO_PC;
		elsif rising_edge(clk) then
			if stall = '0' then
				instr_reg <= instr;
				pc_in_reg <= pc_in;
			end if;
			if flush = '1' then
				instr_reg <= NOP_INST;
			end if;
		end if;
	end process;


end architecture;
