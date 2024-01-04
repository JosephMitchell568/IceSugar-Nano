module rainbow(
  input CLK,
  output RST,
  output SCL,
  output DC,
  output MOSI,
  output CS
 );

 // LCD Command names from Pulse View
 localparam SLPOUT  = 8'h11;
 localparam FRMCTR1 = 8'hB1;
 localparam FRMCTR2 = 8'hB2;
 localparam FRMCTR3 = 8'hB3;
 localparam INVCTR  = 8'hB4;
 localparam PWCTR1  = 8'hC0;
 localparam PWCTR2  = 8'hC1;
 localparam PWCTR3  = 8'hC2;
 localparam PWCTR4  = 8'hC3;
 localparam PWCTR5  = 8'hC4;
 localparam VMCTR1  = 8'hC5;
 localparam GMCTRP1 = 8'hE0;
 localparam GMCTRN1 = 8'hE1;
 localparam PWCTR6  = 8'hFC;
 localparam COLMOD  = 8'h3A;
 localparam MADCTL  = 8'h36;
 localparam INVON   = 8'h21;
 localparam DISPON  = 8'h29;
 localparam CASET   = 8'h2A;
 localparam RASET   = 8'h2B;
 localparam RAMWR   = 8'h2C;

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
 localparam dsleep = 6'd13;
 localparam dpcmd = 6'd14;
 localparam dmw_c = 6'd15;
 localparam dmw_p = 6'd16;
 localparam dcrg_p = 6'd17;
 localparam dfrmctr3_c = 6'd18;
 localparam dfrmctr3_p = 6'd19;
 localparam dgmctr_c = 6'd20;
 localparam dgmctr_p = 6'd21;
 localparam dcr_c = 6'd22;
 localparam dcr_p = 6'd23;

 localparam actRst_d = 16'd23817;
 localparam dactRst_d = 16'd20858;
 localparam sleep = 16'd20848;
 localparam pcmd = 12'd36; // 3us post cmd delay
 localparam mw_c = 12'd480; // 40us post memory write
 localparam mw_p = 12'd72; // memory write param
 localparam crg = 12'd36; //CASET/RASET/Gamma+/- del.
 localparam frmctr3 = 12'd36;
 localparam gmctr = 12'd36; // 3us for gamma ctr
 localparam cr = 12'd36; // 3us for caset raset

 reg rst, scl, dc, mosi, cs;
 reg [5:0] state;
 reg [15:0] delay;

 reg [7:0] data;
 reg [2:0] bit_counter; 
 
 reg [15:0] pixel_data;
 reg [15:0] rainbow;
 reg [3:0] pixel_bit_counter;

 reg [7:0] cmd [0:21];
 reg [4:0] cmd_counter;

 reg [7:0] params [0:67];
 reg [6:0] param_counter;

 reg [13:0] params_left;

 initial
 begin
  state = 6'd0;
  scl = 1'b1;

  rainbow = 16'hFF_FF;

  cmd[0]  = SLPOUT;
  cmd[1]  = FRMCTR1;
  cmd[2]  = FRMCTR2;
  cmd[3]  = FRMCTR3;
  cmd[4]  = INVCTR;
  cmd[5]  = PWCTR1;
  cmd[6]  = PWCTR2;
  cmd[7]  = PWCTR3;
  cmd[8]  = PWCTR4;
  cmd[9]  = PWCTR5;
  cmd[10] = VMCTR1;
  cmd[11] = GMCTRP1;
  cmd[12] = GMCTRN1;
  cmd[13] = PWCTR6;
  cmd[14] = COLMOD;
  cmd[15] = MADCTL;
  cmd[16] = INVON;
  cmd[17] = DISPON;
  cmd[18] = CASET;
  cmd[19] = RASET;
  cmd[20] = RAMWR; 
  cmd[21] = 8'h00; //NOP
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
  params[60] = 8'h01;
  params[61] = 8'h00;
  params[62] = 8'hA0;
  params[63] = 8'h00;
  params[64] = 8'h1A;
  params[65] = 8'h00;
  params[66] = 8'h69;
  params[67] = 8'hF0;// Color

  param_counter = 7'b00;
  params_left = 14'd0;

  data = 8'h00;
  bit_counter = 3'b111;

  pixel_data = 16'h00_00;
  pixel_bit_counter = 4'b1111;
 end

 always@(posedge CLK)
 begin

  scl <= ~scl;

 end

 always@(posedge CLK)
 begin

  case(state)

   init: 
   begin

    rst <= 1'b1;
    dc <= 1'b0;//initialize to low
    mosi <= 1'b0;//initialize to low
    cs <= 1'b1;
    state <= actRst;
    delay <= 16'd0;

   end

   actRst: 
   begin

    rst <= 1'b0;
    state <= drst;

   end

   drst: 
   begin

    if(delay <= actRst_d)
    begin
     delay <= delay + 16'd1; 
    end
    else
    begin
     rst <= 1'b1;
     delay <= 16'd0;
     state <= ddrst;
    end

   end

   ddrst: 
   begin

    if(delay <= dactRst_d)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     delay <= 16'd0;
     state <= lc;
    end

   end

   lc: 
   begin

    if(cmd[cmd_counter] == 8'h00)
    begin
     state <= lc;
    end
    else
    begin
     case(cmd[cmd_counter])
      SLPOUT  : params_left <= 14'h00;
      FRMCTR1 : params_left <= 14'h03;
      FRMCTR2 : params_left <= 14'h03;
      FRMCTR3 : params_left <= 14'h06;
      INVCTR  : params_left <= 14'h01;
      PWCTR1  : params_left <= 14'h03;
      PWCTR2  : params_left <= 14'h01;
      PWCTR3  : params_left <= 14'h02;
      PWCTR4  : params_left <= 14'h02;
      PWCTR5  : params_left <= 14'h02;
      VMCTR1  : params_left <= 14'h01;
      GMCTRP1 : params_left <= 14'h10;
      GMCTRN1 : params_left <= 14'h10;
      PWCTR6  : params_left <= 14'h01;
      COLMOD  : params_left <= 14'h01;
      MADCTL  : params_left <= 14'h01;
      INVON   : params_left <= 14'h00;
      DISPON  : params_left <= 14'h00;
      CASET   : params_left <= 14'h04;
      RASET   : params_left <= 14'h04;
      RAMWR   : params_left <= 14'd12800;
      default : params_left <= 14'h00;
     endcase
     data <= cmd[cmd_counter];
     cmd_counter <= cmd_counter + 5'b1;
     state <= ldc;
    end
 
   end

   dpcmd: begin

    if(delay < pcmd)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= lc;
     delay <= 16'd0;
    end

   end

   dmw_c: begin

    if(delay < mw_c)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= rdc; // Raise dc for params
     delay <= 16'd0; // Reset delay
    end

   end

   ldc: 
   begin

    dc <= 1'b0;
    state <= sm;

   end

   sm: 
   begin

    if(dc == 1'b1 && cmd[cmd_counter-5'd1] == RAMWR)
    begin
     if(pixel_bit_counter == 4'b1111)
     begin
      state <= lcs;
     end
     else if(pixel_bit_counter == 4'b0000)
     begin
      state <= slb;
      pixel_bit_counter <= 4'b1111;
     end
     else
     begin
      state <= send;
     end

     mosi <= pixel_data[pixel_bit_counter];
     pixel_bit_counter <= pixel_bit_counter - 4'b0001;
    end
    else
    begin
     if(bit_counter == 3'b111)
     begin
      state <= lcs;
     end
     else if(bit_counter == 3'b000)
     begin
      state <= slb;
      bit_counter <= 3'b111;
     end
     else
     begin
      state <= send;
     end

     mosi <= data[bit_counter];
     bit_counter <= bit_counter - 3'b001;
    end
 
   end

   lcs: 
   begin

    if(scl == 1'b1)
    begin
     cs <= 1'b0;
     state <= send;
    end
    else
    begin
     state <= lcs;
    end

   end

   send: 
   begin

    if(scl == 1'b1)
    begin
     state <= sm;
    end
    else
    begin
     state <= send;
    end

   end

   slb: 
   begin

    if(scl == 1'b1)
    begin
     state <= rcs;
    end
    else
    begin
     state <= slb;
    end

   end

   rcs: 
   begin
   
    cs <= 1'b1;
    if(dc == 1'b0)
    begin
     if(cmd_counter == 5'd20)
     begin
      state <= dmw_p; // short
     end
     else if(cmd_counter == 5'd23)
     begin
      state <= dmw_c; // long
     end
     else
     begin
      if(cmd[cmd_counter-5'd1] == FRMCTR3)
      begin
       state <= dfrmctr3_c;
      end
      else if(cmd[cmd_counter-5'd1] == GMCTRP1 ||
          cmd[cmd_counter-5'd1] == GMCTRN1)
      begin
       state <= dgmctr_c;
      end
      else if(cmd[cmd_counter-5'd1] == CASET ||
	  cmd[cmd_counter-5'd1] == RASET)
      begin
       state <= dcr_c;
      end
      else if(cmd[cmd_counter-5'd1] == SLPOUT)
      begin
       state <= dsleep;
      end
      else
      begin
       state <= rdc;
      end
     end
    end
    else
    begin
     if(cmd_counter == 5'd23)
     begin
      state <= dmw_p; // Provide 6us delay after each parameter
     end
     else
     begin
      if(cmd[cmd_counter-5'd1] == FRMCTR3)
      begin
       state <= dfrmctr3_p;
      end
      else if(cmd[cmd_counter-5'd1] == GMCTRP1 ||
	      cmd[cmd_counter-5'd1] == GMCTRN1)
      begin
       state <= dgmctr_p;
      end
      else if(cmd[cmd_counter-5'd1] == CASET ||
	      cmd[cmd_counter-5'd1] == RASET)
      begin
       state <= dcr_p;
      end
      else
      begin
       state <= lp;
      end
     end
    end
   
   end

   rdc: 
   begin

    dc <= 1'b1;
    state <= lp;

   end

   lp: 
   begin

    if(cmd[cmd_counter-5'd1] == RAMWR)
    begin
     pixel_data[15:8] <= rainbow[15:8];
     pixel_data[7:0] <= rainbow[7:0];
    end
    else
    begin
     data <= params[param_counter];
    end

    if(params_left == 14'd0)
    begin
     if(cmd[cmd_counter-5'd1] == RAMWR)
     begin
      cmd_counter <= cmd_counter - 5'd3;
      param_counter <= param_counter - 7'd8;
      rainbow <= rainbow - 16'h11_11;
     end
     state <= dpcmd;// need to provide delay
    end
    else
    begin
     if(param_counter != 7'd67)
     begin
      param_counter <= param_counter + 7'd01;
     end                           
     params_left <= params_left - 14'd1;           
     state <= sm;
    end

   end

   dmw_p: begin
    
    if(delay < mw_p)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     if(cmd_counter == 5'd20)
     begin
      state <= rdc;
     end
     else
     begin
      state <= lp;
     end
     delay <= 16'd0;
    end

   end

   dfrmctr3_c: 
   begin

    if(delay < frmctr3)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= rdc;
     delay <= 16'd0; 
    end

   end

   dfrmctr3_p:
   begin

    if(delay < frmctr3)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= lp;
     delay <= 16'd0;
    end
 
   end

   dgmctr_c:
   begin

    if(delay < gmctr)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= rdc;
     delay <= 16'd0;
    end

   end

   dgmctr_p:
   begin

    if(delay < gmctr)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= lp;
     delay <= 16'd0;
    end

   end

   dcr_c:
   begin

    if(delay < cr)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= rdc;
     delay <= 16'd0;
    end

   end

   dcr_p:
   begin

    if(delay < cr)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= lp;
     delay <= 16'd0;
    end

   end

   dsleep:
   begin

    if(delay < sleep)
    begin
     delay <= delay + 16'd1;
    end
    else
    begin
     state <= rdc;
     delay <= 16'd0;
    end

   end

  endcase
 end

 assign RST = rst;
 assign SCL = scl;
 assign DC = dc;
 assign MOSI = mosi;
 assign CS = cs;

endmodule
