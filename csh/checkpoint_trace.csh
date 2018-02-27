#!/bin/csh -f
set min = $argv[1]
set max = $argv[2]

set j = $min
while($j <= $max)
   cd run_$j
   grep -E -H '^Error:' random.log | uniq > error_log
   grep -E -H '\(common check\) Wrong' random.log | uniq > common_check_log
   grep -H "Thank you for using IC Compiler II" random.log | uniq > real_finish     
   @ j = $j + 1
   cd ..
end    
