library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st is
	generic (
		SETS_LD  : natural := SETS_LD;
		WAYS_LD  : natural := WAYS_LD
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		index : in c_index_type;
		wr    : in std_logic;
		rd    : in std_logic;

		valid_in    : in std_logic;
		dirty_in    : in std_logic;
		tag_in      : in c_tag_type;
		way_out     : out c_way_type;
		valid_out   : out std_logic;
		dirty_out   : out std_logic;
		tag_out     : out c_tag_type;
		hit_out     : out std_logic
	);
end entity;

architecture impl of mgmt_st is
	component mgmt_st_1w is
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
	end component;

	signal mgmt_1w_we : std_logic;
	signal mgmt_1w_repl : std_logic;
	signal mgmt_info_in : c_mgmt_info;
	signal mgmt_info_out : c_mgmt_info;

begin

	mgmt_st_1w_inst : mgmt_st_1w
	generic map (
		SETS_LD		=> SETS_LD
	)
	port map (
		clk 			=> clk,
		res_n			=> res_n,
		index			=> index,
		we				=> mgmt_1w_we,
		we_repl			=> mgmt_1w_repl,
		mgmt_info_in	=> mgmt_info_in,
		mgmt_info_out	=> mgmt_info_out
	);


	async : process (all)
	begin
		way_out <= (others => '0');
		valid_out <= '0';
		dirty_out <= '0';
		tag_out <= (others => '0');
		hit_out <= '0';

		mgmt_info_in.valid <= valid_in;
		mgmt_info_in.dirty <= dirty_in;
		mgmt_info_in.tag <= tag_in;
		mgmt_1w_we <= wr;
		mgmt_1w_repl <= '0';		

		if rd then
			if tag_in = mgmt_info_out.tag then
				hit_out <= '1';
			end if;
			valid_out <= mgmt_info_out.valid;
			dirty_out <= mgmt_info_out.dirty;
			tag_out <= mgmt_info_out.tag;
		end if;

		
	end process;


end architecture;
