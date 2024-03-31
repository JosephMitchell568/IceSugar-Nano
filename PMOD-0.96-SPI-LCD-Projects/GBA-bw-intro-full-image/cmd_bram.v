// BRAM files were built off of wuxx example provided on his icesugar up5k
// Joseph Mitchell, 1/9/2024

// I will use preprocessor directives in the case of cmd names
//  since I will be using them in more than one module...

module cmd_bram(
	input wire clk, 
	input wire rd_en,
	input wire [4:0] rd_addr,	
	output reg [7:0] data_out, 
	output reg valid_out
   );

   reg [7:0] cmd_memory [0:21];

   initial begin
      // Modification: Direct initialization
      cmd_memory[0]  = 8'h11;   // SLPOUT
      cmd_memory[1]  = 8'hB1;   // FRMCTR1
      cmd_memory[2]  = 8'hB2;   // FRMCTR2
      cmd_memory[3]  = 8'hB3;   // FRMCTR3
      cmd_memory[4]  = 8'hB4;   // INVCTR
      cmd_memory[5]  = 8'hC0;   // PWCTR1
      cmd_memory[6]  = 8'hC1;   // PWCTR2
      cmd_memory[7]  = 8'hC2;   // PWCTR3
      cmd_memory[8]  = 8'hC3;   // PWCTR4
      cmd_memory[9]  = 8'hC4;   // PWCTR5
      cmd_memory[10] = 8'hC5;   // VMCTR1
      cmd_memory[11] = 8'hE0;   // GMCTRP1
      cmd_memory[12] = 8'hE1;   // GMCTRN1
      cmd_memory[13] = 8'hFC;   // PWCTR6
      cmd_memory[14] = 8'h3A;   // COLMOD
      cmd_memory[15] = 8'h36;   // MADCTL
      cmd_memory[16] = 8'h21;   // INVON
      cmd_memory[17] = 8'h29;   // DISPON
      cmd_memory[18] = 8'h2A;   // CASET
      cmd_memory[19] = 8'h2B;   // RASET
      cmd_memory[20] = 8'h2C;   // RAMWR
      cmd_memory[21] = 8'h00;

      valid_out = 0;
   end

   always @(posedge clk)
   begin
      // default
      valid_out <= 0;

      if (rd_en) begin
         data_out <= cmd_memory[rd_addr];
         valid_out <= 1; //When valid is observed logic high
      end		//data_out is cmd selected
   end

endmodule
