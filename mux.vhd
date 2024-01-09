--2 Way (15-bit) Multiplexor to control where ALU operand comes from (it is also a register for functionality... not very good for performance :( )
--Adam Dulay
--12/7/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity mux is
	port(
		data_out 	: out std_logic_vector(15 downto 0);
		inA 		: in std_logic_vector(15 downto 0);
		inB 		: in std_logic_vector(15 downto 0);
		sel 		: in std_logic;
		clk 		: in std_logic);
end mux;

architecture behav of mux is
begin
	mux_proc : process(clk) -- asynch mux process
	begin
		if(rising_edge(clk)) then
			case sel is
				when '0' =>
					data_out <= inA;
				when '1' =>
					data_out <= inB;
				when others =>
					data_out <= (others => 'X');
			end case;
		end if;
	end process mux_proc;	
end behav;