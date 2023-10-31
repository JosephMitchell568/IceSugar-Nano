
module lcd_rst(  input CLK,
                 output reg LED,
		 output reg SCK,
		 output reg RST,
		 output reg DC,
		 output reg SDA,
		 output reg CS
                );
   reg [2:0] state; 
   reg [25:0] counter;
   // According to the Makefile we use 48MHz clock
   // However, this FPGA does not have 48MHz clock
   // It does however have a 36MHz clock...
   //  So counter bit 25 should be closer to 1 hz freq
   //assign LED = ~counter[23];
   //assign LED = ~counter[21];

   initial begin
      counter = 0;
      state = 0;
   end

   always @(posedge CLK)
   begin
    case(state)
     2'b00: begin
      LED <= 1'b0;
      SCK <= 1'b0;
      RST <= 1'b0;
      DC <= 1'b0;
      SDA <= 1'b0;
      CS <= 1'b0;
      counter <= 26'b0;
      state <= 2'b01;
     end
     2'b01: begin
      if(counter[20] == 1'b1)
      begin
       counter <= 26'b0;
       state <= 2'b10;
       LED <= 1'b1;
      end
      else
      begin
       LED <= 1'b0;
      end
      counter <= counter + 1'b1;
     end
     2'b10: begin
      RST <= 1'b1;
      LED <= 1'b1;
      counter <= 26'b0;
      state <= 2'b11;
     end
     2'b11: begin
      if(counter[20] == 1'b1)
      begin
       LED <= 1'b0;
       counter <= 26'b0;
       state <= 2'b00;
      end
      else
      begin
       LED <= 1'b1;
      end
      counter <= counter + 1'b1;
     end
    endcase
   end

endmodule
