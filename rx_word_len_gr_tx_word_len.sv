program test_tb(i2s_intf intf);
  
  i2s_env env;
  
  initial begin
    i2s_config #(`size) cfg=new;

    env = new(intf,cfg);
    
    cfg.update_config(.repeat_gen(5),.config_ration(RATION16),.word_len(`size),.slv_word_len(WLEN18),.mode_master(
      TX),.mode_slave(RX),.chnl_mode(MONO_RIGHT),.ws_mode(LEFT_JUSTIFIED),.complement(NORMAL));
  

    $display("[---------------RUNNING TEST: SLAVE WS GREATER THAN MASTER WS LENGTH-------------------]");

    fork
      env.run();
    join_any
    disable fork;
  end
endprogram :test_tb
