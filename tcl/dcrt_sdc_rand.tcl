########
# HEAD #
########
##to use pv::icc::rand##
source /remote/pv/CSS/project/PV-ZRAND/lib/srand.dev.tcl
##to dump cmds to other files##
package require pv::ui
pv::ui::use dcrt

##proc_namespace##
namespace eval dcrt_sdc {
    variable cmd_list

    variable average_cap
    variable min_cap
    variable max_cap
    variable period_value
	
    variable cons_count

    variable inst_chosen
    variable obj_chosen

    variable count_num

    variable period_set

    variable ideal_network_list
    variable design_collection
    variable clock_collection
    variable gen_clk_collection
    variable cell_collection
    variable input_collection
    variable output_collection
    variable pin_collection
    variable seq_cell_collection
    variable com_cell_collection
    variable clk_pin_collection
    variable data_pin_collection
    variable unate_cell_collection
    variable leaf_clk_cell_collection
    variable leaf_clk_pin_collection
}

proc initialize {} {
    set dcrt_sdc::pre_cmd_list { \
	"create_clock" \
	"set_propagated_clock" \
    }
    set dcrt_sdc::cmd_list { \
	"set_max_time_borrow" \
	"set_drive" \
	"set_fanout_load" \
	"set_max_transition" \
	"set_timing_derate" \
	"set_case_analysis" \
	"set_false_path" \
	"set_max_delay" \
	"set_min_delay" \
	"set_input_transition" \
	"set_input_delay" \
	"set_output_delay" \
	"set_clock_latency" \
	"set_clock_transition" \
	"set_clock_uncertainty" \
	"set_clock_sense" \
	"set_disable_timing" \
	"set_ideal_network" \
	"set_ideal_latency" \
	"set_ideal_transition" \
    }
    file mkdir sdc
    echo "PV-SDC-INFO:initializing ..=_=.. update timing"
    # in order to get timing-related attribute
    update_timing

    dcrt_sdc::init_get_period
    dcrt_sdc::init_get_capacitance
    echo "PV-SDC-INFO: Initializing ..=_=.. generate collection"
    set dcrt_sdc::design_collection ""
    set dcrt_sdc::ideal_network_list ""
    set dcrt_sdc::latch_collection [all_registers -level_sensitive]
    set dcrt_sdc::ff_collection [all_registers -edge_triggered]
    set dcrt_sdc::clock_collection [remove_from_collection [all_clocks] [get_clock [get_attribute [get_generated_clocks -quiet] master_clock -quiet] -quiet]]
    set dcrt_sdc::gen_clk_collection [get_generated_clocks -quiet]
    set dcrt_sdc::cell_collection [get_cells -hierarchical -quiet]
    set dcrt_sdc::input_collection [remove_from_collection [all_inputs] [get_object_name [all_clocks]]]
    set dcrt_sdc::output_collection [all_outputs]
    set dcrt_sdc::pin_collection [get_pins -hierarchical -quiet]
    set dcrt_sdc::seq_cell_collection [get_cells -hierarchical -filter "is_sequential == true" -quiet]
    set dcrt_sdc::com_cell_collection [get_cells -hierarchical -filter "is_combinational == true" -quiet]
    echo "Initializing ..+_+.. Please wait a while..."
    set dcrt_sdc::clk_pin_collection [get_pins -of_object [get_cells -hierarchical -filter "is_sequential == true || is_combinational == true" -quiet] -filter "is_clock_pin == true" -quiet]
    echo "Initializing ..+_+.. wait a while..."
    set dcrt_sdc::data_pin_collection [get_pins -of_object [get_cells -hierarchical -filter "is_sequential == true  || is_combinational == true" -quiet] -filter "is_data_pin == true" -quiet]
    echo "Initializing ..+_+.. a while..."
    set dcrt_sdc::unate_cell_collection [get_cells -of_object [get_pins -of_objects  [get_cells -hierarchical -filter "is_combinational == true" -quiet] -filter "is_clock_pin ==true" -quiet] -quiet -filter "ref_name =~ *XOR*"]
    echo "Initializing ..+_+.. while..."
    set dcrt_sdc::leaf_clk_cell_collection [get_cells -of_object [get_pins -of_object [get_cells -hierarchical -filter "is_hierarchical == false && (is_sequential == true || is_combinational == true)" -quiet] -filter "is_clock_pin == true" -quiet] -quiet]
    echo "Initializing ..+_+.. ..."
    set dcrt_sdc::leaf_clk_pin_collection [get_pins -of_object [get_cells -of_object [get_pins -of_object [get_cells -hierarchical -filter "is_hierarchical == false && (is_sequential == true || is_combinational == true)" -quiet] -filter "is_clock_pin == true" -quiet] -quiet] -filter "is_clock_pin == true || is_data_pin == true" -quiet]
    

    set all_cell_count [sizeof_collection $dcrt_sdc::cell_collection]
    set all_clock_count [sizeof_collection $dcrt_sdc::clock_collection]
    set all_port_count [expr [sizeof_collection $dcrt_sdc::input_collection] + [sizeof_collection $dcrt_sdc::output_collection]]
    set dcrt_sdc::cons_count [expr $all_clock_count * 2 + $all_cell_count / 100000 + $all_port_count / 200 + 5]
    if {$dcrt_sdc::cons_count > 100} {
	set dcrt_sdc::cons_count [pv::icc::rand_int 50 100]
    }
    echo "PV-SDC-INFO: $dcrt_sdc::cons_count constraints are intend to set.."
}


