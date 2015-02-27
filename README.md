# Elec 450 pipelined cpu

## Implemented
- 8-bit register file containing 4 registers, 2 read ports and synchronous write (write on rising edge, read on falling)
- Asynchronous ALU supporting add, sub, shift left/right, and nand, as well as negative and zero flags (currently not used)
- Instruction memory containing 127 bytes of instructions (mostly No-ops at the moment)
- 4 stage pipelined CPU core implementing all ALU operations (with operand forwarding)
- IN instruction to read from data port and OUT to read register to out port

## Goals:
- Complete Type-A instructions (MOV)
 - Shift left in ALU currently disabled
- Type B instructions including 3 branch instructions and RETURN
- Two-byte L-format instructions: Load, Store and Load Immediate


