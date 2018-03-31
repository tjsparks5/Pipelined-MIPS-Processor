/* Description
 Testbench for the ALU Controller module
*/

`timescale 1ns/1ns

module alu_controller_tb();

// Parameters
 localparam ALUadd = 3'b000;
 localparam ALUsub = 3'b001;
 localparam ALUand = 3'b010;
 localparam ALUor  = 3'b011;
 localparam ALUxor = 3'b100;
 localparam ALUslt = 3'b101;
 localparam ALURtp = 3'b111;

// Module Input
reg [2:0] ALUOp;
reg [5:0] funcode;
	
// Module Output
wire [4:0] ALUCtrl;

initial begin
	ALUOp <= ALUadd;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALUsub;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALUand;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALUor;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALUxor;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALUslt;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h20;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h21;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h22;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h23;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h18;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h19;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h00;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h04;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h02;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h06;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h03;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h07;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h10;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h12;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h11;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h13;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h24;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h25;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h26;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h27;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h2A;
	# 15;
	
	ALUOp <= ALURtp;
	funcode <= 6'h2B;
	# 15;
end

/**********
 * Components
 **********/
 alu_controller_r0 #(
 )UUT(
	.ALUOp(ALUOp),
	.funcode(funcode),
	.ALUCtrl(ALUCtrl)
 );
 
 endmodule