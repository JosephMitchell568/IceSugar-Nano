
module lcd_rst(  input CLK,
                 output reg LED,
		 output reg SCK,
		 output reg RST,
		 output reg DC,
		 output reg SDA,
		 output reg CS
                );

   localparam ACTIVATE_LCD_RST = 2'b00,
	      DELAY_100MS = 2'b01,
	      DEACTIVATE_LCD_RST = 2'b10;

   reg [1:0] state; 
   reg [25:0] counter;
   // According to the Makefile we use 48MHz clock
   // However, this FPGA does not have 48MHz clock
   // It does however have a 36MHz clock...
   //  So counter bit 25 should be closer to 1 hz freq
   //assign LED = ~counter[23];
   //assign LED = ~counter[21];

   initial begin
      counter = 0;
      state = ACTIVATE_LCD_RST;
   end

   always @(posedge CLK)
   begin
    case(state)
     ACTIVATE_LCD_RST: begin
      LED <= 1'b0;
      SCK <= 1'b0;
      RST <= 1'b0;
      DC <= 1'b0;
      SDA <= 1'b0;
      CS <= 1'b0;
      counter <= 26'b0;
      state <= DELAY_100MS;
     end
     DELAY_100MS: begin
      if(counter[20] == 1'b1)
      begin
       counter <= 26'b0;
       if(RST == 1'b0)
       begin
        state <= DEACTIVATE_LCD_RST;
	LED <= 1'b1;
       end
       else
       begin
        state <= ACTIVATE_LCD_RST;
	LED <= 1'b0;
       end
      end
      counter <= counter + 1'b1;
     end
     DEACTIVATE_LCD_RST: begin
      RST <= 1'b1;
      LED <= 1'b1;
      counter <= 26'b0;
      state <= DELAY_100MS;
     end
     default: begin
      state <= ACTIVATE_LCD_RST;
     end
    endcase
   end

endmodule
