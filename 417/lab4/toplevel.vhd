LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY toplevel IS
	PORT (
		KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	
		I2C_SCLK : OUT STD_LOGIC;
		I2C_SDAT : INOUT STD_LOGIC;
		CLOCK_50 : IN STD_LOGIC;
		
		AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, AUD_ADCDAT : IN STD_LOGIC;
		AUD_DACDAT : OUT STD_LOGIC;
		
		AUD_XCK : OUT STD_LOGIC;
		CLOCK2_50 : IN STD_LOGIC
	);
END toplevel;

ARCHITECTURE Behavior OF toplevel IS
   COMPONENT clock_generator --this component is completed for you
      PORT( CLOCK_27 : IN STD_LOGIC;
            reset    : IN STD_LOGIC;
            AUD_XCK  : OUT STD_LOGIC);
   END COMPONENT;

   COMPONENT audio_and_video_config
		PORT (
			CLOCK_50 : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			I2C_SDAT : INOUT STD_LOGIC;
			I2C_SCLK : OUT STD_LOGIC
		);
   END COMPONENT;   

   COMPONENT audio_codec --complete this component
		PORT (
			CLOCK_50, reset, read_s, write_s : IN STD_LOGIC;
			writedata_left, writedata_right : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
			AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK : IN STD_LOGIC;
			AUD_DACDAT : OUT STD_LOGIC;
			read_ready, write_ready : OUT STD_LOGIC;
			readdata_left, readdata_right : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
		);
   END COMPONENT;

   SIGNAL read_ready, write_ready, read_s, write_s 		: STD_LOGIC;
   SIGNAL readdata_left, readdata_right            		: STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL writedata_left, writedata_right          		: STD_LOGIC_VECTOR(23 DOWNTO 0);   
   SIGNAL reset                                    		: STD_LOGIC;
 
BEGIN
	reset <= NOT(KEY(0));
	read_s <= read_ready;
	writedata_left <= readdata_left;
	writedata_right <= readdata_right;
	write_s <= write_ready AND read_ready;
   
  	my_clock_gen: clock_generator PORT MAP (CLOCK2_50, reset, AUD_XCK);
	audvid_config: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	aud_codec: audio_codec PORT MAP (CLOCK_50, reset, read_s, write_s, writedata_left, writedata_right, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, AUD_DACDAT, read_ready, write_ready, readdata_left, readdata_right);

  
END Behavior;
