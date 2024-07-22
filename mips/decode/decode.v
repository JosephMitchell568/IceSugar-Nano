// Joseph Mitchell, 7/14/2024
// Decode stage of MIPS pipline

`include "registerFile.v"

module decode(
 input clk,

 input [31:0] instruction,
 input [31:0] PCnext,
 input [31:0] writeData,
 input RegWrite,
 input RegDst,

 output reg [31:0] rdData1,
 output reg [31:0] rdData2,
 output reg [31:0] imm,
 output reg [8:0] control,
 output reg [31:0] PCnextID
 );

 wire [4:0] rdReg1, rdReg2, wReg;
 wire [31:0] rdData1w, rdData2w, immw;

 registerFile registerFileInst(
  .clk(CLK),
  
  .RegWrite(RegWrite),
  .rdReg1(rdReg1), // rs
  .rdReg2(rdReg2), // rt/rd
  .writeReg(wReg), // wr
  .writeData(writeData), //wd

  .rdData1(rdData1w),
  .rdData2(rdData2w)  
 );
 

 initial
 begin
  rdData1 <= 32'b0;
  rdData2 <= 32'b0;
  imm <= 32'b0;
  control <= 9'b0;
 end

 always @(posedge CLK)
 begin
  PCnextID <= PCnext;
  rdData1 <= rdData1w;
  rdData2 <= rdData2w;
  imm <= immw;
  if(instruction[31:26] == 6'b0)//opcode 0
  begin//instruction is R-Type
   control <= 9'b1100_000_10;//EX-MEM-WB
  end// RegDst ALUop1 ALUop0 ALUSrc
 end// Branch MemRead MemWrite
    // RegWrite MemtoReg
 assign rdReg1 = instruction[25:21];
 assign rdReg2 = instruction[20:16];
 assign wReg = (RegDst == 1'b1) ? 
	instruction[15:11] : instruction[20:16]; 
 assign immw = { {16{instruction[15]}},instruction[15:0]};
endmodule
