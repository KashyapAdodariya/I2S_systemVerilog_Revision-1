`timescale 1ns/1ps
`define FREQ 48.000
`define toggle ((1000/`FREQ)/2)
 `include "i2s_header.svh" 
module top;

  bit clk;

  always #(`toggle) clk=~clk;
  i2s_intf pif(clk);

  test_tb t(pif);
  
  initial begin
   // vif=pif;

    $dumpfile("out.vcd");
    $dumpvars;
    #300000;
    i2s_msg_logger::error_display();
    $finish;
  end
  
endmodule:top
