library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;


entity mem is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- to Ctrl
		mem_busy      : out std_logic;

		-- from EXEC
		mem_op        : in  mem_op_type;
		wbop_in       : in  wb_op_type;
		pc_new_in     : in  pc_type;
		pc_old_in     : in  pc_type;
		aluresult_in  : in  data_type;
		wrdata        : in  data_type;
		zero          : in  std_logic;

		-- to EXEC (forwarding)
		reg_write     : out reg_write_type;

		-- to FETCH
		pc_new_out    : out pc_type;
		pcsrc         : out std_logic;

		-- to WB
		wbop_out      : out wb_op_type;
		pc_old_out    : out pc_type;
		aluresult_out : out data_type;
		memresult     : out data_type;

		-- memory controller interface
		mem_out       : out mem_out_type;
		mem_in        : in  mem_in_type;

		-- exceptions
		exc_load      : out std_logic;
		exc_store     : out std_logic
	);
end entity;

architecture rtl of mem is

	component memu is
		port (
			op   : in  memu_op_type;
			A    : in  data_type;
			W    : in  data_type;
			R    : out data_type;
			B    : out std_logic;
			XL   : out std_logic;
			XS   : out std_logic;
			D    : in  mem_in_type;
			M    : out mem_out_type := MEM_OUT_NOP
		);
	end component;

	constant REG_WRITE_NOP : reg_write_type := (
		write => '0',
		reg => ZERO_REG,
		data => ZERO_DATA
	);

	signal wbop_reg, wbop_reg_next : wb_op_type;
	signal aluresult_reg, aluresult_reg_next : data_type;
	signal pc_old_reg, pc_old_reg_next : pc_type;
	signal pc_new_reg, pc_new_reg_next : pc_type;
	signal mem_op_reg, mem_op_reg_next : mem_op_type;
	signal wrdata_reg, wrdata_reg_next : data_type;
	signal zero_reg, zero_reg_next : std_logic;

begin


	memu_inst : memu
	port map (
		op  => mem_op_reg.mem,
		A   => aluresult_reg,
		W   => wrdata_reg,
		R   => memresult,
		B   => mem_busy,
		XL  => exc_load,
		XS  => exc_store,
		D   => mem_in,
		M   => mem_out
	);

	sync : process (clk, res_n)
	begin
		if not res_n then
			wbop_reg <= WB_NOP;
			pc_old_reg <= ZERO_PC;
			pc_new_reg <= ZERO_PC;
			aluresult_reg <= ZERO_DATA;
			mem_op_reg <= MEM_NOP;
			wrdata_reg <= ZERO_DATA;
			zero_reg <= '0';

		elsif rising_edge(clk) then
			wbop_reg <= wbop_reg_next;
			pc_old_reg <= pc_old_reg_next;
			pc_new_reg <= pc_new_reg_next;
			aluresult_reg <= aluresult_reg_next;
			mem_op_reg <= mem_op_reg_next;
			wrdata_reg <= wrdata_reg_next;
			zero_reg <= zero_reg_next;
			if flush = '1' then
					wbop_reg <= WB_NOP;
			end if;
		end if;
	end process;


	mem_register : process (all)
	begin
		-- New Register Input
		wbop_reg_next <= wbop_in;
		pc_old_reg_next <= pc_old_in;
		pc_new_reg_next <= pc_new_in;
		aluresult_reg_next <= aluresult_in;
		mem_op_reg_next <= mem_op;
		wrdata_reg_next <= wrdata;
		zero_reg_next <= zero;

		-- Output
		wbop_out <= wbop_reg;
		pc_old_out <= pc_old_reg;
		pc_new_out <= pc_new_reg;
		aluresult_out <= aluresult_reg;
		pcsrc <= '0';

		--output for forwarding
		--ASKTUTOR
		reg_write.write <= wbop_reg.write;
		reg_write.reg <= wbop_reg.rd;
		reg_write.data <= aluresult_reg;

		-- if flush then
		-- 	wbop_out <= WB_NOP;
		-- 	pc_old_out <= pc_old_reg;
		-- 	pc_new_out <= pc_new_reg;
		-- 	aluresult_out <= ZERO_DATA;
		--
		-- else
		if not flush then
			case mem_op_reg.branch is
				when BR_NOP =>
					pcsrc <= '0';
				when BR_BR =>
					pcsrc <= '1';
				when BR_CND =>
					pcsrc <= '0';
					if not zero_reg then
						pcsrc <= '1';
					end if;
				when BR_CNDI =>
					pcsrc <= '0';
					if zero_reg then
						pcsrc <= '1';
					end if;
			end case;
		end if;

		-- Old Register Input
		if stall then
			wbop_reg_next <= wbop_reg;
			pc_old_reg_next <= pc_old_reg;
			pc_new_reg_next <= pc_new_reg;
			aluresult_reg_next <= aluresult_reg;
			mem_op_reg_next <= mem_op_reg;
			mem_op_reg_next.mem.memread <= '0';
			mem_op_reg_next.mem.memwrite <= '0';
			wrdata_reg_next <= wrdata_reg;
			zero_reg_next <= zero_reg;
		end if;

	end process;

end architecture;