proc sdc_setup {design_name} {
    #set dcrt_sdc::random_cell [pv::icc::rand_cell $dcrt_sdc::cons_count [get_cells -hierarchical -filter "is_hierarchical == true"]]
    write_sdc -output ./sdc/${design_name}.sdcbefore.sdc
	
    set snwidth [string length $dcrt_sdc::cons_count]
    set dcrt_sdc::inst_chosen [list]
    set dcrt_sdc::obj_chosen [list]
    set dcrt_sdc::count_num 0
    set sdclog [open ./sdc/${design_name}.sdcrandom.sdc w+]
    
    for { set i 0 } { $i < $dcrt_sdc::cons_count } { incr i } {
	set sn [format "%0${snwidth}d" $i]
        if {$i < 3} {
	    set SDC_cmd [random_precmd]
	} elseif {$i == 3} {
	    update_timing
	    set SDC_cmd [random_SDCcmd]
	} else {
	    set SDC_cmd [random_SDCcmd]	    
	}
	if { $SDC_cmd == "set_ideal_latency" || $SDC_cmd == "set_ideal_transition" } {
	    if {[llength $dcrt_sdc::ideal_network_list] == 0} {
		echo "PV-SDC-INFO: No ideal network set, performing set_ideal_network first..."
		set SDC_cmd set_ideal_network
	    }
	}
	set return_list [dcrt_sdc::${SDC_cmd}_config]
	# return "0.$inst 1.$obj_type 2.$cstr_full"
	if { $return_list == 0 } {
	    echo "PV-SDC-INFO: $SDC_cmd is not avaliable in this design, ignored..."
	    set dcrt_sdc::cmd_list [ldelete $dcrt_sdc::cmd_list $SDC_cmd]
	    continue
	}
	#puts $SDC_cmd;#debug
	lappend dcrt_sdc::inst_chosen [lindex $return_list 0]
	set flag 1
	if { [catch {pv::eval [lindex $return_list 2]} res]} {
	    set flag 0
	    puts "[lindex $return_list 2] failed !!!"
	    echo "$res"
	}
	#echo "// [lindex $return_list 2] "
	#if { [lindex $return_list 1] == "clock" } {}
	#    update_timing
	#{}
	if { $SDC_cmd == "set_propagated_clock" || $SDC_cmd == "create_clock" } {
	    # update the clock && generated clock pool
	    set dcrt_sdc::clock_collection [remove_from_collection [all_clocks] [get_clock [get_attribute [get_generated_clocks -quiet] master_clock -quiet] -quiet]]
	    set dcrt_sdc::gen_clk_collection [get_generated_clocks -quiet]
	}
	if { $flag == 1} {
	    set mark "success"
	} elseif { $flag == 0} {
	    set mark "fail"
	    echo "PV-SDC-ERROR: [lindex $return_list 2] set failed."
	} else { 
	    set mark "unknown"
	    echo "PV-SDC-UNKNOWN: [lindex $return_list 2] set unknown."
	}

        puts $sdclog "# instance: [lindex $return_list 0]"
	puts $sdclog "# type: [lindex $return_list 1]"
        puts $sdclog [lindex $return_list 2]
        puts $sdclog ""

	set sn_array([lindex $return_list 0]) $sn

   	set inst_array(${sn}.inst) [lindex $return_list 0]
    	set inst_array(${sn}.obj_type) [lindex $return_list 1]
    	set inst_array(${sn}.cstr) $SDC_cmd 
    	set inst_array(${sn}.cstr_full) [lindex $return_list 2]
	set inst_array(${sn}.flag) $mark
	if { $mark == "success" } {
	    incr dcrt_sdc::count_num
	}
	#puts $i;#debug
    }
    echo "PV-SDC-INFO: $dcrt_sdc::count_num constraints are successfully set"
    close $sdclog
    write_sdc -output ./sdc/${design_name}.sdcafter.sdc
}

