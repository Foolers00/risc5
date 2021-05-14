library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity fetch is
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
end entity;

architecture rtl of fetch is
	
	constant MEM_OUT_FETCH_RES : mem_out_type := (
		address => (others => '0'),
		rd      => '1',
		wr      => '0',
		byteena => (others => '1'),
		wrdata  => (others => '0')
	);

	constant pc_add : pc_type := (2 => '1', others => '0');

	signal pc_counter_reg, pc_counter_reg_next : pc_type := (others => '0');
	signal pcsrc_reg, pcsrc_reg_next : std_logic;
	signal pc_in_reg, pc_in_reg_next : pc_type;
	signal pc_out_reg, pc_out_reg_next : pc_type;
	signal instr_reg, instr_reg_next : instr_type;
	signal mem_in_reg, mem_in_reg_next : mem_in_type;
	signal mem_out_reg, mem_out_reg_next : mem_out_type;
	signal mem_busy_reg, mem_busy_reg_next : std_logic;
	signal stall_reg, stall_reg_next : std_logic;
	signal flush_reg, flush_reg_next : std_logic;


begin


	sync : process (clk, res_n)
	begin
		if not res_n then
			pc_in_reg <= ZERO_PC;
			pc_out_reg <= ZERO_PC;
			pcsrc_reg <= '0';
			instr_reg <= mem_in.rddata;
			mem_in_reg <= MEM_IN_NOP;
			mem_out_reg <= MEM_OUT_FETCH_RES;
			mem_busy_reg <= '0';
			pc_counter_reg <= ZERO_PC;
			stall_reg <= '0';
			flush_reg <= '0';
		elsif rising_edge(clk) then
			mem_busy_reg <= mem_busy_reg_next;
			mem_out_reg <= mem_out_reg_next;
			pc_counter_reg <= pc_counter_reg_next;
			pc_out_reg <= pc_out_reg_next;
			pc_in_reg <= pc_in_reg_next;
			instr_reg <= instr_reg_next;
			mem_in_reg <= mem_in_reg_next;
			pcsrc_reg <= pcsrc_reg_next;
			flush_reg <= flush_reg_next;
			stall_reg <= stall_reg_next;
			
		end if;
	end process;


	output : process (all)
	begin
		pc_out <= pc_out_reg;
		instr <= instr_reg;
		mem_out <= mem_out_reg;
		mem_busy <= mem_busy_reg;
		
	end process;

	pc_reg : process (all)
	variable current_pc : pc_type;
	begin
		pc_counter_reg_next <= pc_counter_reg;
		pc_in_reg_next <= pc_in;
		pc_out_reg_next <= pc_out_reg;
		pcsrc_reg_next <= pcsrc;
		instr_reg_next <= instr_reg;
		mem_in_reg_next <= mem_in;
		mem_out_reg_next <= mem_out_reg;
		mem_out_reg_next.rd <= '0';
		mem_busy_reg_next <= '0';
		flush_reg_next <= flush;
		stall_reg_next <= stall;

		current_pc := pc_counter_reg;

	
		if not stall_reg then 
			if flush_reg then
				instr_reg_next <= NOP_INST;
			else
				if pcsrc_reg then
					current_pc:= pc_in_reg;
				else
					current_pc := std_logic_vector(unsigned(pc_counter_reg) + unsigned(pc_add));
				end if;
				pc_out_reg_next <= current_pc;
				pc_counter_reg_next <= current_pc;
				
				if mem_in_reg.busy then
					mem_busy_reg_next <= '1';
				end if;
				instr_reg_next(7 downto 0) <= mem_in_reg.rddata(31 downto 24);
				instr_reg_next(15 downto 8) <= mem_in_reg.rddata(23 downto 16);
				instr_reg_next(23 downto 16) <= mem_in_reg.rddata(15 downto 8);
				instr_reg_next(31 downto 24) <= mem_in_reg.rddata(7 downto 0);
			
				mem_out_reg_next.address <= current_pc(ADDR_WIDTH+1 downto 2);
				mem_out_reg_next.rd <= '1';
				

			end if;
		end if;

	end process;
end architecture;
