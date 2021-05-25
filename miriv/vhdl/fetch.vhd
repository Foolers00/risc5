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
	constant PC_REG_RESEST_VAL : pc_type := (0 => '0', 1 => '0', others => '1');
	constant PC_ADD : pc_type := (2 => '1', others => '0');

	signal pcsrc_reg : std_logic;
	signal pc_in_reg : pc_type;
	signal pc_current, pc_current_next : pc_type;

begin

	mem_busy <= mem_in.busy;

	mem_out.address <= pc_current_next(ADDR_WIDTH+1 downto 2);
	mem_out.rd <= '1';
	mem_out.wr <= '0';
	mem_out.byteena <= (others => '1');
	mem_out.wrdata <= ZERO_DATA;

	pc_out <= pc_current;

	sync : process (clk, res_n)
	begin
		if res_n = '0' then
			pc_current <= PC_REG_RESEST_VAL;
			pcsrc_reg <= '0';
			pc_in_reg <= ZERO_PC;

		elsif rising_edge(clk) then
			if stall = '0' then
				pcsrc_reg <= pcsrc;
				pc_in_reg <= pc_in;
				pc_current <= pc_current_next;
			end if;
		end if;
	end process;

	async : process(all)
	begin

		pc_current_next <= pc_current;
		if stall = '0' then
			if pcsrc_reg = '1' then
				pc_current_next <= pc_in_reg;
			else
				pc_current_next <= std_logic_vector(unsigned(pc_current) + unsigned(PC_ADD));
			end if;
		end if;

		instr(7 downto 0) <= mem_in.rddata(31 downto 24);
		instr(15 downto 8) <= mem_in.rddata(23 downto 16);
		instr(23 downto 16) <= mem_in.rddata(15 downto 8);
		instr(31 downto 24) <= mem_in.rddata(7 downto 0);
		if res_n = '0' or flush = '1' then
			instr <= NOP_INST;
		end if;

	end process;
end architecture;
