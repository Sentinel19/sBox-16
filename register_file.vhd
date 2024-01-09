-- Register File (using instances of "register.vhd")
-- Adam Dulay
-- 9/26/23

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity register_file is
	port(
		out_one					: out std_logic_vector(15 downto 0); -- output operand One to ALU
		out_two 				: out std_logic_vector(15 downto 0); -- output operand Two to ALU
		data_write_in			: in std_logic_vector(15 downto 0); -- input value to write to a register
		wr_add 					: in std_logic_vector(2 downto 0); -- address of register to be written to
		add_one					: in std_logic_vector(2 downto 0); -- address of operand A
		add_Two	 				: in std_logic_vector(2 downto 0); -- address of operand B
		Wr_En 					: in std_logic; -- write enable (controls when to write the value back to prevent timing hazards)
		reset 					: in std_logic; -- resets contents of all registers (for startup purposes)
		clk 					: in std_logic); -- clock

end register_file;

architecture behavior of register_file is
signal Aout, Bout, Cout, Dout, Eout, Fout 		: std_logic_vector(15 downto 0);
signal Ain, Bin, Cin, Din, Ein, Fin 			: std_logic_vector(15 downto 0);
signal Aload, Bload, Cload, Dload, Eload, Fload : std_logic;


	-- delcaration of the generic register from "register.vhd"
	component reg is
		port(
			data_out 			: out std_logic_vector(15 downto 0);
			data_in 			: in std_logic_vector(15 downto 0);
			load 				: in std_logic; -- write enable
			reset 				: in std_logic; -- async reset
			clk					: in std_logic);
	end component;

begin
	


	-- 6 instances of register to make up the register file's registers
	-- clock is mapped to them already, so all the register file needs to handle is the asynch logic
	A_reg : reg port map(Aout, Ain, Aload, reset, clk);
	B_reg : reg port map(Bout, Bin, Bload, reset, clk);
	C_reg : reg port map(Cout, Cin, Cload, reset, clk);
	D_reg : reg port map(Dout, Din, Dload, reset, clk);
	E_reg : reg port map(Eout, Ein, Eload, reset, clk);
	F_reg : reg port map(Fout, Fin, Fload, reset, clk);


	-- process to map input address 1
	reg_one_proc : process(add_one, clk)
	begin
		if(rising_edge(clk)) then
			case add_one is
				when "000" => -- A register address
					out_one <= Aout;
				when "001" => -- B register address
					out_one <= Bout;
				when "010" => -- C register address
					out_one <= Cout;
				when "011" => -- D register address
					out_one <= Dout;
				when "100" => -- E register address
					out_one <= Eout;
				when "101" => -- F register address
					out_one <= Fout;
				when others => -- sets output 1 to high impedence when an invalid register address is entered
					out_one <= (others => 'X');
			end case;
		end if;
	end process reg_one_proc;

	-- process to map input address 2
	reg_two_proc : process(add_two, clk)
	begin
		if(rising_edge(clk))then
			case add_two is
				when "000" => -- A register address
					out_two <= Aout;
				when "001" => -- B register address
					out_two <= Bout;
				when "010" => -- C register address
					out_two <= Cout;
				when "011" => -- D register address
					out_two <= Dout;
				when "100" => -- E register address
					out_two <= Eout;
				when "101" => -- F register address
					out_two <= Fout;
				when others => -- sets output 2 to high impedence when an invalid register address is entered
					out_two <= (others => 'X');
			end case;
		end if;
	end process reg_two_proc;

	-- process to map write addres and "load" signal
	reg_write_proc : process(wr_add, clk)
	begin
		if(rising_edge(clk)) then
			case wr_add is
				when "000" => -- A register address
					Ain <= data_write_in;
					Aload <= Wr_En;
				when "001" => -- B register address
					Bin <= data_write_in;
					Bload <= Wr_En;
				when "010" => -- C register address
					Cin <= data_write_in;
					Cload <= Wr_En;
				when "011" => -- D register address
					Din <= data_write_in;
					Dload <= Wr_En;
				when "100" => -- E register address
					Ein <= data_write_in;
					Eload <= Wr_En;
				when "101" => -- F register address
					Fin <= data_write_in;
					Fload <= Wr_En;
				when others => -- do nothing when write address is invalid				
			end case;
		end if;
	end process reg_write_proc;

end behavior;
