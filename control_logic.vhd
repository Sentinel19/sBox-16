--Control Logic FSM
--Adam Dulay
--12/2/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity control_logic is
	port (
		-- instruction
		instr 					: in std_logic_vector(15 downto 0);
		strt 					: in std_logic;
		rst 					: in std_logic;
		clk 					: in std_logic;

		-- register file signals
		outaddr 				: out std_logic_vector(2 downto 0);
		reg_areg 				: out std_logic_vector(2 downto 0);
		reg_breg 				: out std_logic_vector(2 downto 0);
		reg_dreg 				: out std_logic_vector(2 downto 0);
		reg_wr_en 				: out std_logic;
		reg_clk 				: out std_logic;
		reg_rst 				: out std_logic;

		-- ALU signals
		alu_op 					: out std_logic_vector(3 downto 0);
		alu_equal_flg 			: in std_logic;
		alu_clk 				: out std_logic;

		-- RAM signals
		ram_wr_en 				: out std_logic;
		ram_clk 				: out std_logic;

		-- program ROM signals
		rom_clk 				: out std_logic;			

		-- program counter signals
		pc_op 					: out std_logic_vector(1 downto 0);
		pc_reset 				: out std_logic;
		pc_clk 					: out std_logic;
		pc_bran_addr 			: out std_logic_vector(15 downto 0);


		-- bus module signals
		bus_addr 				: out std_logic_vector(1 downto 0);
		bus_clk 				: out std_logic;

		-- Operand Mux signals
		mux_sel 				: out std_logic;
		mux_operand 			: out std_logic_vector(15 downto 0);
		mux_clk					: out std_logic);

end control_logic;

architecture behav of control_logic is

