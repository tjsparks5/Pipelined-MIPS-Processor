/*
DESCRIPTION
ALU

NOTES

TODO

*/

module alu_r0 #(
	parameter DATA_WIDTH = 32,
	parameter CTRL_WIDTH = 5,
	parameter STATUS_WIDTH = 4,
	parameter SHAMT_WIDTH = 5,
	parameter DELAY = 0
)(
	input clk,
	input rst,
	input en_n,
	input [DATA_WIDTH*2-1:0] dataIn,
	input [CTRL_WIDTH-1:0] ctrl,
	input [SHAMT_WIDTH-1:0] shamt,
	output [DATA_WIDTH-1:0] dataOut,
	output [STATUS_WIDTH-1:0] status
);
/**********
 *  Array Packing Defines 
 **********/
`define PACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_SRC,PK_DEST, BLOCK_ID, GEN_VAR)    genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[((PK_WIDTH)*GEN_VAR+((PK_WIDTH)-1)):((PK_WIDTH)*GEN_VAR)] = PK_SRC[GEN_VAR][((PK_WIDTH)-1):0]; end endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_DEST,PK_SRC, BLOCK_ID, GEN_VAR)  genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[GEN_VAR][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*GEN_VAR+(PK_WIDTH-1)):((PK_WIDTH)*GEN_VAR)]; end endgenerate

/**********
 * Internal Signals
**********/
wire [DATA_WIDTH - 1:0] tmpIn [1:0];
reg [DATA_WIDTH - 1:0] outtmp;
wire [DATA_WIDTH - 1:0] addOut;
wire [DATA_WIDTH - 1:0] subOut;
wire [2*DATA_WIDTH - 1:0] multOut;
reg [STATUS_WIDTH - 1:0] statusTmp;
reg [DATA_WIDTH - 1:0] hi;
reg [DATA_WIDTH - 1:0] lo;
wire Cadd, Zadd, Vadd, Sadd, Csub, Zsub, Vsub, Ssub, Cmult, Zmult, Vmult, Smult;
/**********
 * Glue Logic 
 **********/
 `UNPACK_ARRAY(DATA_WIDTH,2,tmpIn,dataIn, U_BLK_0, idx_0)
 
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
  delay #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(1),
	.DELAY(DELAY)
 ) U_DEL(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn(outtmp),
	.dataOut(dataOut)
 );
 
 delay #(
	.BIT_WIDTH(STATUS_WIDTH),
	.DEPTH(1),
	.DELAY(DELAY)
 ) U_DEL2(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn(statusTmp),
	.dataOut(status)
 );
 
 add_r0 #(
	.DATA_WIDTH(DATA_WIDTH)
 )U_ADD(
	.input1(tmpIn[1]),
	.input2(tmpIn[0]),
	.dataOut(addOut),
	.C(Cadd),
	.Z(Zadd),
	.V(Vadd),
	.S(Sadd)
 );

 sub_r0 #(
	.DATA_WIDTH(DATA_WIDTH)
 )U_SUB(
	.input1(tmpIn[1]),
	.input2(tmpIn[0]),
	.dataOut(subOut),
	.C(Csub),
	.Z(Zsub),
	.V(Vsub),
	.S(Ssub)
 );
 
 mult_r0 #(
	.DATA_WIDTH(DATA_WIDTH)
 )U_MULT(
	.input1(tmpIn[1]),
	.input2(tmpIn[0]),
	.dataOut(multOut),
	.C(Cmult),
	.Z(Zmult),
	.V(Vmult),
	.S(Smult)
 );
 
