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
			R    : out data_type := (others => '0');
			B    : out std_logic := '0';
			XL   : out std_logic := '0';
			XS   : out std_logic := '0';
			D    : in  mem_in_type;
			M    : out mem_out_type := MEM_OUT_NOP
		);
	end component;
	
	signal wbop, wbop_next : wb_op_type;
	signal aluresult, aluresult_next : data_type;
	signal pc_old, pc_old_next : pc_type;
	signal pc_new, pc_new_next : pc_type;
	signal wire_mem_in, wire_mem_in_next : mem_in_type;
	signal wire_mem_op, wire_mem_op_next : mem_op_type;
	signal branch_decision, branch_decision_next : std_logic;

begin


	memu_inst : memu
	port map (
		op  => wire_mem_op.mem,
		A   => aluresult_in, ---- no lo se
		W   => wrdata,
		R   => memresult,
		B   => mem_busy,
		XL  => exc_load,
		XS  => exc_store, 
		D   => wire_mem_in,
		M   => mem_out
	);

	sync : process (clk, res_n)
	begin
		if not res_n then
			wbop <= WB_NOP;
			pc_old <= ZERO_PC;
			pc_new <= ZERO_PC;
			aluresult <= ZERO_DATA;
			wire_mem_in <= MEM_IN_NOP;
			wire_mem_op <= MEM_NOP;
			branch_decision <= '0';

		elsif rising_edge(clk) then
			wbop <= wbop_next;
			pc_old <= pc_old_next;
			pc_new <= pc_new_next;
			aluresult <= aluresult_next;
			wire_mem_in <= wire_mem_in_next;
			wire_mem_op <= wire_mem_op_next;
			wire_mem_op.mem.memread <= '0';
			wire_mem_op.mem.memwrite <= '0';
			branch_decision <= '0';

			if not stall then
				if flush then
					wbop <= WB_NOP;
					pc_old <= ZERO_PC;
					pc_new <= ZERO_PC;
					aluresult <= ZERO_DATA;
					wire_mem_in <= MEM_IN_NOP;
					wire_mem_op <= MEM_NOP;
					branch_decision <= '0';
				else
					wbop <= wbop_in;
					pc_old <= pc_old_in;
					pc_new <= pc_new_in;
					aluresult <= aluresult_in;
					wire_mem_in <= mem_in;
					wire_mem_op <= mem_op;
					case mem_op.branch is
						when BR_NOP =>
							branch_decision <= '0';
						when BR_BR =>
							branch_decision <= '1';
						when BR_CND =>
							branch_decision <= '0';
							if zero then
								branch_decision <= '1';
							end if;
						when BR_CNDI =>
							branch_decision <= '0';
							if not zero then
								branch_decision <= '1';
							end if;
					end case;
				end if;
			end if;
			

		end if;
	end process;

	output : process (all)
	begin
		wbop_out <= wbop;
		pc_old_out <= pc_old;
		pc_new_out <= pc_new;
		aluresult_out <= aluresult;
		pcsrc <= branch_decision;
		
	end process;


	mem_register : process (all)
	begin
		wbop_next <= wbop;
		pc_old_next <= pc_old;
		pc_new_next <= pc_new;
		aluresult_next <= aluresult;
		wire_mem_in_next <= wire_mem_in;
		wire_mem_op_next <= wire_mem_op;
	end process;

end architecture;
