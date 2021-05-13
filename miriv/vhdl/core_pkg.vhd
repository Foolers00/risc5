library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;

package core_pkg is


	-- width of an instruction word
	constant INSTR_WIDTH_BITS : integer := 5;
	constant INSTR_WIDTH      : integer := 2**INSTR_WIDTH_BITS;

	-- size of instruction memory
	constant PC_WIDTH         : integer := ADDR_WIDTH+2;

	-- regfile properties
	constant REG_BITS         : integer := 5;
	constant REG_COUNT        : integer := 2**REG_BITS;

	-- to make things easier, we make CPU data types identical to memory types.
	subtype data_type       is mem_data_type;

	-- types for the interfaces
	subtype pc_type         is std_logic_vector(PC_WIDTH-1 downto 0);
	subtype instr_type      is std_logic_vector(INSTR_WIDTH-1 downto 0);
	subtype reg_adr_type    is std_logic_vector(REG_BITS-1 downto 0);

	-- useful constants
	constant ZERO_REG         : reg_adr_type := (others => '0');
	constant ZERO_DATA        : data_type    := (others => '0');
	constant ZERO_PC          : pc_type      := (others => '0');
	constant NOP_INST         : instr_type   := X"00000013";

	--opcodes
	constant OPC_BITS : integer := 7;
	constant OPC_LUI : std_logic_vector(OPC_BITS - 1 downto 0) := "0110111";
	constant OPC_AUIPC : std_logic_vector(OPC_BITS - 1 downto 0) := "0010111";
	constant OPC_OP : std_logic_vector(OPC_BITS - 1 downto 0) := "0110011";
	constant OPC_OP_IMM : std_logic_vector(OPC_BITS - 1 downto 0) := "0010011";
	constant OPC_JAL : std_logic_vector(OPC_BITS - 1 downto 0) := "1101111";
	constant OPC_JALR : std_logic_vector(OPC_BITS - 1 downto 0) := "1100111";
	constant OPC_BRANCH : std_logic_vector(OPC_BITS - 1 downto 0) := "1100011";
	constant OPC_STORE : std_logic_vector(OPC_BITS - 1 downto 0) := "0100011";
	constant OPC_LOAD : std_logic_vector(OPC_BITS - 1 downto 0) := "0000011";

	pure function to_data_type(pc : pc_type) return data_type;
	pure function to_pc_type(data : data_type) return pc_type;

end package;

package body core_pkg is

	pure function to_data_type(pc : pc_type) return data_type is
	begin
		return std_logic_vector(resize(unsigned(pc), data_type'length));
	end function;

	pure function to_pc_type(data : data_type) return pc_type is
	begin
		return std_logic_vector(resize(unsigned(data), pc_type'length));
	end function;

end package body;
