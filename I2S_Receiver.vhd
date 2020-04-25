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
   
	signal left_data, right_data : signed (bit_depth downto 1);      
	 	 
begin
 
	 
receive_data : process(bclk,wclk) --takes in I2S data and assigns to binary array

    variable bclk_counter : natural range 0 to 100;
    variable wclk_prev : std_logic;
	
begin
	if rising_edge(bclk) then
		bclk_counter := bclk_counter + 1;
		if (wclk_prev = '1') and (wclk = '0') and bclk_counter /= (bit_depth * 2) then
			bclk_counter := 0;
		end if;
		
		case bclk_counter is
			when 1 to 3 => --begins left channel data
				left_data(bclk_counter) <= serial_data_in;
			when 4 =>
				DATA_latch <= '0'; --clear the frame done flag from previous frame
				left_data(bclk_counter) <= serial_data_in;
			when 5 to (bit_depth - 1) =>
				left_data(bclk_counter) <= serial_data_in;
			when (bit_depth) =>
				if wclk_prev = '0' and wclk = '1' then
					left_data(bclk_counter) <= serial_data_in;
				end if;
			when (bit_depth + 1) to ((bit_depth * 2) - 1) => --begins right channel data
					right_data(bclk_counter - 24) <= serial_data_in;
			when (bit_depth * 2) =>
				if wclk_prev = '1' and wclk = '0' then
					right_data(bclk_counter - 24) <= serial_data_in;
				end if;
				DATA_CH1_out <= left_data;
				DATA_CH2_out <= right_data;
				
				data_latch <= '1'; --trigger data latch flag to begin serial meter data assignment
				bclk_counter := 0;
			when others =>
		end case;
	
		wclk_prev := wclk;
	end if;
	
end process;     
	
end arch_I2S_Receiver;
