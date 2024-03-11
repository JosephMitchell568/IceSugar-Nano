// This bram block will be the remaining bram
//  required in order to achieve 100% memory util
//  I will perform a binary search using the addr

module bramfull(
	input wire clk,
	input wire rd_en, 
	input wire [3:0] rd_addr, 
	output reg [7:0] data_out, 
	output reg valid_out
   );

   reg [7:0] memory [0:8]; //10 -> *(11)* -> 12
   integer i;

   initial begin
      for(i = 0; i <= 8; i=i+1) begin
         memory[i] = 8'b001;
      end
      
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
