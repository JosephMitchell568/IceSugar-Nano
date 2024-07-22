// Joseph Mitchell, 7/22/2024
// Writeback stage of MIPS pipline


module writeback(
 input clk,

 input [31:0] readData,
 input [31:0] ALUresultMEM,
 input MemtoReg,
 input [4:0] writeRegMEM,

 output reg [31:0] wrData,
 output reg [4:0] writeRegWB
 ); 

 initial
 begin
  wrData <= 32'b0;
  writeRegWB <= 5'b1;
 end

 always @(posedge CLK)
 begin
  if(MemtoReg)
  begin
   wrData <= readData;
  end
  else
  begin
   wrData <= ALUresultMEM;
  end
  writeRegWB <= writeRegMEM;
 end
    
endmodule
