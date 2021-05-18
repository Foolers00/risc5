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
	

	constant PC_REG_RESVAL : pc_type := (0 => '0', 1 => '0', others => '1');

	constant PC_ADD : pc_type := (2 => '1', others => '0');

	signal pc_counter_reg, pc_counter_reg_next : pc_type := PC_REG_RESVAL;
	signal pcsrc_reg, pcsrc_reg_next : std_logic;
	signal pc_in_reg, pc_in_reg_next : pc_type;

	

begin


	sync : process (clk, res_n)
	begin
		if not res_n then
			pc_in_reg <= ZERO_PC;
			pcsrc_reg <= '0';
			pc_counter_reg <= PC_REG_RESVAL;
		elsif rising_edge(clk) then
			pc_counter_reg <= pc_counter_reg_next;
			pc_in_reg <= pc_in_reg_next;
			pcsrc_reg <= pcsrc_reg_next;
			
		end if;
	end process;



	pc_reg : process (all)
	variable current_pc : pc_type;
	begin
		-- New Register Input
		pc_counter_reg_next <= pc_counter_reg;
		pc_in_reg_next <= pc_in;
		pcsrc_reg_next <= pcsrc;
	
		current_pc := pc_counter_reg;

		if flush then 
			instr <= NOP_INST;
			mem_out <= MEM_OUT_NOP;
			pc_out <= pc_counter_reg;
			mem_busy <= '0';
		else	
		
			if pcsrc_reg then
				current_pc := pc_in_reg;
			else
				current_pc := std_logic_vector(unsigned(pc_counter_reg) + unsigned(PC_ADD));
			end if;
			pc_out <= pc_counter_reg;
			pc_counter_reg_next <= current_pc;

			if mem_in.busy then
				mem_busy <= '1';
			else
				mem_busy <= '0';
			end if;
			instr(7 downto 0) <= mem_in.rddata(31 downto 24);
			instr(15 downto 8) <= mem_in.rddata(23 downto 16);
			instr(23 downto 16) <= mem_in.rddata(15 downto 8);
			instr(31 downto 24) <= mem_in.rddata(7 downto 0);
			if not res_n then
				instr <= NOP_INST;
			end if;
		
			mem_out.address <= current_pc(ADDR_WIDTH+1 downto 2);
			mem_out.rd <= '1';
			mem_out.wr <= '0';
			mem_out.byteena <= (others => '1');
			mem_out.wrdata <= ZERO_DATA;
		end if;



		-- Old Register Input
		if stall then
			pc_counter_reg_next <= pc_counter_reg;
			pc_in_reg_next <= pc_in_reg;
			pcsrc_reg_next <= pcsrc_reg;
		end if;

	end process;
end architecture;
