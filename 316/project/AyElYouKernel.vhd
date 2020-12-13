Library ieee;
Use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

Entity AyElYouKernel is
  Port(X, Y : in std_logic_vector(15 downto 0);
    CI : in std_logic;
    AMF : in std_logic_vector(4 downto 0);
    CLK : in std_logic;
    R, R2 : out std_logic_vector(15 downto 0);
    AZ, AN, AC, AV, AS : out std_logic);
end AyElYouKernel;

architecture behave of AyElYouKernel is
  signal rsig: std_logic_vector(15 downto 0);
begin
  AyElYouKernel: process(X, Y, CLK, CI, AMF)
    begin
      if(CLK = '1') then
        if(AMF = "10000") then
          rsig <= Y;
        elsif(AMF = "10001") then
          rsig <= Y + 1;
        elsif(AMF = "10010") then
          rsig <= X + Y + CI;
        elsif(AMF = "10011") then
          rsig <= X + Y;
        elsif(AMF = "10100") then
          rsig <= NOT Y;
        elsif(AMF = "10101") then
          rsig <= (-Y);
        elsif(AMF = "10110") then
          rsig <= X - Y + CI - 1;
        elsif(AMF = "10111") then
          rsig <= X - Y;
        elsif(AMF = "11000") then
          rsig <= Y - 1;
        elsif(AMF = "11001") then
          rsig <= Y - X;
        elsif(AMF = "11010") then
          rsig <= Y - X + CI - 1;
        elsif(AMF = "11011") then
          rsig <= NOT X;
        elsif(AMF = "11100") then
          rsig <= X AND Y;
        elsif(AMF = "11101") then 
          rsig <= X OR Y;
        elsif(AMF = "11110") then
          rsig <= X XOR Y; 
        elsif(AMF = "11111") then
          rsig <= ABS X;    
        end if;
      end if;
    end process;
    
    process(X, Y, CLK, CI, AMF)
    begin
      R <= rsig;
	  R2 <= rsig;
      
      -- AZ
      if (rsig = "0000000000000000") then
        AZ <= '1';
      else
        AZ <= '0';
      end if;
      
      -- AN
      if (rsig(15) = '1') then
        AN <= '1';
      else
        AN <= '0';
      end if;
      
      -- AC
      if (X(15) = '0' and Y(15) = '0' and ((X(15) xnor Y(15)) and (rsig(15) xor X(15))) = '1') then
        AC <= '1';
      else
        AC <= '0';
      end if;
      
      -- AV
      AV <= (X(15) xnor Y(15)) and (rsig(15) xor X(15));
      
      -- AS
      if (X(15) = '1') then
        AS <= '1';
      else
        AS <= '0';
      end if;
    end process;
    
end behave;