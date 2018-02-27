#!/bin/csh           

set dir_list = `ls .`
set dir_num = `ls . | wc -l`

set i = 1
while ($i <= $dir_num)
  set dir = `echo $dir_list[$i] | awk '{print substr($0,0,length($0)-1)}'`
  set tmp_var = `ls -lrt $dir`
  set abs_dir = $tmp_var[11]
  cd $abs_dir/
  sed -e "/\(set_app_options -list\|place_opt\.\|place\.\|opt\.\|refine_opt\.\|route\.\|power\.\)/d" replay.tcl >! run.tcl
  cd -
  @ i = $i + 1
end

