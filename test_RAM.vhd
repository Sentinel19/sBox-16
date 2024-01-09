--Testbench for Random Access Memory (RAM)
--Adam Dulay
--12/2/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity test_RAM is
end;

architecture test of test_RAM is

component RAM is
	generic (
		addr_size 					: integer := 65536;
		data_width 					: integer := 16;
		filename 					: string := "temp.mif");
	port (
		data_out 					: out std_logic_vector(data_width-1 downto 0);
		data_in 					: in std_logic_vector(data_width-1 downto 0);
		read_addr 					: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		write_addr 					: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		clk 						: in std_logic;
		write_en 					: in std_logic);
end component;

constant addr_size 					: integer := 65536;
constant data_width					: integer := 16;
constant filename 					: string := "RAM.mif";

signal data_out 			: std_logic_vector(data_width-1 downto 0);
signal data_in 				: std_logic_vector(data_width-1 downto 0);
signal r_addr 				: std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
signal w_addr 				: std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
signal clk 					: std_logic := '0';
signal wr_en 				: std_logic := '0';

begin
	
	--testing the memory
	dev_to_test : RAM
		generic map(addr_size, data_width, filename)
		port map(data_out, data_in, r_addr, w_addr, clk, wr_en);

	stimulus : process
	begin

		data_in <= x"ADAD";
		w_addr <= x"0000";
		wr_en <= '1';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';

		for i in 0 to addr_size-1 loop
			r_addr <= std_logic_vector(to_unsigned(i, r_addr'length));

			for j in 0 to 1 loop
				clk <= not clk;
				wait for 10 ns;
			end loop;
		end loop;
		report "Complete! Program Rom Test Completed";
	end process stimulus;
end test;
