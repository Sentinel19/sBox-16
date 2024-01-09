--Testbench for ALU Module
--Adam Dulay
--11/20/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_ALU is
end;

architecture test of test_ALU is

component ALU is
	port (
		result 				: out std_logic_vector(15 downto 0);
		equal_flag 			: out std_logic;
		op   				: in std_logic_vector(3 downto 0);
		inA 				: in std_logic_vector(15 downto 0);
		inB 				: in std_logic_vector(15 downto 0));
end component;

-- create test signals
signal test_result 			: std_logic_vector(15 downto 0);
signal test_equal_flag	 	: std_logic;
signal test_opcode 			: std_logic_vector(3 downto 0);
signal test_inA 			: std_logic_vector(15 downto 0);
signal test_inB 			: std_logic_vector(15 downto 0);

begin

	dev_to_test : ALU
		port map(test_result, test_equal_flag, test_opcode, test_inA, test_inB);


	stimulus : process
	begin

		for i in 0 to 14 loop
			test_inA <= x"0001";
			test_inB <= x"0001";
			test_opcode <= std_logic_vector(to_unsigned(i, test_opcode'length));

			wait for 10 ns;
		end loop; -- i

		for i in 0 to 14 loop
			test_inA <= x"ADAD";
			test_inB <= x"0001";
			test_opcode <= std_logic_vector(to_unsigned(i, test_opcode'length));

			wait for 10 ns;
		end loop; -- i

		for i in 0 to 14 loop
			test_inA <= x"1002";
			test_inB <= x"0002";
			test_opcode <= std_logic_vector(to_unsigned(i, test_opcode'length));

			wait for 10 ns;
		end loop; -- i
	end process stimulus;

end test;
