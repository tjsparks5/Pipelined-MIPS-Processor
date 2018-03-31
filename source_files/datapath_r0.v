/*
DESCRIPTION
Pipelined MIPS Datapath

NOTES
	Stages:
	IF -> ID -> EXE -> MEM -> WB
TODO
*/

module datapath_r0 #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 5
)(
	input clk,
	input rst,
	input en_n
);

/**********
 * Internal Signals
**********/
wire [4:0] WriteReg; 					// Register to write to
wire JumpReg;

// IF
wire [DATA_WIDTH - 1:0] BranchOut;		// Output of Branch Mux
wire [DATA_WIDTH - 1:0] JumpOut;		// Output of Jump Mux
wire [DATA_WIDTH - 1:0] JumpRegOut;

reg  [DATA_WIDTH - 1:0] PC;			// PC
wire [DATA_WIDTH - 1:0] address;
wire [DATA_WIDTH - 1:0] PCPlus4;		// $PC + 4
wire [DATA_WIDTH - 1:0] instruction;

// IF/ID
wire [DATA_WIDTH - 1:0] IF_ID_PC;
wire [DATA_WIDTH - 1:0] IF_ID_PCPlus4;
wire [DATA_WIDTH - 1:0] IF_ID_Instruction;

// ID
wire isSigned;
wire Jump;
wire JumpRegID;
wire [1:0] RegDst;	// 0 = 20:16, 1 = 15:11, 2 = $31
wire ALUSrc;
wire [2:0] ALUOp;	// Input to the ALU Controller
wire [4:0] ALUCtrl;	// Input to the ALU
wire BranchBEQ;
wire BranchBNE;
wire MemtoReg;
wire ID_MemRead;
wire RegWrite;
wire [1:0] RegWriteSrc;	// 0 = output from memory, 1 = 16-bit left-shifted value for lui, 2 = PC + 4 for JAL

wire [2*DATA_WIDTH - 1:0] RegFileOut;	// 2 Outputs from the Reg file
wire equal;
wire [DATA_WIDTH - 1:0] SignExtOut;	// Output of Sign Extender

// Hazard Detection Unit
wire PCWrite;
wire ID_EX_CtrlFlush;
wire IF_ID_Flush;
wire IF_ID_Hold;

// ID/EX
wire ID_EX_ALUSrc;				// ALU Source Select
wire [2:0] ID_EX_ALUOp;				// ALU Operation
wire [1:0] ID_EX_RegDst;				// Destination Reg Select

wire ID_EX_BranchBEQ;			// Pass through to MEM
wire ID_EX_BranchBNE;			// Pass through to MEM
wire [5:0] ID_EX_Opcode;		// Pass through to MEM

wire ID_EX_MemtoReg;			// Pass through to MEM
wire ID_EX_MemRead;
wire ID_EX_RegWrite;			// Pass through to MEM
wire [1:0] ID_EX_RegWriteSrc;	// Pass through to MEM


wire [DATA_WIDTH - 1:0] ID_EX_PCPlus4;
wire [2*DATA_WIDTH - 1:0] ID_EX_RegFileOut;
wire [DATA_WIDTH - 1:0] ID_EX_SignExtOut;
wire [4:0] ID_EX_Instruction25to21;
wire [4:0] ID_EX_Instruction20to16;
wire [4:0] ID_EX_Instruction15to11;

// EX
wire [DATA_WIDTH - 1:0] ALUSrcOut;	// Output of ALU Source Mux
wire [DATA_WIDTH - 1:0] ALUOut;	// Output of ALU
wire [3:0] StatusReg;			// Status Register from ALU

// EX/MEM
wire EX_MEM_BranchBEQ;			// if BEQ
wire EX_MEM_BranchBNE;			// if BNE
wire [3:0] EX_MEM_StatusReg;			// status reg for use with branch, etc...
wire [5:0] EX_MEM_Opcode;		// Load or store opcode for Memory Controller

