--Testbench for R-type Finite State Machine
--Adam Dulay
--11/28/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity test_rfsm is
end;


architecture test of test_rfsm is

-- declare rfsm comonent
component rfsm
	port (
		start 					: in std_logic;
		instruction 			: in std_logic_vector(15 downto 0);
		reset 					: in std_logic;
		clk 					: in std_logic;
		op 						: out std_logic_vector(3 downto 0);
		areg 					: out std_logic_vector(2 downto 0);
		breg 					: out std_logic_vector(2 downto 0);
		dreg 					: out std_logic_vector(2 downto 0);
		wr_en 					: out std_logic;
		finished 				: out std_logic;
		out_sub_clk 			: out std_logic);
end component;


-- define control signals
signal test_start 				: std_logic := '0';
signal test_instruction 		: std_logic_vector(15 downto 0);
signal test_reset 				: std_logic := '0';
signal test_clk 				: std_logic := '0';
signal test_opcode 				: std_logic_vector(3 downto 0);
signal test_areg 				: std_logic_vector(2 downto 0);
signal test_breg 				: std_logic_vector(2 downto 0);
signal test_dreg 				: std_logic_vector(2 downto 0);
signal test_wr_en 				: std_logic;
signal test_finished 			: std_logic;
signal test_out_sub_clk 		: std_logic;

begin

	-- define device under test and port mappings
	dev_to_test : rfsm
		port map(test_start, test_instruction, test_reset, test_clk, test_opcode, test_areg, test_breg, test_dreg, test_wr_en, test_finished, test_out_sub_clk);

	-- manually driving clock to step through states
	stimulus : process
	begin
		test_instruction <= "0000000001100000"; -- opcode -> "0000", rd -> "000", r1 -> "001", r2 -> "100"
		test_start <= '1';
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
		wait for 10 ns;
		test_clk <= '1';
		wait for 10 ns;
		test_clk <= '0';
	end process stimulus;

end test;