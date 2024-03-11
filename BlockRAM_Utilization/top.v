`include "bram.v"
`include "bramfull.v"


//example of a small memory implementation using bram, both inferred with a verilog array
//and an explicit using the bram primitive in yosys
//bram cannot be read and written at the same time

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
       b4_rd_en,
       b5_rd_en,
       b6_rd_en,
       b7_rd_en,
       b8_rd_en,
       b9_rd_en,
       b10_rd_en,
       b11_rd_en,
       b12_rd_en,
       b13_rd_en,
       b14_rd_en,
       b15_rd_en,
       b16_rd_en,
       b17_rd_en,
       b18_rd_en;
   reg [8:0] b1_rd_addr, 
	     b2_rd_addr,
	     b3_rd_addr,
	     b4_rd_addr,
	     b5_rd_addr,
	     b6_rd_addr,
	     b7_rd_addr,
	     b8_rd_addr,
	     b9_rd_addr,
	     b10_rd_addr,
	     b11_rd_addr,
	     b12_rd_addr,
	     b13_rd_addr,
	     b14_rd_addr,
	     b15_rd_addr,
	     b16_rd_addr,
	     b17_rd_addr;
   reg [3:0] b18_rd_addr;
   wire [7:0] b1_data_out, 
	      b2_data_out,
	      b3_data_out,
	      b4_data_out,
	      b5_data_out,
	      b6_data_out,
	      b7_data_out,
	      b8_data_out,
	      b9_data_out,
	      b10_data_out,
	      b11_data_out,
	      b12_data_out,
	      b13_data_out,
	      b14_data_out,
	      b15_data_out,
	      b16_data_out,
	      b17_data_out,
	      b18_data_out;
   wire b1_valid_out, 
	b2_valid_out,
	b3_valid_out,
	b4_valid_out,
	b5_valid_out,
	b6_valid_out,
	b7_valid_out,
	b8_valid_out,
	b9_valid_out,
	b10_valid_out,
	b11_valid_out,
	b12_valid_out,
	b13_valid_out,
	b14_valid_out,
	b15_valid_out,
	b16_valid_out,
	b17_valid_out,
	b18_valid_out;

   bram block1(
    .clk(clk),
    .rd_en(b1_rd_en), 
    .rd_addr(b1_rd_addr), 
    .data_out(b1_data_out), 
    .valid_out(b1_valid_out)
   );                        

   bram block2(                
    .clk(clk),
    .rd_en(b2_rd_en), 
    .rd_addr(b2_rd_addr), 
    .data_out(b2_data_out), 
    .valid_out(b2_valid_out)
   );                        

   bram block3(
    .clk(clk),
    .rd_en(b3_rd_en), 
    .rd_addr(b3_rd_addr), 
    .data_out(b3_data_out), 
    .valid_out(b3_valid_out)
   );                        

   bram block4(
    .clk(clk),
    .rd_en(b4_rd_en), 
    .rd_addr(b4_rd_addr), 
    .data_out(b4_data_out), 
    .valid_out(b4_valid_out)
   );                        

   bram block5(
    .clk(clk),
    .rd_en(b5_rd_en), 
    .rd_addr(b5_rd_addr), 
    .data_out(b5_data_out), 
    .valid_out(b5_valid_out)
   );                        

   bram block6(
    .clk(clk),
    .rd_en(b6_rd_en), 
    .rd_addr(b6_rd_addr), 
    .data_out(b6_data_out), 
    .valid_out(b6_valid_out)
   );                        

   bram block7(
    .clk(clk),
    .rd_en(b7_rd_en), 
    .rd_addr(b7_rd_addr), 
    .data_out(b7_data_out), 
    .valid_out(b7_valid_out)
   );                        

   bram block8(
    .clk(clk),
    .rd_en(b8_rd_en), 
    .rd_addr(b8_rd_addr), 
    .data_out(b8_data_out), 
    .valid_out(b8_valid_out)
   );                        

   bram block9(
    .clk(clk),
    .rd_en(b9_rd_en), 
    .rd_addr(b9_rd_addr), 
    .data_out(b9_data_out), 
    .valid_out(b9_valid_out)
   );                        

   bram block10(
    .clk(clk),
    .rd_en(b10_rd_en), 
    .rd_addr(b10_rd_addr), 
    .data_out(b10_data_out), 
    .valid_out(b10_valid_out)
   );                        

   bram block11(
    .clk(clk),
    .rd_en(b11_rd_en), 
    .rd_addr(b11_rd_addr), 
    .data_out(b11_data_out), 
    .valid_out(b11_valid_out)
   );                        

   bram block12(
    .clk(clk),
    .rd_en(b12_rd_en), 
    .rd_addr(b12_rd_addr), 
    .data_out(b12_data_out), 
    .valid_out(b12_valid_out)
   );                        

   bram block13(
    .clk(clk),
    .rd_en(b13_rd_en), 
    .rd_addr(b13_rd_addr), 
    .data_out(b13_data_out), 
    .valid_out(b13_valid_out)
   );                        

   bram block14(
    .clk(clk),
    .rd_en(b14_rd_en), 
    .rd_addr(b14_rd_addr), 
    .data_out(b14_data_out), 
    .valid_out(b14_valid_out)
   );                        

   bram block15(
    .clk(clk),
    .rd_en(b15_rd_en), 
    .rd_addr(b15_rd_addr), 
    .data_out(b15_data_out), 
    .valid_out(b15_valid_out)
   );                        

   bram block16(
    .clk(clk),
    .rd_en(b16_rd_en), 
    .rd_addr(b16_rd_addr), 
    .data_out(b16_data_out), 
    .valid_out(b16_valid_out)
   );                        

   bram block17(
    .clk(clk),
    .rd_en(b17_rd_en),
    .rd_addr(b17_rd_addr),
    .data_out(b17_data_out),
    .valid_out(b17_valid_out)
   );

   bramfull block18(
    .clk(clk),
    .rd_en(b18_rd_en),
    .rd_addr(b18_rd_addr),
    .data_out(b18_data_out),
    .valid_out(b18_valid_out)
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

    //byte <= 8'b0;


      b1_rd_en <= 0;
      b1_rd_addr <= 0;

      b2_rd_en <= 0;
      b2_rd_addr <= 0;

      b3_rd_en <= 0;
      b3_rd_addr <= 0;

      b4_rd_en <= 0;
      b4_rd_addr <= 0;

      b5_rd_en <= 0;
      b5_rd_addr <= 0;

      b6_rd_en <= 0;
      b6_rd_addr <= 0;

      b7_rd_en <= 0;
      b7_rd_addr <= 0;
      
      b8_rd_en <= 0;
      b8_rd_addr <= 0;
      
      b9_rd_en <= 0;
      b9_rd_addr <= 0;
      
      b10_rd_en <= 0;
      b10_rd_addr <= 0;

      b11_rd_en <= 0;
      b11_rd_addr <= 0;
                       
      b12_rd_en <= 0;
      b12_rd_addr <= 0;
                       
      b13_rd_en <= 0;
      b13_rd_addr <= 0;
                       
      b14_rd_en <= 0;
      b14_rd_addr <= 0;
                       
      b15_rd_en <= 0;
      b15_rd_addr <= 0;
                       
      b16_rd_en <= 0;
      b16_rd_addr <= 0;

      b17_rd_en <= 0;
      b17_rd_addr <= 0;

      b18_rd_en <= 0;
      b18_rd_addr <= 0;

      //bram need an init, will not work after a few cycles (maybe only when programming in sram?)
      if(init < 60) begin
         init <= init + 1;
      end else begin
         state <= state + 1;
      end

      //implicit/inferred module
      //comment this and uncomment the explicit logic below to use explicit module
      if (state == 4) begin
         b1_rd_en <= 1;
         b1_rd_addr <= 9'd14;
      end else if (state == 6) begin
         led <= b1_data_out[2:0];
      end 
      else if (state == 7) begin
	 b2_rd_en <= 1;
         b2_rd_addr <= 9'd14;
      end else if (state == 8) begin
         led <= b2_data_out[2:0];
      end                               
      else if (state == 8) begin
         b3_rd_en <= 1;
         b3_rd_addr <= 9'd14;
      end else if (state == 9) begin
         led <= b3_data_out[2:0];
      end                           
      else if (state == 10) begin
         b4_rd_en <= 1;
         b4_rd_addr <= 9'd14;
      end else if (state == 11) begin
         led <= b4_data_out[2:0];
      end                           
      else if (state == 12) begin
         b5_rd_en <= 1;
         b5_rd_addr <= 9'd14;
      end else if (state == 13) begin
         led <= b5_data_out[2:0];
      end                               
      else if (state == 13) begin
         b6_rd_en <= 1;
         b6_rd_addr <= 9'd14;
      end else if (state == 14) begin
         led <= b6_data_out[2:0];
      end                           
      else if (state == 15) begin
         b7_rd_en <= 1;
         b7_rd_addr <= 9'd14;
      end else if (state == 16) begin
         led <= b7_data_out[2:0];
      end                           
      else if (state == 17) begin
         b8_rd_en <= 1;
         b8_rd_addr <= 9'd14;
      end else if (state == 18) begin
         led <= b8_data_out[2:0];
      end                           
      else if (state == 19) begin
         b9_rd_en <= 1;
         b9_rd_addr <= 9'd14;
      end else if (state == 20) begin
         led <= b9_data_out[2:0];
      end                           
      else if (state == 21) begin
         b10_rd_en <= 1;
         b10_rd_addr <= 9'd14;
      end else if (state == 22) begin
         led <= b10_data_out[2:0];
      end                           
      else if (state == 23) begin
         b11_rd_en <= 1;
         b11_rd_addr <= 9'd14;
      end else if (state == 24) begin
         led <= b11_data_out[2:0];
      end                            
      else if (state == 25) begin
         b12_rd_en <= 1;
         b12_rd_addr <= 9'd14;
      end else if (state == 26) begin
         led <= b12_data_out[2:0];
      end                           
      else if (state == 27) begin
         b13_rd_en <= 1;
         b13_rd_addr <= 9'd14;
      end else if (state == 28) begin
         led <= b13_data_out[2:0];
      end                           
      else if (state == 29) begin
         b14_rd_en <= 1;
         b14_rd_addr <= 9'd14;
      end else if (state == 30) begin
         led <= b14_data_out[2:0];
      end                           
      else if (state == 31) begin
         b15_rd_en <= 1;
         b15_rd_addr <= 9'd14;
      end else if (state == 32) begin
         led <= b15_data_out[2:0];
      end                           
      else if (state == 33) begin
         b16_rd_en <= 1;
         b16_rd_addr <= 9'd14;
      end else if (state == 34) begin
         led <= b16_data_out[2:0];
      end                             
      else if (state == 35) begin
         b17_rd_en <= 1;
         b17_rd_addr <= 9'd14;
      end else if (state == 36) begin
         led <= b17_data_out[2:0];
      end                           
      else if (state == 37) begin
         b18_rd_en <= 1;
         b18_rd_addr <= 8'd14;
      end else if (state == 38) begin
         led <= b18_data_out[2:0];
      end                             

   end

endmodule
