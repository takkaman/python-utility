#!/bin/csh 
source /remote/us01home40/phyan/.cshrc      
set rpt_log = $argv[1]
#wns
set wns_compare = `awk '/Design.*\(Setup\)/ {print $3}' $rpt_log` 

#tns   
set tns_compare = `awk '/Design.*\(Setup\)/ {print $4}' $rpt_log`

#buffer count
set buff_count_compare = `awk '/^Buf\/Inv Cell Count:/ {print $4}' $rpt_log`        

#area
set area_compare = `awk '/^Cell Area \(netlist and physical only\):/ {v=$7} END {print v}' $rpt_log`
set buff_area_compare = `awk '/^Buf\/Inv Area:/ {print $3}' $rpt_log `    

#max_trans
set max_tran_compare = `awk '/max_transition.*(MET|VIOLATED)/{print $2}' $rpt_log`
set max_tran_vio_num = `awk '/Max Trans Violations:/{print $4}' $rpt_log`

#mem
set mem_compare = `awk '/Maximum memory usage for this session:/{print $7}' $rpt_log`        

#run time
set cpu_compare = `awk '/CPU usage for this session:/{print $6}' $rpt_log`        

#hfn
set hfn60 = `awk '/HFN over 60 is/ {print $5}' $rpt_log`
set hfn100 = `awk '/HFN over 100 is/ {print $5}' $rpt_log` 

#filter design to check in
echo "case_info: 0 source: random cmd: popt wns: $wns_compare tns: $tns_compare max_tran_avg: 0 memory: $mem_compare cpu: $cpu_compare max_tran_cost: $max_tran_compare max_tran_vio_num: $max_tran_vio_num buff_count: $buff_count_compare buff_area: $buff_area_compare ttl_area: $area_compare hfn: $hfn60 $hfn100"| tee checkin_design_data
#call external program to do the checkin       
