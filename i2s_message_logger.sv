

//---verbocity level define macro---//  

`define verbo_lev "LOW"

`define print_info(class_name, type_ver = "display", message,arg_val,verbo_lev = `verbo_lev) \
if(type_ver == "display" && verbo_lev == "LOW")\
  $display("time[%0t]\t%0s\t%0d\tMassage_log_type : %0s\tClass_name : %0s",$time,message,arg_val,type_ver,class_name);\
if(type_ver == "info" && verbo_lev == "LOW")\
  $display("time[%0t]\t %0s\tMassage_log_type : %0s\tClass_name : %0s",$time,message,type_ver,class_name);\
if(type_ver == "error" && verbo_lev == "LOW")\
  $error("time[%0t] %0s\tMassage_log_type : %0s\tClass_name : %0s",$time,message,type_ver,class_name);\
if(type_ver == "warning" && verbo_lev == "LOW")\
  $warning("time[%0t]\t%0s\tMassage_log_type : %0s\tClass_name : %0s",$time,message,type_ver,class_name);\
if(type_ver == "fatal" && verbo_lev == "LOW")\
  $fatal(0,"%0s",message);\
if(type_ver == "error" && verbo_lev == "MID") \
  $error("time[%0t]\t%0s\tMassage_log_type : %0s\tClass_name : %0s",$time,message,type_ver,class_name); \
if(type_ver == "warning" && verbo_lev == "MID") \
  $warning("time[%0t]\t%0s\tMassage_log_type : %0s\tClass_name : %0s",$time,message,type_ver,class_name); \
if(type_ver == "fatal" && verbo_lev == "MID") \
  $fatal(0,"%0s",message);\
if(type_ver == "fatal" && verbo_lev == "HIGH") \
  $fatal(0,"%0s",message);\



class i2s_msg_logger;
  
//---static variable for count error and warning---//  
  static shortint error_count;
  static shortint warning_count;
  
//---static function for use outside of class as well---// 
  
//---for count error---//  
  static function void error_c();
//---max count of error 10 then stop simulation----//    
    if(error_count==10)begin
      `print_info("i2s_msg_logger","display","-----Maximum count of error reaches 10-----",error_count,`verbo_lev);
      $stop();
    end
    error_count++;
  endfunction
  
//---for count warning---//  
  static function void warning_c();
    warning_count++;
  endfunction
  
//----for display total no of error and warning---//  
  static function void error_display();
    `print_info("i2s_msg_logger","display","-----Error Reporting-----",error_count,`verbo_lev);
    `print_info("i2s_msg_logger","display","----Warning Reporting----",warning_count,`verbo_lev);
  endfunction

endclass:i2s_msg_logger