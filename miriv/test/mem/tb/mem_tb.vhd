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

entity mem_tb is
end mem_tb;

architecture sim of mem_tb is

    component mem is
        port (
            clk           : in  std_logic;
            res_n         : in  std_logic;
            stall         : in  std_logic;
            flush         : in  std_logic;
            mem_busy      : out std_logic;
            mem_op        : in  mem_op_type;
            wbop_in       : in  wb_op_type;
            pc_new_in     : in  pc_type;
            pc_old_in     : in  pc_type;
            aluresult_in  : in  data_type;
            wrdata        : in  data_type;
            zero          : in  std_logic;
            reg_write     : out reg_write_type;
            pc_new_out    : out pc_type;
            pcsrc         : out std_logic;
            wbop_out      : out wb_op_type;
            pc_old_out    : out pc_type;
            aluresult_out : out data_type;
            memresult     : out data_type;
            mem_out       : out mem_out_type;
            mem_in        : in  mem_in_type;
            exc_load      : out std_logic;
            exc_store     : out std_logic
	    );
    end component;

    signal clk : std_logic;
    signal res_n : std_logic;
    signal stop_clk : boolean;
    constant CLK_PERIOD : time := 20 ns;

    signal stall : std_logic := '0';
    signal flush : std_logic := '0';
    signal mem_busy : std_logic;
    signal mem_op : mem_op_type := MEM_NOP;
    signal wbop_in : wb_op_type := WB_NOP;
    signal pc_new_in : pc_type := (0 => '1', others => '0');
    signal pc_old_in : pc_type := ZERO_PC;
    signal aluresult_in : data_type := ZERO_DATA;
    signal wrdata : data_type := ZERO_DATA;
    signal zero : std_logic := '0';
    signal reg_write : reg_write_type;
    signal pc_new_out : pc_type;
    signal pcsrc : std_logic;
    signal wbop_out : wb_op_type;
    signal pc_old_out : pc_type;
    signal aluresult_out : data_type;
    signal memresult : data_type;
    signal mem_out : mem_out_type;
    signal mem_in : mem_in_type := MEM_IN_NOP;
    signal exc_load : std_logic;
    signal exc_store : std_logic;        
   

begin

    mem_inst : mem 
    port map (
        clk             => clk,
        res_n           => res_n,
        stall           => stall,
        flush           => flush,    
        mem_busy        => mem_busy,
        mem_op          => mem_op,
        wbop_in         => wbop_in,
        pc_new_in       => pc_new_in,
        pc_old_in       => pc_old_in,
        aluresult_in    => aluresult_in,
        wrdata          => wrdata,
        zero            => zero,    
        reg_write       => reg_write,
        pc_new_out      => pc_new_out,    
        pcsrc           => pcsrc,
        wbop_out        => wbop_out,
        pc_old_out      => pc_old_out,
        aluresult_out   => aluresult_out,
        memresult       => memresult,
        mem_out         => mem_out,
        mem_in          => mem_in,
        exc_load        => exc_load,
        exc_store       => exc_store            
    );

    stimulus : process
    begin
        res_n <= '0';
        wait for 5*CLK_PERIOD;
        res_n <= '1';
        wait for 500 ns;
        mem_op.mem.memread <= '1';
        mem_op.mem.memtype <= MEM_B; 
        wait for 500 ns;
        flush <= '1';
        wait until rising_edge(clk);
        flush <= '0';
        wait for 500 ns;
        stall <= '1';
        wait until rising_edge(clk);
        stall <= '0';
        wait for 500 ns;
        mem_op.branch <= BR_BR;
        wait until rising_edge(clk);
        mem_op.branch <= BR_NOP;
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