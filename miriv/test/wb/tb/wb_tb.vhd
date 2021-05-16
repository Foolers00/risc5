library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity wb_tb is
end wb_tb;

architecture sim of wb_tb is
    
    component wb is
        port (
            clk        : in  std_logic;
            res_n      : in  std_logic;
            stall      : in  std_logic;
            flush      : in  std_logic;
            op         : in  wb_op_type;
            aluresult  : in  data_type;
            memresult  : in  data_type;
            pc_old_in  : in  pc_type;
            reg_write  : out reg_write_type
	    );
    end component;

    signal clk : std_logic;
    signal res_n : std_logic;
    signal stop_clk : boolean;
    constant CLK_PERIOD : time := 20 ns;

    signal stall : std_logic := '0';
    signal flush : std_logic := '0';
    signal op : wb_op_type := WB_NOP;
    signal aluresult : data_type := ZERO_DATA;
    signal memresult : data_type := ZERO_DATA;
    signal pc_old_in : pc_type := ZERO_PC;
    signal reg_write : reg_write_type;

    
    

begin

    wb_inst : wb
    port map (
        clk         => clk,
        res_n       => res_n,
        stall       => stall,
        flush       => flush,
        op          => op,
        aluresult   => aluresult,
        memresult   => memresult,    
        pc_old_in   => pc_old_in,
        reg_write   => reg_write
    );

    stimulus : process
    begin
        res_n <= '0';
        wait for 5*CLK_PERIOD;
        res_n <= '1';
        wait for 500 ns;
        flush <= '1';
        wait until rising_edge(clk);
        flush <= '0';
        wait for 500 ns;
        stall <= '1';
        wait until rising_edge(clk);
        stall <= '0';
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