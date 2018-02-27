#!/bin/csh -f
set log = $argv[1]
grep 'Global-route-opt optimization' $log | sed 's/Global-route-opt optimization//'
exit
