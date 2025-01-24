// Joseph Mitchell, 1/22/2025
// Calculate CRC for binary data packet
//  Instantiate this module in microsd
module crc(
 input CLK, // Clock that drives system
 output LED // Error LED [Flash when CRC incorrect!]
 );

 reg led; // Error LED register
 reg [47:0] data; // SD CMD data packet 40 bits + 7 trailing zeros
                  // Ignore start and end bit for crc transmission
 reg [6:0] data_ptr;// Point to next databit to shift into crc buffer

 reg [3:0] crc_state;
 // CRC STATE PARAMS
 parameter FULL_LOAD  = 4'b0000;
 parameter XNOR_CRC   = 4'b0001;
 parameter SHIFT      = 4'b0010;
 parameter LOAD_NEXT  = 4'b0011;
 parameter CRC_FINISH = 4'b0100;
 // END CRC STATE PARAMS
 reg [7:0] crc_buffer;

 initial
 begin
  led = 1'b0; // led low since no error yet
  data = 48'b0_1_000000_00000000000000000000000000000000_0000000_1; // Full SD Memory command empty crc
  data_ptr = 7'd47; // point to MSB of data

  crc_state = 4'b0000; // LOAD_BUFFER
  crc_buffer = 8'b0000_0000; // CRC Buffer
 end

 always@(posedge CLK)
 begin
  case(crc_state)
   FULL_LOAD:
   begin
    crc_buffer[7:0] <= data[47:40];// Load first 8 most significant data bits
    data_ptr <= data_ptr - 7'd8;// Point to first data bit after first load
    crc_state <= XNOR_CRC;// Transition to XNOR_CRC state
   end

   XNOR_CRC:
   begin
    if(crc_buffer[7] == 1'b0)// If MSB is leading zero, SHIFT it out
    begin
     crc_state <= SHIFT;// Transition to SHIFT to shift MSB out
     if(data_ptr == 7'd0)// If last data bit already loaded...
     begin
      crc_state <= CRC_FINISH;// We are finished!
     end
    end
    else
    begin
     crc_buffer[7:0] <=  {crc_buffer[7] ^ 1'b1, // x^7
                          crc_buffer[6] ^ 1'b0, 
                          crc_buffer[5] ^ 1'b0,
                          crc_buffer[4] ^ 1'b0,
                          crc_buffer[3] ^ 1'b1, // x^3
                          crc_buffer[2] ^ 1'b0,
                          crc_buffer[1] ^ 1'b0,
                          crc_buffer[0] ^ 1'b1  // 1
                        };// Generator Polynomial : x^7 + x^3 + 1
     if(data_ptr != 7'd0)// We need to process data[1]
     begin
      crc_state <= SHIFT;
     end
     else
     begin
      crc_state <= CRC_FINISH;
     end
    end
   end

   SHIFT:
   begin
    crc_buffer <= crc_buffer << 1; // Shift out CRC Buffer MSB and replace it with next data bit
                                   // LSB is now 0
    crc_state <= LOAD_NEXT;
   end                     

   LOAD_NEXT:
   begin
    crc_buffer[0] <= data[data_ptr];// Set next data bit
    if(data_ptr != 7'd0)
    begin
     data_ptr <= data_ptr - 7'd1;// Decrement data pointer
     if(crc_buffer[7] == 1'b1 || data_ptr == 7'd1)// MSB 1, or last data bit has been loaded
     begin
      crc_state <= XNOR_CRC;
     end
     else
     begin
      crc_state <= SHIFT;
     end
    end
    else
    begin
     crc_state <= XNOR_CRC;
    end
   end   

   CRC_FINISH:
   begin
    if(crc_buffer[6:0] != 7'b100_1010)
    begin
     led <= 1'b1;// Raise Error LED when the calculated crc is not expected 0x4A for CMD0
    end
    crc_state <= CRC_FINISH;
   end

  endcase
 end

 assign LED = led;
endmodule
