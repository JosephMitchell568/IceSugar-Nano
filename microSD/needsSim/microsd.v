// Joseph Mitchell, 4/3/2024
// This project is meant to communicate
//  with the microSD card
//  to write and read data
// First step in this process is to initialize it
//  Send CMD0 first (no response expected)
//
module microsd(
 input CLK,
 output SD_CLK,
 output LED,
 inout CMD, //For simulation have port declaration be output
 inout [3:0] DAT //For simulation have port declaration be output
 );

 reg led; // Error LED register
 reg sd_clk; // SD CLK register
 reg cmd; // CMD register
 reg [3:0] dat; // Data Line registers

 // CMD FORMAT : 48 bits wide
 // Start Bit [47]              |      '0'
 // Transmission Bit [46]       |      '1'
 // Command Index [45:40]       |
 // Argument [39:8]             |        
 // CRC7 [7:1]                  |         
 // End Bit [0]                 |      '1'

 parameter CMD0 = 
  48'b0_1_000000_00000000000000000000000000000000_0000000_1;// Move past hardcoded CRCs...
 // CMD0 [GO_IDLE_STATE]:                    This was why Error LED turned on
 // Start Bit - 0
 // Transmission Bit - 1
 // Cmd Index - 0 [6 bits]
 // Argument - 0 [32 bits]
 // CRC7 - 1001010 [7 bits]
 // End Bit - 1
 //
 // RESPONSE:
 // N/A No RESPONSE expected

 // SEND_IF_COND
 parameter CMD8 =
  48'b0_1_001000_00000000000000000000000110101010_0000000_1;// Move past hardcoded CRCs...
 // CMD8 [SEND_IF_COND]:                     This was why Error LED turned on
 // Start Bit - 0
 // Transmission Bit - 1
 // Cmd Index - 001000
 // Argument - 0x1AA [32 bits]
 // CRC7 - 0x43 [7 bits]
 // End bit - 1
 // 
 // RESPONSE:
 // Start Bit - 0
 // Transmission Bit - 0
 // Cmd Index - 001000
 // Arguement - 0x1AA [32 bits]
 // CRC7 - 0x43 [7 bits]
 // End bit - 1
 //
 // When waiting response there should be 44 bits
 //  of R7 after the leading 0s of Cmd Index and Start/Transmission


 reg [13:0] init_delay; // Delay required before sending any commands


 reg [5:0] resp_delay; // Response Delay 
 reg [47:0] sd_cmd_resp; // Actual Response to CMD

 reg cmd_read; // Raise for cmd line read
 reg dat_read; // Raise for data line read

 reg [47:0] sd_mem_cmd;// current sd memory command
 reg sd_mem_cmd_last; // sd memory command last bit flag
 reg [5:0] sd_mem_cmd_ptr;// sd memory command bit pointer

 reg [3:0] sd_mem_state;// Current state of sd memory FSM
 parameter DELAY = 4'b0000;// Delay before sending first command
 parameter CALC_CRC = 4'b0001;// Calculate CRC for CMD transmission
 parameter SEND_CMD = 4'b0010;// Send SD Memory CMD
 parameter WAIT_RESPONSE = 4'b0011;// Wait Response
 parameter SEND_LAST = 4'b0100;// Send Last CMD bit 
 parameter END = 4'b1000;// END state for testing

 reg [6:0] clkdiv; // 7 bit counter for clock divider (100khz)
 reg one_hundredkhz;


 // CRC params/registers
 reg [6:0] data_ptr;// Point to next databit to shift into crc buffer
                                                                       
 reg [3:0] crc_state;
 // CRC STATE PARAMS
 parameter FULL_LOAD  = 4'b0000;
 parameter XOR_CRC   = 4'b0001;
 parameter SHIFT      = 4'b0010;
 parameter LOAD_NEXT  = 4'b0011;
 parameter CRC_FINISH = 4'b0100;
 // END CRC STATE PARAMS
 reg [7:0] crc_buffer;                                                 
 // END CRC params/registers                                           



 initial
 begin
  led = 1'b0; // led low since no error yet
  sd_clk = 1'b0; // Start sd clock low
  cmd = 1'b1; // Initialize command line to 1
  dat[3:0] = 4'b1111; // Initialize to all data lines to 1

  sd_mem_cmd[47:0] = CMD0; // Set initial sd memory command CMD0
  
  sd_mem_cmd_ptr[5:0] = 6'd47; // SD Memory cmd bit pointer
  
  sd_mem_state = DELAY; // Init state
  resp_delay = 6'b110101; // 53 clock cycles ~2us delay
  sd_cmd_resp = 48'b0; // Cmd response init 0

  cmd_read = 1'b0; // Not ready to read a CMD response from card yet
  dat_read = 1'b0; // No data to read yet

  init_delay = 7'b1010000; // 80 100khz clock pulses

  data_ptr = 7'd47; // point to MSB of data
                                           
  crc_state = FULL_LOAD; // FULL_LOAD
  crc_buffer = 8'b0000_0000; // CRC Buffer  
 end

 always @(posedge CLK)
 begin
  
  if(clkdiv == 119)
  begin
   clkdiv <= 0;
  end
  else
  begin
   clkdiv <= clkdiv + 1;
  end

  one_hundredkhz <= (clkdiv == 119) ? 1'b1 : 1'b0;

 end

 always @(posedge one_hundredkhz)
 begin

  if(init_delay != 7'b0)
  begin
   init_delay <= init_delay - 7'b1;
  end

 end



 always @(posedge CLK)
 begin
 
  case(sd_mem_state) // Send CMD or Wait RESPONSE
   
   DELAY: // Init cmd delay
   begin

    sd_clk <= ~sd_clk; // toggle sd clock until initial command delay complete

    if(init_delay == 7'b0)
    begin
     sd_mem_state <= CALC_CRC;
    end
    else
    begin
     sd_mem_state <= DELAY;
    end

   end

   CALC_CRC: // CalcCMDCRC state
   begin
   
    case(crc_state)                                                                                        
     FULL_LOAD:
     begin
      crc_buffer[7:0] <= sd_mem_cmd[47:40];// Load first 8 most significant data bits
      data_ptr <= data_ptr - 7'd8;// Point to first data bit after first load
      crc_state <= XOR_CRC;// Transition to XNOR_CRC state
     end
                                                                                                          
     XOR_CRC:
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
      crc_buffer[0] <= sd_mem_cmd[data_ptr];// Set next data bit                                               
      if(data_ptr != 7'd0)
      begin
       data_ptr <= data_ptr - 7'd1;// Decrement data pointer
       if(crc_buffer[7] == 1'b1 || data_ptr == 7'd1)// MSB 1, or last data bit has been loaded
       begin
        crc_state <= XOR_CRC;
       end
       else
       begin
        crc_state <= SHIFT;
       end
      end
      else
      begin
       crc_state <= XOR_CRC;
      end
     end   
                                                                                                                     
     CRC_FINISH:
     begin
      case(sd_mem_cmd)
       CMD0:
       begin
        if(crc_buffer[6:0] != 7'b100_1010)// CMD0 was correct with 0x4A, now CMD8 needs to be correct with 0x43
        begin
         led <= 1'b1;// Raise Error LED when the calculated crc is not expected 0x4A for CMD0
	 //sd_mem_cmd[7:1] <= crc_buffer[6:0];
        end                                                                                                    
        else
        begin
         sd_mem_cmd[7:1] <= crc_buffer[6:0];// Set the calculated CRC7 for CMD0 before sending
        end
       end
                                                                                                                      
       CMD8:
       begin
        if(crc_buffer[6:0] != 7'b100_0011)// CMD0 was correct with 0x4A, now CMD8 needs to be correct with 0x43
        begin
         led <= 1'b1;// Raise Error LED when the calculated crc is not expected 0x4A for CMD0
	 sd_mem_cmd[7:1] <= crc_buffer[6:0];
        end                                                                                                    
        else
        begin
         sd_mem_cmd[7:1] <= crc_buffer[6:0];// Set the calculated CRC7 for CMD8 before sending
        end
       end
                                                                                                                      
      endcase
      data_ptr <= 7'd47;    
      crc_state <= FULL_LOAD;// Now instead of CRC_FINISH being a dead state, reset CRC FSM...
      sd_mem_state <= SEND_CMD;// And escape CRC FSM to send the CMD
     end
    endcase   

   end

   SEND_CMD: // Send CMD
   begin
 
    sd_clk <= ~sd_clk; // Toggle sd clock

    if(sd_clk == 1'b1) //Set command bit on falling edge + decrement
    begin              
     cmd <= sd_mem_cmd[sd_mem_cmd_ptr]; // Set cmd line to sd_mem_cmd
     if(sd_mem_cmd_ptr == 6'b0) // If sending LSB
     begin// Last CMD bit is set
      sd_mem_cmd_ptr <= 6'd47; // Reset back to MSB 
      sd_mem_state <= SEND_LAST; // Transition to SEND_LAST_CMD_BIT
     end
     else
     begin
      sd_mem_cmd_ptr <= sd_mem_cmd_ptr - 6'b1; // Point to next bit
      sd_mem_state <= SEND_CMD; // Return to Send CMD0
     end
    end
  
   end

   WAIT_RESPONSE: // Wait RESPONSE
   begin // Remember to add default response delay for CMD0

    sd_clk <= ~sd_clk; // Toggle SD CLK

    cmd <= CMD; // Save the current cmd line value in cmd register

    if(cmd == CMD) // prev cmd is equal to current cmd : no response found
    begin
     if(sd_clk == 1'b0)// If rising edge of clock
     begin
      if(resp_delay == 32'b0) // CMD response timed out
      begin
       resp_delay <= 6'b110101; // Reset response delay
       case(sd_mem_cmd[45:40])// Check the CMD Index becuase sd_mem_cmd has calculated CRC now!
        6'b000000: //CMD index 0 
        begin
         sd_mem_cmd <= CMD8; // Set next CMD to CMD8: SEND_IF_COND
        end
       endcase
       sd_mem_state <= CALC_CRC; // Remember to calculate CRC first!
       cmd_read <= 1'b0; // Lower command read signal before writing to command line
       sd_mem_cmd_ptr <= 6'd47; // Ensure sd memory command bit pointer is MSB
      end                       
      else
      begin
       resp_delay <= resp_delay - 6'b1; // Decrement response delay
       sd_mem_state <= WAIT_RESPONSE; // Only transition back to wait response when not timed out
      end
     end
    end
    else // A Response has been found
    begin
     //if(sd_mem_cmd[45:40] == 6'b000000)
     //begin
     // led <= 1'b1; // At no point should there be a response from CMD0
     //end
     sd_mem_state <= END; // Once a response has been received from card go to END state
     resp_delay <= 6'b110101; // Reset response delay for next command
    end

   end

   SEND_LAST: // SEND_LAST_CMD_BIT
   begin// sd clock is low, need rising edge
    sd_clk <= ~sd_clk; // Give rising edge of sd clock
    cmd_read <= 1'b1; // Send cmd line to high impedence to wait response
    cmd <= CMD; // Save the last cmd line value
    sd_mem_state <= WAIT_RESPONSE; // Transition to wait response 
   end

   END: // Dead State for testing
   begin
    sd_clk <= ~sd_clk; // Toggle sd clock while in dead state...
    if(sd_mem_cmd[45:40] == 6'b001000)// If CMD Index is 8, let me know
    begin
     led <= 1'b1; // Turn light on only when response to CMD8 is found...
    end
    sd_mem_state <= END;
   end

  endcase
 end

 assign LED = led;
 assign SD_CLK = sd_clk;
 assign CMD = cmd_read ? 1'bz : cmd;
 assign DAT[3] = dat[3];
 assign DAT[2] = dat[2];
 assign DAT[1] = dat[1];
 assign DAT[0] = dat[0];
endmodule
