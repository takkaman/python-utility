#!/bin/csh -f
setenv SGE_ROOT /remote/sge3/default

set ARCH = `$SGE_ROOT/util/arch`
set DEFAULTMANPATH = `$SGE_ROOT/util/arch -m`
set MANTYPE = `$SGE_ROOT/util/arch -mt`

setenv SGE_CELL galapagos
setenv SGE_CLUSTER_NAME us01_uge_galapagos
unsetenv SGE_QMASTER_PORT
unsetenv SGE_EXECD_PORT

# library path setting required only for architectures where RUNPATH is not supported
if ( $?MANPATH == 1 ) then
   setenv MANPATH $SGE_ROOT/${MANTYPE}:$MANPATH
else
   setenv MANPATH $SGE_ROOT/${MANTYPE}:$DEFAULTMANPATH
endif

set path = ( $SGE_ROOT/bin/$ARCH $path )
switch ($ARCH)
case "sol*":
case "lx*":
case "hp11-64":
   breaksw
case "*":
   set shlib_path_name = `$SGE_ROOT/util/arch -lib`
   if ( `eval echo '$?'$shlib_path_name` ) then
      set old_value = `eval echo '$'$shlib_path_name`
      setenv $shlib_path_name "$SGE_ROOT/lib/$ARCH":"$old_value"
   else
      setenv $shlib_path_name $SGE_ROOT/lib/$ARCH
   endif
   unset shlib_path_name  old_value
endsw
unset ARCH DEFAULTMANPATH MANTYPE
setenv SGE_JSV_TIMEOUT 100
