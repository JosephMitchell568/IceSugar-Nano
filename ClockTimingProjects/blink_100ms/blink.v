
module switch(  input CLK,
                output LED
                );
      
   reg [25:0] counter;
   reg led;
   // According to the Makefile we use 48MHz clock
   // However, this FPGA does not have 48MHz clock
   // It does however have a 36MHz clock...
   //  So counter bit 25 should be closer to 1 hz freq
   assign LED = led; //1001100110011001100110100
   //assign LED = ~counter[21];

   initial begin
      counter = 0;
      led = 1'b0;
   end

   always @(posedge CLK)
   begin
      if(counter == 26'b100100100111110000000)
      begin
       counter <= 26'b0;
       led = ~led;
      end
      else
      begin
       counter <= counter + 1;
      end
   end



endmodule
