#gui proc
proc dump_gif { filename } {
    rm_route
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting viewshot -value ${filename}.bmp
    exec convert ${filename}.bmp ${filename}.gif
    file delete ${filename}.bmp
}

# congestion map
proc dump_cm { filename } {
    rm_route
    # congestion map
    gui_show_map -window [gui_get_current_window -types Layout -mru] -map {globalCongestionMap} -show {true}
    gui_set_map_option -map {globalCongestionMap} -option {rule_level} -value {hard}
    route_global -congestion_map_only true
    dump_gif $filename
}

# rm route
proc rm_route { } {
    gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showRoute -value false
    win_set_select_class -visible {cell port bound routing_blockage shaping_blockage pg_region pin_blockage block_shielding topology_node topology_edge core_area die_area edit_group terminal fill_cell placement_blockage }
    win_set_select_class {cell port bound routing_blockage shaping_blockage pg_region pin_blockage topology_node topology_edge edit_group placement_blockage }
}

# cell density
proc dump_cell_density { filename } {
    rm_route
    gui_show_map -window [gui_get_current_window -types Layout -mru] -map {cellDensityMap} -show {true}
    gui_load_cell_density_mm
    dump_gif $filename
}



