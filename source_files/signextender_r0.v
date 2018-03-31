/*
DESCRIPTION
Sign Extender

NOTES
	IN_WIDTH 	// Width of the input
	OUT_WIDTH 	// Width of the output
	
	isSigned	// Whether the input is signed or unsigned
	dataIn		// Input data
	dataOut		// Output data
TODO

*/

module signextender_r0 #(
	parameter IN_WIDTH = 16,
	parameter OUT_WIDTH = 32,
	parameter DEPTH = 1,
	parameter DELAY = 0
)(
	input [DEPTH*IN_WIDTH - 1:0] dataIn,
	output [DEPTH*OUT_WIDTH - 1:0] dataOut,
	input isSigned,
	
	// Delay Inputs
	input clk,
	input rst,
	input en_n
);

/**********
 *  Array Packing Defines 
 **********/
`define PACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_SRC,PK_DEST, BLOCK_ID, GEN_VAR)    genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[((PK_WIDTH)*GEN_VAR+((PK_WIDTH)-1)):((PK_WIDTH)*GEN_VAR)] = PK_SRC[GEN_VAR][((PK_WIDTH)-1):0]; end endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_DEST,PK_SRC, BLOCK_ID, GEN_VAR)  genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[GEN_VAR][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*GEN_VAR+(PK_WIDTH-1)):((PK_WIDTH)*GEN_VAR)]; end endgenerate

/**********
 * Internal Signals
**********/
wire [IN_WIDTH - 1:0] tmpIn [DEPTH - 1:0];
reg [OUT_WIDTH - 1:0] extTmp [DEPTH - 1:0];	// temp to hold the vector being created
wire [DEPTH*OUT_WIDTH - 1:0] outTmp;

integer i;
/**********
 * Glue Logic 
 **********/
  `UNPACK_ARRAY(IN_WIDTH, DEPTH, tmpIn, dataIn, U_BLK_0, idx_0)
  
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
 `PACK_ARRAY(OUT_WIDTH, DEPTH, extTmp, outTmp, U_BLK_1, idx_1)
 
/**********
 * Components
 **********/
 delay #(
	.BIT_WIDTH(OUT_WIDTH),
	.DEPTH(DEPTH),
	.DELAY(DELAY)
 ) U_IP(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn(outTmp),
	.dataOut(dataOut)
 );
 
/**********
 * Output Combinatorial Logic
 **********/
 always @(tmpIn, isSigned) begin
	for(i=0; i<DEPTH; i=i+1) begin
		if(isSigned == 1'b1) begin
			extTmp[i][OUT_WIDTH - 1:IN_WIDTH] <= {(OUT_WIDTH - IN_WIDTH){tmpIn[i][IN_WIDTH - 1]}};
			extTmp[i][IN_WIDTH - 1:0] <= tmpIn[i];
		end else begin
			extTmp[i][OUT_WIDTH - 1:IN_WIDTH] <= {(OUT_WIDTH - IN_WIDTH){1'b0}};
			extTmp[i][IN_WIDTH - 1:0] <= tmpIn[i];
		end
	end
 end
 
 //assign dataOut = outTmp;	// assign the output to the newly created vector
endmodule