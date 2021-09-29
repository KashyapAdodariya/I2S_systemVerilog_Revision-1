

/* Revision: 2
-------------------------------------------------------------------------------*/

`define vif intf.slave_drv_mp

/*-----------------------------I2S Slave Driver------------------------------*/
class i2s_slave_driver;
  
  //INTERFACE DEFINE
  virtual i2s_intf intf;
  
  i2s_transaction pkt,pkt1,pktQ[$]; 
  
  //Config handle
  i2s_config slave_cfg;
  
  //MAILBOX GENERATOR TO DRIVER
  mailbox gen2driv_mbox;
  
  //MAILBOX DRIVER TO SCB
  mailbox s_driv2scr_mbox;
  
  //CONNECTING MAILBOX
  function new(virtual i2s_intf intf, mailbox gen_mbox, mailbox driv_mbox, i2s_config slave_cfg);
    this.gen2driv_mbox = gen_mbox;
    this.s_driv2scr_mbox = driv_mbox;
    this.intf = intf;
    this.slave_cfg = slave_cfg;
  endfunction:new
  
  /*---------------------------Declare ALL Slave Driver Tasks------------------------------*/
  extern task run();
  extern task run_tx_right();
  extern task run_tx_left();
  extern task send_data_left();
  extern task send_data_right();
    
endclass:i2s_slave_driver
    
 
  /////////////////////////////////////////////////////////////////
  // Method name        : task run_rx();
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : drive WS in rx mode. run only in posedge
  /////////////////////////////////////////////////////////////////
    
  task i2s_slave_driver::run;
    `print_info("i2s_slave_driver","info","\t\t\tSLAVE DRIVER RUNING\t\t\t",0,`verbo_lev);
    repeat(slave_cfg.repeat_gen) begin
      
      //Get the packet from mailbox
      gen2driv_mbox.get(pkt1);
      //put packet into queue
      pktQ.push_back(pkt1);  
      //put packet into driver to scr mailbox
      s_driv2scr_mbox.put(pkt1);
      
      if(slave_cfg.mode_slave == TX) begin
        pkt = pktQ.pop_front();
        
        if(slave_cfg.ws_mode == RIGHT_JUSTIFIED) begin
          run_tx_right();  
        end        
        else if (slave_cfg.ws_mode == LEFT_JUSTIFIED) begin
          run_tx_left(); 
        end
      
      end     
    end
    
  endtask:run
 
    
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // Method name        : task run_tx_right
  // Parameter Passed   : none
  // Returned parameter : none
  // Description        : used in right justified send data based on word length and ration 
  //////////////////////////////////////////////////////////////////////////////////////////////////////
    
  task i2s_slave_driver::run_tx_right;
   static int count;
    
    //STEREO MODE
    if(slave_cfg.chnl_mode == STEREO) begin
      
      //config ration is lesser or equeal to slave word len based on SCK right and left channel data sent
       if(slave_cfg.config_ration <= slave_cfg.slv_word_len) begin
         if(count==0) begin
           @(`edge_clk `vif.SCK);
           send_data_left();       
           send_data_right();   
           count++;
         end
          
          else if(count!=0) begin 
            send_data_left();       
            send_data_right(); 
          end
          
        end
      
      //config ration is greater than slave word len append zero before data sent
      else if(slave_cfg.config_ration > slave_cfg.slv_word_len) begin
        if(count==0) begin
           @(`edge_clk `vif.SCK);
           
           for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
             @(`edge_clk `vif.SCK);
           `  vif.slave_drv_cb.sd_out <= 1'b0;
           end
           send_data_left();  
          
           for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
             @(`edge_clk `vif.SCK);
           `  vif.slave_drv_cb.sd_out <= 1'b0;
           end
          
           send_data_right(); 
   
           count++;
         end
         
         else if(count!=0) begin
           
           for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
             @(`edge_clk `vif.SCK);
           `  vif.slave_drv_cb.sd_out <= 1'b0;
           end
           send_data_left();  
          
           for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
             @(`edge_clk `vif.SCK);
           `  vif.slave_drv_cb.sd_out <= 1'b0;
           end
          
           send_data_right(); 
   
           count++;
         end      
      end
        
    end
  
    //MONO_RIGHT MODE
    else if(slave_cfg.chnl_mode == MONO_RIGHT) begin
      
      repeat(2) begin
        //config ration is lesser or equeal to slave word len based on SCK right and left channel data sent
      	if(slave_cfg.config_ration <= slave_cfg.slv_word_len) begin
      	  if(count==0) begin
            @(`edge_clk `vif.SCK);   
      	    send_data_right();   
      	    count++;
      	  end
      	   else if(count!=0) begin ;       
      	     send_data_right(); 
      	   end   
      	end
    
        //config ration is greater than slave word len append zero before data sent
    	else if(slave_cfg.config_ration > slave_cfg.slv_word_len) begin
      	  
      	  if(count==0) begin
      	    for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin          
              @(`edge_clk `vif.SCK);
      	      `vif.slave_drv_cb.sd_out <= 1'b0;
      	    end
            
            @(`edge_clk `vif.SCK);
      	    send_data_right();
            count++;
          end
         else if(count!=0) begin 
      	   for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin          
              @(`edge_clk `vif.SCK);
      	      `vif.slave_drv_cb.sd_out <= 1'b0;
      	    end
      	    send_data_right();
    	  end
      	 
    	end
      end
    end
   
    //MONO_LEFT MODE
    else if(slave_cfg.chnl_mode == MONO_LEFT) begin
      repeat(2) begin
        
        //config ration is lesser or equeal to slave word len based on SCK right and left channel data sent
      	if(slave_cfg.config_ration <= slave_cfg.slv_word_len) begin  
      	  if(count==0) begin
            @(`edge_clk `vif.SCK);      
      	    send_data_left();   
      	    count++;
      	  end
      	   else if(count!=0) begin      
      	     send_data_left(); 
      	   end         
      	end
     	
        //config ration is greater than slave word len append zero before data sent
      	else if(slave_cfg.config_ration > slave_cfg.slv_word_len) begin
      	 
      	  if(count==0) begin
      	    for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin          
              @(`edge_clk `vif.SCK);
      	      `vif.slave_drv_cb.sd_out <= 1'b0;
      	    end
            
            @(`edge_clk `vif.SCK);
      	    send_data_left();
            count++;
          end
          else if(count!=0) begin 
      	   for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin          
              @(`edge_clk `vif.SCK);
      	      `vif.slave_drv_cb.sd_out <= 1'b0;
      	    end
      	    send_data_left();
    	  end 
     	
      	end
      end
    end
  endtask:run_tx_right
    
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // Method name        : task run_tx_left
  // Parameter Passed   : none
  // Returned parameter : none
  // Description        : used in left justified send data based on word length and ration 
  //////////////////////////////////////////////////////////////////////////////////////////////////////
    
  task i2s_slave_driver::run_tx_left;
   
    static int count;
    //STEREO Mode
    if(slave_cfg.chnl_mode == STEREO) begin
      
      //config ration is lesser or equeal to slave word len based on SCK right and left channel data sent
      if(slave_cfg.config_ration <= slave_cfg.slv_word_len) begin  
        if(count==0) begin
          @(`edge_clk `vif.SCK);
          send_data_left();       
          send_data_right();   
          count++;
        end
         else if(count!=0) begin 
           send_data_left();       
           send_data_right(); 
         end
      end
      
      //config ration is greater than slave word len append zero after data sent
      else if(slave_cfg.config_ration > slave_cfg.slv_word_len) begin    
        if(count==0) begin
          @(`edge_clk `vif.SCK);
          send_data_left();  
          
          for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
            @(`edge_clk `vif.SCK);
          `  vif.slave_drv_cb.sd_out <= 1'b0;
          end
          
          send_data_right(); 
          
          for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
            @(`edge_clk `vif.SCK);
            `vif.slave_drv_cb.sd_out <= 1'b0;
          end
          count++;
        end
        
        else if(count!=0) begin 
          
          send_data_left();  
          
          for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
            @(`edge_clk `vif.SCK);
            `vif.slave_drv_cb.sd_out <= 1'b0;
          end
          
          send_data_right(); 
          for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
            @(`edge_clk `vif.SCK);
          `  vif.slave_drv_cb.sd_out <= 1'b0;
          end
          
        end
      end
        
    end
    
    //MONO_RIGHT Mode
    else if(slave_cfg.chnl_mode == MONO_RIGHT) begin
      repeat(2) begin
        
        //config ration is lesser or equeal to slave word len based on SCK right and left channel data sent
      	if(slave_cfg.config_ration <= slave_cfg.slv_word_len) begin    
      	  if(count==0) begin
            @(`edge_clk `vif.SCK);      
      	    send_data_right();   
      	    count++;
      	  end
      	   else if(count!=0) begin      
      	     send_data_right(); 
      	   end      
      	end
      	
        //config ration is greater than slave word len append zero after data sent
      	else if(slave_cfg.config_ration > slave_cfg.slv_word_len) begin   
      	  if(count==0) begin
            @(`edge_clk `vif.SCK);      
      	    send_data_right();   
      	    count++;
      	  end
      	   else if(count!=0) begin      
      	     send_data_right(); 
      	   end   
      	  
      	  for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
            @(`edge_clk `vif.SCK);
      	    `vif.slave_drv_cb.sd_out <= 1'b0;
      	  end    
      	end
      end
       
    end
   
    //MONO_LEFT Mode
    else if(slave_cfg.chnl_mode == MONO_LEFT) begin
      repeat(2) begin
        
        //config ration is lesser or equeal to slave word len based on SCK right and left channel data sent
        if(slave_cfg.config_ration <= slave_cfg.slv_word_len) begin        
          if(count==0) begin
            @(`edge_clk `vif.SCK); 
            send_data_left();   
            count++;
          end
          
           else if(count!=0) begin 
             send_data_left(); 
           end
        
        end
        
        //config ration is greater than slave word len append zero after data sent
        else if(slave_cfg.config_ration > slave_cfg.slv_word_len) begin   
          if(count==0) begin
            @(`edge_clk `vif.SCK);      
            send_data_left();   
            count++;
          end
           else if(count!=0) begin      
             send_data_left(); 
           end          
        
          for(int j=1; j<=slave_cfg.config_ration - slave_cfg.slv_word_len ; j++) begin
            @(`edge_clk `vif.SCK);
            `vif.slave_drv_cb.sd_out <= 1'b0;
          end
        end
      end
     
    end
  endtask:run_tx_left
  
  /////////////////////////////////////////////////////////////////
  // Method name        : task send_data_left();
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : Task for send data in left channel
  /////////////////////////////////////////////////////////////////
    
  task i2s_slave_driver::send_data_left;
    
    for(int i=1; i <= slave_cfg.slv_word_len; i++) begin
      @(`edge_clk `vif.SCK);
      `vif.slave_drv_cb.sd_out <= pkt.left_data [slave_cfg.slv_word_len - i];
    end
    
  endtask:send_data_left
    
  /////////////////////////////////////////////////////////////////
  // Method name        : task send_data_right();
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : Task for send data in right channel
  /////////////////////////////////////////////////////////////////
  
  task i2s_slave_driver::send_data_right;
    
     for(int i=1; i <= slave_cfg.slv_word_len; i++) begin
       @(`edge_clk `vif.SCK);
       `vif.slave_drv_cb.sd_out <= pkt.right_data [slave_cfg.slv_word_len - i];
     end
    
  endtask:send_data_right
