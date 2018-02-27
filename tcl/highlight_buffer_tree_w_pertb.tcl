# Random function library
source /remote/pv/CSS/project/PV-ZRAND/lib/srand.latest.tcl
lappend auto_path /u/szhang/pv/lib/tcl

package require pv::nwsh
package require pv::ui
pv::ui::use nwsh
redirect -variable aaa {pv::eval -file command}


proc highlight_buffer_tree args {
   parse_proc_arguments -args $args option_input
   set option [array name option_input]
      
   if {[regexp {\-keep_last_highlight} $option]} {
      set keep 1
   } else {
      set keep 0
   }
   
   if {[regexp {\-level} $option]} {
     set mylevel $option_input(-level)
   } else {
     set mylevel -1
   }
   global __my_hidden_net
   global __my_hidden_cell
   global __my_hidden_port

   if {![info exist __my_hidden_net]} {
      set __my_hidden_net ""
   }
   if {![info exist __my_hidden_cell]} {
      set __my_hidden_cell ""
   }
   if {![info exist __my_hidden_port]} {
      set __my_hidden_port ""
   }

   if {$keep==0} {
     if {[info exist __my_hidden_net]} {
        if {[llength $__my_hidden_net]!=0} {
           gui_change_highlight -remove -collection [get_nets -quiet -segments $__my_hidden_net]
           set __my_hidden_net ""
        }
     }
     if {[info exist __my_hidden_port]} {
        if {[llength $__my_hidden_port]!=0} {
           gui_change_highlight -remove -collection [get_ports -quiet $__my_hidden_port]
           set __my_hidden_port ""
        }
     }
     if {[info exist __my_hidden_cell]} {
        if {[llength $__my_hidden_cell]!=0} {
           gui_change_highlight -remove -collection [get_cells -quiet $__my_hidden_cell]
           set __my_hidden_cell ""
        }
     }
   }

   set all_start_point $option_input(-start_point)

   if {[string match _sel* $all_start_point]} {
      set all_start_point [get_object_name $all_start_point]
   }

   #echo "keep is $keep"
   #echo "start_point is [get_object_name $start_point]"
foreach start_point $all_start_point {
   if {[sizeof_collection [get_pins -quiet $start_point -filter is_hierarchical==true]]!=0 || \
       [sizeof_collection [get_nets -quiet $start_point]]!=0 || \
       [sizeof_collection [get_ports -quiet $start_point -filter direction==in]]!=0 || \
       [sizeof_collection [get_pins -quiet $start_point -filter "is_hierarchical==false && direction==out"]]!=0} {

       if {[file exists __rpt]} {
          file delete -force __rpt
       }
       #report_buffer_trees -from $start_point -hierarchy -connections > __rpt
       redirect -file __rpt {report_buffer_trees -from $start_point -hierarchy -connections}
       array unset tree_cel
       array unset tree_net
       set fp [open __rpt r]
       while {![eof $fp]} {
          set str [gets $fp]
          #puts $str
          if {[regexp {Load \(level ([0-9]+)\): (.*) (.*)} $str a level pin ref]} {
             if {[sizeof_collection [get_pins -quiet $pin]]==1} {
               set cell [get_object_name [get_cells -of_objects [get_pins $pin]]]
             } else {
               set cell $pin
             }
             if {[info exist tree_cel($level)]} {
                lappend tree_cel($level) $cell
             } else {
                set tree_cel($level) $cell
             }
          }
          if {[regexp {Driver \(level ([0-9]+)\): (.*) (.*) - Net: (.*)} $str a level pin ref net]} {
             if {[sizeof_collection [get_pins -quiet $pin]]==1} {
               set cell [get_object_name [get_cells -of_objects [get_pins $pin]]]
             } else {
               set cell $pin
             } 
             if {[info exist tree_cel($level)]} {
                lappend tree_cel($level) $cell
             } else {
                set tree_cel($level) $cell
             }
             if {[info exist tree_net($level)]} {
                lappend tree_net($level) $net
             } else {
                set tree_net($level) $net
             }
          }           
       }
       close $fp
   } else {
      puts "Please specify an input port, hierarchical module pins, cell output pins or nets"
   }
   ###

   set all_buf_inv ""
   set color_list {red yellow green orange purple blue light_red light_orange light_green light_blue}
   for {set i 0} {$i < [llength [array name tree_cel]]} {incr i} {
   #puts "IIII $i"
     if {$i<[llength $color_list]} {
        set c [lindex $color_list $i]
     } else {
        set color_list {yellow green orange purple blue light_red light_orange light_green light_blue} 
        set c [lindex $color_list [expr $i - $i/[llength $color_list]*[llength $color_list]]]
     }

     if {$mylevel==-1} {
        if {[sizeof_collection [get_ports -quiet $tree_cel($i)]]!=0} {
           gui_change_highlight -collection [get_ports -quiet $tree_cel($i)] -color $c 
           set __my_hidden_port [concat $__my_hidden_port [get_object_name [get_ports -quiet $tree_cel($i)]]]
           #puts "AAA $__my_hidden_port"
           #puts "BBB [get_object_name [get_ports -quiet $tree_cel($i)]]"
        } 
     } elseif {[lsearch $mylevel $i]!=-1} {
     #puts "LLLL $mylevel"
        if {[sizeof_collection [get_ports -quiet $tree_cel($mylevel)]]!=0} {
           gui_change_highlight -collection [get_ports -quiet $tree_cel($mylevel)] -color $c 
           set __my_hidden_port [concat $__my_hidden_port [get_object_name [get_ports -quiet $tree_cel($mylevel)]]]
           #puts "AAA $__my_hidden_port"
        }   
     }

     if {$mylevel==-1} {
        if {[sizeof_collection [get_cells -quiet $tree_cel($i)]]!=0} {
           #gui_change_highlight -collection [remove_from_collection [get_cells -quiet $tree_cel($i)] [get_cells -quiet $tree_cel($i) -filter is_hierarchical==true]] -color $c 
           #Leo add for cell movement
           set cell_list [get_object_name [get_cells -quiet $tree_cel($i)]]
           foreach cell $cell_list {
               set result [regexp {HFSBUF|HFSINV|BINV|BUFT} $cell match]
               if {$result == 1} {
                   lappend all_buf_inv $cell
                   set delta_x [pv::icc::rand_int -300 300]
                   set delta_y [pv::icc::rand_int -300 300]
                   set x [lindex [get_attribute [get_cells $cell] origin] 0]
                   set y [lindex [get_attribute [get_cells $cell] origin] 1]
                   set new_x [expr $delta_x + $x]
                   set new_y [expr $delta_y + $y]
                   set cmd "set_attribute \[get_cells $cell\] origin \{$new_x $new_y\}"
                   pv::eval $cmd 
                   #echo "$cell is buf/inv can move"
               }
           }
           gui_change_highlight -collection [get_cells -quiet $tree_cel($i)] -color $c 
           set __my_hidden_cell [concat $__my_hidden_cell [get_object_name [get_cells -quiet $tree_cel($i)]]]
           #puts "AAA $__my_hidden_cell"
        } 
     } elseif {[lsearch $mylevel $i]!=-1}  {
        if {[sizeof_collection [get_cells -quiet $tree_cel($mylevel)]]!=0} {
           #gui_change_highlight -collection [remove_from_collection [get_cells -quiet $tree_cel($i)] [get_cells -quiet $tree_cel($i) -filter is_hierarchical==true]] -color $c 
           #Leo add for cell movement
            set cell_list [get_object_name [get_cells -quiet $tree_cel($i)]]
            foreach cell $cell_list {
               set result [regexp {HFSBUF|HFSINV|BINV|BUFT} $cell match]
               if {$result == 1} {
                   lappend all_buf_inv $cell
                   set delta_x [pv::icc::rand_int -300 300]
                   set delta_y [pv::icc::rand_int -300 300]
                   set x [lindex [get_attribute [get_cells $cell] origin] 0]
                   set y [lindex [get_attribute [get_cells $cell] origin] 1]
                   set new_x [expr $delta_x + $x]
                   set new_y [expr $delta_y + $y]
                   set cmd "set_attribute \[get_cells $cell\] origin \{$new_x $new_y\}"
                   pv::eval $cmd

                  # echo "$cell is buf/inv can move"
               }
           }
           gui_change_highlight -collection [get_cells -quiet $tree_cel($mylevel)] -color $c 
           set __my_hidden_cell [concat $__my_hidden_cell [get_object_name [get_cells -quiet $tree_cel($mylevel)]]]
           #puts "AAA $__my_hidden_cell"
        } 
     }

     if {$mylevel==-1} {
        if {[sizeof_collection [get_nets -quiet $tree_net($i)]]!=0} {
           gui_change_highlight -collection [get_nets -segments -quiet $tree_net($i)] -color $c 
           set __my_hidden_net [concat $__my_hidden_net [get_object_name [get_nets -quiet $tree_net($i)]]]
           #puts "AAA $__my_hidden_net"
        } 
     } elseif {[lsearch $mylevel $i]!=-1}  {
        if {[sizeof_collection [get_nets -quiet $tree_net($mylevel)]]!=0} {
           gui_change_highlight -collection [get_nets -segments -quiet $tree_net($mylevel)] -color $c 
           set __my_hidden_net [concat $__my_hidden_net [get_object_name [get_nets -quiet $tree_net($mylevel)]]]
           #puts "AAA $__my_hidden_net"
        } 
     }
   }
   
   #legalize moved buf/inv
   set cmd "legalize_placement -cells \[get_cells -quiet {$all_buf_inv}\]"
   pv::eval $cmd
   #parray tree_cel

   if {[file exists __rpt]} {
      file delete -force __rpt
   }
}
}


