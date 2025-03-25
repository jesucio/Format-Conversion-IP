


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; -- don't use for synthesis, but OK for static numbers

entity spdif_rcvr is
   
    port (
        rst     : in  std_logic := '1';  --pull down for reset
        
		  clk_49_in  : in  std_logic := '0';--49.152MHz
        clk_45_in : in std_logic := '0';--45.1584MHz
		  clk_sel_out : buffer boolean := false ; --low for 45, high for 49
		  		  
		  spdif_data_in : in std_logic := '0';
		  
		  I2S_BCLK_in : in std_logic := '0';
		  I2S_WCLK_in : in std_logic := '0';
		  I2S_data_out : out std_logic := 'Z';
		  
		  sync_flag : buffer std_logic := 'Z' --go low when sync is active.
		  
		  
    );
end spdif_rcvr;

architecture arch_spdif_rcvr of spdif_rcvr is
    
	 signal sync_clk : std_logic := '0';
	 signal curr_decoded_bit : std_logic := '0';
	 signal mclk : std_logic := '0';
	 signal preamble_x_flag, preamble_y_flag, preamble_z_flag : std_logic := '0';
	 signal ready_frame : std_logic_vector(63 downto 0) := x"0000000000000000";
	 
begin
    mclk <= clk_49_in when clk_sel_out else clk_45_in;
	
	  
	--process to sync to stream timing and decode  
	sync_input: process (clk_45_in, clk_49_in, rst, sync_flag)
			constant x_preamble : std_logic_vector(3 downto 0) := "0010";
			constant y_preamble : std_logic_vector(3 downto 0) := "0100";
			constant z_preamble : std_logic_vector(3 downto 0) := "1000";
			variable preamble_byte : std_logic_vector (7 downto 0) := "01010101";--used to hold the last byte's worth of data.

			variable prev_trans_loc, trans_loc : std_logic := '0';
			variable bit_pair : std_logic_vector(1 downto 0) := "00";
    	  
			variable min_bit_count: integer range 0 to 50 := 50; --the lowest number of bit steps
			variable bit_counter  : integer range 0 to 110 := 0; --count the minimum cycles value for sync
		  
			variable bit_sync_okay : std_logic := '0';
		
		begin
			if falling_edge(mclk) then
				bit_counter := bit_counter + 1;
				bit_pair(1) := bit_pair(0); --shift the bit pair left
				bit_pair(0) := spdif_data_in; --read current value
				
				if (bit_sync_okay = '0') then
						if bit_pair(1) xor bit_pair(0) then --look for a state change in datastream
							min_bit_count := bit_counter;
							if bit_counter >= (min_bit_count * 2) then
								trans_loc := '0';
								bit_sync_okay := '0';
							end if;
							bit_counter := 0;
						end if;
				end if;		
				
				if (bit_sync_okay = '1') then
					if (bit_counter = (min_bit_count/2)) then
						trans_loc := '1';
						if bit_pair(1) xor bit_pair(0) then
							curr_decoded_bit <= '1';
						else
							curr_decoded_bit <= '0';
						end if;
					elsif (bit_counter = (min_bit_count)) then
						trans_loc := '0';
						bit_counter := 0;
					end if;
				
				--using the transitions to look for the preambles
					if (trans_loc xor prev_trans_loc) then
						preamble_byte(6 downto 0) := preamble_byte(7 downto 1);
						preamble_byte(7) := spdif_data_in;
						if (preamble_byte(3 downto 0) = "1110") or (preamble_byte(3 downto 0) = "0001") then
							case preamble_byte(3 downto 0) is
								when x_preamble | (not x_preamble) => --preamble x identified
									preamble_x_flag <= '1';
									preamble_y_flag <= '0';
									preamble_z_flag <= '0';
								when y_preamble | (not y_preamble) => --preamble y identified
									preamble_x_flag <= '0';
									preamble_y_flag <= '1';
									preamble_z_flag <= '0';
								when z_preamble | (not z_preamble) => --preamble z identified
									preamble_x_flag <= '0';
									preamble_y_flag <= '0';
									preamble_z_flag <= '1';
								when others => --no preambles identified
									preamble_x_flag <= '0';
									preamble_y_flag <= '0';
									preamble_z_flag <= '0';
							end case;
						else
							preamble_x_flag <= '0';
							preamble_y_flag <= '0';
							preamble_z_flag <= '0';
						end if;
					end if;
				end if;
				
				
					
			end if;
			sync_clk <= trans_loc;
			prev_trans_loc := (trans_loc);
    end process  sync_input;

	 
	 
	data_read : process (preamble_x_flag,preamble_y_flag,preamble_z_flag, sync_clk)
			variable frame_count : integer range 0 to 200 := 0;
			variable subframe_count : integer range 0 to 3 := 0;
			variable bit_count : integer range 0 to 35;
			
			variable curr_frame, ready_frame : std_logic_vector(63 downto 0);
			
			
			
		begin
			if falling_edge(sync_clk) then
				bit_count := bit_count + 1;
				if bit_count >= 33 then
					bit_count := 1;
					subframe_count := subframe_count + 1;
					if subframe_count >= 3 then
						subframe_count := 1;
						ready_frame := curr_frame;
						frame_count := frame_count + 1;
						if frame_count >= 193 then
							frame_count := 1;
						end if;
					end if;
				end if;
				curr_frame(bit_count + (bit_count * (subframe_count - 1)) - 1) := curr_decoded_bit;
			end if;
				
			if rising_edge(preamble_y_flag) then
				subframe_count := 0;
				frame_count := 0;
			elsif rising_edge(preamble_x_flag) then
				bit_count := 0;
    			subframe_count := 0;
				frame_count := 0;
				ready_frame := curr_frame;
			elsif rising_edge(preamble_z_flag) then
				ready_frame := curr_frame;
				bit_count := 0;
				subframe_count := 0;
				frame_count := 0;
			end if;
	
	end process data_read;
	
	
	I2S_xmit : process (preamble_x_flag, I2S_BCLK_in, I2S_WCLK_in)
			
			variable bit_count : integer range 0 to 63 := 1;
			variable prev_wclk : std_logic := '0';
			
		begin
			if falling_edge(I2S_BCLK_in) then
				if (bit_count >= 64) or (prev_wclk = '1' and (prev_wclk /= I2S_WCLK_in))then
					bit_count := 1;
				else
					bit_count := bit_count + 1;
				end if;
			prev_wclk := I2S_WCLK_in;
			end if;
			
			
	end process I2S_xmit;

	
	 
end arch_spdif_rcvr;
