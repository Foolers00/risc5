library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

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
	--internal register for incoming signals
	signal instr_reg : instr_type;
	signal pc_in_reg : pc_type;
	signal reg_write_reg : reg_write_tpye;

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

	regfile_rdaddr1 <= instr_reg(19 downto 15);
	regfile_rdaddr2 <= instr_reg(24 downto 20);
	regfile_wraddr <= reg_write.reg;
	regfile_wrdata <= reg_write.data;
	regfile_write <= reg_write.write;


	decode_instr : process(all)
	begin

		case(instr_reg(OPC_BITS-1 downto 0)) is
			-- output of regfile is always propageted to exec stage
			exec_op.readdata1 <= regfile_rddata1;
			exec_op.readdata2 <= regfile_rddata2;

			-- destination register is always propagated to wb stage
			wb_op.rd <= instr_reg(11 downto 7);

			--set default values
			exec_op.imm <= (others => '0');
			exec_op.rs1 <= instr_reg(19 downto 15);
			exec_op.rs2 <= instr_reg(24 downto 20);


			when OPC_LUI =>
				exec_op.aluop <= ALU_NOP; -- NOP propagates input B to output
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '1'; -- take immediate value for B input of ALU
				exec_op.alusrc3 <= '0';
				exec_op.rs1 <= ZERO_REG;
				exec_op.rs2 <= ZERO_REG;
				exec_op.imm(31 downto 12) <= instr_reg(31 downto 12);

				mem_op <= MEM_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;


			when OPC_AUIPC =>
				exec_op.aluop <= ALU_ADD;
				exec_op.alusrc1 <= '1'; -- choose PC for input A
				exec_op.alusrc2 <= '1'; -- choose imm for input B
				exec_op.alusrc3 <= '0';
				exec_op.rs1 <= ZERO_REG;
				exec_op.rs2 <= ZERO_REG;
				exec_op.imm(31 downto 12) <= instr_reg(31 downto 12);

				mem_op <= MEM_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;

			when OPC_JAL =>
				exec_op.aluop <= ALU_NOP;
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '0'; -- set PC adder to add imm and pc
				exec_op.rs1 <= ZERO_REG;
				exec_op.rs2 <= ZERO_REG;
				exec_op.imm(31 downto 20) <= (others => instr_reg(31));
				exec_op.imm(19 downto 12) <= instr_reg(19 downto 12);
				exec_op.imm(11) <= instr_reg(20);
				exec_op.imm(10 downto 1) <= instr_reg(30 downto 21);
				exec_op.imm(0) <= '0';

				mem_op <= MEM_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_OPC;

			when OPC_JALR =>
				exec_op.aluop <= ALU_NOP;
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '1'; -- set PC adder to add imm and rs1
				exec_op.rs1 <= ZERO_REG;
				exec_op.rs2 <= ZERO_REG;
				exec_op.imm(31 downto 11) <= (others => instr_reg(31));
				exec_op.imm(10 downto 0) <= instr_reg(30 downto 20);

				mem_op <= MEM_NOP;

				wb_op.write <= '1';
				wb_op.src <= WBS_OPC;

			when OPC_BRANCH =>
				case instr_reg(14 downto 12) is

					when "000" =>
						exec_op.aluop <= ALU_SUB;
						exec_op.alusrc1 <= '0';
						exec_op.alusrc2 <= '0';
						exec_op.alusrc3 <= '0';-- set PC adder to add imm and old pc
						exec_op.imm(31 downto 12) <= (others => instr_reg(31));
						exec_op.imm(11) <= instr_reg(7);
						exec_op.imm(10 downto 5) <= instr_reg(30 downto 25);
						exec_op.imm(4 downto 1) <= instr_reg(11 downto 8);
						exec_op.imm(0) <= '0';

						mem_op.branch <= BR_CND;
						mem_op.mem <= MEMU_NOP;








					when others =>

				end case;

			when others =>

		end case;

	end process;

	sync : process(clk, res_n)
	begin
		if res_n = 0 then
			--reset registers
		elsif rising_edge(clk) then
			instr_reg <= instr;
		end if;
	end process;


end architecture;
