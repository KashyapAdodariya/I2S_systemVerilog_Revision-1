`define vif vif.monitor_mp
class i2s_monitor;
  int diff;
  
  i2s_config monitor_cfg;
  i2s_transaction mst_trans;
  virtual i2s_intf vif;

//declaring 2 mailbox one for master one for slave
  mailbox m_mon2scr_mbox;       
  mailbox s_mon2scr_mbox;
  
//copying all the handles  
  
  function new(virtual i2s_intf vif,i2s_config monitor_cfg,mailbox m_mon2scr_mbox,s_mon2scr_mbox);
    this.vif=vif;
 
    this.m_mon2scr_mbox=m_mon2scr_mbox;
    this.s_mon2scr_mbox=s_mon2scr_mbox;
    this.monitor_cfg=monitor_cfg;
  endfunction
  
  task run();
    if(monitor_cfg.mode_master == TX)begin 
       monitor_cfg.word_length= monitor_cfg.slv_word_len;
    end
    else if (monitor_cfg.mode_master == RX)begin
      monitor_cfg.word_length=monitor_cfg.word_len;
    end
    
    repeat (monitor_cfg.repeat_gen) begin
      
      mst_trans=new(monitor_cfg,PKT_RX);
      if(monitor_cfg.chnl_mode == MONO_RIGHT)begin       // calling mono right task
      mon_mono_right();
    end
    else if(monitor_cfg.chnl_mode == MONO_LEFT)begin
      mon_mono_left();					// calling mono left task
    end
    else if(monitor_cfg.chnl_mode == STEREO)begin
      mon_stereo();					// calling stereo task
    end
    else begin
      $display("------------Please select valid channel mode in config class----------");
    end
    end
   
  endtask:run
  
  task mon_mono_right();
    
    if(monitor_cfg.ws_mode == RIGHT_JUSTIFIED)begin
      wait(`vif.WS == 1);
    
    if(monitor_cfg.mode_master == TX) begin
      if(monitor_cfg.slv_word_len >monitor_cfg.word_len)
        monitor_cfg.word_length=monitor_cfg.word_len;
    end
    
    if(monitor_cfg.mode_master == RX) begin
      if(monitor_cfg.word_len > monitor_cfg.slv_word_len)
        monitor_cfg.word_length=monitor_cfg.slv_word_len;
    end
      
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
          diff = monitor_cfg.config_ration - monitor_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
          diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
    
      for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        mst_trans.right_data[i] = `vif.sd_out;
        mst_trans.left_data[i] = 0;
      end
  
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.word_len > monitor_cfg.slv_word_len) begin
          diff = monitor_cfg.word_len - monitor_cfg.slv_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.slv_word_len > monitor_cfg.word_len) begin
          diff = monitor_cfg.slv_word_len - monitor_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      mst_trans.print("monitor data");
      if(monitor_cfg.mode_master == TX)begin 
         s_mon2scr_mbox.put(mst_trans);
      end
     
      else if (monitor_cfg.mode_master == RX)begin
        m_mon2scr_mbox.put(mst_trans);
      end
      @(`edge_clk `vif.SCK);
      
      end
      
      else if(monitor_cfg.ws_mode == LEFT_JUSTIFIED)begin
        wait(`vif.WS == 1);
      
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.slv_word_len >monitor_cfg.word_len)
          monitor_cfg.word_length=monitor_cfg.word_len;
      end
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.word_len > monitor_cfg.slv_word_len)
          monitor_cfg.word_length=monitor_cfg.slv_word_len;
      end
        
      for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        mst_trans.right_data[i] = `vif.sd_out;
        mst_trans.left_data[i] = 0;
      end
  
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.word_len > monitor_cfg.slv_word_len) begin
          diff = monitor_cfg.word_len - monitor_cfg.slv_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.slv_word_len > monitor_cfg.word_len) begin
          diff = monitor_cfg.slv_word_len - monitor_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
  
        

      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
          diff = monitor_cfg.config_ration - monitor_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
          diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      mst_trans.print("monitor data");
      if(monitor_cfg.mode_master == TX)begin 
         s_mon2scr_mbox.put(mst_trans);
      end
     
      else if (monitor_cfg.mode_master == RX)begin
        m_mon2scr_mbox.put(mst_trans);
      end
      @(`edge_clk `vif.SCK);
      end
    

  endtask
  
  task mon_mono_left;
    
    if(monitor_cfg.ws_mode == RIGHT_JUSTIFIED)begin
      wait(`vif.WS == 1);
    
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.slv_word_len >monitor_cfg.word_len)
          monitor_cfg.word_length=monitor_cfg.word_len;
      end
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.word_len > monitor_cfg.slv_word_len)
          monitor_cfg.word_length=monitor_cfg.slv_word_len;
      end
      
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
          diff = monitor_cfg.config_ration - monitor_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
          diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
    
      for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        mst_trans.left_data[i] = `vif.sd_out;
        mst_trans.right_data[i] = 0;
      end
  
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.word_len > monitor_cfg.slv_word_len) begin
          diff = monitor_cfg.word_len - monitor_cfg.slv_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.slv_word_len > monitor_cfg.word_len) begin
          diff = monitor_cfg.slv_word_len - monitor_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      mst_trans.print("monitor data");
      if(monitor_cfg.mode_master == TX)begin 
         s_mon2scr_mbox.put(mst_trans);
      end
     
      else if (monitor_cfg.mode_master == RX)begin
        m_mon2scr_mbox.put(mst_trans);
      end
      @(`edge_clk `vif.SCK);
      
      end
      
      else if(monitor_cfg.ws_mode == LEFT_JUSTIFIED)begin
        wait(`vif.WS == 1);
        
        if(monitor_cfg.mode_master == TX) begin
          if(monitor_cfg.slv_word_len >monitor_cfg.word_len)
            monitor_cfg.word_length=monitor_cfg.word_len;
        end
        
        if(monitor_cfg.mode_master == RX) begin
          if(monitor_cfg.word_len > monitor_cfg.slv_word_len)
            monitor_cfg.word_length=monitor_cfg.slv_word_len;
        end
          
          
        for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
          @(`edge_clk `vif.SCK);
          @(negedge `vif.SCK);
          mst_trans.left_data[i] = `vif.sd_out;
          mst_trans.right_data[i] = 0;
        end
    
        if(monitor_cfg.mode_master == TX) begin
          if(monitor_cfg.word_len > monitor_cfg.slv_word_len) begin
            diff = monitor_cfg.word_len - monitor_cfg.slv_word_len;
            for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          end
        end
        
        if(monitor_cfg.mode_master == RX) begin
          if(monitor_cfg.slv_word_len > monitor_cfg.word_len) begin
            diff = monitor_cfg.slv_word_len - monitor_cfg.word_len;
            for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          end
        end
  
        
        if(monitor_cfg.mode_master == TX) begin
          if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
            diff = monitor_cfg.config_ration - monitor_cfg.word_len;
            for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          end
        end
        
        
        if(monitor_cfg.mode_master == RX) begin
          if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
            diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
            for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          end
        end
        
          
        mst_trans.print("monitor data");
        if(monitor_cfg.mode_master == TX)begin 
           s_mon2scr_mbox.put(mst_trans);
        end
       
        else if (monitor_cfg.mode_master == RX)begin
          m_mon2scr_mbox.put(mst_trans);
        end
        @(`edge_clk `vif.SCK);
     end
    
     
  endtask
  
  
  
  task mon_stereo;

    static int count;
      
    if(monitor_cfg.ws_mode == RIGHT_JUSTIFIED)begin
      
      if(monitor_cfg.mode_master == TX) begin
          if(monitor_cfg.slv_word_len >monitor_cfg.word_len)
            monitor_cfg.word_length=monitor_cfg.word_len;
        end
        
        if(monitor_cfg.mode_master == RX) begin
          if(monitor_cfg.word_len > monitor_cfg.slv_word_len)
            monitor_cfg.word_length=monitor_cfg.slv_word_len;
        end
      
      fork  
        begin:th1
          wait(`vif.WS==1);
          
          
          if(monitor_cfg.mode_master == TX) begin
            if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
              diff = monitor_cfg.config_ration - monitor_cfg.word_len;
              for(int k=0; k<diff; k++) begin
                @(`edge_clk `vif.SCK);
              end
            end
          end
          
          
          if(monitor_cfg.mode_master == RX) begin
            if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
              diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
              for(int k=0; k<diff; k++) begin
                @(`edge_clk `vif.SCK);
              end
            end
          end
          

          for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
            @(`edge_clk `vif.SCK);
            @(negedge `vif.SCK);
            mst_trans.right_data[i] = `vif.sd_out;

          end 
          
          if(monitor_cfg.mode_master == TX) begin
            if(monitor_cfg.word_len > monitor_cfg.slv_word_len) begin
              diff = monitor_cfg.word_len - monitor_cfg.slv_word_len;
              for(int k=0; k<diff; k++) begin
                @(`edge_clk `vif.SCK);
              end
                @(negedge `vif.SCK);
            end
          end
          
          if(monitor_cfg.mode_master == RX) begin
            if(monitor_cfg.slv_word_len > monitor_cfg.word_len) begin
              diff = monitor_cfg.slv_word_len - monitor_cfg.word_len;
              for(int k=0; k<diff; k++) begin
                @(`edge_clk `vif.SCK);
              end
                @(negedge `vif.SCK);
            end
          end
      
        end
        
        begin:th2
          
          wait(`vif.WS==0);
          if(count==0) begin
            if(monitor_cfg.mode_master == TX) begin
              if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
            
            
            if(monitor_cfg.mode_master == RX) begin
              if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
          end
        
          else if(count!=0) begin
            if(monitor_cfg.mode_master == TX) begin
              if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
            
            
            if(monitor_cfg.mode_master == RX) begin
              if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
          end
          
          for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
            @(`edge_clk `vif.SCK);
            @(negedge `vif.SCK);
            mst_trans.left_data[i] = `vif.sd_out;
          end

        end
      join    
      count++;
      mst_trans.print("monitor data");
      if(monitor_cfg.mode_master == TX)begin 
       s_mon2scr_mbox.put(mst_trans);
      end
      else if (monitor_cfg.mode_master == RX)begin
        m_mon2scr_mbox.put(mst_trans);
      end

    end
    
    else if(monitor_cfg.ws_mode == LEFT_JUSTIFIED)begin
      if(monitor_cfg.mode_master == TX) begin
        if(monitor_cfg.slv_word_len >monitor_cfg.word_len)
        monitor_cfg.word_length=monitor_cfg.word_len;
      end
    
      if(monitor_cfg.mode_master == RX) begin
        if(monitor_cfg.word_len > monitor_cfg.slv_word_len)
          monitor_cfg.word_length=monitor_cfg.slv_word_len;
      end
      fork 
        begin
          wait(`vif.WS==1);
          
            for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
              @(`edge_clk `vif.SCK);
              @(negedge `vif.SCK);
              mst_trans.right_data[i] = `vif.sd_out;
            end         
          
            if(monitor_cfg.mode_master == TX) begin
              if(monitor_cfg.word_len > monitor_cfg.slv_word_len) begin
                diff = monitor_cfg.word_len - monitor_cfg.slv_word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
            
            if(monitor_cfg.mode_master == RX) begin
              if(monitor_cfg.slv_word_len > monitor_cfg.word_len) begin
                diff = monitor_cfg.slv_word_len - monitor_cfg.word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
        
              
            if(monitor_cfg.mode_master == TX) begin
              if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
                @(`edge_clk `vif.SCK);
              end
            end
            
            
            if(monitor_cfg.mode_master == RX) begin
              if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
                @(`edge_clk `vif.SCK);
              end
            end
           
        end
        
        begin
          wait(`vif.WS==0);
          if(count==0) begin
            for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
              @(`edge_clk `vif.SCK);
              @(negedge `vif.SCK);
              mst_trans.left_data[i] = `vif.sd_out;
            end
          end
          
          else if(count!=0) begin
            for(int i=monitor_cfg.word_length-1;i>=0;i--)begin
              @(negedge `vif.SCK);
              mst_trans.left_data[i] = `vif.sd_out;
              @(`edge_clk `vif.SCK);
            end
          end
          
          if(monitor_cfg.mode_master == TX) begin
              if(monitor_cfg.config_ration > monitor_cfg.word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
            
            
            if(monitor_cfg.mode_master == RX) begin
              if(monitor_cfg.config_ration > monitor_cfg.slv_word_len) begin
                diff = monitor_cfg.config_ration - monitor_cfg.slv_word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
              end
            end
        end
      join
      count++;
     mst_trans.print("monitor data");
    if(monitor_cfg.mode_master == TX)begin 
      s_mon2scr_mbox.put(mst_trans);
    end
    else if (monitor_cfg.mode_master == RX)begin
      m_mon2scr_mbox.put(mst_trans);
    end
     
      
    end
    
  endtask:mon_stereo
  
endclass:i2s_monitor

