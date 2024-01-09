-- Testbench for "register_file_v2"
-- Adam Dulay
-- 11/23/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_register_file_v2 is
end;

architecture test of test_register_file_v2 is

-- state component to test
component register_file_v2
	port (
		outA 				: out std_logic_vector(15 downto 0);
		outB 				: out std_logic_vector(15 downto 0);
		outSP 				: out std_logic_vector(15 downto 0); -- stack pointer is now a register (for easier programming)
		out_to_bus 			: out std_logic_vector(15 downto 0);
		wr_in 				: in std_logic_vector(15 downto 0);
		wr_en				: in std_logic;
		A_addr 				: in std_logic_vector(2 downto 0);
		B_addr 				: in std_logic_vector(2 downto 0);
		wr_addr 			: in std_logic_vector(2 downto 0);
		otb_addr 			: in std_logic_vector(2 downto 0);
		reset_all 			: in std_logic;
		clk 				: in std_logic);
end component;


-- create test signals
signal test_outA 				: std_logic_vector(15 downto 0);
signal test_outB 				: std_logic_vector(15 downto 0);
signal test_outSP 				: std_logic_vector(15 downto 0);
signal test_out_to_bus 			: std_logic_vector(15 downto 0);
signal test_wr_in 				: std_logic_vector(15 downto 0);
signal test_wr_en				: std_logic;
signal test_A_addr 				: std_logic_vector(2 downto 0);
signal test_B_addr 				: std_logic_vector(2 downto 0);
signal test_wr_addr 			: std_logic_vector(2 downto 0);
signal test_otb_addr 			: std_logic_vector(2 downto 0);
signal test_reset_all 			: std_logic;
signal test_clk 				: std_logic;

begin
		
		dev_to_test : register_file_v2
			port map(test_outA, test_outB, test_outSP, test_out_to_bus, test_wr_in, test_wr_en, test_A_addr, test_B_addr, test_wr_addr, test_otb_addr, test_reset_all, test_clk);

		stimulus : process
		begin
				-- perform global reset and reads all registers to prove it works (and make content values certain)
				test_reset_all <= '0';
				wait for 10 ns;
				test_reset_all <= '1';
				wait for 10 ns;
				test_reset_all <= '0';
				wait for 10 ns;
				-- loop to read contents of all registers
				for i in 0 to 6 loop
					test_clk <= '0';
					wait for 10 ns;
					test_A_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					test_B_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					test_clk <= '1';
					wait for 10 ns;
					test_clk <= '0';
				end loop; --i

				-- write values to all registers and display contents on both A and B outputs
				for i in 0 to 6 loop
					test_clk <= '0';
					wait for 10 ns;
					test_wr_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					test_wr_en <= '1';
					test_wr_in <= std_logic_vector(to_unsigned(i, test_wr_in'length));
					test_clk <= '1';
					wait for 10 ns;
					test_clk <= '1';
					test_A_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					test_B_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					wait for 10 ns;
					test_clk <= '0';
					wait for 10 ns;
					test_clk <= '1';
					wait for 10 ns;
					test_clk <= '0';
				end loop; --i

				-- re-read all register's contents to verify safe storage
				for i in 0 to 6 loop
					test_clk <= '0';
					wait for 10 ns;
					test_A_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					test_B_addr <= std_logic_vector(to_unsigned(i, test_wr_addr'length));
					test_clk <= '1';
					wait for 10 ns;
					test_clk <= '0';
				end loop; --i
		end process stimulus;
end test;
			




