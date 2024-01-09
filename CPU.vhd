--CPU Top File (Connects all sub modules)
--Adam Dulay
--11/29/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

entity CPU is
	port (
		h_digit_three 			: out std_logic_vector(6 downto 0);
		h_digit_two				: out std_logic_vector(6 downto 0);
		h_digit_one 			: out std_logic_vector(6 downto 0);
		h_digit_zero 			: out std_logic_vector(6 downto 0);
		i_digit_three 			: out std_logic_vector(6 downto 0);
		i_digit_two				: out std_logic_vector(6 downto 0);
		i_digit_one 			: out std_logic_vector(6 downto 0);
		i_digit_zero 			: out std_logic_vector(6 downto 0);
		slow_clk 				: out std_logic;
		reset 					: in std_logic;
		go 						: in std_logic; -- to initiate instruction execution
		clock 					: in std_logic);
end CPU;

architecture behav of CPU is 

--COMPONENT DECLARATIONS

-- Register File
component register_file_v2 is
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
end component;

-- ALU
component ALU is
	port (
		result 				: out std_logic_vector(15 downto 0);
		equal_flag 			: out std_logic;
		op   				: in std_logic_vector(3 downto 0);
		inA 				: in std_logic_vector(15 downto 0);
		inB 				: in std_logic_vector(15 downto 0);
		clk 				: in std_logic);
end component;

-- Program Counter
component program_counter is
	port (
		address_out 		: out std_logic_vector(15 downto 0);
		address_in 			: in std_logic_vector(15 downto 0);
		fsm_in 				: in std_logic_vector(15 downto 0);
		opcode				: in std_logic_vector(1 downto 0);
		rst 				: in std_logic;
		clk 				: in std_logic);
end component;

-- Program ROM
component program_rom is
	generic (
		addr_size 				: integer := 65536; -- 2^16
		data_width 				: integer := 16; -- 16-bits per address
		filename 				: string := "temp.mif");
	port (
		data_out 				: out std_logic_vector(data_width-1 downto 0);
		read_addr 				: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		clk 					: in std_logic);
end component;

-- RAM
component RAM is
	generic (
		addr_size 				: integer := 65536;
		data_width 				: integer := 16;
		filename 				: string := "temp.mif");
	port (
		data_out 				: out std_logic_vector(data_width-1 downto 0);
		data_in 				: in std_logic_vector(data_width-1 downto 0);
		read_addr 				: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		write_addr 				: in std_logic_vector(integer(ceil(log2(real(addr_size))))-1 downto 0);
		clk 					: in std_logic;
		write_en 				: in std_logic);
end component;

-- Bus Module
component bus_module is
	port (
		r_file_in 				: in std_logic_vector(15 downto 0);
		alu_in 					: in std_logic_vector(15 downto 0);
		mem_in 					: in std_logic_vector(15 downto 0);
		in_addr 				: in std_logic_vector(1 downto 0);
		clk 					: in std_logic;
		data_out 				: out std_logic_vector(15 downto 0));
end component;

-- ALU Operand Mux
component mux is
	port(
		data_out 	: out std_logic_vector(15 downto 0);
		inA 		: in std_logic_vector(15 downto 0);
		inB 		: in std_logic_vector(15 downto 0);
		sel 		: in std_logic;
		clk 		: in std_logic);
end component;	

-- Control Logic
component control_logic is
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
end component;

-- Seven Segment Display Component
component hex_to_7_seg is
	port (
		seven_seg 					: out std_logic_vector(6 downto 0);
		hex 						: in std_logic_vector(3 downto 0));
end component;

-- Clock Divider
component clock_divider is
	port (
		clk_out 			: out std_logic;
		clk_in 				: in std_logic);
end component;

-- DEFINE CONSTANTS
constant data_width 			: integer := 16;
constant address_size 			: integer := 65536;
constant RAM_file 				: string := "RAM.mif";
constant ROM_file 				: string := "prog_rom.mif";

-- DEFINE INTERNAL SIGNALS

-- divided clock
signal div_clk 					: std_logic;

-- Submodule Interconnects
signal reg_to_ALU_a 			: std_logic_vector(15 downto 0);
--signal reg_to_ALU_b 			: std_logic_vector(15 downto 0);
--signal sp_to_RAM 				: std_logic_vector(15 downto 0);
signal ALU_result 				: std_logic_vector(15 downto 0);
signal bus_to_reg				: std_logic_vector(15 downto 0);
signal pc_to_ROM 				: std_logic_vector(15 downto 0);
signal sp_pointer_out 			: std_logic_vector(15 downto 0);
signal ROM_to_ctrl_logic 		: std_logic_vector(15 downto 0);
signal ROM_data_out 			: std_logic_vector(15 downto 0);
signal bus_register_in 			: std_logic_vector(15 downto 0);
signal bus_data_out 			: std_logic_vector(15 downto 0);
signal RAM_data_out 			: std_logic_vector(15 downto 0);
signal mux_in_a 				: std_logic_vector(15 downto 0);
signal mux_in_b 				: std_logic_vector(15 downto 0);
signal mux_out					: std_logic_vector(15 downto 0);
signal pc_fsm_in 				: std_logic_vector(15 downto 0);
signal hex_out_data 			: std_logic_vector(15 downto 0);

