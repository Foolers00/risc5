library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity ctrl is
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
end entity;

architecture rtl of ctrl is

begin


	async : process (all)
	begin
		-- Output
		stall_fetch <= '0';
		stall_dec <= '0';
		stall_exec <= '0';
		stall_mem <= '0';
		stall_wb <= '0';

		flush_fetch <= '0';
		flush_dec <= '0';
		flush_exec <= '0';
		flush_mem <= '0';
		flush_wb <= '0';

		pcsrc_out <= pcsrc_in;

		-- when branch occurs the following 3 instructions need to be flushed
		-- flush signal is registered in dec, ex and mem stage
		-- therefore dec, ex, mem need to be flushed instead of fetch, dec, ex
		if pcsrc_in then
			flush_dec <= '1';
			flush_exec <= '1';
			flush_mem <= '1';
		end if;

		if res_n = '0' then
			flush_fetch <= '1';
			flush_dec <= '1';
			flush_exec <= '1';
			flush_mem <= '1';
			flush_wb <= '1';
		end if;

		if stall then
			stall_fetch <= '1';
			stall_dec <= '1';
			stall_exec <= '1';
			stall_mem <= '1';
			stall_wb <= '1';

		else
			--TODO flush exec
			if (wb_op_exec.src = WBS_MEM and wb_op_exec.rd /= ZERO_REG and
			(exec_op_dec.rs1 = wb_op_exec.rd or exec_op_dec.rs2 = wb_op_exec.rd)) then
				stall_fetch <= '1';
				stall_dec <= '1';
				flush_exec <= '1';
			end if;
		end if;

	end process;
end architecture;
