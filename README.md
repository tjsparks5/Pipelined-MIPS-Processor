# Pipelined MIPS Processor
32-bit MIPS processor written in Verilog while taking Digital Computer Architecture.

#### Details:
+ Implements instructions from the MIPS instruction set.
+ Five stage pipeline: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Write Back (WB). 
+ Data forwarding unit to eliminate data dependencies. Forwards from the MEM and WB stages to the EX stage.
+ Hazard detection unit which stalls the pipelne to eliminate hazards such as the load-use hazard and inserts noops for branches and jumps.
+ Separate instruction and data memories.
+ Datapath with program counter, pipeline registers, register file, ALU, and other processor components.
+ Main Controller and ALU Controller.


## Simulation
All simulation was done using [ModelSim Starter Edition](https://www.altera.com/downloads/software/modelsim-starter/120.html). The provided test benches in the `simulation_files/` folder can be used to test the final datapath or individual components.

In order to run the simulations for the processor create a new project and add all of the files from the `simulation_files/` and `source_files/` folders. Compile and then go to Simulate -> Start Simulation and choose the appropriate testbench from the "work" directory. When simulating the datapath place the .hex files from the `test programs/` folder in the root of the ModelSim project and change the file being read in `rom.v` from "data.hex" to the test to be run. Include signals from the UUT in the "sim" tab.

## Assembler and Disassembler
Included in the `assembler_disassembler/` folder are a MIPS assembler and disassembler written in Python. The assembler can be used to generate a .mif file from a given assembly program. The disassembler can be used to turn machine code (from a .mif file) into an assembly file.
