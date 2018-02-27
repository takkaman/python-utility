#!/usr/bin/tclsh 

if {[file exist __tmp]} {
  source __tmp
  puts "job_id is: $job_id"
  set check 1
  set i 1
  while {$check} {
    puts "$i: Check the job status..."
    incr i
    if {[file exist jstat]} {
     exec rm -rf jstat
    } 
    exec qstat > jstat
    foreach j $job_id {
       puts $j  
#puts $job_id
       exec qstat
       if {[catch {exec grep $j jstat}]} {
#exec grep $j jstat
          regsub $j $job_id {} job_id
       } else {
         exec grep $j jstat
         break
       }
    }
    puts [llength $job_id]
    if {[llength $job_id]==0} {
       set check 0
    } else {
      exec pwd
      exec sleep 300
    }
  }  
  puts "All jobs are done"
} else {
  puts "Job ID file does not exist"
}
