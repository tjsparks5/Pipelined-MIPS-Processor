/*
 * DESCRIPTION
 * This creates an array or vector registers of generic bitwidth, array width, and pipeline depth. 
 * 
 * NOTES
 * BIT_WIDTH = bitwidth
 * DEPTH = input/output array width
 * DELAY = pipeline depth 
 * clk = clock
 * rst = synchronous, active high reset, clears out pipeline
 * en_n = active low enable
 * dataIn = vectorized input array
 * dataOut = vectorized output array
 * 
 * TODO
 * 
 */


module delay_r0 #(
	parameter BIT_WIDTH = 4,
	parameter DEPTH = 2,
	parameter DELAY = 4
)(
	input clk,
	input rst,
	input en_n,
	input [BIT_WIDTH*DEPTH - 1:0] dataIn,
	output [BIT_WIDTH*DEPTH - 1:0] dataOut
);
	/**********
	 *  Array Packing Defines 
	 **********/
//These are preprocessor defines similar to C/C++ preprocessor or VHDL functions
	`define PACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_SRC,PK_DEST, BLOCK_ID, GEN_VAR)    genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[((PK_WIDTH)*GEN_VAR+((PK_WIDTH)-1)):((PK_WIDTH)*GEN_VAR)] = PK_SRC[GEN_VAR][((PK_WIDTH)-1):0]; end endgenerate
	`define UNPACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_DEST,PK_SRC, BLOCK_ID, GEN_VAR)  genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[GEN_VAR][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*GEN_VAR+(PK_WIDTH-1)):((PK_WIDTH)*GEN_VAR)]; end endgenerate

	/**********
	 * Internal Signals
	 **********/
//These iterators are purely use for for-loops which get unrolled in synthesis
//So we can use integers here since these do not become hardware
	integer i,j; //iterators
	
//Wire data type is used for nonregistered signals
//assign with "assign wire_signal_name = value_for_wire_signal;"
	wire [BIT_WIDTH - 1:0] tmp [DEPTH - 1:0]; //input as array
	wire [BIT_WIDTH*DEPTH - 1:0] tmpOut; //wire for output, more of this at end
	
//NOTE: in VHDL, there are for generate and if generate statements
//this is done in verilog with "generate"
//packing and unpacking array defines are examples of for-generate
//in the "generate" blocks, in addition to instantiations, one can do assignments 
//to wire (becuase nonsynchronous), which is done in the packing and unpacking defines	
	
//Register data type is used for synchronous logic
//assign with "<="
	reg [BIT_WIDTH - 1:0] pipe [DELAY-1:0][DEPTH - 1:0]; //data pipeline

	/**********
	 * Glue Logic 
	 **********/
//very often there needs to be some logic/decoding to inputs to a module 
//here we just unpacking the input vector into an array 
	`UNPACK_ARRAY(BIT_WIDTH,DEPTH,tmp,dataIn, U_BLK_0, idx_0)
	
	/**********
	 * Synchronous Logic
	 **********/
//NOTE in C/C++ "{" and "}" are used to show hierarchy, in verilog use "begin" and "end"
	 
//similar to vhdl process statements, verilog has always blocks 
//"posedge clk" is the sensitivity list
//since the reset is not in the sensitivity list, the reset is synchronous
	always @(posedge clk) begin
		
		// Synchronous Reset
//"1'b0" translates to "one bit with value binary 0"  
		if(rst == 1'b1)	begin
			//reset all the stages of the pipeline to zero
			for(j=0; j<DELAY; j=j+1) begin //For all delay layers
				for(i=0; i<DEPTH; i=i+1) begin //For all depth of input array
					pipe[j][i] <= {(BIT_WIDTH){1'b0}};
				end
			end
		end

		else begin
//all for-loops are unrolled, so should never have sequential dependences				
//since all loops are unrolled and no sequential dependences, 
//all assignments occure at the same time (i.e. clock edge)

			// Pipeline delay
			if(en_n == 1'b0) begin			
				for(i=0;i<DEPTH; i=i+1) begin //For all depth of input array
					pipe[0][i] <= tmp[i]; 
				end
			end

//only got to DELAY - 1 since the last stage of pipe is overwritten and zeroth stage assigned above
			for(i=0; i<DELAY-1; i=i+1) begin 
				for(j=0;j<DEPTH; j=j+1) begin //For all depth of input array
					pipe[i+1][j] <= pipe[i][j]; //Pipe shifts makes delay
				end
			end
		end
	end
				
	/**********
	 * Glue Logic 
	 **********/
	/**********
	 * Components
	 **********/
	/**********
	 * Output Combinatorial Logic
	 **********/
//currently pipe is a 2D array of logic vectors, so we need to make the last delay stage into a vector
	`PACK_ARRAY(BIT_WIDTH,DEPTH,pipe[(DELAY-1)],tmpOut,U_BLK_1,idx_1)
	 
//to be able to do conditional combinatorial logic, use "generate"
	//When delay is 0, this entity should be a wire
	generate
	if(DELAY > 0)
		assign dataOut = tmpOut;
		
//NOTE the below statement would be ideal rather than having another temp signal but this isnt allowed since
//pack array also uses a generate statement and they can not be nested
//'PACK_ARRAY(BIT_WIDTH,DEPTH,dataOut,pipe[DELAY-1],U_BLK_1,idx_1)

	else
		assign dataOut = dataIn;
	endgenerate
	
endmodule