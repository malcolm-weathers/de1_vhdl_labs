Library ieee;
Use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

Entity ALU is 
  Port(CI : in std_logic;
    AMF : in std_logic_vector(4 downto 0);
    CLK : in std_logic;
    DMD, R : inout std_logic_vector(15 downto 0);
    PMD : in std_logic_vector(23 downto 0);
    En : in std_logic_vector(3 downto 0);
    alu_out : inout std_logic_vector(15 downto 0);
    Load : in std_logic_vector(5 downto 0);
    Sel : in std_logic_vector(7 downto 0);
    AZ, AN, AC, AV, AS : out std_logic;
    Display1, Display2, Display3, Display4 : out std_logic_vector (6 downto 0));
end ALU;

Architecture behave of ALU is
component ForeverSixteenMUX 
      Port(SEL : in std_logic;
          A : in std_logic_vector(15 downto 0);
          B : in std_logic_vector(15 downto 0);
          X : out std_logic_vector(15 downto 0));
end component;

component sixteenTriState
  Port(input : in std_logic_vector(15 downto 0);
        enable : in std_logic;
        output : out std_logic_vector(15 downto 0));
end component;

component interfaceSpec
      Port(Inp : in std_logic_vector(15 downto 0);
      Load, Clk : in std_logic;
      Outp : out std_logic_vector(15 downto 0));
end component;

component AyElYouKernel
    Port(X, Y : in std_logic_vector(15 downto 0);
    CI : in std_logic;
    AMF : in std_logic_vector(4 downto 0);
    CLK : in std_logic;
    R, R2 : out std_logic_vector(15 downto 0);
    AZ, AN, AC, AV, AS : out std_logic);
end component;

component Display_Ckt is
port(inputD: in std_logic_vector(3 downto 0);
	segmentSeven : out std_logic_vector(6 downto 0));
end component;

  signal S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14: std_logic_vector(15 downto 0);

begin
  
  tri0: sixteenTriState port map(input => S3, enable => En(0), output => DMD);
  tri1: sixteenTriState port map(input => S8, enable => En(1), output => DMD);
  tri2: sixteenTriState port map(input => S14, enable => En(2), output => DMD);
  tri3: sixteenTriState port map(input => S14, enable => En(3), output => R);
  
  ax0: interfaceSpec port map(Inp => "0000000000001011", Load => Load(0), Clk => CLK, Outp => S1);
  ax1: interfaceSpec port map(Inp => "0000000000000101", Load => Load(1), Clk => CLK, Outp => S2);
  mux1: ForeverSixteenMUX port map(SEL => Sel(1), A => S1, B => S2, X => S3);
  
  mux0: ForeverSixteenMUX port map(SEL => Sel(0), A => DMD, B => PMD(15 downto 0), X => S5);
  ay0: interfaceSpec port map(Inp => "0000000000000111", Load => Load(2), Clk => CLK, Outp => S6);
  ay1: interfaceSpec port map(Inp => "0000000000001101", Load => Load(3), Clk => CLK, Outp => S7);
  mux3: ForeverSixteenMUX port map(SEL => Sel(3), A => S6, B => S7, X => S8);
    
  mux2: ForeverSixteenMUX port map(SEL => Sel(2), A => R, B => S3, X => S4);
  mux4: ForeverSixteenMUX port map(SEL => Sel(4), A => S8, B => S9, X => S10);
  mux5: ForeverSixteenMUX port map(SEL => Sel(5), A => S12, B => DMD, X => S13);
    
  alu: AyElYouKernel port map(X => S4, Y => S10, CI => CI, AMF => "10011", CLK => CLK, R => S12, R2 => S11, AZ => AZ, AN => AN, AC => AC, AV => AV, AS => AS);
    
  af: interfaceSpec port map(Inp => S11, Load => Load(4), Clk => CLK, Outp => S9);
  ar: interfaceSpec port map(Inp => S13, Load => Load(5), Clk => CLK, Outp => S14);
    
  Dis_1: Display_Ckt port map(inputD => S14(15 downto 12), segmentSeven => Display1);
  Dis_2: Display_Ckt port map(inputD => S14(11 downto 8), segmentSeven => Display2);
  Dis_3: Display_Ckt port map(inputD => S14(7 downto 4), segmentSeven => Display3);
  Dis_4: Display_Ckt port map(inputD => S14(3 downto 0), segmentSeven => Display4);
  
end behave;
