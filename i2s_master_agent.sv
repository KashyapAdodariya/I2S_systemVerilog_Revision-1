

// Revision: 1 

  
class i2s_master_agent;
  
  //mailbox for generater to driver
  mailbox gen2driv_mbox;
  //mailbox for master driver to scoreboard
  mailbox m_driv2scr_mbox;
  //mailbox for master monitor to scoreboard
  mailbox m_mon2scr_mbox;
  //mailbox for slave monitor to scoreboard 
  mailbox s_mon2scr_mbox;
  //generater handle
  i2s_master_gen gen;
  //driver handle
  i2s_master_driver driv;
  //monitor handle
  i2s_monitor m_mon;
  //virtual interface handle
  virtual i2s_intf vif;
  //config class handle
  i2s_config master_cfg;
  
  function new(virtual i2s_intf vif,mailbox m_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,i2s_config cfg);
    //assign formal argument to class propreties
    this.vif = vif;
    master_cfg=cfg;
    this.m_driv2scr_mbox =m_driv2scr_mbox;
    this.m_mon2scr_mbox=m_mon2scr_mbox;
    this.s_mon2scr_mbox=s_mon2scr_mbox;
    //allocate memory to mailbox
    gen2driv_mbox=new;
    //allocate memory to generator, driver and monitor
    //pass argument: mailbox and config_class handle
    if(master_cfg.mode_master == TX) 
      gen=new(gen2driv_mbox, master_cfg);
    driv=new(vif,gen2driv_mbox,m_driv2scr_mbox,master_cfg); 
    m_mon=new(vif,master_cfg,m_mon2scr_mbox,s_mon2scr_mbox);
  endfunction

  task run();
    `print_info("i2s_master_agent","info","\t\t\tMASTER AGENT RUNNING\t\t\t",0,`verbo_lev);
    //run parellel generater, driver and monitor 
    fork 
      if(master_cfg.mode_master == TX) 
        //call generater run method
        gen.run();
        //call driver run method
      driv.run();
      if(master_cfg.mode_slave == TX)
        //monitor run method
        m_mon.run();
    join
  endtask
  
endclass:i2s_master_agent