/**********
 * Output Combinatorial Logic
 **********/
 always @(posedge clk) begin
	if(rst == 1'b1) begin
		hi <= {(DATA_WIDTH){1'b0}};
		lo <= {(DATA_WIDTH){1'b0}};
	end else if(ctrl == 5'b00010) begin
		hi <= multOut[2*DATA_WIDTH - 1:DATA_WIDTH];
		lo <= multOut[DATA_WIDTH-1:0];	
	end else if(ctrl == 5'b01011) begin	// mthi
		hi <= tmpIn[0];
	end else if(ctrl == 5'b01100) begin	// mtlo
		lo <= tmpIn[0];
	end
 end
 
 always @(dataIn, ctrl, shamt, addOut, subOut, multOut) begin
	statusTmp = {(STATUS_WIDTH){1'b0}};
 
	if(ctrl == 5'b00000) begin	// add, addu, addi, addiu
		outtmp = addOut;
		statusTmp[3] = Cadd;
		statusTmp[2] = Zadd;
		statusTmp[1] = Vadd;
		statusTmp[0] = Sadd;
	end else if(ctrl == 5'b00001) begin	// sub, subu, subi, subiu
		outtmp = subOut;
		statusTmp[3] = Csub;
		statusTmp[2] = Zsub;
		statusTmp[1] = Vsub;
		statusTmp[0] = Ssub;
	end else if(ctrl == 5'b00010) begin	// mult, multu	
		outtmp = multOut[DATA_WIDTH-1:0];
		statusTmp[3] = Cmult;
		statusTmp[2] = Zmult;
		statusTmp[1] = Vmult;
		statusTmp[0] = Smult;
	end else if(ctrl == 5'b00011) begin	// sll
		outtmp = tmpIn[0] << shamt;
	end else if(ctrl == 5'b00100) begin	// sllv
		outtmp = tmpIn[0] << tmpIn[1];
	end else if(ctrl == 5'b00101) begin	// srl
		outtmp = tmpIn[0] >> shamt;
	end else if(ctrl == 5'b00110) begin	// srlv
		outtmp = tmpIn[0] >> tmpIn[1];
	end else if(ctrl == 5'b00111) begin	// sra
		outtmp = $signed(tmpIn[0]) >>> shamt;
		//outtmp[DATA_WIDTH-1:DATA_WIDTH-shamt] = tmpIn[0][DATA_WIDTH-1];
	end else if(ctrl == 5'b01000) begin	// srav
		outtmp = $signed(tmpIn[0]) >>> tmpIn[1];
		//outtmp[DATA_WIDTH-1:DATA_WIDTH-shamt] = tmpIn[0][DATA_WIDTH-1];
	end else if(ctrl == 5'b01001) begin	// mfhi
		outtmp = hi;
	end else if(ctrl == 5'b01010) begin	// mflo
		outtmp = lo;
	end else if(ctrl == 5'b01011) begin	// mthi
		//hi <= tmpIn[0];
		outtmp = tmpIn[0];
	end else if(ctrl == 5'b01100) begin	// mtlo
		//lo <= tmpIn[0];
		outtmp = tmpIn[0];
	end else if(ctrl == 5'b01101) begin
		outtmp = tmpIn[0] & tmpIn[1];	// and, andi
	end else if(ctrl == 5'b01110) begin
		outtmp = tmpIn[0] | tmpIn[1];	// or, ori
	end else if(ctrl == 5'b01111) begin
		outtmp = tmpIn[0] ^ tmpIn[1];	// xor, xori
	end else if(ctrl == 5'b10000) begin
		outtmp = ~(tmpIn[0]) & ~(tmpIn[1]);	// nor
	end else if(ctrl == 5'b10001) begin
		if($signed(tmpIn[1]) < $signed(tmpIn[0])) begin	// slt
			outtmp = 32'h00000001;
		end else begin
			outtmp = 32'h00000000;
		end
	end else if(ctrl == 5'b10010) begin
		if($unsigned(tmpIn[1]) < $unsigned(tmpIn[0])) begin	// sltu
			outtmp = 32'h00000001;
		end else begin
			outtmp = 32'h00000000;
		end
	end
	
	if((ctrl != 5'b00000) && (ctrl != 5'b00001) && (ctrl != 5'b00010)) begin
		if(outtmp[DATA_WIDTH-1:0] == {(DATA_WIDTH){1'b0}}) begin
			statusTmp[2] = 1;
		end
		
		statusTmp[0] = outtmp[DATA_WIDTH-1];
	end
 end
endmodule