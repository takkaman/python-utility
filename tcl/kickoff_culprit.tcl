#!/usr/bin/tclsh
source ./dir_info_tcl

set s [exec date]

if {[file size ./culprit_case_list] > 0} {
  set latest_b [exec grep -m1 "Testing image" ${latest_dir}/24x7.log | awk {{print $3}}]
  set prev_b [exec grep -m1 "Testing image" ${prev_dir}/24x7.log | awk {{print $3}}]
  exec /remote/pv/utility/icc2/optimization/qor_regression/utility/culprit_find_mt.pl -latest_b $latest_b -prev_b $prev_b -branch ${branch} -case_list ./culprit_case_list -output_path $rpt_dir | tee ./culprit_find.log
} else {
  puts "No case has outlier to run culprit"
}

set e [exec date]
puts "Start time $s"
puts "End time $e"

exec chmod -R 777 $rpt_dir/xtpl
exit
