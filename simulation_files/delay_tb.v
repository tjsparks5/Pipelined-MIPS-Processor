/* Description
 Testbench for the ram
*/

`timescale 1ns/1ns

module delay_tb();

// Parameters
parameter BIT_WIDTH = 2;
parameter DEPTH = 3;
parameter DELAY = 1;

// Module Input
reg clk = 0;
reg rst = 1;
reg en_n = 0;
reg [BIT_WIDTH*DEPTH-1:0] dataIn;

// Module Output
wire [BIT_WIDTH*DEPTH-1:0] dataOut;

reg done = 0;
always begin
	if(done != 1) begin
		# 1;
		clk = ~clk;	// Clocking
	end
end

initial begin
	rst = 1;
	#2;
	
	rst = 0;
	dataIn = 011011;
	#50;
	
	done <= 1;
	#50;
end

/**********
 * Components
 **********/
 delay #(
	.BIT_WIDTH(BIT_WIDTH),
	.DEPTH(DEPTH),
	.DELAY(DELAY)
 ) UUT(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn(dataIn),
	.dataOut(dataOut)
 );
 
 endmodule