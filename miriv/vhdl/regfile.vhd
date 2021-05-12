library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;

entity regfile is
	port (
		clk              : in  std_logic;
		res_n            : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  reg_adr_type;
		rddata1, rddata2 : out data_type;
		wraddr           : in  reg_adr_type;
		wrdata           : in  data_type;
		regwrite         : in  std_logic
	);
end entity;

architecture rtl of regfile is

	type reg_type is array (0 to (2 ** REG_BITS) - 1) of data_type;
	signal reg : reg_type := (others => (others => '0'));
	signal rddata1_reg, rddata2_reg : data_type;

begin

	-- enables bypassing and ensures that reads from register x0 always return 0
	-- bypassing: necessary to read registers that are written within the same clk cycle
	detect_bypassing_and_x0_reads : process(all)
	begin
			rddata1 <= rddata1_reg;
			rddata2 <= rddata2_reg;

			if regwrite = '1' and stall = '0' then
				if rdaddr1 = wraddr then
					rddata1 <= wrdata;
				end if;

				if rdaddr2 = wraddr then
					rddata2 <= wrdata;
				end if;
			end if;

			if to_integer(unsigned(rdaddr1)) = 0 then
				rddata1 <= (others => '0');
			end if;
			if to_integer(unsigned(rdaddr2)) = 0 then
				rddata2 <= (others => '0');
			end if;

	end process;

	sync : process(clk, res_n)
	begin
			if (res_n = '0') then
				rddata1_reg <= (others => '0');
				rddata2_reg <= (others => '0');

			elsif rising_edge(clk) then

				rddata1_reg <= reg(to_integer(unsigned(rdaddr1)));
				rddata2_reg <= reg(to_integer(unsigned(rdaddr2)));

				if regwrite = '1' and stall = '0' then
					reg(to_integer(unsigned(wraddr))) <= wrdata;
				end if;

			end if;
	end process;

end architecture;
