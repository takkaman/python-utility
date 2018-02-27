#!/bin/sh

for case in `cat list`
do
  sed -i 's/check_rp_constraints -all/check_rp_constraints/g' `grep -rl "check_rp_constraints" $case/*.tcl` 
  cd $case
  pre_check.pl  
done        
