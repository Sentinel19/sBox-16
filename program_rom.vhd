--Program Memory (ROM) Adapted from "memory_2.vhd" from ECE 501
--Adam Dulay
--11/22/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;
use work.sim_mem_init_16.all;

entity program_rom is
	generic (
		addr_size 				: integer := 65536; -- 2^16
		data_width 				: integer := 16; -- 16-bits per address
		filename 				: string := "temp.mif");
	port (
		data_out 					: out std_logic_vector(data_width-1 downto 0);
		--data_in 					: in std_logic_vector(data_width-1 downto 0); -- don't need this for ROM
		read_addr 					: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		--write_addr 					: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0); -- don't need this for ROM
		clk 						: in std_logic);
		--write_en 					: in std_logic); -- don't need this for ROM
end program_rom;

architecture behavior of program_rom is

-- the following is used to intitialize the memory in simulation
signal Mem 							: MemType(0 to addr_size-1) := init_quartus_mem_16bit(filename, addr_size-1);
-- the following lines are used to initialize the memory in synthesis
attribute ram_init_file 			: string;
attribute ram_init_file of Mem 		: signal is filename;

begin
	
	-- Define the memry structure
	--mem_write : process(clk)
	--begin
	--	if(rising_edge(clk)) then
	--		if(write_en = '1') then
	--			Mem(to_integer(unsigned(write_addr))) <= data_in;
	--		end if;
	--	end if;
	--end process mem_write;

	mem_read : process(clk)
	begin
		if(rising_edge(clk)) then
			data_out <= Mem(to_integer(unsigned(read_addr)));
		end if;
	end process mem_read;
end behavior;