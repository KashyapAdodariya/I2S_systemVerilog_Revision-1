
class i2s_master_gen;
//---seed---//  
  int unsigned seed;
//---transaction class handle---//  
  i2s_transaction tx,tx1;
//---config class handle---//  
  i2s_config cfg;
//---mailbox between generator and driver---//   
  mailbox gen2driv_mbox;
////////////////////////////---New constructor---///////////////////////////////////
  
  function new(mailbox gen2driv_mbox,i2s_config cfg);
    this.cfg=cfg;
    tx1=new(cfg);
    this.gen2driv_mbox=gen2driv_mbox;
  endfunction
  
//////////////////////////////////////////////////////////////////////////////////////
// Method name        : run()
// Parameter Passed   : None 
// Returned parameter : None
// Description        : For generate packets and drive to the driver(master,slave)
////////////////////////////////////////////////////////////////////////////////////// 
  
  task run();
    
//---run for mater=TX or slave=Tx---//    
    if(cfg.mode_master==TX || cfg.mode_slave==TX )begin:str
      `print_info("i2s_master_generator","info","\t\t\tGENERATOR RUNING\t\t\t",0,`verbo_lev);
      cfg.print("GENERATOR::Information of Configuration");
      
//---repeat loop for repeat_gen times---//      
      repeat(cfg.repeat_gen) begin:rept
        tx=new(cfg,PKT_TX);
        seed=$urandom;
        tx1.srandom(seed);
        assert(tx1.randomize)begin:sucs_1
          `print_info("i2s_master_generator","info","------Randomization successed------",0,`verbo_lev);
//---copy from tx1 to tx handle---// 
         tx1.copy(tx);
//---for master=TX---//          
         if(cfg.mode_master==TX)begin
           gen2driv_mbox.put(tx);
           tx.print("GENERATOR:MASTER");
         end
//---for slave=TX---//          
          else if(cfg.mode_slave==TX) begin
           gen2driv_mbox.put(tx);
           tx.print("GENERATOR:SLAVE");
        end
        end:sucs_1
//---for other option---//        
       else begin:sucs_0
         `print_info("i2s_master_generator","fatal","------Fatal Error::Randomization Failed------",0,`verbo_lev);
        end:sucs_0
      end:rept
  end:str
  endtask:run
endclass:i2s_master_gen