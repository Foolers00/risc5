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
	output : process(all)
	begin
			rddata1 <= rddata1_reg;
			rddata2 <= rddata2_reg;

	end process;

	sync : process(clk, res_n)
	begin
			if (res_n = '0') then
				rddata1_reg <= (others => '0');
				rddata2_reg <= (others => '0');
				reg(0) <= (others => '0');

			elsif rising_edge(clk) then
				if stall = '0' then
					rddata1_reg <= reg(to_integer(unsigned(rdaddr1)));
					rddata2_reg <= reg(to_integer(unsigned(rdaddr2)));

					if regwrite = '1' then
						if to_integer(unsigned(wraddr)) /= 0 then -- x0 needs to stay 0
							reg(to_integer(unsigned(wraddr))) <= wrdata;
						end if;
						-- set output registers immediatly to new values when a bypass ocurrs
						-- to make sure the output registers contain their value even if the address changes with next rising edge
						if wraddr = rdaddr1 then
							rddata1_reg <= wrdata;
							if to_integer(unsigned(rdaddr1)) = 0 then
								rddata1_reg <= (others => '0');
							end if;
						end if;
						if wraddr = rdaddr2 then
							rddata2_reg <= wrdata;
							if to_integer(unsigned(rdaddr2)) = 0 then
								rddata2_reg <= (others => '0');
							end if;
						end if;
					end if;
				end if;
			end if;
	end process;

end architecture;
