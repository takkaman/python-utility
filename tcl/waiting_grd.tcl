#! /usr/bin/tclsh

# Waiting all qstat are finished
if {!$argc} {
	set interval 10m
} else {
	set interval [lindex $argv 0]
}

set job_id ""
set initial_list ""
set INI [open qstat.initial r]
while {[gets $INI line] >= 0} {
    regexp {^.*?(\d+)\s.*} $line tmp job_id
    lappend initial_list $job_id
}
close $INI

set job_id ""
set run_list ""
set RUN [open qstat.run r]
while {[gets $RUN line] >= 0} {
    regexp {^.*?(\d+)\s.*} $line tmp job_id
    lappend run_list $job_id
}
close $RUN

#puts $initial_list
#puts $run_list

# Remove initial_list from run_list
foreach itr $initial_list {
    if {[lsearch $run_list $itr] >= 0} {
    	set index [lsearch $run_list $itr]
	    set run_list [lreplace $run_list $index $index]
    }
}

if {![llength $run_list]} {
    exit
}

#puts $initial_list
#puts $run_list
#puts "########################################"

set job_id ""
set sleep_mode 1
while {$sleep_mode} {
    catch {exec qstat > qstat.new}
    set new_list ""
    set NEW [open qstat.new r]	
    while {[gets $NEW line] >= 0} {
    	if {[regexp {^.*?(\d+)\s.*} $line tmp job_id]} {
    	    lappend new_list $job_id
		}
    }
    close $NEW
    #puts $new_list
    
    set flag 1
    foreach itr $new_list {
    	if {[lsearch $run_list $itr] >= 0} {
            set flag [expr {$flag & 0}]
		}
    }

    if {$flag} {
    	set sleep_mode 0
    } else {
		set core_file ""
		catch {set core_file [glob run*/core*]}
		foreach file $core_file {
			file delete -force $file
		}

		exec sleep $interval 
    }
}

#eval exec rm -f [glob bjobs.*]
exit
