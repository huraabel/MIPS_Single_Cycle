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
          
          WA : in std_logic_vector(2 downto 0);
          WD : in std_logic_vector(15 downto 0);
          
          RD1: out std_logic_vector(15 downto 0);
          RD2: out std_logic_vector(15 downto 0);
          Ext_Imm : out std_logic_vector(15 downto 0);
          func : out std_logic_vector(2 downto 0);
          sa : out std_logic ;
          Pass_writeAdress : out std_logic_vector(2 downto 0)  
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
    
    --PIPELINE
    signal IF_PC_1 : std_logic_vector(15 downto 0);
    signal IF_Instruction : std_logic_vector(15 downto 0);
    
    signal ID_Instruction : std_logic_vector(15 downto 0);
    signal ID_PC_1 : std_logic_vector(15 downto 0);
    signal ID_RD1 : std_logic_vector(15 downto 0);
    signal ID_RD2 : std_logic_vector(15 downto 0);
    signal ID_EXT_IMM : std_logic_vector(15 downto 0);
    signal ID_FUNC : std_logic_vector(2 downto 0);
    signal ID_MemtoReg : std_logic;
    signal ID_RegWrite : std_logic;
    signal ID_branch_gtz : std_logic;
    signal ID_Branch : std_logic;
    signal ID_memwrite : std_logic;
    signal ID_EXTOP : std_logic;
    signal ID_ALUOP : std_logic_vector(1 downto 0);
    signal ID_ALUSRC : std_logic;
    signal ID_regdst : std_logic;
    signal ID_WriteAdress : std_logic_vector(15 downto 0);
     signal ID_BranchAdress : std_logic_vector(15 downto 0);
     signal ID_JumpAdress : std_logic_vector(15 downto 0);
     signal ID_jump : std_logic;
     signal ID_SA : std_logic;
     signal ID_pass_writeAdress :std_logic_vector(2 downto 0);
     
    signal EX_SA : std_logic;
    signal EX_ALUOP : std_logic_vector (1 downto 0); 
    signal EX_ALUSRC : std_logic;
    signal EX_memtoReg: std_logic;
    signal EX_regWrite: std_logic;
    signal EX_Branch: std_logic;
    signal EX_branch_gtz: std_logic;
    signal EX_memwrite: std_logic;
    signal EX_PC_1 : std_logic_vector(15 downto 0);
    signal EX_branch_address: std_logic_vector(15 downto 0);
    signal EX_zero : std_logic;
    signal EX_GTZ : std_logic;
    signal EX_AluResult: std_logic_vector(15 downto 0);
    signal EX_RD1 : std_logic_vector(15 downto 0);
    signal EX_RD2 : std_logic_vector(15 downto 0);
    signal EX_WirteAdress: std_logic_vector(15 downto 0);
    signal EX_EXT_IMM : std_logic_vector(15 downto 0);
    signal EX_func : std_logic_vector(2 downto 0);
    signal EX_pass_writeAdress : std_logic_vector(2 downto 0);
   -- signal EX_PCSRC : std_logic;
    
    signal MEM_memwrite : std_logic;
    signal MEM_MemtoReg : std_logic;
    signal MEM_RegWrite: std_logic;
    signal MEM_pcsrc: std_logic;
    signal MEM_ReadData : std_logic_vector(15 downto 0);
    signal MEM_AluResult : std_logic_vector(15 downto 0);
    signal MEM_pass_WriteAdress : std_logic_vector(2 downto 0);
    signal MEM_BranchAdress : std_logic_vector(15 downto 0);
    signal MEM_RD2 : std_logic_vector(15 downto 0);
    signal MEM_branch : std_logic;
    signal MEM_branch_gtz : std_logic;
    signal MEM_gtz : std_logic;
    signal MEM_zero : std_logic;
    
    signal WB_WA : std_logic_vector(2 downto 0);
    signal WB_WD : std_logic_vector(15 downto 0);
    signal WB_readData : std_logic_vector(15 downto 0);
    signal WB_ALUresult : std_logic_vector(15 downto 0);
    signal WB_RegWrite : std_logic;
    signal WB_MemtoReg : std_logic;
    
