-- Generic 16-bit register for various purposes
-- Modeled after "p_load_2 from ECE 501"
-- Adam Dulay
-- 9/26/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity reg is
	port(
		data_out 			: out std_logic_vector(15 downto 0);
		data_in 			: in std_logic_vector(15 downto 0);
		load 				: in std_logic; -- write enable
		reset 				: in std_logic; -- async reset
		clk					: in std_logic);
end reg;

architecture behavior of reg is

signal data_reg				: std_logic_vector(15 downto 0);

begin
	-- using a temp signal that always is assigned to the output
	data_out <= data_reg;

	-- one process handles synchronous setting as well as asynchronous reset
	reg_proc : process(clk, reset)
	begin
		if(reset = '1') then
			data_reg <= (others => '0');
		elsif(rising_edge(clk)) then
			if(load = '1') then
				data_reg <= data_in;
			else
				data_reg <= data_reg;
			end if;
		end if;
	end process reg_proc;
end behavior;
