/* Description
 Testbench for the comparator
*/

`timescale 1ns/1ns

module comparator_tb();

// Parameters
parameter BIT_WIDTH = 32;

// Module Input
reg [2*BIT_WIDTH - 1:0] dataIn;

// Module Output
wire equal;

initial begin
	dataIn = {32'h00001111, 32'h11110000};
	#50;
	
	dataIn = {32'h11111111, 32'h11111111};
	#50;
	
	dataIn = {32'h00000000, 32'h00000000};
	#50;
	
	dataIn = {32'h10101010, 32'h01010101};
	#50;
end

/**********
 * Components
 **********/
 comparator_r0 #(
	.BIT_WIDTH(BIT_WIDTH)
 ) UUT(
	.dataIn(dataIn),
	.equal(equal)
 );
 
 endmodule