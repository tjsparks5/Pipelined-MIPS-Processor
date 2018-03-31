// Data Memory

module ram(q, a, d, rst, we, re, clk);
   output[7:0] q;
   input [7:0] d;
   input [5:0] a;
   input rst, we, re, clk;
   
   reg [7:0] qtmp;
   
   reg [7:0] mem [63:0];
   integer i;
   
   always @(posedge clk) begin
        if(rst == 1'b1) begin
			for(i = 0; i < 64; i=i+1) begin
				mem[i] <= {(8){1'b0}};
			end
		end else if (we == 1'b1) begin
            mem[a] <= d;
		end
   end
   
   always @* begin
		if(re == 1'b1) begin
			qtmp <= mem[a];
		end else begin
			qtmp <= {(8){1'b0}};
		end
   end
   
   assign q = qtmp;
endmodule