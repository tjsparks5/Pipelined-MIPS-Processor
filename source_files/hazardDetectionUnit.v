/*
DESCRIPTION:
Hazard Detection Unit

NOTES:
TODO:
*/

module hazardDetectionUnit_r0 (
	input [5:0] IF_ID_Opcode,
	input [5:0] IF_ID_Funcode,
	input [4:0] IF_ID_Rs,
	input [4:0] IF_ID_Rt,
	input ID_EX_MemRead,
	input [4:0] ID_EX_Rt,
	input equal,
	input [4:0] ID_EX_Rd,
	input [4:0] EX_MEM_Rd,
	input ID_EX_RegWrite,
	input EX_MEM_RegWrite,
	output reg PCWrite,
	output reg ID_EX_CtrlFlush,
	output reg IF_ID_Flush,
	output reg IF_ID_Hold
);

/**********
 * Internal Signals
 **********/
 localparam j		= 6'h02;
 localparam jal		= 6'h03;
 localparam beq		= 6'h04;
 localparam bne		= 6'h05;
 
 localparam R_Type 	= 6'h00;
 localparam fun_jr		= 6'h08;
 
/**********
 * Glue Logic 
 **********/
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
	always @(IF_ID_Opcode, IF_ID_Rs, IF_ID_Rt, ID_EX_MemRead, ID_EX_Rt, equal, ID_EX_Rd, EX_MEM_Rd, ID_EX_RegWrite, EX_MEM_RegWrite) begin
		if((ID_EX_MemRead == 1'b1) && ((ID_EX_Rt == IF_ID_Rs) || (ID_EX_Rt == IF_ID_Rt))) begin
			PCWrite <= 1'b0;
			ID_EX_CtrlFlush <= 1'b1;
			IF_ID_Flush <= 1'b0;
			IF_ID_Hold <= 1'b1;
		end else if(((IF_ID_Opcode == beq) || (IF_ID_Opcode == bne) || ((IF_ID_Opcode == R_Type) && (IF_ID_Funcode == fun_jr))) 
		&& (((ID_EX_Rd == IF_ID_Rs || ID_EX_Rd == IF_ID_Rt) && (ID_EX_RegWrite == 1'b1)) || ((EX_MEM_Rd == IF_ID_Rs || EX_MEM_Rd == IF_ID_Rt) && (EX_MEM_RegWrite == 1'b1)))) begin
			PCWrite <= 1'b0;
			ID_EX_CtrlFlush <= 1'b1;
			IF_ID_Flush <= 1'b0;
			IF_ID_Hold <= 1'b1;
		end else if((IF_ID_Opcode == j) /*|| (IF_ID_Opcode == jal)*/ || ((IF_ID_Opcode == R_Type) && (IF_ID_Funcode == fun_jr)) || (IF_ID_Opcode == beq && (equal == 1'b1)) || (IF_ID_Opcode == bne && (equal == 1'b0))) begin
			PCWrite <= 1'b1;
			ID_EX_CtrlFlush <= 1'b0;
			IF_ID_Flush <= 1'b1;
			IF_ID_Hold <= 1'b0;
		end else if(IF_ID_Opcode == jal) begin
			PCWrite <= 1'b1;
			ID_EX_CtrlFlush <= 1'b0;
			IF_ID_Flush <= 1'b1;
			IF_ID_Hold <= 1'b0;
		end else begin
			PCWrite <= 1'b1;
			ID_EX_CtrlFlush <= 1'b0;
			IF_ID_Flush <= 1'b0;
			IF_ID_Hold <= 1'b0;
		end
	end	
endmodule