#!/usr/bin/tclsh

set s [exec date]

source /remote/pv/utility/icc2/optimization/qor_regression/utility/pre_check_log.tcl
source dir_info_tcl

set fp_c_w_dir [open case_w_dir w+]

#set flow_dir [exec grep -m1 "Run directory created" ./24x7.log | awk {{print $4}}]
#set base_dir [exec grep -m1 "Run directory created" /remote/us01home24/sunna/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/prev/24x7.log | awk {{print $4}}] 

#set latest [exec ls -l /remote/us01home24/sunna/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/latest | awk {/latest/ {print $11}}]
#set prev [exec ls -l /remote/us01home24/sunna/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/prev | awk {/prev/ {print $11}}]

#set flow_bin [lindex [split $latest _] 0]
#regsub {D} $flow_bin {} flow_bin
#set base_bin [lindex [split $prev _] 0]
#regsub {D} $base_bin {} base_bin

#set rpt_dir /remote/us01home24/sunna/proj_disk/NT/reg_qor
#set rpt_dir /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${latest}

if {[file exist ${latest_dir}/${flow_bin}_pre_cmp]} {
   exec rm -rf ${latest_dir}/${flow_bin}_pre_cmp
}
exec mkdir ${latest_dir}/${flow_bin}_pre_cmp
exec mkdir ${latest_dir}/${flow_bin}_pre_cmp/base_${base_bin}
exec mkdir ${latest_dir}/${flow_bin}_pre_cmp/flow_${flow_bin}
set base_rpt_dir ${latest_dir}/${flow_bin}_pre_cmp/base_${base_bin}
set flow_rpt_dir ${latest_dir}/${flow_bin}_pre_cmp/flow_${flow_bin}

exec mkdir ${latest_dir}/${flow_bin}_pre_cmp/xtpl
exec touch ${latest_dir}/${flow_bin}_pre_cmp/xtpl/.unote
exec chmod 777 ${latest_dir}/${flow_bin}_pre_cmp/xtpl       

if {[file exist ${latest_dir}/${flow_bin}_repeat]} {
   exec rm -rf ${latest_dir}/${flow_bin}_repeat
} 
exec mkdir ${latest_dir}/${flow_bin}_repeat
exec mkdir ${latest_dir}/${flow_bin}_repeat/repeat
set repeat_dir ${latest_dir}/${flow_bin}_repeat/repeat


#set f_for_prsrpt [open dir_info_csh w+]
#puts $f_for_prsrpt "set rpt_dir = ${rpt_dir}/${flow_bin}_pre_cmp"
#puts $f_for_prsrpt "set repeat_dir = ${rpt_dir}/${flow_bin}_repeat"
#puts $f_for_prsrpt "set latest_dir = /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${latest}"
#puts $f_for_prsrpt "set prev_dir = /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${prev}"
#puts $f_for_prsrpt "set latest_bin = $flow_bin"
#puts $f_for_prsrpt "set prev_bin = $base_bin"
#close $f_for_prsrpt
#set f_for_prsrpt [open dir_info_tcl w+]
#puts $f_for_prsrpt "set rpt_dir ${rpt_dir}/${flow_bin}_pre_cmp"
#puts $f_for_prsrpt "set repeat_dir ${rpt_dir}/${flow_bin}_repeat"
#puts $f_for_prsrpt "set latest_dir /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${latest}"
#puts $f_for_prsrpt "set prev_dir /remote/pv/24x7/nwtn/L-2016.03-SP/sunna/Reg_QoR/${prev}"
#puts $f_for_prsrpt "set latest_bin $flow_bin"
#puts $f_for_prsrpt "set prev_bin $base_bin"
#close $f_for_prsrpt


