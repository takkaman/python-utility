#!/bin/csh -f

set origin_path = $argv[1]
set new_path = $argv[2]

echo "You are to move case under $argv[1] to $argv[2], case list fetched from L-2016.03-SP1"

set root = "/remote/pv/regression/p4_client/L-2016.03-SP1/ICC2/Feature/"
set case_list = `find $root/$origin_path -max_depth 1 -name "*.tcl"`

foreach case ($case_list)
  set case_name = `echo $case | awk '{split($0,a,"/"); print a[length(a)]}'`
  echo "$origin_path/$case_name $new_path/$case_name" >> case_file
end  
  
