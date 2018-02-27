setenv duo_dir /remote/pv/utility/icc2/optimization/duo
echo "Usage Flow:"
echo "    set_app_options -list {opt.common.checkpoints all} before place_opt"
echo "    execute place_opt"
echo "    duo    # debugging utility for optimization    "
echo "          \[-cell cell_input\]     (input cell name to analyze)    "  
echo "          \[-path_from pin_input\] (input startpoint)              "
echo "          \[-path_through pin_input\]                              "
echo "                                 (input through point)           "
echo "          \[-path_to pin_input\]   (input endpoint)                "
echo "          \[-net net_input\]       (input net name to analyze)     "
echo "          \[-density\]             (dump cell density map for whole design)"
echo "          \[-congestion\]          (dump congestion map for whole design)"

proc get_qor args {
    exec sed "s/TITLE/Report for cell/g" \
         /remote/pv/utility/icc2/optimization/duo/head.html  > qor_info.html

    echo "<table>" >> qor_info.html
    echo "<tr>" >> qor_info.html
    echo "<td> STAGE </td>" >> qor_info.html
    echo "<td> ELAPSED_TIME </td>" >> qor_info.html
    echo "<td> WNS </td>" >> qor_info.html
    echo "<td> TNS </td>"  >> qor_info.html
    echo "<td> AREA </td>"  >> qor_info.html
    echo "<td> TRAN_COST </td>"  >> qor_info.html
    echo "<td> CAP_COST </td>"  >> qor_info.html
    echo "<td> BUF_COUNT </td>"  >> qor_info.html
    echo "<td> INV_COUNT </td>"  >> qor_info.html
    echo "<td> LVTH_COUNT </td>"  >> qor_info.html
    echo "<td> LVTH_PERCENT </td>"  >> qor_info.html
    echo "<td> MEM </td>"  >> qor_info.html

    echo "</tr>" >> qor_info.html

    set qor [exec /remote/pv/utility/icc2/optimization/duo/qor2.pl icc2_output.txt ]

    set qor_list [split $qor "\n"]
    foreach one_line $qor_list {
        set line_len [llength $one_line]
        echo "<tr>"  >> qor_info.html
        for {set i 0} {$i<$line_len} {incr i} {
            if {$i==0} {
                if {[regexp {\w+} [lindex $one_line $i]]} {
                    continue
                }
            }
            echo "<td>[lindex $one_line $i]</td>" >> qor_info.html
        }
        echo "</tr>" >> qor_info.html
    }
    echo "</table>" >> qor_info.html
    sh cat [getenv duo_dir]/foot.html >> qor_info.html
    puts "Link for qor: http://clearcase/[pwd]/qor_info.html"
}


