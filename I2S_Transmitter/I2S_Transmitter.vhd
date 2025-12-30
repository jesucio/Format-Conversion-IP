--Master I2S transmitter 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
use IEEE.numeric_std.all;


ENTITY I2S_Transmitter is
port (
	--inputs
	bit_depth : in integer range 0 to 33 := 32;
	sample_rate : in integer range 40000 to 200000 := 48000;

	system_clock : in std_logic := '0';
	data_CH1 : in signed((bit_depth - 1) downto 0);
	data_CH2 : in signed((bit_depth - 1) downto 0);
	data_latch : in std_logic := '0';
	--outputs
	bclk : buffer std_logic := '0';
   wclk : buffer std_logic := '0';
	data_out : out std_logic := '0'
		);
END I2S_Transmitter;

ARCHITECTURE arch_I2S_Transmitter OF I2S_Transmitter IS
-- constants                                                 
-- signals                                                   
signal mclk : std_logic := '0';
--signal data_block_left, data_block_right : std_logic_vector((bit_depth - 1) downto 0);
signal sync_flag : std_logic := '0';

--test signals



BEGIN
                                    
gen_clock : process (system_clock,bclk,wclk) --generate I2S clocks

	variable bclk_counter,wclk_counter : integer range 0 to 40000 := 0;
	
begin
mclk <= system_clock;
if falling_edge(mclk) then
	if bclk_counter >= 3 then
		bclk_counter := 0;
		bclk <= not bclk;
		if wclk_counter >= ((bit_depth * 2) - 1) then 
			wclk <= not wclk;
			wclk_counter := 0;
		else
			wclk_counter := wclk_counter + 1;
		end if;
	else
		bclk_counter := bclk_counter + 1;
	end if;
	
end if;

end process gen_clock;


send_data: process (bclk,wclk,data_latch,data_CH1,data_CH2)

	variable prev_wclk : std_logic := '0';
	variable data_to_send : std_logic_vector(((bit_depth * 2) - 1) downto 0);
	variable bclk_counter : integer range 0 to 80 := 0;
begin
	
	if falling_edge(wclk) then
		sync_flag <= '1';
	end if;
	
	if rising_edge(bclk) and sync_flag = '1' then
		data_out <= data_to_send(((bit_depth * 2) - 1) - bclk_counter);
		if bclk_counter >= ((bit_depth * 2) - 1) then
			bclk_counter := 0;
		else
			bclk_counter := bclk_counter + 1;
		end if;
		
		prev_wclk := wclk;
	end if;
	
	
	if rising_edge(sync_flag) then
		data_to_send(((bit_depth) - 1) downto 0) := std_logic_vector(data_CH2);
		data_to_send(((bit_depth * 2) - 1) downto bit_depth) := std_logic_vector(data_CH1);
		bclk_counter := 0;
	end if;
	
	
	

end process send_data;
                      
END arch_I2S_Transmitter;
