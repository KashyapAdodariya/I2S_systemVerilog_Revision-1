

// Revision: 1
//-------------------------------------------------------------------------------

program test_tb(i2s_intf intf);  
  i2s_config#(`size) cfg=new;
  i2s_env env;

  initial begin
    
    assert(cfg.randomize() with {mode_master == TX; slv_word_len == `size; repeat_gen inside {[5:10]};}) begin
      `print_info("TEST_CASE","display","config randomization done",0,`verbo_lev);
    end
    else begin
      `print_info("TEST_CASE","error","config_randomization fail",0,`verbo_lev);
    end
    env=new(intf,cfg);

      $display("[---------------RUNNING TEST: MASTER TX AND SLAVE RX SAME WLEN-------------------]");
    env.run();
    
  end
endprogram:test_tb

