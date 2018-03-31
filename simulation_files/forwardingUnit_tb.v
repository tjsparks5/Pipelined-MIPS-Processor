/* Description
 Testbench for the forwarding unit
*/

`timescale 1ns/1ns

module forwardingUnit_tb();

// Parameters
parameter BIT_WIDTH = 5;

// Module Input
reg [BIT_WIDTH - 1:0] ID_EX_Rs;
reg [BIT_WIDTH - 1:0] ID_EX_Rt;
reg [BIT_WIDTH - 1:0] EX_MEM_Rd;
reg [BIT_WIDTH - 1:0] MEM_WB_Rd;
reg EX_MEM_RegWrite;
reg MEM_WB_RegWrite;

// Module Output
wire [1:0] ForwardA;
wire [1:0] ForwardB;

initial begin
	ID_EX_Rs = 5'b00001;
	ID_EX_Rt = 5'b00001;
	EX_MEM_Rd = 5'b00001;
	MEM_WB_Rd = 5'b00001;
	EX_MEM_RegWrite = 1'b1;
	MEM_WB_RegWrite = 1'b1;
	#20;
	
	ID_EX_Rs = 5'b00001;
	ID_EX_Rt = 5'b00010;
	EX_MEM_Rd = 5'b00001;
	MEM_WB_Rd = 5'b00010;
	EX_MEM_RegWrite = 1'b1;
	MEM_WB_RegWrite = 1'b1;
	#20;
	
	ID_EX_Rs = 5'b00010;
	ID_EX_Rt = 5'b00001;
	EX_MEM_Rd = 5'b00001;
	MEM_WB_Rd = 5'b00010;
	EX_MEM_RegWrite = 1'b1;
	MEM_WB_RegWrite = 1'b1;
	#20;
	
	ID_EX_Rs = 5'b01010;
	ID_EX_Rt = 5'b01010;
	EX_MEM_Rd = 5'b01010;
	MEM_WB_Rd = 5'b01010;
	EX_MEM_RegWrite = 1'b0;
	MEM_WB_RegWrite = 1'b1;
	#20;
	
	ID_EX_Rs = 5'b01010;
	ID_EX_Rt = 5'b01010;
	EX_MEM_Rd = 5'b01010;
	MEM_WB_Rd = 5'b01010;
	EX_MEM_RegWrite = 1'b0;
	MEM_WB_RegWrite = 1'b0;
	#20;
	
	ID_EX_Rs = 5'b01010;
	ID_EX_Rt = 5'b01010;
	EX_MEM_Rd = 5'b01111;
	MEM_WB_Rd = 5'b01010;
	EX_MEM_RegWrite = 1'b1;
	MEM_WB_RegWrite = 1'b1;
	#20;
	
	ID_EX_Rs = 5'b00000;
	ID_EX_Rt = 5'b00000;
	EX_MEM_Rd = 5'b00000;
	MEM_WB_Rd = 5'b00000;
	EX_MEM_RegWrite = 1'b1;
	MEM_WB_RegWrite = 1'b1;
	#20;
end

/**********
 * Components
 **********/
 forwardingUnit_r0 #(
	.BIT_WIDTH(BIT_WIDTH)
 ) UUT(
	.ID_EX_Rs(ID_EX_Rs),
	.ID_EX_Rt(ID_EX_Rt),
	.EX_MEM_Rd(EX_MEM_Rd),
	.MEM_WB_Rd(MEM_WB_Rd),
	.EX_MEM_RegWrite(EX_MEM_RegWrite),
	.MEM_WB_RegWrite(MEM_WB_RegWrite),
	.ForwardA(ForwardA),
	.ForwardB(ForwardB)
 );
 
 endmodule