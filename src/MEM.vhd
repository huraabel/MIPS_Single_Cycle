


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity MEM is
  Port ( 
  clk: in std_logic;
  en : in std_logic;
  MemWrite : in  std_logic;
  AluRes : in std_logic_vector(15 downto 0);
  rd2 : in std_logic_vector(15 downto 0);
  
  MemData : out std_logic_vector(15 downto 0)
  
  );
end MEM;

architecture Behavioral of MEM is
        
    type ram_array is array (0 to 63) of std_logic_vector (15 downto 0);
         signal  ram_file : ram_array := ( 
         16=>x"0000", 
         40=> X"0004", 41=>X"000A", 42=>x"0009", 43=>x"0000", 44=>x"0001", 45=>x"0006", 46=>x"0005", 47=>x"0002", 48=> x"000B", 49=>x"FFFF",
          
         others => X"0000"
         );    
        
        
begin


    process (clk)
	begin
		if (rising_edge(clk)) then
		  if(en='1') then
			 if ( MemWrite='1') then
				ram_file ( conv_integer(alures) ) <= rd2;
				--memdata <= rd2;
			 --else
			    -- memdata <= ram_file ( conv_integer(alures) );
			end if;
		  end if;
		end if;
	end process;
    --citire combinationala
    memdata <= ram_file ( conv_integer(alures) );
    
end Behavioral;
