/*
DESCRIPTION:
Comparator For Branching in the ID stage
Checks if the inputs are equivalent and sets the "equal" flag accordingly

NOTES:
TODO:
*/

module comparator_r0 #(
	parameter BIT_WIDTH = 32
)(
	input [2*BIT_WIDTH - 1:0] dataIn,
	output equal
);

/**********
 * Internal Signals
 **********/
 reg equal_tmp;
	 
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
	always @(dataIn) begin
		if(dataIn[2*BIT_WIDTH - 1:BIT_WIDTH] == dataIn[BIT_WIDTH - 1:0]) begin
			equal_tmp <= 1'b1;
		end else begin
			equal_tmp <= 1'b0;
		end
	end

	assign equal = equal_tmp;
	
endmodule