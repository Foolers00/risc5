library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.single_clock_rw_ram_pkg.all;

entity data_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk       : in std_logic;

		we        : in std_logic;
		rd        : in std_logic;
		index     : in c_index_type;
		byteena   : in mem_byteena_type;

		data_in   : in mem_data_type;
		data_out  : out mem_data_type
);
end entity;

architecture impl of data_st_1w is
	
	signal ram_we_byte_0, ram_we_byte_1, ram_we_byte_2, ram_we_byte_4 : std_logic;
	signal rd_reg, rd_reg_next : std_logic;
	signal data_temp_out : mem_data_type;

begin
	ram_byte_0_inst : single_clock_rw_ram
	generic map (
		ADDR_WIDTH	=> 2**(SETS_LD-1),
		DATA_WIDTH 	=> BYTE_WIDTH	
	)
	port map (
		clk 				=> clk,
		data_in				=> data_in(DATA_WIDTH-1 downto DATA_WIDTH-BYTE_WIDTH),
		write_address		=> index,
		read_address		=> index,
		we 					=> ram_we_byte_0,
		data_out			=> data_temp_out(DATA_WIDTH-1 downto DATA_WIDTH-BYTE_WIDTH)
	);

	ram_byte_1_inst : single_clock_rw_ram
	generic map (
		ADDR_WIDTH	=> 2**(SETS_LD-1),
		DATA_WIDTH 	=> BYTE_WIDTH	
	)
	port map (
		clk 				=> clk,
		data_in				=> data_in(DATA_WIDTH-1-BYTE_WIDTH downto DATA_WIDTH-2*BYTE_WIDTH),
		write_address		=> index,
		read_address		=> index,
		we 					=> ram_we_byte_1,
		data_out			=> data_temp_out(DATA_WIDTH-1-BYTE_WIDTH downto DATA_WIDTH-2*BYTE_WIDTH)
	);

	ram_byte_2_inst : single_clock_rw_ram
	generic map (
		ADDR_WIDTH	=> 2**(SETS_LD-1),
		DATA_WIDTH 	=> BYTE_WIDTH	
	)
	port map (
		clk 				=> clk,
		data_in				=> data_in(DATA_WIDTH-1-2*BYTE_WIDTH downto DATA_WIDTH-3*BYTE_WIDTH),
		write_address		=> index,
		read_address		=> index,
		we 					=> ram_we_byte_2,
		data_out			=> data_temp_out(DATA_WIDTH-1-2*BYTE_WIDTH downto DATA_WIDTH-3*BYTE_WIDTH)
	);

	ram_byte_3_inst : single_clock_rw_ram
	generic map (
		ADDR_WIDTH	=> 2**(SETS_LD-1),
		DATA_WIDTH 	=> BYTE_WIDTH	
	)
	port map (
		clk 				=> clk,
		data_in				=> data_in(DATA_WIDTH-1-3*BYTE_WIDTH downto DATA_WIDTH-4*BYTE_WIDTH),
		write_address		=> index,
		read_address		=> index,
		we 					=> ram_we_byte_3,
		data_out			=> data_temp_out(DATA_WIDTH-1-3*BYTE_WIDTH downto DATA_WIDTH-4*BYTE_WIDTH)
	);



	sync : process (all)
	begin
		if rising_edge(clk) then
			rd_reg <= rd_reg_next;
		end if;
	end process;

	async : process (all)
	begin

		ram_we_byte_0 <= '0';
		ram_we_byte_1 <= '0';
		ram_we_byte_2 <= '0';
		ram_we_byte_3 <= '0';

		data_out <= (others => '0');
		rd_reg_next <= rd;

		if we then
			case byteena is
				when "1000" =>
					ram_we_byte_0 <= '1';
				when "0100" =>
					ram_we_byte_1 <= '1';
				when "0010" =>
					ram_we_byte_2 <= '1';
				when "0001" =>
					ram_we_byte_3 <= '1';
				when "1100" =>
					ram_we_byte_0 <= '1';
					ram_we_byte_1 <= '1';
				when "0011" => 
					ram_we_byte_2 <= '1';
					ram_we_byte_3 <= '1';
				when "1111" =>
					ram_we_byte_0 <= '1';
					ram_we_byte_1 <= '1';
					ram_we_byte_2 <= '1';
					ram_we_byte_3 <= '1';
				when others =>
			end case;	
		end if;

		if rd_reg then
			data_out <= data_temp_out;
		end if;

	end process;
end architecture;
