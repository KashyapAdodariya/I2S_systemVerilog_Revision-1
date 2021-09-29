

/* Revision: 2
-------------------------------------------------------------------------------*/


/*-----------------------------I2S Scoreboard------------------------------*/
class i2s_scoreboard;
  
  //Config handle
  i2s_config cfg;
  
  //Transaction class instance
  i2s_transaction d_pkt;
  i2s_transaction m_pkt;
  
  //MAILBOX MASTER DRIVER TO SCOREBOARD
  mailbox m_driv2scr_mbox;
  
  //MAILBOX SLAVE DRIVER TO SCOREBOARD
  mailbox s_driv2scr_mbox;
  
  //MAILBOX MASTER MONITOR TO SCOREBOARD
  mailbox m_mon2scr_mbox;
  
  //MAILBOX SLAVE MONITOR TO SCOREBOARD
  mailbox s_mon2scr_mbox;
  
  //CONNECTING MAILBOX
  function new(mailbox m_driv2scr_mbox,s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,i2s_config cfg);
    
    this.cfg = cfg;
    this.m_driv2scr_mbox = m_driv2scr_mbox;
    this.s_driv2scr_mbox = s_driv2scr_mbox;
    this.m_mon2scr_mbox = m_mon2scr_mbox;
    this.s_mon2scr_mbox = s_mon2scr_mbox;
    
  endfunction
  
  /*---------------------------Declare ALL SCOREBOARD Tasks------------------------------*/
  extern task run();
  extern task mas_tx_slv_rx_check();
  extern task mas_rx_slv_tx_check();
  
