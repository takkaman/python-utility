#!/bin/csh 
set run_case = $argv[1]
set run_img = $argv[2]
set run_num = $argv[3]

set i = 1
while ($i <= $run_num)
  $run_img -f $run_case | tee log_${i}
  @ i = $i + 1
end
      
