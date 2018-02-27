#!/bin/csh 
source /remote/us01home40/phyan/.cshrc

#set icc2_image = "/u/nwtnmgr/image/nwtn_main_dev/latest/Testing/linux64/nwtn/bin/icc2_exec"
#set icc2_image = "/u/nwtnmgr/image/K-2015.06-SP-DEV/latest/Testing/linux64/nwtn/bin/icc2_exec"
#set PV_24x7_IMAGE = "/u/nwtnmgr/image/nwtn_main_dev/latest/Testing/" 
  
set bjob_server = "-l minslotmem=16G"    
#fetch options
setenv PV_24x7_RELEASE "L-2016.03-SP"

set user_list = ($argv[1])
set user_num = ${#user_list}
#set date = ($argv[2])
#set start_date = $date[1]
#set end_date = $date[2]
set days = $argv[2]
set today = `date +%Y%m%d`

echo "preparing qor folder..."
if (! -d "qor_compare") then
  mkdir qor_compare
  cd qor_compare
  mkdir base compare
  cd ..
endif

set work_dir = ${PWD}
echo $work_dir

set i = 1
while ($i <= $user_num)
  set d = 0
  while ($d <= $days)
    set date = `date -d "-$d day" +%Y%m%d`
    echo "Extract QoR data for $user_list[$i], date $date"
    set qor_dir = `ls /remote/pv/24x7/nwtn/${PV_24x7_RELEASE}/optimization/opt_random_suite_icc2_$user_list[$i]/D$date*`
    set qor_dir = `echo $qor_dir | awk '{print substr($1,1,length($1)-1)}'`

    if (-d "$qor_dir") then
      echo "Find dir: $qor_dir"
      cd $qor_dir     
    else
      echo "Cannot find dir for user: $user_list[$i], date: $date ... Skip Daily QoR summary..."
      set cclist = "weif phyan"
#      echo "No data for user: $user_list[$i], date: $date, branch ${PV_24x7_RELEASE}..." > email.html 
#      cat email.html | /u/junma/bin/mutt -c $cclist -e 'set content_type="text/html"' -s "ICC2 Preroute Random Suite Daily Summary" $USER
      @ d = $d + 1
      continue
    endif
    
    set base_run_list = `find ./ -name "base"`
    set compare_run_list = `find ./ -name "compare"`

    #link base run
    echo "collecting base qor data"
    cd $work_dir/qor_compare/base
    foreach run ($base_run_list)
      if ($run !~ "*report*" && $run !~ "*html*" && $run !~ "*qor_compare*") then        
        echo "Linking $qor_dir/$run"
        ln -s $qor_dir/$run/* .
      endif
    end
    
    #link compare run
    echo "collecting compare qor data"
    cd ../compare
    foreach run ($compare_run_list)
      if ($run !~ "*report*" && $run !~ "*html*" && $run !~ "*qor_compare*") then
        ln -s $qor_dir/$run/* . 
        echo "Linking $qor_dir/$run"
      endif
    end
             
    @ d = $d + 1
  end
  @ i = $i + 1
end

cd $work_dir/qor_compare 
#generate qor report
/remote/us01home40/phyan/random_icc2/report.csh
ln -s report html
ln -s /remote/us01home40/phyan/random_icc2/utility/outlier_propts.cfg propts.cfg
/remote/pv/repo/pvutil/prsetc/bin/outlier.tcl -tsv html >! html/outlier.tsv
/remote/pv/repo/pvutil/prsetc/bin/proutlier html/outlier.tsv > outlier.html
   
cd ..
# Send mail
echo "Preparing mail to user."
/remote/us01home40/phyan/random_icc2/utility/report_gen_customer_qor.pl
#set cclist = "phyan, weif"
set cclist = "phyan" 
cat email.html | /u/junma/bin/mutt -c $cclist -e 'set content_type="text/html"' -s "ICC2 QoR Summary" ${USER}

chmod 777 .
