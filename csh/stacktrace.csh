#!/bin/csh -f
set min = $argv[1]
set max = $argv[2]

set i = $min

while($i <= $max)
   cd run_$i
   set icc2_image = (`awk '/Version .* for .* -/ {print $0}' random.log | awk '{if(match($0,/ \- (\w+) (\w+), (\w+)/,arr)) print arr[1],arr[2],arr[3]}'`)
   switch ($icc2_image[1])
     case "Jan":
       set month = 01
       breaksw 
     case "Feb":
       set month = 02
       breaksw        
     case "Mar":
       set month = 03
       breaksw 
     case "Apr":
       set month = 04
       breaksw 
     case "May":
       set month = 05
       breaksw 
     case "Jun":
       set month = 06
       breaksw
     case "Jul":
       set month = 07
       breaksw
     case "Aug":
       set month = 08
       breaksw
     case "Sep":
       set month = 09
       breaksw
     case "Oct":
       set month = 10
       breaksw 
     case "Nov":
       set month = 11
       breaksw
     case "Dec":
       set month = 12
       breaksw
   endsw

   set day = $icc2_image[2]
   set year = $icc2_image[3]
   /remote/pv/bin/pvfatal random.log > stacktrace
   grep "Segmentation fault" random.log > abnormal_fatal
   grep "Thank you for using IC Compiler II" random.log > real_finish
#/remote/pv/bin/pvfatal -latest ${year}${month}${day} random.log > stacktrace
   @ i = $i + 1
   cd ..
end
