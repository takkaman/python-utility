#!/usr/local/bin/perl5  
#
# Script to extract the metrics from report summary in different
# stages of APS flow.
#
# Usage:
#   qor.pl <logfile>
#
# James Lee, Oct 2013

$n = 0;
$num = 4;


if ($ARGV[0] =~ m/gz$/) {
  open FH, "gunzip -c $ARGV[0] |";
} else {
  open FH, "cat $ARGV[0] |";
}

while (<FH>) {
  if (/WORST NEG/) {
    ++$n;
  }
  if ($n > 0) {
    if (/ [0-9]+:[0-9][0-9]:[0-9][0-9] /) {
#      print;
      $qor = $_;
#      $n= 0;
    }
    if (/Creating Checkpoint\s+(\S+)/) {
      $checkp = $1;
      print $checkp.$qor;
      $n = 0
    }
  }
}

close FH;

