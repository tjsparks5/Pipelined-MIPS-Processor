/*
DESCRIPTION
Mult Module

NOTES

TODO

*/

module mult_r0 #(
	parameter DATA_WIDTH = 32
)(
	input [DATA_WIDTH - 1:0] input1,
	input [DATA_WIDTH - 1:0] input2,
	output[2*DATA_WIDTH - 1:0] dataOut,
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
reg [2*DATA_WIDTH - 1:0] tmpMult;
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
	
	tmpMult = input1 * input2;
	
	if(tmpMult[DATA_WIDTH-1:0] == {(2*DATA_WIDTH){1'b0}}) begin
		Ztmp = 1;
	end

	Stmp = tmpMult[2*DATA_WIDTH - 1];
 end
 
 assign dataOut = tmpMult;
 assign C = Ctmp;
 assign Z = Ztmp;
 assign V = Vtmp;
 assign S = Stmp;
 
endmodule