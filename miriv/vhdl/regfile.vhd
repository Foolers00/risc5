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
	signal rdaddr1_reg, rdaddr2_reg : reg_adr_type := ZERO_REG;

begin

	-- enables bypassing and ensures that reads from register x0 always return 0
	-- bypassing: necessary to read registers that are written within the same clk cycle
	output : process(all)
	begin
		if stall = '0' then
			rddata1 <= reg(to_integer(unsigned(rdaddr1_reg)));
			rddata2 <= reg(to_integer(unsigned(rdaddr2_reg)));

			if regwrite = '1' then
				if wraddr = rdaddr1_reg then
					rddata1 <= wrdata;
					if to_integer(unsigned(rdaddr1_reg)) = 0 then
						rddata1 <= (others => '0');
					end if;
				end if;
				if wraddr = rdaddr2_reg then
					rddata2 <= wrdata;
					if to_integer(unsigned(rdaddr2_reg)) = 0 then
						rddata2 <= (others => '0');
					end if;
				end if;
			end if;
		end if;

	end process;

	sync : process(clk, res_n)
	begin
			if (res_n = '0') then
				rdaddr1_reg <= ZERO_REG;
				rdaddr2_reg <= ZERO_REG;
				reg(0) <= (others => '0');

			elsif rising_edge(clk) then
				if stall = '0' then
					rdaddr1_reg <= rdaddr1;
					rdaddr2_reg <= rdaddr2;

					if regwrite = '1' then
						if to_integer(unsigned(wraddr)) /= 0 then -- x0 needs to stay 0
							reg(to_integer(unsigned(wraddr))) <= wrdata;
						end if;
					end if;

				end if;
			end if;
	end process;

end architecture;
