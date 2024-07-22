// Register File for the MIPS ISA

module registerFile(
	input wire clk,
	input wire rd_en, 
	input wire RegWrite,
	input wire [31:0] writeData,
	input wire [4:0] writeReg,
	input wire [4:0] rdReg1, // word addr
	input wire [4:0] rdReg2, // word addr
		
	output reg [31:0] rdData1,// word
	output reg [31:0] rdData2,// word
	output reg valid_out
   );

   reg [31:0] memory [0:31]; //128 instruction words
   integer i;			

   initial begin
    memory[0]=32'b11111111;
    memory[1]=32'b11111111;
    memory[2]=32'b11111111;
    memory[3]=32'b11111111;
    memory[4]=32'b11111111;
    memory[5]=32'b11111111;
    memory[6]=32'b11111111;
    memory[7]=32'b11111111;
    memory[8]=32'b11111111;
    memory[9]=32'b11111111;
    memory[10]=32'b11111111;
    memory[11]=32'b11111111;
    memory[12]=32'b11111111;
    memory[13]=32'b11111111;
    memory[14]=32'b11111111;
    memory[15]=32'b11111111;
    memory[16]=32'b11111111;
    memory[17]=32'b11111111;
    memory[18]=32'b11111111;
    memory[19]=32'b11111111;
    memory[20]=32'b11111111;
    memory[21]=32'b11111111;
    memory[22]=32'b11111111;
    memory[23]=32'b11111111;
    memory[24]=32'b11111111;
    memory[25]=32'b11111111;
    memory[26]=32'b11111111;
    memory[27]=32'b11111111;
    memory[28]=32'b11111111;
    memory[29]=32'b11111111;
    memory[30]=32'b11111111;
    memory[31]=32'b11111111;
     
    valid_out = 0;
   end

   always @(posedge clk)
   begin
      // default
      valid_out <= 0;

      if (rd_en) begin
	 rdData1 <= memory[rdReg1];
	 rdData2 <= memory[rdReg2];
         valid_out <= 1;
      end
      else if (RegWrite) begin
         memory[WriteReg] <= writeData;
      end
   end
endmodule
