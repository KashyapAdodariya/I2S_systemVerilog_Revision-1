`define edge_clk posedge

interface i2s_intf(input bit clk);
  //bidirection signal used wire
  logic sd_out;              //serial data
  logic WS;              //word select
  logic SCK;              //clock
  
  //clocking blockes
  clocking master_drv_cb @(`edge_clk SCK);
    default input #1 output #1;
    inout sd_out;
    output WS;
    output SCK;
  endclocking:master_drv_cb

  //both monitor are same interface signal and direction
  clocking monitor_cb @(`edge_clk SCK);
    default input #1 output #1;
    input sd_out;
    input WS;
    input SCK;
  endclocking:monitor_cb

  clocking slave_drv_cb @(`edge_clk SCK);
    default input #1 output #1;
    input SCK;
    input WS;
    output sd_out;
  endclocking:slave_drv_cb

  //modports
  modport master_drv_mp (clocking master_drv_cb,inout sd_out, output WS,output SCK);
    modport slave_drv_mp (clocking slave_drv_cb,input SCK,input WS, inout sd_out);
    modport monitor_mp (clocking monitor_cb, input sd_out,input WS, input SCK);

endinterface:i2s_intf