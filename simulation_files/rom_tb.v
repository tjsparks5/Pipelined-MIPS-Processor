/* Description
 Testbench for the rom
*/

`timescale 1ns/1ns

module rom_tb();

// Parameters

// Module Input
reg [5:0] a;
	
// Module Output
wire [31:0] q;

integer i;

initial begin
	for(i = 0; i < 64; i=i+1) begin
		a <= i;
		#50;
	end
	
	#10;
end

/**********
 * Components
 **********/
 rom UUT(
	.q(q),
	.a(a)
 );
 
 endmodule