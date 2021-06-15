library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity cache is
	generic (
		SETS_LD   : natural          := SETS_LD;
		WAYS_LD   : natural          := WAYS_LD;
		ADDR_MASK : mem_address_type := (others => '1')
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		mem_out_cpu : in  mem_out_type;
		mem_in_cpu  : out mem_in_type;
		mem_out_mem : out mem_out_type;
		mem_in_mem  : in  mem_in_type
	);
end entity;

architecture bypass of cache is --bypass cache for exIII and testing
	alias cpu_to_cache : mem_out_type is mem_out_cpu; 
	alias cache_to_cpu : mem_in_type is mem_in_cpu;   
	alias cache_to_mem : mem_out_type is mem_out_mem; 
	alias mem_to_cache : mem_in_type is mem_in_mem;   
begin
	cache_to_mem <= cpu_to_cache; 
	cache_to_cpu <= mem_to_cache; 
end architecture;


-------------------------------------------------------------------------------

architecture impl of cache is

	component mgmt_st is
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
	end component;


	component data_st is
		generic (
			SETS_LD  : natural := SETS_LD;
			WAYS_LD  : natural := WAYS_LD
		);
		port (
			clk        : in std_logic;
	
			we         : in std_logic;
			rd         : in std_logic;
			way        : in c_way_type;
			index      : in c_index_type;
			byteena    : in mem_byteena_type;
	
			data_in    : in mem_data_type;
			data_out   : out mem_data_type
	);
	end component;




	signal state_reg, state_reg_next : cache_state_t := IDLE;
	signal is_caching_reg, is_caching_reg_next : std_logic := '1'; 
	signal mem_out_cpu_reg, mem_out_cpu_reg_next : mem_out_type;
	--signal mem_in_mem_reg, mem_in_mem_reg_next : mem_in_type;
	signal mem_rddata_reg, mem_rddata_reg_next : mem_data_type;
	signal wrback_mem_out_reg, wrback_mem_out_reg_next : mem_out_type;


	--mgmt signals 
	signal mgmt_index : c_index_type := (others => '0');
	signal mgmt_wr : std_logic := '0';
	signal mgmt_rd : std_logic := '0';
	signal mgmt_valid_in : std_logic := '0';
	signal mgmt_dirty_in : std_logic := '0';
	signal mgmt_tag_in : c_tag_type := (others => '0');
	signal mgmt_way_out : c_way_type;
	signal mgmt_valid_out : std_logic;
	signal mgmt_dirty_out : std_logic;
	signal mgmt_tag_out : c_tag_type;
	signal mgmt_hit_out : std_logic;

	--data signals
	signal data_we : std_logic := '0';
	signal data_rd : std_logic := '0';
	signal data_way : c_way_type :=  (others => '0'); 
	signal data_index : c_index_type := (others => '0');
	signal data_byteena : mem_byteena_type := (others => '1');
	signal data_in : mem_data_type := (others => '0');
	signal data_out : mem_data_type;
	
