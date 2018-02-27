#!/remote/us01home40/phyan/depot/Python-2.7.11/bin/python
import os
import time, datetime
import commands
import re

ICC2_BIN_TAIL = 'Testing/linux64/nwtn/bin/icc2_exec'
CRNT_DATE = datetime.date.today()
RESULT_LIST = ["PASS","PASS","PASS","PASS","PASS","PASS","FATAL","FATAL","FATAL"]
RESULT_LIST1 = ["PASS","PASS","PASS","PASS","FATAL","FATAL","FATAL","FATAL","FATAL"]
RESULT_LIST2 = ["FATAL","PASS","PASS","PASS","FATAL","FATAL","FATAL","FATAL","FATAL"]
last_pass = 0
first_fatal = 0
tcl_file = ''
log_suffix = ''

def get_fatal_since(day, icc2_release):
    global last_pass, first_fatal
    #get binary list
    bin_list = []
    for i in range(day):
        date = (CRNT_DATE + datetime.timedelta(-i)).strftime('%Y%m%d');
        try:
            (status, output) = commands.getstatusoutput("ls "+icc2_release+'/D'+date+'*/'+ICC2_BIN_TAIL)
            if status == 0:
                bin_exec_list = output.split('\n')
                for bin_exec in bin_exec_list:
                    print "Find binary of -%d day: %s" % (i, bin_exec)
                bin_list.extend(bin_exec_list)
        except:
            pass

    #print bin_list
    print "Start fatal date detection..."
    bin_list.reverse()
    first_fatal = len(bin_list)-1
    #exit()
    run_icc2_images(bin_list, last_pass)

def get_fatal_from_to(start_date, end_date, icc2_release):
    global last_pass, first_fatal
    bin_list = []
    s=time.strptime(start_date,'%Y%m%d');
    e=time.strptime(end_date,'%Y%m%d');
    s_datetime=datetime.datetime(*s[:3]);
    e_datetime=datetime.datetime(*e[:3]);
    dayCount = (e_datetime - s_datetime).days
    for i in range(dayCount+1):
        date = (e_datetime + datetime.timedelta(-i)).strftime('%Y%m%d');
        try:
            (status, output) = commands.getstatusoutput("ls "+icc2_release+'/D'+date+'*/'+ICC2_BIN_TAIL)
            if status == 0:
                bin_exec_list = output.split('\n')
                for bin_exec in bin_exec_list:
                    print "Find binary of -%d day: %s" % (i, bin_exec)
                bin_list.extend(bin_exec_list)
        except:
            pass

    #print bin_list
    print "Start fatal date detection..."
    bin_list.reverse()
    first_fatal = len(bin_list)-1
    #exit()
    run_icc2_images(bin_list, last_pass) 

def run_icc2_images(bin_list, check_index):
    global last_pass, first_fatal
    print (last_pass, first_fatal)
    #run binary
    bin_exec = bin_list[check_index]
    result = run_and_check(bin_exec)

    if result == "FATAL":
        print "Found fatal in %s" % bin_exec
        first_fatal = check_index
        if first_fatal == 0:
            print "All fatal during the period, please expand the date range!"
            exit(0)
        if last_pass == first_fatal - 1:
            print "Find fatal occur date (%s, %s)" %(bin_list[last_pass], bin_list[first_fatal])
            run_culprit(bin_list[last_pass],bin_list[first_fatal])

    else:
        print "No fatal found in %s" % bin_exec
        last_pass = check_index
        if last_pass == first_fatal - 1:
            print "Find fatal occur date (%s, %s)" %(bin_list[last_pass], bin_list[first_fatal])
            run_culprit(bin_list[last_pass],bin_list[first_fatal])

    if (last_pass+first_fatal)%2 == 0:
        check_index = (last_pass+first_fatal)/2
    else:
        check_index = (last_pass+first_fatal)/2+1

    run_icc2_images(bin_list, check_index)

def run_and_check(bin_exec):
    global tcl_file
    bin_date = extract_date(bin_exec)
    #os.system("mkdir "+bin_date)
    #os.chdir(bin_date)
    os.system(bin_exec+' -f '+tcl_file+' > log_'+bin_date)
    os.system("pvfatal log_"+bin_date+' > fatal_info_'+bin_date)
    (status, output) = commands.getstatusoutput("grep 'Fatal Found' fatal_info_"+bin_date)
    #os.chdir("..")
    if status == 0:
        return "FATAL"
    else:
        return "PASS"

    #return RESULT_LIST2[bin_exec]

def run_culprit(pass_bin, fatal_bin):
    start_culprit = extract_culprit(pass_bin)
    end_culprit = extract_culprit(fatal_bin)
    branch = extract_branch(pass_bin)
    print "Launch original culprit_diy.pl..."
    print start_culprit, end_culprit, branch
    #os.system("/remote/pv/regression/utility/others/culprit_diy.pl -product ICC2 -branch "+branch+" -base_image "+start_culprit+" -current_image "+end_culprit+" -test_tcl "+tcl_file+" > culprit.run.log")
    print "Culprit finder run finished, please check culprit.run.log to see if there's culprit found!"
    exit(0)

def extract_branch(bin_exec):
    match = re.search('.*image\/(.*)-DEV\/D\d+_\d+\/',bin_exec)
    if match:
        return match.group(1)
    else:
        print "Exception found during branch extraction of bin: %s" %bin_exec
        return 0

def extract_culprit(bin_exec):
    match = re.search('.*\/D\d+_(\d+)\/',bin_exec)
    if match:
        return match.group(1)
    else:
        print "Exception found during culprit extraction of bin: %s" %bin_exec
        return 0

def extract_date(bin_exec):
    match = re.search('.*\/D(\d+)_\d+\/',bin_exec)
    if match:
        return match.group(1)
    else:
        print "Exception found during date extraction of bin: %s" %bin_exec
        return 0

if __name__ == "__main__":
    import argparse
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('-tcl', required=True, help='Run tcl')
        parser.add_argument('-icc2_release', required=True, help="ICC2 release bin date path like '/u/nwtnmgr/image/N-2017.09-DEV'")
        parser.add_argument('-day', help='Backtrace day number') 
        parser.add_argument('-start_date', help='Start date, eg: 20170610')
        parser.add_argument('-end_date', help='End date, eg: 20170620')
        
        args = parser.parse_args()
        tcl_file = args.tcl

        if args.day is not None:
            get_fatal_since(int(args.day), args.icc2_release)

        elif args.start_date is not None and args.end_date is not None:
            get_fatal_from_to(args.start_date, args.end_date, args.icc2_release)
        else:
            print "Please choose either '-day' or '-start_date/end_date'!"

    except OSError as e:
        import traceback
        traceback.print_exc()
        print "I/O error({0}): {1} {2}".format(e.errno, e.strerror, e.filename)
    except Exception as e:
        import traceback
        traceback.print_exc()
        print e