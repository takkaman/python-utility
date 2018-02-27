open_lib $env(lib_name)

exec mkdir $env(duo_work)/$env(design_name)

if {[catch {open_block $env(design_name)}]} {
    echo "open design error!"
    echo "    design issue" >  $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
}


set sh_continue_on_error true
set w1 12
set w2 25

link -force

set get_path_str "get_timing_paths"
set path_rpt_str "report_timing"
if {[file exist $env(duo_work)/run_option.tmp]} {
    set path_info [sh cat $env(duo_work)/run_option.tmp]
    foreach one_info $path_info {
        append get_path_str " $one_info "
        append path_rpt_str " $one_info "
    }
}

proc dump_gif { filename } {
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting viewshot -value ${filename}.bmp
    exec convert ${filename}.bmp ${filename}.gif
    file delete ${filename}.bmp
}

set env(DISPLAY) pvicc014:121.0


set path ""
set path [eval $get_path_str]
if {$path != ""} {
    start_gui
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showVoltageArea -value true
    change_selection $path
    dump_gif $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).path.snapshot     
    stop_gui

    append path_rpt_str " -transition_time -input_pins -nets"
    eval $path_rpt_str > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).path.rpt
    set slack [get_attribute $path slack]
    echo [format "%*s%*s" $w1 present $w1 $slack ] > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
}  else {
    echo [format "%*s%*s" $w1 "not present" $w1 NA ] > $env(duo_work)/$env(design_name)/$env(lib_name).$env(design_name).info
}

close_block
close_lib
exit
