// Fourth initialization block ram for the
//  gba bw intro image project

module gba_bw_intro_b4ram(
	input wire clk,
	input wire rd_en, 
	input wire [5:0] rd_addr, 
	output reg [7:0] data_out, 
	output reg valid_out
   );

   reg [7:0] memory [0:63];
   integer i;

   initial begin
    memory[0]=8'b11111111;
    memory[1]=8'b11111111;
    memory[2]=8'b11111111;
    memory[3]=8'b11111111;
    memory[4]=8'b11111111;
    memory[5]=8'b11111111;
    memory[6]=8'b11111111;
    memory[7]=8'b11111111;
    memory[8]=8'b11111111;
    memory[9]=8'b11111111;
    memory[10]=8'b11111111;
    memory[11]=8'b11111111;
    memory[12]=8'b11111111;
    memory[13]=8'b11111111;
    memory[14]=8'b11111111;
    memory[15]=8'b11111111;
    memory[16]=8'b11111111;
    memory[17]=8'b11111111;
    memory[18]=8'b11111111;
    memory[19]=8'b11111111;
    memory[20]=8'b11111111;
    memory[21]=8'b11111111;
    memory[22]=8'b11111111;
    memory[23]=8'b11111111;
    memory[24]=8'b11111111;
    memory[25]=8'b11111111;
    memory[26]=8'b11111111;
    memory[27]=8'b11111111;
    memory[28]=8'b11111111;
    memory[29]=8'b11111111;
    memory[30]=8'b11111111;
    memory[31]=8'b11111111;
    memory[32]=8'b11111111;
    memory[33]=8'b11111111;
    memory[34]=8'b11111111;
    memory[35]=8'b11111111;
    memory[36]=8'b11111111;
    memory[37]=8'b11111111;
    memory[38]=8'b11111111;
    memory[39]=8'b11111111;
    memory[40]=8'b11111111;
    memory[41]=8'b11111111;
    memory[42]=8'b11111111;
    memory[43]=8'b11111111;
    memory[44]=8'b11111111;
    memory[45]=8'b11111111;
    memory[46]=8'b11111111;
    memory[47]=8'b11111111;
    memory[48]=8'b11111111;
    memory[49]=8'b11111111;
    memory[50]=8'b11111111;
    memory[51]=8'b11111111;
    memory[52]=8'b11111111;
    memory[53]=8'b11111111;
    memory[54]=8'b11111111;
    memory[55]=8'b11111111;
    memory[56]=8'b11111111;
    memory[57]=8'b11111111;
    memory[58]=8'b11111111;
    memory[59]=8'b11111111;
    memory[60]=8'b11111111;
    memory[61]=8'b11111111;
    memory[62]=8'b11111111;
    memory[63]=8'b11111111;
    valid_out = 0;
   end

   always @(posedge clk)
   begin
      // default
      valid_out <= 0;

      if (rd_en) begin
	 data_out <= memory[rd_addr];
         valid_out <= 1;
      end
   end
endmodule
