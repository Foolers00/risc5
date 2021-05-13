library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity fetch_tb is
end fetch_tb;

architecture sim of fetch_tb is
    
    component fetch is
        port (
            clk        : in  std_logic;
            res_n      : in  std_logic;
            stall      : in  std_logic;
            flush      : in  std_logic;

            -- to control
            mem_busy   : out std_logic;

            pcsrc      : in  std_logic;
            pc_in      : in  pc_type;
            pc_out     : out pc_type := (others => '0');
            instr      : out instr_type;

            -- memory controller interface
            mem_out   : out mem_out_type;
            mem_in    : in  mem_in_type
	    );
    end component;

    signal clk : std_logic;
    signal res_n : std_logic;
    signal stop_clk : boolean;
    constant CLK_PERIOD : time := 20 ns;

    signal stall : std_logic := '0';
    signal flush : std_logic := '0';
    signal mem_busy : std_logic;
    signal pcsrc : std_logic := '0';
    signal pc_in : pc_type := (others => '0');
    signal pc_out : pc_type;
    signal instr : instr_type;

    signal mem_out : mem_out_type;
    signal mem_in : mem_in_type := MEM_IN_NOP;

    
    

begin

    fetch_inst : fetch
    port map (
        clk         => clk,
        res_n       => res_n,
        stall       => stall,
        flush       => flush,
        mem_busy    => mem_busy,
        pcsrc       => pcsrc,
        pc_in       => pc_in,
        pc_out      => pc_out,
        instr       => instr,
        mem_out     => mem_out,
        mem_in      => mem_in    
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
        pcsrc <= '1';
        wait until rising_edge(clk);
        pcsrc <= '0';
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