wire EX_MEM_MemtoReg;			// Pass through to WB
wire EX_MEM_RegWrite;			// Pass through to WB
wire [1:0] EX_MEM_RegWriteSrc;	// Pass through to WB

wire [DATA_WIDTH - 1:0] EX_MEM_BranchADD;			// Result of addition in EX stage
wire [DATA_WIDTH - 1:0] EX_MEM_PCPlus4;
wire [DATA_WIDTH - 1:0] EX_MEM_SignExtOut;
wire [DATA_WIDTH - 1:0] EX_MEM_ALUOut;
wire [DATA_WIDTH - 1:0] EX_MEM_ReadData2;
wire [ADDR_WIDTH - 1:0] EX_MEM_WriteReg;

// MEM
wire [5:0] ALUaddress;
wire [1:0] MemSelect;

wire [3:0] MemRead;
wire [3:0] MemWrite;
wire MemMux1Sel;
wire [1:0] MemMux2Sel;
wire [1:0] MemMux3Sel;
wire [7:0] MemMux1Out;
wire [7:0] MemMux2Out;
wire [7:0] MemMux3Out;

wire [DATA_WIDTH - 1:0] DataMemOut;		// Output from Data Memory
wire [DATA_WIDTH - 1:0] MemOut;

// MEM/WB
wire MEM_WB_MemtoReg;			// Choose between Memory Out or ALU Result
wire MEM_WB_RegWrite;			// Write enable for Reg File
wire [1:0] MEM_WB_RegWriteSrc;	// Choose between output of MemtoReg, Immediate Value, or $PC+4

wire [DATA_WIDTH - 1:0] MEM_WB_PCPlus4;
wire [DATA_WIDTH - 1:0] MEM_WB_SignExtOut;
wire [DATA_WIDTH - 1:0] MEM_WB_DataMemOut;
wire [DATA_WIDTH - 1:0] MEM_WB_MemOut;
wire [DATA_WIDTH - 1:0] MEM_WB_ALUOut;
wire [ADDR_WIDTH - 1:0] MEM_WB_WriteReg;

// WB
wire [DATA_WIDTH - 1:0] MemtoRegOut;	// Out of MemtoReg Mux
wire [DATA_WIDTH - 1:0] WriteData;		// Data Written to Reg file

