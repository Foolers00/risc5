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

	signal stall : std_logic;

	signal if_ctrl_mem_busy : std_logic;
	signal mem_ctrl_pcsrc : std_logic;
	signal ctrl_if_pcsrc : std_logic;
	signal mem_if_pc : pc_type;
	signal if_id_pc : pc_type;
	signal if_id_instr : instr_type;
	signal wb_id_reg_write : reg_write_type;
	signal id_ex_pc : pc_type;
	signal id_ex_exec_op : exec_op_type;
	signal id_ex_mem_op : mem_op_type;
	signal id_ex_wb_op : wb_op_type;
	-- signal id_ctrl_exc_dec : std_logic;
	signal ex_mem_pc_old, ex_mem_pc_new : pc_type;
	signal ex_mem_aluresult : data_type;
	signal ex_mem_wrdata : data_type;
	signal ex_mem_zero : std_logic;
	signal ex_mem_mem_op : mem_op_type;
	signal ex_mem_wbop : wb_op_type;
	signal mem_ctrl_mem_busy : std_logic;
	signal mem_wb_wbop : wb_op_type;
	signal mem_wb_pc : pc_type;
	signal mem_wb_aluresult : data_type;
	signal meme_wb_memresult : data_type;

	signal ctrl_id_flush : std_logic;
	signal ctrl_exec_flush : std_logic;
	signal ctrl_if_flush : std_logic;
	signal ctrl_mem_flush : std_logic;
	signal ctrl_wb_flush : std_logic; 

	signal ctrl_id_stall : std_logic;
	signal ctrl_exec_stall : std_logic;
	signal ctrl_if_stall : std_logic;
	signal ctrl_mem_stall : std_logic;
	signal ctrl_wb_stall : std_logic; 
	
	constant REG_WRITE_NOP : reg_write_type := (
		write => '0',
		reg => ZERO_REG,
		data => ZERO_DATA
	);


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

	component ctrl is
		port (
			clk         : in std_logic;
			res_n       : in std_logic;
			stall       : in std_logic;
	
			stall_fetch : out std_logic;
			stall_dec   : out std_logic;
			stall_exec  : out std_logic;
			stall_mem   : out std_logic;
			stall_wb    : out std_logic;
	
			flush_fetch : out std_logic;
			flush_dec   : out std_logic;
			flush_exec  : out std_logic;
			flush_mem   : out std_logic;
			flush_wb    : out std_logic;
	
			-- from FWD
			wb_op_exec  : in  wb_op_type;
			exec_op_dec : in  exec_op_type;
	
			pcsrc_in : in std_logic;
			pcsrc_out : out std_logic
		);
	end component;

begin


	fetch_inst : fetch
	port map(
		clk => clk,
		res_n => res_n,
		stall => ctrl_if_stall,
		flush => ctrl_if_flush,

		mem_busy => if_ctrl_mem_busy,

		pcsrc => ctrl_if_pcsrc,
		pc_in => mem_if_pc,
		pc_out => if_id_pc,
		instr => if_id_instr,

		mem_out => mem_i_out,
		mem_in => mem_i_in
	);

	decode_inst : decode
	port map(
		clk => clk,
		res_n => res_n,
		stall => ctrl_id_stall,
		flush => ctrl_id_flush,

		pc_in => if_id_pc,
		instr => if_id_instr,

		reg_write => wb_id_reg_write,

		pc_out => id_ex_pc,
		exec_op => id_ex_exec_op,
		mem_op => id_ex_mem_op,
		wb_op => id_ex_wb_op,
		exc_dec => open
	);

	execute_inst : exec
	port map(
		clk => clk,
		res_n => res_n,
		stall => ctrl_exec_stall,
		flush => ctrl_exec_flush,

		op => id_ex_exec_op,
		pc_in => id_ex_pc,

		pc_old_out => ex_mem_pc_old,
		pc_new_out => ex_mem_pc_new,
		aluresult => ex_mem_aluresult,
		wrdata => ex_mem_wrdata,
		zero => ex_mem_zero,

		memop_in => id_ex_mem_op,
		memop_out => ex_mem_mem_op,
		wbop_in => id_ex_wb_op,
		wbop_out => ex_mem_wbop,

		exec_op => open,
		reg_write_mem => REG_WRITE_NOP,
		reg_write_wr => REG_WRITE_NOP
	);

	memory_inst : mem
	port map(
		clk => clk,
		res_n => res_n,
		stall => ctrl_mem_stall,
		flush => ctrl_mem_flush,

		mem_busy => mem_ctrl_mem_busy,

		mem_op => ex_mem_mem_op,
		wbop_in => ex_mem_wbop,
		pc_new_in => ex_mem_pc_new,
		pc_old_in => ex_mem_pc_old,
		aluresult_in => ex_mem_aluresult,
		wrdata => ex_mem_wrdata,
		zero => ex_mem_zero,

		reg_write => open,

		pc_new_out => mem_if_pc,
		pcsrc => mem_ctrl_pcsrc,

		wbop_out => mem_wb_wbop,
		pc_old_out => mem_wb_pc,
		aluresult_out => mem_wb_aluresult,
		memresult => meme_wb_memresult,

		mem_out => mem_d_out,
		mem_in => mem_d_in,

		exc_load => open,
		exc_store => open
	);

	writeback_inst : wb
	port map(
		clk => clk,
		res_n => res_n,
		stall => ctrl_wb_stall,
		flush => ctrl_wb_flush,

		op => mem_wb_wbop,
		aluresult => mem_wb_aluresult,
		memresult => meme_wb_memresult,
		pc_old_in => mem_wb_pc,

		reg_write => wb_id_reg_write
	);

	ctrl_inst : ctrl
	port map (
		clk		=> clk,
		res_n	=> res_n,
		stall	=> stall,

		stall_fetch => ctrl_if_stall,
		stall_dec   => ctrl_id_stall, 
		stall_exec  => ctrl_exec_stall,
		stall_mem   => ctrl_mem_stall,
		stall_wb    => ctrl_wb_stall,

		flush_fetch => ctrl_if_flush,
		flush_dec   => ctrl_id_flush,
		flush_exec  => ctrl_exec_flush,
		flush_mem   => ctrl_mem_flush,
		flush_wb    => ctrl_wb_flush,

		-- from FWD
		wb_op_exec  =>  ,
		exec_op_dec =>  ,
		
		pcsrc_in 	=> mem_ctrl_pcsrc,
		pcsrc_out 	=> ctrl_if_pcsrc

	);

	--flush <= '0';

	stall <= mem_ctrl_mem_busy or if_ctrl_mem_busy;

end architecture;