if {[file exist log_error_list]} {exec rm -rf log_error_list}
set fp_case_list [open ${latest_dir}/case_list r]
while {![eof $fp_case_list]} {
  set c_list [gets $fp_case_list]
  puts "=== $c_list"
  if {[llength $c_list]!=0} {
     set case_name [lindex [split $c_list /] end]

     array unset rpt_flow_cmd
     array unset rpt_base_cmd
     array unset rpt_repeat_cmd

     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_popt_*}]} {
        set popt_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_popt_*]
     } else {
        set popt_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_popt_*}]} {
        set popt_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_popt_*]
     } else {
        set popt_base ""
     }
     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cbt_*}]} {
        set cbt_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cbt_*]
     } else {
        set cbt_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_cbt_*}]} {
        set cbt_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_cbt_*]
     } else {
        set cbt_base ""
     }
     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refopt_*}]} {
        set refopt_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refopt_*]
     } else {
        set refopt_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_refopt_*}]} {
        set refopt_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_refopt_*]
     } else {
        set refopt_base ""
     }
     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refplc_*}]} {
        set refplc_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refplc_*]
     } else {
        set refplc_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_refplc_*}]} {
        set refplc_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_refplc_*]
     } else {
        set refplc_base ""
     }         
     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_copt_*}]} {
        set copt_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_copt_*]
     } else {
        set copt_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_copt_*}]} {
        set copt_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_copt_*]
     } else {
        set copt_base ""
     }         
     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_ropt_*}]} {
        set ropt_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_ropt_*]
     } else {
        set ropt_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_ropt_*}]} {
        set ropt_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_ropt_*]
     } else {
        set ropt_base ""
     }         
     if {![catch {glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cplc_*}]} {
        set cplc_test [glob ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cplc_*]
     } else {
        set cplc_test ""
     }
     if {![catch {glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_cplc_*}]} {
        set cplc_base [glob ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_cplc_*]
     } else {
        set cplc_base ""
     }                     


     set cmd_list "" 
     for {set i 0} {$i<[llength $popt_test]} {incr i} {
        set rpt_flow_cmd(popt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_popt_$i/icprpt_popt.out
        set rpt_repeat_cmd(popt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_popt_$i/icprpt_popt_repeat.out
        set cmd_list [concat $cmd_list popt_$i]
     }
     for {set i 0} {$i<[llength $popt_base]} {incr i} {
        set rpt_base_cmd(popt_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_popt_$i/icprpt_popt.out
     }
     
     for {set i 0} {$i<[llength $cbt_test]} {incr i} {
        set rpt_flow_cmd(cbt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cbt_$i/icprpt_cbt.out
        set rpt_repeat_cmd(cbt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cbt_$i/icprpt_cbt_repeat.out
        set cmd_list [concat $cmd_list cbt_$i]
     }
     for {set i 0} {$i<[llength $cbt_base]} {incr i} {
        set rpt_base_cmd(cbt_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_cbt_$i/icprpt_cbt.out
     }
     
     for {set i 0} {$i<[llength $refopt_test]} {incr i} {
        set rpt_flow_cmd(refopt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refopt_$i/icprpt_refopt.out
        set rpt_repeat_cmd(refopt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refopt_$i/icprpt_refopt_repeat.out
        set cmd_list [concat $cmd_list refopt_$i]
     }
     for {set i 0} {$i<[llength $refopt_base]} {incr i} {
        set rpt_base_cmd(refopt_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_refopt_$i/icprpt_refopt.out
     }
         
     for {set i 0} {$i<[llength $refplc_test]} {incr i} {
        set rpt_flow_cmd(refplc_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refplc_$i/icprpt_refplc.out
        set rpt_repeat_cmd(refplc_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_refplc_$i/icprpt_refplc_repeat.out
        set cmd_list [concat $cmd_list refplc_$i]
     }
     for {set i 0} {$i<[llength $refplc_base]} {incr i} {
        set rpt_base_cmd(refplc_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_refplc_$i/icprpt_refplc.out
     }
         
     for {set i 0} {$i<[llength $copt_test]} {incr i} {
        set rpt_flow_cmd(copt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_copt_$i/iccrpt_copt.out
        set rpt_repeat_cmd(copt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_copt_$i/iccrpt_copt_repeat.out
        set cmd_list [concat $cmd_list copt_$i]
     }
     for {set i 0} {$i<[llength $copt_base]} {incr i} {
        set rpt_base_cmd(copt_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_copt_$i/iccrpt_copt.out
     }
         
     for {set i 0} {$i<[llength $ropt_test]} {incr i} {
        set rpt_flow_cmd(ropt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_ropt_$i/icrpt_ropt.out
        set rpt_repeat_cmd(ropt_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_ropt_$i/icrpt_ropt_repeat.out
        set cmd_list [concat $cmd_list ropt_$i]
     }
     for {set i 0} {$i<[llength $ropt_base]} {incr i} {
        set rpt_base_cmd(ropt_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_ropt_$i/icrpt_ropt.out
     }
                             
     for {set i 0} {$i<[llength $cplc_test]} {incr i} {
        set rpt_flow_cmd(cplc_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cplc_$i/icprpt_cplc.out
        set rpt_repeat_cmd(cplc_$i) ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_cplc_$i/icprpt_cplc_repeat.out
        set cmd_list [concat $cmd_list cplc_$i]
     }
     for {set i 0} {$i<[llength $cplc_base]} {incr i} {
        set rpt_base_cmd(cplc_$i) ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_cplc_$i/icprpt_cplc.out
     }
 
     set log_flow ${flow_dir}/ICC2/${c_list}/${case_name}.log
     set log_base ${base_dir}/ICC2/${c_list}/${case_name}.log


     foreach cmd $cmd_list {
       if {![catch {info var $rpt_flow_cmd($cmd)}] && ![catch {info var $rpt_base_cmd($cmd)}]} {
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
               switch -regexp $cmd {
               "copt_*" {
                        exec cp -f $rpt_base ${base_rpt_dir}/${case_dir}/${case}.iccrpt.out
                        exec cp -f $rpt_flow ${flow_rpt_dir}/${case_dir}/${case}.iccrpt.out
                      }
               "ropt_*" {
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
               #exec ln -s ${base_dir}/ICC2/${c_list}/ ${base_rpt_dir}/${case_dir}/base_run_dir
               #exec ln -s ${flow_dir}/ICC2/${c_list}/ ${flow_rpt_dir}/${case_dir}/flow_run_dir
               exec ln -s ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_${cmd} ${base_rpt_dir}/${case_dir}/base_run_dir
               exec ln -s ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_${cmd} ${flow_rpt_dir}/${case_dir}/test_run_dir
               exec ln -s ${base_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/base_${cmd} ${flow_rpt_dir}/${case_dir}/base_run_dir

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

       if {![catch {info var $rpt_repeat_cmd($cmd)}]} {
        if {[file exist $rpt_repeat_cmd($cmd)]} {
          set rpt_repeat $rpt_repeat_cmd($cmd)
          if {[catch {exec grep "Current block is not defined" $rpt_repeat}]} {
            set case1 [join [lreplace [split $case_name .] end end] .]
            set case ${case1}-${cmd}
            set case_dir [join [concat [lrange [split $c_list /] 1 end-1] $case] -]
     
            set repeat_go [pre_check_log $rpt_repeat go]
     
            if {$repeat_go==1} {
               exec mkdir ${repeat_dir}/${case_dir}
               switch -regexp $cmd {
               "copt_*" {
                        exec cp -f $rpt_repeat ${repeat_dir}/${case_dir}/${case}.iccrpt.out
                      }
               "ropt_*" {
                        exec cp -f $rpt_repeat ${repeat_dir}/${case_dir}/${case}.icrpt.out
                      }
                default {
                        exec cp -f $rpt_repeat ${repeat_dir}/${case_dir}/${case}.icprpt.out
                      }
               }
               exec ln -s ${flow_dir}/ICC2/${c_list}/tmp_test/run_dir_${case_name}/run/test_${cmd} ${repeat_dir}/${case_dir}/repeat_run_dir

               exec touch ${repeat_dir}/${case_dir}/${case}.all.done
               exec touch ${repeat_dir}/${case_dir}/${case}.all.csh
               puts "${case_dir}"
               puts ""
            }
          }
        }
       }



       }
     }
  }
}
close $fp_case_list


close $fp_c_w_dir

exec ln -s $flow_rpt_dir ${latest_dir}/${flow_bin}_repeat/
set e [exec date]
puts "Start time $s"
puts "End time $e"
   
exit
