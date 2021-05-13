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

	signal pc_counter, pc_counter_next : pc_type := (others => '0');

begin


	sync : process (clk, res_n)
	variable current_pc : pc_type;
	begin
		current_pc := pc_counter_next;
		if not res_n then
			pc_out <= ZERO_PC;
			instr <= mem_in.rddata;
			mem_out <= MEM_OUT_FETCH_RES;
			mem_busy <= '0';
			pc_counter <= ZERO_PC;
		elsif rising_edge(clk) then
			mem_busy <= '0';
			mem_out <= MEM_OUT_FETCH_RES;
			pc_counter <= pc_counter_next;
			if not stall then 
				if flush then
					instr <= NOP_INST;
				else
					if pcsrc then
						current_pc:= pc_in;
					else
						current_pc := std_logic_vector(unsigned(pc_counter_next) + unsigned(pc_add));
					end if;
					pc_out <= current_pc;
					pc_counter <= current_pc;
					
					if mem_in.busy then
						mem_busy <= '1';
					end if;
					instr(7 downto 0) <= mem_in.rddata(31 downto 24);
					instr(15 downto 8) <= mem_in.rddata(23 downto 16);
					instr(23 downto 16) <= mem_in.rddata(15 downto 8);
					instr(31 downto 24) <= mem_in.rddata(7 downto 0);
				
					mem_out.address <= current_pc(ADDR_WIDTH+1 downto 2);
					mem_out.rd <= '1';
					

				end if;
			end if;
		end if;
	end process;

	pc_reg : process (all)
	begin
		pc_counter_next <= pc_counter;

	end process;
end architecture;
