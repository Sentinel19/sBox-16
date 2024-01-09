--Improved Register File
--Adam Dulay
--11/23/23

library IEEE;
use IEEE.STD_Logic_1164.ALL;
use IEEE.numeric_std.all;

entity register_file_v2 is
	port (
		outA 				: out std_logic_vector(15 downto 0);
		outB 				: out std_logic_vector(15 downto 0);
		outSP 				: out std_logic_vector(15 downto 0); -- stack pointer is now a register (for easier programming)
		out_to_bus 			: out std_logic_vector(15 downto 0);
		out_to_disp 		: out std_logic_vector(15 downto 0); -- output to 7 seg displays (4 hex digits)
		wr_in 				: in std_logic_vector(15 downto 0);
		wr_en				: in std_logic;
		A_addr 				: in std_logic_vector(2 downto 0);
		B_addr 				: in std_logic_vector(2 downto 0);
		wr_addr 			: in std_logic_vector(2 downto 0);
		otb_addr 			: in std_logic_vector(2 downto 0);
		reset_all 			: in std_logic;
		clk 				: in std_logic);
end register_file_v2;

architecture behav of register_file_v2 is
	-- design synthesizes with PL registers despite not looking the part
	type reg_file is array(0 to 6) of std_logic_vector(15 downto 0);
	signal regs : reg_file;

begin
	
	-- constantly output stack pointer's value
	outSP <= regs(6);
	-- constantly output display register's value (set to "D" register)
	out_to_disp <= regs(3);
	-- one synchronous process to handle reading/writing
	reg_file_proc : process(clk, reset_all)
	begin
		-- global asynchrounous reset condition
		if(reset_all = '1') then
			-- looks like spaghetti code, but this runs in parallel
			regs(0) <= (others => '0');
			regs(1) <= (others => '0');
			regs(2) <= (others => '0');
			regs(3) <= (others => '0');
			regs(4) <= (others => '0');
			regs(5) <= (others => '0');
			regs(6) <= (others => '0');

			
		-- regular synchronous behavior
		elsif(rising_edge(clk)) then
			-- pass through values on rising edge then deal with writing
			outA <= regs(to_integer(unsigned(A_addr)));
			outB <= regs(to_integer(unsigned(B_addr)));
			out_to_bus <= regs(to_integer(unsigned(otb_addr)));
			if(wr_en = '1') then
				regs(to_integer(unsigned(wr_addr))) <= wr_in;

				-- update outputs to new input so it can be ready ASAP
				if(A_addr = wr_addr) then
					outA <= wr_in;
				elsif(B_addr = wr_addr) then
					outB <= wr_in;
				end if;
			end if;
		end if;
	end process reg_file_proc;
end behav;
