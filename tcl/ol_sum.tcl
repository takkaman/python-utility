#!/usr/bin/tclsh

source dir_info_tcl
exec rm -rf postmail
exec mkdir postmail

set htmldir "http://prs${rpt_dir}/html/"

exec grep -A8 "tr data-item='html/ICPWNS' class=" $rpt_dir/outlier.html > postmail/icpwns
exec sed -i "/unote/d" postmail/icpwns
exec sed -i "/autosum/d" postmail/icpwns
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpwns

exec grep -A8 "tr data-item='html/ICPTNSPM' class=" $rpt_dir/outlier.html > postmail/icptnspm
exec sed -i "/unote/d" postmail/icptnspm
exec sed -i "/autosum/d" postmail/icptnspm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icptnspm

exec grep -A8 "tr data-item='html/ICPNVioPPM' class=" $rpt_dir/outlier.html > postmail/icpnvioppm
exec sed -i "/unote/d" postmail/icpnvioppm
exec sed -i "/autosum/d" postmail/icpnvioppm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpnvioppm

exec grep -A8 "tr data-item='html/ICPMaxTCostPM' class=" $rpt_dir/outlier.html > postmail/icpmaxtcostpm
exec sed -i "/unote/d" postmail/icpmaxtcostpm
exec sed -i "/autosum/d" postmail/icpmaxtcostpm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpmaxtcostpm

exec grep -A8 "tr data-item='html/ICPBufInvCnt' class=" $rpt_dir/outlier.html > postmail/icpbufinvcnt
exec sed -i "/unote/d" postmail/icpbufinvcnt
exec sed -i "/autosum/d" postmail/icpbufinvcnt
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpbufinvcnt

exec grep -A8 "tr data-item='html/ICPBufInvArea' class=" $rpt_dir/outlier.html > postmail/icpbufinvarea
exec sed -i "/unote/d" postmail/icpbufinvarea
exec sed -i "/autosum/d" postmail/icpbufinvarea
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpbufinvarea
            
exec grep -A8 "tr data-item='html/ICPOPTCPU' class=" $rpt_dir/outlier.html > postmail/icpoptcpu
exec sed -i "/unote/d" postmail/icpoptcpu
exec sed -i "/autosum/d" postmail/icpoptcpu
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpoptcpu

exec grep -A8 "tr data-item='html/ICPOPTMEM' class=" $rpt_dir/outlier.html > postmail/icpoptmem
exec sed -i "/unote/d" postmail/icpoptmem
exec sed -i "/autosum/d" postmail/icpoptmem
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icpoptmem

exec grep -A8 "tr data-item='html/ICPHFN100' class=" $rpt_dir/outlier.html > postmail/icphfn100
exec sed -i "/unote/d" postmail/icphfn100
exec sed -i "/autosum/d" postmail/icphfn100
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icphfn100



exec grep -A8 "tr data-item='html/ICCWNS' class=" $rpt_dir/outlier.html > postmail/iccwns
exec sed -i "/unote/d" postmail/iccwns
exec sed -i "/autosum/d" postmail/iccwns
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccwns

exec grep -A8 "tr data-item='html/ICCTNSPM' class=" $rpt_dir/outlier.html > postmail/icctnspm
exec sed -i "/unote/d" postmail/icctnspm
exec sed -i "/autosum/d" postmail/icctnspm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icctnspm

exec grep -A8 "tr data-item='html/ICCNVioPPM' class=" $rpt_dir/outlier.html > postmail/iccnvioppm
exec sed -i "/unote/d" postmail/iccnvioppm
exec sed -i "/autosum/d" postmail/iccnvioppm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccnvioppm

exec grep -A8 "tr data-item='html/ICCMaxTCostPM' class=" $rpt_dir/outlier.html > postmail/iccmaxtcostpm
exec sed -i "/unote/d" postmail/iccmaxtcostpm
exec sed -i "/autosum/d" postmail/iccmaxtcostpm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccmaxtcostpm

exec grep -A8 "tr data-item='html/ICCBufInvCnt' class=" $rpt_dir/outlier.html > postmail/iccbufinvcnt
exec sed -i "/unote/d" postmail/iccbufinvcnt
exec sed -i "/autosum/d" postmail/iccbufinvcnt
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccbufinvcnt

exec grep -A8 "tr data-item='html/ICCBufInvArea' class=" $rpt_dir/outlier.html > postmail/iccbufinvarea
exec sed -i "/unote/d" postmail/iccbufinvarea
exec sed -i "/autosum/d" postmail/iccbufinvarea
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccbufinvarea
            
exec grep -A8 "tr data-item='html/ICCOPTCPU' class=" $rpt_dir/outlier.html > postmail/iccoptcpu
exec sed -i "/unote/d" postmail/iccoptcpu
exec sed -i "/autosum/d" postmail/iccoptcpu
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccoptcpu

exec grep -A8 "tr data-item='html/ICCOPTMEM' class=" $rpt_dir/outlier.html > postmail/iccoptmem
exec sed -i "/unote/d" postmail/iccoptmem
exec sed -i "/autosum/d" postmail/iccoptmem
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/iccoptmem

exec grep -A8 "tr data-item='html/ICCHFN100' class=" $rpt_dir/outlier.html > postmail/icchfn100
exec sed -i "/unote/d" postmail/icchfn100
exec sed -i "/autosum/d" postmail/icchfn100
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icchfn100
                       


exec grep -A8 "tr data-item='html/ICFWNS' class=" $rpt_dir/outlier.html > postmail/icfwns
exec sed -i "/unote/d" postmail/icfwns
exec sed -i "/autosum/d" postmail/icfwns
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfwns

