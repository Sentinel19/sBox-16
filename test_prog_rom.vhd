--Testbench for Program Memory (ROM)
--Adam Dulay
--11/22/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity test_prog_rom is
end;

architecture test of test_prog_rom is

component program_rom is
	generic (
		addr_size 				: integer := 65536; -- 2^16
		data_width 				: integer := 16; -- 16-bits per address
		filename 				: string := "temp.mif");
	port (
		data_out 					: out std_logic_vector(data_width-1 downto 0);
		--data_in 					: in std_logic_vector(data_width-1 downto 0); -- don't need this for ROM
		read_addr 					: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		--write_addr 					: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0); -- don't need this for ROM
		clk 						: in std_logic);
		--write_en 					: in std_logic); -- don't need this for ROM
end component;

constant addr_size 					: integer := 65536;
constant data_width					: integer := 16;
constant filename 					: string := "prog_rom.mif";


signal data_out 			: std_logic_vector(data_width-1 downto 0);
signal addr 				: std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
signal clk 					: std_logic := '0';


begin 
	
	--testing the memory
	dev_to_test : program_rom
		generic map(addr_size, data_width, filename)
		port map(data_out, addr, clk);

	stimulus : process
	begin

		for i in 0 to addr_size-1 loop
			addr <= std_logic_vector(to_unsigned(i, addr'length));

			for j in 0 to 1 loop
				clk <= not clk;
				wait for 10 ns;
			end loop;
		end loop;
		report "Complete! Program Rom Test Completed";
	end process stimulus;
end test;