proc duo args {
#    set duo_dir [sh cat /remote/pv/utility/icc2/optimization/duo/duo_dir]

    parse_proc_arguments -args $args option_input ;
    set cell_name ""
    set path_from ""
    set path_through ""
    set path_to ""
    set net_name ""
    set is_density 0
    set is_cong 0
#    exec rm -rf duo_work
#    exec mkdir duo_work
    regexp {\w+\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d)+\s+(\d+)} [date] all mon day h m s year
    set date ${mon}_${day}_${h}_${m}_${s}_${year}
    if {[info exist option_input(-cell)]} {
        set cell_name $option_input(-cell)
        set duo_work_dir duo_work_${date}_cell
        exec mkdir duo_work_${date}_cell
        echo $cell_name > ${duo_work_dir}/run_option.tmp
    }
    if {[info exist option_input(-path_from)]} {
        set path_from $option_input(-path_from)
    }

    if {[info exist option_input(-path_through)]} {
        set path_through $option_input(-path_through)
    }

    if {[info exist option_input(-path_to)]} {
        set path_to $option_input(-path_to)
    }

    if {$path_from != "" || $path_through != "" || $path_to != ""} {
        exec mkdir duo_work_${date}_path
        set duo_work_dir duo_work_${date}_path

        if {[info exist path_from] && $path_from != ""} {
            echo "-from  $path_from" >> ${duo_work_dir}/run_option.tmp
        }

        if {[info exist path_through] && $path_through != ""} {
            echo "-through  $path_through" >> ${duo_work_dir}/run_option.tmp
        }

        if {[info exist path_to] && $path_to != ""} {
            echo "-to  $path_to" >> ${duo_work_dir}/run_option.tmp
        }

    }


    if {[info exist option_input(-net)]} {
        set net_name $option_input(-net)
        exec mkdir duo_work_${date}_net
        set duo_work_dir duo_work_${date}_net
        echo $net_name > ${duo_work_dir}/run_option.tmp
    }

    if {[info exist option_input(-density)]} {                                                                 
       set is_density 1;                                                                                      
       exec mkdir duo_work_${date}_des
       set duo_work_dir duo_work_${date}_des
    }     

    if {[info exist option_input(-congestion)]} {
       set is_cong 1;
       exec mkdir duo_work_${date}_cong
       set duo_work_dir duo_work_${date}_cong
    }

    set checkpoints ""
    set all_stage [sh cat [getenv duo_dir]/all_stage]
    list_blocks > all_blocks
    set all_designs [exec awk {{print $3}}  all_blocks]
    foreach one_design $all_designs {
        if {[regexp {(^[A-Z]+\d*)[a-z]*\.design$}  [set one_design] all step] } {
            if {[lsearch $all_stage $step] != -1}  {
                 lappend checkpoints $one_design
            }
        }
    }

    set num_checkp [llength $checkpoints]
    set nthread [expr $num_checkp/4]
    set last_njobs [expr $num_checkp%4]
    if {[expr $num_checkp%4]} {
        set nthread [expr $nthread + 1]
    }

    sh rm -rf thread*
#    sh rm -f *.info
#    sh rm -f *.job
    for {set i 0} {$i < $nthread} {incr i} {
        echo "Start Thread $i"
        exec mkdir thread_$i
        echo "#!/bin/csh" > thread_$i/run.csh
        for {set j 0} {$j < 4}  {incr j} {
            set one_stage [lindex $checkpoints [expr $i*4+$j]]
            if {$one_stage == ""} {
                break
            }
            echo "stage: $one_stage"
            exec mkdir -p thread_$i/$one_stage
            set clib [get_object_name [current_lib]]
         #run cell analysis
            if {$cell_name != ""} {
       exec sed "s/LIB_NAME/$clib/g;s/DES_NAME/$one_stage/g; s/OPTION/cell/g; s/DUO_WORK/$duo_work_dir/g" \
           [getenv duo_dir]/run.csh \
                       >> thread_$i/$one_stage/run.csh
            }
        #run path analysis
            if {$path_from != "" || $path_through != "" || $path_to != ""} {


       exec sed "s/LIB_NAME/$clib/g;s/DES_NAME/$one_stage/g; s/OPTION/path/g; s/DUO_WORK/$duo_work_dir/g" \
           [getenv duo_dir]/run.csh \
                       >> thread_$i/$one_stage/run.csh
            }
         #run net analysis
            if {$net_name != ""} {
       exec sed "s/LIB_NAME/$clib/g;s/DES_NAME/$one_stage/g; s/OPTION/net/g; s/DUO_WORK/$duo_work_dir/g" \
           [getenv duo_dir]/run.csh \
                       >> thread_$i/$one_stage/run.csh
            }
         
          #run cell density analysis                                                                                     
             if {$is_density} {                                                                                          
        exec sed "s/LIB_NAME/$clib/g;s/DES_NAME/$one_stage/g; s/OPTION/density/g; s/DUO_WORK/$duo_work_dir/g" \
            [getenv duo_dir]/run.csh \
                        >> thread_$i/$one_stage/run.csh                                                                  
             }                                                                                                           

          #run gr congestion map analysis      
             if {$is_cong} {                                                                                    
        exec sed "s/LIB_NAME/$clib/g;s/DES_NAME/$one_stage/g; s/OPTION/congestion/g; s/DUO_WORK/$duo_work_dir/g" \
            [getenv duo_dir]/run.csh \
                        >> thread_$i/$one_stage/run.csh                                                            
             }                
                                                                                                                         
         #generate run.csh

            echo "thread_$i/$one_stage/run.csh" >> thread_$i/run.csh
            exec chmod 777 thread_$i/$one_stage/run.csh
            
        }

        exec chmod 777 thread_$i/run.csh
        set qid [exec qsub thread_$i/run.csh]
        echo $qid
    }

    set ck_num [llength $checkpoints]
    set lastn 0
    set count 0
    while {1} {
        after 2000
        set i 0
        set unfinished_check ""
        foreach one_check $checkpoints {
            if {[file exist ${duo_work_dir}/$clib.$one_check.info]}  {
                incr i
            } else {
                lappend unfinished_check $one_check
            }
        }
        if {$i != $lastn} {
            set lastn $i
            echo $i/$ck_num done
        }
        if {$i == $ck_num} {break}
        if {[expr $ck_num - $i] < 4} {echo "Info: unfinished checks : $unfinished_check"}
        incr count
        if {$count == 900} {
            echo "Time out!!"
            break;
        }
    }
    echo "Info: all jobs are done"

