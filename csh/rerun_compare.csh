#!/bin/csh
source ~phyan/.cshrc

set PV_24x7_IMAGE = "/u/nwtnmgr/image/L-2016.03-SP-DEV/D20160308_3141899/Testing"   
set bjob_server = "-l minslotmem=16G"

set dir_list = `ls phyan*`
set dir_num = `ls phyan* | wc -l`

set i = 1
while ($i <= $dir_num)
  set dir = `echo $dir_list[$i] | awk '{print substr($0,0,length($0)-1)}'`
  set tmp_var = `ls -lrt $dir`
  set abs_dir = $tmp_var[11]

  echo "handling $dir_list[$i]"
  cd $abs_dir/
  echo "Kick off job..."
  qsub $bjob_server -o run.log "/u/szhang/pv/bin/localdisk ${PV_24x7_IMAGE}/linux64/nwtn/bin/icc2_exec -f run.tcl"  
  cd -

  @ i = $i + 1
end
      