endclass
    
    
  ////////////////////////////////////////////////////////////////////////////////
  // Method name         : run task
  // Parameters passed   : none
  // Returned parameters : none
  // Description         : To run all the methods 
  ////////////////////////////////////////////////////////////////////////////////

  task i2s_scoreboard::run();
    `print_info("i2s_scoreboard","info","\t\t\tSCOREBOARD RUNING\t\t\t",0,`verbo_lev);
    repeat(cfg.repeat_gen) begin

      if(cfg.mode_master == TX && cfg.mode_slave == RX) begin 
        mas_tx_slv_rx_check();
      end
      
      if(cfg.mode_master == RX && cfg.mode_slave == TX) begin 
        mas_rx_slv_tx_check();
      end
      
    end
    
  endtask
   
  ////////////////////////////////////////////////////////////////////////////////
  // Method name         : mas_rx_slv_tx_check
  // Parameters passed   : none
  // Returned parameters : none
  // Description         : slave tx and master rx mode based on channel mode 
  ////////////////////////////////////////////////////////////////////////////////
  
  task i2s_scoreboard::mas_rx_slv_tx_check();
    int flag = 1;
    static int count;
    bit [`size-1: 0] temp_array_l,temp_array_r;
    int diff;
    s_driv2scr_mbox.get(d_pkt);
    m_mon2scr_mbox.get(m_pkt);
    
    if(cfg.slv_word_len > cfg.word_len) begin
      
      diff = cfg.slv_word_len - cfg.word_len;
      
      for(int i=cfg.slv_word_len-1; i >= diff ; i--) begin
        temp_array_l[i - diff ] = d_pkt.left_data[i];
        temp_array_r[i - diff ] = d_pkt.right_data[i];
      end

      if(cfg.chnl_mode == MONO_RIGHT) begin
       
        if(m_pkt.right_data == temp_array_r) begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == MONO_LEFT) begin
        
        if(m_pkt.left_data == temp_array_l) begin
          `print_info("i2s_scoreboard","info","------Mono mode Left channel data pass------",0,`verbo_lev);
        end
        
        else begin 
         `print_info("i2s_scoreboard","info","------Mono mode Left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == STEREO) begin
        
        if(m_pkt.left_data == temp_array_l && m_pkt.right_data == temp_array_r) begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      count++;
      
      if(count== cfg.repeat_gen && flag==0) begin
        `print_info("i2s_scoreboard","info","------TESTCASE FAIL------",0,`verbo_lev);
      end
      else if(count == cfg.repeat_gen && flag==1) begin
        `print_info("i2s_scoreboard","info","------TESTCASE PASS------",0,`verbo_lev);
      end
      
    end
      
    else if (cfg.slv_word_len == cfg.word_len) begin
      
      if(cfg.chnl_mode == MONO_RIGHT) begin
      
        if(m_pkt.right_data == d_pkt.right_data) begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
    
      else if(cfg.chnl_mode == MONO_LEFT) begin
        
        if(m_pkt.left_data == d_pkt.left_data) begin
          `print_info("i2s_scoreboard","info","------Mono mode Left channel data pass------",0,`verbo_lev);
        end
        
        else begin 
         `print_info("i2s_scoreboard","info","------Mono mode Left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == STEREO) begin
        
        if(m_pkt.left_data == d_pkt.left_data && m_pkt.left_data == d_pkt.left_data) begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data fail------",0,`verbo_lev);
          flag=0;
        end
        
      end
      count++;
      
      if(count== cfg.repeat_gen && flag==0) begin
        `print_info("i2s_scoreboard","info","------TESTCASE FAIL------",0,`verbo_lev);
      end
      else if(count == cfg.repeat_gen && flag==1) begin
        `print_info("i2s_scoreboard","info","------TESTCASE PASS------",0,`verbo_lev);
      end
      
    end
    
    else if(cfg.slv_word_len < cfg.word_len) begin
      
      diff = cfg.slv_word_len - cfg.word_len ;
    
      for(int i=cfg.word_len - diff; i >= 0 ; i--) begin
        temp_array_l[i] = d_pkt.left_data[i];
        temp_array_r[i] = d_pkt.right_data[i];
      end
      
      $display("LEFT DATA %0h  size = %0d",temp_array_l,$size(temp_array_l));
      $display("RIGHT DATA %0h  size = %0d",temp_array_r,$size(temp_array_r));

      if(cfg.chnl_mode == MONO_RIGHT) begin
    
        if(m_pkt.right_data == temp_array_r) begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == MONO_LEFT) begin
        
        if(m_pkt.left_data == temp_array_l) begin
         `print_info("i2s_scoreboard","info","------Mono mode Left channel data pass------",0,`verbo_lev);
        end
        
        else begin 
          `print_info("i2s_scoreboard","info","------Mono mode Left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == STEREO) begin
        
        if(m_pkt.right_data == temp_array_r && m_pkt.left_data == temp_array_l) begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data fail------",0,`verbo_lev);
          flag=0;
        end
        
      end
      count++;
      
      if(count == cfg.repeat_gen && flag==0) begin
        `print_info("i2s_scoreboard","info","------TESTCASE FAIL------",0,`verbo_lev);
      end
      else if(count == cfg.repeat_gen && flag==1) begin
        `print_info("i2s_scoreboard","info","------TESTCASE PASS------",0,`verbo_lev);
      end
    end
    
  endtask
        
  ////////////////////////////////////////////////////////////////////////////////
  // Method name         : mas_tx_slv_rx_check
  // Parameters passed   : none
  // Returned parameters : none
  // Description         : slave rx and master tx mode based on channel mode 
  ////////////////////////////////////////////////////////////////////////////////  
  
  task i2s_scoreboard::mas_tx_slv_rx_check();
    int flag = 1;
    static int count;
    bit [`size-1: 0] temp_array_l,temp_array_r;
    int diff;
    m_driv2scr_mbox.get(d_pkt);
    s_mon2scr_mbox.get(m_pkt);  
    
    if(cfg.word_len > cfg.slv_word_len) begin

      diff = cfg.word_len - cfg.slv_word_len;
    
      for(int i=cfg.word_len-1; i >= diff ; i--) begin
        temp_array_l[i - diff ] = d_pkt.left_data[i];
        temp_array_r[i - diff ] = d_pkt.right_data[i];
      end
      $display("LEFT DATA %0h  size = %0d",temp_array_l,$size(temp_array_l));
      $display("RIGHT DATA %0h  size = %0d",temp_array_r,$size(temp_array_r));

      if(cfg.chnl_mode == MONO_RIGHT) begin
    
        if(m_pkt.right_data == temp_array_r) begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == MONO_LEFT) begin
        
        if(m_pkt.left_data == temp_array_l) begin
         `print_info("i2s_scoreboard","info","------Mono mode Left channel data pass------",0,`verbo_lev);
        end
        
        else begin 
          `print_info("i2s_scoreboard","info","------Mono mode Left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == STEREO) begin
        
        if(m_pkt.right_data == temp_array_r && m_pkt.left_data == temp_array_l) begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data fail------",0,`verbo_lev);
          flag=0;
        end
        
      end
      count++;
      
      if(count == cfg.repeat_gen && flag==0) begin
        `print_info("i2s_scoreboard","info","------TESTCASE FAIL------",0,`verbo_lev);
      end
      else if(count == cfg.repeat_gen && flag==1) begin
        `print_info("i2s_scoreboard","info","------TESTCASE PASS------",0,`verbo_lev);
      end
    end
    
    else if (cfg.word_len == cfg.slv_word_len) begin
      
      if(cfg.chnl_mode == MONO_RIGHT) begin
  
        
        if(m_pkt.right_data == d_pkt.right_data) begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data fail------",0,`verbo_lev);
          flag=0;
        end
        
      end
      
      else if(cfg.chnl_mode == MONO_LEFT) begin
        
        if(m_pkt.left_data == d_pkt.left_data) begin
         `print_info("i2s_scoreboard","info","------Mono mode Left channel data pass------",0,`verbo_lev);
        end
        
        else begin 
          `print_info("i2s_scoreboard","info","------Mono mode Left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == STEREO) begin
        
        if(m_pkt.right_data == d_pkt.right_data && m_pkt.left_data == d_pkt.left_data) begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data fail------",0,`verbo_lev);
          flag=0;
        end
        
      end
      count++;
      
      if(count== cfg.repeat_gen && flag==0) begin
        `print_info("i2s_scoreboard","info","------TESTCASE FAIL------",0,`verbo_lev);
      end
      else if(count == cfg.repeat_gen && flag==1) begin
         `print_info("i2s_scoreboard","info","------TESTCASE PASS------",0,`verbo_lev);
      end

     end
    
    else if(cfg.word_len < cfg.slv_word_len) begin

      diff = cfg.slv_word_len - cfg.word_len -1;
    
      for(int i=cfg.slv_word_len - diff; i >= 0 ; i--) begin
        temp_array_l[i] = d_pkt.left_data[i];
        temp_array_r[i] = d_pkt.right_data[i];
      end

       $display("LEFT DATA %0h  size = %0d",temp_array_l,$size(temp_array_l));
      $display("RIGHT DATA %0h  size = %0d",temp_array_r,$size(temp_array_r));
      if(cfg.chnl_mode == MONO_RIGHT) begin
    
        if(m_pkt.right_data == temp_array_r) begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Mono mode Right channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == MONO_LEFT) begin
        
        if(m_pkt.left_data == temp_array_l) begin
         `print_info("i2s_scoreboard","info","------Mono mode Left channel data pass------",0,`verbo_lev);
        end
        
        else begin 
          `print_info("i2s_scoreboard","info","------Mono mode Left channel data fail------",0,`verbo_lev);
          flag=0;
        end
      end
      
      else if(cfg.chnl_mode == STEREO) begin
        
        if(m_pkt.right_data == temp_array_r && m_pkt.left_data == temp_array_l) begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data pass------",0,`verbo_lev);
        end
        
        else begin
          `print_info("i2s_scoreboard","info","------Stereo mode right and left channel data fail------",0,`verbo_lev);
          flag=0;
        end
        
      end
      count++;
      
      if(count == cfg.repeat_gen && flag==0) begin
        `print_info("i2s_scoreboard","info","------TESTCASE FAIL------",0,`verbo_lev);
      end
      else if(count == cfg.repeat_gen && flag==1) begin
        `print_info("i2s_scoreboard","info","------TESTCASE PASS------",0,`verbo_lev);
      end
    end
       
  endtask
   