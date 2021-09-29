
program test_tb(i2s_intf intf);
  
 i2s_config#(`size) cfg=new;
  i2s_env env;

  initial begin
    
   env=new(intf,cfg); 
    
    assert(cfg.randomize() with {mode_master == TX; chnl_mode ==STEREO; repeat_gen inside {[2:5]};});
    `print_info("TEST_CASE","display","config randomization done",0,`verbo_lev);
  
    $display("[---------------RUNNING TEST:VARIABLE WORD LENGTH -------------------]");
    env.run();
    
  end
endprogram :test_tb
