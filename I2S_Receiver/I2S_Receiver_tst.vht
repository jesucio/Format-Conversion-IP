-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "06/21/2019 21:56:33"
                                                            
-- Vhdl Test Bench template for design  :  I2S_Receiver
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
use STD.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;


ENTITY I2S_Receiver_vhd_tst IS
port (
	system_clock : in std_logic
	);
END I2S_Receiver_vhd_tst;
ARCHITECTURE I2S_Receiver_arch OF I2S_Receiver_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL BCLK : STD_LOGIC := '0';
SIGNAL DATA : STD_LOGIC := '0';
SIGNAL DATA_CH1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DATA_CH2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MCLK : STD_LOGIC := '0';
SIGNAL sample_rate : integer;
SIGNAL WCLK : STD_LOGIC := '0';
signal data_block_left, data_block_right : std_logic_vector(31 downto 0);


COMPONENT I2S_Receiver
	PORT (
	BCLK : IN STD_LOGIC;
	DATA : IN STD_LOGIC;
	DATA_CH1_out : out STD_LOGIC_VECTOR(31 DOWNTO 0);
	DATA_CH2_out : out STD_LOGIC_VECTOR(31 DOWNTO 0);
	MCLK : IN STD_LOGIC;
	sample_rate : IN integer;
	WCLK : IN STD_LOGIC
	);
END COMPONENT;



BEGIN
	i1 : I2S_Receiver
	PORT MAP (
-- list connections between master ports and signals
	BCLK => BCLK,
	DATA => DATA,
	DATA_CH1_out => DATA_CH1,
	DATA_CH2_out => DATA_CH2,
	MCLK => MCLK,
	sample_rate => sample_rate,
	WCLK => WCLK
	);
                                    
gen_clock : process (mclk,system_clock,bclk,wclk)

	variable bclk_counter,wclk_counter : integer range 0 to 4000000 := 0;
	variable bclk_count_cycle : integer range 0 to 5 := 0;
	
begin
sample_rate <= 48000;
mclk <= system_clock;
if falling_edge(system_clock) then


	if bclk_counter >= 31 then
		bclk_count_cycle := bclk_count_cycle + 1;
		bclk_counter := 0;
		if bclk_count_cycle >= 3 then 
			bclk <= not bclk;
			bclk_count_cycle := 0;
		end if;
	else
		bclk_counter := bclk_counter + 1;
	end if;
	
	if wclk_counter >= 511 then
		wclk <= not wclk;
		wclk_counter := 0;
	else
		wclk_counter := wclk_counter + 1;
	end if;
	
end if;

end process gen_clock;


get_data: process (bclk,wclk)

	variable data_counter : integer range 0 to 33 := 0 ;
	variable dummy_data : std_logic_vector(31 downto 0) := x"00000000";
	variable dummy_data_int : integer;	
begin

	if rising_edge(wclk) then
		if dummy_data >= x"FFFFFFFF" then
			dummy_data := x"00000000";
		else
			dummy_data_int := to_integer(unsigned(dummy_data)) + 1;
			dummy_data := std_logic_vector(to_unsigned(dummy_data_int,dummy_data'length));
		end if;
	elsif falling_edge(wclk) then
		data_counter := 0;
	end if;

	if rising_edge(bclk) then
		data <= dummy_data(data_counter);
		if data_counter <= 31 then
			data_counter := 0;
		else 
			data_counter := data_counter + 1;	
		end if;
	end if;


end process get_data;
                      
END I2S_Receiver_arch;
