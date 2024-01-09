--BUS Circuit (resembling a register for simplicity at the cost of performance)
--Adam Dulay
--12/4/2023

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity bus_module is
	port (
		r_file_in 			: in std_logic_vector(15 downto 0);
		alu_in 				: in std_logic_vector(15 downto 0);
		mem_in 				: in std_logic_vector(15 downto 0);
		in_addr 			: in std_logic_vector(1 downto 0); -- address to determine which input to store
		clk 				: in std_logic;
		data_out 			: out std_logic_vector(15 downto 0));
end bus_module;

architecture behav of bus_module is
signal contents 			: std_logic_vector(15 downto 0);

begin
	
	-- temp signal always set to output just like a in pload.vhd
	data_out <= contents;

	bus_proc : process(clk)
	begin
		if(rising_edge(clk)) then
			case in_addr is
				when "00" => -- register file input
					contents <= r_file_in;
				when "01" => -- ALU input
					contents <= alu_in;
				when "10" => -- RAM input
					contents <= mem_in;
				when others =>
					contents <= (others => 'X');
			end case;
		end if;
	end process bus_proc;
end behav;
