`include "gba_bw_intro_b1ram.v"
`include "gba_bw_intro_b2ram.v"
`include "gba_bw_intro_b3ram.v"
`include "gba_bw_intro_b4ram.v"


// GBA bw intro image project 
// 	memory utilization

module top(
	input [3:0] SW, 
	input clk, 
	output LED_R, 
	output LED_G, 
	output LED_B
   );


   reg b1_rd_en, 
       b2_rd_en,
       b3_rd_en,
       b4_rd_en;
   reg [8:0] b1_rd_addr, 
	     b2_rd_addr,
	     b3_rd_addr;
   reg [5:0] b4_rd_addr;
   wire [7:0] b1_data_out, 
	      b2_data_out,
	      b3_data_out,
	      b4_data_out;
   wire b1_valid_out, 
	b2_valid_out,
	b3_valid_out,
	b4_valid_out;
	

   gba_bw_intro_b1ram block1(
    .clk(clk),
    .rd_en(b1_rd_en), 
    .rd_addr(b1_rd_addr), 
    .data_out(b1_data_out), 
    .valid_out(b1_valid_out)
   );                        

   gba_bw_intro_b2ram block2(                
    .clk(clk),
    .rd_en(b2_rd_en), 
    .rd_addr(b2_rd_addr), 
    .data_out(b2_data_out), 
    .valid_out(b2_valid_out)
   );                        

   gba_bw_intro_b3ram block3(
    .clk(clk),
    .rd_en(b3_rd_en), 
    .rd_addr(b3_rd_addr), 
    .data_out(b3_data_out), 
    .valid_out(b3_valid_out)
   );                        

   gba_bw_intro_b4ram block4(
    .clk(clk),
    .rd_en(b4_rd_en), 
    .rd_addr(b4_rd_addr), 
    .data_out(b4_data_out), 
    .valid_out(b4_valid_out)
   );                        

   reg [32:0] init;
   reg [32:0] state;
   reg [2:0] led;

   //leds are active low
   assign LED_R = ~led[0];
   assign LED_G = ~led[1];
   assign LED_B = ~led[2];

   initial begin
      block = 0;
      b1_rd_en = 0;
      b1_rd_addr = 0;


      init = 0;
      state = 0;
      led = 0;
   end

   always @(posedge clk)
   begin

    b1_rd_en <= 0;
    b1_rd_addr <= 0;

    b2_rd_en <= 0;
    b2_rd_addr <= 0;

    b3_rd_en <= 0;
    b3_rd_addr <= 0;

    b4_rd_en <= 0;
    b4_rd_addr <= 0;

    if (state == 0) begin
       b1_rd_en <= 1;
       b1_rd_addr <= 9'd14;
    end else if (state == 1) begin
       led <= b1_data_out[2:0];
    end 
    else if (state == 2) begin
       b2_rd_en <= 1;
       b2_rd_addr <= 9'd14;
    end else if (state == 3) begin
       led <= b2_data_out[2:0];
    end                               
    else if (state == 4) begin
       b3_rd_en <= 1;
       b3_rd_addr <= 9'd14;
    end else if (state == 5) begin
       led <= b3_data_out[2:0];
    end                           
    else if (state == 6) begin
       b4_rd_en <= 1;
       b4_rd_addr <= 9'd14;
    end else if (state == 7) begin
       led <= b4_data_out[2:0];
    end                           

    if(state < 8)
    begin
     state <= state + 1;
    end

   end

endmodule
