
module lcd_rst(  input CLK,
                 output reg LED,
		 output reg SCK,
		 output reg RST,
		 output reg DC,
		 output reg SDA,
		 output reg CS
                );
   reg [31:0] state; 
   reg [25:0] counter;
   reg [7:0] data;
   reg [2:0] bit_counter;
   // According to the Makefile we use 48MHz clock
   // However, this FPGA does not have 48MHz clock
   // It does however have a 36MHz clock...
   //  So counter bit 25 should be closer to 1 hz freq
   //assign LED = ~counter[23];
   //assign LED = ~counter[21];

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
     32'd0: begin
      LED <= 1'b0;
      SCK <= 1'b0;
      RST <= 1'b0;
      DC <= 1'b0;
      SDA <= 1'b0;
      CS <= 1'b0;
      counter <= 26'b0;
      state <= 32'd1;
     end
     32'd1: begin
      if(counter[20] == 1'b1)
      begin
       counter <= 26'b0;
       state <= 32'd2;
       LED <= 1'b1;
      end
      else
      begin
       LED <= 1'b0;
      end
      counter <= counter + 1'b1;
     end
     32'd2: begin
      RST <= 1'b1;
      LED <= 1'b1;
      counter <= 26'b0;
      state <= 32'd3;
     end
     32'd3: begin
      if(counter[20] == 1'b1)
      begin
       LED <= 1'b0;
       counter <= 26'b0;
       state <= 32'd4; // Begin sleep-out
      end
      else
      begin
       LED <= 1'b1;
      end
      counter <= counter + 1'b1;
     end
     // LCD RESET END
     // LCD SLEEP-OUT BEGIN
     32'd4: begin // I need to ask myself, What can happen concurrently?
      // Step 1: Lower Data/Command line
      // Step 2: Set the data bits
      // Step 3: Lower chip select signal
      // Step 4: Lower serial clock signal
      // { 1, 2, 3, 4 } = One State
      // Step 5: Check MSB ; Raise/Lower MOSI signal
      // Step 6: Raise serial clock signal
      // Step 7: Shift data left 1 bit
      // Step 8: Increment data counter
      // { 5, 6, 7, 8 } = Two State
      // Step 9: Check data counter
      // Step 10: Go through another loop iteration
      // Step 11: Go through the last loop iteration (Include raising CS)
      // { 9, 10, 11 } = Three State
      // Step 12: Delay for 120ms
     end

    endcase
   end

endmodule
