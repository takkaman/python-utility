proc prepare_chkp_file {rpt cmd case_info} {
  if {[file exist chkp.log]} {
     file delete chkp.log
  }
  if {![catch {exec grep "Design.*(Setup)" $rpt}]} {
     set WNS [exec grep "Design.*(Setup)" $rpt | awk {{print $3}}]
     set TNS [exec grep "Design.*(Setup)" $rpt | awk {{print $4}}]
     set NVP [exec grep "Design.*(Setup)" $rpt | awk {{print $5}}]
     if {$WNS=="--"} {
        set WNS ""
     }
  } else {
     set WNS ""
     set TNS ""
     set NVP ""
  }
  if {![catch {exec grep -m1 "max_transition" $rpt}]} {
     set TranCost [exec grep -m1 "max_transition" $rpt | awk {{print $2}}]
  } else {
     set TranCost ""
  }
  if {![catch {exec grep "Max Trans Violations" $rpt}]} {
     set TranNVP [exec grep "Max Trans Violations" $rpt | awk {{print $4}}]
  } else {
     set TranNVP ""
  }
  if {![catch {exec grep "All cpu is" $rpt}]} {
     set CPU [exec grep "All cpu is" $rpt | awk {{print $4}}]
  } else {
     set CPU ""
  }
  if {![catch {exec grep "Peak memory is" $rpt}]} {
     set MEM [exec grep "Peak memory is" $rpt | awk {{print $4}}]
     set MEM [expr $MEM/1024]
  } else {
     set MEM ""
  }
  if {$TranNVP!="" && $TranCost!=""} {
     if {$TranNVP!=0} {
        set TranAvg [format %.2f [expr $TranCost/$TranNVP]]
     } else {
        set TranAvg 0
     }
  } else {
      set TranAvg ""
  }

  if {![catch {exec grep "Buf/Inv Cell Count" $rpt}]} {
     set BufCnt [exec grep -m1 "Buf/Inv Cell Count" $rpt | awk {{print $4}}]
  } else {
     set BufCnt 0
  }

  if {![catch {exec grep "Buf/Inv Area" $rpt}]} {
     set BufArea [exec grep -m1 "Buf/Inv Area" $rpt | awk {{print $3}}]
  } else {
     set BufArea 0
  }

  if {![catch {exec grep "Cell Area (netlist and physical only)" $rpt}]} {
     set TotalArea [exec grep -m1 "Cell Area (netlist and physical only)" $rpt | awk {{print $7}}]
  } else {
     set TotalArea 0
  }

  if {![catch {exec grep "HFN over 60 is" $rpt}]} {
     set HFN_60 [exec grep "HFN over 60 is" $rpt | awk {{print $5}}]
  } else {
     set HFN_60 0
  }
  if {![catch {exec grep "HFN over 100 is" $rpt}]} {
     set HFN_100 [exec grep "HFN over 100 is" $rpt | awk {{print $5}}]
  } else {
     set HFN_100 0
  }

  if {![catch {exec grep "Buffer removal is" $rpt}]} {
     set BufRmvl [exec grep "Buffer removal is" $rpt | awk {{print $4}}]
  } else {
     set BufRmvl -1
  }

  if {$WNS!="" && $TNS!="" && $NVP!="" && $TranCost!="" && $TranNVP!="" && $CPU!="" && $MEM!="" && $TranAvg!=""} {
      set fp [open chkp.log w+]
      puts $fp "case_path: case_path source: reg cmd: $cmd ICPWNS: $WNS ICPTNSPM: $TNS ICPOPTMEM: $MEM ICPNVP: $NVP ICPOPTCPU: $CPU ICPMaxTCostPM: $TranCost ICPNMxTranPM: $TranNVP ICPBufInvCnt: $BufCnt ICPBufInvArea: $BufArea ttl_area: $TotalArea HFN60: $HFN_60 HFN100: $HFN_100 buf_removal: $BufRmvl"
      close $fp
      set case_info "$WNS $TNS $NVP $TranAvg $MEM $CPU $TranCost $TranNVP $BufCnt $BufArea $TotalArea $HFN_60 $HFN_100 $BufRmvl"
  } else {
      set case_info ""
  }
  return $case_info
}
