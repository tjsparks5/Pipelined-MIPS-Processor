/*
DESCRIPTION
Main Controller

NOTES

TODO
*/

module controller_r0 (
	input [5:0] opcode,
	input [5:0] funcode, 
	output [1:0] RegDst,				// 0 = 20:16, 1 = 15:11, 2 = $31
	output ALUSrc,
	output MemtoReg,
	output RegWrite,
	output [1:0] RegWriteSrc,	// 0 = output from memory, 1 = 16-bit left-shifted value for lui, 2 = PC + 4 for JAL
	output MemRead,
	//output MemRead1,
	//output MemRead2,
	//output MemRead3,
	//output MemWrite0,
	//output MemWrite1,
	//output MemWrite2,
	//output MemWrite3,
	output Jump,
	output JumpRegID,
	output BranchBEQ,
	output BranchBNE,
	output [2:0] ALUOp,
	output isSigned
);

/**********
 * Internal Signals
**********/
 reg [1:0] RegDst_tmp;
 reg ALUSrc_tmp;
 reg MemtoReg_tmp;
 reg RegWrite_tmp;
 reg [1:0] RegWriteSrc_tmp;
 reg MemRead_tmp;
 //reg MemRead1_tmp;
 //reg MemRead2_tmp;
 //reg MemRead3_tmp;
 //reg MemWrite0_tmp;
 //reg MemWrite1_tmp;
 //reg MemWrite2_tmp;
 //reg MemWrite3_tmp;
 reg BranchBEQ_tmp;
 reg BranchBNE_tmp;
 reg Jump_tmp;
 reg JumpRegID_tmp;
 reg [2:0] ALUOp_tmp;
 reg isSigned_tmp;
	
