// Joseph Mitchell, 7/22/2024
// Memory stage of MIPS pipline

// Structure of Data Memory:
// dataMem1 [MSB] dataMem2 [MSB-1] dataMem3 [MSB-2] dataMem4 [LSB]
// Each BRAM block for data memory stores 1 byte of each data word
// Each BRAM has 512 addressable locations

`include "dataMem1.v"
`include "dataMem2.v"
`include "dataMem3.v"
`include "dataMem4.v"

module memory(
 input clk,

 input Branch,
 input zero,
 input MemWrite,
 input MemRead,
 input [31:0] brnch,
 input [31:0] writeDataEX,
 input [31:0] ALUresultEX,
 input [4:0] writeRegEX,

 output reg MemtoReg,
 output reg [31:0] readData,
 output reg [31:0] ALUresultMem,
 output reg [4:0] writeRegMem
 );
 

 initial
 begin
  MemtoReg <= 1'b1;
  readData <= 32'b0;
  ALUresultMem <= 32'b0;
  writeRegMem <= 5'b1;
 end

 always @(posedge CLK)
 begin

  if(MemWrite)
  begin

  end
  
  if(MemRead)
  begin

  end

 end

endmodule
