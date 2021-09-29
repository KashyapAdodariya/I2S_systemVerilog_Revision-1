class alternate_data_stream_test_stereo extends i2s_transaction ;
  constraint right_data_c {right_data == {(`size/2){2'b10}};}
  constraint left_data_c {left_data == {(`size/2){2'b10}};}

  function new(i2s_config cfg);
      super.new(cfg);
    endfunction 


endclass:alternate_data_stream_test_stereo 

program test_tb(i2s_intf intf);  
  i2s_config#(`size) cfg=new;

  i2s_env env;
  initial begin
    alternate_data_stream_test_stereo seq_h=new(cfg);

    cfg.update_config(.repeat_gen(5),.config_ration(RATION16),.word_len(`size),.slv_word_len(WLEN16),.mode_master(
      RX),.mode_slave(TX),.chnl_mode(STEREO),.ws_mode(LEFT_JUSTIFIED),.complement(NORMAL));
  
    env=new(intf,cfg);
    if(cfg.mode_master == TX)begin
   env.m_agent.gen.tx1=seq_h;
    end
    else begin
      env.s_agent.gen.tx1=seq_h;
    end
    $display("[---------------RUNNING TEST:ALTERNATE DATA STREAM ON STEREO MODE-------------------]");
    env.run();
    
  end
endprogram:test_tb
