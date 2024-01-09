--Testbench for Bus Module
--Adam Dulay
--12/4/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity test_bus_module is
end;

architecture test of test_bus_module is

component bus_module is
	port (
		r_file_in 			: in std_logic_vector(15 downto 0);
		alu_in 				: in std_logic_vector(15 downto 0);
		mem_in 				: in std_logic_vector(15 downto 0);
		in_addr 			: in std_logic_vector(1 downto 0); -- address to determine which input to store
		clk 				: in std_logic;
		data_out 			: out std_logic_vector(15 downto 0));
end component;

signal test_r_file_in 			: std_logic_vector(15 downto 0);
signal test_alu_in 				: std_logic_vector(15 downto 0);
signal test_mem_in 				: std_logic_vector(15 downto 0);
signal test_in_addr 			: std_logic_vector(1 downto 0);
signal test_clk 				: std_logic := '0';
signal test_data_out 			: std_logic_vector(15 downto 0);

begin

	dev_to_test : bus_module
	port map(test_r_file_in, test_alu_in, test_mem_in, test_in_addr, test_clk, test_data_out);

	stimulus : process
	begin

		test_r_file_in <= x"ADAD";
		test_alu_in <= x"ADAE";
		test_mem_in <= x"ADAF";

		test_in_addr <= "00";
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		test_in_addr <= "01";
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		test_in_addr <= "10";
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;				
		test_in_addr <= "11";
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
	end process stimulus;
end test;