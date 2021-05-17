library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;
use work.tb_util_pkg.all;

use ieee.std_logic_textio.all;

library std; -- for Printing
use std.textio.all;

entity decode_tb is
end decode_tb;

architecture sim of decode_tb is

    component decode is
        port (
            clk        : in  std_logic;
            res_n      : in  std_logic;
            stall      : in  std_logic;
            flush      : in  std_logic;
            pc_in      : in  pc_type;
            instr      : in  instr_type;
            reg_write  : in reg_write_type;
            pc_out     : out pc_type;
            exec_op    : out exec_op_type;
            mem_op     : out mem_op_type;
            wb_op      : out wb_op_type;
            exc_dec    : out std_logic
	);
    end component;

    constant REG_WRITE_NOP : reg_write_type := (
		write => '0',
		reg => ZERO_REG,
		data => ZERO_DATA
	);

    signal clk : std_logic;
    signal res_n : std_logic;
    signal stop_clk : boolean;
    constant CLK_PERIOD : time := 20 ns;

    signal stall : std_logic := '0';
    signal flush : std_logic := '0';
    signal mem_op : mem_op_type := MEM_NOP;
    signal wb_op : wb_op_type := WB_NOP;
    signal exec_op : exec_op_type := EXEC_NOP;
    signal pc_in : pc_type := (others => '0');
    signal pc_out : pc_type;
    signal exc_dec : std_logic;
    signal instr : instr_type := NOP_INST;
  

    signal reg_write : reg_write_type := REG_WRITE_NOP;

   
   

begin

    decode_inst : decode 
    port map (
            clk         => clk,
            res_n       => res_n,
            stall       => stall,
            flush       => flush,
            pc_in       => pc_in,
            instr       => instr,
            reg_write   => reg_write,
            pc_out      => pc_out, 
            exec_op     => exec_op,
            mem_op      => mem_op,
            wb_op       => wb_op,
            exc_dec     => exc_dec
    );

    stimulus : process
    begin
        res_n <= '0';
        wait for 5*CLK_PERIOD;
        res_n <= '1';
        wait for 5 us;
        stop_clk <= true;
        wait;
    end process;

    clk_generate : process
    begin
        while not stop_clk loop
            clk <= '0', '1' after CLK_PERIOD/2;
            wait for CLK_PERIOD;
        end loop;
        wait;
    end process;

   

end architecture;