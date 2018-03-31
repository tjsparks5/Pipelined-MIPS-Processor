/* Description
 Testbench for the Sign Extender module
*/

`timescale 1ns/1ns

module signextender_tb();

// Parameters
parameter IN_WIDTH = 16;
parameter OUT_WIDTH = 32;
parameter DEPTH = 1;
parameter DELAY = 0;

// Module Input
reg [IN_WIDTH - 1:0] dataIn;
reg clk = 0;
reg rst = 1;
reg en_n = 0;
reg isSigned = 0;

// Module Output
wire [OUT_WIDTH - 1:0] dataOut;

reg done = 0;


always begin
	if(done != 1) begin
		# 1;
		clk = ~clk;	// Clocking
	end
end

initial begin
	done = 0;
	rst = 1;
	#50;
	
	rst = 0;
	isSigned <= 0;
	dataIn <= 16'h0001;
	# 50;
	
	isSigned <= 1;
	# 50;
	
	done = 1;
	
	$stop;
end

/**********
 * Components
 **********/
 signextender_r0 #(
	.IN_WIDTH(IN_WIDTH),
	.OUT_WIDTH(OUT_WIDTH),
	.DEPTH(DEPTH),
	.DELAY(DELAY)
 )UUT(
	.dataIn(dataIn),
	.dataOut(dataOut),
	.isSigned(isSigned),
	.clk(clk),
	.rst(rst),
	.en_n(en_n)
 );
 
 endmodule