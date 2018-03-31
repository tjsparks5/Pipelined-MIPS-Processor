/*
DESCRIPTION
ALU Controller Module

NOTES

TODO
*/

module alu_controller_r0 (
	input [2:0] ALUOp,		// ALUOp from the main controller
	input [5:0] funcode,	// Function code from instruction
	output [4:0] ALUCtrl,	// ALU function
	output JumpReg
);

/**********
 * Internal Signals
**********/
reg [4:0] ALUCtrl_tmp;
reg JumpReg_tmp;

/**********
 * Glue Logic 
 **********/
 // ALUOp Signals
 localparam ALUadd = 3'b000;
 localparam ALUsub = 3'b001;
 localparam ALUand = 3'b010;
 localparam ALUor  = 3'b011;
 localparam ALUxor = 3'b100;
 localparam ALUslt = 3'b101;
 localparam ALURtp = 3'b111;
 
 // Function codes
 localparam fun_sll		= 6'h00;
 localparam fun_srl		= 6'h02;
 localparam fun_sra		= 6'h03;
 localparam fun_sllv	= 6'h04;
 localparam fun_srlv	= 6'h06;
 localparam fun_srav	= 6'h07;
 localparam fun_jr		= 6'h08;
 //localparam fun_jalr	= 6'h09;
 localparam fun_mfhi	= 6'h10;
 localparam fun_mthi	= 6'h11;
 localparam fun_mflo	= 6'h12;
 localparam fun_mtlo	= 6'h13;
 localparam fun_mult	= 6'h18;
 localparam fun_multu	= 6'h19;
 localparam fun_div		= 6'h1A;
 localparam fun_divu	= 6'h1B;
 localparam fun_add 	= 6'h20;
 localparam fun_addu 	= 6'h21;
 localparam fun_sub		= 6'h22;
 localparam fun_subu	= 6'h23;
 localparam fun_and		= 6'h24;
 localparam fun_or		= 6'h25;
 localparam fun_xor		= 6'h26;
 localparam fun_nor		= 6'h27;
 localparam fun_slt		= 6'h2A;
 localparam fun_sltu	= 6'h2B;
 
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
/**********
 * Output Combinatorial Logic
 **********/
 always @(ALUOp, funcode) begin
	JumpReg_tmp = 0;
 
	//----------------------- NOT R-Type ---------------------------//
	if(ALUOp == ALUadd) begin
		ALUCtrl_tmp <= 5'b00000;
	end else if(ALUOp == ALUsub) begin
		ALUCtrl_tmp <= 5'b00001;	
	end else if(ALUOp == ALUand) begin
		ALUCtrl_tmp <= 5'b01101;
	end else if(ALUOp == ALUor) begin
		ALUCtrl_tmp <= 5'b01110;
	end else if(ALUOp == ALUxor) begin
		ALUCtrl_tmp <= 5'b01111;
	end else if(ALUOp == ALUslt) begin
		ALUCtrl_tmp <= 5'b10001;	
	
	//------------------------- If R-Type --------------------------//
	end else if((funcode == fun_add) || (funcode == fun_addu)) begin
		ALUCtrl_tmp <= 5'b00000;
	end else if((funcode == fun_sub) || (funcode == fun_subu)) begin
		ALUCtrl_tmp <= 5'b00001;
	end else if((funcode == fun_mult) || (funcode == fun_multu)) begin
		ALUCtrl_tmp <= 5'b00010;
	end else if(funcode == fun_sll) begin
		ALUCtrl_tmp <= 5'b00011;
	end else if(funcode == fun_sllv) begin
		ALUCtrl_tmp <= 5'b00100;
	end else if(funcode == fun_srl) begin
		ALUCtrl_tmp <= 5'b00101;
	end else if(funcode == fun_srlv) begin
		ALUCtrl_tmp <= 5'b00110;
	end else if(funcode == fun_sra) begin
		ALUCtrl_tmp <= 5'b00111;
	end else if(funcode == fun_srav) begin
		ALUCtrl_tmp <= 5'b01000;
	end else if(funcode == fun_mfhi) begin
		ALUCtrl_tmp <= 5'b01001;
	end	else if(funcode == fun_mflo) begin
		ALUCtrl_tmp <= 5'b01010;
	end else if(funcode == fun_mthi) begin
		ALUCtrl_tmp <= 5'b01011;
	end else if(funcode == fun_mtlo) begin
		ALUCtrl_tmp <= 5'b01100;
	end else if(funcode == fun_and) begin
		ALUCtrl_tmp <= 5'b01101;
	end else if(funcode == fun_or) begin
		ALUCtrl_tmp <= 5'b01110;
	end else if(funcode == fun_xor) begin
		ALUCtrl_tmp <= 5'b01111;
	end else if(funcode == fun_nor) begin
		ALUCtrl_tmp <= 5'b10000;
	end else if(funcode == fun_slt) begin
		ALUCtrl_tmp <= 5'b10001;
	end else if(funcode == fun_sltu) begin
		ALUCtrl_tmp <= 5'b10010;
	end else if(funcode == fun_jr) begin
		ALUCtrl_tmp <= 5'b00000;
		JumpReg_tmp = 1;
	end
 end
 
 assign ALUCtrl = ALUCtrl_tmp;
 assign JumpReg = JumpReg_tmp;
 
endmodule