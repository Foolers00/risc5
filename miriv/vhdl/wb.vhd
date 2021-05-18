library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity wb is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from MEM
		op         : in  wb_op_type;
		aluresult  : in  data_type;
		memresult  : in  data_type;
		pc_old_in  : in  pc_type;

		-- to FWD and DEC
		reg_write  : out reg_write_type
	);
end entity;

architecture rtl of wb is

	constant REG_WRITE_NOP : reg_write_type := (
		write => '0',
		reg => ZERO_REG,
		data => ZERO_DATA
	);

	signal op_reg, op_reg_next : wb_op_type;
	signal aluresult_reg, aluresult_reg_next : data_type;
	signal memresult_reg, memresult_reg_next : data_type;
	signal pc_old_in_reg, pc_old_in_reg_next : pc_type;

begin

	sync : process (clk, res_n)
	begin
		if not res_n then
			op_reg <= WB_NOP;
			aluresult_reg <= ZERO_DATA;
			memresult_reg <= ZERO_DATA;
			pc_old_in_reg <= ZERO_PC;

		elsif rising_edge(clk) then
			op_reg <= op_reg_next;
			aluresult_reg <= aluresult_reg_next;
			memresult_reg <= memresult_reg_next;
			pc_old_in_reg <= pc_old_in_reg_next;
		end if;
	end process;

	wb_reg : process (all)
	begin
		-- New Register Input
		op_reg_next <= op;
		aluresult_reg_next <= aluresult;
		memresult_reg_next <= memresult;
		pc_old_in_reg_next <= pc_old_in;

		

		if flush then
			reg_write <= REG_WRITE_NOP;
		else

			-- Output
			reg_write.reg <= op_reg.rd;
			reg_write.write <= op_reg.write; 
			case op_reg.src is
				when WBS_ALU =>
					reg_write.data <= aluresult_reg;
				when WBS_MEM =>
					reg_write.data <= memresult_reg;
				when WBS_OPC =>
					reg_write.data <= to_data_type(pc => pc_old_in_reg);
			end case;
		
		end if;

		-- Old Register Input
		if stall then
			op_reg_next <= op_reg;
			aluresult_reg_next <= aluresult_reg;
			memresult_reg_next <= memresult_reg;
			pc_old_in_reg_next <= pc_old_in_reg;
		end if;

	end process;

end architecture;
