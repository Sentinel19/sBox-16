-- Testbench for Program Counter
-- Modeled after "test_P_load" from ECE 501
-- 10/9/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.sim_mem_init.all;

entity test_program_counter is
end;

architecture test of test_program_counter is

component program_counter
	generic (
		data_width 			: integer := 16);
	port (
		address_out 		: out std_logic_vector(data_width-1 downto 0);
		address_in 			: in std_logic_vector(data_width-1 downto 0);
		opcode				: in std_logic_vector(1 downto 0);
		clk 				: in std_logic);
end component;

constant data_width 		: integer := 16;
signal address_in 			: std_logic_vector(data_width-1 downto 0);
signal address_out 			: std_logic_vector(data_width-1 downto 0);
signal opcode				: std_logic_vector(1 downto 0);
signal clk 					: std_logic := '0';

-- filepaths in case testing with file I/O is required
--file PC_input 				: string := "PC_input.txt"; 
--file PC_output 				: string := "PC_output.txt";

begin
	-- declare the device under test and define generic and port maps
	dev_to_test : program_counter
		generic map(data_width)
		port map(address_out, address_in, opcode, clk);

	stimulus : process
	variable ErrCnt : integer := 0;
	begin
		address_in <= x"ADAD"; -- testing it with my initials
		opcode <= "11";
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
	-- test inputting values
		-- testing trying to input without propper opcode
		for i in 0 to 15 loop -- looping through opcodes to check jump/branch capibilities
			case i is
				when 13 => -- branch instruction case
					opcode <= "10";
				when 14 => -- jump instruction case
					opcode <= "10";
				when 15 => -- no-op instruction case
					opcode <= "00";
				when others => -- all other instructions case (incriment)
					opcode <= "01";
				end case;
			wait for 10 ns;
			clk <= '1';
			wait for 10 ns;
			clk <= '0';
			if(i = 13 or i = 14 or i = 15) then -- checking to see if it loads addresses or halts
				if(address_out /= x"ADAD") then
					ErrCnt := ErrCnt + 1;
				end if;
			end if;
		end loop; -- i

		-- checking for errors
		if(ErrCnt = 0) then
			report "SUCCESS!! PROGRAM COUNTER TEST COMPLETED";
		else 
			report "The program counter device is broken" severity error;
		end if;

	end process stimulus;
end test;
	


