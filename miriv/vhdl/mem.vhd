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
	signal mem_in_reg, mem_in_reg_next : mem_in_type;
	signal mem_out_reg, mem_out_reg_next : mem_out_type;
	signal mem_op_reg, mem_op_reg_next : mem_op_type;
	signal pcsrc_reg, pcsrc_reg_next : std_logic;
	signal flush_reg, flush_reg_next : std_logic;
	signal stall_reg, stall_reg_next : std_logic;
	signal wrdata_reg, wrdata_reg_next : data_type;
	signal memresult_reg, memresult_reg_next : data_type;
	signal mem_busy_reg, mem_busy_reg_next : std_logic;
	signal exc_load_reg, exc_load_reg_next : std_logic;
	signal exc_store_reg, exc_store_reg_next : std_logic;
	signal zero_reg, zero_reg_next : std_logic;

begin


	memu_inst : memu
	port map (
		op  => mem_op_reg.mem,
		A   => aluresult_reg, 
		W   => wrdata_reg,
		R   => memresult_reg_next,
		B   => mem_busy_reg_next,
		XL  => exc_load_reg_next,
		XS  => exc_store_reg_next, 
		D   => mem_in_reg,
		M   => mem_out_reg_next
	);

	sync : process (clk, res_n)
	begin
		if not res_n then
			wbop_reg <= WB_NOP;
			pc_old_reg <= ZERO_PC;
			pc_new_reg <= ZERO_PC;
			aluresult_reg <= ZERO_DATA;
			mem_in_reg <= MEM_IN_NOP;
			mem_out_reg <= MEM_OUT_NOP;
			mem_op_reg <= MEM_NOP;
			pcsrc_reg <= '0';
			stall_reg <= '0';
			flush_reg <= '0';
			wrdata_reg <= ZERO_DATA;
			memresult_reg <= ZERO_DATA;
			mem_busy_reg <= '0';
			exc_load_reg <= '0';
			exc_store_reg <= '0';
			zero_reg <= '0';

		elsif rising_edge(clk) then
			wbop_reg <= wbop_reg_next;
			pc_old_reg <= pc_old_reg_next;
			pc_new_reg <= pc_new_reg_next;
			aluresult_reg <= aluresult_reg_next;
			mem_in_reg <= mem_in_reg_next;
			mem_out_reg <= mem_out_reg_next;
			mem_op_reg <= mem_op_reg_next;
			pcsrc_reg <= pcsrc_reg_next;
			stall_reg <= stall_reg_next;
			flush_reg <= flush_reg_next;
			wrdata_reg <= wrdata_reg_next;
			memresult_reg <= memresult_reg_next;
			mem_busy_reg <= mem_busy_reg_next;
			exc_load_reg <= exc_load_reg_next;
			exc_store_reg <= exc_store_reg_next; 
			zero_reg <= zero_reg_next;

		end if;
	end process;

	output : process (all)
	begin
		wbop_out <= wbop_reg;
		pc_old_out <= pc_old_reg;
		pc_new_out <= pc_new_reg;
		aluresult_out <= aluresult_reg;
		pcsrc <= pcsrc_reg;
		memresult <= memresult_reg;
		mem_out <= mem_out_reg;
		mem_busy <= mem_busy_reg;
		exc_load <= exc_load_reg;
		exc_store <= exc_store_reg;
		
	end process;


	mem_register : process (all)
	begin
		wbop_reg_next <= wbop_reg;
		pc_old_reg_next <= pc_old_reg;
		pc_new_reg_next <= pc_new_reg;
		aluresult_reg_next <= aluresult_reg;
		mem_in_reg_next <= mem_in_reg;
		mem_op_reg_next <= mem_op_reg;
		mem_op_reg_next.mem.memread <= '0';
		mem_op_reg_next.mem.memwrite <= '0';
		pcsrc_reg_next <= pcsrc_reg;
		wrdata_reg_next <= wrdata_reg;
		zero_reg_next <= zero_reg;
		flush_reg_next <= flush;
		stall_reg_next <= stall;

		if not stall_reg then
			if flush_reg then
				wbop_reg_next <= WB_NOP;
				pc_old_reg_next <= ZERO_PC;
				pc_new_reg_next <= ZERO_PC;
				aluresult_reg_next <= ZERO_DATA;
				mem_in_reg_next <= MEM_IN_NOP;
				mem_op_reg_next <= MEM_NOP;
				pcsrc_reg_next <= '0';
				wrdata_reg_next <= ZERO_DATA;
				zero_reg_next <= '0';
			else
				wbop_reg_next <= wbop_in;
				pc_old_reg_next <= pc_old_in;
				pc_new_reg_next <= pc_new_in;
				aluresult_reg_next <= aluresult_in;
				mem_in_reg_next <= mem_in;
				mem_op_reg_next <= mem_op;
				wrdata_reg_next <= wrdata;
				
				case mem_op_reg.branch is
					when BR_NOP =>
						pcsrc_reg_next <= '0';
					when BR_BR =>
						pcsrc_reg_next <= '1';
					when BR_CND =>
						pcsrc_reg_next <= '0';
						if zero_reg then
							pcsrc_reg_next <= '1';
						end if;
					when BR_CNDI =>
						pcsrc_reg_next <= '0';
						if not zero_reg then
							pcsrc_reg_next <= '1';
						end if;
				end case;
			end if;
		end if;
		
	end process;

	reg_write <= REG_WRITE_NOP;

end architecture;
