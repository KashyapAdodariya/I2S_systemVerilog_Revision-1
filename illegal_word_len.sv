program test_tb(i2s_intf intf);
  
 i2s_config#(`size) cfg=new;
  i2s_env env;

  initial begin
   env=new(intf,cfg); 
    
 cfg.update_config(.repeat_gen(5),.config_ration(RATION16),.word_len(`size),.slv_word_len(WLEN17),.mode_master(
      TX),.mode_slave(RX),.chnl_mode(MONO_LEFT),.ws_mode(RIGHT_JUSTIFIED),.complement(NORMAL));
  
    $display("[---------------RUNNING TEST:ILLEGAL WORD LENGTH-------------------]");
    env.run();
    
  end
endprogram :test_tb
