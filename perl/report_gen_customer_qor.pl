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
   
my $rpt = "email_ttl.html";
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
  $run_date = $year."0".$mon.$day;
}

say OUT "<h3 class=title>Flow Run Date: $run_date</h3>";

say OUT "<h4 class=title>Run dir: $ENV{PWD}</h4>";  

say OUT "<h4 class=title>Please click the following link for your QoR Flow report</h4>";  
say OUT "<h4><a href=\"http://clearcase$ENV{PWD}/qor_compare_ttl/report/\">report</a></h4>";
say OUT "<h4><a href=\"http://clearcase$ENV{PWD}/qor_compare_ttl/outlier.html\">outlier</a></h4>";

$dbh->do("INSERT INTO qor_reg_app_report (date, link, source) VALUES ('$run_date', 'http://clearcase$ENV{PWD}/qor_compare_ttl/outlier.html', 'random')");  
 
say OUT "</body>";
say OUT "</html>";

close OUT;
