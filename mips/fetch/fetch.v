// Joseph Mitchell, 7/13/2024
// Fetch stage of mips isa

`include "instructionMem1.v"

module fetch(
 input CLK
 );

 reg [31:0] instruction; //Instruction fetched from instMemory
 reg [31:0] pc; //Program Counter (Points to next instruction)

 reg instRdEn1; // Read enable line
 reg [6:0] instRdAddr1; // 7 bit - 128 addresses

 wire [31:0] instDataOut1;
 wire instValidOut1;

 instructionMem1 instructionMem1Inst(
  .clk(CLK),
  .rd_en(instRdEn1),
  .rd_addr(instRdAddr1),
  .data_out(instDataOut1),
  .valid_out(instValidOut1)
  );

 initial
 begin
  instruction[31:0] = 32'b0; // NOP
  pc[31:0] = 32'b0; // First instruction
  instRdEn1 = 1'b1; // Enable read
  instRdAddr1 = 7'b0; // Instruction address
 end

 always @(posedge CLK)
 begin
   
 end
 
endmodule
