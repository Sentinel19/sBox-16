-- Testbench for Stack Pointer
-- Modeled after "test_P_load" from ECE 501
-- 10/11/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;



entity test_stack_pointer is
end;

architecture test of test_stack_pointer is

component stack_pointer
	generic (
		data_width 		: integer := 16);
	port (
		pointer_out 	: out std_logic_vector(data_width-1 downto 0);
		set_in			: in std_logic_vector(data_width-1 downto 0);
		set 			: in std_logic;
		reset 			: in std_logic;
		clk 			: in std_logic);
end component;

constant data_width 		: integer := 16;
signal set_in 				: std_logic_vector(data_width-1 downto 0);
signal pointer_out 			: std_logic_vector(data_width-1 downto 0);
signal set					: std_logic := '0';
signal reset 				: std_logic := '0';
signal clk 					: std_logic := '0';

-- filepaths in case testing with file I/O is required
--file PC_input 				: string := "PC_input.txt"; 
--file PC_output 				: string := "PC_output.txt";

begin
	-- declare the device under test and define generic and port maps
	dev_to_test : stack_pointer
		generic map(data_width)
		port map(pointer_out, set_in, set, reset, clk);

	stimulus : process
	variable ErrCnt : integer := 0;
	begin
		-- reset contents to 0x0000
		reset <= '1';
		wait for 10 ns;
		reset <= '0';
		set_in <= x"ADAD"; -- using my initials for testing

		-- testing the non-setting case
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
		if(pointer_out /= x"0000") then
			ErrCnt := ErrCnt + 1;
		end if;

		-- testing the setting case
		clk <= '1';
		set <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
		if(pointer_out /= x"ADAD") then
			ErrCnt := ErrCnt + 1;
		end if;

		-- checking for errors
		if(ErrCnt = 0) then
			report "SUCCESS!! STACK POINTER TEST COMPLETED";
		else 
			report "The stack pointer device is broken" severity error;
		end if;

	end process stimulus;
end test;
	


