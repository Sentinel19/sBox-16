--VGA Display Circuit
--Adam Dulay
--8/16/2023

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;


entity vga is
	-- constants obtained from http://tinyvga.com (for 800x600 pixel resolution)
	generic (
		h_pix 				: integer := 800;-- # of horizontal pixels
		v_pix 				: integer := 600;-- # of vertical pixels
		h_fporch			: integer := 56;-- horizontal front porch in pixels
		v_fporch 			: integer := 37;-- vertical front porch in pixels
		h_pulse 			: integer := 120;-- h synch pulse width in pixels
		v_pulse 			: integer := 6;-- v synch pulse width in pixels
		h_bporch 			: integer := 64;-- horizontal back porch in pixels
		v_bporch 			: integer := 23);  -- vertical back porch in pixels
	port (
		h_synch 			: out std_logic;
		v_synch 			: out std_logic;
		blank 				: out std_logic;
		color_data 			: out std_logic_vector(23 downto 0); -- 24 bits of color data (8 bits per color in RGB order)
		vga_clk 			: out std_logic;
		clk 				: in std_logic);

end vga;

architecture behavior of vga is

constant h_period 			: integer := h_pix + h_fporch + h_pulse + h_bporch; -- total # of horizontal pixels
constant v_period 			: integer := v_pix + v_fporch + v_pulse + v_bporch; -- total # of vertical pixels

begin
	---- keeping blank of DAC low to maintain blanking intervals
	--blank <= '0';
	-- quick and dirty all in one process (can refine later if it works)
	vga_clk <= clk;
	vga_proc : process(clk)
	variable h_count : integer range 0 to h_period - 1; -- using variables because they do not have to be
	variable v_count : integer range 0 to v_period - 1; -- inputted/outputted anywhere else
	variable red_count : integer range 0 to 255 := 0;
	variable green_count : integer range 0 to 255 := 0;
	variable blue_count : integer range 0 to 255 := 0;
	begin

		if(rising_edge(clk)) then
			-- counter update
			if(h_count < h_period-1) then
				h_count := h_count + 1;
			else
				h_count := 0;
				if(v_count < v_period-1) then
					v_count := v_count + 1;
				else
					v_count := 0;
				end if;
			end if;

			-- horizontal synch signal control
			if((h_count < h_pix + h_fporch) or (h_count >= h_pix + h_fporch + h_pulse)) then
				h_synch <= '1';
			else
				h_synch <= '0';
			end if;

			-- vertical synch signal control
			if((v_count < v_pix + v_fporch) or (v_count >= v_pix + v_fporch + v_pulse)) then
				v_synch <= '1';
			else
				v_synch <= '0';
			end if;

			-- controlling the blanking signal
			if((h_count < h_pix) and (v_count < v_pix)) then
				blank <= '1';
				-- setting color to red for testing purposes
				color_data(23 downto 16) <= std_logic_vector(to_unsigned(h_count*2, 8));
				color_data(15 downto 8) <= std_logic_vector(to_unsigned((h_count - v_count)*2, 8));
				color_data(7 downto 0) <= std_logic_vector(to_unsigned((255 - v_count)*2, 8));

			else
				blank <= '0';
				color_data <= (others => '0');
			end if;


			
				

		end if;
	end process vga_proc;
end behavior;




