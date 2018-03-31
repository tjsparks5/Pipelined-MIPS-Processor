/* Description
 Testbench for the datapath
*/

`timescale 1ns/1ns

module datapth_tb();

// Parameters
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 5;

// Module Input
reg clk = 0;
reg rst = 1;
reg en_n = 0;
//reg PC_we = 1;
	
// Module Output


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
	//PC_we = 1;
	# 5;
	
	rst = 0;
	# 800;
	
	
	done = 1;
	# 5;
end

/**********
 * Components
 **********/
 datapath_r0 #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)
 )UUT(
	.clk(clk),
	.rst(rst),
	.en_n(en_n)
	//.PC_we(PC_we)
 );
 
 endmodule