-- state machine
-- general states: init (initial state upon startup) and rst_state (reset button state)
-- r-type instructions: fetch -> decode -> accum -> r_mux -> calc -> alu_to_bus -> bus_to_reg -> pc_inc
-- i_type instructions: fetch -> decode -> i_accum -> calc -> alu_to_bus -> bus_to_reg -> pc_inc
-- store instruction: fetch -> decode -> s_accum -> s_calc -> sw_to_bus -> store -> pc_inc
-- load instruction: fetch -> decode -> l_accum -> l_calc -> mem_out -> mem_to_bus -> load -> pc_inc
-- jump instruction: fetch -> decode -> j_accum -> j_calc -> j_alu_to_bus -> bus_to_pc
-- branch instruction: fetch -> decode -> b_accum -> b_mux -> b_calc -> check_eq -> (branch or pc_inc depending on check_eq's result)
-- no-op instruction: fetch -> decode -> pc_inc
type state_type is(init, fetch, decode, pc_inc, accum, calc, rom_to_alu, alu_to_bus,
					 mem_to_bus, bus_to_reg, check_eq, rst_state, i_accum,
					 j_accum, r_mux, j_calc, j_alu_to_bus, bus_to_pc, s_accum, s_calc, sw_to_bus, store,
					 l_accum, l_calc, mem_out, load, b_accum, b_mux, b_calc, branch);
signal state, nxt_state 		: state_type;

signal start_mult_lead 						: std_logic := '0';
signal start_mult_follow 					: std_logic := '0';
signal start 								: std_logic := '0';

begin
	
	-- edge detection circuitry (copied directly from bmult)
	-- start_count = '1' on the rising edge of the start input
	start <= start_mult_lead and (not start_mult_follow);
	start_mult_proc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '1') then
				start_mult_lead <= '0';
				start_mult_follow <= '0';
			else
				start_mult_lead <= strt;
				start_mult_follow <= start_mult_lead;
			end if;
		end if;
	end process start_mult_proc;

	-- 2 process state machine
	state_proc : process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '1') then
				state <= rst_state;
			else
				state <= nxt_state;
			end if;
		end if;
	end process state_proc;

	state_machine_proc : process(state, strt, start, instr, alu_equal_flg)
	begin
		-- re-initialize variable each time around so case statement can update them
		nxt_state <= state;

		-- register file signals
		outaddr <= (others => 'X');
		reg_areg <= (others => 'X');
		reg_breg <= (others => 'X');
		reg_dreg <= (others => 'X');
		reg_wr_en <= '0';
		reg_clk <= '0';
		reg_rst <= '0';

		-- alu signals
		alu_op <= (others => 'X');
		alu_clk <= '0';

		-- RAM signals
		ram_wr_en <= '0';
		ram_clk <= '0';

		-- ROM signals
		rom_clk <= '0';

		-- program counter signals
		pc_op <= (others => 'X');
		pc_reset <= '0';
		pc_clk <= '0';
		pc_bran_addr <= (others => 'X');


		-- bus module signals
		bus_addr <= (others => 'X');
		bus_clk <= '0';

		-- mux module signal
		mux_sel <= '0';
		mux_operand <= (others => 'X');
		mux_clk <= '0';

		case state is
			when init =>
				if(start = '1') then
					nxt_state <= fetch;
				end if;
			when fetch =>
				rom_clk <= '1';
				nxt_state <= decode;
			when decode =>
				case instr(15 downto 12) is -- case statement to check instruction opcodes
					when x"0" => -- add
						nxt_state <= accum;
					when x"1" => -- subtract
						nxt_state <= accum;
					when x"2" => -- multiply
						nxt_state <= accum;
					when x"3" => -- divide
						nxt_state <= accum;
					when x"4" => -- shift right
						nxt_state <= i_accum;
					when x"5" => -- shift left
						nxt_state <= i_accum;
					when x"6" => -- and
						nxt_state <= accum;
					when x"7" => -- or
						nxt_state <= accum;
					when x"8" => -- add immediate
						nxt_state <= i_accum;
					when x"9" => -- xor
						nxt_state <= accum;
					when x"A" => -- not
						nxt_state <= accum;
					when x"B" => -- store word
						nxt_state <= s_accum;
					when x"C" => -- load word
						nxt_state <= l_accum;
					when x"D" => -- branch
						nxt_state <= b_accum;
					when x"E" => -- jump
						nxt_state <= j_accum;
					when x"F" => -- no operation
						nxt_state <= pc_inc;
					when others =>
						nxt_state <= init;
				end case;
			when accum => -- put operands from register file to ALU
				reg_areg <= instr(8 downto 6);
				reg_breg <= instr(5 downto 3);
				reg_clk <= '1';
				nxt_state <= r_mux;
			when r_mux => -- puts data into the mux (filp-flop)
				mux_sel <= '0'; -- take data from output of register file
				mux_clk <= '1';
				nxt_state <= calc;
			when calc => -- puts opcode to ALU and calculates result
				alu_op <= instr(15 downto 12);
				alu_clk <= '1';
				nxt_state <= alu_to_bus;
			when alu_to_bus =>
				bus_addr <= "01";
				bus_clk <= '1';
				nxt_state <= bus_to_reg;
			when bus_to_reg => -- writes value of bus to destination register
				reg_dreg <= instr(11 downto 9);
				reg_wr_en <= '1';
				reg_clk <= '1';
				nxt_state <= pc_inc;
			when pc_inc => -- incriments the program counter
				pc_op <= "01";
				pc_clk <= '1';
				nxt_state <= fetch;
			when i_accum => -- accumulate state for immediate type instructions
				mux_sel <= '1'; -- change operand to come from memory rather than register file
				mux_operand <= instr(5) & instr(5) & instr(5) & instr(5) & instr(5) & instr(5) & instr(5) & instr(5) & instr(5) & instr(5) & instr(5 downto 0); -- makes "B" operand the immediate from the instruction (signed)
				mux_clk <= '1';
				reg_areg <= instr(8 downto 6);
				reg_clk <= '1';
				nxt_state <= calc;
			when j_accum => -- accumulate state for jump instruction
				mux_sel <= '1';
				mux_operand <= instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8 downto 0); -- adds 9 bit signed immediate to target address to get jump address
				mux_clk <= '1';
				reg_areg <= instr(11 downto 9);
				reg_clk <= '1';
				nxt_state <= j_calc;
			when b_accum =>
				reg_areg <= instr(11 downto 9);
				reg_breg <= instr(8 downto 6);
				reg_clk <= '1';
				nxt_state <= b_mux;
			when b_mux =>
				mux_sel <= '0'; -- take data from output of register file
				mux_clk <= '1';
				nxt_state <= b_calc;
			when b_calc =>
				alu_op <= instr(15 downto 12);
				alu_clk <= '1';
				nxt_state <= check_eq;
			when check_eq => -- checks for equal flag and decides to branch if operands are equal
				if(alu_equal_flg = '1') then
					nxt_state <= branch;
				else
					nxt_state <= pc_inc;
				end if;
			when branch => -- handles branching
				pc_bran_addr <= "0000000000" & instr(5 downto 0);
				pc_op <= "00";
				pc_clk <= '1';
				nxt_state <= fetch;
			when j_calc => -- calculates jump address
				alu_op <= instr(15 downto 12);
				alu_clk <= '1';
				nxt_state <= j_alu_to_bus;
			when j_alu_to_bus => -- outputs jump address from ALU onto bus
				bus_addr <= "01";
				bus_clk <= '1';
				nxt_state <= bus_to_pc;
			when bus_to_pc => -- updates program counter with bus contents
				pc_op <= "10";
				pc_clk <= '1';
				nxt_state <= fetch;
			when s_accum => -- accumulates operands to calculate store mem address
				mux_sel <= '1'; -- change operand to come from memory rather than register file
				mux_operand <= instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8 downto 0); -- makes "B" operand the immediate from the instruction (signed)
				mux_clk <= '1';
				reg_areg <= "110";
				reg_clk <= '1';
				nxt_state <= s_calc;
			when s_calc => -- calculates store address (SP + offset)
				alu_op <= instr(15 downto 12);
				alu_clk <= '1';
				nxt_state <= sw_to_bus;
			when sw_to_bus =>
				outaddr <= instr(11 downto 9);
				reg_clk <= '1';
				nxt_state <= store;
			when store => -- stores contents of bus to RAM at address indicated by ALU result
				ram_wr_en <= '1';
				ram_clk <= '1';
				nxt_state <= pc_inc;
			when l_accum => -- accumulates operands to calculate load mem address
				mux_sel <= '1';
				mux_operand <= instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8) & instr(8 downto 0);
				mux_clk <= '1';
				reg_areg <= "110";
				reg_clk <= '1';
				nxt_state <= l_calc;
			when l_calc => -- calculates load address (SP + offset)
				alu_op <= instr(15 downto 12);
				alu_clk <= '1';
				nxt_state <= mem_out;
			when mem_out=> -- need to get mem output ready to go to bus
				ram_clk <= '1';
				nxt_state <= mem_to_bus;
			when mem_to_bus => -- places mem output contents onto bus
				bus_addr <= "10";
				bus_clk <= '1';
				nxt_state <= load;
			when load => -- loads bus mem contents into dest register
				reg_dreg <= instr(11 downto 9);
				reg_wr_en <= '1';
				reg_clk <= '1';
				nxt_state <= pc_inc;
			when rst_state =>
				reg_rst <= '1';
				pc_reset <= '1';
				nxt_state <= init;
			when others =>
				nxt_state <= init;
		end case;
	end process state_machine_proc;
end behav;
				
