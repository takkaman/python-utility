#! /depot/perl-5.14.2/bin/perl -w
##!/usr/bin/perl
use 5.014;  
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
say OUT 'td {';
say OUT '    font-family:sans-serif;';
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
say OUT '.no_star {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.open_star {';
say OUT '    background-color:#87ceeb;';
say OUT '}';
say OUT '';
say OUT '.closed_star {';
say OUT '    background-color:#ff4500;';
say OUT '}';
say OUT '';
say OUT '.False {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.True {';
say OUT '    background-color:#90ee90;';
say OUT '}';
say OUT '';
say OUT '.NA {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.success {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.fail {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.no_star {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.no_command {';
say OUT '    background-color:#AAAAAA;';
say OUT '}';
say OUT '';
say OUT '.has_command {';
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
say OUT '.fail {';
say OUT '    background-color:#ff4500;';
#say OUT '    color:red;';
#say OUT '    font-weight:bold;';
say OUT '}';
say OUT '';
say OUT '.pass {';
say OUT '    background-color:#90ee90;';
#say OUT '    color:green;';
#say OUT '    font-weight:bold;';
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

my @all_fatal_info = `grep http stacktrace.log`;
my @all_error_info = `grep -E 'Error|Wrong' checkpoint_trace.log`;
my $design_name;
my $star_line;
my $star_status;
my $star_num;
my $command_line;
my $result;
my $pack_result; 
my $va_num;
my $blk_num;
my $is_n7 = "False";
my $is_n12 = "False";
my $run_result= `awk '{print \$0}' ../result`;
my $flow= `awk '{if(NR==1) print \$2}' ../kick_off_record`;

#print @all_error_info;
#print $design_name;

my $total_count = `ls -d run* | wc -l`;
my $fatal_count = $#all_fatal_info + 1;
my $fail_count = $#all_error_info + 1;

say OUT "<h3 class=title>Random Suite: Preroute_random</h3>";

#####################################
# run statistics table
#####################################
say OUT "<h4 class=title>Run statistics</h4>";
say OUT "<h4 class=title>Flow: $flow</h4>";
#tmp report added here
   
if (-e "run_1/run_stats") {
  say OUT "<table>";
  say OUT "<tr>";
  say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Design</h4></td>";  
  say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">MV</h4></td>";
  say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">TOP</h4></td>";
  say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">N7</h4></td>"; 
  say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">N12</h4></td>"; 
  say OUT "</tr>";
  say OUT "<tr>";

  chomp ($design_name = `awk '/design_name/{print \$2}' run_1/run_stats`);
  say OUT "<td class=run_dir><h4>$design_name</h4></td>";
  
  chomp ($va_num = `awk '/no.VA/{print \$2}' run_1/run_stats`);
  my $is_mv = "False";
  if ($va_num > 1) {
    $is_mv = "True";
    `touch ../MV`
  }
  say OUT "<td class=$is_mv><h4>$is_mv</h4></td>";

  chomp ($blk_num = `awk '/no.Block/{print \$2}' run_1/run_stats`);
  my $is_top = "False";
  if ($blk_num > 1) {
    $is_top = "True";
    `touch ../TOP`
  }
  say OUT "<td class=$is_top><h4>$is_top</h4></td>";

  if (-e "../N7") {
      $is_n7 = "True";
  }
  say OUT "<td class=$is_n7><h4>$is_n7</h4></td>";

  if (-e "../N12") {
      $is_n12 = "True";
  }
  say OUT "<td class=$is_n12><h4>$is_n12</h4></td>";

  say OUT "</tr>";
  say OUT "</table>";

}

if (-e "run_1/snapshot.gif") {
  say OUT "<h4 class=title>Design Snapshot</h4>";
  say OUT "<img src=\"http://clearcase$ENV{PWD}/run_1/snapshot.gif\" width=\"400\">";
}

