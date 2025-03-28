-- Copyright (C) 2023  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "03/27/2025 12:45:43"
                                                            
-- Vhdl Test Bench template for design  :  spdif_rcvr
-- 
-- Simulation tool : Questa Intel FPGA (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY spdif_rcvr_vhd_tst IS

port (
        tb_rst     : in  std_logic := '1';  --pull down for reset
   	  tb_clk_49_in  : in  std_logic := '0';--49.152MHz
        tb_clk_45_in : in std_logic := '0'--45.1584MHz
		  
    );

END spdif_rcvr_vhd_tst;
ARCHITECTURE spdif_rcvr_arch OF spdif_rcvr_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL tb_clk_sel_out : STD_LOGIC := '0';
SIGNAL tb_I2S_BCLK : STD_LOGIC := '0';
SIGNAL tb_I2S_data : STD_LOGIC := '0';
SIGNAL tb_I2S_WCLK : STD_LOGIC := '0';
SIGNAL tb_spdif_data_out : STD_LOGIC := '0';
SIGNAL tb_sync_flag : STD_LOGIC;

signal xmit_clk : std_logic := '1';
signal tb_mclk : std_logic := '0';

-----test variables-----
signal tb_test_cycle_counter : integer := 0;
signal tb_test_bclk_counter : integer := 0;

------------------------


COMPONENT spdif_rcvr is
	PORT (
	clk_45_in : IN STD_LOGIC;
	clk_49_in : IN STD_LOGIC;
	clk_sel_out : BUFFER STD_LOGIC;
	I2S_BCLK_in : IN STD_LOGIC;
	I2S_data_out : OUT STD_LOGIC;
	I2S_WCLK_in : IN STD_LOGIC;
	rst : IN STD_LOGIC;
	spdif_data_in : IN STD_LOGIC;
	sync_flag : BUFFER STD_LOGIC
	);
END COMPONENT;


BEGIN
	i1 : spdif_rcvr
	PORT MAP (
-- list connections between master ports and signals
	clk_45_in => tb_mclk,
	clk_49_in => tb_mclk,
	clk_sel_out => tb_clk_sel_out,
	I2S_BCLK_in => tb_I2S_BCLK,
	I2S_data_out => tb_I2S_data,
	I2S_WCLK_in => tb_I2S_WCLK,
	rst => tb_rst,
	spdif_data_in => tb_spdif_data_out,
	sync_flag => tb_sync_flag
	);
--init : PROCESS                                               
---- variable declarations                                     
--BEGIN                                                        
--        -- code that executes only once                      
--WAIT;                                                       
--END PROCESS init; 

tb_mclk <= tb_clk_45_in;                                          
														
gen_clocks : PROCESS (tb_mclk,xmit_clk)                                             
	variable clk_cyc_counter : integer range 0 to 2000 := 0;
	variable bclk_counter : integer range 0 to 70 := 0;
	variable bit_counter : integer range 0 to 70 := 0;
	
--	constant xmit_clk_count := integer := 32;
--	constant bclk_count := integer := 16;
--	constant wlk_count := integer := 1024;
	
	BEGIN                                                         
		if falling_edge(tb_mclk) then
			clk_cyc_counter := clk_cyc_counter + 1;
			bit_counter := bit_counter + 1;
			tb_test_cycle_counter <= clk_cyc_counter; -----test
			if clk_cyc_counter = 4 then
				xmit_clk <= not xmit_clk;
				clk_cyc_counter := 0;
			end if;
			
			
			if bit_counter >= 32 then
				bclk_counter := bclk_counter + 1;
				tb_test_bclk_counter <= bclk_counter; -----test
				clk_cyc_counter := 0;
				tb_test_cycle_counter <= clk_cyc_counter; -----test
				tb_I2S_BCLK <= '0';
			elsif bit_counter = 16 then
				tb_I2S_BCLK <= '1';
			end if;
			
			if bclk_counter = 16 then
				tb_I2S_WCLK <= '1';
			elsif bclk_counter >= 32 then
				tb_I2S_WCLK <= '0';
				bclk_counter := 0;
				tb_test_bclk_counter <= bclk_counter; -----test
			end if;
		end if;

END PROCESS gen_clocks;


--note!  Data transmitted in LSB first order.
gen_data : process (xmit_clk)

	type sin_data is array (0 to 49) of std_logic_vector(0 to 23); --data is MSB left
	constant sin_1764Hz : sin_data := (x"000000", x"1FD510", x"3DAA18", x"579F39", x"6C12EC", x"79BC36", x"7FBF56", x"7DBB99", x"73D166", x"62A038", x"4B3C9A", x"2F1EC7", x"100B01", x"EFF52C", x"D0E163", x"B4C38A", x"9D5FE5", x"8C2EAD", x"82446F", x"8040A7", x"8643BD", x"93ECFC", x"A860A6", x"C255C1", x"E02AC5",x"000000", x"1FD510", x"3DAA18", x"579F39", x"6C12EC", x"79BC36", x"7FBF56", x"7DBB99", x"73D166", x"62A038", x"4B3C9A", x"2F1EC7", x"100B01", x"EFF52C", x"D0E163", x"B4C38A", x"9D5FE5", x"8C2EAD", x"82446F", x"8040A7", x"8643BD", x"93ECFC", x"A860A6", x"C255C1", x"E02AC5");
	constant sin_882Hz : sin_data := (x"000000", x"100AEA", x"1FD510", x"2F1EB2", x"3DAA18", x"4B3C88", x"579F39", x"62A02A", x"6C12EC", x"73D15C", x"79BC36", x"7DBB95", x"7FBF56", x"7FBF58", x"7DBB99", x"79BC3C", x"73D166", x"6C12F8", x"62A038", x"579F4A", x"4B3C9A", x"3DAA2B", x"2F1EC7", x"1FD526", x"100B01", x"000016", x"EFF52C", x"E02B05", x"D0E163", x"C255FC", x"B4C38A", x"A860D7", x"9D5FE5", x"93ED20", x"8C2EAD", x"8643D1", x"82446F", x"8040AB", x"8040A7", x"824463", x"8643BD", x"8C2E91", x"93ECFC", x"9D5FBA", x"A860A6", x"B4C354", x"C255C1", x"D0E125", x"E02AC5", x"EFF4E9");
	
	variable data_pointer : integer range 0 to 50 := 0;
	variable frame_counter : integer range 0 to 200 := 0;
	
	-----frame and frame aliases-----
	variable frame : std_logic_vector(0 to 63);
		
	alias subframe_A_data : std_logic_vector (0 to 23) is frame(4 to 27);
	alias subframe_B_data : std_logic_vector (0 to 23) is frame(36 to 59);
	alias subframe_A_preamble : std_logic_vector(3 downto 0) is frame (0 to 3);
	alias subframe_B_preample : std_logic_vector(3 downto 0) is frame (32 to 35);
	alias subframe_A_validity : std_logic is frame(28);
	alias subframe_B_validity : std_logic is frame(60);
	alias subframe_A_user : std_logic is frame(29);
	alias subframe_B_user : std_logic is frame(61);
	alias subframe_A_channel : std_logic is frame(30);
	alias subframe_B_channel : std_logic is frame(62);
	alias subframe_A_parity : std_logic is frame(31);
	alias subframe_B_parity : std_logic is frame(63);
	
	-----channel_status and channel status aliases-----
	--"minimum" value settings has bit 7 of byte 0 set to '1' for "pro" followed by all zeros
	
	variable channel_status : std_logic_vector (0 to 191) := x"800000000000000000000000000000000000000000000000";
--byte 0	
	alias pro : std_logic is channel_status(0);-- := '0'; --set to "consumer" for compatibility
	alias nonaudio :std_logic is channel_status(1);-- := '0'; --set to normal audio mode
	alias emph :std_logic_vector(0 to 2) is channel_status(2 to 4);--:= "000"; --no preemphasis but receiver's choice okay
	alias src_samp_lock :std_logic is channel_status(5) ;--:= '1'; --source sample rate unlocked
	alias samp_freq : std_logic_vector(0 to 1) is channel_status(6 to 7);-- := "10"; --setting to 44.1KHz by default
--byte 1	
	alias ch_mode :std_logic_vector(0 to 3) is channel_status(8 to 11);-- := "0001"; --set to two-channel mode.
	alias user_bits :std_logic_vector(0 to 3) is channel_status(12 to 15);-- := "0000"; --set to no user information provided
--byte 2	
	alias aux_bits :std_logic_vector (0 to 2) is channel_status(16 to 18);-- := "001"; --set to use aux bits with audio data bits (24 bit mode)
	alias audio_word_length :std_logic_vector (0 to 2) is channel_status(19 to 21);-- := "101"; --set to use maximum 20 to 24 bit word
	alias rsvd_undef_0 : std_logic_vector (0 to 1) is channel_status(22 to 23);-- := "00" --undefined reserved block set to all zeroes
--byte 3	
	alias rsvd_multichan : std_logic_vector (0 to 7) is channel_status(24 to 31);-- := x"00"; --reserved byte defaulted to all zeroes
--byte 4	
	alias dig_ref_sig : std_logic_vector (0 to 1) is channel_status(32 to 33);-- := "00";  --set to default "non reference signal"
	alias rsvd_undef_1 : std_logic_vector (0 to 5) is channel_status(34 to 39);-- := "000000";  --undefiined reserved block set to all zeroes
--byte 5	
	alias rsvd_undef_2 : std_logic_vector(0 to 7) is channel_status(40 to 47);-- := x"00";--undefined reserved block set to all zeroes
--bytes 6 thru 9
	alias channel_origin : std_logic_vector(0 to 31) is channel_status(48 to 79);-- := x"00000000"; --alphanumeric data set all zeros
--bytes 10 thru 13
	alias channel_dest : std_logic_vector(0 to 31) is channel_status(80 to 111);-- := x"00000000"; --alphanumeric data set all zeros
--bytes 14 thru 17
	alias samp_addr : std_logic_vector(0 to 31) is channel_status(112 to 143);-- := x"00000000"; --local sample address code seet to all zeros
--bytes 18 thru 21
	alias tod_samp_addr : std_logic_vector(0 to 31) is channel_status(144 to 175);-- := x"00000000"; --time of day sample address code set to all zeros
--byte 22
	alias rsvd_undef_02 : std_logic_vector(0 to 3) is channel_status(176 to 179);-- := "0000";--undefiined reserved block set to all zeroes
	alias byte_0to5_valid : std_logic is channel_status(180);-- := '1'; --define channel status bytes 0 through 5 as valid
	alias byte_6to13_valid : std_logic is channel_status(181);-- := '1'; --define channel status bytes 6 through 13 as valid
	alias byte_14to17_valid : std_logic is channel_status(182);-- := '1'; --define channel status bytes 14 through 17 as valid
	alias byte_18to21_valid : std_logic is channel_status(183);-- := '1'; --define channel status bytes 18 through 21 as valid
--byte 23	
	alias crcc : std_logic_vector(0 to 7) is channel_status(184 to 191);-- := "0000000"; 
	----------------	
	
	
	
begin



end process gen_data;

                                          
END spdif_rcvr_arch;