#print the cell analysis report
    if {$cell_name != ""} {
        echo "Report for cell $cell_name"
        set w1 12
        set w1_1  20

        set w2 25
        puts [format "%*s%*s%*s%*s%*s%*s" $w1 STEP $w1_1 EXISTENCE $w1 REF $w2 LOCATION $w2 POWER $w1 SITEDEF]
        foreach one_check $checkpoints {
            regexp {(\S+)\.design} $one_check all step
#            echo "$step" [sh cat $clib.$one_check.info]
            puts [format "%*s%s" $w1 $step [sh cat ${duo_work_dir}/$clib.$one_check.info]]
        }

        for {set i 0} {$i <  [string length $cell_name]} {incr i} {
            if { [string index $cell_name $i] == "/"}  {
                set cell_name [string replace $cell_name  $i $i "_"]
            }
        }

        exec sed "s/TITLE/Report for $cell_name/g; "  /remote/pv/utility/icc2/optimization/duo/head.html  >  ${duo_work_dir}/cell_info.html

        echo "<table>" >>  ${duo_work_dir}/cell_info.html
        echo "<tr>" >>  ${duo_work_dir}/cell_info.html
        echo "<td> STEP </td>" >>  ${duo_work_dir}/cell_info.html
        echo "<td> EXISTENCE </td>" >>  ${duo_work_dir}/cell_info.html
        echo "<td> REF </td>"  >>  ${duo_work_dir}/cell_info.html
        echo "<td> LOCATION </td>"  >>  ${duo_work_dir}/cell_info.html
        echo "<td> POWER </td>"  >>  ${duo_work_dir}/cell_info.html
        echo "<td> SITEDEF </td>"  >>  ${duo_work_dir}/cell_info.html
        echo "</tr>" >>  ${duo_work_dir}/cell_info.html
        echo "<tr>" >>  ${duo_work_dir}/cell_info.html

        foreach one_check $checkpoints {
            echo "<tr>" >>  ${duo_work_dir}/cell_info.html
            regexp {(\S+)\.design} $one_check all step
            if {[file exist ${duo_work_dir}/$clib.$one_check.cell.snapshot.gif]} {
                echo "<td><a href=\"$clib.$one_check.cell.snapshot.gif\"> $step</a> </td>" >>  ${duo_work_dir}/cell_info.html
            } else {
                echo "<td> $step </td>" >>  ${duo_work_dir}/cell_info.html
            }
            set cell_info [sh cat ${duo_work_dir}/$clib.$one_check.info]
            foreach one_info $cell_info  {
                echo "<td> $one_info  </td>" >>  ${duo_work_dir}/cell_info.html
            }
            echo "</tr>" >>  ${duo_work_dir}/cell_info.html
        }
        echo "</table>" >>  ${duo_work_dir}/cell_info.html
        sh cat [getenv duo_dir]/foot.html >> cell_info.html
        puts "Report End"
        puts "Link for snapshot: http://clearcase/[pwd]/${duo_work_dir}/cell_info.html"

    }

    #print path analysis report
    if {$path_from != "" || $path_through != "" || $path_to != ""} {
        set report_head ""
        if {$path_from != "" } {
            append report_head " from $path_from"
        }
        if {$path_through != ""} {
            append report_head " through $path_through"
        }
        if {$path_to != ""} {
            append report_head " to $path_to"
        }
        
        echo "Report for path $report_head"
        set w1 12
        set w2 25
        puts [format "%*s%*s%*s" $w1 STEP $w1 EXISTENCE $w1 SLACK]
        exec sed "s/TITLE/Report for path/g" \
         [getenv duo_dir]/head.html  > ${duo_work_dir}/path.html

        echo "<table>" >> ${duo_work_dir}/path.html
        foreach one_check $checkpoints {
            echo "<tr>" >> ${duo_work_dir}/path.html
            regexp {(\S+)\.design} $one_check all step
            puts [format "%*s%s" $w1 $step [sh cat ${duo_work_dir}/$clib.$one_check.info]]
            if {[file exist ${duo_work_dir}/$clib.$one_check.snapshot.gif]} {
                echo "<td><a href=\"$clib.$one_check.snapshot.gif\"> $step</a> </td> <td> [sh cat ${duo_work_dir}/$clib.$one_check.info] </td>" >> ${duo_work_dir}/path.html
                echo "</tr>" >> ${duo_work_dir}/path.html
            } else {
                echo "<td> $step </td> <td> [sh cat ${duo_work_dir}/$clib.$one_check.info] </td>" >> ${duo_work_dir}/path.html
                echo "</tr>" >> ${duo_work_dir}/path.html
            }

        }
        echo "</table>" >> ${duo_work_dir}/path.html
        sh cat [getenv duo_dir]/foot.html >> ${duo_work_dir}/path.html
        puts "Report End"
        puts "Link for snapshot: http://clearcase/[pwd]/${duo_work_dir}/path.html"
    }
    #print net analysis result
    if {$net_name != ""} {
        echo "Report for net $net_name"
        set w1 12
        set w1_1  20

        set w2 25
        puts [format "%*s%*s%*s%*s" $w1 STEP $w1 TRANS $w1 TRANS_CON $w1 fanout ]
        foreach one_check $checkpoints {
            regexp {(\S+)\.design} $one_check all step
#            echo "$step" [sh cat $clib.$one_check.info]
            puts [format "%*s%s" $w1 $step [sh cat ${duo_work_dir}/$clib.$one_check.info]]
        }

        exec sed "s/TITLE/Report for net/g" \
         /remote/pv/utility/icc2/optimization/duo/head.html  > ${duo_work_dir}/net_info.html

        echo "<table>" >> ${duo_work_dir}/net_info.html
        echo "<tr>" >> ${duo_work_dir}/net_info.html
        echo "<td> STEP </td>" >> ${duo_work_dir}/net_info.html
        echo "<td> TRANS </td>" >> ${duo_work_dir}/net_info.html
        echo "<td> TRANS_CON</td>" >> ${duo_work_dir}/net_info.html

        echo "<td> Fanout </td>"  >> ${duo_work_dir}/net_info.html
        echo "</tr>" >> ${duo_work_dir}/net_info.html

        foreach one_check $checkpoints {
            echo "<tr>" >> ${duo_work_dir}/net_info.html
            regexp {(\S+)\.design} $one_check all step
            if {[file exist ${duo_work_dir}/$clib.$one_check.net.snapshot.gif]} {
                echo "<td><a href=\"$clib.$one_check.net.snapshot.gif\"> $step</a> </td>" >> ${duo_work_dir}/net_info.html
            }  else {
                echo "<td> $step </td>" >> ${duo_work_dir}/net_info.html
            }
            set net_info [sh cat ${duo_work_dir}/$clib.$one_check.info]
            foreach one_info $net_info  {
                echo "<td> $one_info  </td>" >> ${duo_work_dir}/net_info.html
            }
            echo "</tr>" >>  ${duo_work_dir}/net_info.html
        }
        echo "</table>" >> ${duo_work_dir}/net_info.html
        sh cat [getenv duo_dir]/foot.html >> ${duo_work_dir}/net_info.html

        puts "Report End"
        puts "Link for snapshot: http://clearcase/[pwd]/${duo_work_dir}/net_info.html"
    }

     if {$is_density}  {                                                                                        
         exec sed "s/TITLE/Report for net/g" \
          /remote/pv/utility/icc2/optimization/duo/head.html  >  ${duo_work_dir}/density_info.html                  

         echo "<table>" >>  ${duo_work_dir}/density_info.html                                                    
         echo "<tr>" >>  ${duo_work_dir}/density_info.html                                             
         echo "<td> STEP </td>" >>  ${duo_work_dir}/density_info.html
         echo "</tr>" >>  ${duo_work_dir}/density_info.html


         foreach one_check $checkpoints {
             echo "<tr>" >>  ${duo_work_dir}/density_info.html
             regexp {(\S+)\.design} $one_check all step
             if {[file exist ${duo_work_dir}/$clib.$one_check.density.snapshot.gif]} {
                 echo "<td><a href=\"$clib.$one_check.density.snapshot.gif\"> $step</a> </td>" >>  ${duo_work_dir}/density_info.html
             }  else {
                 echo "<td> $step </td>" >>  ${duo_work_dir}/density_info.html
             }
             set net_info [sh cat ${duo_work_dir}/$clib.$one_check.info]
             foreach one_info $net_info  {
                 echo "<td> $one_info  </td>" >>  ${duo_work_dir}/density_info.html
             }
             echo "</tr>" >>  ${duo_work_dir}/density_info.html
         }
         echo "</table>" >>  ${duo_work_dir}/density_info.html
         sh cat [getenv duo_dir]/foot.html >>  ${duo_work_dir}/density_info.html

         puts "Report End"
         puts "Link for snapshot: http://clearcase/[pwd]/${duo_work_dir}/density_info.html"

     }

     if {$is_cong}  {
         exec sed "s/TITLE/Report for net/g" \
          /remote/pv/utility/icc2/optimization/duo/head.html  > ${duo_work_dir}/cong_info.html

         echo "<table>" >> ${duo_work_dir}/cong_info.html                                                          
         echo "<tr>" >> ${duo_work_dir}/cong_info.html                                                         
         echo "<td> STEP </td>" >> ${duo_work_dir}/cong_info.html
         echo "</tr>" >> ${duo_work_dir}/cong_info.html


         foreach one_check $checkpoints {
             echo "<tr>" >> ${duo_work_dir}/cong_info.html
             regexp {(\S+)\.design} $one_check all step
             if {[file exist ${duo_work_dir}/$clib.$one_check.congestion.snapshot.gif]} {
                 echo "<td><a href=\"$clib.$one_check.congestion.snapshot.gif\"> $step</a> </td>" >> ${duo_work_dir}/cong_info.html
             }  else {
                 echo "<td> $step </td>" >> ${duo_work_dir}/cong_info.html
             }
             set net_info [sh cat ${duo_work_dir}/$clib.$one_check.info]
             foreach one_info $net_info  {
                 echo "<td> $one_info  </td>" >> ${duo_work_dir}/cong_info.html
             }
             echo "</tr>" >> ${duo_work_dir}/cong_info.html
         }
         echo "</table>" >> ${duo_work_dir}/cong_info.html
         sh cat [getenv duo_dir]/foot.html >> ${duo_work_dir}/cong_info.html

         puts "Report End"
         puts "Link for snapshot: http://clearcase/[pwd]/${duo_work_dir}/cong_info.html"

     }


}

define_proc_attributes duo -info "debugging utility for optimization" \
   -define_args {\
   {
       -cell "input cell name to analyze" cell_input string optional
   }

   {
       -path_from "input startpoint" pin_input string optional
   }


   {
       -path_through "input through point" pin_input string optional
   }


   {
       -path_to "input endpoint" pin_input string optional
   }

   {
       -net "input net name to analyze" net_input string optional
   }

   {
        -density "dump cell density map for whole design" "" boolean optional
   }


   {
        -congestion "dump congestion map for whole design" "" boolean optional
   }


  }

