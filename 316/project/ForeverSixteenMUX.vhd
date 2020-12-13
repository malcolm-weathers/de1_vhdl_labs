Library ieee;
Use ieee.std_logic_1164.all;
  Entity ForeverSixteenMUX is
    Port(SEL : in std_logic;
          A : in std_logic_vector(15 downto 0);
          B : in std_logic_vector(15 downto 0);
          X : out std_logic_vector(15 downto 0));
End ForeverSixteenMUX;

Architecture behave of ForeverSixteenMUX is
Begin
    with SEL select
     X <= A when '0',
          B when '1',
          "ZZZZZZZZZZZZZZZZ" when others;
End behave;

