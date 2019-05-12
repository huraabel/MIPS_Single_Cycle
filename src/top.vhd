----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2019 12:17:12 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
Port ( 
    btn : in std_logic_vector(1 downto 0);
    clk : in std_logic;
    cat : out std_logic_vector (6 downto 0);
    led : out std_logic_vector(15 downto 0);
    sw : in std_logic_vector(3 downto 0);
    
    an : out std_logic_vector (7 downto 0)
   );
end top;

architecture Behavioral of top is


component MPG is
  port(
      btn  : in std_logic ;     
      clk : in std_logic;
      enable: out std_logic
      );
  end component;

  component SSD is
  Port ( 
           digit1 : in std_logic_vector (3 downto 0);
           digit2 : in std_logic_vector (3 downto 0);
           digit3 : in std_logic_vector (3 downto 0);
           digit4 : in std_logic_vector (3 downto 0);  
           clk : in std_logic;
           cat : out std_logic_vector (6 downto 0);
           an : out std_logic_vector (3 downto 0)
           );
  end component;
  
 
  
 component IF1 is
    Port (
      clk : in std_logic;
      ce : in std_logic;
      addr_branch : in std_logic_vector(15 downto 0);
      addr_jump : in std_logic_vector(15 downto 0);
      PCSrc : in std_logic;
      JUMP : in std_logic;
      reset_pc:in std_logic;
      curent_instruction: out std_logic_vector(15 downto 0);
      next_instruction : out std_logic_vector(15 downto 0)
      
     );
  end component;
  
  
  component ID is
     Port (
          CLK : in std_logic;
          EN : in std_logic;
          RegWrite : in std_logic;
          Instr : in std_logic_vector(15 downto 0);
          RegDst : in std_logic;
          ExtOp : in std_logic;
          
         
          WD : in std_logic_vector(15 downto 0);
          
          RD1: out std_logic_vector(15 downto 0);
          RD2: out std_logic_vector(15 downto 0);
          Ext_Imm : out std_logic_vector(15 downto 0);
          func : out std_logic_vector(2 downto 0);
          sa : out std_logic  
      );
 end component ID;
 
 component EX is
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
 end component EX;
 
component MEM is
   Port ( 
   clk: in std_logic;
   en : in std_logic;
   MemWrite : in  std_logic;
   AluRes : in std_logic_vector(15 downto 0);
   rd2 : in std_logic_vector(15 downto 0);
   
   MemData : out std_logic_vector(15 downto 0)
   
   );
 end component MEM;
 
  
  
  --IF
  signal reset_pc_en :std_logic;
  signal cnt: std_logic_vector ( 7 downto 0) := "00000000";
  signal ce : std_logic;
  signal cur_o  : std_logic_vector ( 15 downto 0) := X"0000";
  signal next_o  : std_logic_vector ( 15 downto 0) := X"0000";
  
  signal br_adr : std_logic_vector(15 downto 0):= X"0000";
  signal jump_adr: std_logic_vector(15 downto 0):= X"0000";
  
  signal o  : std_logic_vector ( 15 downto 0) := X"0000";
  
  --ID
  signal regWrite : std_logic;
  
  signal         RegDst :  std_logic;
  signal         ExtOp :  std_logic;
        
  signal         WD :  std_logic_vector(15 downto 0);        
  signal         RD1:  std_logic_vector(15 downto 0);
  signal         RD2:  std_logic_vector(15 downto 0);
   signal        Ext_Imm :  std_logic_vector(15 downto 0);
   signal        func :  std_logic_vector(2 downto 0);
   signal        sa :  std_logic ;
  
  --controller
  signal alusrc: std_logic;
  signal branch :std_logic;
  signal branch_gtz :std_logic;
  signal jmp :std_logic;
  signal pcsrc:std_logic;
  signal aluop: std_logic_vector(1 downto 0);
  signal memWrite:std_logic;
  signal memtoreg:std_logic;
    
    --ex
    signal zero : std_logic;
    signal gtz: std_logic;
    signal alures : std_logic_vector(15 downto 0);
    
    --mem
    signal memdata : std_logic_vector(15 downto 0);
    
    
    
