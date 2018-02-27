open_lib $env(lib_name)

exec mkdir  $env(duo_work)/$env(design_name)
if {[catch {open_block $env(design_name)}]} {
    echo "open design error!"
    echo "    design issue" >  $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
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

set net_name [sh cat $env(duo_work)/run_option.tmp]

if {[sizeof_collection [get_nets -quiet $net_name]] != 0}  {
    start_gui
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value true
    change_selection [get_nets $net_name]
    dump_gif $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).net.snapshot
    stop_gui
}

set net_driver_pin [get_pins -quiet -of_objects [get_nets -quiet -segments $net_name] -filter "is_hierarchical == false && direction == out"]

if {$net_driver_pin != ""} {
    echo $net_name
} else {
    set net_driver_pin [get_ports -quiet -of_objects [get_nets -quiet -segments $net_name] -filter "direction == out"]
}

set net_loads [get_pins -quiet -of_objects [get_nets -quiet -segments $net_name] -filter "is_hierarchical == false && direction == in"]

if {$net_loads == ""} {
    set net_loads [get_ports -quiet -of_objects [get_nets -quiet -segments $net_name] -filter "direction == out"]
}
#if {$net_driver_pin != ""} {
#    set trans [get_attribute $net_driver_pin late_fall_transition ]
#} else {
#    set trans "NA"
#}
if {$net_loads != ""}  {
    set trans [get_attribute [index_collection $net_loads 0] late_fall_transition ]
    set trans_con [get_attribute [index_collection $net_loads 0] max_transition_constraint]
} else {
    set trans "NA"
    set trans_con "NA"
}

set fanout [sizeof_collection $net_loads]

echo $trans
echo 
echo $fanout
echo "    $trans    $trans_con    $fanout" > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info


close_block
close_lib
exit
