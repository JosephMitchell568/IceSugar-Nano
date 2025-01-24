/*
 Joseph Mitchell

 CRC with IceSugarNano Testbench
*/


module crc_tb;

 reg clk, led;

 // Instantiate Lattice IceSugarNano custom microsd module
 crc c(
  .CLK(clk),
  .LED(led)
 );


 initial
 begin
  clk = 1'b0;
  led = 1'b0;
 end

 always
 begin
  #5 clk = 1'b0;
  #5 clk = 1'b1;
 end

endmodule