--ALU Circuit (had to change to synchronous to function at the cost of performance :( .... )
--Adam Dulay
--8/29/2023

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity ALU is
	port(
		result 				: out std_logic_vector(15 downto 0);
		equal_flag 			: out std_logic;
		op   				: in std_logic_vector(3 downto 0);
		inA 				: in std_logic_vector(15 downto 0);
		inB 				: in std_logic_vector(15 downto 0);
		clk 				: in std_logic);
end ALU;

architecture behavior of ALU is
signal shift_l_temp			: std_logic_vector(15 downto 0);
signal shift_r_temp 		: std_logic_vector(15 downto 0);
begin

	
	-- probably a better way to shift left or right than two giant 15-case case statements, but this functions... (don't care about FPGA space optimization at the moment)
	shift_r_proc : process(inA, inB(3 downto 0))
	begin
		 case inB(3 downto 0) is
		 	when x"1" =>
		 		shift_r_temp <= inA(15) & inA(15 downto 1);
		 	when x"2" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15 downto 2); 
		 	when x"3" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15 downto 3);
		 	when x"4" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 4);
		 	when x"5" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 5);
		 	when x"7" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 6);
		 	when x"8" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 7);
		 	when x"9" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 8);
		 	when x"A" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 9);
		 	when x"B" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 10);
			when x"C" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 11);
		 	when x"D" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 12);
		 	when x"E" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 13);
		 	when x"F" =>
		 		shift_r_temp <= inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15) & inA(15 downto 14);			
		 	when others =>
		 		shift_r_temp <= inA;
		 end case;
	end process shift_r_proc;

	shift_l_proc : process(inA, inB(3 downto 0))
	begin	
		case inB(3 downto 0) is
			when x"1" =>
				shift_l_temp <= inA(14 downto 0) & '0';
			when x"2" =>
				shift_l_temp <= inA(13 downto 0) & "00";
			when x"3" =>
				shift_l_temp <= inA(12 downto 0) & "000";
			when x"4" =>
				shift_l_temp <= inA(11 downto 0) & "0000";
			when x"5" =>
				shift_l_temp <= inA(10 downto 0) & "00000";
			when x"6" =>
				shift_l_temp <= inA(9 downto 0) & "000000";
			when x"7" =>
				shift_l_temp <= inA(8 downto 0) & "0000000";
			when x"8" =>
				shift_l_temp <= inA(7 downto 0) & "00000000";
			when x"9" =>
				shift_l_temp <= inA(6 downto 0) & "000000000";
			when x"A" =>
				shift_l_temp <= inA(5 downto 0) & "0000000000";
			when x"B" =>
				shift_l_temp <= inA(4 downto 0) & "00000000000";
			when x"C" =>
				shift_l_temp <= inA(3 downto 0) & "000000000000";
			when x"D" =>
				shift_l_temp <= inA(2 downto 0) & "0000000000000";
			when x"E" =>
				shift_l_temp <= inA(1 downto 0) & "00000000000000";
			when x"F" =>
				shift_l_temp <= inA(0) & "000000000000000";
			when others =>
				shift_l_temp <= inA;
		end case;
		 
	end process shift_l_proc;

	-- handles most of the ALU opperations
	ALU_proc : process(clk)
	begin
		---- reset each output to eliminate timing hazards and extra latches being created
		--equal_flag <= '0';
		--result <= (others => 'X');
		--result <= (others => '0');
		if(rising_edge(clk)) then
			case op is 
				when "0000" => -- add
					result <= std_logic_vector(signed(inA) + signed(inB));
				when "0001" => -- subtract
					result <= std_logic_vector(signed(inA) - signed(inB));
				when "0010" => -- multiply
					result <= std_logic_vector(to_unsigned((to_integer(unsigned(inA)) * to_integer(unsigned(inB))),16));				
				when "0011" => -- divide
					result <= std_logic_vector(to_unsigned(to_integer(unsigned(inA)) / to_integer(unsigned(inB)),16));
				when "0100" => -- shift right
					result <= shift_r_temp;
				when "0101" => -- shift left
					result <= shift_l_temp;
				when "0110" => -- and
					result <= inA and inB;
				when "0111" => -- or
					result <= inA or inB;
				when "1000" => -- add immediate
					result <= std_logic_vector(signed(inA) + signed(inB));
				when "1001" => -- xor
					result <= inA xor inB;
				when "1010" => -- not
					result <= not(inA);
				when "1101" => -- A = B flag sets if the two inputs are equal (for branch opperation)
					result <= (others => 'X');
					if(inA = inB) then
						equal_flag <= '1';					
					end if;
				when "1011" => -- calculates store address
					result <= std_logic_vector(signed(inA) + signed(inB));
				when "1100" => -- calculates store address
					result <= std_logic_vector(signed(inA) + signed(inB));
				when "1110" => -- jump offset calculation
					result <= std_logic_vector(signed(inA) + signed(inB));
				-- this case handles cases of opcodes that do not use the ALU (as of now)
				when others =>
					result <= (others => 'X');
			end case;
		end if;
	end process ALU_proc;
end behavior;



	

