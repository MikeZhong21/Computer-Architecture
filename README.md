# Project Description
This project aims at implementing a 5-stage pipeline CPU using Verilog. The CPU contains five stages: Instruction Fetching (IF), Instruction Decoding (ID), Executing (EX), Memory Access (MEM), and Write Back (WB). 

# Implementation

In the first clock cycle, the CPU read one instruction in the instruction memory with the
new given pc address. <br/>

In the second, the processor will divide the instruction to different
parts and decode the MIPS instruction with the registers and control unit. The operation
code and function code in MIPS instruction are sent to the control unit, which recognize
the type of an instruction. <br/>

In the third cycle, ALU will handle arithmetic, logical, shifting,
and conditional branch instructions. <br/>

In the fourth cycle, data will be fetched from or
stored to the data memory by data transfer instructions. <br/>

In the fifth cycle, data will be
written back to registers if needed. <br/>
