proc pre_check_log {rpt go} {
  set go 1
  if {![catch {exec grep "Design.*(Setup)" $rpt}]} {
     set WNS [exec grep "Design.*(Setup)" $rpt | awk {{print $3}}]
     if {$WNS=="--"} {
        set go 0
     }
  } else {
    set go 0
  }

  if {[catch {exec grep -m1 "max_transition" $rpt}]} {
     set go 0
  } 

  if {[catch {exec grep "Max Trans Violations" $rpt}]} {
     set go 0
  } 

  if {[catch {exec grep "All cpu is" $rpt}]} {
     set go 0
  }

  if {[catch {exec grep "Peak memory is" $rpt}]} {
     set go 0
  }

  if {[catch {exec grep "Buf/Inv Cell Count" $rpt}]} {
     set go 0
  }

  if {[catch {exec grep "Buf/Inv Area" $rpt}]} {
     set go 0
  }

  if {[catch {exec grep "Cell Area (netlist and physical only)" $rpt}]} {
     set go 0
  }

  return $go
}
