-- Program Counter
-- Modeled after "p_load_2" from ECE 501
-- Adam Dulay
-- 10/7/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity program_counter is
	port (
		address_out 		: out std_logic_vector(15 downto 0);
		address_in 			: in std_logic_vector(15 downto 0);
		fsm_in 				: in std_logic_vector(15 downto 0);
		opcode				: in std_logic_vector(1 downto 0);
		rst 				: in std_logic;
		clk 				: in std_logic);
end program_counter;

architecture behavior of program_counter is
signal count 		: std_logic_vector(15 downto 0) := x"0000";
begin
	
	-- using a temp signal that is always assigned to the output
	address_out <= count;

	-- one process handles all four cases (no-op, incriment, jump/branch, and reset)
	pc_proc : process(clk, rst)
	begin
		if(rst = '1') then -- asynch reset
			count <= (others => '0');
		elsif(rising_edge(clk)) then
			case opcode is
				when "00" => -- for branch (gets branch address from control logic to save clock cycles)
					count <= fsm_in;
				when "01" => -- incriments PC by 1 to advance to next instruction
					count <= std_logic_vector(unsigned(count) + 1);
				when "10" => -- jump/branch instruction (sets value from input)
					count <= address_in;
				when others =>
					-- do nothing
			end case;
		end if;

	end process pc_proc;
end behavior;