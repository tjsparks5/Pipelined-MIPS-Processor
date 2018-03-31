/*
DESCRIPTION
Module for the logic with load instructions and the memory

NOTES

TODO

*/

module memout_r0 #(
	parameter DATA_WIDTH = 8
)(
	input [DATA_WIDTH - 1:0] Mem0Out,
	input [DATA_WIDTH - 1:0] Mem1Out,
	input [DATA_WIDTH - 1:0] Mem2Out,
	input [DATA_WIDTH - 1:0] Mem3Out,
	input [1:0] MemSel,
	input [5:0] Opcode, 
	output [31:0] MemOut
);
/**********
 *  Array Packing Defines 
 **********/
/**********
 * Internal Signals
**********/
reg [31 - 1:0] MemOut_tmp;

/**********
 * Glue Logic 
 **********/
 localparam lw		= 6'h23;
 localparam lbu		= 6'h24;
 localparam lhu		= 6'h25;
 
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
 always @(Opcode, MemSel, Mem0Out, Mem1Out, Mem2Out, Mem3Out) begin
	if(Opcode == lbu) begin
		if(MemSel == 2'b00) begin
			MemOut_tmp <= {24'h000000, Mem0Out};
		end else if(MemSel == 2'b01) begin
			MemOut_tmp <= {24'h000000, Mem1Out};
		end else if(MemSel == 2'b10) begin
			MemOut_tmp <= {24'h000000, Mem2Out};
		end else if(MemSel == 2'b11) begin
			MemOut_tmp <= {24'h000000, Mem3Out};
		end
	end else if(Opcode == lhu) begin
		if(MemSel == 2'b00) begin
			MemOut_tmp <= {16'b0000, Mem1Out, Mem0Out};
		end else if(MemSel == 2'b01) begin
			MemOut_tmp <= {16'b0000, Mem2Out, Mem1Out};
		end else begin
			MemOut_tmp <= {16'b0000, Mem3Out, Mem2Out};
		end
	end else if(Opcode == lw) begin
		MemOut_tmp <= {Mem3Out, Mem2Out, Mem1Out, Mem0Out};
	end
 end 
 
 assign MemOut = MemOut_tmp;
endmodule