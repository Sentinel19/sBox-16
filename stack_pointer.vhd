-- Stack Pointer
-- Modeled after "p_load_2 from ECE 501"
-- Adam Dulay
-- 10/11/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity stack_pointer is
	port (
		pointer_out 	: out std_logic_vector(15 downto 0);
		set_in			: in std_logic_vector(15 downto 0);
		set 			: in std_logic;
		reset 			: in std_logic;
		clk 			: in std_logic);
end stack_pointer;

architecture behavior of stack_pointer is
signal contents 		: std_logic_vector(15 downto 0) := x"0000"; -- this initializes it to 0x0000 on instantiation
begin

	-- using a temp signal that is always assigned to the output
	pointer_out <= contents;

	-- simple one synchronous process to handle everything
	sp_proc : process(clk)
	begin
		if(reset = '1') then
			contents <= (others => '0');
		elsif(rising_edge(clk)) then -- makes it synchronous
			if(set = '1') then
				contents <= set_in;
			end if;
		end if;
	end process sp_proc;
end behavior;
		

