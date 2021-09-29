
// Revision: 1 

class i2s_slave_agent;
  //----mailbox for slave driver to scoreboard---//
  mailbox s_driv2scr_mbox;
  //----mailbox for master monitor to scoreboard---//
  mailbox m_mon2scr_mbox;
  //----mailbox for slave monitor to scoreboard---//
  mailbox s_mon2scr_mbox;
  //----mailbox for generator to driver---//
  mailbox gen2driv_mbox;
  //----virtual interface----//
  virtual i2s_intf vif;
  //----handles----//
  i2s_master_gen gen;
  i2s_slave_driver driv;
  i2s_monitor s_mon;
  i2s_config slave_cfg;
  
  //----function new---//
  function new(virtual i2s_intf vif,mailbox s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,i2s_config cfg);
    //assign formal argument to class propreties-//
    this.vif = vif;    
    this.s_driv2scr_mbox=s_driv2scr_mbox;
    this.m_mon2scr_mbox=m_mon2scr_mbox;
    this.s_mon2scr_mbox=s_mon2scr_mbox;
    slave_cfg = cfg;
    //---allocate memory--//
    gen2driv_mbox=new;
    //---allocate memory to generator, driver and monitor--//
    //---pass argument: mailbox and config_class handle--//
    if(slave_cfg.mode_slave == TX) 
      gen=new(gen2driv_mbox, slave_cfg);
    driv=new(vif,gen2driv_mbox,s_driv2scr_mbox,slave_cfg);
    s_mon=new(vif,slave_cfg,m_mon2scr_mbox,s_mon2scr_mbox);
  endfunction
  
  //----------------------------task run-----------------------//
  task run();
    `print_info("i2s_slave_agent","info","\t\t\tSLAVE AGENT RUNNING\t\t\t",0,`verbo_lev);
    fork 
      if(slave_cfg.mode_slave == TX)  
        gen.run();
      driv.run();
      if(slave_cfg.mode_master == TX) 
       s_mon.run();
    join
  endtask
  
endclass:i2s_slave_agent