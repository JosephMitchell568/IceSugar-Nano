// Joseph Mitchell, 7/13/2024
// Fetch stage of mips isa

`include "instructionMem1.v"

module fetch(
 input CLK
 //Later there must be a PCsrc control bit added
 // and a 32 bit branch/jump address supplied as inputs
 //Later there must be an IF/ID Pipe as output which includes
 // a 32 bit instruction word
 // a 32 bit pc address for next instruction
 );

 reg [31:0] instruction; //Instruction fetched from instMemory
 reg [31:0] pc; //Program Counter (Points to next instruction)

 //-------------- InstructionMem1 inputs ---------------------
 reg instRdEn1; // Read enable line
 reg [6:0] instRdAddr1; // 7 bit - 128 addresses
 //-------------- End InstructionMem1 inputs -----------------
 
 //-------------- InstructionMem1 outputs --------------------
 wire [31:0] instDataOut1;
 wire instValidOut1;
 //-------------- End InstructionMem1 outputs ----------------

 //-------------- InstructionMem1 module instantiaton --------
 instructionMem1 instructionMem1Inst(
  .clk(CLK),
  .rd_en(instRdEn1),
  .rd_addr(instRdAddr1),
  .data_out(instDataOut1),
  .valid_out(instValidOut1)
 );
 //-------------- End instructionMem1 module Instantation ----

 initial
 begin
  instruction[31:0] = 32'b0; // NOP
  pc[31:0] = 32'b0; // First instruction
  instRdEn1 = 1'b1; // Enable read
  instRdAddr1 = 7'b0; // Instruction address
 end

 always @(posedge CLK)
 begin
  //if(PCsrc)
  //begin
  // pc[31:0] <= brchJmpAddr;
  //end
  //else
  //begin
  pc[31:0] <= pc[31:0] + 32'd4; // Increment PC by 4 bytes
  //end
  instruction[31:0] <= instDataOut1;
  instRdAddr1[6:0] <= pc[6:2]; //7 bit byte addressable (word)
 end
 
endmodule
