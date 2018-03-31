/*
DESCRIPTION:
General Delay Wrapper Entity

NOTES:
This module is to be called by other modules for a functional entity.
This module wraps various implementations.

TODO:

*/

module delay #(
	parameter BIT_WIDTH = 32,
	parameter DEPTH = 1,
	parameter DELAY = 1,
	parameter ARCH_SEL = 0
)(
	input clk,
	input rst,
	input en_n,
	input [BIT_WIDTH*DEPTH-1:0] dataIn,
	output [BIT_WIDTH*DEPTH-1:0] dataOut
);

	/**********
	 * Internal Signals
	 **********/
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
//generate if(!ARCH_SEL) //since only have a single implementation, dont need now
	delay_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.DEPTH(DEPTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.en_n(en_n),
		.dataIn(dataIn),
		.dataOut(dataOut)
	);
//endgenerate	

	/**********
	 * Output Combinatorial Logic
	 **********/


endmodule