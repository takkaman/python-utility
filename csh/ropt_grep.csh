#!/bin/csh -f
set log = $argv[1]
grep 'Route-opt optimization' $log | sed 's/Route-opt optimization//'
exit
