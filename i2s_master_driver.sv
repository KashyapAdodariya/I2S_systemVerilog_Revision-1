

//`define edge_clk posedge

`define vif intf.master_drv_mp
class i2s_master_driver;
  
  i2s_config master_cfg;

  mailbox gen2driv_mbox;
  mailbox m_driv2scr_mbox;
  virtual i2s_intf intf;
  
  function new(virtual i2s_intf intf, mailbox gen_mbox, mailbox driv_mbox, i2s_config master_cfg);
    this.gen2driv_mbox = gen_mbox;
    this.m_driv2scr_mbox = driv_mbox;
    this.intf = intf; 
    this.master_cfg = master_cfg;
  endfunction:new
  
  //transaction class
  i2s_transaction tx1,txQ[$],tx;
  //declear prototypeing
  extern task run();
  //run rx mode of master
  extern task run_rx();
  //task for left fustified
  extern task left_jst(input i2s_transaction tr, input string data_select = "left");
  //task for right jusdtified
  extern task right_jst(input i2s_transaction tr, input string data_select = "left");
  //generate ws signal
  extern task generate_ws(input string sel_ws = "left");
  //run as stereo mode in tx
  extern task run_tx();


endclass:i2s_master_driver

  ///////////////////////////////////////////////////////////
  // Method name        : task run();
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : run tx and rx mode based on config
  ///////////////////////////////////////////////////////////

task i2s_master_driver::run();
  `print_info("i2s_master_driver","info","\t\t\tMASTER DRIVER RUNING\t\t\t",0,`verbo_lev);
   // begin
    fork
      begin:th1
      //generate SCK by using config clk
        forever begin
        //repeat(master_cfg.repeat_gen*master_cfg.config_ration) begin
          `vif.SCK<= 0;
          //#1;
          #(master_cfg.high_low);
          `vif.SCK<=1;
          //#1;
          #(master_cfg.high_low);
        end
      end:th1

    begin:th2
      forever begin
      //repeat(master_cfg.repeat_gen) begin
        generate_ws("left");
        generate_ws("right");
      end
    end:th2
   
    begin
      forever begin //repeat(master_cfg.repeat_gen) begin
        begin:th3
          //get data form gen.
          gen2driv_mbox.get(tx1);
          txQ.push_back(tx1);
          //put data into gen.
          m_driv2scr_mbox.put(tx1);
          //master set as a TX mode
          if(master_cfg.mode_master == TX) begin:txmode
            tx = txQ.pop_front();
            run_tx();
            //m_driv2scr_mbox.put(tx);
          end:txmode
          //master set as a RX mode
          else if(master_cfg.mode_master==RX) begin:rxmode
            run_rx();
          end:rxmode

          else begin:none
            $error("MASTER_DRIVER: Not select any mode. Plz Select mode in config class");
          end:none

        end:th3
     end
    end
  join_any 
endtask:run

  /////////////////////////////////////////////////////////////////////////////
  // Method name        : task run_tx();
  // Parameter Passed   : none
  // Returned parameter : none
  // Description        : done all TX config. which contain mono and stereo mode 
  //////////////////////////////////////////////////////////////////////////////

 task i2s_master_driver :: run_tx();
  begin:mainRun
    
    //only left channel driver data
    fork:for_left_channel
      
      //thread for left justified
      begin:th2
        wait(`vif.WS == 0);
        if(master_cfg.ws_mode == LEFT_JUSTIFIED) begin
          if(master_cfg.chnl_mode == MONO_LEFT || master_cfg.chnl_mode == STEREO) begin
            //wait(vif.WS == 0);
            left_jst(tx, "left");
          end
          else if(master_cfg.chnl_mode == MONO_RIGHT) begin
            left_jst(tx, "right");
          end
        end
      end:th2
      
      //thread for right justified
      begin:th3
        wait(`vif.WS == 0);
        if(master_cfg.ws_mode == RIGHT_JUSTIFIED) begin
          if(master_cfg.chnl_mode == MONO_LEFT || master_cfg.chnl_mode == STEREO) begin
            //wait(vif.WS == 0);
            right_jst(tx,"left");
          end
          else if(master_cfg.chnl_mode == MONO_RIGHT) begin
            right_jst(tx,"right");
          end
        end
      end:th3

    join:for_left_channel
    
    //only right channel drive data
    fork:for_right_channel

      //thread for left justified
      begin:th5
        wait(`vif.WS == 1);
         if(master_cfg.ws_mode == LEFT_JUSTIFIED) begin
           if(master_cfg.chnl_mode == MONO_RIGHT || master_cfg.chnl_mode == STEREO) begin
            //wait(vif.WS == 1);
            //@(`edge_clk vif.SCK);
            left_jst(tx, "right");
          end
          else if(master_cfg.chnl_mode == MONO_LEFT) begin
            //wait(vif.WS == 1);
            left_jst(tx, "left");
          end
        end
      end:th5
      
      //thread for right justified
      begin:th6
        wait(`vif.WS == 1);
          if(master_cfg.ws_mode == RIGHT_JUSTIFIED) begin
            if(master_cfg.chnl_mode == MONO_RIGHT || master_cfg.chnl_mode == STEREO) begin
              //wait(vif.WS == 1);
              right_jst(tx, "right");
            end
            else if(master_cfg.chnl_mode == MONO_LEFT) begin
              right_jst(tx, "left");
            end
          end
        end:th6

    join:for_right_channel

  end:mainRun
endtask:run_tx

  /////////////////////////////////////////////////////////////////
  // Method name        : task run_rx();
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : drive WS in rx mode. run only in posedge
  /////////////////////////////////////////////////////////////////

task i2s_master_driver :: run_rx;
  begin:mainRx
    generate_ws("left");
    generate_ws("right");
     
  end:mainRx
endtask:run_rx;

  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // Method name        : task left_jst(input i2s_transaction tr, input string data_select = "left");
  // Parameter Passed   : 1. transaction class instance
  //                      2. data_select
  // Returned parameter : none
  // Description        : used in left left justified and based on WS value
  //                      select data by using data_select parameter
  //////////////////////////////////////////////////////////////////////////////////////////////////////

task i2s_master_driver :: left_jst(input i2s_transaction tr, input string data_select = "left");
  begin
    //declear veriable
    //for counting data latch in sd_out
    int count_left = 0;
    //difference for config_ration and word_len
    int diff = 0;

    //loop for latch data in sd_out 
    //data latch till config_ration or word_len which was smaller
    for(int j=master_cfg.word_len-1; j>=0; j--) begin
      @(`edge_clk `vif.SCK);
      //make selection based on channel mode
      if(data_select == "left") `vif.master_drv_cb.sd_out <= tr.left_data[j];
      else if (data_select == "right")  `vif.master_drv_cb.sd_out <= tr.right_data[j];
      count_left++;
      //reach counting form config_ration-1 stop trasmitting data
      if(count_left == (master_cfg.config_ration)) break;
    end
    //config_ration larger then word_len then append zero at last remaning bits
    if(master_cfg.config_ration > master_cfg.word_len) begin
      diff = master_cfg.config_ration - master_cfg.word_len;
      for(int k=0; k<diff; k++) begin
        @(`edge_clk `vif.SCK);
        `vif.master_drv_cb.sd_out <= 1'b0;
      end
    end
  end
endtask:left_jst

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  // Method name        : task right_jst(input i2s_transaction tr, input string data_select = "left");
  // Parameter Passed   : 1. transaction class instance
  //                      2. data_select
  // Returned parameter : none
  // Description        : used in right justified config. and based on WS value
  //                      select data by using data_select parameter
  ///////////////////////////////////////////////////////////////////////////////////////////////////////

task i2s_master_driver :: right_jst(input i2s_transaction tr, input string data_select = "left");
  begin
    //declear variable for difference
    int diff = 0;
    
    //config_ration less or equal word_len then drive data as per clk and data_select
    if(master_cfg.config_ration <= master_cfg.word_len) begin:less_comp
      for(int j=master_cfg.config_ration-1; j>=0; j--) begin:for1
        @(`edge_clk `vif.SCK);
        if(data_select == "left") `vif.master_drv_cb.sd_out <= tr.left_data[j];
        else if (data_select == "right")  `vif.master_drv_cb.sd_out <= tr.right_data[j];
      end:for1
    end:less_comp
    //config_ration grater then word_len insert zeros at begining 
    else if(master_cfg.config_ration > master_cfg.word_len) begin:more_comp
      diff = master_cfg.config_ration - master_cfg.word_len;
      //insert zeros 
      for(int j=0; j<diff; j++) begin
        @(`edge_clk `vif.SCK);
        `vif.master_drv_cb.sd_out <= 1'b0;
      end
      //after insert zeros, data will drive
      for(int k=master_cfg.word_len-1; k>=0; k--) begin:for2
        @(`edge_clk `vif.SCK);
        if(data_select == "left") `vif.master_drv_cb.sd_out <= tr.left_data[k];
        else if (data_select == "right")  `vif.master_drv_cb.sd_out <= tr.right_data[k];
      end:for2
    end:more_comp
  end
endtask:right_jst

  ////////////////////////////////////////////////////////////////////////
  // Method name        : task generate_ws(input string sel_ws = "left");
  // Parameter Passed   : 1. passed string for select WS value
  // Returned parameter : none
  // Description        : based on user input select WS value and on till
  //                      config_ration
  ////////////////////////////////////////////////////////////////////////

task i2s_master_driver :: generate_ws(input string sel_ws = "left");
  begin
    //drive WS based on sel_ws
    for(int i=0; i<=master_cfg.config_ration-1; i++) begin
      @(`edge_clk `vif.SCK);
      //for left channel
      if(sel_ws=="left")  `vif.WS <= 1'b0;
      //for right channel
      else if(sel_ws == "right") `vif.WS <= 1'b1;
    end
  end
endtask:generate_ws

