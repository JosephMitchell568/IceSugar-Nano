module reset(
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

 reg [7:0] frmctr1_c [0:1];
 reg [7:0] frmctr1_num_params [0:1]; // Number of parameters for each command including NOP

 reg [7:0] frmctr1_p [0:2];
 
 reg [2:0] bit_counter;
 reg cmd_counter;
 reg [1:0] param_counter;
 reg [7:0] params_left;

 initial
 begin
  state = 6'd0;
  scl = 1'b1;

  frmctr1_c[0] = 8'hB1;
  frmctr1_c[1] = 8'h00; // NOP ; when reached deadstate...
  frmctr1_num_params[0] = 8'h03; // cmd 1 has 3 parameters
  frmctr1_num_params[1] = 8'h00; // cmd 2 has 0 parameters

  frmctr1_p[0] = 8'h05;
  frmctr1_p[1] = 8'h3C;
  frmctr1_p[2] = 8'h3C;

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
    if(frmctr1_c[cmd_counter] == 8'h00)
    begin
     state <= lc; // Deadstate when no more cmds left
    end
    else
    begin
     data <= frmctr1_c[cmd_counter];
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
    params_left <= frmctr1_num_params[cmd_counter - 1'b1];
    state <= lp; // After setting dc line load first parameter
   end
   lp: begin // Load next parameter for cmd
    data <= frmctr1_p[param_counter];
    params_left <= params_left - 8'd1; // decrement params left
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
