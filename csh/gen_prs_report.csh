#!/bin/csh

set flow_base = $argv[1]
set flow_test = $argv[2]

rm -rf report
rm -rf prreport.cache.*
/u/iccprsmgr/script/nwtn/nwtn_result.pl  -nolocal -stack -flow_base $flow_base -flow_test $flow_test  -dir report  -split
