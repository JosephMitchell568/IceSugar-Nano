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

 reg rst, scl, dc, mosi, cs;
 reg [5:0] state;
 reg [15:0] delay; // 120 for 10us, 60000 for 5ms
 reg [7:0] displayOn;

 always@(posedge CLK)
 begin
  case(state)
   default: state <= 6'd0;
   6'd0: begin //Initialize Signals (Init)
    rst <= 1'b1;
    scl <= 1'b1;
    dc <= 1'b1;
    mosi <= 1'b1;
    cs <= 1'b1;
    state <= state + 6'd1;
    delay <= 16'd0;
    displayOn <= 8'h29;
   end
   6'd1: begin // Activate Reset (RST)
    rst <= 1'b0; //Activate reset
    scl <= ~scl; //toggle serial clock
    state <= state + 6'd1;
   end
   6'd2: begin // Delay & Deassert RST (DRST)
    if(delay <= 16'd120)
    begin
     delay <= delay + 16'd1; 
    end
    else
    begin
     rst <= 1'b1; //Deactivate reset
     delay <= 16'd0;
     state <= state + 6'd1;
    end
    scl <= ~scl;
   end
   6'd3: begin // Delay Deassert RST (DDRST)
    if(delay <= 16'd60000)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     delay <= 16'd0;
     state <= state + 6'd1;
    end
    scl <= ~scl;
   end
   6'd4: begin // Next command based on demo waveform
    // Next state will act as next lcd command
   end
  endcase
 end

 assign RST = rst;
 assign SCL = scl;
 assign DC = dc;
 assign MOSI = mosi;
 assign CS = cs;
endmodule
