#!/usr/bin/tclsh
set branch [lindex [split [exec grep "REGRESSO_REFROOT" run.csh | awk {{print $3}}] /] end]
set latest [exec ls -l /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/latest | awk {/latest/ {print $11}}]
set prev [exec ls -l /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/prev | awk {/prev/ {print $11}}]
set latest_dir /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}
set prev_dir /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${prev}
set flow_bin [lindex [split $latest _] 0]
regsub {D} $flow_bin {} flow_bin
set base_bin [lindex [split $prev _] 0]
regsub {D} $base_bin {} base_bin
set latest_bin $flow_bin
set prev_bin $base_bin

set rpt_dir /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}

set flow_dir [exec grep -m1 "Run directory created" ${latest_dir}/24x7.log | awk {{print $4}}]
set base_dir [exec grep -m1 "Run directory created" ${prev_dir}/24x7.log | awk {{print $4}}] 

#####################
set f_for_prsrpt [open dir_info_csh w+]
puts $f_for_prsrpt "set branch = $branch"
puts $f_for_prsrpt "set rpt_dir = ${rpt_dir}/${flow_bin}_pre_cmp"
puts $f_for_prsrpt "set latest = ${latest}"
puts $f_for_prsrpt "set prev = ${prev}"
puts $f_for_prsrpt "set repeat_dir = ${rpt_dir}/${flow_bin}_repeat"
puts $f_for_prsrpt "set latest_dir = /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}"
puts $f_for_prsrpt "set prev_dir = /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${prev}"
puts $f_for_prsrpt "set latest_bin = $flow_bin"
puts $f_for_prsrpt "set prev_bin = $base_bin"
puts $f_for_prsrpt "set flow_dir = $flow_dir"
puts $f_for_prsrpt "set base_dir = $base_dir"
puts $f_for_prsrpt "set flow_bin = $flow_bin"
puts $f_for_prsrpt "set base_bin = $base_bin"
close $f_for_prsrpt
set f_for_prsrpt [open dir_info_tcl w+]
puts $f_for_prsrpt "set branch $branch"
puts $f_for_prsrpt "set rpt_dir ${rpt_dir}/${flow_bin}_pre_cmp"
puts $f_for_prsrpt "set latest ${latest}"
puts $f_for_prsrpt "set prev ${prev}"
puts $f_for_prsrpt "set repeat_dir ${rpt_dir}/${flow_bin}_repeat"
puts $f_for_prsrpt "set latest_dir /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}"
puts $f_for_prsrpt "set prev_dir /remote/pv/24x7/nwtn/${branch}/sunna/Reg_QoR/${prev}"
puts $f_for_prsrpt "set latest_bin $flow_bin"
puts $f_for_prsrpt "set prev_bin $base_bin"
puts $f_for_prsrpt "set flow_dir $flow_dir"
puts $f_for_prsrpt "set base_dir $base_dir"
puts $f_for_prsrpt "set flow_bin $flow_bin"
puts $f_for_prsrpt "set base_bin $base_bin"
close $f_for_prsrpt
#####################

if {[file exist all_runpack.list]} {
   exec rm -rf all_runpack.list
}
exec find $flow_dir -name "runpack.csh" > all_runpack.list
#if {[file exists /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/latest/kickoff_pack.log]} {
#  exec rm -rf /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/latest/kickoff_pack.log
#}
set fp_kickoff_test [open kickoff_test_pack.csh w+]
set fp_kickoff_base [open kickoff_base_pack.csh w+]
set fp_repeat [open kickoff_repeat.csh w+]
puts $fp_kickoff_test "#! /bin/csh -f"
puts $fp_kickoff_base "#! /bin/csh -f"
puts $fp_repeat "#! /bin/csh -f"
set fp [open all_runpack.list r]
if {[file exists /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_test.log]} {
  exec rm -rf /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_test.log
}
if {[file exist /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_base.log]} {
  exec rm -rf /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_base.log
}
if {[file exist /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_repeat.log]} {
  exec rm -rf /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_repeat.log
}
exec touch /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_test.log
exec touch /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_base.log
exec touch /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_repeat.log