begin
    
    
    M : MPG port map ( btn(0), clk, ce);
    M2: MPG port map (btn(1), clk, reset_pc_en);
    
   IF11: IF1 port map(clk,ce,br_adr,jump_adr,pcsrc,jmp,reset_pc_en,cur_o,next_o);
    
    --controller
    process(cur_o)
    begin
    
    case cur_o(15 downto 13) is
        --type R--
       when "000" =>regdst<='1'; regwrite<='1'; alusrc<='0'; --pcsrc<='0';
                     memwrite<='0'; memtoreg<='0'; jmp<='0'; branch<='0';
                     branch_gtz<='0'; extop<='0'; aluop<="10";
                    
        --ADDI--
       when "001" =>regdst<='0'; regwrite<='1'; alusrc<='1'; --pcsrc<='0';
                      memwrite<='0'; memtoreg<='0'; jmp<='0'; branch<='0';
                      branch_gtz<='0'; extop<='1'; aluop<="00";
        -- LW
       when "010" =>regdst<='0'; regwrite<='1'; alusrc<='1'; --pcsrc<='0';
                     memwrite<='0'; memtoreg<='1'; jmp<='0'; branch<='0';
                     branch_gtz<='0'; extop<='1'; aluop<="00";
        --SW             
       when "011" =>regdst<='0'; regwrite<='0'; alusrc<='1'; --pcsrc<='0';
                    memwrite<='1'; memtoreg<='0'; jmp<='0'; branch<='0';
                    branch_gtz<='0'; extop<='1'; aluop<="00";
       --BEQ
       when "100" =>regdst<='0'; regwrite<='0'; alusrc<='0';-- pcsrc<='1';
                    memwrite<='0'; memtoreg<='0'; jmp<='0'; branch<='1';
                    branch_gtz<='0'; extop<='1'; aluop<="01";
       --BGTZ
       when "101" =>regdst<='0'; regwrite<='0'; alusrc<='0'; --pcsrc<='1';
                    memwrite<='0'; memtoreg<='0'; jmp<='0'; branch<='0';
                    branch_gtz<='1'; extop<='1'; aluop<="01";
       --ANDI
       when "110" =>regdst<='0'; regwrite<='1'; alusrc<='1'; --pcsrc<='0';
                    memwrite<='0'; memtoreg<='0'; jmp<='0'; branch<='0';
                    branch_gtz<='0'; extop<='0'; aluop<="11";
       --JUMP
       when "111"=>regdst<='0'; regwrite<='0'; alusrc<='0'; --pcsrc<='0';
                   memwrite<='0'; memtoreg<='0'; jmp<='1'; branch<='0';
                   branch_gtz<='0'; extop<='0'; aluop<="00";
       
       when others => null;       
    end case;
    
    end process;
    
    --leduri
    process(regdst,regwrite,alusrc,pcsrc,memwrite,memtoreg,jmp,branch,branch_gtz,extop, aluop)
    begin
    led(15) <= regdst;
    led(14) <= regwrite;
    led(13) <= alusrc;
    led(12) <= pcsrc;
    led(11) <= memwrite;
    led(10) <= memtoreg;
    led(9) <= jmp;
    led(8) <= branch;
    led(7) <= branch_gtz;
    led(6) <= extop;
    led(5 downto 4) <= aluop;
    led(3)<=zero;
    led(2)<=gtz;
    led(1 downto 0) <= "11"; 
   -- led <= cur_o;
    end process;
    
    --sa <= cur_o(3);
    ID11: ID port map(clk,ce,regwrite,cur_o,regdst,extop,wd,rd1,rd2,ext_imm,func,sa );
    
    Ex11 : EX port map(rd1,rd2,ext_imm,alusrc,sa,func,aluop,next_o,zero,gtz,alures,br_adr);
    
    Mem11: MEM port map(clk,ce,memwrite,alures,rd2,memdata);
    
    --wride data
    wd <= memdata when memtoreg = '1' else alures;  
    
    --and jump address
    jump_adr <= "000" & cur_o(12 downto 0);
    
    --PCSRC
    process(branch,zero,branch_gtz,gtz)
    begin
         pcsrc <= (branch and zero) or ( branch_gtz and gtz);
    end process;
    
     
    process(sw,cur_o,next_o,rd1,rd2,wd,ext_imm)
    begin
        case sw is
            when "0000" => o <= cur_o;
            when "0001" => o <=next_o;
            when "0010" => o <=rd1;
            when "0011" => o <=rd2;
            when "0100" => o <=ext_imm;
            when "0101" => o <= alures;
            when "0110" => o <= memdata;
            when "0111" => o <=wd;
            when "1000" => o <=br_adr;
            when "1001" => o <=jump_adr;
            when others => o <=x"0000";
        end case;
    end process;
     
    SSD1 : SSD port map (o(3 downto 0), o(7 downto 4), o(11 downto 8),   o(15 downto 12),clk, cat,an(3 downto 0) );
                             
    an(7 downto 4) <="1111";     
    
    
end Behavioral;
