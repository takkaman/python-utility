open_lib $env(lib_name)

exec mkdir $env(duo_work)/$env(design_name)
if {[catch {open_block $env(design_name)}]} {
    echo "open design error!"
    echo "    design issue" > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
}

link -force
update_timing -full
#redirect -tee $env(lib_name).$env(design_name).info {cell_info  $env(cell_name)}
proc dump_gif { filename } {
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting viewshot -value ${filename}.bmp
    exec convert ${filename}.bmp ${filename}.gif
    file delete ${filename}.bmp
}

set env(DISPLAY) pvicc014:121.0

start_gui
gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
gui_load_cell_density_mm

dump_gif $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).density.snapshot

echo " " > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info


close_block
close_lib
exit

