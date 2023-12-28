module demo(
  input CLK,
  output RST,
  output SCL,
  output DC,
  output MOSI,
  output CS
 );

 // --- Summary of Reset FSM states ---
 // (*) Init --- initializes LCD Signals -> RST
 // (2) RST --- assert active low RST -> DRST
 // (3) DRST --- delay and deassert RST -> DDRST
 // (4) DDRST --- delay post deassert RST (RST cmd is finished)

 localparam init = 6'd0;
 localparam actRst = 6'd1;
 localparam drst = 6'd2;
 localparam ddrst = 6'd3;
 localparam lc = 6'd4;
 localparam ldc = 6'd5;
 localparam sm = 6'd6;
 localparam lcs = 6'd7;
 localparam slb = 6'd8;
 localparam rcs = 6'd9;
 localparam send = 6'd10;
 localparam rdc = 6'd11;
 localparam lp = 6'd12;
 

 reg rst, scl, dc, mosi, cs;
 reg [5:0] state;
 reg [15:0] delay; // 120 for 10us, 60000 for 5ms

 reg [7:0] data;

 reg [7:0] cmd [0:23];
 reg [13:0] num_params [0:23]; // Number of parameters for each command including NOP

 reg [7:0] params [0:75]; // Holds parameters for cmds
 
 reg [2:0] bit_counter;
 reg [4:0] cmd_counter; // 5 bit counter
 reg [6:0] param_counter; // 7 bit counter
 reg [13:0] params_left;

 initial
 begin
  state = 6'd0;
  scl = 1'b1;

  cmd[0]  = 8'hB1;
  cmd[1]  = 8'hB2;
  cmd[2]  = 8'hB3;
  cmd[3]  = 8'hB4;
  cmd[4]  = 8'hC0;
  cmd[5]  = 8'hC1;
  cmd[6]  = 8'hC2;
  cmd[7]  = 8'hC3;
  cmd[8]  = 8'hC4;
  cmd[9]  = 8'hC5;
  cmd[10] = 8'hE0;
  cmd[11] = 8'hE1;
  cmd[12] = 8'hFC;
  cmd[13] = 8'h3A;
  cmd[14] = 8'h36;
  cmd[15] = 8'h21;
  cmd[16] = 8'h29;
  cmd[17] = 8'h2A;
  cmd[18] = 8'h2B;
  cmd[19] = 8'h2C;
  cmd[20] = 8'h2A;
  cmd[21] = 8'h2B;
  cmd[22] = 8'h2C;
  cmd[23] = 8'h00; // NOP ; when reached deadstate...
  num_params[0]  = 14'h03;
  num_params[1]  = 14'h03; 
  num_params[2]  = 14'h06;
  num_params[3]  = 14'h01;
  num_params[4]  = 14'h03;
  num_params[5]  = 14'h01;
  num_params[6]  = 14'h02;
  num_params[7]  = 14'h02;
  num_params[8]  = 14'h02;
  num_params[9]  = 14'h01;
  num_params[10] = 14'h10;
  num_params[11] = 14'h10;
  num_params[12] = 14'h01;
  num_params[13] = 14'h01;
  num_params[14] = 14'h01;
  num_params[15] = 14'h00;
  num_params[16] = 14'h00;
  num_params[17] = 14'h04;
  num_params[18] = 14'h04;
  num_params[19] = 14'h00;
  num_params[20] = 14'h04;
  num_params[21] = 14'h04;
  num_params[22] = 14'd12800;
  num_params[23] = 8'h00;

  params[0]  = 8'h05;
  params[1]  = 8'h3C;
  params[2]  = 8'h3C;
  params[3]  = 8'h05;
  params[4]  = 8'h3C;
  params[5]  = 8'h3C;
  params[6]  = 8'h05;
  params[7]  = 8'h3C;
  params[8]  = 8'h3C;
  params[9]  = 8'h05;
  params[10] = 8'h3C;
  params[11] = 8'h3C;
  params[12] = 8'h03;
  params[13] = 8'hAB;
  params[14] = 8'h0B;
  params[15] = 8'h04;
  params[16] = 8'hC5;
  params[17] = 8'h0D;
  params[18] = 8'h00;
  params[19] = 8'h8D;
  params[20] = 8'h6A;
  params[21] = 8'h8D;
  params[22] = 8'hEE;
  params[23] = 8'h0F;
  params[24] = 8'h07;
  params[25] = 8'h0E;
  params[26] = 8'h08;
  params[27] = 8'h07;
  params[28] = 8'h10;
  params[29] = 8'h07;
  params[30] = 8'h02;
  params[31] = 8'h07;
  params[32] = 8'h09;
  params[33] = 8'h0F;
  params[34] = 8'h25;
  params[35] = 8'h36;
  params[36] = 8'h00;
  params[37] = 8'h08;
  params[38] = 8'h04;
  params[39] = 8'h10;
  params[40] = 8'h0A;
  params[41] = 8'h0D;
  params[42] = 8'h08;
  params[43] = 8'h07;
  params[44] = 8'h0F;
  params[45] = 8'h07;
  params[46] = 8'h02;
  params[47] = 8'h07;
  params[48] = 8'h09;
  params[49] = 8'h0F;
  params[50] = 8'h25;
  params[51] = 8'h35;
  params[52] = 8'h00;
  params[53] = 8'h09;
  params[54] = 8'h04;
  params[55] = 8'h10;
  params[56] = 8'h80;
  params[57] = 8'h05;
  params[58] = 8'h78;
  params[59] = 8'h00;
  params[60] = 8'h1A;
  params[61] = 8'h00;
  params[62] = 8'h69;
  params[63] = 8'h00;
  params[64] = 8'h01;
  params[65] = 8'h00;
  params[66] = 8'hA0;
  params[67] = 8'h00;
  params[68] = 8'h01;
  params[69] = 8'h00;
  params[70] = 8'hA0;
  params[71] = 8'h00;
  params[72] = 8'h1A;
  params[73] = 8'h00;
  params[74] = 8'h69;
  params[75] = 8'hFF;

  data = 8'h00; // Internal Reg to hold mosi data

  bit_counter = 3'b111;
  cmd_counter = 1'b0; // Points to command
  param_counter = 2'b00; // Points to parameter
  params_left = 14'd0; // Determines number of remaining parameters for cmd
 end

 always@(posedge CLK)
  scl <= ~scl; //Toggle scl each rising edge

 always@(posedge CLK)
 begin
  case(state)
   init: begin //Initialize Signals (Init)
    rst <= 1'b1;
    dc <= 1'b1;
    mosi <= 1'b1;
    cs <= 1'b1;
    state <= actRst;
    delay <= 16'd0;
   end
   actRst: begin // Activate Reset (RST)
    rst <= 1'b0; //Activate reset
    state <= drst;
   end
   drst: begin // Delay & Deassert RST (DRST)
    if(delay <= 16'd120)
    begin
     delay <= delay + 16'd1; 
    end
    else
    begin
     rst <= 1'b1; //Deactivate reset
     delay <= 16'd0;
     state <= ddrst;
    end
   end
   ddrst: begin // Delay Deassert RST (DDRST)
    if(delay <= 16'd60000)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     delay <= 16'd0;
     state <= lc;
    end
   end
   lc: begin // Load Cmd
    if(cmd[cmd_counter] == 8'h00)
    begin
     state <= lc; // Deadstate when no more cmds left
    end
    else
    begin
     data <= cmd[cmd_counter];
     cmd_counter <= cmd_counter + 1'b1; // Point to next cmd
     state <= ldc; //Move to lower DC
    end
   end
   ldc: begin
    dc <= 1'b0;
    state <= sm; //Set mosi
   end
   sm: begin
    if(bit_counter == 3'b111)
    begin
     state <= lcs; //Lower CS
    end
    else if(bit_counter == 3'b000)
    begin
     state <= slb; //Send last bit
     bit_counter <= 3'b111; //Reset bit counter
    end
    else
    begin
     state <= send; //Send non last bit
    end

    mosi <= data[bit_counter]; //Set on falling edge
    bit_counter <= bit_counter - 3'b001;
   end
   lcs: begin // Lower CS
    if(scl == 1'b1)
    begin
     cs <= 1'b0;
     state <= send; //Send first bit
    end
    else
    begin
     state <= lcs; //Wait until scl is about to fall
    end
   end
   send: begin
    if(scl == 1'b1) //MOSI gets sent on rising scl
    begin
     state <= sm; //Set mosi after sending
    end
    else
    begin
     state <= send;
    end
   end
   slb: begin
    if(scl == 1'b1) // Send Last bit of byte
    begin
     state <= rcs; // Raise CS, after write byte
     //state <= slb; // THIS LINE FOR DEBUG
    end
    else
    begin
     state <= slb; // Send last bit
    end
   end
   rcs: begin
    cs <= 1'b1; // First Raise CS to prepare next data
    if(dc == 1'b0) // If cmd, raise dc for param
    begin
     state <= rdc; // Need to raise dc line, sets data, lowers cs
    end
    else // If last byte was a parameter,
    begin // check if it is the last parameter
     if(params_left == 14'd0)
     begin
      state <= lc; // Load cmd eventually lowers dc line
     end
     else
     begin
      state <= lp; // load parameter if more parameters exist
     end
    end
   end
   rdc: begin // Should also set params_left...
    dc <= 1'b1;
    params_left <= num_params[cmd_counter - 1'b1];
    state <= lp; // After setting dc line load first parameter
   end
   lp: begin // Load next parameter for cmd
    data <= params[param_counter];
    params_left <= params_left - 14'd1; // decrement params left
    param_counter <= param_counter + 2'b01;
    state <= sm; // Send the first mosi bit 
   end
  endcase
 end

 assign RST = rst;
 assign SCL = scl;
 assign DC = dc;
 assign MOSI = mosi;
 assign CS = cs;
endmodule