#########################
#   functional proc     #
#########################
proc dcrt_sdc::init_get_period {} {
    set period_list ""
    set period_list [get_attribute [get_clocks] period]
    set a [llength $period_list]
    if {$a > 0 && $a < 2} {
	set dcrt_sdc::period_value [lindex $period_list 0]
    } elseif {$a >= 2} {
	set b [lsort $period_list]
    	set dcrt_sdc::period_value [pv::icc::rand_float [lindex $b 0] [lindex $b end]]
    	echo "min_period:[lindex $b 0]   "
    	echo "max_period:[lindex $b end] "
    } else {
    	echo "the period_list is not valid"
    }
    echo "the period_value is: $dcrt_sdc::period_value"
}

proc dcrt_sdc::init_get_capacitance {} {
    set lib_pin_pool [get_lib_pins -all -filter "pin_capacitance > 0"]
    set cap_pool [get_attribute $lib_pin_pool pin_capacitance]
    set sum 0
    foreach x $cap_pool {
	set sum [expr $sum + $x]
    }
    echo "sum is $sum"
    set dcrt_sdc::average_cap [expr $sum/[sizeof_collection $lib_pin_pool]]
    set dcrt_sdc::min_cap [lindex [lsort $cap_pool] 0]
    set dcrt_sdc::max_cap [lindex [lsort $cap_pool] end]
    
    echo "average_cap is $dcrt_sdc::average_cap"
    echo "min_cap is $dcrt_sdc::min_cap"
    echo "max_cap is $dcrt_sdc::max_cap"

}


