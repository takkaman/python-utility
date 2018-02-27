#! /depot/perl-5.14.2/bin/perl -w
##!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Storable;
use CGI qw(:standard);  
use DBI;  

#connect to mysql db
sub handle_error {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";
    exit; #stop the program
}

my $dbh = DBI->connect(
    "dbi:mysql:preroute_random:pvicc015",
    "user",
    "",
    {
        PrintError  => 0,
        HandleError => \&handle_error,
    }
) or handle_error(DBI->errstr);

chomp (my $check = `cat checkin_design_data | wc -w`);
if ($check < 16) {
  print "incomplete design data, skip...\n";
  exit;
}

chomp (my $case_info = `awk '{print \$2}' checkin_design_data`);
chomp (my $source = `awk '{print \$4}' checkin_design_data`);   
chomp (my $cmd = `awk '{print \$6}' checkin_design_data`);
chomp (my $wns = `awk '{print \$8}' checkin_design_data`);
chomp (my $tns = `awk '{print \$10}' checkin_design_data`);
chomp (my $max_tran_avg = `awk '{print \$12}' checkin_design_data`);
chomp (my $memory = `awk '{print \$14}' checkin_design_data`);
chomp (my $cpu = `awk '{print \$16}' checkin_design_data`); 
chomp (my $max_tran_cost = `awk '{print \$18}' checkin_design_data`);     
#chomp (my $area = `awk '{print \$20}' checkin_design_data`);

chomp(my $date = `date +%Y%m%d`);
my $case_path;
my $udc_checkin_root = "/remote/pv/DATA_CENTER/DEPOT/optimization/opt_other/qor_comp/random";
my $udc_checkin_root_1 = '\/remote\/pv\/DATA_CENTER\/DEPOT\/optimization\/opt_other\/qor_comp\/random';
my $reg_case_root = "preroute_opt/flow/qor_comp_only";

print "$case_info, $source, $cmd, $wns, $tns, $max_tran_avg, $memory, $cpu, $max_tran_cost\n";

if ($wns >= -20 && $tns >= -3000 && $memory <= 4800 && $cpu <= 3600 && $max_tran_cost <= 1000) {
  print "Design QoR is suitable for checkin...\n";

  if ($source eq "random") {
    chomp (my $folder_name = `awk '{print \$1}' design_folder`);
    print "Star design check-in for random case...\n";
    #check-in file
    print "Check in pack into UDC...\n";
    system("data_check_in.p -file ./run_1/qor_${case_info}.pack -to $udc_checkin_root/$folder_name/");
    #update case pack path to absolute path
    print "Update case for reg checkin...\n"; 
    system("sed -i 's/read_lib_package -overwrite qor.*pack/read_lib_package -overwrite $udc_checkin_root_1\\/$folder_name\\/qor_${case_info}.pack/g' ./run_1/step_${case_info}.tcl");
    system("sed -i '1i\ # Project ID% <...> ' ./run_1/step_${case_info}.tcl");
    system("sed -i '1i\ # Suite% Feature ' ./run_1/step_${case_info}.tcl");
    system("sed -i '1i\ # R&D Owner% phyan' ./run_1/step_${case_info}.tcl");  
    system("sed -i '1i\ # Case% ${reg_case_root}/${folder_name}/step_${case_info}.tcl' ./run_1/step_${case_info}.tcl");
    system("sed -i '/read_lib_package/asource \\/remote\\/pv\\/bin\\/aid.tcl\\naid_simple_check -begin' ./run_1/step_${case_info}.tcl");
    system("sed -i '/exit/iaid_simple_check' ./run_1/step_${case_info}.tcl");
    system("sed -i 's/set_host_options/#set_host_options/' ./run_1/step_${case_info}.tcl"); 
    system("sed -i '/verilog_rule_check/d' ./run_1/step_${case_info}.tcl");
    system("sed -i '/redirect.*prsrpt.tcl/a#insert_rpt_here#' ./run_1/step_${case_info}.tcl");   
    system("sed -i '/redirect.*prsrpt.tcl/d' ./run_1/step_${case_info}.tcl"); 
    
    $case_path = "Feature/${reg_case_root}/${folder_name}/step_${case_info}.tcl";
    #check-in case
    system("echo \"\${PWD}/run_1/step_${case_info}.tcl\" | tee case_list");
    system("/remote/pv/regression/utility/others/reg_submit.pl -case_list case_list -product ICC2 -branch \${PV_24x7_RELEASE} | tee ./run_1/checkin_step_${case_info}.log");

  } else {   
    $case_path = $case_info;    
  }

  print "Updating database info...\n";
  $dbh->do("INSERT INTO qor_reg_app_testcase (case_path, source, cmd, date, wns, tns, max_tran_cost, memory, cpu) VALUES ('$case_path', '$source', '$cmd', '$date', '$wns', '$tns', '$max_tran_cost', '$memory', '$cpu')");
  open(case_file, ">>/remote/us01home40/phyan/random_icc2/utility/check_in_design_list");
  print case_file ("$case_path $source $cmd $date $wns $tns $max_tran_avg $memory $cpu $max_tran_cost\n"); 
  close(case_file);
  
} else {
  print "Design QoR not suitable for checkin, skip...\n";
}


