library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my.all;

ENTITY SYNC IS
	PORT(
		CLK: IN STD_LOGIC;
		SW1, SW2, SW3: IN STD_LOGIC;
		HSYNC: OUT STD_LOGIC;
		VSYNC: OUT STD_LOGIC;
		R: OUT STD_LOGIC_VECTOR(7 downto 0);
		G: OUT STD_LOGIC_VECTOR(7 downto 0);
		B: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END SYNC;


ARCHITECTURE MAIN OF SYNC IS
	SIGNAL RGB: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL square1_x_axis,square1_y_axis: INTEGER RANGE 0 TO 1688:=0;
	SIGNAL square2_x_axis,square2_y_axis: INTEGER RANGE 0 TO 1688:=0;
	SIGNAL HPOS: INTEGER RANGE 0 TO 1688:=0;
	SIGNAL VPOS: INTEGER RANGE 0 TO 1066:=0;
	
	SIGNAL S1: INTEGER RANGE 0 to 1280 := 100;
	SIGNAL S2: INTEGER RANGE 0 to 1024 := 100;
	SIGNAL S3: INTEGER RANGE 0 to 1280 := 500;
	SIGNAL S4: INTEGER RANGE 0 to 1024 := 500;
	
	SIGNAL COUNT: INTEGER RANGE 0 to 107999999 := 0;
	
	BEGIN
	--square(HPOS,VPOS,square1_x_axis,square1_y_axis,RGB);
	--square(HPOS,VPOS,square2_x_axis,square2_y_axis,RGB);
	PROCESS(CLK)
		BEGIN
		IF(CLK'EVENT AND CLK='1') THEN
			--R<=(others=>'1');
			--G<=(others=>'1');
			--B<=(others=>'0');
			
			
			--Porch control code
			--IF (HPOS >= 1280 AND HPOS <= 1327) OR (HPOS >= 1440 AND HPOS <= 1667) OR (VPOS = 1024) OR (VPOS >= 1028 AND VPOS <= 1065) THEN
			IF HPOS >= 1280 OR VPOS >= 1024 THEN
				R <= "00000000";
				G <= "00000000";
				B <= "00000000";
			ELSE
				--- squares
				--R <= "11111111";
				--G <= "00000000";
				--B <= "00000000";
				IF HPOS >= S1 AND HPOS <= S1+100 AND VPOS >= S2 AND VPOS <= S2+100  THEN
					R <= "00000000";
					G <= "10100000";
					B <= "00000001";
				ELSIF HPOS >= S3 AND HPOS <= S3+100 AND VPOS >= S4 AND VPOS <= S4+100 THEN
					IF SW3 = '0' THEN
						R <= "10011000";
						G <= "00001111";
						G <= "00000001";
					ELSIF SW3 = '1' THEN
						R <= "00000000";
						G <= "00000010";
						B <= "01000000";
					END IF;
				ELSE
					R <= "00000000";
					G <= "00000000";
					B <= "00000000";
				END IF;
			END IF;
			
			--Synch control code
			IF HPOS >= 1328 AND HPOS <= 1439 THEN
				HSYNC <= '1';
			ELSE
				HSYNC <= '0';
			END IF;
			
			IF VPOS >= 770 AND VPOS <= 772 THEN
				VSYNC <= '1';
			ELSE
				VSYNC <= '0';
			END IF;
			
			
			--Square signal control
			-- 0-1279, 0-1023
			COUNT <= COUNT + 1;
			IF COUNT = 27999999 THEN
				COUNT <= 0;
				IF SW1 = '1' THEN
					S1 <= S1 + 1;
				END IF;
				IF SW2 = '1' THEN
					S3 <= S3 + 1;
				END IF;
			END IF;
			
			
			--Frame control code
			HPOS <= HPOS + 1;
			IF HPOS = 1688 THEN
				HPOS <= 0;
				VPOS <= VPOS + 1;
				IF VPOS = 1066 THEN
					VPOS <= 0;
				END IF;
			END IF;


		END IF;
	END PROCESS;
END MAIN;