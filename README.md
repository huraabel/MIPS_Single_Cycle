# MIPS_Single_Cycle

A MIPS (Microprocessor without Interlocked Pipelined Stages) Processor 16 bits, written in vhdl 
for the NEXYS 4 DDR FPGA from Xillinx.

The processor has the following stages: IF - Instruction Fetch, ID - Instruction Decode
EX : Execution, MEM - Memory

Other description: MPG : monopulse generator ; SSD : seven-segment decoder

The programm that the processor executes is located in IF.vhd : iterates on an array
and saves in memory if the a value is found.