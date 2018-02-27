#! /depot/perl-5.14.2/bin/perl -w
##!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Storable;
use CGI qw(:standard);  
use DBI;  

my $latest_b;
my $prev_b;
my $case_list;
my $start_id;
my $end_id;
my $branch;
my $line;
my $pwd = $ENV{PWD};
my $output_path;

Getopt::Long::GetOptions(
            'latest_b=s'  => \$latest_b, 
            'prev_b=s'  => \$prev_b,
            'branch=s' => \$branch,
            'case_list=s' => \$case_list,
            'output_path=s' => \$output_path,
);

if ($latest_b =~ /.*D.*_(\d+)\/Testing.*exec/) {
 $end_id = $1;
}

if ($prev_b =~ /.*D.*_(\d+)\/Testing.*exec/) {
 $start_id = $1;
}

open (MYFILE, "$case_list") || die ("Could not open file");
my @lines = <MYFILE>;
close(MYFILE);

my @culprit_list;
my $no_culprit_id = -1;
open(case_file, ">$output_path/case_list_w_culprit");

foreach my $case (@lines) {
  chomp($case);
  chomp(my $case_dir = `dirname $case`);
  chomp(my $case_name = `basename $case`);
  print $case_dir,"\n", $case_name, "\n";

  chdir $case_dir;
  system("/remote/pv/regression/utility/others/culprit_diy.pl -product ICC2 -branch $branch -base_image $start_id -current_image $end_id -test_tcl $case_name | tee culprit.run.log");
  chomp(my $culprit_result = `awk '/\\[Culprit found\\]/ {print \$0}' culprit.run.log`);
  if ($culprit_result =~ /\d+/) {
#print "$culprit_result\n";
    while ($culprit_result =~ /\s+(\d+)/mg) {   
      push @culprit_list, $1;
    }
    print case_file ("$case @culprit_list\n");
    my @case_struct = split(/\//, $case_dir);
    $case_name =~ s/_culprit//;
    push @case_struct, $case_name;
    my $flat_name = join("-", @case_struct[12..16]);
#print "case-struct: @case_struct\n"; 
    print "flattened: $flat_name\n"; 
    open(rpt_file, ">$output_path/xtpl/design-$flat_name.txt");
    foreach my $culprit_id (@culprit_list) {
      print rpt_file ("<a href=\"http://wwwin.synopsys.com/pv/regression/culprit_new/id_info.cgi?id=$culprit_id\" target=\"_blank\">$culprit_id</a> ");
    }
    close(rpt_file); 
  } else {
    print "No culprit found...\n";
    print case_file ("$case $no_culprit_id\n");
  }
  chdir $pwd;
}

close(case_file);