$design_name = `grep "^set prs_design " step/setup.tcl`;
if ($design_name =~ /^set prs_design (.*)$/) {
    say OUT "<h3 class=title>Design: $1</h3>";
} else {
  $design_name = `grep "^open_mw_lib" step/setup.tcl`;
  if ($design_name =~ /^open_mw_lib\s+(\S+)$/) {
    $design_name = $1;
    say OUT "<h3 class=title>Design: $1</h3>";
  }
}   

if (-z "stacktrace.log" && -z "abnormal_fatal.log") {
    say OUT "<h3>No crash detected in this run! Congratulations!</h3>";
}
elsif (-z "stacktrace.log" && ! -z "abnormal_fatal.log") {
    say OUT "<h3>Abnormal FATAL detected in this run! please check the log!</h3>";
}
else {
    say OUT "<h3>Fatal Count: $fatal_count</h3>";

#####################################
# Fatal table
#####################################
    say OUT "<table>";
    say OUT "<tr>";
    say OUT "<td class=crash_header><h3>Dir</h3></td>";
    say OUT "<td class=crash_header><h3>StackT</h3></td>";
    say OUT "<td class=crash_header><h3>Command</h3></td>";
    say OUT "<td class=crash_header><h3>Star</h3></td>";
    say OUT "<td class=crash_header><h3>Status</h3></td>"; 
    say OUT "<td class=crash_header><h3>Pack</h3></td>"; 
    say OUT "</tr>";

    foreach (@all_fatal_info) {
        chomp;
        say OUT "<tr>";
        if (/^(run_\d+)\/.+(OLD|NEW).+\/(\d+)\/\d+$/) {
            say OUT "<td class=run_dir><h4><a href=\"http://clearcase$ENV{PWD}/$1\">$1</a></h4></td>";
            if ($2 eq "NEW") {
                say OUT "<td class=new_trace><h4><a href=\"http://pv/pone/fatal/nwtn/$3\">$3</a></h4></td>";
                #Fatal command info
                $command_line = "";
                chomp ($command_line = `grep -A 2 "Command Back Trace" $1/stacktrace | tail -1`); 
                if ($command_line eq "") {
                    say OUT "<td class=no_command><h4>N/A</h4></td>";
                }
                else {
                    say OUT "<td class=has_command><h4>$command_line</h4></td>";
                }
                say OUT "<td class=no_star><h4>N/A</h4></td>";

            }
            else {
                say OUT "<td class=similar_trace><h4><a href=\"http://pv/pone/fatal/nwtn/$3\">$3</a></h4></td>";
                #Fatal command info
                $command_line = "";
                chomp ($command_line = `grep -A 2 "Command Back Trace" $1/stacktrace | tail -1`); 
                if ($command_line eq "") {
                    say OUT "<td class=no_command><h4>NA</h4></td>";
                }
                else {
                    say OUT "<td class=has_command><h4>$command_line</h4></td>";
                }

                # Star info
                $star_line = "";
                chomp ($star_line = `grep "PV-INFO: STAR =" $1/stacktrace`);
                if ($star_line eq "") {
                    say OUT "<td class=no_star><h4>N/A</h4></td>";
                    say OUT "<td class=no_star><h4>N/A</h4></td>"; 
                }
                else {
                    if ($star_line =~ /STAR\s+=\s+(\d+)/) {
                        $star_num = $1;
                        print $star_num;
                        chomp ($star_status = `/remote/us01home19/szhang/pv/bin/pvstar $star_num`);
                        if ($star_status =~ /^\d+ (.*)$/) {
                           $star_status = $1;
                           print $star_status;
                           if ($star_status =~ /Fix/ || $star_status eq "Closed") {
                              say OUT "<td class=closed_star><h4><a href=\"http://crmdbci.synopsys.com:9958/sap(bD1lbiZjPTkxMA==)/bc/bsp/sap/zservice/getService.do?id=$star_num\">$star_num</a></h4></td>"; 
                              say OUT "<td class=closed_star><h4>$star_status</h4></td>";
                           } else {
                              say OUT "<td class=open_star><h4><a href=\"http://crmdbci.synopsys.com:9958/sap(bD1lbiZjPTkxMA==)/bc/bsp/sap/zservice/getService.do?id=$star_num\">$star_num</a></h4></td>";
                              say OUT "<td class=open_star><h4>$star_status</h4></td>";
                           }
                        }
                    }
                }
            }
            #prepare pack result
            if (! -e "run_1/pack_star/summary.txt") {
              $pack_result = "NA";              
            } else {
#chomp ($pack_result = `awk '/
              $pack_result = "success"; 
            }
            say OUT "<td class=$pack_result><h4>$pack_result</h4></td>";
        }
        say OUT "</tr>";
    }

    say OUT "</table>";
}

