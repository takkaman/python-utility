#! /depot/perl-5.14.2/bin/perl
## Copyright (C) 2013 by Yours Truly
use 5.014;
use warnings;
use strict;

my $rpt = "email.html";
open (OUT, ">$rpt") or die "Error when creating $rpt: $!";

# Write HTML header to OUT
say OUT '<html>';
say OUT '<head>';
say OUT '<style type="text/css">';
say OUT 'h3 {';
say OUT '    font-family:sans-serif;';
say OUT '    font-weight:bold;';
say OUT '}';
say OUT '';
say OUT 'h4 {';
say OUT '    font-family:sans-serif;';
say OUT '    font-weight:normal;';
say OUT '}';
say OUT '';
say OUT '.run_dir {';
say OUT '    background-color:#FFCC22;';
say OUT '}';
say OUT '';
say OUT '.title {';
say OUT '    font-family:sans-serif;';
say OUT '    font-weight:bold;';
say OUT '}';
say OUT '';
say OUT '.fail_header {';
say OUT '    background-color:#c0c0c0;';
say OUT '}';
say OUT '';
say OUT '.crash_header {';
say OUT '    background-color:#009FCC;';
say OUT '    padding:0px 7px'; 
say OUT '}';
say OUT '';
say OUT '.stat_header {';
say OUT '    background-color:#009FCC;';
say OUT '    padding:0px 7px';
say OUT '}';
say OUT '';
say OUT '.new_trace {';
say OUT '    background-color:#ff4500;';
say OUT '}';
say OUT '';
say OUT '.similar_trace {';
say OUT '    background-color:#90ee90;';
say OUT '}';
say OUT '';
say OUT '.has_star {';
say OUT '    background-color:#87ceeb;';
say OUT '}';
say OUT '';

say OUT '.checkpoint {';
say OUT '    background-color:#ff7f50;';
say OUT '    text-align:left;';
say OUT '    padding:0px 0px 0px 7px';
say OUT '}';
say OUT '';
say OUT 'table, td {';
say OUT '    border:solid 2px black;';
say OUT '    text-align:center;';
say OUT '    vertical-align:medium;';
say OUT '}';
say OUT '';
say OUT 'table {';
say OUT '    border-style:solid;';
say OUT '    border-collapse:collapse;';
say OUT '}';
say OUT '';
say OUT '.assigned {';
say OUT '    background-color:#87ceeb;';
say OUT '}';
say OUT '';
say OUT '.fatal {';
say OUT '    background-color:#ff4500;';
say OUT '}';
say OUT '';
say OUT '.fail {';
say OUT '    background-color:#ff4500;';
say OUT '}';
say OUT '';
say OUT '.pass {';
say OUT '    background-color:#90ee90;';
say OUT '}';
say OUT '';
say OUT '.kill {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT 'a:visited {';
say OUT '   color:#8b008b;';
say OUT '}';
say OUT '';
say OUT 'a:link {';
say OUT '   color:blue;';
say OUT '}';
say OUT '';
say OUT '</style>';
say OUT '</head>';
say OUT '<body>';

my $run_date;
my $path = $ENV{PWD};

(my $sec,my $min,my $hour,my $day,my $mon,my $year,my $wday, my $yday, my $isdst)=localtime(time());
$year += 1900;
$mon += 1;
$day -= 1;
if ($mon > 10) {
  $run_date = $year.$mon.$day;
} else {
  $run_date = $year."0".$mon."0".$day;
}

#print $run_date;

say OUT "<h3 class=title>Random Run Date: $run_date</h3>";
#####################################
# run statistics table
#####################################
say OUT "<h4 class=title>Run summary</h4>";
say OUT "<table>";
say OUT "<tr>";
say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Category</h4></td>";  
#say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Assigned</h4></td>";
say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">PASS</h4></td>";
say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">PASS_w_FAIL</h4></td>";
say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">FAIL</h4></td>";
say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">FATAL</h4></td>";
say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">KILL</h4></td>";
say OUT "</tr>";

my $mode;
my @rand_mode = ("DG_placed", "DG_floorplanned", "DG_post_route", "UDC_placed", "UDC_floorplanned", "USER_RAND");
my @rand_mode_times = ("6", "20", "4", "5", "7", "12");
my $i = 0;
#print $path;
opendir (TMPDIR, $path) or die "can't open it $!";

my @dir = grep -d, readdir TMPDIR;
my $mv_pass_num = 0;
my $mv_pass_w_fail_num = 0;
my $mv_fail_num = 0;
my $mv_kill_num = 0;
my $mv_fatal_num = 0;

my $top_pass_num = 0;
my $top_pass_w_fail_num = 0;
my $top_fail_num = 0;
my $top_kill_num = 0;
my $top_fatal_num = 0;

my $n7_pass_num = 0;
my $n7_pass_w_fail_num = 0;
my $n7_fail_num = 0;
my $n7_kill_num = 0;
my $n7_fatal_num = 0;

foreach $mode (@rand_mode) {
  
  my $pass_num = 0;
  my $pass_w_fail_num = 0;
  my $fail_num = 0;
  my $kill_num = 0;
  my $fatal_num = 0;
  my $result;

  my @run = grep /(rand_)?${mode}_*/, @dir; 
  foreach my $sub_run (@run) {
    if (-e "./$sub_run/result") {
      chomp ($result = `awk '{print \$0}' ./$sub_run/result`);
#print $result;
      if ($result eq "pass") {
        $pass_num += 1;
      } elsif ($result eq "pass_w_fail") {
        $pass_w_fail_num += 1;
      } elsif ($result eq "fail") {
        $fail_num += 1;
      }  elsif ($result eq "kill") {
        $kill_num += 1;
      } elsif ($result eq "fatal") {
        $fatal_num += 1;
      }
    }
  }

  say OUT "<tr>";
  say OUT "<td class=run_dir><h4>$mode\($rand_mode_times[$i]\)</h4></td>";  
#  say OUT "<td class=assigned><h4>$rand_mode_times[$i]</h4></td>";
  say OUT "<td class=pass><h4>$pass_num</h4></td>";
  say OUT "<td class=pass><h4>$pass_w_fail_num</h4></td>";  
  say OUT "<td class=fail><h4>$fail_num</h4></td>"; 
  say OUT "<td class=fatal><h4>$fatal_num</h4></td>"; 
  say OUT "<td class=kill><h4>$kill_num</h4></td>";

  say OUT "</tr>";  

  $i += 1;
} 

close TMPDIR;
  
say OUT "</table>";  
say OUT "<h4 class=title>Run dir: $ENV{PWD}</h4>";  

say OUT "<h4 class=title>Please click the following link for your Random QoR Summary</h4>";  
say OUT "<h4><a href=\"http://clearcase$ENV{PWD}/qor_compare/report/\">report</a></h4>";
say OUT "<h4><a href=\"http://clearcase$ENV{PWD}/qor_compare/outlier.html\">outlier</a></h4>";

 

say OUT "</body>";
say OUT "</html>";

close OUT;
