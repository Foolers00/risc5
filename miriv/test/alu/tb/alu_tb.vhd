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

entity alu_tb is
end alu_tb;

architecture bench of alu_tb is

    component alu is
        port (
            op   : in  alu_op_type;
            A, B : in  data_type;
            R    : out data_type := (others => '0');
            Z    : out std_logic := '0'
	    );
    end component;

    signal op : alu_op_type := ALU_NOP;
    signal A, B : data_type := (others => '0');
    signal R : data_type := (others => '0');
    signal Z : std_logic := '0';

    signal start_stimulus : boolean := true;
    signal start_output : boolean := true;

    file input_file : text;
    file output_ref_file : text;
    
    type input_t is
        record
            A : data_type;
            B : data_type;
        end record;

    signal inp : input_t;

    impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);
		result.B := bin_to_slv(l.all, DATA_WIDTH);

		return result;
    end function;
    

    type output_t is
        record
            R : data_type;
            Z : std_logic;
        end record;
    
    signal outp : output_t; 

    impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.R := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
        result.Z := str_to_sl(l(1));
        
		return result;
    end function;
    
    procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if passed then
            report " PASSED: "
            & "OP: " & to_string(op) & lf
			& " A = "     & to_string(inp.A) & lf
            & " B = "  & to_string(inp.B) & lf
            & "**     outcome:   R =" & to_string(outp.R)       & " Z =" & to_string(outp.Z) & lf             
			severity note;
		else
            report "FAILED: "
            & "OP: " & to_string(op) & lf
			& " A = "     & to_string(inp.A) & lf
			& " B = "  & to_string(inp.B) & lf
			& "**     expected: R =" & to_string(output_ref.R) & " Z =" & to_string(output_ref.Z) & lf
			& "**     actual:   R =" & to_string(outp.R)       & " Z =" & to_string(outp.Z) & lf
			severity error;
		end if;
	end procedure;

begin

   

    alu_inst : alu 
    port map (
        op   => op,
        A    => A,
        B    => B,
        R    => R,
        Z    => Z   
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
            B <= inp.B;
            op <= ALU_NOP;
            start_stimulus <= false;
            wait for 1 ns;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_SLT;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_SLTU;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_SLL;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_SRL;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_SRA;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_ADD;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_SUB;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_AND;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_OR;
            wait for 1 ns;
            start_stimulus <= false;
            wait until not start_output; 
            start_stimulus <= true;
            op <= ALU_XOR;
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
            outp.Z <= Z;
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