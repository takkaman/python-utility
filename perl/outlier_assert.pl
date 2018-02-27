#! /depot/perl-5.14.2/bin/perl -w
##!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Storable;
use CGI qw(:standard);  
use DBI;  

my $latest;
my $prev;
my $rpt_log;
my $case_path;
my $output_path;

Getopt::Long::GetOptions(
            'latest=s'  => \$latest, 
            'prev=s'  => \$prev,
            'log=s'  => \$rpt_log,
            'case_path=s' => \$case_path,
            'output_path=s' => \$output_path,
);

#chomp (my $case_info = `awk '{print \$2}' $latest`);
#chomp (my $source = `awk '{print \$4}' $latest `); 
#latest qor info  
chomp (my $cmd_l = `awk '{print \$6}' $latest`);
chomp (my $wns_l = `awk '{print \$8}' $latest`);
chomp (my $tns_l = `awk '{print \$10}' $latest`);
chomp (my $tranAvg_l = `awk '{print \$12}' $latest`);
chomp (my $mem_l = `awk '{print \$14}' $latest`);
chomp (my $cpu_l = `awk '{print \$16}' $latest`); 
chomp (my $tranCst_l = `awk '{print \$18}' $latest`);
chomp (my $tranNVP_l = `awk '{print \$20}' $latest`); 
chomp (my $bufCnt_l = `awk '{print \$22}' $latest`); 
chomp (my $bufArea_l = `awk '{print \$24}' $latest`);
chomp (my $ttlArea_l = `awk '{print \$26}' $latest`); 
chomp (my $hfn60_l = `awk '{print \$28}' $latest`);
chomp (my $hfn100_l = `awk '{print \$29}' $latest`); 
chomp (my $bufrmv_l = `awk '{print \$31}' $latest`); 
      
#prev qor info
chomp (my $cmd_p = `awk '{print \$6}' $prev`);
chomp (my $wns_p = `awk '{print \$8}' $prev`);
chomp (my $tns_p = `awk '{print \$10}' $prev`);
chomp (my $tranAvg_p = `awk '{print \$12}' $prev`);
chomp (my $mem_p = `awk '{print \$14}' $prev`);
chomp (my $cpu_p = `awk '{print \$16}' $prev`); 
chomp (my $tranCst_p = `awk '{print \$18}' $prev`);
chomp (my $tranNVP_p = `awk '{print \$20}' $prev`); 
chomp (my $bufCnt_p = `awk '{print \$22}' $prev`); 
chomp (my $bufArea_p = `awk '{print \$24}' $prev`);
chomp (my $ttlArea_p = `awk '{print \$26}' $prev`); 
chomp (my $hfn60_p = `awk '{print \$28}' $prev`);
chomp (my $hfn100_p = `awk '{print \$29}' $prev`); 
chomp (my $bufrmv_p = `awk '{print \$31}' $prev`); 

my $wns_ol = "no_outlier";
my $tns_ol = "no_outlier";
my $tranAvg_ol = "no_outlier";
my $mem_ol = "no_outlier";
my $cpu_ol = "no_outlier";
my $tranCst_ol = "no_outlier";
my $tranNVP_ol = "no_outlier";
my $bufCnt_ol = "no_outlier";
my $bufArea_ol = "no_outlier";
my $ttlArea_ol = "no_outlier";
my $hfn60_ol = "no_outlier";
my $hfn100_ol = "no_outlier";
my $bufRmvl_ol = "no_outlier";

print "latest: $cmd_l, $wns_l, $tns_l, $tranAvg_l, $mem_l, $cpu_l, $tranCst_l, $tranNVP_l, $bufCnt_l, $bufArea_l, $ttlArea_l, $hfn60_l, $hfn100_l, $bufrmv_l\n";
print "prev: $cmd_p, $wns_p, $tns_p, $tranAvg_p, $mem_p, $cpu_p, $tranCst_p, $tranNVP_p, $bufCnt_p, $bufArea_p, $ttlArea_p, $hfn60_p, $hfn100_p, $bufrmv_p\n";

system("cp -rf /remote/us01home40/phyan/random_icc2/utility/checkpoint_prep checkpoint_file");
system("sed -i 's/prepare_chkp_file rpt_log place_opt case_info/prepare_chkp_file $rpt_log place_opt case_info/' checkpoint_file");
open(case_file, ">>checkpoint_file");

my $has_outlier = 0;
if (($wns_l < $wns_p*1.1) && $wns_l < 0) {
  print "outlier found in wns column... prev: $wns_p vs. latest: $wns_l\n";
  my $wns_chk = $wns_l*0.9;
#  print case_file ("set wns [exec awk {/Design.*\(Setup\)/ {print \$3}} $rpt_log]\n");
  print case_file ("aid_assert [expr \$WNS >= $wns_chk]\n");
  $has_outlier  = 1;
  $wns_ol = "has_outlier";
}

