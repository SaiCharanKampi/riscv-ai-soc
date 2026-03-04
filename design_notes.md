**RV32I Processor Design Notes**
This document tracks the step-by-step development of a 32-bit RV32I processor in SystemVerilog.
The goal is to understand each hardware block clearly before integrating them into a full datapath.

1️⃣ Register Architecture (RV32I)
RV32I defines:
32 general-purpose registers
Each register is 32 bits wide
Register names: x0 – x31
Important details:
x0 is hardwired to 0
Registers are addressed using 5-bit fields
Register index fields appear in instruction encoding as:
rs1 → source register 1
rs2 → source register 2
rd → destination register
Register index encoding example:
x1 = 00001
x2 = 00010
x3 = 00011
These 5-bit values are extracted during instruction decoding.

2️⃣ Instruction Encoding Overview
All RV32I instructions are 32 bits.
Each instruction contains:
opcode (bits [6:0])
register fields (rs1, rs2, rd)
funct3
funct7 (for R-type)
immediate fields (depending on type)

3️⃣ Instruction Types Implemented So Far
🔹 R-Type (Register-Register Arithmetic)
Used for:
ADD
SUB
Field format:
[31:25] funct7
[24:20] rs2
[19:15] rs1
[14:12] funct3
[11:7]  rd
[6:0]   opcode

Example:
ADD x3, x1, x2

Binary structure:
0000000 00010 00001 000 00011 0110011

🔹 I-Type (Immediate Arithmetic / Loads)
Used for:
ADDI
LW
Field format:
[31:20] imm[11:0]
[19:15] rs1
[14:12] funct3
[11:7]  rd
[6:0]   opcode
Immediate is contiguous in bits [31:20].
Sign extension required.

🔹 S-Type (Store Instructions)
Used for:
SW
Immediate split across:
imm[11:5] = instr[31:25]
imm[4:0]  = instr[11:7]
Reconstruction required before address calculation.

🔹 B-Type (Branch Instructions)
Used for:
BEQ
Immediate scattered:
imm[12]   = instr[31]
imm[11]   = instr[7]
imm[10:5] = instr[30:25]
imm[4:1]  = instr[11:8]
imm[0]    = 0
Immediate must be reconstructed and shifted left by 1.

4️⃣ Immediate Generator Module
Objective
Design a combinational module that:
Takes 32-bit instruction as input
Extracts immediate based on opcode
Outputs 32-bit sign-extended immediate
Supported types:
I-type
S-type
B-type
Sign Extension Concept
If the immediate MSB = 1 → negative number
Upper bits must be filled with 1’s.

Example:
12-bit -1 = 111111111111
32-bit output = 11111111111111111111111111111111
This ensures correct signed arithmetic.

5️⃣ Verification Strategy
A directed testbench was written in ModelSim.
Tested:
Instruction	Expected Immediate
ADDI +5	5
ADDI -1	-1
SW +8	8
SW -4	-4
BEQ +16	16
BEQ -4	-4

Simulation Output:

ADDI +5 -> imm_out = 5
ADDI -1 -> imm_out = -1
SW +8 -> imm_out = 8
SW -4 -> imm_out = -4
BEQ +16 -> imm_out = 16
BEQ -4 -> imm_out = -4

All tests passed.

Waveform verification confirms correct extraction and sign extension.

6) Instruction Decoder (Control Signal Generation)
Objective
Design a simple instruction decoder that interprets the instruction opcode and generates control signals required by the processor datapath.
The decoder determines how the processor should behave for each instruction.

Why a Decoder is Needed?
The processor only sees a 32-bit instruction.
It does not directly understand instructions like:
ADD x3, x1, x2
SW x3, 8(x1)
BEQ x1, x2, 16
Instead, the processor reads the opcode field and generates control signals that guide the datapath.
These control signals determine:
whether a register should be written
whether memory should be read
whether memory should be written
whether the ALU should use an immediate value
whether a branch operation should occur
Control Signals Implemented
Signal	Purpose
reg_write	Enables writing data to destination register
mem_read	Enables reading from memory
mem_write	Enables writing to memory
alu_src	Selects ALU input (register or immediate)
branch	Indicates a branch instruction
Opcode Detection
The decoder reads the opcode from the instruction:
opcode = instr[6:0]
Each opcode corresponds to an instruction type.
Instruction	Opcode
R-type (ADD/SUB)	0110011
I-type (ADDI)	0010011
Load (LW)	0000011
Store (SW)	0100011
Branch (BEQ)	1100011
Decoder Behavior
R-Type (ADD)
reg_write = 1
alu_src   = 0
mem_read  = 0
mem_write = 0
branch    = 0

I-Type (ADDI)
reg_write = 1
alu_src   = 1
mem_read  = 0
mem_write = 0
branch    = 0

Load (LW)
reg_write = 1
mem_read  = 1
alu_src   = 1

Store (SW)
mem_write = 1
alu_src   = 1
reg_write = 0
Branch (BEQ)
branch = 1
reg_write = 0
Verification

The decoder was verified using a simple testbench in ModelSim.

Tested instructions:

Instruction	Expected Behavior
ADD	register write enabled
ADDI	register write + immediate ALU input
LW	memory read enabled
SW	memory write enabled
BEQ	branch signal enabled

Simulation output confirmed that the control signals were generated correctly for each instruction.
