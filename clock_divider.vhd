--Clock Divider Module (for operational visibility on FPGA)
--Adam Dulay
--12/25/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity clock_divider is
	port (
		clk_out 			: out std_logic;
		clk_in 				: in std_logic);
end clock_divider;

architecture behav of clock_divider is

signal slow_clk 							: unsigned(26 downto 0) := (others => '0');
begin
	clk_out <= slow_clk(25);
	-- process to divide clock
	div_clk : process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(slow_clk(26) = '1') then
				slow_clk <= (others => '0');
			else
				slow_clk <= slow_clk + 1;
			end if;
		end if;
	end process div_clk;
end behav;