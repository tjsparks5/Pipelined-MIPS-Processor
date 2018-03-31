/* Description
 Testbench for the Main Controller module
*/

`timescale 1ns/1ns

module controller_tb();

// Parameters
 localparam R_Type 	= 6'h00;
 localparam j		= 6'h02;
 localparam jal		= 6'h03;
 localparam beq		= 6'h04;
 localparam bne		= 6'h05;
 //localparam blez	= 6'h06;
 //localparam bgtz	= 6'h07;
 localparam addi 	= 6'h08;
 localparam addiu 	= 6'h09;
 localparam slti 	= 6'h0A;
 localparam sltiu	= 6'h0B;
 localparam andi	= 6'h0C;
 localparam ori		= 6'h0D;
 localparam xori	= 6'h0E;
 localparam lui		= 6'h0F;
 //localparam lb	= 6'h20;
 //localparam lh	= 6'h21;
 //localparam lwl	= 6'h22;
 localparam lw		= 6'h23;
 localparam lbu		= 6'h24;
 localparam lhu		= 6'h25;
 //localparam lwr	= 6'h26;
 localparam sb		= 6'h28;
 localparam sh		= 6'h29;
 //localparam swl	= 6'h2A;
 localparam sw 		= 6'h2B;
 //localparam swr	= 6'h2E;


// Module Input
reg [5:0] opcode;
	
// Module Output
wire [1:0] RegDst;
wire ALUSrc;
wire MemtoReg;
wire RegWrite;
wire [1:0] RegWriteSrc;
wire MemRead;
wire MemWrite;
wire Jump;
wire BranchBEQ;
wire BranchBNE;
wire [2:0] ALUOp;

initial begin
	opcode <= R_Type;
	# 15;
	
	opcode <= j;
	# 15;
	
	opcode <= jal;
	# 15;
	
	opcode <= beq;
	# 15;
	
	opcode <= bne;
	# 15;
	
	opcode <= addi;
	# 15;
	
	opcode <= addiu;
	# 15;
	
	opcode <= slti;
	# 15;
	
	opcode <= sltiu;
	# 15;
	
	opcode <= andi;
	# 15;
	
	opcode <= ori;
	# 15;
	
	opcode <= xori;
	# 15;
	
	opcode <= lui;
	# 15;
	
	opcode <= lw;
	# 15;
	
	opcode <= lbu;
	# 15;
	
	opcode <= lhu;
	# 15;
	
	opcode <= sb;
	# 15;
	
	opcode <= sh;
	# 15;
	
	opcode <= sw;
	# 15;
end

/**********
 * Components
 **********/
 controller_r0 #(
 )UUT(
	.opcode(opcode),
	.RegDst(RegDst),
	.ALUSrc(ALUSrc),
	.MemtoReg(MemtoReg),
	.RegWrite(RegWrite),
	.RegWriteSrc(RegWriteSrc),
	.MemRead(MemRead),
	.MemWrite(MemWrite),
	.Jump(Jump),
	.BranchBEQ(BranchBEQ),
	.BranchBNE(BranchBNE),
	.ALUOp(ALUOp)
 );
 
 endmodule