#####################
#   create_clock    #
#####################
proc dcrt_sdc::create_clock_config {}  {
    set ava_list [check_col "clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    
    set period [get_attribute [get_clock $inst] period]
    set wave_tmp1 [get_attribute [get_clock $inst] waveform]
    set source [get_attribute  [get_attribute [get_clock $inst] sources] full_name]
    regexp {(\d+.\d+)\s(\d+.\d+)} $wave_tmp1 tmp w1 w2
    set wave_seg1 [expr 1.0*$w1]
    set wave_seg2 [expr 0.9*$period/2+$wave_seg1]
    set dcrt_sdc::period_set($inst) [expr 0.9*$period]
    pv::eval remove_clock $inst
    if {$source == ""} {
        set cstr_full "create_clock -name $inst -period $dcrt_sdc::period_set($inst) -wave \"$wave_seg1 $wave_seg2\" "
    } else {
        set cstr_full "create_clock -name $inst -period $dcrt_sdc::period_set($inst) -wave \"$wave_seg1 $wave_seg2\" \"$source\""
    }
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
    
}

###############################
#   set_max_time_borrow       #
###############################
proc dcrt_sdc::set_max_time_borrow_config {} {
    set ava_list [check_col "latch"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    
    set option_value [expr [pv::icc::rand_float 0 1] * $dcrt_sdc::max_cap]
    set cstr_full "set_max_time_borrow $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

#####################
#   set_drive       #
#####################
proc dcrt_sdc::set_drive_pool {type} {
    set input_cstr_option [list \
	"-rise" "-fall" \
	"" \
	"-max" "-min" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_drive_config {} {
    set ava_list [check_col "input"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_drive_pool $obj_type]
    
    set option_value [expr [pv::icc::rand_float 0 2] * $dcrt_sdc::max_cap]
    set cstr_full "set_drive $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}
#######################
#   set_driving_cell  #
#######################

######################
#   set_max_fanout   # Not Supported
######################
proc dcrt_sdc::set_max_fanout_pool {type} {
    set input_cstr_option [list \
	""  \
    ]
    set design_cstr_option [list \
	"\[current_design\]" \
    ]
    
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}

proc dcrt_sdc::set_max_fanout_config {} {
    set ava_list [check_col "input design"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }    
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_max_fanout_pool $obj_type]    
    set option_value [pv::icc::rand_float 10 50]
    set cstr_full "set_max_fanout $option_value $cstr_option $inst"

    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

######################
#   set_fanout_load  #
######################
proc dcrt_sdc::set_fanout_load_pool {type} {
    set output_cstr_option [list \
	""  \
    ]
    
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}

proc dcrt_sdc::set_fanout_load_config {} {
    set ava_list [check_col "output"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }    
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_fanout_load_pool $obj_type]    
    set option_value [expr [pv::icc::rand_float 0.01 1] * $dcrt_sdc::max_cap]
    set cstr_full "set_fanout_load $option_value $cstr_option $inst"

    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

###############################
#   set_max_transition        #
###############################
proc dcrt_sdc::set_max_transition_pool {type} {
    set input_cstr_option [list \
	""  \
    ]
    set output_cstr_option [list \
	""  \
    ]
    set design_cstr_option [list \
	"\[current_design\]" \
    ]
    set clock_cstr_option [list \
	"" \
	"-clock_path" \
	"-data_path" \
    ]
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}

proc dcrt_sdc::set_max_transition_config {} {
    set ava_list [check_col "input output design clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }    
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_max_transition_pool $obj_type]
    set option_value [expr [pv::icc::rand_float 0.3 0.5] * $dcrt_sdc::period_value]
    set cstr_full "set_max_transition $option_value $cstr_option $inst"

    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

###############################
#   set_timing_derate         #
###############################
proc dcrt_sdc::set_timing_derate_pool {type} {
    set cell_cstr_option [list \
	"-cell_delay -early" \
	"-cell_delay -late"  \
    ]
    set net_cstr_option [list \
    ]
    set design_cstr_option [list \
	"-net_delay -early" "-net_delay -late" \
	"-clock -early" "-clock -late" \
	"-data -early" "-data -late" \
	"-cell_delay -early" "-cell_delay -late" \
	"-early" "-late"\
    ]
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}

proc dcrt_sdc::set_timing_derate_config {} {
    set ava_list [check_col "cell design"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }    
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_timing_derate_pool $obj_type]
    set option_value [pv::icc::rand_float 0.1 2.0]
    set cstr_full "set_timing_derate $cstr_option $option_value $inst"

    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

##########################
# set_case_analysis      #   
##########################
proc dcrt_sdc::set_case_analysis_config {}  {
    set ava_list [check_col "pin input output"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set option_value [pv::icc::rand_list 1 {0 1 rising falling}]
    set cstr_full "set_case_analysis $option_value $inst"

    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

####################### 
# set_false_path      #  dont use 
####################### 
proc dcrt_sdc::set_false_path_config_alt {} {
    set col_a [get_nets -hierarchical]
    set col_b [get_nets ]
    set obj_type net
    set false_path_net_collection [remove_from_collection $col_a $col_b]
    set count 0
    while 1 {
	incr count
	if { $count > 100 } {
	    return 0
	}
        set inst [pv::icc::rand_collection 1 $false_path_net_collection]
        if {[sizeof_collection [get_cells -of_object [get_nets $inst]]] < 2} {
            continue
        }
        set fp_cell [get_object_name [get_cells -of_object [get_nets $inst]]]
        if {[get_attribute [get_cells [lindex $fp_cell 0  ]] is_hierarchical] != true && \
            [get_attribute [get_cells [lindex $fp_cell end]] is_hierarchical] != true} {
                set cstr_full "set_false_path -from [lindex $fp_cell 0] -to [lindex $fp_cell end]"
		set inst [get_attribute $inst full_name]
		set return_list [list "$inst" "$obj_type" "$cstr_full"]
		return $return_list
        }
    }
}

##################
#set_false_path  # TODO
##################
proc dcrt_sdc::set_false_path_config {} {
    set ava_list [check_col "clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set clock_path ""
    set i 0
    while {$clock_path == ""} {
        set inst [random_obj $obj_type]
        set clock_path [get_pins [get_attribute [get_clocks $inst] clock_network_pins]]
	incr i
	if {$i > 10} {return 0}
    }
    set clk_pin [pv::icc::rand_list 1 [get_attribute [get_pins $clock_path -quiet -filter "is_clock_pin == true"] full_name]]
    set data_pin [pv::icc::rand_list 1 [get_attribute [get_pins -of_objects [get_cells -of_objects  $clock_path] -quiet -filter "is_data_pin == true"] full_name]]
    if { $clk_pin == "" || $data_pin == "" } {return 0}
    set cstr_full "set_false_path -from $clk_pin -to $data_pin"
    set inst "$clk_pin $data_pin"
    set return_list [list "$inst" "pin" "$cstr_full"]
    return $return_list
    
}

###################### 
# set_max_delay      #   
######################
proc dcrt_sdc::set_max_delay_pool {option} {
    set to_cstr_object [list \
	"clock" \
	"output" \
	"seq_cell" \
	"clk_pin" \
    ]
    set from_cstr_object [list \
	"clock" \
	"input" \
	"seq_cell" \
	"data_pin" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${option}_cstr_object]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_max_delay_config {} {
    set cstr_option [pv::icc::rand_list 1 {from to}]
    set obj_type ""
    set count 0
    while { $obj_type == "" } {
	incr count
	if {$count > 100} {
	    return 0
	}
	set obj_type [dcrt_sdc::set_max_delay_pool $cstr_option]
	set obj_type [check_col "$obj_type"]
    }
    set inst [random_obj $obj_type]
    set option_value [expr [pv::icc::rand_float 0.3 0.5] * $dcrt_sdc::period_value]
    set cstr_full "set_max_delay -$cstr_option $inst $option_value"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

###################### 
# set_min_delay      #   
######################
proc dcrt_sdc::set_min_delay_pool {option} {
    set to_cstr_object [list \
	"clock" \
	"output" \
	"seq_cell" \
	"clk_pin" \
    ]
    set from_cstr_object [list \
	"clock" \
	"input" \
	"seq_cell" \
	"data_pin" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${option}_cstr_object]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_min_delay_config {} {
    set cstr_option [pv::icc::rand_list 1 {from to}]
    set obj_type ""
    while { $obj_type == "" } {
	set obj_type [dcrt_sdc::set_max_delay_pool $cstr_option]
	set obj_type [check_col "$obj_type"]
    }
    set inst [random_obj $obj_type]
    set option_value [expr [pv::icc::rand_float 0.1 0.3] * $dcrt_sdc::period_value]
    set cstr_full "set_min_delay -$cstr_option $inst $option_value"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

######################## 
# set_input_transition #   
########################
proc dcrt_sdc::set_input_transition_pool {type} {
    set input_cstr_option [list \
	"-rise" "-fall" \
	"-max"  "-min" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
    ]
    set clock_cstr_option [list \
	"-clock" \
	"-clock_fall -clock" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_input_transition_config {} {
    set ava_list [check_col "input"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_input_transition_pool $obj_type]
    set appe_option [pv::icc::rand_list 1 clock ""]
    if {$appe_option == "clock"} {
	set appe_option "[dcrt_sdc::set_input_transition_pool $appe_option] [random_obj $appe_option]"
    } else {
	set appe_option ""
    }
    set option_value [expr [pv::icc::rand_float 0.05 0.1] * $dcrt_sdc::period_value]
    set cstr_full "set_input_transition $appe_option $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

###################### 
# set_input_delay    #   
######################
proc dcrt_sdc::set_input_delay_pool {type} {
    set input_cstr_option [list \
	"-rise" "-fall" \
	"-max"  "-min" \
	"-add_delay" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
	"-max -add_delay" \
    ]
    set clock_cstr_option [list \
	"-clock" \
	"-clock_fall -clock" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_input_delay_config {} {
    set ava_list [check_col "input"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_input_delay_pool $obj_type]
    set appe_option [pv::icc::rand_list 1 clock ""]
    if {$appe_option == "clock"} {
	set appe_option "[dcrt_sdc::set_input_delay_pool $appe_option] [random_obj $appe_option]"
    } else {
	set appe_option ""
    }
    set option_value [expr [pv::icc::rand_float 0.1 0.3] * $dcrt_sdc::period_value]
    set cstr_full "set_input_delay $appe_option $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

###################### 
# set_output_delay   #   
######################
proc dcrt_sdc::set_output_delay_pool {type} {
    set output_cstr_option [list \
	"-rise" "-fall" \
	"-max"  "-min" \
	"-add_delay" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
	"-max -add_delay" \
    ]
    set clock_cstr_option [list \
	"-clock" \
	"-clock_fall -clock" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_output_delay_config {} {
    set ava_list [check_col "output"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_output_delay_pool $obj_type]

    set appe_option [pv::icc::rand_list 1 clock ""]
    if {$appe_option == "clock"} {
	set appe_option "[dcrt_sdc::set_output_delay_pool $appe_option] [random_obj $appe_option]"
    } else {
	set appe_option ""
    }

    set option_value [expr [pv::icc::rand_float 0.1 0.3] * $dcrt_sdc::period_value]
    set cstr_full "set_output_delay $appe_option $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

###################### 
# set_clock_latency  #   
######################
proc dcrt_sdc::set_clock_latency_pool {type} {
    set clock_cstr_option [list \
	"-rise" "-fall" \
	"" \
	"-max" "-min" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
    ]
    set source_cstr_option [list \
	"-source -early" \
	"-source -late" \
	"-source" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_clock_latency_config {} {
    set ava_list [check_col "clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_clock_latency_pool $obj_type]

    set appe_option [pv::icc::rand_list 1 {source ""}]
    if {$appe_option == "source"} {
	set appe_option "[dcrt_sdc::set_clock_latency_pool $appe_option]"
    } else {
	set appe_option ""
    }
    set option_value [expr [pv::icc::rand_float 0.5 0.8] * $dcrt_sdc::period_value]
    set cstr_full "set_clock_latency $appe_option $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

######################## 
# set_clock_transition #   
#######################$
proc dcrt_sdc::set_clock_transition_pool {type} {
    set clock_cstr_option [list \
	"-rise" "-fall" \
	"" \
	"-max" "-min" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_clock_transition_config {} {
    set ava_list [check_col "clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_clock_transition_pool $obj_type]
    
    set option_value [expr [pv::icc::rand_float 0.1 0.3] * $dcrt_sdc::period_value]
    set cstr_full "set_clock_transition $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

########################## 
# set_clock_uncertainty  #   
##########################
proc dcrt_sdc::set_clock_uncertainty_pool {type} {
    set clock_cstr_option [list \
	"" \
	"-setup" \
	"-hold" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
 	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_clock_uncertainty_config {} {
    set ava_list [check_col "clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_option [dcrt_sdc::set_clock_uncertainty_pool $obj_type]
    set option_value [expr [pv::icc::rand_float 0.05 0.10] * $dcrt_sdc::period_value]
    set cstr_full "set_clock_uncertainty $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

#################### 
# set_clock_sense  #   
####################
proc dcrt_sdc::set_clock_sense_pool {type} {
    set unate_cell_cstr_option [list \
	"-stop_propagation" \
	"-positive" \
	"-negative" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_clock_sense_config {} {
    set ava_list [check_col "unate_cell"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst "[random_obj $obj_type]/Z"
    set cstr_option [dcrt_sdc::set_clock_sense_pool $obj_type]
    set cstr_full "set_clock_sense $cstr_option $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

######################## 
# set_multicycle_path  #  TODO 
########################
proc dcrt_sdc::set_multicycle_path_pool {type} {
	set cell_cstr_option [list \
		"-through" \
		"-rise_through" \
		"-fall_through" \
	]
	set pin_cstr_option [list \
		"-through" \
		"-rise_through" \
		"-fall_through" \
	]
        set net_cstr_option [list \
		"-through" \
		"-rise_through" \
		"-fall_through" \
	]

	set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
	if {[regexp {\{(.*)\}} "$option" full temp]} {
		set option $temp
	}
	return $option
}
proc dcrt_sdc::set_multicycle_path_config {} {
	set inst [get_inst]
	set ref_presu [get_attribute [get_cells ${inst}] ref_name]
	set obj_type [pv::icc::rand_list 1 {pin cell }]
	set obj_name [random_obj ${inst} $obj_type]
	set cstr_option [dcrt_sdc::set_multicycle_path_pool $obj_type]
	set option_value [pv::icc::rand_int 2 5]
	set cstr_full "set_multicycle_path $cstr_option $obj_name $option_value"	
	
	set return_list [list "$inst" "$ref_presu" "$obj_type" "$obj_name" "$cstr_full"]
	return $return_list
}

######################## 
# set_propagated_clock #   
########################
proc dcrt_sdc::set_propagated_clock_config {} {
    set ava_list [check_col "clock"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_full "set_propagated_clock $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

######################## 
# set_disable_timing   #   
########################
proc dcrt_sdc::set_disable_timing_config {} {
    set ava_list [check_col "leaf_clk_cell"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    if {$inst == ""} {return "0"}
    set pin_in [get_attribute [pv::icc::rand_collection 1 [get_pins -of_object $inst -filter "is_data_pin == true && direction == in"]] name]
    set pin_clk [get_attribute [pv::icc::rand_collection 1 [get_pins -of_object $inst -filter "is_clock_pin == true && direction == in"]] name]
    set pin_out [get_attribute [pv::icc::rand_collection 1 [get_pins -of_object $inst -filter "direction == out"]] name]
    set cstr_full "set_disable_timing $inst -from $pin_clk -to $pin_out"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

######################## 
#  set_ideal_network   # No return value  
########################
proc dcrt_sdc::set_ideal_network_config {} {
    set ava_list [check_col "leaf_clk_pin input output"]
    if { [llength $ava_list] == 0 } {
	return "0"
    }
    set obj_type [pv::icc::rand_list 1 $ava_list]
    set inst [random_obj $obj_type]
    set cstr_full "set_ideal_network $inst"	
    
    lappend dcrt_sdc::ideal_network_list $inst	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}

##############################
#   set_ideal_latency        # No return value
##############################
proc dcrt_sdc::set_ideal_latency_pool {type} {
    set ideal_network_cstr_option [list \
	"-rise" "-fall" \
	"" \
	"-max" "-min" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_ideal_latency_config {} {
    set obj_type ideal_network
    set inst [pv::icc::rand_list 1 $dcrt_sdc::ideal_network_list]
    set cstr_option [dcrt_sdc::set_ideal_latency_pool $obj_type]

    set option_value [expr [pv::icc::rand_float 0.3 0.5] * $dcrt_sdc::period_value]
    set cstr_full "set_ideal_latency $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}


###############################
#   set_ideal_transition      # No return value
###############################
proc dcrt_sdc::set_ideal_transition_pool {type} {
    set ideal_network_cstr_option [list \
	"-rise" "-fall" \
	"" \
	"-max" "-min" \
	"-rise -max" "-rise -min" \
	"-fall -max" "-fall -min" \
    ]
	
    set option [pv::icc::rand_list 1 [set ${type}_cstr_option]]
    if {[regexp {\{(.*)\}} "$option" full temp]} {
	set option $temp
    }
    return $option
}
proc dcrt_sdc::set_ideal_transition_config {} {
    set obj_type ideal_network
    set inst [pv::icc::rand_list 1 $dcrt_sdc::ideal_network_list]
    set cstr_option [dcrt_sdc::set_ideal_transition_pool $obj_type]

    set option_value [expr [pv::icc::rand_float 0.3 0.5] * $dcrt_sdc::period_value]
    set cstr_full "set_ideal_transition $cstr_option $option_value $inst"	
	
    set return_list [list "$inst" "$obj_type" "$cstr_full"]
    return $return_list
}


proc dcrt_sdc::set_size_only_config {} {
	set inst [get_inst]
	set ref_presu [get_attribute [get_cells ${inst}] ref_name]
	set obj_type [pv::icc::rand_list 1 {cell}]
	set obj_name [random_obj ${inst} $obj_type]
	set cstr_full "set_size_only $obj_name"	
	
	set return_list [list "$inst" "$ref_presu" "$obj_type" "$obj_name" "$cstr_full"]
	return $return_list
}

proc dcrt_sdc::set_dont_touch_config {} {
	set inst [get_inst]
	set ref_presu [get_attribute [get_cells ${inst}] ref_name]
	set obj_type [pv::icc::rand_list 1 {cell}]
	set obj_name [random_obj ${inst} $obj_type]
	set cstr_full "set_dont_touch $obj_name"	
	
	set return_list [list "$inst" "$ref_presu" "$obj_type" "$obj_name" "$cstr_full"]
	return $return_list
}





############################################
#Functional Procedure			   #
############################################

#  Focus to program                    #
proc random_obj {type} {
    if {[string equal $type latch]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::latch_collection] full_name]
    }

    if {[string equal $type ff]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::ff_collection] full_name]
    }

    if {[string equal $type clock]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::clock_collection] name]
    }

    if {[string equal $type gen_clk]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::gen_clk_collection] full_name]
    }

    if {[string equal $type design]} {
	return ""
    }

    if {[string equal $type cell]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::cell_collection] full_name]
    }

    if {[string equal $type input]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::input_collection] full_name]
    }

    if {[string equal $type output]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::output_collection] full_name]	
    }
    
    if {[string equal $type pin]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::pin_collection] full_name]
    }

    if {[string equal $type seq_cell]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::seq_cell_collection] full_name]
    }

    if {[string equal $type com_cell]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::com_cell_collection] full_name]
    }

    if {[string equal $type clk_pin]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::clk_pin_collection] full_name]
    }

    if {[string equal $type data_pin]} {
        return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::data_pin_collection] full_name]
    }

    if {[string equal $type unate_cell]} {
	return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::unate_cell_collection] full_name]
    }

    if {[string equal $type leaf_clk_cell]} {
	set flag 10 
	set i 0
	while {$flag > 8} {
            set return_cell [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::leaf_clk_cell_collection] full_name]
	    set flag [sizeof_collection [get_pins -of_object $return_cell]]
	    if {$i > 50} {return ""}
	    incr i
	}
	return $return_cell
    }
    
    if {[string equal $type leaf_clk_pin]} {
	return [get_attribute [pv::icc::rand_collection 1 $dcrt_sdc::leaf_clk_pin_collection] full_name]
    }
}

proc check_col { col } {
    set ava_col [list]
    foreach x $col {
	if {$x == "design"} {
	    lappend ava_col $x
	}
	if { [sizeof_collection [set dcrt_sdc::${x}_collection]] != 0 } {
	    lappend ava_col $x
	}
    }
    return $ava_col
}

proc ldelete {list value} {
    set ix [lsearch -exact $list $value]
    if {$ix != -1} {
	return [lreplace $list $ix $ix]
    } else {
	return $list
    }
}

proc random_SDCcmd {} {
    return [?? list 1 [set dcrt_sdc::cmd_list]]
}

proc random_precmd {} {
    return [?? list 1 [set dcrt_sdc::pre_cmd_list]]
}
