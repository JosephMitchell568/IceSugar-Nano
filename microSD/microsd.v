// Joseph Mitchell, 4/3/2024
// This project is meant to communicate
//  with the microSD card
//  to write and read data
// First step in this process is to initialize it
//  Send CMD0 first (no response expected)
//
`include "cmd_bram.v" //Use bram for cmd index list
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

 parameter CMD0   = 48'b0_1_000000_00000000000000000000000000000000_0000000_1;// GO_IDLE_STATE
 parameter CMD8   = 48'b0_1_001000_00000000000000000000000110101010_0000000_1;// SEND_IF_COND
 parameter CMD55  = 48'b0_1_110111_00000000000000000000000000000000_0000000_1;// APP_CMD - Tell SD Card next cmd APP
 parameter CMD41  = 48'b0_1_101001_01000000000100000000000000000000_0000000_1;// HCS && 3.3v raised SEND_OP_COND
 parameter CMD2   = 48'b0_1_000010_00000000000000000000000000000000_0000000_1;// CMD2 ALL_SEND_CID
 parameter CMD3   = 48'b0_1_000011_00000000000000000000000000000000_0000000_1;// CMD3 SEND_RELATIVE_ADDR
 parameter CMD7   = 48'b0_1_000111_00000000000000000000000000000000_0000000_1;// CMD7 needs RCA from CMD3
 parameter CMD6   = 48'b0_1_000110_00000000000000000000000000000010_0000000_1;// CMD6 for ACMD6 to SET_BUS_WIDTH

 reg [13:0] init_delay; // Delay required before sending any commands


 reg [5:0] resp_delay; // Response Delay
 reg [135:0] sd_cmd_resp_r2; // Response from CMD2
 reg [7:0] sd_cmd_resp_ptr_r2; // Point to current R2 response bit
 reg [47:0] sd_cmd_resp; // Actual Response to CMD
 reg [5:0] sd_cmd_resp_ptr;// Point to current response bit

 reg cmd_read; // Raise for cmd line read
 reg dat_read; // Raise for data line read

 reg [47:0] sd_cmd;// current sd memory command
 reg [5:0] sd_cmd_ptr;// sd memory command bit pointer

 reg [15:0] sd_rca;// Target card's RELATIVE_CARD_ADDR from CMD3

 reg [3:0] sd_mem_state;// Current state of sd memory FSM
 parameter DELAY = 4'b0000;// Delay before sending first command
 parameter SET_CMD = 4'b0001;// Set next SD Memory command
 parameter CALC_CRC_CMD = 4'b0010;// Calculate CRC for CMD
 parameter SEND_CMD = 4'b0011;// Send SD Memory CMD
 parameter WAIT_RESPONSE = 4'b0100;// Wait Response
 parameter READ_RESPONSE = 4'b0101;// Read Response
 parameter FINISH_RESPONSE = 4'b0110;// Finish Response
 parameter CALC_CRC_RESP = 4'b0111;// Calculate CRC for RESPONSE
 parameter SEND_LAST_CMD_BIT = 4'b1000;// Send Last CMD bit 
 parameter END = 4'b1001;// END state for testing

 parameter SEND_ACMD51 = 4'b1010;// SEND_ACMD51


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
 reg [7:0] crc_counter;
 // END CRC params/registers                                           


 // CMD BRAM registers/wires
 reg cb_rd_en;
 reg [4:0] cb_rd_addr;// 5 bit cmd read address 

 wire [7:0] cb_data_out;// Start bit, transmission bit, cmd index
 wire cb_valid;
 // END CMD BRAM registers/wires

 //************ CMD BRAM instantiation *************
 cmd_bram cmd_bram_inst(
  .clk(CLK),
  .rd_en(cb_rd_en),
  .rd_addr(cb_rd_addr),
  .data_out(cb_data_out),
  .valid_out(cb_valid)
 );
 //************ END CMD BRAM instantiation *********


 initial
 begin
  led = 1'b0; // led low since no error yet
  sd_clk = 1'b0; // Start sd clock low
  cmd = 1'b1; // Initialize command line to 1
  dat[3:0] = 4'b1111; // Initialize to all data lines to 1

  sd_cmd[47:0] = 48'd0; // Initialize to 0
  
  sd_cmd_ptr[5:0] = 6'd47; // SD Memory cmd bit pointer
  
  sd_mem_state = DELAY; // Init state
  
  resp_delay = 6'b110101; // 53 clock cycles ~2us delay
  sd_cmd_resp = 48'b0; // Cmd response
  sd_cmd_resp_ptr = 48'd47; // CMD response pointer MSB

  sd_cmd_resp_r2 = 136'b0;// Init 0
  sd_cmd_resp_ptr_r2 = 8'd135; // Initialize to MSB 135

  cmd_read = 1'b0; // Not ready to read a CMD response from card yet
  dat_read = 1'b0; // No data to read yet

  cb_rd_en = 1'b0;// CMD BRAM enable line
  cb_rd_addr = 5'b00000;// Point to first CMD to run

  init_delay = 7'b1010000; // 80 100khz clock pulses

  data_ptr = 7'd47; // point to MSB of data
                                           
  crc_state = FULL_LOAD; // FULL_LOAD
  crc_buffer = 8'b0000_0000; // CRC Buffer  
  crc_counter = 8'b0000_0000;
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
     sd_mem_state <= SET_CMD;
     cb_rd_en <= 1'b1;
    end
    else
    begin
     sd_mem_state <= DELAY;
    end
   end



   //////////////////////   SD Memory CMD related states  //////////////////



   SET_CMD:
   begin
    if(cb_valid == 1'b0)
    begin
     sd_mem_state <= SET_CMD;
    end
    else
    begin
     sd_mem_state <= CALC_CRC_CMD;// Only transition to CALC_CRC_CMD once command data is valid
     cb_rd_addr <= cb_rd_addr + 5'b1;// Increment cmd bram read address
     case(cb_rd_addr)
      5'b1:    sd_cmd <= {cb_data_out,32'h1AA,7'b0,1'b1};
      5'b11:   sd_cmd <= {cb_data_out,32'h40100000,7'b0,1'b1};
      5'b100:
      begin
       if(sd_cmd_resp[38] != 1'b1)// If ACMD41 does not send microSD card to READY state...
       begin
        cb_rd_addr <= 5'b00011;// Point to CMD41 for next SET_CMD state
	sd_cmd <= {8'b0_1_110111,32'b0,7'b0,1'b1};// Set CMD55
        sd_mem_state <= CALC_CRC_CMD;// Stay in SET_CMD state 
       end
       else
       begin
        sd_cmd <= {cb_data_out,32'b0,7'b0,1'b1};// Send CMD2
       end                                                                                             
      end
      5'b110:
      begin
       sd_rca <= sd_cmd_resp[38:23];// Should be 16 bits...
       sd_cmd <= {cb_data_out,sd_cmd_resp[38:23],16'b0,7'b0,1'b1};
      end
      5'b111:
      begin
       sd_cmd <= {cb_data_out,sd_rca,16'b0,7'b0,1'b1};// Try Sending APP_CMD with its RCA in the argument...
      end
      5'b1000:// Send ACMD6 with bus width set to 4 bit
      begin
       sd_cmd <= {cb_data_out,32'h00000002,7'b0,1'b1};// SET_BUS_WIDTH to 4 bit
       //sd_mem_state <= END;
      end
      5'b1001:
      begin
       sd_cmd <= {cb_data_out,sd_rca,16'b0,7'b0,1'b1};
       //sd_mem_state <= END;
      end
      5'b1011:
      begin
       sd_mem_state <= END;
      end
      default: sd_cmd <= {cb_data_out,32'b0,7'b0,1'b1};// Applies to CMD55
     endcase
    end
   end

/////////////// USE BRAM for the SD Memory CMDs ////////////////////


   CALC_CRC_CMD: // CalcCMDCRC state
   begin
   
    case(crc_state)                                                                                        
     FULL_LOAD:
     begin
      crc_buffer[7:0] <= sd_cmd[47:40];// Load first 8 most significant cmd bits
      data_ptr <= data_ptr - 7'd8;// Point to 9th bit
      crc_state <= XOR_CRC;// Transition to XNOR_CRC state
     end
                                                                                                          
     XOR_CRC:// Left off here, mirror CALC_CRC_RESP state but with response data instead.
     begin     // After we have working intialization working for microSD card I can clean this up...
      if(crc_buffer[7] == 1'b0)// If MSB is leading zero, SHIFT it out
      begin 
       if(data_ptr == 7'd0)// If last data bit already loaded...
       begin
        crc_state <= CRC_FINISH;// We are finished!
       end
       else// Last data bit has yet to be loaded
       begin
        crc_state <= SHIFT;// Only when MSB is 0 and last bit not loaded in
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
       if(data_ptr != 7'd0)// Last data bit has not been loaded yet
       begin
        crc_state <= SHIFT;// Shift leading 0 out
       end
       else
       begin
        crc_state <= CRC_FINISH;
       end
      end
     end
                                                                                                          
     SHIFT:
     begin
      if(data_ptr == 7'b0)// Last bit already loaded...
      begin
       crc_state <= CRC_FINISH;// CRC Calculation is finished!
      end
      else// Shift can only happen when the data pointer is greater than 0!
      begin
       crc_buffer <= crc_buffer << 1; // Shift out CRC Buffer MSB and replace it with next data bit
                                     // LSB is now 0
       crc_state <= LOAD_NEXT;
      end
     end                     
                                                                                                          
     LOAD_NEXT:
     begin
       if(data_ptr != 7'd0)// If last bit has already been loaded
       begin
	crc_buffer[0] <= sd_cmd[data_ptr];// Only load when data_ptr is greater than 0
        data_ptr <= data_ptr - 7'd1;// Decrement data pointer
        if(crc_buffer[7] == 1'b1)// MSB is 1, or last data bit has been loaded [data_ptr == 1]
        begin
         crc_state <= XOR_CRC;// XOR with Generator Polynomial
        end
        else
        begin
         crc_state <= SHIFT;// If leading zero and last bit not loaded
        end
       end
       else
       begin
        crc_state <= XOR_CRC;// Last data bit has been loaded
       end                                                                                      
     end   
                                                                                                                     
     CRC_FINISH:
     begin
      sd_cmd[7:1] <= crc_buffer[6:0];// Shift in calculated crc7 regardless of what command we transmit 
      data_ptr <= 7'd47;// Reset the command data pointer once CRC calculation is finished    
      sd_mem_state <= SEND_CMD;// And escape CRC FSM to send the CMD                          
      crc_state <= FULL_LOAD;// When CRC calculation is fininshed, return to FULL_LOAD state
      cmd_read <= 1'b0;// Regardless of transmission/response lower cmd read line for send cmd
     end
    endcase   

   end

   SEND_CMD: // Send CMD
   begin
 
    sd_clk <= ~sd_clk; // Toggle sd clock

    if(sd_clk == 1'b1) //Set command bit on falling edge + decrement
    begin              
     cmd <= sd_cmd[sd_cmd_ptr]; // Set cmd line to sd_mem_cmd
     if(sd_cmd_ptr == 6'd0) // If sending LSB
     begin// Last CMD bit is set
      sd_cmd_ptr <= 6'd47; // Reset back to MSB 
      sd_mem_state <= SEND_LAST_CMD_BIT; // Transition to SEND_LAST_CMD_BIT
     end
     else
     begin
      sd_cmd_ptr <= sd_cmd_ptr - 6'd1; // Point to next bit
      sd_mem_state <= SEND_CMD; // Return to Send CMD0
     end
    end
  
   end

    
   SEND_LAST_CMD_BIT: // SEND_LAST_CMD_BIT
   begin// sd clock is low, need rising edge
    sd_clk <= ~sd_clk; // Give rising edge of sd clock
    cmd_read <= 1'b1; // Send cmd line to high impedence to wait response
    if(sd_cmd[45:40] == 6'b110011)
    begin
     //dat_read <= 1'b1;// Try reading data lines here...
    end
    cmd <= CMD; // Save the last cmd line value
    sd_mem_state <= WAIT_RESPONSE; // Transition to wait response 
   end                                                                     



   //////////////////////   SD Memory CMD related states END  //////////////////





   //////////////////////   SD Memory RESPONSE related states ////////////////



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
       sd_mem_state <= SET_CMD; // When CMD0 times out, go back to SET_CMD state...
       sd_cmd_ptr <= 6'd47; // Ensure sd memory command bit pointer is MSB
      end                       
      else
      begin
       resp_delay <= resp_delay - 6'b1; // Decrement response delay
       sd_mem_state <= WAIT_RESPONSE; // Only transition back to wait response when not timed out
      end
     end
    end
    else // A Response has been found. When a Response has been found, we should calculate its CRC
    begin
     if(sd_cmd[45:40] == 6'b000010)// If CMD2 ALL_SEND_CID, use R2 response register and pointer instead!
     begin
      sd_cmd_resp_r2[sd_cmd_resp_ptr_r2] <= CMD;
      sd_cmd_resp_ptr_r2 <= sd_cmd_resp_ptr_r2 - 8'd1;
     end
     else
     begin
      sd_cmd_resp[sd_cmd_resp_ptr] <= CMD;// CMD must have been 0 for start bit
      sd_cmd_resp_ptr <= sd_cmd_resp_ptr - 7'd1;// MSB - 1                     
     end
     sd_mem_state <= READ_RESPONSE;// Read the response once found
     resp_delay <= 6'b110101; // Reset response delay for next command
    end

   end

   READ_RESPONSE:
   begin// Arrival here implies sd_clk is low, when low it hasn't changed...
    sd_clk <= ~sd_clk;// Toggle sd_clk
    if(sd_clk == 1'b1)// Every falling edge of clock
    begin
     if(sd_cmd[45:40] == 6'b000010)
     begin
      sd_cmd_resp_r2[sd_cmd_resp_ptr_r2] <= CMD;// Read the next CMD response bit
      if(sd_cmd_resp_ptr_r2 == 8'd0)// We captured the last response bit, but haven't risen the sd_clk
      begin
       sd_mem_state <= FINISH_RESPONSE;// Finish response by giving rising edge of sd_clk
       sd_cmd_resp_ptr_r2 <= 8'd135;// Reset the sd command response bit pointer after response is finished!
      end
      else
      begin
       sd_cmd_resp_ptr_r2 <= sd_cmd_resp_ptr_r2 - 8'd1;// Point to the next command response bit only if not last one!
       sd_mem_state <= READ_RESPONSE;// Transition back to read next response bit
      end                                                                                                       
     end
     else
     begin    
      sd_cmd_resp[sd_cmd_resp_ptr] <= CMD;// Read the next CMD response bit
      if(sd_cmd_resp_ptr == 7'd0)// We captured the last response bit, but haven't risen the sd_clk
      begin
       sd_mem_state <= FINISH_RESPONSE;// Finish response by giving rising edge of sd_clk
       sd_cmd_resp_ptr <= 7'd47;// Reset the sd command response bit pointer after response is finished!
      end
      else
      begin
       sd_cmd_resp_ptr <= sd_cmd_resp_ptr - 7'd1;// Point to the next command response bit only if not last one!
       sd_mem_state <= READ_RESPONSE;// Transition back to read next response bit
      end                                                                                                       
     end
    end
   end

   FINISH_RESPONSE:
   begin
    sd_clk <= ~sd_clk;// Toggle sd_clk once to finish receiving response
    sd_mem_state <= CALC_CRC_RESP;// CALC CRC for the response of sent command...
    sd_cmd_resp_ptr_r2 <= 8'd135;                                                             
    sd_cmd_resp_ptr <= 7'd47;// Reset response pointer
    sd_mem_state <= SET_CMD;// Once CRC has been calculated for the response set next command
    cb_rd_en <= 1'b1;// Make sure to enable cmd bram block before SET_CMD state
    cmd <= 1'b1; // Make sure CMD is high before sending start bit for next CMD
    if(sd_cmd[45:40] == 6'b110011)
    begin
     cmd_read <= 1'b1; // Keep cmd line high impedance longer so it can capture the SCR for ACMD51
     dat_read <= 1'b1; // Try reading SCR over data lines...?
    end
    else
    begin
     cmd_read <= 1'b0;// Lower the command read signal for the next command to send             
    end
   end


   END: // Dead State for testing
   begin
    sd_clk <= ~sd_clk;
    sd_mem_state <= END;
   end

  endcase
 end

 assign LED = led;
 assign SD_CLK = sd_clk;
 assign CMD = cmd_read ? 1'bz : cmd;
 assign DAT[3] = dat_read ? 1'bz : dat[3];
 assign DAT[2] = dat_read ? 1'bz : dat[2];
 assign DAT[1] = dat_read ? 1'bz : dat[1];
 assign DAT[0] = dat_read ? 1'bz : dat[0];
endmodule