-- Control Logic Lines

-- to Register File Lines
signal reg_one 					: std_logic_vector(2 downto 0);
signal reg_two					: std_logic_vector(2 downto 0);
signal dest_reg 				: std_logic_vector(2 downto 0);
signal reg_to_bus_address 		: std_logic_vector(2 downto 0);
signal reg_write_enable			: std_logic;
signal reg_sub_clk 				: std_logic;
signal reg_reset				: std_logic;

-- to ALU Lines
signal alu_opcode 				: std_logic_vector(3 downto 0);
signal alu_equal_flag 			: std_logic;
signal alu_sub_clk 				: std_logic;

-- to RAM Lines
signal RAM_write_enable 		: std_logic;
signal RAM_sub_clk				: std_logic;

-- to Program ROM Lines
signal ROM_sub_clk 				: std_logic;

-- to Program Counter Lines
signal pc_opcode				: std_logic_vector(1 downto 0);
signal pc_sub_clk				: std_logic;
signal pc_reset 				: std_logic;

-- to Bus Lines
signal bus_opcode 				: std_logic_vector(1 downto 0);
signal bus_sub_clk 				: std_logic;

-- Operand Mux control
signal mux_select 				: std_logic;
signal mux_sub_clk 				: std_logic;


begin
-- INSTANTIATE MODULES AND DECLARE PORT MAPPINGS

	-- Register File Port Map
	CPU_reg_file : register_file_v2
		port map(reg_to_ALU_a, mux_in_a, sp_pointer_out, bus_to_reg, hex_out_data, bus_data_out, reg_write_enable, reg_one, reg_two, dest_reg, reg_to_bus_address, reg_reset, reg_sub_clk);

	-- ALU Port Map
	CPU_ALU : ALU
		port map(ALU_result, alu_equal_flag, alu_opcode, reg_to_ALU_a, mux_out, alu_sub_clk);

	-- Operand Mux Port Map
	CPU_Op_Mux : mux
		port map(mux_out, mux_in_a, mux_in_b, mux_select, mux_sub_clk);

	-- RAM Port Map
	CPU_RAM : RAM
		generic map(address_size, data_width, RAM_file)
		port map(RAM_data_out, bus_data_out, ALU_result, ALU_result, RAM_sub_clk, RAM_write_enable);

	-- Program ROM
	CPU_ROM : program_rom
		generic map(address_size, data_width, ROM_file)
		port map(ROM_data_out, pc_to_ROM, ROM_sub_clk);

	-- Program Counter
	CPU_Program_Counter : program_counter
		port map(pc_to_ROM, bus_data_out, pc_fsm_in, pc_opcode, pc_reset, pc_sub_clk);

	-- Bus
	CPU_Bus : bus_module
		port map(bus_register_in, ALU_result, RAM_data_out, bus_opcode, bus_sub_clk, bus_data_out);

	-- Control Logic
	CPU_Control_Logic : control_logic
		port map(ROM_data_out, go, reset, clock, -- general signals
					reg_to_bus_address, reg_one, reg_two, dest_reg, reg_write_enable, reg_sub_clk, reg_reset, -- register file signals
					alu_opcode, alu_equal_flag, alu_sub_clk, -- ALU signals
					RAM_write_enable, RAM_sub_clk, -- RAM signals
					ROM_sub_clk, -- ROM signals
					pc_opcode, pc_reset, pc_sub_clk, pc_fsm_in, -- Program Counter signals
					bus_opcode, bus_sub_clk, -- Bus signals
					mux_select, mux_in_b, mux_sub_clk); -- Mux signals

	-- Output Decoders
	-- Digit 3
	CPU_d_dig_three : hex_to_7_seg
		port map(h_digit_three, hex_out_data(15 downto 12));
	-- Digit 2
	CPU_d_dig_two : hex_to_7_seg
		port map(h_digit_two, hex_out_data(11 downto 8));
	-- Digit 1
	CPU_d_dig_one : hex_to_7_seg
		port map(h_digit_one, hex_out_data(7 downto 4));
	-- Digit 0
	CPU_d_dig_zero : hex_to_7_seg
		port map(h_digit_zero, hex_out_data(3 downto 0));

	-- Digit 3
	CPU_i_dig_three : hex_to_7_seg
		port map(i_digit_three, ROM_data_out(15 downto 12));
	-- Digit 2
	CPU_i_dig_two : hex_to_7_seg
		port map(i_digit_two, ROM_data_out(11 downto 8));
	-- Digit 1
	CPU_i_dig_one : hex_to_7_seg
		port map(i_digit_one, ROM_data_out(7 downto 4));
	-- Digit 0
	CPU_i_dig_zero : hex_to_7_seg
		port map(i_digit_zero, ROM_data_out(3 downto 0));

	-- Clock Divider
	CPU_Clock_Divider : clock_divider
		port map(div_clk, clock);

	-- Tie Slow Clock to Output
	slow_clk <= div_clk;


end behav;