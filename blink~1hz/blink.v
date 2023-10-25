
module switch(  input CLK,
                output LED
                );
      
   reg [25:0] counter;
   // According to the Makefile we use 48MHz clock
   // However, this FPGA does not have 48MHz clock
   // It does however have a 36MHz clock...
   //  So counter bit 25 should be closer to 1 hz freq
   assign LED = ~counter[23];
   //assign LED = ~counter[21];

   initial begin
      counter = 0;
   end

   always @(posedge CLK)
   begin
      counter <= counter + 1;
   end



endmodule