#####################################

#say OUT "<br />";
if (-z "checkpoint_trace.log") {
    say OUT "<h3>No error detected in this run! Congratulations!</h3>";
}
else {                         
    say OUT "<h3>Fail count: $fail_count</h3>";
#####################################
# Fail table
#####################################
    say OUT "<table>";
    say OUT "<tr>";
    say OUT "<td class=crash_header><h3>Directory</h3></td>";
    say OUT "<td class=crash_header><h3>Failed Checkpoint</h3></td>";
    say OUT "</tr>";

#my $error_number = @all_error_number;
    foreach (@all_error_info) {
        chomp;
        say OUT "<tr>";
        #check aid checkpoint
        if (/^(run_\d+)\/.+Error:?(.*)/) {
            say OUT "<td class=run_dir><h4><a href=\"http://clearcase$ENV{PWD}/$1\">$1</a></h4></td>";
            say OUT "<td class=checkpoint><h4>$2</h4></td>";
        }

        #check common checkpoint
        if (/^(run_\d+)\/.+Wrong:(.*)$/) {
            say OUT "<td class=run_dir><h4><a href=\"http://clearcase$ENV{PWD}/$1\">$1</a></h4></td>";
            say OUT "<td class=checkpoint><h4>$2</h4></td>";
        }
        say OUT "</tr>";
    }
    say OUT "</table>";
}                    

