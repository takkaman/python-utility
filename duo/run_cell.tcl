open_lib $env(lib_name)
exec mkdir $env(duo_work)/$env(design_name)

if {[catch {open_block $env(design_name)}]} {
    echo "open design error!"
    echo "    design issue" >  $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
}

link -force
source [getenv duo_dir]/cell_info.tcl
#redirect -tee $env(lib_name).$env(design_name).info {cell_info  $env(cell_name)}
proc dump_gif { filename } {
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting viewshot -value ${filename}.bmp
    exec convert ${filename}.bmp ${filename}.gif
    file delete ${filename}.bmp
}

set env(DISPLAY) pvicc014:121.0

set cell_name [sh cat $env(duo_work)/run_option.tmp]

if {[sizeof_collection [get_cells -quiet $cell_name]] != 0}  {
    start_gui
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value true
    change_selection [get_cells $cell_name]
    dump_gif $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).cell.snapshot
    stop_gui
}
cell_info  $cell_name >  $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
close_block
close_lib
exit
