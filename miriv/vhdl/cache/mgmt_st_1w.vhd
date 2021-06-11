library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk     : in std_logic;
		res_n   : in std_logic;

		index   : in c_index_type;
		we      : in std_logic;
		we_repl	: in std_logic;

		mgmt_info_in  : in c_mgmt_info;
		mgmt_info_out : out c_mgmt_info
	);
end entity;

architecture impl of mgmt_st_1w is

	type mgmt_info is array (2**(SETS_LD)-1 downto 0) of c_mgmt_info;

	signal mgmt_info_reg, mgmt_info_reg_next : mgmt_info;

begin

	sync : process (clk, res_n)
	begin
		if res_n then
			for i in 0 to 2**(SETS_LD)-1 loop
				mgmt_info_reg(i).valid <= '0';
			end loop;

		elsif rising_edge(clk) then
			mgmt_info_reg <= mgmt_info_reg_next;
		end if;
	
	end process;


	async : process (all)
	begin
		mgmt_info_out <= mgmt_info_reg(to_integer(unsigned(index)));
		if we then
			mgmt_info_reg_next(to_integer(unsigned(index))) <= mgmt_info_in;
		end if;
	end process;

end architecture;
