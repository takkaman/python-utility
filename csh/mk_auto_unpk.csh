#!/bin/csh
cd auto
rm -rf auto replay.tcl
mv pack_star_replay.out auto_verify.out
mv pack_star_replay.tcl auto_verify.tcl
cd ..

cp -rf auto replay_pkg
mv replay_pkg/auto_verify.tcl replay_pkg/replay.tcl
mv replay_pkg/auto_verify.out replay_pkg/replay.log
chmod -R 777 replay_pkg

cp /remote/us01home40/phyan/not_use_pack .
