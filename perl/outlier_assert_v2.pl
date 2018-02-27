#! /depot/perl-5.14.2/bin/perl -w
##!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Storable;
use CGI qw(:standard);  
use DBI;  
use Switch;
use Math::BigFloat;

my $rpt_dir;
my $run_dir;

Getopt::Long::GetOptions(
            'rpt_dir=s'  => \$rpt_dir, 
            'run_dir=s'  => \$run_dir,
);

my $pwd = $ENV{PWD};

###################
# split tsv
################### 
`awk '/^ICP/ {print \$0}' $rpt_dir/../html/outlier.tsv | tee $rpt_dir/../html/outlier_icp.tsv`;
`awk '/^ICC/ {print \$0}' $rpt_dir/../html/outlier.tsv | tee $rpt_dir/../html/outlier_icc.tsv`;
`awk '/^ICF/ {print \$0}' $rpt_dir/../html/outlier.tsv | tee $rpt_dir/../html/outlier_icf.tsv`;

###################
# handling cfg
###################
print "Translating propts.cfg for outlier cfg...\n";
open(FILE, "$rpt_dir/../propts.cfg")||die"cannot open the file: $!\n";
my @linelist=<FILE>;
my %outlier_cfg;
my %outlier_cfg_icp;
my %outlier_cfg_icc;
my %outlier_cfg_icf;

my $key;
my $value;
foreach my $eachline (@linelist) {
    print $eachline;
    if ($eachline =~ /::\s+html\/(\S+)\s+(\d+)/) {
      $key = $1;
      $value = $2;
      print "$key, $value\n";
      switch ($key) {
        case /ICF/ {$outlier_cfg_icf{"$key"} = $value;}
        case /ICC/ {$outlier_cfg_icc{"$key"} = $value;} 
        case /ICP/ {$outlier_cfg_icp{"$key"} = $value;} 
      }
#print "$1, $2, \n";
    }
}
#print %outlier_cfg_icc; 
foreach $key (sort keys %outlier_cfg_icf) {
  print "$key\n";
}
close FILE;

