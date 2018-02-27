#!/bin/csh
#mkdir auto
#cp replay_pkg/replay.tcl replay_pkg/replay.log .
#cp replay.tcl auto/auto_verify.tcl
#cp replay.log auto/auto_verify.out

cp -rf replay_pkg auto
mv auto/replay.tcl auto/auto_verify.tcl
mv auto/replay.log auto/auto_verify.out

chmod -R 777 replay_pkg
