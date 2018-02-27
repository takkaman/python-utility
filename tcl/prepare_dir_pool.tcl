#!/usr/bin/tclsh

set s [exec date]

source /remote/pv/utility/icc2/optimization/qor_regression/utility/pre_check_log.tcl

set fp_c_w_dir [open case_w_dir w+]

set flow_dir [exec grep -m1 "Run directory created" ./24x7.log | awk {{print $4}}]
set base_dir [exec grep -m1 "Run directory created" /remote/us01home24/sunna/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/prev/24x7.log | awk {{print $4}}] 

set latest [exec ls -l /remote/us01home24/sunna/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/latest | awk {/latest/ {print $11}}]
set prev [exec ls -l /remote/us01home24/sunna/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/prev | awk {/prev/ {print $11}}]

set flow_bin [lindex [split $latest _] 0]
regsub {D} $flow_bin {} flow_bin
set base_bin [lindex [split $prev _] 0]
regsub {D} $base_bin {} base_bin

#set rpt_dir /remote/us01home24/sunna/proj_disk/NT/reg_qor
set rpt_dir /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${latest}

if {[file exist ${rpt_dir}/${flow_bin}_pre_cmp]} {
   exec rm -rf ${rpt_dir}/${flow_bin}_pre_cmp
}
exec mkdir ${rpt_dir}/${flow_bin}_pre_cmp
exec mkdir ${rpt_dir}/${flow_bin}_pre_cmp/base_${base_bin}
exec mkdir ${rpt_dir}/${flow_bin}_pre_cmp/flow_${flow_bin}
set base_rpt_dir ${rpt_dir}/${flow_bin}_pre_cmp/base_${base_bin}
set flow_rpt_dir ${rpt_dir}/${flow_bin}_pre_cmp/flow_${flow_bin}

exec mkdir ${rpt_dir}/${flow_bin}_pre_cmp/xtpl
exec touch ${rpt_dir}/${flow_bin}_pre_cmp/xtpl/.unote
exec chmod 777 ${rpt_dir}/${flow_bin}_pre_cmp/xtpl

set f_for_prsrpt [open dir_info_csh w+]
puts $f_for_prsrpt "set rpt_dir = ${rpt_dir}/${flow_bin}_pre_cmp"
puts $f_for_prsrpt "set latest_dir = /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${latest}"
puts $f_for_prsrpt "set prev_dir = /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${prev}"
puts $f_for_prsrpt "set latest_bin = $flow_bin"
puts $f_for_prsrpt "set prev_bin = $base_bin"
close $f_for_prsrpt
set f_for_prsrpt [open dir_info_tcl w+]
puts $f_for_prsrpt "set rpt_dir ${rpt_dir}/${flow_bin}_pre_cmp"
puts $f_for_prsrpt "set latest_dir /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${latest}"
puts $f_for_prsrpt "set prev_dir /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${prev}"
puts $f_for_prsrpt "set latest_bin $flow_bin"
puts $f_for_prsrpt "set prev_bin $base_bin"
close $f_for_prsrpt


