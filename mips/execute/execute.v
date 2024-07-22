// Joseph Mitchell, 7/22/2024
// Execute stage of MIPS pipline

module execute(
 input clk,

 input [31:0] PCnextID,
 input [31:0] rdData1,
 input [31:0] rdData2,
 input [31:0] imm,
 input ALUSrc,
 input [1:0] ALUOp,
 input RegDst,
 input [4:0] rd,
 input [4:0] rt,


 output reg [31:0] brnch,
 output reg zero,
 output reg [31:0] ALUresult,
 output reg [31:0] rdData2,
 output reg [4:0] writeReg
 );


 initial
 begin
  
 end

 always @(posedge CLK)
 begin
  
  brnch <= PCnextID + (imm << 2);

  if(ALUSrc)// op2 is imm
  begin
   
  end
  else// op2 is rdData2
  begin

  end
  
  if(RegDst)// Destination register for data
  begin
   writeReg <= rt;// Target Register
  end
  else
  begin
   writeReg <= rd;// Destination Register
  end
 end

endmodule