my $TB_COLUMN = 10;
chomp($run_result);
if ($run_result =~ "pass") {
  #qor compare report
  if (-e "qor_compare_result") {
    chomp (my $qor_result = `awk '{if(NR==1) print \$1}' qor_compare_result`);
    say OUT "<h3 class=title>QoR Compare Result</h3>";
    if ($qor_result eq "pass") {
      say OUT "<table style=\"border:0\">";
      say OUT "<tr>";
      say OUT "<td style=\"border:0\"><h4 style=\"background-color:#90ee90;font-weight:bold;width:auto\">$qor_result</h4></td>";
      say OUT "</tr>";
      say OUT "</table>"; 
    } else {
      chomp (my $step_num = `awk '{if(NR==1) print \$3}' qor_compare_result`); 
      if ($qor_result eq "fatal") {                                             
        say OUT "<td class=report><h4>Found $qor_result at step $step_num</h4></td>";
      } elsif ($qor_result eq "common_checkpoint_fail") {
        say OUT "<td class=report><h4>Found $qor_result at step $step_num</h4></td>";
      } else {  
        say OUT "<td class=report><h4>Found <a href=\"http://clearcase$ENV{PWD}/report/\">$qor_result</a> at step $step_num</h4></td>";
        chomp (my $base_qor = `awk '{if(NR==3) print \$0}' qor_compare_result`);
        my @base_qor = split(/ /,$base_qor);
        @base_qor = @base_qor[4..$#base_qor];
        chomp (my $base_1_qor = `awk '{if(NR==4) print \$0}' qor_compare_result`);
        my @base_1_qor = split(/ /,$base_1_qor);
        @base_1_qor = @base_1_qor[4..$#base_1_qor];
        chomp (my $compare_qor = `awk '{if(NR==5) print \$0}' qor_compare_result`);
        my @compare_qor = split(/ /,$compare_qor);
        @compare_qor = @compare_qor[4..$#compare_qor];
        chomp (my $step_cmd = `awk '{if(NR==2) print \$1}' qor_compare_result`);
        say OUT "<td class=report><h4>$step_cmd</h4></td>";           
        say OUT "<table>";
        say OUT "<tr>";
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Flow</h4></td>";  
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">WNS</h4></td>";
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">TNS</h4></td>";
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">BUFFCNT</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">AREA</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">MAXTRAN</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">MEM</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">CPU</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">BUFFAREA</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">HFN60</h4></td>"; 
        say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">HFN100</h4></td>"; 
        say OUT "</tr>";
        say OUT "<tr>";
        say OUT "<td class=run_dir><h4>Base</h4></td>";
        for (my $i=0;$i<$TB_COLUMN;$i++) {
            say OUT "<td>$base_qor[$i*2+1]</td>";
        }
        say OUT "</tr>";
        say OUT "<tr>";
        say OUT "<td class=run_dir><h4>Base_1</h4></td>";
        for (my $i=0;$i<$TB_COLUMN;$i++) {
            say OUT "<td>$base_1_qor[$i*2+1]</td>";
        }
        say OUT "</tr>";
        say OUT "<tr>";
        say OUT "<td class=run_dir><h4>Compare</h4></td>";
        for (my $i=0;$i<$TB_COLUMN;$i++) {
            say OUT "<td>$compare_qor[$i*2+1]</td>";
        }
        say OUT "</tr>";
        say OUT "</table>"; 
        #print @base_qor,"\n", @base_1_qor,"\n", @compare_qor,"\n";
        #say OUT "<td class=report><h4>$base_qor</h4></td>";
        #say OUT "<td class=report><h4>$base_1_qor</h4></td>";
        #say OUT "<td class=report><h4>$compare_qor</h4></td>";
      }
    }
  } else {
    say OUT "<h3 class=title>Skip QoR compare</h3>";
  }

  #common check report
  if (-e "common_check_result") {
    say OUT "<h3 class=title>Common Check Result</h3>";
    chomp (my $common_check_result = `cat common_check_result`);
    my @common_check_result = split(/ /, $common_check_result);
    say OUT "<table>";
    say OUT "<tr>";
    say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Power Shape</h4></td>";  
    say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Ground Shape</h4></td>";
    say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">MV</h4></td>";
    say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Spare Cell</h4></td>";
    say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Unconnected Cell</h4></td>";
    say OUT "<td class=stat_header><h4 style=\"font-weight:bold\">Formality</h4></td>";
    say OUT "</tr>";

    say OUT "<tr>";
    foreach $result (@common_check_result) {
        if ($result == 0) {
            say OUT "<td class=pass>Pass</td>"; 
        } else {
            say OUT "<td class=fail>Fail</td>";
        }
    }
    say OUT "</tr>";
    say OUT "</table>";
  } else {
    say OUT "<h3 class=title>Skip common check</h3>";
  }

}  

#$dbh->do("INSERT INTO qor_reg_app_run (date, link, source) VALUES ('$run_date', 'http://clearcase$ENV{PWD}/qor_compare_ttl/outlier.html', 'random')");  

#List working dir
say OUT "<h3>Working dir: <p id=\"dir\" onclick=\"getDir()\">$ENV{PWD}</p></h3>";
#say OUT "<h4><a href=\"http://clearcase/remote/us01home40/phyan/public_html/web/index.php\"><b>Random Suite Web Page</b></a></h4>";

#say OUT '<script type="text/javascript">';
#say OUT 'function getDir() { ';
#say OUT '  var text = document.getElementById(\'dir\').innerHTML;';
#say OUT '  if (window.clipboardData.setData(\'Text\', text)) {';
#say OUT '    alert("Text has been copied to clipboard. Please use Ctrl+V to paste it.");';
#say OUT '  }';
#say OUT '}';
#say OUT '</script>';

say OUT "</body>";
say OUT "</html>";

close OUT;
