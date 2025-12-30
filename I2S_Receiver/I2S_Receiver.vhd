library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all; 

entity I2S_Receiver is

generic (
    bit_depth : integer := 32
    );

port (

--inputs

    --sample_rate : in integer := 48000;
    WCLK : in std_logic;
    BCLK : in std_logic;
    serial_data_in : in std_logic;
    --MCLK : in std_logic; 
--outputs
    DATA_CH1_out : out signed ((bit_depth - 1) downto 0);
    DATA_CH2_out : out signed ((bit_depth - 1) downto 0);
	 DATA_latch : out std_logic

    );
    
end I2S_Receiver;


architecture arch_I2S_Receiver of I2S_Receiver is
   
	signal left_data, right_data : signed ((bit_depth - 1) downto 0);      
	 	 
begin
 
	 
receive_data : process(bclk,wclk) --takes in I2S data and assigns to binary array

    variable bclk_counter : integer range -2 to 89 := 22;
    variable wclk_prev : std_logic;
	 variable sync_flag : std_logic := '0';
begin

	if falling_edge(BCLK) and (sync_flag = '1') then
		if (bclk_counter >= 63) then
			bclk_counter := 0;
		else
			bclk_counter := bclk_counter + 1;
		end if;
		
		case bclk_counter is
			when 0 to 2 => --begins left channel data
				left_data((bit_depth - bclk_counter) - 1) <= serial_data_in;
			when 3 =>
				DATA_latch <= '0'; --clear the frame done flag from previous frame
				left_data((bit_depth - bclk_counter) - 1) <= serial_data_in;
			when 4 to (bit_depth - 1) =>
				left_data((bit_depth - bclk_counter) - 1) <= serial_data_in;
			when bit_depth to ((bit_depth * 2) - 2) => --begins right channel data
				right_data(((bit_depth * 2) - bclk_counter) - 1) <= serial_data_in;
			when ((bit_depth * 2) - 1) => 	
				right_data(((bit_depth * 2) - bclk_counter) - 1) <= serial_data_in;
				DATA_CH1_out <= left_data;
				DATA_CH2_out <= right_data;
				data_latch <= '1'; --trigger data latch flag to begin serial meter data assignment
				sync_flag := '0';
			when others =>
				sync_flag := '0';
		end case;
	
		wclk_prev := wclk;
	end if;
	
	
	if falling_edge(wclk) then
		sync_flag := '1';
	end if;

end process;     
	
end arch_I2S_Receiver;
