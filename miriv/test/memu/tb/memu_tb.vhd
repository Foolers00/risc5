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

entity memu_tb is
end memu_tb;

architecture sim of memu_tb is

    component memu is
        port (
            -- to mem
            op   : in  memu_op_type;
            A    : in  data_type;
            W    : in  data_type;
            R    : out data_type := (others => '0');

            B    : out std_logic := '0';
            XL   : out std_logic := '0';
            XS   : out std_logic := '0';

            -- to memory controller
            D    : in  mem_in_type;
            M    : out mem_out_type := MEM_OUT_NOP
	    );
    end component;

    signal op : memu_op_type;
    signal A : data_type;
    signal W : data_type;
    signal R : data_type;
    signal B : std_logic;
    signal XL : std_logic;
    signal XS : std_logic;
    signal D : mem_in_type;
    signal M : mem_out_type;


    signal start_stimulus : boolean := true;
    signal start_output : boolean := true;

    file input_file : text;
    file output_ref_file : text;
    
    type input_t is
        record
            A    : data_type;
            W    : data_type;
            D    : mem_in_type;
        end record;

    signal inp : input_t;

    impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
        result.W := bin_to_slv(l.all, DATA_WIDTH);
        
        l := get_next_valid_line(f);
        result.D.busy := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
		result.D.rddata := bin_to_slv(l.all, DATA_WIDTH);

		return result;
    end function;
    

    type output_t is
        record
            R    : data_type;
            B    : std_logic;
            XL   : std_logic;
            XS   : std_logic;
            M    : mem_out_type;
        end record;
    
    signal outp : output_t; 

    impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
        result.R := bin_to_slv(l.all, DATA_WIDTH);
        
        l := get_next_valid_line(f);
        result.B := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
        result.XL := str_to_sl(l(1));
        
        l := get_next_valid_line(f);
		result.XS := str_to_sl(l(1));

		l := get_next_valid_line(f);
        result.M.address := bin_to_slv(l.all, ADDR_WIDTH);

        l := get_next_valid_line(f);
        result.M.rd := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.M.wr := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.M.byteena:= bin_to_slv(l.all, BYTEEN_WIDTH);

        l := get_next_valid_line(f);
        result.M.wrdata := bin_to_slv(l.all, DATA_WIDTH);
        
		return result;
    end function;

    
    procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if passed then
            report " PASSED: "
            & "OP.memtype: " & to_string(op.memtype) & " OP.rd: " & to_string(op.memread) & " OP.wr: " & to_string(op.memwrite) & lf
			& " A = "     & to_string(inp.A) & lf
            & " W = "  & to_string(inp.W) & lf
            & " D.busy = "  & to_string(inp.D.busy) & " D.rddata = "  & to_string(inp.D.rddata) & lf
            & "**     outcome:   R =" & to_string(outp.R)   & " B =" & to_string(outp.B) 
            & " XL =" & to_string(outp.XL) &    " XS =" & to_string(outp.XS) 
            & " M.address =" & to_string(outp.M.address) &    " M.rd =" & to_string(outp.M.rd) 
            & " M.wr =" & to_string(outp.M.wr) &    " M.byteena =" & to_string(outp.M.byteena) 
            & " M.wrdata =" & to_string(outp.M.wrdata) & lf             
			severity note;
		else
            report "FAILED: "
            & "OP.memtype: " & to_string(op.memtype) & " OP.rd: " & to_string(op.memread) & " OP.wr: " & to_string(op.memwrite) & lf
			& " A = "     & to_string(inp.A) & lf
            & " W = "  & to_string(inp.W) & lf
            & " D.busy = "  & to_string(inp.D.busy) & " D.rddata = "  & to_string(inp.D.rddata) & lf
            & "**     expected:   R =" & to_string(output_ref.R)   & " B =" & to_string(output_ref.B) 
            & " XL =" & to_string(output_ref.XL) &    " XS =" & to_string(output_ref.XS) 
            & " M.address =" & to_string(output_ref.M.address) &    " M.rd =" & to_string(output_ref.M.rd) 
            & " M.wr =" & to_string(output_ref.M.wr) &    " M.byteena =" & to_string(output_ref.M.byteena) 
            & " M.wrdata =" & to_string(output_ref.M.wrdata) & lf 
            & "**     actual:   R =" & to_string(outp.R)   & " B =" & to_string(outp.B) 
            & " XL =" & to_string(outp.XL) &    " XS =" & to_string(outp.XS) 
            & " M.address =" & to_string(outp.M.address) &    " M.rd =" & to_string(outp.M.rd) 
            & " M.wr =" & to_string(outp.M.wr) &    " M.byteena =" & to_string(outp.M.byteena) 
            & " M.wrdata =" & to_string(outp.M.wrdata) & lf 
            
			severity error;
		end if;
	end procedure;

begin

    memu_inst : memu 
    port map (
        op  => op,
        A   => A,
        W   => W,
        R   => R,
        B   => B,
        XL  => XL,
        XS  => XS,
        D   => D,
        M   => M              
    );

    stimulus : process
    variable fstatus: file_open_status;
    begin
        file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		
        while not endfile(input_file) loop
            start_stimulus <= true;
            inp <= read_next_input(input_file);
            wait for 1 ns;
            A <= inp.A;
            W <= inp.W;
            D <= inp.D;
            op <= MEMU_NOP;
            start_stimulus <= false;
            wait for 1 ns;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_B;
            op.memread <= '1';
            op.memwrite <= '0';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_BU;
            op.memread <= '1';
            op.memwrite <= '0';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_H;
            op.memread <= '1';
            op.memwrite <= '0';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_HU;
            op.memread <= '1';
            op.memwrite <= '0';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_W;
            op.memread <= '1';
            op.memwrite <= '0';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_B;
            op.memread <= '0';
            op.memwrite <= '1';
            D.busy <= '0';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_BU;
            op.memread <= '0';
            op.memwrite <= '1';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_H;
            op.memread <= '0';
            op.memwrite <= '1';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_HU;
            op.memread <= '0';
            op.memwrite <= '1';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op.memtype <= MEM_W;
            op.memread <= '0';
            op.memwrite <= '1';
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 

        end loop; 

        wait;    
    end process;


    output_checker : process
		variable fstatus: file_open_status;
		variable output_ref : output_t;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);


        while not endfile(output_ref_file) loop
            wait until not start_stimulus;
            wait for 1 ns;
            outp.R <= R;
            outp.B <= B;
            outp.XL <= XL;
            outp.XS <= XS;
            outp.M <= M;
            start_output <= true;
            wait for 1 ns;
			output_ref := read_next_output(output_ref_file);
            check_output(output_ref);
            start_output <= false;
            wait for 1 ns;
            
		end loop;		
		wait;
    end process;


   

end architecture;