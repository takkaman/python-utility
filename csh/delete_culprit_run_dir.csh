#! /bin/csh -f 
source dir_info_csh

find R*/ICC2/Feature/*/*/*/*/*/tmp_test/run_dir*/run/ -name "[0-9]*" -type d | xargs rm -rf
find R*/ICC2/Feature/*/*/*/*/tmp_test/run_dir*/run/ -name "[0-9]*" -type d | xargs rm -rf
