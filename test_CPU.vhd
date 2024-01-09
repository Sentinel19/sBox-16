--CPU Module Testbench
--Adam Dulay
--11/30/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_CPU is
end;

architecture test of test_CPU is

-- declare CPU test entity
component CPU
	port (
		h_digit_three 			: out std_logic_vector(6 downto 0);
		h_digit_two				: out std_logic_vector(6 downto 0);
		h_digit_one 			: out std_logic_vector(6 downto 0);
		h_digit_zero 			: out std_logic_vector(6 downto 0);
		slow_clk 				: out std_logic;
		reset 					: in std_logic;
		go 						: in std_logic; -- to initiate instruction execution
		clock 					: in std_logic);
end component;

-- declare test signals
signal test_rst 		: std_logic := '0';
signal test_go 			: std_logic := '0';
signal test_clk 		: std_logic := '0';
signal test_data 		: std_logic_vector(27 downto 0);
signal test_slow_clk 	: std_logic;

begin
	-- declare port mappings
	dev_to_test : CPU
		port map(test_data(27 downto 21), test_data(20 downto 14), test_data(13 downto 7), test_data(6 downto 0), test_slow_clk, test_rst, test_go, test_clk);

	-- manually drive clock and go signal and see what happens...
	stimulus : process
	begin
		-- reset the whole thing
		test_rst <= '1';
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_rst <= '0';
		test_clk <= '0';
		wait for 10 ns;
		-- send "go" signal
		test_go <= '1';
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		-- everything above is 50 ns
		for i in 0 to 240 loop -- input double the amount of clock cycles as wanted b/c it only toggles once per loop
			test_clk <= not test_clk;
			wait for 10 ns;
		end loop; --i
	end process stimulus;
end test;


