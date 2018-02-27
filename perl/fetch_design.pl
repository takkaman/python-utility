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

my $sth = $dbh->prepare("SELECT case_path FROM qor_reg_app_testcase WHERE source='random' order by rand() limit 200");
$sth->execute();
open(case_file, ">case_list"); 
while (my @ref = $sth->fetchrow_array()) {
  print case_file ("$ref[0]\n");
}

$sth = $dbh->prepare("SELECT case_path FROM qor_reg_app_testcase WHERE source='reg' order by rand() limit 200");
$sth->execute();
while (my @ref = $sth->fetchrow_array()) {
  print case_file ("$ref[0]\n");
}

close(case_file);
