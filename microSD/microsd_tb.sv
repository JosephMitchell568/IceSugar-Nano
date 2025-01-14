/*
 Joseph Mitchell

 MicroSD Card IceSugarNano Testbench
*/


module microsd_tb;

 reg clk, sd_clk, led, cmd;
 reg [3:0] dat;

 // Instantiate Lattice IceSugarNano custom microsd module
 microsd sd(
  .CLK(clk),
  .SD_CLK(sd_clk),
  .LED(led),
  .CMD(cmd),
  .DAT(dat)
 );


 initial
 begin
  clk = 1'b0;

  sd_clk = 1'b0;
  led = 1'b0;
  cmd = 1'b0;
  dat[3:0] = 4'b1111;
 end

 always
 begin
  #5 clk = 1'b0;
  #5 clk = 1'b1;
 end

endmodule