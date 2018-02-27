#!/usr/local/bin/perl5  
#
# Script to extract the metrics from report summary in different
# stages of APS flow.
#
# Usage:
#   qor.pl <logfile>


$first = 0;
$n = 0;
$num = 4;
$func_name = "init";
@heart_beat = ();
$max_length = 0;
$head_update = 0;
$core_cmd = "";
$cmd_flag = 0;

print "Heartbeat, $ARGV[0]\n";

if ($ARGV[0] =~ m/gz$/) {
  open FH, "gunzip -c $ARGV[0] |";
} else {
  open FH, "cat $ARGV[0] |";
}

while (<FH>) {
  if (/WORST NEG/) {
    ++$n;
    @log_header = split(/\s+/,$_);    
    if ($#log_header > $max_length) {
      $max_length = $#log_header;
      $head_update = 1;
      ++$first;
    }
  }

  if (/Perform clock synthesis and placement\+optimization \(clock_opt\) flow/) {
    $core_cmd = "clock_opt";
    if ($cmd_flag) {push @heart_beat, "$core_cmd\n";}
  }

  if (/Perform placement and circuit optimization \(place_opt\) on design/) {
    $core_cmd = "place_opt";
    if ($cmd_flag) {push @heart_beat, "$core_cmd\n";}
  }

  if (/Perform placement and circuit optimization \(refine_opt\) on design/) {
    $core_cmd = "refine_opt";
    if ($cmd_flag) {push @heart_beat, "$core_cmd\n";}
  }

  if (($first > 0) && ($first < 4) && $head_update) {
    $heart_beat[$first] = $_;
    ++$first;
  }

  if (($first == 4) && !$cmd_flag) {
    if ($core_cmd) {
      push @heart_beat, "$core_cmd\n";    
      $cmd_flag = 1;
    }
  } 

  if (($first == 4) && $head_update) {
    $first = 0;
    $head_update = 0;
  }

  if (/START_FUNC:\s+(\S+)\s+CPU/) {
    $func_name = $1;
    if ($func_name eq "psynopt_delay_opto") {
      $func_name = "psynopt";
    }
  }

  if ($n > 0) {
    if (/(\S+)\s+[0-9]+:[0-9][0-9]:[0-9][0-9] /) {
      push @heart_beat, $_;
      $n= 0;
    } elsif (/[0-9]+:[0-9][0-9]:[0-9][0-9]/) {
      push @heart_beat, "$func_name $_";
      $n= 0;
    }
  }
}

close FH;

print @heart_beat;

