

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.STD_LOGIC_arith.ALL;
use ieee.STD_LOGIC_unsigned.ALL;


entity SSD is
  Port ( 
         digit1 : in std_logic_vector (3 downto 0);
         digit2 : in std_logic_vector (3 downto 0);
         digit3 : in std_logic_vector (3 downto 0);
         digit4 : in std_logic_vector (3 downto 0);  
         clk : in std_logic;
         cat : out std_logic_vector (6 downto 0);
         an : out std_logic_vector (3 downto 0)
         );
end SSD;

architecture Behavioral of SSD is

signal cnt : std_logic_vector (15 downto 0) := X"0000";
signal dcd : std_logic_vector (3 downto 0) := "0000";

begin
    
    process(digit1,digit2,digit3,digit4,cnt(15 downto 14))
    begin
    case cnt(15 downto 14) is
        when "00" => dcd <= digit1;
        when "01" => dcd <= digit2;
        when "10" => dcd <= digit3;
        when others => dcd <= digit4;
        end case;
    end process;
    
    process(clk)
    begin
    if(rising_edge(clk)) then
        cnt<=cnt+1;
     end if;
    end process;
    
    
    process(cnt(15 downto 14))
    begin
        case cnt(15 downto 14) is
            when "00" => an <= "1110";
            when "01" => an <= "1101";
            when "10" => an <= "1011";
            when others => an <="0111";
        end case;
    end process;
    
    
    process(dcd)
    begin
        case dcd is
            when X"0" => cat <= "1000000"; --0;
                     when X"1" => cat <= "1111001"; --1
                     when X"2" => cat <= "0100100"; --2
                     when X"3" => cat <= "0110000"; --3
                     when X"4" => cat <= "0011001"; --4
                     when X"5" => cat <= "0010010"; --5
                     when X"6" => cat <= "0000010"; --6
                     when X"7" => cat <= "1111000"; --7
                     when X"8" => cat <= "0000000"; --8
                     when X"9" => cat <= "0010000"; --9
                     when X"A" => cat <= "0001000"; --A
                     when X"B" => cat <= "0000011"; --b
                     when X"C" => cat <= "1000110"; --C
                     when X"D" => cat <= "0100001"; --d
                     when X"E" => cat <= "0000110"; --E
                     when X"F" => cat <= "0001110"; --F
                     when others => cat <= "1111111"; -- gol
            
            
        end case;
    end process;
    
end Behavioral;
