/*
DESCRIPTION
Controller for Memory

NOTES
	
TODO

*/

module memcontroller_r0 (
	input [5:0] opcode,
	input [1:0] MemSelect,
	output [3:0] MemWrite,
	output [3:0] MemRead,
	output MemMux1Sel,
	output [1:0] MemMux2Sel,
	output [1:0] MemMux3Sel
);

/**********
 * Internal Signals
**********/
reg [3:0] MemWrite_tmp;
reg [3:0] MemRead_tmp;
reg MemMux1Sel_tmp;
reg [1:0] MemMux2Sel_tmp;
reg [1:0] MemMux3Sel_tmp;

/**********
 * Glue Logic 
 **********/
 localparam lw		= 6'h23;
 localparam lbu		= 6'h24;
 localparam lhu		= 6'h25;
 localparam sb		= 6'h28;
 localparam sh		= 6'h29;
 localparam sw 		= 6'h2B;
 
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
 always @(opcode, MemSelect) begin
	MemWrite_tmp <= 4'b0000;
	MemRead_tmp <= 4'b0000;
	MemMux1Sel_tmp <= 1'b0;
	MemMux2Sel_tmp <= 2'b00;
	MemMux3Sel_tmp <= 2'b00;
 
	casez({opcode, MemSelect})
	 // Store Byte
	 {sb, 2'b00} : begin
		MemWrite_tmp <= 4'b0001;
	 end
	 {sb, 2'b01} : begin
		MemWrite_tmp <= 4'b0010;
		MemMux1Sel_tmp <= 1'b0;
	 end
	 {sb, 2'b10} : begin
		MemWrite_tmp <= 4'b0100;
		MemMux2Sel_tmp <= 2'b00;
	 end
	 {sb, 2'b11} : begin
		MemWrite_tmp <= 4'b1000;
		MemMux3Sel_tmp <= 2'b00;
	 end
	 
	 // Store Half Word
	 {sh, 2'b00} : begin
		MemWrite_tmp <= 4'b0011;
		MemMux1Sel_tmp <= 1'b1;
	 end
	 {sh, 2'b01} : begin
		MemWrite_tmp <= 4'b0110;
		MemMux1Sel_tmp <= 1'b0;
		MemMux2Sel_tmp <= 2'b01;
	 end
	 {sh, 2'b10} : begin
		MemWrite_tmp <= 4'b1100;
		MemMux2Sel_tmp <= 2'b00;
		MemMux3Sel_tmp <= 2'b01;
	 end

	 // Store Word
	 {sw, 2'b??} : begin
		MemWrite_tmp <= 4'b1111;
		MemMux1Sel_tmp <= 1'b1;
		MemMux2Sel_tmp <= 2'b10;
		MemMux3Sel_tmp <= 2'b10;
	 end
	 
	 // Load Byte
	 {lbu, 2'b00} : begin
		MemRead_tmp <= 4'b0001;
	 end
	 {lbu, 2'b01} : begin
		MemRead_tmp <= 4'b0010;
	 end
	 {lbu, 2'b10} : begin
		MemRead_tmp <= 4'b0100;
	 end
	 {lbu, 2'b11} : begin
		MemRead_tmp <= 4'b1000;
	 end
	 
	 // Load Half Word
	 {lhu, 2'b00} : begin
		MemRead_tmp <= 4'b0011;
	 end
	 {lhu, 2'b01} : begin
		MemRead_tmp <= 4'b0110;
	 end
	 {lhu, 2'b10} : begin
		MemRead_tmp <= 4'b1100;
	 end

	 // Load Word
	 {lw, 2'b??} : begin
		MemRead_tmp <= 4'b1111;
	 end
	endcase
 end
 
 assign MemWrite = MemWrite_tmp;
 assign MemRead = MemRead_tmp;
 assign MemMux1Sel = MemMux1Sel_tmp;
 assign MemMux2Sel = MemMux2Sel_tmp;
 assign MemMux3Sel = MemMux3Sel_tmp;
endmodule