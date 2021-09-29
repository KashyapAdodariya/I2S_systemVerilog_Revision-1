#=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
#	* File Name          : script.pl
# 	* Title              :                                                      
#	* Created Date       : Monday 12 July 2021 07:12:50 AM
#	* Last Modified Date : Monday 12 July 2021 07:13:03 AM
#	* purpose 			 :  
#	* Author 			 : Kashyap Adodariya  
#	* Organization 		 : EITRA
# 	* Modifier 			 : Kashyap Adodariya  
# 	* Assumptions 		 :   
# 	* Limitation		 :   
# 	* Know Errors		 :  
# 	* Revision           : 
#=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:  

#!/usr/bin/perl
use strict;
use warnings;

print "SELECT EDGE TRIGGERING AT TX:\n PRESS 1) POSITIVE EDGE (write posedge)\t 2) NEGATIVE EDGE (write negedge)\t";

my $edge = <STDIN>;
chomp($edge);

print "WORD LENGTH FOR TRANSMITER: \t";
my $wlen = <STDIN>;
chomp($wlen);


print "RUN ALL TEST-CASE PRESS - 1\n";
print "RUN SPECIFIC TEST-CASE PRESS - 2\n";

my $select = <STDIN>;
chomp($select);
my $max_test_no = 27;

if($select == 1){
  print("ENTER NUMBER OF TOTAL TEST-CASE:\t");
  my $no_test = <STDIN>;
  chomp($no_test);

  my @a = (1..$no_test);
  foreach(@a){
    system("vcs -sverilog -full64 -debug_access+r +define+edge_clk=\"$edge\" +define+size=\"$wlen\" +define+test$_ i2s_testbench.sv");
    system("./simv >> i2s_log_file.log");
    # GEN_REPORT($_);
  }
}
else {
  print "1) ALTERNATE_DATA_STREAM_MONO_LEFT_MODE\n";
  print "2) ALTERNATE_DATA_STERAM_MONO_RIGHT_MODE\n";
  print "3) ALTERNATE_DATA_STERAM_STEREO_MODE\n";
  print "4) CHANGE_WORD_LEN\n";
  print "5) CONSTANT_DATA_STREAM_MONO_LEFT_MODE\n";
  print "6) CONSTANT_DATA_STREAM_MONO_RIGHT_MODE\n";
  print "7) CONSTANT_DATA_STREAM_STEREO_MODE\n";
  print "8) DATA_SYNC_WITH_WORD_LENGTH\n";
  print "9) EXTRA_BIT_MASTER_TX_MODE\n";
  print "10) ILLEGAL_WORD_LENGTH\n";
  print "11) MONO_LEFT_MODE_ONLY\n";
  print "12) MONO_RIGHT_MODE_ONLY\n";
  print "13) STEREO_MODE_ONLY\n";
  print "14) RX_WORD_LENGTH_GRETER_THEN_TX_WORD_LENGTH\n";
  print "15) MASTER_TX_AND_SLAVE_RX_WITH_WLEN_SAME\n";
  print "16) MASTER_TX_MONO_LEFT_MODE_WITH_NORMAL_DATA_TRANSFER\n";
  print "17) MASTER_TX_MONO_LEFT_MODE_WITH_NORMAL_DATA_TRANSFER\n";
  print "18) MASTER_TX_STEREO_MODE_WITH_NORMAL_DATA_TRANSFER\n";
  print "19) MASTER_TX_MONO_LEFT_MODE_WITH_TWOS_COMPLEMENT_DATA_TRANSFER\n";
  print "20) MASTER_TX_MONO_RIGHT_MODE_WITH_TWOS_COMPLEMENT_DATA_TRANSFER\n";
  print "21) MASTER_TX_STEREO_MODE_WITH_TWOS_COMPLEMENT_DATA_TRANSFER\n";
  print "22) SLAVE_TX_MONO_LEFT_MODE_WITH_TWOS_COMPLEMENT_DATA_TRANSFER\n";
  print "23) SLAVE_TX_MONO_RIGHT_MODE_WITH_TWOS_COMPLEMENT_DATA_TRANSFER\n";
  print "24) SLAVE_TX_STEREO_MODE_WITH_TWOS_COMPLEMENT_DATA_TRANSFER\n";
  print "25) SLAVE_TX_MONO_LEFT_MODE_WITH_NORMAL_DATA_TRANSFER\n";
  print "26) SLAVE_TX_MONO_RIGHT_MODE_WITH_NORMAL_DATA_TRANSFER\n";
  print "27) SLAVE_TX_STEREO_MODE_WITH_NORMAL_DATA_TRANSFER\n";
  print "\n";
  print "ENTER TESTCASE NUMBER:\t";
  my $test_no = <STDIN>;
  
  chomp($test_no);
  if($test_no <= $max_test_no){
  	system("vcs -sverilog -full64 -debug_access+r +define+edge_clk=\"$edge\" +define+size=\"$wlen\" +define+test$test_no i2s_testbench.sv");
  	system("./simv >> i2s_log_testcase_$test_no.log");
  }
  }

=for comment 

format FORMAT_EDIT = 
------------------------------------------------------------------------------
.
format FORMAT_EDIT1 = 
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
.

=cut
