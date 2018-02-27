#!/bin/csh
cp -rf auto replay_pkg
mv replay_pkg/auto_verify.tcl replay_pkg/replay.tcl
mv replay_pkg/auto_verify.out replay_pkg/replay.log
chmod -R 777 replay_pkg