begin

	mgmt_st_inst : mgmt_st
	generic map (
		SETS_LD  => SETS_LD,
		WAYS_LD  => WAYS_LD
	)
	port map (
		clk   		=> clk,
		res_n 		=> res_n,
		index 		=> mgmt_index,
		wr    		=> mgmt_wr,
		rd    		=> mgmt_rd,
		valid_in    => mgmt_valid_in,
		dirty_in    => mgmt_dirty_in,
		tag_in      => mgmt_tag_in,
		way_out     => mgmt_way_out,
		valid_out   => mgmt_valid_out,
		dirty_out   => mgmt_dirty_out,
		tag_out     => mgmt_tag_out,
		hit_out     => mgmt_hit_out
	);

	data_st_inst : data_st
	generic map (
		SETS_LD  => SETS_LD,
		WAYS_LD  => WAYS_LD
	)
	port map (
		clk 		=> clk,	
		we        	=> data_we,
		rd         	=> data_rd,
		way        	=> data_way,
		index       => data_index,
		byteena    	=> data_byteena,
		data_in    	=> data_in,
		data_out   	=> data_out

	);

	sync : process (clk, res_n)
	begin
		if not res_n then
			state_reg <= IDLE;
			is_caching_reg <= '1';
			mem_out_cpu_reg <= MEM_OUT_NOP;
			mem_rddata_reg <= (others => '0');
			wrback_mem_out_reg <= MEM_OUT_NOP;

		elsif rising_edge(clk) then
			state_reg <= state_reg_next;
			is_caching_reg <= is_caching_reg_next;
			mem_out_cpu_reg <= mem_out_cpu_reg_next;
			mem_rddata_reg <= mem_rddata_reg_next;
			wrback_mem_out_reg <= wrback_mem_out_reg_next;
		end if;

	end process;

	next_state_reg : process (all)
	variable set_signal : std_logic;
	begin
		state_reg_next <= state_reg;
		is_caching_reg_next <= is_caching_reg;
		set_signal := '0';
		mem_out_cpu_reg_next <= mem_out_cpu_reg;
		mem_rddata_reg_next <= mem_rddata_reg;
		wrback_mem_out_reg_next <= wrback_mem_out_reg;

		-- mgmt signals
		mgmt_index <= (others => '0');
		mgmt_wr <= '0';
		mgmt_rd <= '0';
		mgmt_valid_in <= '0';
		mgmt_dirty_in <= '0';
		mgmt_tag_in <= (others => '0');

		-- data signals
		data_we <= '0';
		data_rd <= '0';
		data_way <=  (others => '0'); 
		data_index <= (others => '0');
		data_byteena <= (others => '1');
		data_in <= (others => '0');

		-- OUTPUTS
		mem_in_cpu  <= MEM_IN_NOP;
		mem_out_mem <= MEM_OUT_NOP;

		case state_reg is
			when IDLE =>
				-- New Inputs
				mem_out_cpu_reg_next <= mem_out_cpu;

				is_caching_reg_next <= '0';
				if (unsigned(mem_out_cpu.address) or unsigned(ADDR_MASK)) = unsigned(ADDR_MASK) then
					is_caching_reg_next <= '1';
					set_signal := '1';
				end if;

				-- READ ACCESS CACHE
				if mem_out_cpu.rd then
					mem_in_cpu.busy <= '1';
					if not set_signal then
						-- SETTING MEMORY READ SIGNALS
						state_reg_next <= READ_MEM_START;
						mem_out_mem <= mem_out_cpu;
					else
						-- SETTING MGMT CACHE READ SIGNALS
						mgmt_index <= mem_out_cpu.address(INDEX_SIZE-1 downto 0);
						mgmt_rd <= '1';
						if mgmt_hit_out and mgmt_valid_out then
							if mgmt_tag_out = mem_out_cpu.address(TAG_SIZE-1+INDEX_SIZE downto INDEX_SIZE) then
								-- SETTING DATA CACHE READ SIGNALS
								data_rd <= '1';
								data_index <= mem_out_cpu.address(INDEX_SIZE-1 downto 0);
								data_byteena <= mem_out_cpu.byteena;
								state_reg_next <= READ_CACHE;
							else
								state_reg_next <= READ_MEM_START;
							end if;
						else
							state_reg_next <= READ_MEM_START;
						end if;
					end if;

				-- WRITE ACCESS CACHE
				elsif mem_out_cpu.wr then
					if not set_signal then
						-- SETTING MEMORY WRITE SIGNALS
						mem_out_mem <= mem_out_cpu;
					else
						-- SETTING CACHE WRITE SIGNALS
						mgmt_index <= mem_out_cpu.address(INDEX_SIZE-1 downto 0);
						mgmt_tag_in <= mem_out_cpu.address(TAG_SIZE-1+INDEX_SIZE downto INDEX_SIZE);
						mgmt_rd <= '1';
						if mgmt_hit_out then
							mgmt_valid_in <= '1';
							mgmt_dirty_in <= '1';
							mgmt_wr <= '1';
							
							data_we <= '1';
							data_index <= mem_out_cpu.address(INDEX_SIZE-1 downto 0);
							data_byteena <= mem_out_cpu.byteena;
							data_in <= mem_out_cpu.wrdata;
						else
							mem_out_mem <= mem_out_cpu;
						end if;
					end if;
					state_reg_next <= IDLE;
				end if;
			
			when READ_CACHE =>
				mem_in_cpu.busy <= '1';
				mem_in_cpu.rddata <= data_out;
				state_reg_next <= IDLE;
				
			when READ_MEM_START =>
				mem_out_mem <= mem_out_cpu_reg;
				mem_in_cpu.busy <= '1';
				state_reg_next <= READ_MEM;
			
			when READ_MEM =>
				mem_in_cpu.busy <= '1';
				if not mem_in_mem.busy then
					if not is_caching_reg then
						mem_in_cpu <= mem_in_mem;
						state_reg_next <= IDLE;
					else
						mem_rddata_reg_next <= mem_in_mem.rddata;
						
						mgmt_index <= mem_out_cpu_reg.address(INDEX_SIZE-1 downto 0);
						mgmt_rd <= '1';


						-- CACHE NEW MGMT INFORMATION WRITE ACCESS
						mgmt_wr <= '1';
						mgmt_valid_in <= '1';
						mgmt_dirty_in <= '0';
						mgmt_tag_in <= mem_out_cpu_reg.address(TAG_SIZE-1+INDEX_SIZE downto INDEX_SIZE);
						
						-- CACHE NEW DATA WRITE ACCESS
						data_we <= '1';
						data_index <= mem_out_cpu_reg.address(INDEX_SIZE-1 downto 0);
						data_byteena <= mem_out_cpu_reg.byteena;
						data_in <= mem_in_mem.rddata;

						if mgmt_dirty_out then
							-- CACHE OLD DATA READ ACCESS
							data_rd <= '1';
							data_index <= mem_out_cpu_reg.address(INDEX_SIZE-1 downto 0);
							data_byteena <= (others => '1');

							-- PREPERATIONN FOR WRITE BACK FOR DIRTY CACHE ENTRY
							wrback_mem_out_reg.address(TAG_SIZE-1+INDEX_SIZE downto INDEX_SIZE) <= mgmt_tag_out;
							wrback_mem_out_reg.address(INDEX_SIZE-1 downto 0) <= mem_out_cpu_reg.address(INDEX_SIZE-1 downto 0);
							wrback_mem_out_reg.byteena <= (others => '1');
							wrback_mem_out_reg.wrdata <= data_out;
							wrback_mem_out_reg.wr <= '1';

							state_reg_next <= WRITE_BACK_START;
						else
							state_reg_next <= IDLE;
						end if;	
					end if;
				end if;
			
			when WRITE_BACK_START =>
				mem_in_cpu.busy <= '1';
				mem_out_mem <= wrback_mem_out_reg;
				state_reg_next <= WRITE_BACK;


			when WRITE_BACK => 
				mem_in_cpu.busy <= '0';
				mem_in_cpu.rddata <= mem_rddata_reg;
				state_reg_next <= IDLE;

			when others =>

		end case;
	end process;

end architecture;
