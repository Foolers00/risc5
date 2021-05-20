library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity exec is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- from DEC
		op            : in  exec_op_type;
		pc_in         : in  pc_type;

		-- to MEM
		pc_old_out    : out pc_type;
		pc_new_out    : out pc_type;
		aluresult     : out data_type;
		wrdata        : out data_type;
		zero          : out std_logic;

		memop_in      : in  mem_op_type;
		memop_out     : out mem_op_type;
		wbop_in       : in  wb_op_type;
		wbop_out      : out wb_op_type;

		-- FWD
		exec_op       : out exec_op_type;
		reg_write_mem : in  reg_write_type;
		reg_write_wr  : in  reg_write_type
	);
end entity;

architecture rtl of exec is

	component alu is
		port (
			op   : in  alu_op_type;
			A, B : in  data_type;
			R    : out data_type;
			Z    : out std_logic
		);
	end component;



	signal wbop_reg, wbop_reg_next : wb_op_type;
	signal mem_op_reg, mem_op_reg_next : mem_op_type;
	signal pc_old_reg, pc_old_reg_next : pc_type;
	signal temp_pc_new_out : data_type;
	signal exec_op_reg, exec_op_reg_next : exec_op_type;
	signal pc_add_A_reg, pc_add_A_reg_next : data_type;
	signal pc_add_B_reg, pc_add_B_reg_next : data_type;

	signal alu_A, alu_B : data_type;



begin


	alu_inst1 : alu
	port map (
		op => exec_op_reg.aluop,
		A => alu_A,
		B => alu_B,
		R => aluresult,
		Z => zero
	);

	alu_inst2 : alu
	port map (
		op => ALU_ADD,
		A => pc_add_A_reg,
		B => pc_add_B_reg,
		R => temp_pc_new_out,
		Z => open
	);

	sync : process (clk, res_n)
	begin
		if not res_n then
			wbop_reg <= WB_NOP;
			mem_op_reg <= MEM_NOP;
			pc_old_reg <= ZERO_PC;
			exec_op_reg <= EXEC_NOP;
			pc_add_A_reg <= ZERO_DATA;
			pc_add_B_reg <= ZERO_DATA;
		elsif rising_edge(clk) then
			wbop_reg <= wbop_reg_next;
			mem_op_reg <= mem_op_reg_next;
			pc_old_reg <= pc_old_reg_next;
			exec_op_reg <= exec_op_reg_next;
			pc_add_A_reg <= pc_add_A_reg_next;
			pc_add_B_reg <= pc_add_B_reg_next;
		end if;
	end process;



	alu_reg : process (all)
	begin
		--define inputs of ALU
		if exec_op_reg.alusrc1 = '0' then
			alu_A <= exec_op_reg.readdata1;
		else
			alu_A <= pc_old_reg;
		end if;

		if exec_op_reg.alusrc2 = '0' then
			alu_B <= exec_op_reg.readdata2;
		else
			alu_B <= exec_op_reg.imm;
		end if;

		-- New Register Input
		wbop_reg_next <= wbop_in;
		mem_op_reg_next <= memop_in;
		pc_old_reg_next <= pc_in;
		exec_op_reg_next <= op;

		-- Output
		wbop_out <= wbop_reg;
		memop_out <= mem_op_reg;
		pc_old_out <= pc_old_reg;
		pc_new_out <= to_pc_type(data => temp_pc_new_out);
		wrdata <= exec_op_reg.readdata2;

		if flush then
			wbop_out <= WB_NOP;
			memop_out <= MEM_NOP;
			pc_old_out <= pc_old_reg;
			pc_new_out <= pc_old_reg;
			wrdata <= ZERO_DATA;

		else

			pc_add_A_reg_next <= op.imm;
			pc_add_B_reg_next <= to_data_type(pc => pc_in);
			if op.alusrc3 then
				pc_add_B_reg_next <= op.readdata1;
			end if;

		end if;

		-- Old Register Input
		if stall then
			wbop_reg_next <= wbop_reg;
			mem_op_reg_next <= mem_op_reg;
			pc_old_reg_next <= pc_old_reg;
			exec_op_reg_next <= exec_op_reg;
		end if;

	end process;

	exec_op  <= EXEC_NOP;


end architecture;
