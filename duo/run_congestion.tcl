open_lib $env(lib_name)
exec mkdir $env(duo_work)/$env(design_name)
source /u/phyan/random_icc2/utility/icc2_common_proc.tcl

if {[catch {open_block $env(design_name)}]} {
    echo "open design error!"
    echo "    design issue" >  $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
}

link -force
update_timing -full
#redirect -tee $env(lib_name).$env(design_name).info {cell_info  $env(cell_name)}
#proc dump_gif { filename } {
#    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting viewshot -value ${filename}.bmp
#    exec convert ${filename}.bmp ${filename}.gif
#    file delete ${filename}.bmp
#}
set env(DISPLAY) pvicc014:121.0

start_gui
dump_cm $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).congestion.snapshot
stop_gui
echo " " > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info


close_block -force
close_lib
exit