exec grep -A8 "tr data-item='html/ICFTNSPM' class=" $rpt_dir/outlier.html > postmail/icftnspm
exec sed -i "/unote/d" postmail/icftnspm
exec sed -i "/autosum/d" postmail/icftnspm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icftnspm

exec grep -A8 "tr data-item='html/ICFNVioPPM' class=" $rpt_dir/outlier.html > postmail/icfnvioppm
exec sed -i "/unote/d" postmail/icfnvioppm
exec sed -i "/autosum/d" postmail/icfnvioppm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfnvioppm

exec grep -A8 "tr data-item='html/ICFMaxTCostPM' class=" $rpt_dir/outlier.html > postmail/icfmaxtcostpm
exec sed -i "/unote/d" postmail/icfmaxtcostpm
exec sed -i "/autosum/d" postmail/icfmaxtcostpm
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfmaxtcostpm

exec grep -A8 "tr data-item='html/ICFBufInvCnt' class=" $rpt_dir/outlier.html > postmail/icfbufinvcnt
exec sed -i "/unote/d" postmail/icfbufinvcnt
exec sed -i "/autosum/d" postmail/icfbufinvcnt
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfbufinvcnt

exec grep -A8 "tr data-item='html/ICFBufInvArea' class=" $rpt_dir/outlier.html > postmail/icfbufinvarea
exec sed -i "/unote/d" postmail/icfbufinvarea
exec sed -i "/autosum/d" postmail/icfbufinvarea
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfbufinvarea
            
exec grep -A8 "tr data-item='html/ICFOPTCPU' class=" $rpt_dir/outlier.html > postmail/icfoptcpu
exec sed -i "/unote/d" postmail/icfoptcpu
exec sed -i "/autosum/d" postmail/icfoptcpu
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfoptcpu

exec grep -A8 "tr data-item='html/ICFOPTMEM' class=" $rpt_dir/outlier.html > postmail/icfoptmem
exec sed -i "/unote/d" postmail/icfoptmem
exec sed -i "/autosum/d" postmail/icfoptmem
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfoptmem

exec grep -A8 "tr data-item='html/ICFHFN100' class=" $rpt_dir/outlier.html > postmail/icfhfn100
exec sed -i "/unote/d" postmail/icfhfn100
exec sed -i "/autosum/d" postmail/icfhfn100
exec sed -i "/href=/ {s#html\/#$htmldir#}" postmail/icfhfn100

############### 
set all_case_list [exec ls $rpt_dir/flow_${latest_bin}]
set pre_cts 0
set post_cts 0
set post_rt 0
foreach cl $all_case_list {
   set cmd_stage [lindex [split [lindex [split $cl -] end] _] 0]
   if {$cmd_stage=="popt" || $cmd_stage=="cplc" || $cmd_stage=="refopt" || $cmd_stage=="refplc" || $cmd_stage=="cbt"} {
      incr pre_cts
   } elseif {$cmd_stage=="copt"} {
      incr post_cts
   } else {
      incr post_rt
   }
}


set fp [open postmail/mail_add w+]
puts $fp "<li>Number of test case"
puts $fp "<ul>"
puts $fp "<li>Pre CTS case: $pre_cts<\/li>"
puts $fp "<li>Post CTS case:   $post_cts<\/li>"
puts $fp "<li>Post Route case: $post_rt<br><\/br><\/li>"
puts $fp "<\/ul>"
puts $fp "<\/li>"
close $fp

exec sed -i "$ r /remote/us01home24/sunna/proj_disk/NT/reg_qor/mail_summary/mail_head" postmail/mail_add
#exec cp -f /remote/us01home24/sunna/proj_disk/NT/reg_qor/mail_summary/mail_head postmail

set trcol "icpwns icptnspm icpnvioppm icpmaxtcostpm icpbufinvcnt icpbufin icpoptcpu icpoptmem icphfn100 \
           iccwns icctnspm iccnvioppm iccmaxtcostpm iccbufinvcnt iccbufin iccoptcpu icfoptmem icchfn100 \
           icfwns icftnspm icfnvioppm icfmaxtcostpm icfbufinvcnt icfbufin icfoptcpu icfoptmem icfhfn100"
           
set w_ol ""
set wo_ol ""
for {set i 0} {$i < [llength $trcol]} {incr i} {
   set c [lindex $trcol $i]
   if {![catch {exec grep "outlier-clean" postmail/$c}]} {
      set wo_ol [concat $wo_ol $c]
   } else {
      set w_ol [concat $w_ol $c]
   }
}


for {set i 0} {$i < [llength $w_ol]} {incr i} {
   set c [lindex $w_ol $i]
   exec sed -i "$ r postmail/$c" postmail/mail_add
}
   
#for {set i 0} {$i < [llength $wo_ol]} {incr i} {
#   set c [lindex $wo_ol $i]
#   exec sed -i "$ r postmail/$c" postmail/mail_head
#}

exec sed -i "$ a <\/table>" postmail/mail_add
exec sed -i "$ a </ul>" postmail/mail_add
exec sed -i "$ a &nbsp<\/br>" postmail/mail_add 
exec sed -i "$ a &nbsp<\/br>" postmail/mail_add 
  
exec sed -i "/ADD HERE/r postmail/mail_add" $rpt_dir/mail
exec sed -i "/ADD HERE/d" $rpt_dir/mail

exec /usr/sbin/sendmail -t < ${rpt_dir}/mail
exit
