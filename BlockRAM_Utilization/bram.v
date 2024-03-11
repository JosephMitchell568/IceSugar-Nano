//this should be transformed into a bram when doing a synthesis in yosys 0.8
//and it should be equivalent to the explicit_bram.v

module bram(
	input wire clk,
	input wire rd_en, 
	input wire [8:0] rd_addr, 
	output reg [7:0] data_out, 
	output reg valid_out
   );

   reg [7:0] memory [0:511];
   integer i;

   initial begin
      for(i = 0; i <= 511; i=i+1) begin
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
