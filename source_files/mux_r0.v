/*
DESCRIPTION
Generic Mux

NOTES
	BIT_WIDTH 	// number of bits for input(s) and output
	DEPTH 		// number of inputs to the mux
	SEL_WIDTH	// width of the select for the mux
	
	dataIn		// vectorized inputs to the mux
	sel			// select value
	dataOut		// output from the selected input
	
TODO
*/

module mux_r0 #(
	parameter BIT_WIDTH = 4,
	parameter DEPTH = 2,
	parameter SEL_WIDTH = log2(DEPTH)
)(
	input [BIT_WIDTH*DEPTH - 1:0] dataIn,
	input [SEL_WIDTH - 1:0] sel,
	output [BIT_WIDTH - 1:0] dataOut
);

/**********
 *  Array Packing Defines 
 **********/
`define PACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_SRC,PK_DEST, BLOCK_ID, GEN_VAR)    genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[((PK_WIDTH)*GEN_VAR+((PK_WIDTH)-1)):((PK_WIDTH)*GEN_VAR)] = PK_SRC[GEN_VAR][((PK_WIDTH)-1):0]; end endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_DEST,PK_SRC, BLOCK_ID, GEN_VAR)  genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[GEN_VAR][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*GEN_VAR+(PK_WIDTH-1)):((PK_WIDTH)*GEN_VAR)]; end endgenerate

/**********
 * Internal Signals
 **********/
function integer log2; //This is a macro function (no hardware created) which finds the log2, returns log2
   input [31:0] val; //input to the function
   integer 	i;
   begin
      log2 = 0;
      for(i = 0; 2**i < val; i = i + 1)
		log2 = i + 1;
   end
endfunction 

wire [BIT_WIDTH - 1:0] tmp [DEPTH - 1:0]; //input as array

/**********
 * Glue Logic 
 **********/
`UNPACK_ARRAY(BIT_WIDTH,DEPTH,tmp,dataIn, U_BLK_0, idx_0)
 
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
 assign dataOut = tmp[sel];
endmodule