###################
# Judge outlier
# case by case
################### 
open(culprit_case_list, ">culprit_case_list");
opendir(DIR, "$rpt_dir") or die "Could not open dir, $!";
while (my $file = readdir DIR)
{
  if ($file =~ /^\.+/) {
    print "skip special dir: $file\n";
    next;
  }

  print "Processing dir: $file\n";
#  print "Transfer rpt_dir name to run_dir format...\n";
  my @case_struct = split("-", $file);
  my $case_name = "$case_struct[-2].tcl";
  my $sub_cmd = $case_struct[-1];
  my $sub_case = $sub_cmd; #popt_n
  if ($sub_cmd =~ /(\S+)_\d+/) { 
    $sub_cmd = $1;     #popt copt ropt refopt etc
  }
  print "sub cmd is: $sub_cmd\n";
  my $sub_case_name = "$sub_cmd.tcl";
  my $dir_depth = $#case_struct - 1;
  my $run_case_dir = join("/", @case_struct[0..$dir_depth]).".tcl";
  print "case info: $case_name, $sub_case_name, $run_case_dir\n"; 
#  print "Run struct is: $case_struct\n";
  my $case_path = "$run_case_dir/tmp_test/run_dir_$case_name/run/test_$sub_case";
  print "case path: $case_path\n";
  chdir "$run_dir/$case_path";
#  system("cp -rf /remote/us01home40/phyan/random_icc2/utility/checkpoint_prep checkpoint_file_$sub_cmd");
#system("cp -rf $case_name $sub_case_name");
  my $log_surfix;
  switch ($sub_cmd) {
    case ("copt") {
      system("cp -rf /remote/us01home40/phyan/qor_regression/utility/checkpoint_prep_icc checkpoint_file_$sub_cmd");
      system("sed -i 's/prepare_chkp_file rpt_log popt case_info/prepare_chkp_file iccrpt_${sub_cmd}.out popt case_info/' checkpoint_file_$sub_cmd"); 
      $log_surfix = "icc";
      %outlier_cfg = %outlier_cfg_icc; 
    }
    case ("ropt") {
      system("cp -rf /remote/us01home40/phyan/qor_regression/utility/checkpoint_prep_icr checkpoint_file_$sub_cmd");
      system("sed -i 's/prepare_chkp_file rpt_log popt case_info/prepare_chkp_file icrpt_${sub_cmd}.out popt case_info/' checkpoint_file_$sub_cmd");
      $log_surfix = "icf";  
      %outlier_cfg = %outlier_cfg_icf; 
    }
    else {
      system("cp -rf /remote/us01home40/phyan/qor_regression/utility/checkpoint_prep_icp checkpoint_file_$sub_cmd");
      system("sed -i 's/prepare_chkp_file rpt_log popt case_info/prepare_chkp_file icprpt_${sub_cmd}.out popt case_info/' checkpoint_file_$sub_cmd");
      $log_surfix = "icp";   
      %outlier_cfg = %outlier_cfg_icp;      
    }
  }
  
  open(case_file, ">>checkpoint_file_$sub_cmd");
  foreach $key (keys %outlier_cfg) {
    my $prs_col_val = `awk '/$key.*$file/ {print \$3, \$4, \$6}' $rpt_dir/../html/outlier_${log_surfix}.tsv`;    
    if($prs_col_val =~ /(.*) \+(.*)% (.*)/) {
      my $base = $3;
      my $percent = $2;
      my $compare = $1;
#print "$key, $base, $percent, $compare\n";
      if ($percent > $outlier_cfg{$key} && $percent != 100) {
        printf ("Outlier found: $file, $key, %.2f, $percent, %.2f\n", $base, $compare);        
        my $threshold = $compare * 0.9;
        my $judge = ($compare>0?"<=":">=");
        print case_file ("aid_assert [expr \$$key $judge $threshold]\n");
      } elsif ($percent == 100) {
        open(rpt_file, ">$rpt_dir/../xtpl/outlier-html-$key-$file.txt");
        print rpt_file ("skip");
        close(rpt_file);
      }
    }
  }

  if (`wc -l < checkpoint_file_$sub_cmd` > 31) {
    print "Culprit finder needed for $sub_case_name\n";
    my $culprit_case_name = "${sub_cmd}_culprit.tcl";
#system("cp $sub_case_name $culprit_case_name"); 
#chomp(my $aid_simple_chk = `grep "aid_simple_check" $culprit_case_name | grep -v "begin" | grep -v "#"`);
#print case_file ("$aid_simple_chk\n");
    system("rm -rf tmp $culprit_case_name");
    system("echo \"aid_simple_check\" >> checkpoint_file_$sub_cmd");    
    system("echo \"exit\" >> checkpoint_file_$sub_cmd");
#system("sed -i \"/write_lib_package flow_$sub_cmd/r checkpoint_file_$sub_cmd\" $culprit_case_name");
#system("sed -i \"s/write_lib_package flow_$sub_cmd/#write_lib_package flow_$sub_cmd/\" $culprit_case_name");
#system("cat /remote/us01home24/sunna/proj_disk/NT/reg_qor/rm_all_icprpt.tcl $culprit_case_name > tmp_culprit.tcl");
    system("tac checkpoint_file_$sub_cmd > tmp");
    system("tac $sub_case_name | sed '2 r tmp' | sed 1,2d | tac > $culprit_case_name");
#system("rm -rf tmp");
#system("sed -i '$ r checkpoint_file_popt' $culprit_case_name");   
#system("mv tmp_culprit.tcl $culprit_case_name"); 
    print culprit_case_list ("$run_dir/$case_path/$culprit_case_name\n");   
  } else {
    print "No outlier found, skip culprit finder...\n";
#system("rm -rf $sub_case_name");
  }

  close(case_file);
  chdir $pwd;
}

close(culprit_case_list);

exit ;

