/*
DESCRIPTION
Counter

NOTES
	MAX_COUNT		// Max count value
	COUNT_WIDTH 	// Bit width of the count
	
	clk				// Clock
	rst				// Synchronous reset
	load			// Whether to load the input value or not
	dataIn			// Value to load into the counter
	count			// Count value

TODO

*/

module counter_r0 #(
	parameter MAX_COUNT = 4,
	parameter COUNT_WIDTH = log2(MAX_COUNT) + 1,
	parameter DELAY = 0
)(
	input clk,
	input rst,
	input load,
	input pause,
	input [COUNT_WIDTH - 1:0] countIn,
	output [COUNT_WIDTH - 1:0] countOut,
	 
	// Delay
	input en_n
	
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

reg [COUNT_WIDTH - 1:0] countValue;	// Register to hold the count value
wire [COUNT_WIDTH - 1:0] countMax = MAX_COUNT;
/**********
 * Glue Logic 
 **********/
/**********
 * Synchronous Logic
 **********/
 always @(posedge clk) begin
	if(rst) begin
		countValue <= {(COUNT_WIDTH){1'b0}};		// Reset the count to zero
	end else begin
		if(load) begin
			countValue <= countIn;					// If load = 1 then set count value to the input value
		end else if(pause) begin
			countValue <= countValue;				// If pause = 1 hold the value
		end else if(countValue^countMax) begin
			countValue <= countValue + 1;			// Increase count value by 1
		end else begin
			countValue <= {(COUNT_WIDTH){1'b0}};	// If at MAX_COUNT next value is 0
		end
	end
 end
 
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
  delay #(
	.BIT_WIDTH(COUNT_WIDTH),
	.DEPTH(1),
	.DELAY(DELAY)
 ) U_IP(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn(countValue),
	.dataOut(countOut)
 );
 
/**********
 * Output Combinatorial Logic
 **********/
 //assign countOut = countValue;		// Assign output
 
endmodule