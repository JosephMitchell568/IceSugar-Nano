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
  48'b0_1_000000_00000000000000000000000000000000_1001010_1;
 // CMD0 [GO_IDLE_STATE]:
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
  48'b0_1_001000_00000000000000000000000110101010_1000011_1;
 // CMD8 [SEND_IF_COND]:
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

 reg [31:0] resp_delay; // Response Delay 
 reg [47:0] cmd_resp; // Actual Response to CMD

 reg cmd_read; // Raise for cmd line read
 reg dat_read; // Raise for data line read

 reg [47:0] sd_mem_cmd;// current sd memory command
 reg sd_mem_cmd_last; // sd memory command last bit flag
 reg [5:0] sd_mem_cmd_ptr;// sd memory command bit pointer

 reg [3:0] sd_mem_state;// Current state of sd memory FSM

 initial
 begin
  led = 1'b0; // led low since no error yet
  sd_clk = 1'b0; // Start sd clock low
  cmd = 1'b0; // Initialize command line to 0
  dat[3:0] = 4'b1111; // Initialize to all data lines to 1

  sd_mem_cmd[47:0] = CMD0; // Set initial sd memory command CMD0
  
  sd_mem_cmd_ptr[5:0] = 6'd47; // SD Memory cmd bit pointer
  
  sd_mem_state = 4'b0000; // Init state
  resp_delay = 32'h00001000; // Large number of clock cycles
  cmd_resp = 48'b0; // Cmd response init 0

  cmd_read = 1'b0;
  dat_read = 1'b0;
 end

 always @(posedge CLK)
 begin
 
  case(sd_mem_state) // Send CMD or Wait RESPONSE
   4'b0000: // Send CMD
   begin
 
    sd_clk <= ~sd_clk; // Toggle sd clock

    if(sd_clk == 1'b1) //Set command bit on falling edge + decrement
    begin              
     cmd <= sd_mem_cmd[sd_mem_cmd_ptr]; // Set cmd line to sd_mem_cmd
     if(sd_mem_cmd_ptr == 6'b0) // If sending LSB
     begin// Last CMD bit is set
      sd_mem_cmd_ptr <= 6'd47; // Reset back to MSB 
      sd_mem_state <= 4'b0010; // Transition to SEND_LAST_CMD_BIT
     end
     else
     begin
      sd_mem_cmd_ptr <= sd_mem_cmd_ptr - 6'b1; // Point to next bit
      sd_mem_state <= 4'b0000; // Return to Send CMD0
     end
    end
  
   end

   4'b0001: // Wait RESPONSE
   begin // Remember to add default response delay for CMD0

    //dat_read <= (CMD != 1'b1); // Find logical value of conditional

    if(CMD != 1'b1) // If response has not officially started
    begin           //  we know it has started on reception of 1
     led <= 1'b0; // lower error LED
     sd_clk <= ~sd_clk; // Toggle sd clock
     sd_mem_state <= 4'b0001; // return to Wait RESPONSE state

     if(resp_delay == 32'b0) // If response delay finished
     begin
      resp_delay <= 32'h00001000; // Reset response delay
      sd_mem_state <= 4'b0000; // Send next command
      sd_mem_cmd <= CMD8; // Set next command as CMD8
     end
     else
     begin      
      resp_delay <= resp_delay - 32'b1; // Decrement response delay
     end
    end
    else if(CMD != 1'b0)
    begin
     if(sd_mem_cmd == CMD0) // If sent command is GO_IDLE_STATE
     begin
      led <= 1'b1; // Error CMD0 got a RESPONSE
     end
     sd_clk <= 1'b1; // Ensure sd clock is high
     sd_mem_state <= 4'b0000; // return to Send CMD
     resp_delay <= 32'h00001000; // Reset response delay
    end
    else // RESPONSE to SD Memory command exists
    begin
     led <= 1'b0;
     sd_clk <= ~sd_clk; // Toggle sd_clk while no response from card
     sd_mem_state <= 4'b0001; // stay in wait response state while cmd line is unknown
     if(resp_delay == 32'b0)
     begin
      resp_delay <= 32'h00001000; // Reset response delay
      sd_mem_state <= 4'b0000; // Send next command
      //sd_mem_cmd <= CMD0; // Set next command as CMD0
     end
     else
     begin
      resp_delay <= resp_delay - 32'b1; // Decrement response delay even though it is unknown
     end
    end

    cmd_resp <= cmd_resp << 1; // Shift bits left 1
    cmd_resp[0] <= cmd; // Set cmd response LSB to response bit

   end

   4'b0010: // SEND_LAST_CMD_BIT
   begin// sd clock is low, need rising edge
    sd_clk <= ~sd_clk; // Give rising edge of sd clock
    cmd_read <= 1'b1; // Send cmd line to high impedence to wait response
    sd_mem_state <= 4'b0001; // Transition to wait response 
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