if {[file exist log_error_list]} {exec rm -rf log_error_list}
set fp_case_list [open ./case_list r]
while {![eof $fp_case_list]} {
  set c_list [gets $fp_case_list]
  puts "=== $c_list"
  if {[llength $c_list]!=0} {
     set case_name [lindex [split $c_list /] end]

     array unset rpt_flow_cmd
     array unset rpt_base_cmd

     set rpt_flow_cmd(popt) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_popt_0.out
     set rpt_base_cmd(popt) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_popt_0.out
     set rpt_flow_cmd(cbt) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_cbt_0.out
     set rpt_base_cmd(cbt) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_cbt_0.out
     set rpt_flow_cmd(refopt) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_refopt_0.out
     set rpt_base_cmd(refopt) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_refopt_0.out
     set rpt_flow_cmd(refplc) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_refplc_0.out
     set rpt_base_cmd(refplc) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_refplc_0.out
     set rpt_flow_cmd(copt) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/iccrpt_copt_0.out
     set rpt_base_cmd(copt) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/iccrpt_copt_0.out
     set rpt_flow_cmd(ropt) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icrpt_ropt_0.out
     set rpt_base_cmd(ropt) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icrpt_ropt_0.out
     set rpt_flow_cmd(cplc) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_cplc_0.out
     set rpt_base_cmd(cplc) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/icprpt_cplc_0.out
     set log_flow ${flow_dir}/ICC2/${c_list}/${case_name}.log
     set log_base ${base_dir}/ICC2/${c_list}/${case_name}.log


     set cmd_list "popt cbt refopt refplc copt ropt cplc"

     foreach cmd $cmd_list {
        if {[file exist $rpt_flow_cmd($cmd)] && [file exist $rpt_base_cmd($cmd)]} {
          set rpt_flow $rpt_flow_cmd($cmd)
          set rpt_base $rpt_base_cmd($cmd)
          if {[catch {exec grep "Current block is not defined" $rpt_flow}] || [catch {exec grep "Current block is not defined" $rpt_base}]} {
            #set case1 [lindex [split $case_name .] 0]
            set case1 [join [lreplace [split $case_name .] end end] .]
            set case ${case1}-${cmd}
            set case_dir [join [concat [lrange [split $c_list /] 1 end-1] $case] -]
     
            set flow_go [pre_check_log $rpt_flow go]
            set base_go [pre_check_log $rpt_base go]
     
            if {$flow_go==1 && $base_go==1} {
               exec mkdir ${base_rpt_dir}/${case_dir}
               exec mkdir ${flow_rpt_dir}/${case_dir}
               switch -exact $cmd {
               "copt" {
                        exec cp -f $rpt_base ${base_rpt_dir}/${case_dir}/${case}.iccrpt.out
                        exec cp -f $rpt_flow ${flow_rpt_dir}/${case_dir}/${case}.iccrpt.out
                      }
               "ropt" {
                        exec cp -f $rpt_base ${base_rpt_dir}/${case_dir}/${case}.icrpt.out
                        exec cp -f $rpt_flow ${flow_rpt_dir}/${case_dir}/${case}.icrpt.out
                      }
                default {
                        exec cp -f $rpt_base ${base_rpt_dir}/${case_dir}/${case}.icprpt.out
                        exec cp -f $rpt_flow ${flow_rpt_dir}/${case_dir}/${case}.icprpt.out
                      }
               }
               exec cp -f ${base_dir}/ICC2/${c_list}/$case_name  ${base_rpt_dir}/${case_dir}
               exec cp -f ${flow_dir}/ICC2/${c_list}/$case_name  ${flow_rpt_dir}/${case_dir}
               exec ln -s ${base_dir}/ICC2/${c_list} ${base_rpt_dir}/${case_dir}/base_run_dir
               exec ln -s ${flow_dir}/ICC2/${c_list} ${flow_rpt_dir}/${case_dir}/flow_run_dir
               if {[file exist ${flow_rpt_dir}/${case_dir}/pre_latest_diff]} {file delete -force ${flow_rpt_dir}/${case_dir}/pre_latest_diff} 
               catch {exec diff ${base_rpt_dir}/${case_dir}/$case_name ${flow_rpt_dir}/${case_dir}/$case_name >  ${flow_rpt_dir}/${case_dir}/pre_latest_diff}
               if {$cmd=="ropt"} {
                 if {![catch {exec grep -m1 "Buffer removal complete" $log_base}]} {
                    set buf_rm_base [string replace [exec grep -m1 "Buffer removal complete" $log_base | awk {{print $8}}] end end]
                 } else {
                    set buf_rm_base ""
                 }
                 if {![catch {exec grep -m1 "Buffer removal complete" $log_flow}]} {
                    set buf_rm_flow [string replace [exec grep -m1 "Buffer removal complete" $log_flow | awk {{print $8}}] end end]
                 } else {
                    set buf_rm_flow ""
                 }
                 exec echo "Buffer removal is $buf_rm_base" >> ${base_rpt_dir}/${case_dir}/${case}.icprpt.out
                 exec echo "Buffer removal is $buf_rm_flow" >> ${flow_rpt_dir}/${case_dir}/${case}.icprpt.out
               }
               exec touch ${base_rpt_dir}/${case_dir}/${case}.all.done
               exec touch ${base_rpt_dir}/${case_dir}/${case}.all.csh
               exec touch ${flow_rpt_dir}/${case_dir}/${case}.all.done
               exec touch ${flow_rpt_dir}/${case_dir}/${case}.all.csh
               puts "${case_dir}"
               puts ""
               puts $fp_c_w_dir $c_list
            }
          }
        }
     }
  }
}
close $fp_case_list


close $fp_c_w_dir

set e [exec date]
puts "Start time $s"
puts "End time $e"
   
exit
