library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MPG is 
	port(
	btn  : in std_logic ;	 
	clk : in std_logic;
	enable: out std_logic);
end;

architecture behave of MPG is

signal cnt : std_logic_vector (15 downto 0) :=x"0000";
signal Q1,Q2,Q3 : std_logic ;


begin
	
	
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			cnt <= cnt +1;
		end if;
	end process;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if( cnt = X"FFFF" ) then
				Q1 <= btn;
			end if;
		end if;
   	end process;
	   
	
	 process(clk)
	 begin
		 if(rising_edge(clk))
			then Q2 <= Q1;
			Q3 <= Q2;
		end if;
	end process;
	
	enable	<= Q2 and ( not(Q3));
	   
end;