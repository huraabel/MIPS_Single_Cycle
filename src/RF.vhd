library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity Registru is
	port(
	clk : in  std_logic;
	ra1 : in  std_logic_vector (2 downto 0);
	ra2 : in  std_logic_vector (2 downto 0);
	wa  : in  std_logic_vector (2 downto 0);
	wd  : in  std_logic_vector (15 downto 0); 
	wen : in  std_logic;
	RegWrite: in std_logic;
	rd1 : out std_logic_vector (15 downto 0);
	rd2 : out std_logic_vector (15 downto 0)
	);
end entity;

architecture Reg of Registru is

	type registru_array is array (0 to 7) of std_logic_vector (15 downto 0);
	
   	signal reg_file : registru_array :=
   	( (X"0000"), (X"0000"),(X"0000"),(X"0000"),
   	(X"0000"),(X"0000"),(X"0000"),(X"0000")
   	)
   	;

begin  
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (wen ='1' and RegWrite='1') then
				reg_file ( conv_integer(wa) ) <= wd;
			end if;
		end if;
	end process; 
	
	rd1 <= reg_file( conv_integer(ra1));
	rd2 <= reg_file( conv_integer(ra2)); 
end;