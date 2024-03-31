// BRAM files were built off of wuxx example provided on his icesugar up5k
// Joseph Mitchell, 1/9/2024

module param_bram(
	input wire clk, 
	input wire rd_en, 
	input wire [6:0] rd_addr,  //Bug found here with width 
	output reg [7:0] data_out, 
	output reg valid_out
   );

   reg [7:0] param_memory [0:67];

   initial begin
      param_memory[0]  = 8'h05;
      param_memory[1]  = 8'h3C;
      param_memory[2]  = 8'h3C;//FRMCTR1
      param_memory[3]  = 8'h05;
      param_memory[4]  = 8'h3C;
      param_memory[5]  = 8'h3C;//FRMCTR2
      param_memory[6]  = 8'h05;
      param_memory[7]  = 8'h3C;
      param_memory[8]  = 8'h3C;
      param_memory[9]  = 8'h05;
      param_memory[10] = 8'h3C;
      param_memory[11] = 8'h3C;//FRMCTR3
      param_memory[12] = 8'h03;//INCTR
      param_memory[13] = 8'hAB;
      param_memory[14] = 8'h0B;
      param_memory[15] = 8'h04;//PWCTR1
      param_memory[16] = 8'hC5;//PWCTR2
      param_memory[17] = 8'h0D;
      param_memory[18] = 8'h00;//PWCTR3
      param_memory[19] = 8'h8D;
      param_memory[20] = 8'h6A;//PWCTR4
      param_memory[21] = 8'h8D;
      param_memory[22] = 8'hEE;//PWCTR5
      param_memory[23] = 8'h0F;//VMCTR1
      param_memory[24] = 8'h07;
      param_memory[25] = 8'h0E;
      param_memory[26] = 8'h08;
      param_memory[27] = 8'h07;
      param_memory[28] = 8'h10;
      param_memory[29] = 8'h07;
      param_memory[30] = 8'h02;
      param_memory[31] = 8'h07;
      param_memory[32] = 8'h09;
      param_memory[33] = 8'h0F;
      param_memory[34] = 8'h25;
      param_memory[35] = 8'h36;
      param_memory[36] = 8'h00;
      param_memory[37] = 8'h08;
      param_memory[38] = 8'h04;
      param_memory[39] = 8'h10;//GMCTRP1
      param_memory[40] = 8'h0A;
      param_memory[41] = 8'h0D;
      param_memory[42] = 8'h08;
      param_memory[43] = 8'h07;
      param_memory[44] = 8'h0F;
      param_memory[45] = 8'h07;
      param_memory[46] = 8'h02;
      param_memory[47] = 8'h07;
      param_memory[48] = 8'h09;
      param_memory[49] = 8'h0F;
      param_memory[50] = 8'h25;
      param_memory[51] = 8'h35;
      param_memory[52] = 8'h00;
      param_memory[53] = 8'h09;
      param_memory[54] = 8'h04;
      param_memory[55] = 8'h10;//GMCTRN1
      param_memory[56] = 8'h80;//PWCTR6
      param_memory[57] = 8'h05;//COLMOD
      param_memory[58] = 8'h78;//MADCTL
      param_memory[59] = 8'h00;
      param_memory[60] = 8'h01;
      param_memory[61] = 8'h00;
      param_memory[62] = 8'hA0;//CASET
      param_memory[63] = 8'h00;
      param_memory[64] = 8'h1A;
      param_memory[65] = 8'h00;
      param_memory[66] = 8'h69;//RASET
      param_memory[67] = 8'h50;// Purple Test Color
      valid_out = 0;
   end     
           
   always @(posedge clk)
   begin   
      // default
      valid_out <= 0;
           
      if (rd_en) begin
         data_out <= param_memory[rd_addr];
         valid_out <= 1;
      end  
   end    
endmodule  
           