/**********
 * Glue Logic 
 **********/
 localparam R_Type 	= 6'h00;
 localparam j		= 6'h02;
 localparam jal		= 6'h03;
 localparam beq		= 6'h04;
 localparam bne		= 6'h05;
 //localparam blez	= 6'h06;
 //localparam bgtz	= 6'h07;
 localparam addi 	= 6'h08;
 localparam addiu 	= 6'h09;
 localparam slti 	= 6'h0A;
 localparam sltiu	= 6'h0B;
 localparam andi	= 6'h0C;
 localparam ori		= 6'h0D;
 localparam xori	= 6'h0E;
 localparam lui		= 6'h0F;
 //localparam lb	= 6'h20;
 //localparam lh	= 6'h21;
 //localparam lwl	= 6'h22;
 localparam lw		= 6'h23;
 localparam lbu		= 6'h24;
 localparam lhu		= 6'h25;
 //localparam lwr	= 6'h26;
 localparam sb		= 6'h28;
 localparam sh		= 6'h29;
 //localparam swl	= 6'h2A;
 localparam sw 		= 6'h2B;
 //localparam swr	= 6'h2E;
 
 localparam ALUadd = 3'b000;	// for addi, addiu, lw, lbu, lhu, sb, sh, sw
 localparam ALUsub = 3'b001;	// for beq, bne
 localparam ALUand = 3'b010;	// for andi
 localparam ALUor  = 3'b011;	// for ori
 localparam ALUxor = 3'b100;	// for xori
 localparam ALUslt = 3'b101;	// for slti, sltiu
 localparam ALURtp = 3'b111;	// for all R-Type
 
 localparam fun_jr		= 6'h08;
 
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
 /*always @(funcode) begin
	JumpRegID_tmp = 0;
	
	if(funcode == fun_jr) begin
		JumpRegID_tmp = 1;
	end
 end*/
 
 always @(opcode, funcode) begin
	RegDst_tmp = 2'b00;
	ALUSrc_tmp = 0;
	MemtoReg_tmp = 0;
	RegWrite_tmp = 0;
	RegWriteSrc_tmp = 2'b00;
	MemRead_tmp = 0;
	//MemRead1_tmp = 0;
	//MemRead2_tmp = 0;
	//MemRead3_tmp = 0;
	//MemWrite0_tmp = 0;
	//MemWrite1_tmp = 0;
	//MemWrite2_tmp = 0;
	//MemWrite3_tmp = 0;
	BranchBEQ_tmp = 0;
	BranchBNE_tmp = 0;
	Jump_tmp = 0;
	ALUOp_tmp = 3'b000;
	isSigned_tmp = 0;
	
	JumpRegID_tmp = 0;
	
	case(opcode)
		R_Type: begin
			RegDst_tmp = 2'b01;
			RegWrite_tmp = 1;
			ALUOp_tmp = ALURtp;
			
			if(funcode == fun_jr) begin
				JumpRegID_tmp = 1;
			end
		end
		
		addi: begin
			ALUSrc_tmp = 1;
			RegWrite_tmp = 1;
			ALUOp_tmp = ALUadd;
			isSigned_tmp = 1;
		end
		
		addiu: begin
			ALUSrc_tmp = 1;
			RegWrite_tmp = 1;
			ALUOp_tmp = ALUadd;
		end
		
		slti: begin
			ALUSrc_tmp = 1;
			ALUOp_tmp = ALUslt;
			RegWrite_tmp = 1;
			isSigned_tmp = 1;
		end
		
		sltiu: begin
			ALUSrc_tmp = 1;
			ALUOp_tmp = ALUslt;
			RegWrite_tmp = 1;
		end
		
		andi: begin
			ALUSrc_tmp = 1;
			RegWrite_tmp = 1;
			ALUOp_tmp = ALUand;
			//isSigned_tmp = 1;
		end
		
		ori: begin
			ALUSrc_tmp = 1;
			RegWrite_tmp = 1;
			ALUOp_tmp = ALUor;
			//isSigned_tmp = 1;
		end
		
		xori: begin
			ALUSrc_tmp = 1;
			RegWrite_tmp = 1;
			ALUOp_tmp = ALUxor;
			//isSigned_tmp = 1;
		end
		
		lui: begin
			RegWrite_tmp = 1;
			RegWriteSrc_tmp = 2'b01;
			isSigned_tmp = 1;
		end
		
		lbu: begin
			ALUSrc_tmp = 1;
			MemtoReg_tmp = 1;
			RegWrite_tmp = 1;
			MemRead_tmp = 1;
			ALUOp_tmp = ALUadd;
		end
		
		lhu: begin
			ALUSrc_tmp = 1;
			MemtoReg_tmp = 1;
			RegWrite_tmp = 1;
			MemRead_tmp = 1;
			//MemRead1_tmp = 1;
			ALUOp_tmp = ALUadd;
		end
		
		lw: begin
			ALUSrc_tmp = 1;
			MemtoReg_tmp = 1;
			RegWrite_tmp = 1;
			MemRead_tmp = 1;
			//MemRead1_tmp = 1;
			//MemRead2_tmp = 1;
			//MemRead3_tmp = 1;
			ALUOp_tmp = ALUadd;
			isSigned_tmp = 1;
		end
		
		sb: begin
			ALUSrc_tmp = 1;
			//MemWrite0_tmp = 1;
			ALUOp_tmp = ALUadd;
			isSigned_tmp = 1;
		end
		
		sh: begin
			ALUSrc_tmp = 1;
			//MemWrite0_tmp = 1;
			//MemWrite1_tmp = 1;
			ALUOp_tmp = ALUadd;
			isSigned_tmp = 1;
		end
		
		sw: begin
			ALUSrc_tmp = 1;
			//MemWrite0_tmp = 1;
			//MemWrite1_tmp = 1;
			//MemWrite2_tmp = 1;
			//MemWrite3_tmp = 1;
			ALUOp_tmp = ALUadd;
			isSigned_tmp = 1;
		end
		
		beq: begin
			BranchBEQ_tmp = 1;
			ALUOp_tmp = ALUsub;
			isSigned_tmp = 1;
		end
		
		bne: begin
			BranchBNE_tmp = 1;
			ALUOp_tmp = ALUsub;
			isSigned_tmp = 1;
		end
		
		j: begin
			Jump_tmp = 1;
			isSigned_tmp = 1;
		end
		
		jal: begin
			Jump_tmp = 1;
			RegDst_tmp = 2'b10;
			RegWrite_tmp = 1;
			RegWriteSrc_tmp = 2'b10;
			isSigned_tmp = 1;
		end
	endcase
	
 end
 
 assign RegDst = RegDst_tmp;
 assign ALUSrc = ALUSrc_tmp;
 assign MemtoReg = MemtoReg_tmp;
 assign RegWrite = RegWrite_tmp;
 assign RegWriteSrc = RegWriteSrc_tmp;
 assign MemRead = MemRead_tmp;
 //assign MemRead1 = MemRead1_tmp;
 //assign MemRead2 = MemRead2_tmp;
 //assign MemRead3 = MemRead3_tmp;
 //assign MemWrite0 = MemWrite0_tmp;
 //assign MemWrite1 = MemWrite1_tmp;
 //assign MemWrite2 = MemWrite2_tmp;
 //assign MemWrite3 = MemWrite3_tmp;
 assign BranchBEQ = BranchBEQ_tmp;
 assign BranchBNE = BranchBNE_tmp;
 assign Jump = Jump_tmp;
 assign JumpRegID = JumpRegID_tmp;
 assign ALUOp = ALUOp_tmp;
 assign isSigned = isSigned_tmp;
 
endmodule