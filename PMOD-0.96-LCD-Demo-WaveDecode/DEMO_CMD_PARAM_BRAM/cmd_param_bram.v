module cmd_param_bram
 (
  input CLK,
  output RST,
  output SCL,
  output DC,
  output MOSI,
  output CS 
 );
     
 // This design will recreate the demo (white frame)

 // I need to determine all delays...
 //  then I can add them where needed

 // ----- Reset FSM States ------------------
 localparam ASSERT_RST = 8'd0;
 localparam ASSERT_RST_DELAY = 8'd1;
 localparam DEASSERT_RST = 8'd2;
 localparam DEASSERT_RST_DELAY = 8'd3;
 // ----- End Reset FSM States --------------

 // ----- Send Command FSM States -----------
 localparam LOAD_CMD = 8'd4;
 localparam LOWER_DC = 8'd5;
 // ----- End Send Command FSM States -------

 // ----- SPI Byte Transmition States -------
 localparam SET_NEXT_MOSI = 8'd6;
 localparam LOWER_CS = 8'd7;
 localparam WRITE_BIT_SPI = 8'd8;
 localparam SEND_LAST_BIT = 8'd9;
 // ----- End SPI Byte Transmition States ---

 // ----- Send Parameter FSM States ---------
 localparam LOAD_PARAM = 8'd10;
 localparam RAISE_DC = 8'd11;
 // ----- End Send Parameter States ---------

 reg rst, scl, dc, mosi, cs;
 reg [7:0] cmd_bram [0:22]; // 23 lcd commands
 reg [7:0] param_bram [0:75]; // 76 lcd params
 reg [7:0] num_cmd_params_bram [0:21]; // # params
 // The last number of params is 80 * 160 = 12800 14b
 reg [4:0] cmd_counter; //cmd counter
 reg [6:0] param_counter;//param counter
 reg [13:0] num_params_left;// number of params left
 reg [13:0] frame_size; //frame size for mem write
 reg [7:0] data; // Can be cmd or param
 reg [2:0] bit_counter; // Points to current bit
 reg [7:0] state; // FSM state  
 reg [15:0] delay; // Currently only for reset

 assign RST = rst;
 assign SCL = scl;
 assign DC = dc;
 assign MOSI = mosi;
 assign CS = cs;

 initial 
 begin
  cmd_bram[0]  = 8'hB1; 
  cmd_bram[1]  = 8'hB2;
  cmd_bram[2]  = 8'hB3;
  cmd_bram[3]  = 8'hB4;
  cmd_bram[4]  = 8'hC0;
  cmd_bram[5]  = 8'hC1;
  cmd_bram[6]  = 8'hC2;
  cmd_bram[7]  = 8'hC3;
  cmd_bram[8]  = 8'hC4;
  cmd_bram[9]  = 8'hC5;
  cmd_bram[10] = 8'hE0;
  cmd_bram[11] = 8'hE1;
  cmd_bram[12] = 8'hFC;
  cmd_bram[13] = 8'h3A;
  cmd_bram[14] = 8'h36;
  cmd_bram[15] = 8'h21;
  cmd_bram[16] = 8'h29;
  cmd_bram[17] = 8'h2A;
  cmd_bram[18] = 8'h2B;
  cmd_bram[19] = 8'h2C;
  cmd_bram[20] = 8'h2A;
  cmd_bram[21] = 8'h2B;
  cmd_bram[22] = 8'h2C;

  num_cmd_params_bram[0]  = 8'h03;
  num_cmd_params_bram[1]  = 8'h03;
  num_cmd_params_bram[2]  = 8'h06;
  num_cmd_params_bram[3]  = 8'h01;
  num_cmd_params_bram[4]  = 8'h03;
  num_cmd_params_bram[5]  = 8'h01;
  num_cmd_params_bram[6]  = 8'h02;
  num_cmd_params_bram[7]  = 8'h02;
  num_cmd_params_bram[8]  = 8'h02;
  num_cmd_params_bram[9]  = 8'h01;
  num_cmd_params_bram[10] = 8'h10;
  num_cmd_params_bram[11] = 8'h10;
  num_cmd_params_bram[12] = 8'h01;
  num_cmd_params_bram[13] = 8'h01;
  num_cmd_params_bram[14] = 8'h01;
  num_cmd_params_bram[15] = 8'h00;
  num_cmd_params_bram[16] = 8'h00;
  num_cmd_params_bram[17] = 8'h04;
  num_cmd_params_bram[18] = 8'h04;
  num_cmd_params_bram[19] = 8'h00;
  num_cmd_params_bram[20] = 8'h04;
  num_cmd_params_bram[21] = 8'h04;
  frame_size = 14'd12800;  

  param_bram[0]  = 8'h05;
  param_bram[1]  = 8'h3C;
  param_bram[2]  = 8'h3C;
  param_bram[3]  = 8'h05;
  param_bram[4]  = 8'h3C;
  param_bram[5]  = 8'h3C;
  param_bram[6]  = 8'h05;
  param_bram[7]  = 8'h3C;
  param_bram[8]  = 8'h3C;
  param_bram[9]  = 8'h05;
  param_bram[10] = 8'h3C;
  param_bram[11] = 8'h3C;
  param_bram[12] = 8'h03;
  param_bram[13] = 8'hAB;
  param_bram[14] = 8'h0B;
  param_bram[15] = 8'h04;
  param_bram[16] = 8'hC5;
  param_bram[17] = 8'h0D;
  param_bram[18] = 8'h00;
  param_bram[19] = 8'h8D;
  param_bram[20] = 8'h6A;
  param_bram[21] = 8'h8D;
  param_bram[22] = 8'hEE;
  param_bram[23] = 8'h0F;
  param_bram[24] = 8'h07;
  param_bram[25] = 8'h0E;
  param_bram[26] = 8'h08;
  param_bram[27] = 8'h07;
  param_bram[28] = 8'h10;
  param_bram[29] = 8'h07;
  param_bram[30] = 8'h02;
  param_bram[31] = 8'h07;
  param_bram[32] = 8'h09;
  param_bram[33] = 8'h0F;
  param_bram[34] = 8'h25;
  param_bram[35] = 8'h36;
  param_bram[36] = 8'h00;
  param_bram[37] = 8'h08;
  param_bram[38] = 8'h04;
  param_bram[39] = 8'h10;
  param_bram[40] = 8'h0A;
  param_bram[41] = 8'h0D;
  param_bram[42] = 8'h08;
  param_bram[43] = 8'h07;
  param_bram[44] = 8'h0F;
  param_bram[45] = 8'h07;
  param_bram[46] = 8'h02;
  param_bram[47] = 8'h07;
  param_bram[48] = 8'h09;
  param_bram[49] = 8'h0F;
  param_bram[50] = 8'h25;
  param_bram[51] = 8'h35;
  param_bram[52] = 8'h00;
  param_bram[53] = 8'h09;
  param_bram[54] = 8'h04;
  param_bram[55] = 8'h10;
  param_bram[56] = 8'h80;
  param_bram[57] = 8'h05;
  param_bram[58] = 8'h78;
  param_bram[59] = 8'h00;
  param_bram[60] = 8'h1A;
  param_bram[61] = 8'h00;
  param_bram[62] = 8'h69;
  param_bram[63] = 8'h00;
  param_bram[64] = 8'h01;
  param_bram[65] = 8'h00;
  param_bram[66] = 8'hA0;
  param_bram[67] = 8'h00;
  param_bram[68] = 8'h01;
  param_bram[69] = 8'h00;
  param_bram[70] = 8'hA0;
  param_bram[71] = 8'h00;
  param_bram[72] = 8'h1A;
  param_bram[73] = 8'h00;
  param_bram[74] = 8'h69;
  param_bram[75] = 8'hFF; //Choose your own RGB565

  cmd_counter = 5'd0; //cmd counter
  param_counter = 7'd0;//param counter
  num_params_left = 14'd0;

  rst = 1'b1;
  scl = 1'b1;
  dc = 1'b1;
  mosi = 1'b1;
  cs = 1'b1;

  state = 8'd0;

  delay = 16'd0;

  bit_counter = 3'b111; // MSB
 end

 always @(posedge CLK)
  scl <= ~scl;

 always @(posedge CLK)
 begin
  //(1) Reset LCD
  //(2) Begin FSM command executions
  //(3) Provide Delays when needed
  //(*) FSM Should replicate the nanoDLA waveform
  case(state)
   ASSERT_RST: begin // Assert Reset
    rst <= 1'b0;
    state <= ASSERT_RST_DELAY;
   end
   ASSERT_RST_DELAY: begin // Assert Reset Delay
    if(delay < 16'd120)
    begin
     delay <= delay + 16'd1; // Increment delay
     state <= ASSERT_RST_DELAY; // Return to Assert RST Delay
    end
    else
    begin
     delay <= 16'd0; // Reset Delay
     state <= DEASSERT_RST; // Next state
    end
   end
   DEASSERT_RST: begin // Deassert RST
    rst <= 1'b1;
    state <= DEASSERT_RST_DELAY;
   end
   DEASSERT_RST_DELAY: begin // Deassert RST Delay
    if(delay < 16'd60000)
    begin
     delay <= delay + 16'd1; // Increment Delay
     state <= DEASSERT_RST_DELAY; // Remain in Deassert RST Delay
    end
    else
    begin
     delay <= 16'd0;
     state <= LOAD_CMD;
    end
   end
   LOAD_CMD: begin // Load next command
    if(cmd_counter < 6'd23)
    begin
     data <= cmd_bram[cmd_counter];
     cmd_counter = cmd_counter + 6'd1;
     state <= LOWER_DC;
    end
    else
    begin
     state <= LOAD_CMD; // Deadstate : execution ends
    end
   end
   LOWER_DC: begin // Lower DC signal for command
    dc <= 1'b0;
    state <= SET_NEXT_MOSI; // Set mosi bit
   end
   RAISE_DC: begin
    dc <= 1'b1;
    state <= SET_NEXT_MOSI;
   end
   SET_NEXT_MOSI: begin
    mosi <= data[bit_counter]; //set next mosi bit
    if(bit_counter == 3'b000)
    begin
     bit_counter <= 3'b111; // Reset to MSB
     state <= SEND_LAST_BIT;
    end
    else if(bit_counter == 3'b111)
    begin
     bit_counter <= bit_counter - 3'b1;
     state <= LOWER_CS;
    end
    else
    begin
     bit_counter <= bit_counter - 3'b1; // Next bit
     state <= WRITE_BIT_SPI;
    end
   end
   LOWER_CS: begin // Lower CS when SCL is high
    if(scl == 1'b1)
    begin
     cs <= 1'b0; // CS falls with SCL
     state <= WRITE_BIT_SPI; // move to write bit
    end
    else
    begin
     state <= LOWER_CS; // Wait until scl is high
    end
   end
   WRITE_BIT_SPI: begin // write bit to spi
    if(scl == 1'b1) // MOSI bit was sent
    begin
     state <= SET_NEXT_MOSI;
    end
    else
    begin
     state <= WRITE_BIT_SPI;
    end
   end
   SEND_LAST_BIT: begin // Send last bit of spi byte
    if(scl == 1'b1)
    begin
     state <= LOAD_PARAM; // Set parameter
     if(cmd_counter == 6'd22)
     begin
      num_params_left <= frame_size;
     end
     else
     begin
      num_params_left <= num_cmd_params_bram[cmd_counter-6'd1];
     end
     cs <= 1'b1; // Reset both cs and dc
    end
    else
    begin
     state <= SEND_LAST_BIT;
    end
   end
   LOAD_PARAM: begin // Set next parameter
    if(num_params_left > 8'd0)
    begin
     data <= param_bram[param_counter];
     num_params_left <= num_params_left - 8'd1;
     if(cmd_counter != 6'd22) //Ensure the same parameter is set for memory write (frame)
     begin
      param_counter <= param_counter + 7'b1;
     end
     dc <= 1'b1;
     state <= RAISE_DC; // Set mosi and dc
    end
    else
    begin //Parameters are finished
     state <= LOAD_CMD;//Transition to next cmd
    end
   end
  endcase
 end

endmodule
