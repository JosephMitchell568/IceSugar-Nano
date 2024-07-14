// Joseph Mitchell, 7/13/2024
// MIPS ISA core (top level module)

`include "fetch/fetch.v"

module mips(
 input CLK,

 output INSTR_B1,
 output INSTR_B2,
 output INSTR_B3,
 output INSTR_B4
 );

 //---------------- Fetch Stage input ports ----------------
 reg PCsrc;
 reg [31:0] brnchJmpAddr;
 //---------------- End Fetch Stage input ports ------------
 
 //---------------- Fetch Stage output ports ---------------
 wire [31:0] instruction;
 wire [31:0] PCnext;
 //---------------- End Fetch Stage output ports -----------

 fetch fetchInst(
  .clk(CLK),
  .PCsrc(PCsrc),
  .brnchJmpAddr(brnchJmpAddr),

  .instruction(instruction),
  .PCnext(PCnext)  
 );

 initial
 begin
  PCsrc = 1'b0;
  brnchJmpAddr = 32'b0;
 end

 always @(posedge CLK)
 begin
  // Send data to some output device like an LCD screen or LEDS
 end
 


 assign INSTR_B4 = instruction[0];
 assign INSTR_B3 = instruction[8];
 assign INSTR_B2 = instruction[16];
 assign INSTR_B1 = instruction[24];
endmodule
