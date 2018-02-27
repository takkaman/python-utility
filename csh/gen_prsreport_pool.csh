#!/bin/csh -fb

set s = ` date `

source ./dir_info_csh

set SH_dir = ` ls -d R2016* `

cd $repeat_dir
cp -f /remote/pv/utility/icc2/optimization/qor_regression/utility/propts_repeat.cfg ./propts.cfg
setenv PRSUITE_HOME ~sunna/RegQoRPRS
prreport.pl -partial -filtergspg -filterpg_useflow -stack -showall -html -minparse -bold_row 9999 -rcache -cachefiles prreport.cache -alldes -success "^(Done|FMNoVer)" -rows "MeanVal Mean MeanX Mean1/X NSDMean 95%High 95%Low StdDev SDMean ProbErr Count Histgrm" -columns "FlowLong ICPWNS ICPTNS ICPTNSPM ICPNVioPPM ICPTotalHoldVioPM ICPWorstHoldVioPM ICPNHoldVioPM ICPMaxTCostPM ICPNMxTranPM ICPNMxCapPM Gap ICPPhysicalArea ICPAreaLeafCel ICPMvArea ICPInst ICPBufInvArea ICPBufArea ICPInvArea ICPBufInvCnt ICPBufCnt ICPInvCnt Gap ICPSLeakPow ICPSDynPow ICPSTotPow ICPGLVthDVio Gap ICPOPTCPU ICPOPTMEM ICPHFN60 ICPHFN100 Gap FlowLong ICCWNS ICCTNS ICCTNSPM ICCNVioPPM ICCTotalHoldVioPM ICCWorstHoldVioPM ICCNHoldVioPM ICCMaxTCostPM ICCNMxTranPM ICCNMxCapPM Gap ICCPhysicalArea ICCAreaLeafCel ICCMvArea ICCInst ICCBufInvArea ICCBufArea ICCInvArea ICCBufInvCnt ICCBufCnt ICCInvCnt Gap ICCSLeakPow ICCSDynPow ICCSTotPow ICCGLVthDVio Gap ICCOPTCPU ICCOPTMEM ICCHFN60 ICCHFN100 Gap FlowLong ICFWNS ICFTNS ICFTNSPM ICFNVioPPM ICFTotalHoldVioPM ICFWorstHoldVioPM ICFNHoldVioPM ICFMaxTCostPM ICFNMxTranPM ICFNMxCapPM Gap ICFPhysicalArea ICFAreaLeafCel ICFMvArea ICFInst ICFBufInvArea ICFBufArea ICFInvArea ICFBufInvCnt ICFBufCnt ICFInvCnt Gap ICFSLeakPow ICFSDynPow ICFSTotPow ICFGLVthDVio Gap ICFOPTCPU ICFOPTMEM ICFHFN60 ICFHFN100 Gap" -base flow_${latest_bin} 

echo "Run step 1"
/remote/pv/repo/pvutil/prsetc/bin/outlier.tcl -tsv html > ! html/outlier.tsv
echo "Run step 2"
/u/pv/utility/icc2/optimization/qor_regression/utility/proutlier html/outlier.tsv > ! outlier.html
      
cd $rpt_dir
cp -f /remote/pv/utility/icc2/optimization/qor_regression/utility/propts.cfg .

setenv PRSUITE_HOME ~sunna/RegQoRPRS
prreport.pl -partial -filtergspg -filterpg_useflow -stack -showall -html -minparse -bold_row 9999 -rcache -cachefiles prreport.cache -alldes -success "^(Done|FMNoVer)" -rows "MeanVal Mean MeanX Mean1/X NSDMean 95%High 95%Low StdDev SDMean ProbErr Count Histgrm" -columns "FlowLong ICPWNS ICPTNS ICPTNSPM ICPNVioPPM ICPTotalHoldVioPM ICPWorstHoldVioPM ICPNHoldVioPM ICPMaxTCostPM ICPNMxTranPM ICPNMxCapPM Gap ICPPhysicalArea ICPAreaLeafCel ICPMvArea ICPInst ICPBufInvArea ICPBufArea ICPInvArea ICPBufInvCnt ICPBufCnt ICPInvCnt Gap ICPSLeakPow ICPSDynPow ICPSTotPow ICPGLVthDVio Gap ICPOPTCPU ICPOPTMEM ICPHFN60 ICPHFN100 Gap FlowLong ICCWNS ICCTNS ICCTNSPM ICCNVioPPM ICCTotalHoldVioPM ICCWorstHoldVioPM ICCNHoldVioPM ICCMaxTCostPM ICCNMxTranPM ICCNMxCapPM Gap ICCPhysicalArea ICCAreaLeafCel ICCMvArea ICCInst ICCBufInvArea ICCBufArea ICCInvArea ICCBufInvCnt ICCBufCnt ICCInvCnt Gap ICCSLeakPow ICCSDynPow ICCSTotPow ICCGLVthDVio Gap ICCOPTCPU ICCOPTMEM ICCHFN60 ICCHFN100 Gap FlowLong ICFWNS ICFTNS ICFTNSPM ICFNVioPPM ICFTotalHoldVioPM ICFWorstHoldVioPM ICFNHoldVioPM ICFMaxTCostPM ICFNMxTranPM ICFNMxCapPM Gap ICFPhysicalArea ICFAreaLeafCel ICFMvArea ICFInst ICFBufInvArea ICFBufArea ICFInvArea ICFBufInvCnt ICFBufCnt ICFInvCnt Gap ICFSLeakPow ICFSDynPow ICFSTotPow ICFGLVthDVio Gap ICFOPTCPU ICFOPTMEM ICFHFN60 ICFHFN100 Gap" -base base_${prev_bin}

