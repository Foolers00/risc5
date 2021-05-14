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

entity exec_tb is
end exec_tb;

architecture sim of exec_tb is

    component exec is
        port (
            clk           : in  std_logic;
            res_n         : in  std_logic;
            stall         : in  std_logic;
            flush         : in  std_logic;
            op            : in  exec_op_type;
            pc_in         : in  pc_type;
            pc_old_out    : out pc_type;
            pc_new_out    : out pc_type;
            aluresult     : out data_type;
            wrdata        : out data_type;
            zero          : out std_logic;
            memop_in      : in  mem_op_type;
            memop_out     : out mem_op_type;
            wbop_in       : in  wb_op_type;
            wbop_out      : out wb_op_type;
            exec_op       : out exec_op_type;
            reg_write_mem : in  reg_write_type;
            reg_write_wr  : in  reg_write_type
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
    signal memop_in : mem_op_type := MEM_NOP;
    signal memop_out : mem_op_type;
    signal wbop_in : wb_op_type := WB_NOP;
    signal wbop_out : wb_op_type := WB_NOP;
    signal op : exec_op_type := EXEC_NOP;
    signal pc_in : pc_type := (others => '0');
    signal pc_old_out : pc_type;
    signal pc_new_out : pc_type;
    signal aluresult : data_type;
    signal wrdata : data_type;
    signal zero : std_logic;

    signal reg_write_mem : reg_write_type := REG_WRITE_NOP;
    signal reg_write_wr : reg_write_type := REG_WRITE_NOP;

   
   

begin

    exec_inst : exec 
    port map (
        clk             => clk,
        res_n           => res_n,
        stall           => stall,
        flush           => flush,
        op              => op,
        pc_in           => pc_in,
        pc_old_out      => pc_old_out,
        pc_new_out      => pc_new_out,
        aluresult       => aluresult,
        wrdata          => wrdata,
        zero            => zero,
        memop_in        => memop_in,
        memop_out       => memop_out,
        wbop_in         => wbop_in,
        wbop_out        => wbop_out,
        exec_op         => open,
        reg_write_mem   => reg_write_mem,
        reg_write_wr    => reg_write_wr       
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