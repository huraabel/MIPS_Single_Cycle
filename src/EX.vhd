


library IEEE;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity EX is
 Port ( 
    RD1 : in std_logic_vector(15 downto 0);
    RD2 : in std_logic_vector(15 downto 0);
    Ext_Imm : in std_logic_vector(15 downto 0);
    ALUSrc : in std_logic;
    sa : in std_logic;
    func : in std_logic_vector(2 downto 0);
    AluOp : in std_logic_vector(1 downto 0);
    next_o : in  std_logic_vector(15 downto 0);
    
    Zero: out std_logic;
    GTZ : out std_logic;
    ALURes : out std_logic_vector(15 downto 0);
    br_adr : out std_logic_vector(15 downto 0)
    
   
 );
end EX;

architecture Behavioral of EX is

signal ALUCTRL : std_logic_vector(3 downto 0);
signal alu_second_entry : std_logic_vector(15 downto 0);
begin


process ( func , aluop)
begin
    case aluop is
        -- lw sw => add
        when "00" => aluctrl <= "0010";
        
        --beq, => sub
        when "01" => aluctrl <= "0110";
        
        --andi => and
        when "11" => aluctrl <= "0000";
        
        --type R
        when others => case func is
                     --add
                     when "000" => aluctrl <= "0010";
                     --sub
                     when "001" => aluctrl <= "0110";
                     --sll
                     when "010" => aluctrl <= "1000";
                     --srl
                     when "011" => aluctrl <= "1100";
                     --and
                     when "100" => aluctrl <= "0000";
                     --or
                     when "101" => aluctrl <= "0001";
                     --xor
                     when "110" => aluctrl <= "0011";
                     --nor
                     when others => aluctrl <= "0111";
                    
                     end case;
    
    end case;

end process;


process( RD2, Ext_imm, alusrc)
begin
    case alusrc is
        when '0' => alu_second_entry <= RD2;
        when others => alu_second_entry <= Ext_Imm;
    end case;
    
end process;





process( RD1, alu_second_entry, sa, aluctrl)
begin
    case ALUCTRL is
    --and
    when "0000" => alures <= rd1 and alu_second_entry;
                  
    --or
    when "0001" => alures <= rd1 or alu_second_entry;
                    
    --add
    when "0010" =>alures <= rd1 + alu_second_entry;
                                   
    --xor
    when "0011" => alures <= rd1 xor alu_second_entry;
                  
    --sub
    when "0110" =>alures <= rd1 - alu_second_entry;
                  
    --nor              
    when "0111" => alures <= rd1 nor alu_second_entry;
                 
     
     --shl
    when "1000" => if(sa='1') then
                     alures<= rd1(14 downto 0) & '0';
                    else
                     alures <= rd1;
                    end if;                       
     
     --srl 1100
    when others => if(sa ='1') then
                         alures<= '0' & rd1(15 downto 1) ;
                   else
                         alures <= rd1;
                    end if;                 
                    
    end case;

end process;






--flagurile ZERO si GTZ
process(RD1, alu_second_entry)
begin


    if(  ( rd1 - alu_second_entry)= X"0000") then
            zero <= '1';
    else
            zero <= '0';
    end if;
                  --rd(15)
                  if ( rd1(15)='1' or ( rd1=0)  ) then
                    gtz <='0';
                  else
                    gtz <= '1'; 
                  end if;
end process;


br_adr <= ext_imm + next_o;



end Behavioral;
