

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity ID is
   Port (
        CLK : in std_logic;
        EN : in std_logic;
        RegWrite : in std_logic;
        Instr : in std_logic_vector(15 downto 0);
        RegDst : in std_logic;
        ExtOp : in std_logic;
        
        WA : in std_logic_vector(2 downto 0);
        WD : in std_logic_vector(15 downto 0);
        
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        Ext_Imm : out std_logic_vector(15 downto 0);
        func : out std_logic_vector(2 downto 0);
        sa : out std_logic ;
        Pass_writeAdress : out std_logic_vector(2 downto 0)
   
    );
end ID;

architecture Behavioral of ID is
    
    component Registru is
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
  end component;
    
   signal WriteAddress  : std_logic_vector(2 downto 0);
   signal sE : std_logic:='0';
begin


    process( Instr(9 downto 7), Instr(6 downto 4), RegDst)
    begin
        case RegDst is
            when '0' =>     WriteAddress <= Instr(9 downto 7);
            when others =>  WriteAddress <= Instr(6 downto 4);
        end case;
    end process;
    
    Pass_writeAdress <= WriteAddress;
    
    RF1:  Registru port map (CLK, Instr(12 downto 10), Instr(9 downto 7),WA,
          WD,en, RegWrite, RD1, RD2);  
    
    func <= Instr(2 downto 0);
    sa <= Instr(3);
    
    sE <= '0' when Instr(6)='0' else '1'; -- sign Extend
    
    process( Instr(6 downto 0), ExtOp)
    begin
    case ExtOp is
        when '0' => Ext_Imm <= "000000000"&Instr(6 downto 0);
        when others => Ext_Imm <= sE& sE& sE& sE& sE& sE& sE& sE& sE& Instr(6 downto 0);
    end case;
    end process;
    

end Behavioral;