begin
    
    
    M : MPG port map ( btn(0), clk, ce);
    M2: MPG port map (btn(1), clk, reset_pc_en);
    
    
    IF11: IF1 port map(clk,ce,MEM_BranchAdress,ID_JumpAdress,MEM_pcsrc,ID_jump,reset_pc_en, IF_Instruction, IF_PC_1);                         
    
    ID_JumpAdress<= ID_PC_1(15 downto 13) & ID_Instruction(12 downto 0);
    
    --IF/ID
    process(clk)
    begin 
    if(rising_edge(clk)) then
        if(ce = '1') then
            ID_Instruction <= IF_Instruction;
            ID_PC_1 <= IF_PC_1;
         end if;
    end if;
    end process;
    
    ID11: ID port map(clk,ce,WB_regwrite,ID_Instruction,ID_regdst,ID_extop,WB_WA,WB_WD,ID_rd1,ID_rd2,ID_EXT_IMM,ID_func,ID_sa,ID_pass_writeAdress );
    
    --CONTROLS
    process(ID_Instruction)
        begin
        
        case ID_Instruction(15 downto 13) is
            --type R--
           when "000" => ID_regdst<='1'; ID_regwrite<='1'; ID_alusrc<='0'; --pcsrc<='0';
                         ID_memwrite<='0'; ID_memtoreg<='0'; ID_jump<='0'; ID_branch<='0';
                         ID_branch_gtz<='0'; ID_extop<='0'; ID_aluop<="10";
                        
            --ADDI--
           when "001" =>  ID_regdst<='0'; ID_regwrite<='1'; ID_alusrc<='1'; --pcsrc<='0';
                          ID_memwrite<='0'; ID_memtoreg<='0'; ID_jump<='0'; ID_branch<='0';
                         ID_branch_gtz<='0'; ID_extop<='1'; ID_aluop<="00";
            -- LW
           when "010" => ID_regdst<='0'; ID_regwrite<='1'; ID_alusrc<='1'; --pcsrc<='0';
                         ID_memwrite<='0'; ID_memtoreg<='1'; ID_jump<='0'; ID_branch<='0';
                         ID_branch_gtz<='0'; ID_extop<='1'; ID_aluop<="00";
            --SW             
           when "011" =>ID_regdst<='0'; ID_regwrite<='0'; ID_alusrc<='1'; --pcsrc<='0';
                        ID_memwrite<='1'; ID_memtoreg<='0'; ID_jump<='0'; ID_branch<='0';
                        ID_branch_gtz<='0'; ID_extop<='1'; ID_aluop<="00";
           --BEQ
           when "100" =>ID_regdst<='0'; ID_regwrite<='0'; ID_alusrc<='0';-- pcsrc<='1';
                        ID_memwrite<='0'; ID_memtoreg<='0'; ID_jump<='0'; ID_branch<='1';
                        ID_branch_gtz<='0'; ID_extop<='1'; ID_aluop<="01";
           --BGTZ
           when "101" =>ID_regdst<='0'; ID_regwrite<='0'; ID_alusrc<='0'; --pcsrc<='1';
                        ID_memwrite<='0'; ID_memtoreg<='0'; ID_jump<='0'; ID_branch<='0';
                        ID_branch_gtz<='1'; ID_extop<='1'; ID_aluop<="01";
           --ANDI
           when "110" =>ID_regdst<='0'; ID_regwrite<='1'; ID_alusrc<='1'; --pcsrc<='0';
                        ID_memwrite<='0'; ID_memtoreg<='0'; ID_jump<='0'; ID_branch<='0';
                        ID_branch_gtz<='0'; ID_extop<='0'; ID_aluop<="11";
           --JUMP
           when "111"=>ID_regdst<='0'; ID_regwrite<='0'; ID_alusrc<='0'; --pcsrc<='0';
                       ID_memwrite<='0'; ID_memtoreg<='0'; ID_jump<='1'; ID_branch<='0';
                       ID_branch_gtz<='0'; ID_extop<='0'; ID_aluop<="00";
           
           when others => null;       
        end case;
        
        end process;
    
    --ID/EX
     process(clk)
       begin 
       if(rising_edge(clk)) then
           if(ce = '1') then
             EX_PC_1 <= ID_PC_1;
             EX_EXT_IMM <= ID_EXT_IMM;
             EX_func <= ID_func;
             EX_pass_writeAdress <= ID_pass_writeAdress;
             EX_RD1 <= ID_RD1;
             EX_RD2 <= ID_RD2;
             EX_ALUOP <= ID_ALUOP;
             EX_ALUSRC<= ID_ALUSRC;
             EX_MEMTOREG <= ID_MEMTOREG;
             EX_MEMWRITE <= ID_MEMWRITE;
             EX_BRANCH <= ID_BRANCH;
             EX_BRANCH_GTZ <= ID_BRANCH_GTZ;
             EX_REGWRITE <= ID_REGWRITE;
             EX_SA <= ID_SA;
           end if;
       end if;
       end process;
    
    
    Ex11 : EX port map(EX_rd1,EX_rd2,EX_ext_imm,EX_alusrc,EX_sa,EX_func,EX_aluop,EX_PC_1,EX_zero,EX_gtz,EX_aluresult,EX_branch_address);
    
    --EX/MEM
    process(clk)
           begin 
           if(rising_edge(clk)) then
               if(ce = '1') then
                 MEM_BranchAdress <= EX_branch_address;
                 MEM_MEMTOREG <= EX_MEMTOREG;
                 MEM_MEMWRITE <= EX_MEMWRITE;
                 MEM_aluresult <= EX_aluresult;
                 MEM_RD2 <= EX_Rd2;
                 MEM_pass_writeAdress <= EX_pass_writeAdress;
                 MEM_Branch <= EX_branch;
                 MEM_branch_gtz <=EX_branch_gtz;
                 MEM_regWrite <= EX_regwrite;
                 MEM_zero <= EX_zero;
                 MEM_GTZ <= EX_GTZ;
               end if;
           end if;
    end process;
    
    Mem11: MEM port map(clk,ce,MEM_memwrite,MEM_aluresult,MEM_rd2,MEM_ReadData);
    
    --MEM/WB
     process(clk)
        begin 
           if(rising_edge(clk)) then
             if(ce = '1') then
                WB_Regwrite<= MEM_regwrite;
                WB_memtoreg <= MEM_memtoreg;
                WB_readData <= MEM_readData;
                WB_ALUresult <= MEM_aluresult;
                WB_WA <= MEM_pass_writeAdress;    
             end if;
         end if;
     end process;
    
    WB_WD <= WB_readData when WB_memtoreg = '1' else WB_ALUresult;
    
    --MEM_PCSRC
        process(MEM_branch,MEM_zero,MEM_branch_gtz,MEM_gtz)
        begin
             MEM_pcsrc <= (MEM_branch and MEM_zero) or ( MEM_branch_gtz and MEM_gtz);
        end process;
    
    
     --leduri
           process(regdst,regwrite,alusrc,pcsrc,memwrite,memtoreg,jmp,branch,branch_gtz,extop, aluop)
           begin
           led(15) <= ID_regdst;
           led(14) <= ID_regwrite;
           led(13) <= ID_alusrc;
           led(12) <= MEM_pcsrc;
           led(11) <= ID_memwrite;
           led(10) <= ID_memtoreg;
           led(9) <= ID_jump;
           led(8) <= ID_branch;
           led(7) <= ID_branch_gtz;
           led(6) <= ID_extop;
           led(5 downto 4) <= ID_aluop;
           led(3)<=EX_zero;
           led(2)<=EX_gtz;
           led(1 downto 0) <= "11"; 
          -- led <= cur_o;
           end process;
    
    
    
    process(sw,IF_Instruction,IF_PC_1,rd1,rd2,wd,ext_imm)
            begin
                case sw is
                    when "0000" => o <= IF_Instruction;
                    when "0001" => o <=IF_PC_1;
                    when "0010" => o <=ID_rd1;
                    when "0011" => o <=ID_rd2;
                    when "0100" => o <=ID_ext_imm;
                    when "0101" => o <=  EX_aluresult;
                    when "0110" => o <= MEM_readData;
                    when "0111" => o <=WB_wd;
                    when "1000" => o <=MEM_BranchAdress;
                    when "1001" => o <= ID_JumpAdress;
                    when others => o <=x"0000";
                end case;
            end process;
             
     SSD1 : SSD port map (o(3 downto 0), o(7 downto 4), o(11 downto 8),   o(15 downto 12),clk, cat,an(3 downto 0) );
                                     
     an(7 downto 4) <="1111"; 
    
    
end Behavioral;
