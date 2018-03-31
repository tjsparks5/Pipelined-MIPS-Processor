// Instruction Memory
// 128 Words Long
// $readmemh will load the given program from the .hex file

module rom(q, a);
   output[31:0] q;
   input [6:0] a;
  
   reg [31:0] mem [127:0];
	
   initial $readmemh("data.hex", mem, 0, 127) ;
   assign q = mem[a];
	
endmodule