while {![eof $fp]} {
   set is_test 0
   set is_base 0
   set one [gets $fp]
   #puts $one
   if {[llength $one]>0} {
      set flow [lindex [split $one /] end-1]
      set packdir [join [lrange [split $one /] 10 end-1] /]
      set path [join [lrange [split $one /] 0 end-1] /]
      exec find $path -name "*repeat*" | xargs rm -rf
      if {[string match test_* $flow]} {
         if {![catch {glob $path/*.tcl}]} {
           set tcl [glob $path/*.tcl]
           set tcln [lindex [split $tcl /] end]
           set rtcl [lrange [split $tcln .] 0 end-1]
           exec sed "/rpt_.*\.out/{s/\.out/_repeat\.out/}" $tcl > $path/${rtcl}_repeat.tcl
         }
         exec sed "s/\.tcl/_repeat\.tcl/" $one > $path/runpack_repeat.csh
         exec sed -i "s/tee log/tee repeat_log/" $path/runpack_repeat.csh
         exec chmod 777 $path/runpack_repeat.csh 
         set is_test 1
         set is_base 0
         regsub "test" $flow "base" flow_base
         set packdir_tmp [lrange [split $packdir /] 0 end-1]
         set packdir_tmp [concat $packdir_tmp $flow_base]
         set packdir_base [join $packdir_tmp /]
         if {![catch {glob $base_dir/$packdir_base/*.pack.gz}]} {
            set packname [glob $base_dir/$packdir_base/*.pack.gz]
            if {![catch {glob $flow_dir/$packdir/*.pack.gz}]} {
              set packln [glob $flow_dir/$packdir/*.pack.gz]
              if {[llength $packln]>0} {
               foreach p $packln {
                  exec rm -rf $p
               }
              }
            }
            exec ln -s $packname $flow_dir/$packdir/
            set have_test 1
         }
      } else {
         set is_base 1
         set is_test 0
      }

      if {$is_test==1} {
         puts $fp_kickoff_test "cd ${flow_dir}/${packdir}"
         puts $fp_kickoff_test "rm -rf *.nlib"
         puts $fp_kickoff_test "qsub -l \"hconfig=sbg26o2a|sbg26o2a4|sbg26o2a16|sbg26o2b4|hwl26d2a|hwl26d2a4|wsm26h2b|gtn26q2a|gtn26q2b\" runpack.csh >> /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_test.log"
         puts $fp_kickoff_test "sleep 1"                                                                              
         puts $fp_kickoff_test "\n"

         puts $fp_repeat "cd ${flow_dir}/${packdir}"
         puts $fp_repeat "rm -rf *.nlib"
         puts $fp_repeat "qsub -l \"hconfig=sbg26o2a|sbg26o2a4|sbg26o2a16|sbg26o2b4|hwl26d2a|hwl26d2a4|wsm26h2b|gtn26q2a|gtn26q2b\" runpack_repeat.csh >> /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_repeat.log"
         puts $fp_repeat "sleep 1"                                                                              
         puts $fp_repeat "\n"
      }
      if {$is_base==1} {
         puts $fp_kickoff_base "cd ${flow_dir}/${packdir}"
         puts $fp_kickoff_base "rm -rf *.nlib"
         puts $fp_kickoff_base "qsub -l \"hconfig=sbg26o2a|sbg26o2a4|sbg26o2a16|sbg26o2b4|hwl26d2a|hwl26d2a4|wsm26h2b|gtn26q2a|gtn26q2b\" runpack.csh >> /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}/kickoff_pack_base.log"
         puts $fp_kickoff_base "sleep 1"                                                                              
         puts $fp_kickoff_base "\n"
      }
      
   }
}
puts $fp_kickoff_test "cd /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}"
puts $fp_kickoff_base "cd /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}"
puts $fp_repeat "cd /remote/us01home24/sunna/24x7/nwtn/${branch}/sunna/Reg_QoR/${latest}"


puts $fp_kickoff_test "#! /bin/csh -f"
puts $fp_kickoff_test "awk \'\/Your job\/ \{print \$3\}\' kickoff_pack_test.log > ! __tmp"
puts $fp_kickoff_test "sed -i \'1iset job_id \{\' __tmp"
puts $fp_kickoff_test "echo \"\}\" >> __tmp"
puts $fp_kickoff_test "\/remote\/us01home24\/sunna\/proj_disk\/NT\/ABUF_ENH\/BT\/scripts\/job_done.tcl"
puts $fp_kickoff_test "rm -rf __tmp"

puts $fp_repeat "#! /bin/csh -f"
puts $fp_repeat "awk \'\/Your job\/ \{print \$3\}\' kickoff_pack_repeat.log >>  __tmp"
puts $fp_repeat "sed -i \'1iset job_id \{\' __tmp"
puts $fp_repeat "echo \"\}\" >> __tmp"
puts $fp_repeat "\/remote\/us01home24\/sunna\/proj_disk\/NT\/ABUF_ENH\/BT\/scripts\/job_done.tcl"
puts $fp_repeat "rm -rf __tmp"
   

close $fp_kickoff_test
close $fp_kickoff_base
close $fp_repeat
close $fp

set fp [open monitor_base.csh w+]
puts $fp "#! /bin/csh -f"
puts $fp "awk \'\/Your job\/ \{print \$3\}\' kickoff_pack_base.log >>  __tmp"
puts $fp "sed -i \'1iset job_id \{\' __tmp"
puts $fp "echo \"\}\" >> __tmp"
puts $fp "\/remote\/us01home24\/sunna\/proj_disk\/NT\/ABUF_ENH\/BT\/scripts\/job_done.tcl"
puts $fp "rm -rf __tmp" 
close $fp

exec chmod 777 kickoff_test_pack.csh
exec chmod 777 kickoff_base_pack.csh
exec chmod 777 kickoff_repeat.csh
exec chmod 777 monitor_base.csh         
exit




