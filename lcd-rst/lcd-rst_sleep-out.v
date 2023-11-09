
module lcd_rst(  input CLK,
                 output reg LED,
		 output reg SCK,
		 output reg RST,
		 output reg DC,
		 output reg SDA,
		 output reg CS
                );
   localparam ACTIVATE_LCD_RST = 32'd0,
	      DELAY_100MS = 32'd1,
	      DEACTIVATE_LCD_RST = 32'd2,

              SLEEP_OUT_SETUP = 32'd4,
              CHECK_DATA_COUNTER = 32'd5,
              PROCESS_LAST_BIT = 32'd6,
              PROCESS_MSB = 32'd7,

              DELAY120MS = 32'd8,
	      
	      END = 32'd9;

   reg [31:0] state; 
   reg [25:0] counter;

   reg [7:0] data;
   reg [2:0] bit_counter;

   initial begin
      counter = 0;
      state = 0;
      data = 0;
      bit_counter = 0;
   end

   always @(posedge CLK)
   begin
    case(state)
     // LCD RESET START
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
      if(counter == 26'b100100100111110000000) //More exact 100 MS timer...
      begin
       counter <= 26'b0;
       if(RST == 1'b0)
       begin
        state <= DEACTIVATE_LCD_RST;
        LED <= 1'b1;
       end
       else
       begin
	state <= SLEEP_OUT_SETUP;
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
     // LCD RESET END
     // LCD SLEEP-OUT BEGIN
     SLEEP_OUT_SETUP: begin // I need to ask myself, What can happen concurrently?
      // Step 1: Lower Data/Command line
      // Step 2: Set the data bits
      // Step 3: Lower chip select signal
      // Step 4: Lower serial clock signal
      // { 1, 2, 3, 4 } = One State

      DC <= 1'b0; // Step 1
      data <= 8'h11; // Step 2 set data bits
      CS <= 1'b0; // Step 3
      
      SCK <= 1'b0; // Step 4

      LED <= 1'b0; // Turn off test LED

      state <= PROCESS_MSB; //Does FSM reach this state?
       
      // { 9, 10, 11 } = Three State
      // Step 12: Delay for 120ms
     end
     PROCESS_MSB: begin
      // Step 5: Check MSB ; Raise/Lower MOSI signal
      // Step 6: Raise serial clock signal
      // Step 7: Shift data left 1 bit
      // Step 8: Increment data counter
      // { 5, 6, 7, 8 } = Two State                 

      if(data[7]) // Step 5
      begin
       SDA <= 1'b1; // Step 5
      end
      else
      begin
       SDA <= 1'b0; // Step 5
      end

      LED <= 1'b0;

      SCK <= 1'b1; // Step 6
      data <= data << 1; // Step 7
      bit_counter <= bit_counter + 1'b1; // Step 8
      state <= CHECK_DATA_COUNTER;
     end
     CHECK_DATA_COUNTER: begin
      // Step 9: Check data counter
      // Step 10: Go through another loop iteration
      // Step 11: Go through the last loop iteration (Include raising CS)

      LED <= 1'b0;



      if(bit_counter == 3'd7) // Step 9
      begin
       // Step 11 goes here
       if(data[7])
       begin
	SDA <= 1'b1;
       end
       else
       begin
	SDA <= 1'b0;
       end
       SCK <= 1'b1;
       bit_counter <= 3'd0;
       counter <= 26'd0;
       CS <= 1'b1; // Remember to raise CS at the end...
       state <= DELAY120MS;
      end
      else
      begin
       state <= PROCESS_MSB; // Step 10
       SCLK <= 1'b0; // Ensure the serial clock is set
      end
     end
     DELAY120MS: begin
      LED <= 1'b0;
      if(counter == 26'b101011111100100000000)
      begin
       counter <= 26'b0;
       state <= END;
      end
      else
      begin
       counter <= counter + 26'b1;
      end
      state <= DELAY120MS;
     end
     END: begin
      LED <= 1'b1;
      state <= END;
     end
     // LCD SLEEP-OUT END
    endcase
   end

endmodule
