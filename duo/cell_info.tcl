proc cell_info {cell_name} {

    if {![sizeof_collection [get_cells -quiet $cell_name]] } {
       set w1 16
       set w1_1 20
       set w2 25
       puts [format "%*s%*s%*s%*s%*s" $w1 "\"not_present\"" $w1 NA $w2 NA $w2 NA $w1 NA ]

        return
    } else {

        set w1 12
        set w1_1  [expr [string length [get_attribute $cell_name ref_name]] +4 ]
        set w2 25

        set ref_name [get_attribute $cell_name ref_name]
        regexp {(\S+)\s+(\S+)} [get_attribute [get_cells $cell_name] origin] all x y
        set location \"$x,$y\"
        set power [get_object_name \
     [get_supply_nets -of_object [get_pins -of_objects $cell_name -filter "port_type == power"]] ]


        for {set i 0} {$i<[llength $power]} {incr i} {
            if {$i == [expr [llength $power]-1]} {
                append power_list [lindex $power $i]
            } else {
                append power_list [lindex $power $i],
            }
        }

        set gnd [get_object_name \
     [get_supply_nets -of_object [get_pins -of_objects $cell_name -filter "port_type == ground"]] ]

        for {set i 0} {$i<[llength $gnd]} {incr i} {
            if {$i == [expr [llength $gnd]-1]} {
                append gnd_list [lindex $gnd $i]
            } else {
                append gnd_list [lindex $gnd $i],
            }
        }

        set site [get_attribute [get_attribute $cell_name ref_lib_name]/[get_attribute $cell_name ref_name] site_name]
        set w1 16
        set w2 25
        puts [format "%*s%*s%*s%*s%*s" $w1 present [expr [string length $ref_name]+2] $ref_name [expr [string length $location]+2] "$location" [expr [string length $power]*2+6] "$power_list|$gnd_list" [expr [string length $site]+2] $site ]
    }
} 