echo "Run step 1"
/remote/pv/repo/pvutil/prsetc/bin/outlier.tcl -tsv html > ! html/outlier.tsv
echo "Run step 2"
/u/pv/utility/icc2/optimization/qor_regression/utility/proutlier html/outlier.tsv > ! outlier.html

/remote/us01home40/phyan/depot/python/bin/python /u/phyan/qor_regression/utility/qor_trend_analysis.py $latest_bin outlier.html


sed -i "/ui header.*Outlier Summary/aBase branch: ${branch} $prev_bin<\/br>Test branch: ${branch} $latest_bin<\/br>" outlier.html

echo "To: sunna@synopsys.com phyan@synopsys.com" > ! mail
echo "Cc: weif@synopsys.com" >> mail
echo "Subject: Regression QoR Report for ${branch}($latest_bin)" >> mail
echo "Content-Type: text/html;" >> mail


echo "<html>" >> mail
echo "<head>" >> mail
echo \<style type=\"text\/css\"\> >> mail
echo "body {font-family:arial; font-size:14}" >> mail
echo "</style>" >> mail
echo "</head>" >> mail
echo "<body>" >> mail
echo "Hi All,</br>" >> mail
echo "&nbsp</br>" >> mail
echo "The following is the QoR Regression report. The test cases come from PV regression and random suite. This report compare the recent two runs' result.</br>" >> mail

echo "<ul>" >> mail
echo "<li>Binary Info" >> mail
echo "<ul>" >> mail
echo "<li>Base branch: ${branch} $prev_bin</li>" >> mail
echo "<li>Test branch: ${branch} $latest_bin<br></br></li>" >> mail
echo "</ul>" >> mail
echo "</li>" >> mail
echo "<li>The detail QoR report" >> mail
echo "<ul>" >> mail
echo \<li\>\<a href=\"http://clearcase/${rpt_dir}/outlier.html\"\>Compare_with_last_run\</a\>\<br\>\</br\>\</li\> >> mail
echo "</ul>" >> mail
echo "</li>" >> mail
echo "<li>The QoR trend" >> mail
echo "<ul>" >> mail
echo \<li\>\<a href=\"http://clearcase/${rpt_dir}/qor_trend_analysis.html\"\>QoR_Trend_Analysis\</a\>\<br\>\</br\>\</li\> >> mail
echo "</ul>" >> mail
echo "</li>" >> mail
echo "<li>Repeatability report (Same image, run twice)" >> mail
echo "<ul>" >> mail
echo \<li\>\<a href=\"http://clearcase/${repeat_dir}/outlier.html\"\>Repeatability\</a\>\<br\>\</br\>\</li\> >> mail
echo "</ul>" >> mail
echo "</li>" >> mail
echo "ADD HERE" >> mail
echo "&nbsp</br>" >> mail
echo "----------------------------</br>" >> mail
echo "The previous report:</br>" >> mail
echo "----------------------------</br>" >> mail
echo "&nbsp</br>" >> mail
ls -r /remote/us01home24/sunna/proj_disk/NT/reg_qor/send_mail_cmp > ! pre_mail
sed -i "1d" pre_mail
sed -i "3,$ d" pre_mail
foreach m ( `cat pre_mail` )
  set n = `wc -l < mail`
  sed -i "${n}r /remote/us01home24/sunna/proj_disk/NT/reg_qor/send_mail_cmp/$m" mail
  echo "  </br>" >> mail
end
rm -rf pre_mail
echo "</br>" >> mail
echo "</br>" >> mail
echo "Best Regards</br>" >> mail
echo "Na Sun</br>" >> mail
echo "</body>" >> mail
echo "</html>" >> mail

#/usr/sbin/sendmail -t < mail

echo "Base branch: ${branch} $prev_bin </br>"  > ! /remote/us01home24/sunna/proj_disk/NT/reg_qor/send_mail_cmp/mail_${latest_bin}
echo "Flow branch: ${branch} $latest_bin</br>" >> /remote/us01home24/sunna/proj_disk/NT/reg_qor/send_mail_cmp/mail_${latest_bin}
echo \<a href=\"http://clearcase/${rpt_dir}/outlier.html\"\>Compare_with_last_run\</a\> >> /remote/us01home24/sunna/proj_disk/NT/reg_qor/send_mail_cmp/mail_${latest_bin}
echo "&nbsp</br>" >> /remote/us01home24/sunna/proj_disk/NT/reg_qor/send_mail_cmp/mail_${latest_bin}

cd $latest_dir

chmod -R 777 $rpt_dir

### Generate the check point for outlier case ###
/remote/pv/utility/icc2/optimization/qor_regression/utility/outlier_assert_v2.pl -rpt_dir ${rpt_dir}/flow_${latest_bin} -run_dir ${latest_dir}/${SH_dir}/ICC2/Feature | tee outlier_assert_v2.log

set e = ` date `


echo "Start time: $s"
echo "End time: $e"
exit
