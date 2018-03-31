/*
DESCRIPTION
Mux Wrapper

NOTES
	BIT_WIDTH 	// number of bits for input(s) and output
	DEPTH 		// number of inputs to the mux
	SEL_WIDTH	// width of the select for the mux
	
	dataIn		// vectorized inputs to the mux
	sel			// select value
	dataOut		// output from the selected input
	
TODO

*/

module mux #(
	parameter BIT_WIDTH = 4,
	parameter DEPTH = 2,
	parameter SEL_WIDTH = log2(DEPTH)
)(
	input [BIT_WIDTH*DEPTH - 1:0] dataIn,
	input [SEL_WIDTH - 1:0] sel,
	output [BIT_WIDTH - 1:0] dataOut
);

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
mux_r0 #(
	.BIT_WIDTH(BIT_WIDTH),
	.DEPTH(DEPTH),
	.SEL_WIDTH(SEL_WIDTH)
)U_IP(
	.dataIn(dataIn),
	.sel(sel),
	.dataOut(dataOut)
);
/**********
 * Output Combinatorial Logic
 **********/
endmodule