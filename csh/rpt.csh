#!/bin/csh           
cd base

set dir_list = `ls .`
set dir_num = `ls . | wc -l`

set i = 1
while ($i <= $dir_num)
  set dir = `echo $dir_list[$i] | awk '{print substr($0,0,length($0)-1)}'`
  set tmp_var = `ls -lrt $dir`
  set abs_dir = $tmp_var[11]
  cd $abs_dir/

  rm -rf *.ic*.out *.all.csh *.all.done
  ln -s run.log design.icpopt.out
  ln -s rpt.log design.icprpt.out
  touch design.all.csh
  touch design.all.done

  cd -
  @ i = $i + 1
end

cd ../compare

set dir_list = `ls .`
set dir_num = `ls . | wc -l`

set i = 1
while ($i <= $dir_num)
  set dir = `echo $dir_list[$i] | awk '{print substr($0,0,length($0)-1)}'`
  set tmp_var = `ls -lrt $dir`
  set abs_dir = $tmp_var[11]
  cd $abs_dir/

  rm -rf *.ic*.out *.all.csh *.all.done
  ln -s run.log design.icpopt.out
  ln -s rpt.log design.icprpt.out
  touch design.all.csh
  touch design.all.done

  cd -
  @ i = $i + 1
end

cd ..

/remote/us01home40/phyan/random_icc2/report.csh

