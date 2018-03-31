/* Description
 Testbench for the memory controller
*/

`timescale 1ns/1ns

module memcontroller_tb();

// Parameters

// Module Input
reg [5:0] opcode;
reg [1:0] MemSelect;

// Module Output
wire [3:0] MemWrite;
wire [3:0] MemRead;
wire MemMux1Sel;
wire [1:0] MemMux2Sel;
wire [1:0] MemMux3Sel;

localparam lw		= 6'h23;
localparam lbu		= 6'h24;
localparam lhu		= 6'h25;
localparam sb		= 6'h28;
localparam sh		= 6'h29;
localparam sw 		= 6'h2B;

initial begin
	// Store Byte
	opcode <= sb;
	MemSelect <= 2'b00;
	# 10;
	
	MemSelect <= 2'b01;
	# 10;
	
	MemSelect <= 2'b10;
	# 10;
	
	MemSelect <= 2'b11;
	# 10;
	
	// Store Half Word
	opcode <= sh;
	MemSelect <= 2'b00;
	# 10;
	
	MemSelect <= 2'b01;
	# 10;
	
	MemSelect <= 2'b10;
	# 10;
	
	// Store Word
	opcode <= sw;
	MemSelect <= 2'b00;
	# 10;
	
	MemSelect <= 2'b01;
	# 10;
	
	MemSelect <= 2'b10;
	# 10;
	
	MemSelect <= 2'b11;
	# 10;
	
	
	// ----- Load ------ //
	// Load Byte
	opcode <= lbu;
	MemSelect <= 2'b00;
	# 10;
	
	MemSelect <= 2'b01;
	# 10;
	
	MemSelect <= 2'b10;
	# 10;
	
	MemSelect <= 2'b11;
	# 10;
	
	// Load Half Word
	opcode <= lhu;
	MemSelect <= 2'b00;
	# 10;
	
	MemSelect <= 2'b01;
	# 10;
	
	MemSelect <= 2'b10;
	# 10;
	
	// Load Word
	opcode <= lw;
	MemSelect <= 2'b00;
	# 10;
	
	MemSelect <= 2'b01;
	# 10;
	
	MemSelect <= 2'b10;
	# 10;
	
	MemSelect <= 2'b11;
	# 10;
end

/**********
 * Components
 **********/
 memcontroller_r0 UUT(
	.opcode(opcode),
	.MemSelect(MemSelect),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.MemMux1Sel(MemMux1Sel),
	.MemMux2Sel(MemMux2Sel),
	.MemMux3Sel(MemMux3Sel)
 );
 
 endmodule