if (($tns_l < $tns_p*1.1) && $tns_l < 0) {
  print "outlier found in tns column... prev: $tns_p vs. latest: $tns_l\n";
  my $tns_chk = $tns_l*0.9;
#  print case_file ("set tns [exec awk {/Design.*\(Setup\)/ {print \$4}} $rpt_log]\n");  
  print case_file ("aid_assert [expr \$TNS >= $tns_chk]\n");
  $has_outlier  = 1;
  $tns_ol = "has_outlier";
}  

#if ($tranAvg_l > $tranAvg_p*1.1) {
#  print "outlier found in tranAvg column... prev: $tranAvg_p vs. latest: $tranAvg_l\n";
#  my $tranAvg_chk = $tranAvg_p*1.09;
#  print case_file ("set tranAvg [exec awk {/max_transition.*(MET|VIOLATED)/{print \$2}} $rpt_log]\n");  
#  print case_file ("aid_assert [expr \$tranAvg <= $tranAvg_chk]\n");
#}  

if ($mem_l > $mem_p*3) {
  print "outlier found in mem column... prev: $mem_p vs. latest: $mem_l\n";
  my $mem_chk = $mem_p*2.5;
#  print case_file ("set mem [exec awk {/Maximum mem usage for this session:/{print \$7}} $rpt_log]\n");
#  print case_file ("aid_assert [expr \$MEM <= $mem_chk]\n");  
  $has_outlier = 1; 
  $mem_ol = "has_outlier";
}  

if ($cpu_l > $cpu_p*3) {
  print "outlier found in cpu column... prev: $cpu_p vs. latest: $cpu_l\n";
  my $cpu_chk = $cpu_p*2.5;
#  print case_file ("set cpu [exec awk {/CPU usage for this session:/{print \$6}} $rpt_log]\n");  
#  print case_file ("aid_assert [expr \$CPU <= $cpu_chk]\n");  
  $has_outlier  = 1; 
  $cpu_ol = "has_outlier"; 
}  

if ($tranCst_l > $tranCst_p*1.1) {
  print "outlier found in tranCst column... prev: $tranCst_p vs. latest: $tranCst_l\n";
  my $tranCst_chk = $tranCst_l*0.9;
#  print case_file ("set tranCst [exec awk {/max_transition.*(MET|VIOLATED)/{print \$2}} $rpt_log]\n");  
  print case_file ("aid_assert [expr \$TranCost <= $tranCst_chk]\n");
  $has_outlier = 1; 
  $tranCst_ol = "has_outlier";
}  

if ($tranNVP_l > $tranNVP_p*1.1) {
  print "outlier found in tranNVP column... prev: $tranNVP_p vs. latest: $tranNVP_l\n";
  my $tranNVP_chk = $tranNVP_l*0.9;
#  print case_file ("set tranNVP [exec awk {/Max Trans Violations:/{print \$4}} $rpt_log]\n");  
  print case_file ("aid_assert [expr \$TranNVP <= $tranNVP_chk]\n");
  $has_outlier = 1;  
  $tranNVP_ol = "has_outlier";
}  

if ($bufCnt_l > $bufCnt_p*1.1) {
  print "outlier found in bufCnt column... prev: $bufCnt_p vs. latest: $bufCnt_l\n";
  my $bufCnt_chk = $bufCnt_l*0.9;
#  print case_file ("set bufCnt [exec awk {/^Buf\\/Inv Cell Count:/ {print \$4}} $rpt_log]\n");  
  print case_file ("aid_assert [expr \$BufCnt <= $bufCnt_chk]\n");
  $has_outlier  = 1;  
  $bufCnt_ol = "has_outlier";
}  

if ($bufArea_l > $bufArea_p*1.1) {
  print "outlier found in bufArea column... prev: $bufArea_p vs. latest: $bufArea_l\n";
  my $bufArea_chk = $bufArea_l*0.9;
#  print case_file ("set bufArea [exec awk {/^Buf\\/Inv Area:/ {print \$3}} $rpt_log]\n");  
  print case_file ("aid_assert [expr \$BufArea <= $bufArea_chk]\n");
  $has_outlier = 1;  
  $bufArea_ol = "has_outlier";
}  


if ($ttlArea_l > $ttlArea_p*1.1) {
  print "outlier found in ttlArea column... prev: $ttlArea_p vs. latest: $ttlArea_l\n";
  my $ttlArea_chk = $ttlArea_l*0.9;
#  print case_file ("set ttlArea [exec awk {/^Cell Area \\(netlist and physical only\\):/ {v=\$7} END {print v}} $rpt_log]\n");  
  print case_file ("aid_assert [expr \$TotalArea <= $ttlArea_chk]\n");
  $has_outlier = 1;  
  $ttlArea_ol = "has_outlier";
}  