define_proc_attributes highlight_buffer_tree \
    -info "Highlight the buffer tree in GUI based on the start_point you specified" \
    -define_args { \
        {-start_point "Specify a start point of a bufer tree, it should be only one of input port, output pin of an instance, a hierarchy pin or a net" "" list required} \
        {-keep_last_highlight "The last step's hightlight will be kept if this option is specified" "" boolean optional} \
        {-level "The level you want to hightlight" "" int optional} \
    }



proc get_high_fanout_net {threshold hfn} {
   if {[file exist __net_rpt]} {
      exec rm -rf __net_rpt
   }
 
   report_net_fanout -nosplit -threshold $threshold > __net_rpt
   if {![catch {exec grep "NetName" __net_rpt}]} {
     set s [expr [exec grep -n "NetName" __net_rpt | cut -d: -f1] + 2]
     set e [expr [exec wc -l < __net_rpt] -1]
     set n [exec sed -n ${s},${e}p __net_rpt]
     set hfn_d ""
     for {set i 0} {$i < [llength $n]} {set i [expr $i+3]} {
        set hfn [lindex $n $i]
        if {[sizeof_collection [get_pins -of_objects [get_nets $hfn] -quiet -filter direction==out]]==0} {
           set d_p [get_object_name [get_ports -of_objects [get_nets $hfn] -quiet -filter direction==in]]
           if {[get_attribute [get_ports $d_p] is_clock_used_as_clock]!="true"} {
              set hfn_d [concat $hfn_d $d_p]
           }
        } else {
           set is_buf 1
           set hfn_d_cur [get_object_name [get_pins -of_objects [get_nets $hfn] -quiet -filter direction==out]]
           if {[get_attribute [get_pins $hfn_d_cur] is_clock_used_as_clock]!="true"} {
             while {$is_buf} {
                set d $hfn_d_cur
                #set d_c [get_cells -of_objects [get_pins -of_objects [get_nets -of_objects [get_pins -of_objects [get_cells -of_objects [get_pins $hfn_d_cur]] -filter "direction==in && port_type==signal"]] -quiet -filter direction==out]]
                set d_c [get_object_name [get_cells -of_objects [get_pins $hfn_d_cur]]]
                set fun [get_attribute [get_lib_cells -of_objects [get_cells $d_c]] function_id]
                if {$fun=="a1.0" || $fun=="Ia1.0"} {
                   set conn_net [get_object_name [get_nets -of_objects [get_pins -of_objects [get_cells $d_c] -filter "direction==in && port_type==signal"]]]
                   if {[sizeof_collection [get_pins -of_objects [get_nets $conn_net] -quiet -filter direction==out]]==0} {
                     set hfn_d [concat $hfn_d [get_object_name [get_ports -of_objects [get_nets $conn_net] -filter direction==in]]]
                     set is_buf 0
                   } else {
                     set hfn_d_cur [get_object_name [get_pins -of_objects [get_nets $conn_net] -quiet -filter direction==out]]
                   }
                } else {
                  set hfn_d [concat $hfn_d $d]
                  set is_buf 0
                }
             }
           }
        }
     }
   } else {
     puts "No high fanout net (threshold > $threshold) can be found"
     set hfn_d ""
   }
   return $hfn_d
}
