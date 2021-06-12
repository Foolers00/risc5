library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity fwd is
	port (
		-- from Mem
		reg_write_mem : in reg_write_type;

		-- from WB
		reg_write_wb  : in reg_write_type;

		-- from/to EXEC
		reg    : in  reg_adr_type;
		val    : out data_type;
		do_fwd : out std_logic
	);
end entity;

architecture rtl of fwd is
begin

	output : process(all)
	begin
		do_fwd <= '0';
		val <= ZERO_DATA;
		
		--check for forwarding from writeback stage first
		if reg_write_wb.write = '1' and reg_write_wb.reg /= ZERO_REG and reg_write_wb.reg = reg then
			do_fwd <= '1';
			val <= reg_write_wb.data;
		end if;

		-- check for forwarding from mem stage afterwards
		-- ensures that the most recent value of the register is forwared
		if reg_write_mem.write = '1' and reg_write_mem.reg /= ZERO_REG and reg_write_mem.reg = reg then
			do_fwd <= '1';
			val <= reg_write_mem.data;
		end if;

	end process;

end architecture;