if ($hfn60_l > $hfn60_p*1.1) {
  print "outlier found in hfn60 column... prev: $hfn60_p vs. latest: $hfn60_l\n";
  my $hfn60_chk = $hfn60_l*0.9;
#  print case_file ("set hfn_60 [get_hfn_count 60 count]\n");
  print case_file ("aid_assert [expr \$HFN_60 <= $hfn60_chk]\n");
  $has_outlier = 1;  
  $hfn60_ol = "has_outlier";

}  
       
if ($hfn100_l > $hfn100_p*1.1) {
  print "outlier found in hfn100 column... prev: $hfn100_p vs. latest: $hfn100_l\n";
  my $hfn100_chk = $hfn100_l*0.9;
#  print case_file ("set hfn_100 [exec awk {/^Cell Area \\(netlist and physical only\\):/ {v=\$7} END {print v}} $rpt_log]\n");
  print case_file ("aid_assert [expr \$HFN_100 <= $hfn100_chk]\n"); 
  $has_outlier = 1; 
  $hfn100_ol = "has_outlier";

}  
    
close(case_file);

#####################
# outlier summary
#####################
chomp(my $case_name = `basename $case_path`); 

if (1) {
  if ($has_outlier) {
    open(outlier_file, ">>$output_path/outlier_list"); 
    print outlier_file ("<tr>\n");
    print outlier_file ("<th rowspan=\"2\" class=\"case\">$case_name</td>\n");
    print outlier_file ("<th>Compare</th>\n");
    print outlier_file ("<td class=\"$wns_ol\" title=\"WNS\">$wns_l</td>\n");
    print outlier_file ("<td class=\"$tns_ol\" title=\"TNS\">$tns_l</td>\n");
    print outlier_file ("<td class=\"$tranAvg_ol\" title=\"TranAvg\">$tranAvg_l</td>\n");
    print outlier_file ("<td class=\"$mem_ol\" title=\"MEM\">$mem_l</td>\n");
    print outlier_file ("<td class=\"$cpu_ol\" title=\"CPU\">$cpu_l</td>\n");
    print outlier_file ("<td class=\"$tranCst_ol\" title=\"TranCst\">$tranCst_l</td>\n");
    print outlier_file ("<td class=\"$tranNVP_ol\" title=\"TranNVP\">$tranNVP_l</td>\n");
    print outlier_file ("<td class=\"$bufCnt_ol\" title=\"BufCnt\">$bufCnt_l</td>\n");
    print outlier_file ("<td class=\"$bufArea_ol\" title=\"BufArea\">$bufArea_l</td>\n");
    print outlier_file ("<td class=\"$ttlArea_ol\" title=\"TotalArea\">$ttlArea_l</td>\n");
    print outlier_file ("<td class=\"$hfn60_ol\" title=\"HFN_60\">$hfn60_l</td>\n");
    print outlier_file ("<td class=\"$hfn100_ol\" title=\"HFN_100\">$hfn100_l</td>\n");
    print outlier_file ("<td class=\"$bufRmvl_ol\" title=\"BufRmvl\">$bufrmv_l</td>\n");
    print outlier_file ("</tr>\n");

    print outlier_file ("<tr>\n");
#    print outlier_file ("<td rowspan=\"2\">$case_path<\\td>\n");
    print outlier_file ("<th>base</th>\n"); 
    print outlier_file ("<td title=\"WNS\">$wns_p</td>\n");
    print outlier_file ("<td title=\"TNS\">$tns_p</td>\n");
    print outlier_file ("<td title=\"TranAvg\">$tranAvg_p</td>\n");
    print outlier_file ("<td title=\"MEM\">$mem_p</td>\n");
    print outlier_file ("<td title=\"CPU\">$cpu_p</td>\n");
    print outlier_file ("<td title=\"TranCst\">$tranCst_p</td>\n");
    print outlier_file ("<td title=\"TranNVP\">$tranNVP_p</td>\n");
    print outlier_file ("<td title=\"BufCnt\">$bufCnt_p</td>\n");
    print outlier_file ("<td title=\"BufArea\">$bufArea_p</td>\n");
    print outlier_file ("<td title=\"TotalArea\">$ttlArea_p</td>\n");
    print outlier_file ("<td title=\"HFN_60\">$hfn60_p</td>\n");
    print outlier_file ("<td title=\"HFN_100\">$hfn100_p</td>\n");
    print outlier_file ("<td title=\"BufRmvl\">$bufrmv_p</td>\n");
    print outlier_file ("</tr>\n");
    close(outlier_file); 
  }
}

