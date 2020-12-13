Library ieee;
Use ieee.std_logic_1164.all;
  Entity interfaceSpec is
    Port(Inp : in std_logic_vector(15 downto 0);
      Load, Clk : in std_logic;
      Outp : out std_logic_vector(15 downto 0));
End interfaceSpec;

Architecture behave of interfaceSpec is
    Signal Storage : std_logic_vector(15 downto 0);
      Begin
          Process(Inp, Load, Clk)
          Begin
            if(Clk'event and Clk = '1' and Load = '1') then
              Storage <= Inp;
            Elsif(Clk'event and Clk = '0') then
              Outp <= Storage;
            End if;
          End Process;
    
End behave;


