library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity pipeline is
	port (
		clk    : in  std_logic;
		res_n  : in  std_logic;

		-- instruction interface
		mem_i_out    : out mem_out_type;
		mem_i_in     : in  mem_in_type;

		-- data interface
		mem_d_out    : out mem_out_type;
		mem_d_in     : in  mem_in_type
	);
end entity;

architecture impl of pipeline is
begin

	component fetch is
		port (
			clk        : in  std_logic;
			res_n      : in  std_logic;
			stall      : in  std_logic;
			flush      : in  std_logic;

			-- to control
			mem_busy   : out std_logic;

			pcsrc      : in  std_logic;
			pc_in      : in  pc_type;
			pc_out     : out pc_type := (others => '0');
			instr      : out instr_type;

			-- memory controller interface
			mem_out   : out mem_out_type;
			mem_in    : in  mem_in_type
		);
	end component;

	component decode is
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
	end component;

	component exec is
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
	end component;

	component mem is
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
	end component;

	component wb is
		port (
			clk        : in  std_logic;
			res_n      : in  std_logic;
			stall      : in  std_logic;
			flush      : in  std_logic;

			-- from MEM
			op         : in  wb_op_type;
			aluresult  : in  data_type;
			memresult  : in  data_type;
			pc_old_in  : in  pc_type;

			-- to FWD and DEC
			reg_write  : out reg_write_type
		);
	end component;


end architecture;
