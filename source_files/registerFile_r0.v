/*
DESCRIPTION
Generic Register File

NOTES
	DATA_WIDTH	// word length
	RD_DEPTH	// number of parallel reads
	REG_DEPTH	// depth of the register file
	ADDR_WIDTH	// address width, operand width
	rst			// synchronous reset
	wr			// write enable
	rr			// rg read address as vecotrized array
	rw			// reg write address
	d			// input datat to be written to reg
	q			// output data from reg reads as vectorized array
	
TODO
*/

module registerFile_r0 #(
	parameter DATA_WIDTH = 32,
	parameter RD_DEPTH = 2,
	parameter REG_DEPTH = 32,
	parameter ADDR_WIDTH = log2(REG_DEPTH)
)(
	input clk,
	input rst,
	input wr,
	input [ADDR_WIDTH*RD_DEPTH - 1:0] rr,
	input [ADDR_WIDTH - 1:0] rw,
	input [DATA_WIDTH - 1:0] d,
	output [DATA_WIDTH*RD_DEPTH - 1:0] q
);

/**********
 *  Array Packing Defines 
 **********/
`define PACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_SRC,PK_DEST, BLOCK_ID, GEN_VAR)    genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[((PK_WIDTH)*GEN_VAR+((PK_WIDTH)-1)):((PK_WIDTH)*GEN_VAR)] = PK_SRC[GEN_VAR][((PK_WIDTH)-1):0]; end endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_DEST,PK_SRC, BLOCK_ID, GEN_VAR)  genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[GEN_VAR][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*GEN_VAR+(PK_WIDTH-1)):((PK_WIDTH)*GEN_VAR)]; end endgenerate

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

reg [DATA_WIDTH - 1:0] registers [REG_DEPTH - 1:0];	// registers in the register file
wire [DATA_WIDTH - 1:0] readouttmp [RD_DEPTH - 1:0];	// tmp for the read values from the registers

integer i,j;

wire [ADDR_WIDTH - 1:0] rrtmp [RD_DEPTH - 1:0];		// array for the address values
wire [DATA_WIDTH*RD_DEPTH - 1:0] qtmp;				// vector for the output values
wire [DATA_WIDTH*REG_DEPTH - 1:0] regvector;

/**********
 * Glue Logic 
 **********/
 `UNPACK_ARRAY(ADDR_WIDTH, RD_DEPTH, rrtmp, rr, U_BLK_0, idx_0)
 
 //assign regswires = registers;
/**********
 * Synchronous Logic
 **********/
 always @(negedge clk /*posedge clk*/) begin
	if(rst) begin
		for(i=0; i<REG_DEPTH; i=i+1) begin
			registers[i] <= {(DATA_WIDTH){1'b0}};	// Reset each register to 0
		end
	end else begin		
		if(wr == 1'b1) begin
			registers[rw] <= d;	// Write to the register if write is enabled
		end
		
		registers[0] <= {(DATA_WIDTH){1'b0}};
	end
 end
 
/**********
 * Glue Logic 
 **********/
 `PACK_ARRAY(DATA_WIDTH, RD_DEPTH, readouttmp, qtmp, U_BLK_1, idx_1)	// Turn array into vector for output
 `PACK_ARRAY(DATA_WIDTH, REG_DEPTH, registers, regvector, U_BLK_2, idx_2)	// Turn array into vector for output
 
/**********
 * Components
 **********/
 genvar k;
 generate 
	for(k=0; k<RD_DEPTH; k=k+1) begin : regmuxes
		mux #(
			.BIT_WIDTH(DATA_WIDTH),
			.DEPTH(REG_DEPTH),
			.SEL_WIDTH(ADDR_WIDTH)
		)U_IP(
			.dataIn(regvector),
			.sel(rrtmp[k]),
			.dataOut(readouttmp[k])
		);
	end
 endgenerate
 
/**********
 * Output Combinatorial Logic
 **********/
 assign q = qtmp;
 
endmodule