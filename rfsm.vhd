--Control Logic of R-Type Instructions
--Adam Dulay
--11/26/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity rfsm is
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
end rfsm;

architecture behav of rfsm is

-- state machine
type state_type is(init, accum, calc, done);
signal state, nxt_state 		: state_type;


begin
	
	-- 2 process state machine
	state_proc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				state <= init;
			else
				state <= nxt_state;
			end if;
		end if;
	end process state_proc;

	state_machine_proc : process(state, start)
	begin
		-- re-initialize variable each time around so case statement can update them
		nxt_state <= state;
		finished <= '0';
		op <= (others => 'X');
		dreg <= (others => 'X');
		areg <= (others => 'X');
		breg <= (others => 'X');
		out_sub_clk <= '0';


		case state is
			when init =>
				if(start = '1') then
					nxt_state <= accum;
				end if;
			when accum =>
				areg <= instruction(8 downto 6);
				breg <= instruction(5 downto 3);
				out_sub_clk <= '1';
				nxt_state <= calc;
			when calc =>
				op <= instruction(15 downto 12);
				nxt_state <= done;
			when done =>
				finished <= '1';
				nxt_state <= init;
		end case;
	end process state_machine_proc;


end behav;