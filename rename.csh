#!/bin/csh -f
set tcl_file = $argv[1]
set log_file = $argv[2]

mv $tcl_file auto_verify.tcl
mv $log_file auto_verify.out


