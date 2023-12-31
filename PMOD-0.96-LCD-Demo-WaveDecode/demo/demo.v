module demo(
  input CLK,
  output RST,
  output SCL,
  output DC,
  output MOSI,
  output CS
 );


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
 reg [15:0] delay;

 reg [7:0] data;
 reg [2:0] bit_counter; 
 
 reg [15:0] pixel_data;
 reg [3:0] pixel_bit_counter;

 reg [7:0] cmd [0:23];
 reg [13:0] num_params [0:23];
 reg [4:0] cmd_counter;

 reg [7:0] params [0:75];
 reg [6:0] param_counter;

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
  cmd_counter = 5'b0;

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
  param_counter = 7'b00;
  params_left = 14'd0;


  data = 8'h00;
  bit_counter = 3'b111;

  pixel_data = 16'h00_00;
  pixel_bit_counter = 4'b1111;
 end

 always@(posedge CLK)
 begin

  scl <= ~scl; //Toggle scl each rising edge

 end

 always@(posedge CLK)
 begin // FSM Start [begin 1]

  case(state)

   init: 
   begin // Init Start [begin 2]

    rst <= 1'b1;
    dc <= 1'b1;
    mosi <= 1'b1;
    cs <= 1'b1;
    state <= actRst;
    delay <= 16'd0;

   end // Init End [end 40]

   actRst: 
   begin // actRst Start [begin 3]

    rst <= 1'b0;
    state <= drst;

   end // actRst End [end 39]

   drst: 
   begin // drst Start [begin 4]

    if(delay <= 16'd120)
    begin // [begin 5]
     delay <= delay + 16'd1; 
    end// [end 38]
    else
    begin // [begin 6]
     rst <= 1'b1;
     delay <= 16'd0;
     state <= ddrst;
    end// [end 37]

   end // drst End [end 36]

   ddrst: 
   begin // ddrst Start [begin 7]

    if(delay <= 16'd60000)
    begin // [begin 8]
     delay <= delay + 16'd1;
    end// [end 35]
    else
    begin // [begin 9]
     delay <= 16'd0;
     state <= lc;
    end // [end 34]

   end // ddrst End [end 33]

   lc: 
   begin // lc Start [begin 10]

    if(cmd[cmd_counter] == 8'h00)
    begin // [begin 11]
     state <= lc;
    end// [end 32]
    else
    begin // [begin 12]
     data <= cmd[cmd_counter];
     cmd_counter <= cmd_counter + 5'b1;
     state <= ldc;
    end// [end 31]
 
   end // lc End [end 30]

   ldc: 
   begin // ldc Start [begin 13]

    dc <= 1'b0;
    state <= sm;

   end // ldc End [end 29]

   sm: 
   begin // sm Start [begin 14]

    if(dc == 1'b1 && cmd[cmd_counter-5'd1] == 8'h2C)
    begin // [begin 15]
     if(pixel_bit_counter == 4'b1111)
     begin// [begin 16]
      state <= lcs;
     end// [end 28]
     else if(pixel_bit_counter == 4'b0000)
     begin// [begin 17]
      state <= slb;
      pixel_bit_counter <= 4'b1111;
     end// [end 27]
     else
     begin// [begin 18]
      state <= send;
     end// [end 26]

     mosi <= pixel_data[pixel_bit_counter];
     pixel_bit_counter <= pixel_bit_counter - 4'b0001;
    end// [end 25]
    else
    begin// [begin 19]
     if(bit_counter == 3'b111)
     begin
      state <= lcs; //Lower CS
     end// [end 24]
     else if(bit_counter == 3'b000)
     begin// [begin 20]
      state <= slb; //Send last bit
      bit_counter <= 3'b111; //Reset bit counter
     end// [end 23]
     else
     begin// [begin 21]
      state <= send;
     end// [end 22]

     mosi <= data[bit_counter];
     bit_counter <= bit_counter - 3'b001;
    end// [end 21]
 
   end // sm End [end 20]

   lcs: 
   begin // lcs Start [begin 22]

    if(scl == 1'b1)
    begin// [begin 23]
     cs <= 1'b0;
     state <= send;
    end// [end 19]
    else
    begin// [begin 24]
     state <= lcs;
    end// [end 18]

   end // lcs End [end 17]

   send: 
   begin // send Start [begin 25]

    if(scl == 1'b1)
    begin// [begin 26]
     state <= sm;
    end// [end 16]
    else
    begin// [begin 27]
     state <= send;
    end// [end 15]

   end // send End [end 14]

   slb: 
   begin // slb Start [begin 28]

    if(scl == 1'b1)
    begin// [begin 29]
     state <= rcs;
    end// [end 13]
    else
    begin// [begin 30]
     state <= slb;
    end// [end 12]

   end // slb End [end 11]

   rcs: 
   begin // rcs Start [begin 31]
   
    cs <= 1'b1;
    if(dc == 1'b0)
    begin// [begin 32]
     state <= rdc;
    end// [end 10]
    else
    begin// [begin 33]
     state <= lp;
    end// [end 10]
   
   end // rcs End [end 9]

   rdc: 
   begin // rdc Start [begin 34]

    dc <= 1'b1;
    params_left <= num_params[cmd_counter - 5'b1];
    state <= lp;

   end // rdc End [end 8]

   lp: begin // lp Start [begin 35]

    if(cmd[cmd_counter-5'd1] == 8'h2C)
    begin// [begin 36]
     pixel_data[15:8] <= params[param_counter];
     pixel_data[7:0] <= params[param_counter];
    end// [end 7]
    else
    begin// [begin 37]
     data <= params[param_counter];
    end// [end 6]

    if(params_left == 14'd0)
    begin// [begin 38]
     state <= lc;
    end // [end 5]
    else
    begin// [begin 39]
     if(param_counter != 7'd75)
     begin// [begin 40]
      param_counter <= param_counter + 7'd01;
     end// [end 4]                           
     params_left <= params_left - 14'd1;           
     state <= sm;
    end // [end 3]

   end // lp End [end 2]
   
  endcase
 end // [end 1]

 assign RST = rst;
 assign SCL = scl;
 assign DC = dc;
 assign MOSI = mosi;
 assign CS = cs;

endmodule
