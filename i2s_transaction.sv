

class i2s_transaction #(parameter word_size = `size);
//---config handle---//  
  i2s_config cfg;
//---for define which type of packet tranmitted or received---//  
  pkt_type_e pkt_type;
//---right and left data---//  
  rand  bit [word_size-1:0] right_data;
  rand  bit [word_size-1:0] left_data; 
//---unique id and count---//  
  int UID;
  static int count;
  
////////////////////////////---New constructor---///////////////////////////////////
  function new(i2s_config cfg,pkt_type_e pkt_type=PKT_TX);
    UID=count;
    count++;
    this.cfg=cfg;
    this.pkt_type=pkt_type;
  endfunction:new

//////////////////////////////---Methods---////////////////////////////////////////
  extern function void print(string str = "Transaction Class");
  extern function i2s_transaction copy(i2s_transaction tr);
  extern function bit compare(i2s_transaction tr);
  extern function void pre_randomize();  
  extern function void post_randomize();

endclass:i2s_transaction

////////////////////////////////////////////////////////////////////////////////////
// Method name        : print()
// Parameter Passed   : String str = "Transaction Class"bydefault value 
// Returned parameter : None
// Description        : Display property of i2s_transaction Class
////////////////////////////////////////////////////////////////////////////////////

  function void i2s_transaction::print(string str = "Transaction Class");
    string print_trans;
    print_trans=$psprintf(
     "\t\t%0s\t\t\n",str,
     "Packet_Type =%0s\n",this.pkt_type,
     "UID         =%0d\n",this.UID,
     "Left_data   =%h\n",this.left_data,
     "Right_data  =%h\n",this.right_data,
     "===========================================================================================\n");
    `print_info("i2s_transaction","info",print_trans,0,`verbo_lev);
  endfunction:print
  
/////////////////////////////////////////////////////////////////////////////////////
// Method name        : copy()
// Parameter Passed   : ref of i2s_transaction class handle 
// Returned parameter : i2s_transaction class handle
// Description        : for copying property of i2s_transaction Class
/////////////////////////////////////////////////////////////////////////////////////
  
  function i2s_transaction i2s_transaction::copy(i2s_transaction tr);
 //---for null object---//   
    if(tr==null)begin
      `print_info("i2s_transaction","warning","-----i2s_transaction class copy into NULL object-----",0,`verbo_lev);
      i2s_msg_logger::warning_c();
      tr=new(cfg,PKT_TX);
    end
    tr.right_data=this.right_data;
    tr.left_data=this.left_data;
  endfunction:copy
  
//////////////////////////////////////////////////////////////////////////////////////
// Method name        : compare()
// Parameter Passed   : i2s_transaction class handle 
// Returned parameter : bit datatype variable
// Description        : for compare property of two i2s_transaction Class handle
//////////////////////////////////////////////////////////////////////////////////////
  
  function bit i2s_transaction::compare(i2s_transaction tr);
    bit comp_res=1;
//---for null object---//    
    if(tr==null)begin
      `print_info("i2s_transaction","warning","-----Null packet try to compare with class packet-----",0,`verbo_lev);
      i2s_msg_logger::warning_c();
      comp_res=0;
    end
    
    else begin
      if(tr.right_data != this.right_data)begin
        `print_info("i2s_transaction","info","-----right_data channel data is not match-----",0,`verbo_lev);
        comp_res=0;
      end
      if(tr.left_data != this.left_data)begin
        `print_info("i2s_transaction","info","------left_data channel data is not match-------",0,`verbo_lev);
      comp_res=0;
      end
    end
    return comp_res;
  endfunction:compare
    
//////////////////////////////////////////////////////////////////////////////////////
// Method name        : pre_randomize()
// Parameter Passed   : None 
// Returned parameter : None
// Description        : Based on channel mode enable and disable randomization mode
//////////////////////////////////////////////////////////////////////////////////////  
    
  function void i2s_transaction::pre_randomize();
//---for MONO_RIGHT---//    
    if(cfg.chnl_mode==MONO_RIGHT)begin:mod_0
      left_data.rand_mode(0);
      right_data.rand_mode(1);
    end:mod_0
//---for MONO_LEFT---//    
    else if(cfg.chnl_mode==MONO_LEFT)begin:mod_1
      right_data.rand_mode(0);
      left_data.rand_mode(1);
    end:mod_1
//---for STEREO---//    
    else if(cfg.chnl_mode==STEREO)begin:mod_2
      right_data.rand_mode(1);
      left_data.rand_mode(1); 
    end:mod_2
//---for other option---//    
    else begin:err
      `print_info("i2s_transaction","error","------Please select valid channel mode------",0,`verbo_lev);
      i2s_msg_logger::error_c();
    end:err
  endfunction:pre_randomize
  
  
//////////////////////////////////////////////////////////////////////////////////////
// Method name        : post_randomize()
// Parameter Passed   : None 
// Returned parameter : None
// Description        : Based on data transfer mode post process on data
//////////////////////////////////////////////////////////////////////////////////////
  
  function void i2s_transaction::post_randomize();
    
//---for NORMAL---//    
    if(cfg.complement==NORMAL)begin:normal
      `print_info("i2s_transaction","info","\tNormal Data Transfer\t",0,`verbo_lev);
    end:normal
    
//---for ONES_COMPL---//    
    else if(cfg.complement==ONES_COMPL)begin:ones
      `print_info("i2s_transaction","info","\tONES Complement Data Transfer\t",0,`verbo_lev);
      if(cfg.chnl_mode==STEREO)begin
       right_data=~right_data;
       left_data=~left_data;
      end
      else if(cfg.chnl_mode==MONO_RIGHT)begin
        right_data=~right_data;
      end
      else begin
        left_data=~left_data;
      end
    end:ones
    
//---for TWOS_COMPL---//    
    else if(cfg.complement==TWOS_COMPL)begin:twos
      `print_info("i2s_transaction","info","\tTWOS Complement Data Transfer\t",0,`verbo_lev);
      if(cfg.chnl_mode==STEREO)begin
       right_data=~right_data+1;
       left_data=~left_data+1;
      end
      else if(cfg.chnl_mode==MONO_RIGHT)begin
        right_data=~right_data+1;
      end
      else begin
        left_data=~left_data+1;
      end
    end:twos
    
//---for other option---//    
    else begin:fail
      `print_info("i2s_transaction","error","-----Please select valid Data transfer mode-------",0,`verbo_lev);
      i2s_msg_logger::error_c();
    end:fail
      
  endfunction:post_randomize