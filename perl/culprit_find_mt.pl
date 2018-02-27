#! /depot/perl-5.14.2/bin/perl -w
##!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Storable;
use CGI qw(:standard);  
use DBI;  

print "Start Culprit Finder...\n";

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

my $case;
my $case_dir;
my $case_name;
my @childs;
my $sub_cmd;
#launch multi-thread for culprit run
foreach $case (@lines) {
  sleep 2;
  my $pid = fork();
  if ($pid) {
    # parent
#    print "PARENT ID: $pid\n";
    push(@childs, $pid); 
  } elsif ($pid == 0) {   
    chomp($case);
    chomp($case_dir = `dirname $case`);
    chomp($case_name = `basename $case`);
#$case_name =~ /.*_(\w+)\.tcl/;
#$sub_cmd = $1;

    print $case_dir,"\n", $case_name, "\n";

    chdir $case_dir;
#system("rm -rf $sub_cmd;mkdir $sub_cmd;cp $case_name $sub_cmd/.");
#chdir "$case_dir/$sub_cmd";
    system("/remote/pv/regression/utility/others/culprit_diy.pl -product ICC2 -branch $branch -base_image $start_id -current_image $end_id -test_tcl $case_name | tee culprit.run.log");
    sleep 2;
    chomp(my $culprit_result = `awk '/\\[Culprit found\\]/ {print \$0}' culprit.run.log`);

    my @case_struct = split(/\//, $case_dir);
#push @case_struct, $case_name;
    $case_struct[-5] =~ s/\.tcl//;
    $case_struct[-1] =~ /test_(\w+)/;
    $case_struct[-1] = $1; 
    print "$case_struct[-5], $case_struct[-1]\n";
    my $index = $#case_struct - 4;
#print "$index\n";
    my @flat_case_struct = (@case_struct[12..$index], $case_struct[-1]);
    my $flat_name = join("-", @flat_case_struct);                 
    print "flattened: $flat_name\n";
    
#open(case_file, ">>$output_path/case_list_w_culprit");
    if ($culprit_result =~ /\d+/) {
#print "$culprit_result\n";
      while ($culprit_result =~ /\s+(\d+)/mg) {   
        push @culprit_list, $1;
      }
      print case_file ("$case @culprit_list\n");

      open(rpt_file, ">$output_path/xtpl/design-$flat_name.txt");
      foreach my $culprit_id (@culprit_list) {
        print rpt_file ("<a href=\"http://wwwin.synopsys.com/pv/regression/culprit_new/id_info.cgi?id=$culprit_id\" target=\"_blank\">$culprit_id</a>\n");
      }
      close(rpt_file); 
    } else {
      print "No culprit found...\n";
      open(rpt_file, ">$output_path/xtpl/design-$flat_name.txt");
      print rpt_file ("No Culprit\n");
      close(rpt_file);           
      print case_file ("$case $no_culprit_id\n");
    }

#    close(case_file);
    chdir $pwd;  
    exit(0);
  } else {
    die "couldn't fork: $!\n";
  }  
}

foreach (@childs) {
  waitpid($_, 0);
}

print "All culprit done!\n";

close(case_file);