// Forwarding Unit
wire [1:0] ForwardA;
wire [1:0] ForwardB;
wire [DATA_WIDTH - 1:0] ForwardAOut;
wire [DATA_WIDTH - 1:0] ForwardBOut;

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
 // ------- Forwarding Components ------ //
 forwardingUnit_r0 #(
	.BIT_WIDTH(ADDR_WIDTH)
 ) U_FWDUNIT (
	.ID_EX_Rs(ID_EX_Instruction25to21),
	.ID_EX_Rt(ID_EX_Instruction20to16),
	.EX_MEM_Rd(EX_MEM_WriteReg),
	.MEM_WB_Rd(MEM_WB_WriteReg),
	.EX_MEM_RegWrite(EX_MEM_RegWrite),
	.MEM_WB_RegWrite(MEM_WB_RegWrite),
	.ForwardA(ForwardA),
	.ForwardB(ForwardB)
 );
 
 mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(3)
 ) U_FWDA (
	.dataIn({EX_MEM_ALUOut, MemtoRegOut, ID_EX_RegFileOut[2*DATA_WIDTH - 1:DATA_WIDTH]}),
	.sel(ForwardA),
	.dataOut(ForwardAOut)
 );
 
 mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(3)
 ) U_FWDB (
	.dataIn({EX_MEM_ALUOut, MemtoRegOut, ID_EX_RegFileOut[DATA_WIDTH - 1:0]}),
	.sel(ForwardB),
	.dataOut(ForwardBOut)
 );
 
 // ----------- Hazard Detection Unit ------- //
 hazardDetectionUnit_r0 U_HDU(
	.IF_ID_Opcode(IF_ID_Instruction[31:26]),
	.IF_ID_Funcode(IF_ID_Instruction[5:0]),
	.IF_ID_Rs(IF_ID_Instruction[25:21]),
	.IF_ID_Rt(IF_ID_Instruction[20:16]),
	.ID_EX_MemRead(ID_EX_MemRead),
	.ID_EX_Rt(ID_EX_Instruction20to16),
	.equal(equal),
	.ID_EX_Rd(WriteReg),
	.EX_MEM_Rd(EX_MEM_WriteReg),
	.ID_EX_RegWrite(ID_EX_RegWrite),
	.EX_MEM_RegWrite(EX_MEM_RegWrite),
	.PCWrite(PCWrite),
	.ID_EX_CtrlFlush(ID_EX_CtrlFlush),
	.IF_ID_Flush(IF_ID_Flush),
	.IF_ID_Hold(IF_ID_Hold)
 );
 
 // --------- PIPELINE REGS ------------ //
 // IF/ID Register
 delay #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(3),
	.DELAY(1)
 ) U_IF_ID_REG (
	.clk(clk),
	.rst(IF_ID_Flush | rst),
	.en_n(IF_ID_Hold),
	.dataIn({PC, PCPlus4, instruction}),
	.dataOut({IF_ID_PC, IF_ID_PCPlus4, IF_ID_Instruction})
 );
 
 // ID/EX Register
 // --- CONTROL PIPELINE REGS --- //
 delay #(
	.BIT_WIDTH(1),
	.DEPTH(6),
	.DELAY(1)
 ) U_ID_EX_REG0 (
	.clk(clk),
	.rst(ID_EX_CtrlFlush | rst),
	.en_n(1'b0),
	.dataIn({ALUSrc, BranchBEQ, BranchBNE, MemtoReg, ID_MemRead, RegWrite}),
	.dataOut({ID_EX_ALUSrc, ID_EX_BranchBEQ, ID_EX_BranchBNE, ID_EX_MemtoReg, ID_EX_MemRead, ID_EX_RegWrite})
 );
 
  delay #(
	.BIT_WIDTH(2),
	.DEPTH(2),
	.DELAY(1)
 ) U_ID_EX_REG1 (
	.clk(clk),
	.rst(ID_EX_CtrlFlush | rst),
	.en_n(1'b0),
	.dataIn({RegDst, RegWriteSrc}),
	.dataOut({ID_EX_RegDst, ID_EX_RegWriteSrc})
 );
 
  delay #(
	.BIT_WIDTH(3),
	.DEPTH(1),
	.DELAY(1)
 ) U_ID_EX_REG2 (
	.clk(clk),
	.rst(ID_EX_CtrlFlush | rst),
	.en_n(1'b0),
	.dataIn(ALUOp),
	.dataOut(ID_EX_ALUOp)
 );
 
 // --- END CONTROL PIPELINE REGS --- //
 
  delay #(
	.BIT_WIDTH(6),
	.DEPTH(1),
	.DELAY(1)
 ) U_ID_EX_REG3 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(IF_ID_Instruction[31:26]),
	.dataOut(ID_EX_Opcode)
 );
 
 delay #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(4),
	.DELAY(1)
 ) U_ID_EX_REG4 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({IF_ID_PCPlus4, RegFileOut, SignExtOut}),
	.dataOut({ID_EX_PCPlus4, ID_EX_RegFileOut, ID_EX_SignExtOut})
 );
 
 delay #(
	.BIT_WIDTH(ADDR_WIDTH),
	.DEPTH(3),
	.DELAY(1)
 ) U_ID_EX_REG5 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({IF_ID_Instruction[25:21], IF_ID_Instruction[20:16], IF_ID_Instruction[15:11]}),
	.dataOut({ID_EX_Instruction25to21, ID_EX_Instruction20to16, ID_EX_Instruction15to11})
 );
 
 // EX/MEM Register
 delay #(
	.BIT_WIDTH(1),
	.DEPTH(4),
	.DELAY(1)
 ) U_EX_MEM_REG0 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({ID_EX_BranchBEQ, ID_EX_BranchBNE, ID_EX_MemtoReg, ID_EX_RegWrite}),
	.dataOut({EX_MEM_BranchBEQ, EX_MEM_BranchBNE, EX_MEM_MemtoReg, EX_MEM_RegWrite})
 );
 
 delay #(
	.BIT_WIDTH(2),
	.DEPTH(1),
	.DELAY(1)
 ) U_EX_MEM_REG1 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(ID_EX_RegWriteSrc),
	.dataOut(EX_MEM_RegWriteSrc)
 );
 
  delay #(
	.BIT_WIDTH(4),
	.DEPTH(1),
	.DELAY(1)
 ) U_EX_MEM_REG2 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(StatusReg),
	.dataOut(EX_MEM_StatusReg)
 );
 
  delay #(
	.BIT_WIDTH(6),
	.DEPTH(1),
	.DELAY(1)
 ) U_EX_MEM_REG3 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(ID_EX_Opcode),
	.dataOut(EX_MEM_Opcode)
 );
 
  delay #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(5),
	.DELAY(1)
 ) U_EX_MEM_REG4 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({{ID_EX_SignExtOut[29:0], 2'b00} + ID_EX_PCPlus4, ID_EX_PCPlus4, ID_EX_SignExtOut, ALUOut, ForwardBOut}),
	.dataOut({EX_MEM_BranchADD, EX_MEM_PCPlus4, EX_MEM_SignExtOut, EX_MEM_ALUOut, EX_MEM_ReadData2})
 );
 
   delay #(
	.BIT_WIDTH(ADDR_WIDTH),
	.DEPTH(1),
	.DELAY(1)
 ) U_EX_MEM_REG5 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(WriteReg),
	.dataOut(EX_MEM_WriteReg)
 );
 
 // MEM/WB Register
 delay #(
	.BIT_WIDTH(1),
	.DEPTH(2),
	.DELAY(1)
 ) U_MEM_WB_REG0 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({EX_MEM_MemtoReg, EX_MEM_RegWrite}),
	.dataOut({MEM_WB_MemtoReg, MEM_WB_RegWrite})
 );
 
  delay #(
	.BIT_WIDTH(2),
	.DEPTH(1),
	.DELAY(1)
 ) U_MEM_WB_REG1 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(EX_MEM_RegWriteSrc),
	.dataOut(MEM_WB_RegWriteSrc)
 );
 
 delay #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(5),
	.DELAY(1)
 ) U_MEM_WB_REG2 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({EX_MEM_PCPlus4, EX_MEM_SignExtOut, DataMemOut, MemOut, EX_MEM_ALUOut}),
	.dataOut({MEM_WB_PCPlus4, MEM_WB_SignExtOut, MEM_WB_DataMemOut, MEM_WB_MemOut, MEM_WB_ALUOut})
 );
 
 delay #(
	.BIT_WIDTH(ADDR_WIDTH),
	.DEPTH(1),
	.DELAY(1)
 ) U_MEM_WB_REG3 (
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(EX_MEM_WriteReg),
	.dataOut(MEM_WB_WriteReg)
 );
 
 
 // ----- INSTRUCTION FETCH (IF) ----- //
  mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(2)
 )U_BRANCHMUX(
	.dataIn({{SignExtOut[29:0], 2'b00} + IF_ID_PCPlus4, PCPlus4}),
	.sel((BranchBEQ & equal) | (BranchBNE & ~equal)),
	.dataOut(BranchOut)
 );
 
  mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(2)
 )U_JUMPMUX(
	.dataIn({{IF_ID_PCPlus4[31:28], {IF_ID_Instruction[25:0], 2'b00}}, BranchOut}),
	.sel(Jump),
	.dataOut(JumpOut)
 );
 
  mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(2)
 )U_JUMPREGMUX(
	.dataIn({RegFileOut[2*DATA_WIDTH - 1:DATA_WIDTH], JumpOut}),
	.sel(JumpRegID),
	.dataOut(JumpRegOut)
 );
 
  rom U_rom(
	.q(instruction),
	.a(address[6:0])
 );
 
 // ----- INSTRUCTION DECODE (ID) ----- //
  controller_r0 U_CONTROLLER(
	.opcode(IF_ID_Instruction[31:26]),
	.funcode(IF_ID_Instruction[5:0]),
	.RegDst(RegDst),
	.ALUSrc(ALUSrc),
	.MemtoReg(MemtoReg),
	.MemRead(ID_MemRead),
	.RegWrite(RegWrite),
	.RegWriteSrc(RegWriteSrc),
	.Jump(Jump),
	.JumpRegID(JumpRegID),
	.BranchBEQ(BranchBEQ),
	.BranchBNE(BranchBNE),
	.ALUOp(ALUOp),
	.isSigned(isSigned)
 );
 
  registerFile #(
	.DATA_WIDTH(DATA_WIDTH),
	.RD_DEPTH(2),
	.REG_DEPTH(32),
	.ADDR_WIDTH(ADDR_WIDTH)
 )U_REGFILE(
	.clk(clk),
	.rst(rst),
	.wr(MEM_WB_RegWrite),
	.rr({IF_ID_Instruction[25:21], IF_ID_Instruction[20:16]}),
	.rw(MEM_WB_WriteReg),
	.d(WriteData),
	.q(RegFileOut)
 );
 
 comparator_r0 #(
	.BIT_WIDTH(DATA_WIDTH)
 ) U_COMPARE(
	.dataIn(RegFileOut),
	.equal(equal)
 );
 
  signextender_r0 #(
	.IN_WIDTH(16),
	.OUT_WIDTH(DATA_WIDTH),
	.DEPTH(1),
	.DELAY(0)
 )U_SIGNEXTENDER(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn(IF_ID_Instruction[15:0]),
	.dataOut(SignExtOut),
	.isSigned(isSigned)
 );
 
 // ----- EXECUTE (EX) ----- //
  mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(2)
 )U_ALUSRCMUX(
	//.dataIn({ID_EX_SignExtOut, ID_EX_RegFileOut[DATA_WIDTH - 1:0]}),
	.dataIn({ID_EX_SignExtOut, ForwardBOut}),
	.sel(ID_EX_ALUSrc),
	.dataOut(ALUSrcOut)
 );
 
  alu_controller_r0 U_ALUCONTROLLER(
	.ALUOp(ID_EX_ALUOp),
	.funcode(ID_EX_SignExtOut[5:0]),
	.ALUCtrl(ALUCtrl),
	.JumpReg(JumpReg)
 );
 
  alu_r0 #(
	.DATA_WIDTH(DATA_WIDTH),
	.CTRL_WIDTH(5),
	.STATUS_WIDTH(4),
	.SHAMT_WIDTH(5),
	.DELAY(0)
 )U_ALU(
	.clk(clk),
	.rst(rst),
	.en_n(en_n),
	.dataIn({ForwardAOut, ALUSrcOut}),
	.ctrl(ALUCtrl),
	.shamt(ID_EX_SignExtOut[10:6]),
	.dataOut(ALUOut),
	.status(StatusReg)
 );
 
  mux #(
	.BIT_WIDTH(ADDR_WIDTH),
	.DEPTH(3)
 )U_REGDSTMUX(
	.dataIn({5'b11111, ID_EX_Instruction15to11, ID_EX_Instruction20to16}),
	.sel(ID_EX_RegDst),
	.dataOut(WriteReg)
 );
 
 // ----- MEMORY (MEM) ----- //
 // ----- Memory Muxes ----- //
 mux #(
	.BIT_WIDTH(8),
	.DEPTH(2)
 ) U_MEMMUX1(
	.dataIn({EX_MEM_ReadData2[15:8], EX_MEM_ReadData2[7:0]}),
	.sel(MemMux1Sel),
	.dataOut(MemMux1Out)
 );
 
 mux #(
	.BIT_WIDTH(8),
	.DEPTH(3)
 ) U_MEMMUX2(
	.dataIn({EX_MEM_ReadData2[23:16], EX_MEM_ReadData2[15:8], EX_MEM_ReadData2[7:0]}),
	.sel(MemMux2Sel),
	.dataOut(MemMux2Out)
 );
 
 mux #(
	.BIT_WIDTH(8),
	.DEPTH(3)
 ) U_MEMMUX3(
	.dataIn({EX_MEM_ReadData2[31:24], EX_MEM_ReadData2[15:8], EX_MEM_ReadData2[7:0]}),
	.sel(MemMux3Sel),
	.dataOut(MemMux3Out)
 );
 
 // ---- Data Memory ---- //
 ram U_ram0(
	.q(DataMemOut[7:0]),
	.d(EX_MEM_ReadData2[7:0]),
	.a(ALUaddress),
	.rst(rst),
	.we(MemWrite[0]),
	.re(MemRead[0]),
	.clk(clk)
 );
 
 ram U_ram1(
	.q(DataMemOut[15:8]),
	.d(MemMux1Out),
	.a(ALUaddress),
	.rst(rst),
	.we(MemWrite[1]),
	.re(MemRead[1]),
	.clk(clk)
 );
 
 ram U_ram2(
	.q(DataMemOut[23:16]),
	.d(MemMux2Out),
	.a(ALUaddress),
	.rst(rst),
	.we(MemWrite[2]),
	.re(MemRead[2]),
	.clk(clk)
 );
 
 ram U_ram3(
	.q(DataMemOut[31:24]),
	.d(MemMux3Out),
	.a(ALUaddress),
	.rst(rst),
	.we(MemWrite[3]),
	.re(MemRead[3]),
	.clk(clk)
 );
 
  memout_r0 # (
	.DATA_WIDTH(8)
 ) U_MEMOUT (
	.Mem0Out(DataMemOut[7:0]),
	.Mem1Out(DataMemOut[15:8]),
	.Mem2Out(DataMemOut[23:16]),
	.Mem3Out(DataMemOut[31:24]),
	.MemSel(MemSelect),
	.Opcode(EX_MEM_Opcode),
	.MemOut(MemOut)
 
 );
 
 memcontroller_r0 U_MEMCONTROLLER(
	.opcode(EX_MEM_Opcode),
	.MemSelect(MemSelect),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.MemMux1Sel(MemMux1Sel),
	.MemMux2Sel(MemMux2Sel),
	.MemMux3Sel(MemMux3Sel)
 );
 
 // ----- WWRITE BACK (WB) ----- //
  mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(2)
 )U_MEMTOREGMUX(
	.dataIn({MEM_WB_MemOut, MEM_WB_ALUOut}),
	.sel(MEM_WB_MemtoReg),
	.dataOut(MemtoRegOut)
 );
 
  mux #(
	.BIT_WIDTH(DATA_WIDTH),
	.DEPTH(3)
 )U_REGWRITESRCMUX(
	.dataIn({MEM_WB_PCPlus4, {MEM_WB_SignExtOut[15:0], 16'h0000}, MemtoRegOut}),
	.sel(MEM_WB_RegWriteSrc),
	.dataOut(WriteData)
 );
  
/**********
 * Output Combinatorial Logic
 **********/
 assign PCPlus4 = PC + 4;
 assign address = PC >> 2;	// Shift PC by two since ROM is byte-addressable
 
 // ------------------ Memory Signals --------------------- //
 assign ALUaddress = EX_MEM_ALUOut[7:2];	// Calculated Address bits
 assign MemSelect = EX_MEM_ALUOut[1:0];	// Select bits from ALU output
 
 always @(posedge clk) begin
	if(rst == 1'b1) begin
		PC <= {(DATA_WIDTH){1'b0}};
	end else begin
		if(PCWrite) begin
			PC <= JumpRegOut;
		end
	end
 end
endmodule