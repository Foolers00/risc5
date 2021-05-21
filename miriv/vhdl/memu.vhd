library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
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
end entity;

architecture rtl of memu is
begin

	memu_process : process (all)
		variable byte_address : std_logic_vector(1 downto 0);
		variable sign_extend : std_logic;
	begin

		M <= MEM_OUT_NOP;
		R <= ZERO_DATA;
		XL <= '0';
		XS <= '0';
		byte_address := A(1 downto 0);
		sign_extend := D.rddata(31);

		if D.busy then --should change?
			B <= '1';
		else
			B <= '0';
		end if;

		-- Reading result from memory interface
		case op.memtype is
			when MEM_B | MEM_BU=>
				if op.memtype = MEM_BU then
					sign_extend := '0';
				end if;
				R(31 downto 8) <= (others => sign_extend); 
				case byte_address is
					when "00" =>
						R(7 downto 0) <=  D.rddata(31 downto 24);
					when "01" =>
						R(7 downto 0) <=  D.rddata(23 downto 16);	
					when "10" =>
						R(7 downto 0) <=  D.rddata(15 downto 8);
					when "11" =>
						R(7 downto 0) <=  D.rddata(7 downto 0);
					when others =>
				end case;
			
			when MEM_H | MEM_HU =>
				if op.memtype = MEM_HU then
					sign_extend := '0';
				end if;
				R(31 downto 16) <= (others => sign_extend); 
				case byte_address is
					when "00" | "01" =>
						R(7 downto 0) <=  D.rddata(31 downto 24);
						R(15 downto 8) <=  D.rddata(23 downto 16);
					when "10" | "11" =>
						R(7 downto 0) <=  D.rddata(15 downto 8);
						R(15 downto 8) <=  D.rddata(7 downto 0);
					when others =>
				end case;

			when MEM_W =>
				R(7 downto 0) <= D.rddata(31 downto 24);
				R(15 downto 8) <= D.rddata(23 downto 16);
				R(23 downto 16) <= D.rddata(15 downto 8);
				R(31 downto 24) <= D.rddata(7 downto 0);
		end case;  

		-- setting up the output signal for memory interface (read)
		if op.memread then
			M.rd <= '1';
			M.address <= A(M.address'length+1 downto 2);
			B <= '1';

			case op.memtype is

				when MEM_H | MEM_HU =>
					case byte_address is
						when "00" | "01" =>
							if byte_address = "01" then
								XL <= '1';
								M.rd <= '0';
								B <= '0';
							end if;
						when "10" | "11" =>
							if byte_address = "11" then
								XL <= '1';
								M.rd <= '0';
								B <= '0';
							end if;
						when others =>
					end case;
	
				when MEM_W =>
					if byte_address /= "00" then
						XL <= '1';
						M.rd <= '0';
						B <= '0';
					end if;
				
				when others =>
			end case;  

		-- setting up the output signal for memory interface (write)
		elsif op.memwrite then
			M.wr <= '1';
			M.address <= A(M.address'length+1 downto 2);

			-- writing data to memory interface
			case op.memtype is
				when MEM_B | MEM_BU =>
					case byte_address is
						when "00" =>
							M.wrdata(31 downto 24) <=  W(7 downto 0);
							M.wrdata(23 downto 0) <= (others => '-');
							M.byteena <= "1000";
						when "01" =>
							M.wrdata(23 downto 16) <=  W(7 downto 0);
							M.wrdata(31 downto 24) <= (others => '-');
							M.wrdata(15 downto 0) <= (others => '-');
							M.byteena <= "0100";
						when "10" =>
							M.wrdata(15 downto 8) <=  W(7 downto 0);
							M.wrdata(31 downto 16) <= (others => '-');
							M.wrdata(7 downto 0) <= (others => '-');
							M.byteena <= "0010";
						when "11" =>
							M.wrdata(7 downto 0) <=  W(7 downto 0);
							M.wrdata(31 downto 8) <= (others => '-');
							M.byteena <= "0001";
						when others =>
					end case;

				when MEM_H | MEM_HU=>
					case byte_address is
						when "00" | "01" =>
							if byte_address = "01" then
								XS <= '1';
								M.wr <= '0';
							end if;
							M.wrdata(31 downto 24) <=  W(7 downto 0);
							M.wrdata(23 downto 16) <=  W(15 downto 8);
							M.wrdata(15 downto 0) <= (others => '-');
							M.byteena <= "1100";
						when "10" | "11"=>
							if byte_address = "11" then
								XS <= '1';
								M.wr <= '0';
							end if;
							M.wrdata(15 downto 8) <=  W(7 downto 0);
							M.wrdata(7 downto 0) <=  W(15 downto 8);
							M.wrdata(31 downto 16) <= (others => '-');
							M.byteena <= "0011";
						when others =>
				end case;
					
				when MEM_W =>
					if byte_address /= "00" then
						XS <= '1';
						M.wr <= '0';
					end if;
					M.wrdata(7 downto 0) <= W(31 downto 24);
					M.wrdata(15 downto 8) <= W(23 downto 16);
					M.wrdata(23 downto 16) <= W(15 downto 8);
					M.wrdata(31 downto 24) <= W(7 downto 0);
			end case;
		end if;

	end process;
end architecture;
