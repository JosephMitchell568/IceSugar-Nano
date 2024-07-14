`include "instructionMem1.v"
`include "instructionMem2.v"
`include "instructionMem3.v"
`include "instructionMem4.v"

//example of a small memory implementation using bram, both inferred with a verilog array
//and an explicit using the bram primitive in yosys
//bram cannot be read and written at the same time

module fetch( 
	input clk,

        input PCsrc,
        input [31:0] brnchJmpAddr,

        output [31:0] instruction,
        output [31:0] PCnext	
   );


   reg im1_rd_en,
       im2_rd_en,
       im3_rd_en,
       im4_rd_en; 
   reg [8:0] im1_rd_addr,
	     im2_rd_addr,
	     im3_rd_addr,
	     im4_rd_addr; 
   wire [7:0] im1_data_out,
	      im2_data_out,
	      im3_data_out,
	      im4_data_out; 
   wire im1_valid_out,
	im2_valid_out,
	im3_valid_out,
	im4_valid_out; 

   instructionMem1 instructionMem1Inst(
    .clk(clk),
    .rd_en(im1_rd_en), 
    .rd_addr(im1_rd_addr), 
    .data_out(im1_data_out), 
    .valid_out(im1_valid_out)
   );                                     

   instructionMem2 instructionMem2Inst(
    .clk(clk),
    .rd_en(im2_rd_en), 
    .rd_addr(im2_rd_addr), 
    .data_out(im2_data_out), 
    .valid_out(im2_valid_out)
   );                                  

   instructionMem3 instructionMem3Inst(
    .clk(clk),
    .rd_en(im3_rd_en), 
    .rd_addr(im3_rd_addr), 
    .data_out(im3_data_out), 
    .valid_out(im3_valid_out)
   );                                  

   instructionMem4 instructionMem4Inst(
    .clk(clk),
    .rd_en(im4_rd_en), 
    .rd_addr(im4_rd_addr), 
    .data_out(im4_data_out), 
    .valid_out(im4_valid_out)
   );                                  

   reg [32:0] init;
   reg [32:0] state;
   reg [31:0] instruction;

   //leds are active low --- To show that 4 BRAM were used...
   //assign INSTR_B4 = instruction[0];
   //assign INSTR_B3 = instruction[8];
   //assign INSTR_B2 = instruction[16];
   //assign INSTR_B1 = instruction[24];

   initial begin
      block = 0;

      im1_rd_en = 0;
      im1_rd_addr = 0;

      im2_rd_en = 0;
      im2_rd_addr = 0;

      im3_rd_en = 0;
      im3_rd_addr = 0;

      im4_rd_en = 0;
      im4_rd_addr = 0;

      init = 0;
      state = 0;
      instruction = 0;
   end

   always @(posedge clk)
   begin

      //bram need an init, will not work after a few cycles (maybe only when programming in sram?)
    if(init < 60) begin
       init <= init + 1;
    end else begin
       state <= state + 1;
    end                   

      //implicit/inferred module
      //comment this and uncomment the explicit logic below to use explicit module
    if (state == 4) begin
       im1_rd_en <= 1;
       im1_rd_addr <= 9'b0;
       im2_rd_en <= 1;
       im2_rd_addr <= 9'b0;
       im3_rd_en <= 1;
       im3_rd_addr <= 9'b0;
       im4_rd_en <= 1;
       im4_rd_addr <= 9'b0;
    end 
    else if (state == 5) begin
       if(PCsrc)
       begin
        pc[31:0] <= brnchJmpAddr;
       end
       else
       begin
	pc[31:0] <= pc[31:0] + 32'd4;
       end

       instruction <= {im1_data_out,
	               im2_data_out,
	               im3_data_out,
	               im4_data_out};

       im1_rd_addr[8:0] <= pc[10:2];
       im2_rd_addr[8:0] <= pc[10:2];
       im3_rd_addr[8:0] <= pc[10:2];
       im4_rd_addr[8:0] <= pc[10:2];
    end                          

   end

endmodule
