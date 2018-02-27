#!/bin/csh -f
set fatal_log = $argv[1]

echo "Start star fatal info extraction"
/remote/pv/bin/pvfatal $fatal_log > fatal_stacktrace
#prepare star info
sed -n '{/Fatal Stack Trace/,/Command Back Trace/p}' fatal_stacktrace > fatal_star_info
sed -i '/Command Back Trace/d' fatal_star_info
printf "==============================================\n" >> fatal_star_info
printf "Stacktrace link:\n" >> fatal_star_info
awk '/PV-INFO: Fatal URL/ {print $6}' fatal_stacktrace >> fatal_star_info  
printf "\nImage:\n" >> fatal_star_info
awk '/PV-INFO: icc_exec/ {print $4}' fatal_stacktrace >> fatal_star_info
printf "\nHow to reproduce:\nPlease copy all 'replay_pkg' to local and run 'replay.tcl'.\n" >> fatal_star_info
printf "\nLog:\nreplay.log\n" >> fatal_star_info
printf "\nThank you.\nBRs/Leo" >> fatal_star_info

exit
