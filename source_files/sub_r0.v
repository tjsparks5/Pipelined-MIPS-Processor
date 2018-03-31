/*
DESCRIPTION
Sub Module

NOTES

TODO

*/

module sub_r0 #(
	parameter DATA_WIDTH = 32
)(
	input [DATA_WIDTH - 1:0] input1,
	input [DATA_WIDTH - 1:0] input2,
	output[DATA_WIDTH - 1:0] dataOut,
	output C,
	output Z,
	output V,
	output S
);
/**********
 *  Array Packing Defines 
 **********/
/**********
 * Internal Signals
**********/
reg [DATA_WIDTH:0] tmpSub;
reg Ctmp, Ztmp, Vtmp, Stmp;

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
 always @(input1, input2) begin
	Ctmp = 0;
	Ztmp = 0;
	Vtmp = 0;
	Stmp = 0;
	
	tmpSub = input1 - input2;
	
	Ctmp = tmpSub[DATA_WIDTH];
	
	if(tmpSub[DATA_WIDTH-1:0] == {(DATA_WIDTH){1'b0}}) begin
		Ztmp = 1;
	end
	
	if((input1[DATA_WIDTH - 1] != input2[DATA_WIDTH - 1]) && (tmpSub[DATA_WIDTH - 1] == input2[DATA_WIDTH - 1])) begin
		Vtmp = 1;
	end

	Stmp = tmpSub[DATA_WIDTH - 1];
 end
 
 assign dataOut = tmpSub[DATA_WIDTH - 1:0];
 assign C = Ctmp;
 assign Z = Ztmp;
 assign V = Vtmp;
 assign S = Stmp;
 
endmodule