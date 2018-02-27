#!/remote/pv/web/util/opt/depot/anaconda3/bin/python
import os
import subprocess
import pandas as pd
import numpy as np

pd.options.mode.chained_assignment = None  # default='warn'

QOR_COLUMNS = ['base_wns', 'test_wns', 'base_tns', 'test_tns', 'base_bufinv_cnt', 'test_bufinv_cnt', 'base_bufinv_area', 'test_bufinv_area', 'base_max_tran', 'test_max_tran', 'base_max_cap', 'test_max_cap', 'base_lkg_pwr', 'test_lkg_pwr', 'base_dyn_pwr', 'test_dyn_pwr', 'base_cpu', 'test_cpu', 'base_mem', 'test_mem']

class QorExtractor():
    def __init__(self, case_list, base_dir, test_dir, csv_path):
        self.__case_list = case_list;
        self.__base_dir = os.path.abspath(base_dir);
        self.__test_dir = os.path.abspath(test_dir);
        self.__csv_path = csv_path;
        self.__case_dir = self.__get_case_dirs()
        self.df = pd.DataFrame(index=QOR_COLUMNS)

    @property
    def case_dirs(self):
        return self.__case_dir

    def __get_case_dirs(self):
        case_dir = []
        with open(self.__case_list) as f:
            fp = f.readlines()
            for case in fp:
                case_dir.append(case.strip())
        # print(case_dir)
        return case_dir

    def comp_qor(self):
        # print(self.__base_dir)
        for case_dir in self.__case_dir:
            case_name = case_dir.split('/')[-1]
            # print(case_dir)
            # case_dir_mod = self.df['_'.join(case_dir.split('/'))]
            base_path = self.__base_dir + '/ICC2/' + case_dir + "/tmp_test/run_dir_" + case_name + '/run/'
            base_path_1 = self.__base_dir + '/ICC2/' + case_dir
            test_path = self.__test_dir + '/ICC2/' + case_dir + "/tmp_test/run_dir_" + case_name + '/run/'   
            test_path_1 = self.__test_dir + '/ICC2/' + case_dir
            self.df[case_dir] = [np.nan] * len(QOR_COLUMNS)        
            # prim qor
            self.df[case_dir].base_wns, self.df[case_dir].base_tns = self.__get_prim_qor(base_path+'tim_qor.rpt')
            self.df[case_dir].test_wns, self.df[case_dir].test_tns = self.__get_prim_qor(test_path+'tim_qor.rpt')
            # secondary qor
            self.df[case_dir].base_bufinv_cnt, self.df[case_dir].base_bufinv_area = self.__get_secondary_qor(base_path+'qor.rpt')
            self.df[case_dir].test_bufinv_cnt, self.df[case_dir].test_bufinv_area = self.__get_secondary_qor(test_path+'qor.rpt')
            # pwr
            self.df[case_dir].base_lkg_pwr, self.df[case_dir].base_dyn_pwr = self.__get_pwr(base_path+'pwr.rpt')
            self.df[case_dir].test_lkg_pwr, self.df[case_dir].test_dyn_pwr = self.__get_pwr(test_path+'pwr.rpt')
            # cstr
            self.df[case_dir].base_max_tran, self.df[case_dir].base_max_cap = self.__get_cstr(base_path+'cstr.rpt')
            self.df[case_dir].test_max_tran, self.df[case_dir].test_max_cap = self.__get_cstr(test_path+'cstr.rpt')
            # cpu mem
            self.df[case_dir].base_cpu, self.df[case_dir].base_mem = self.__get_cpu_mem(base_path_1+'/'+case_name+'.log')
            self.df[case_dir].test_cpu, self.df[case_dir].test_mem = self.__get_cpu_mem(test_path_1+'/'+case_name+'.log')

        print(self.df)
        self.df.T.to_csv(self.__csv_path)
        # self.df.T.to_csv(self.__csv_path,float_format='%g')

    def __get_pwr(self, rpt):
        """extract leakage and dynamic power"""
        lkg_pwr = dyn_pwr = np.nan
        try:
            pwr_unit = subprocess.getoutput('grep "Leakage Power Unit" '+rpt).split()[-1]
            lkg_pwr = subprocess.getoutput('grep "Cell Leakage Power" '+rpt).split()[4]
            dyn_pwr = subprocess.getoutput('grep "Total Dynamic Power" '+rpt).split()[4] 
        except:
            pass

        return lkg_pwr, dyn_pwr

    def __get_prim_qor(self, rpt):
        """extract wns, tns"""
        wns = tns = np.nan
        try:
            setup_info = subprocess.getoutput('grep "Design.*(Setup)" '+rpt).split()
            # print(setup_info)
            wns = setup_info[2]
            tns = setup_info[3]
        except:
            pass

        return wns, tns

    def __get_secondary_qor(self, rpt):
        """extract bug/inv count, area"""
        bufinv_cnt = bufinv_area = np.nan
        try:
            bufinv_cnt = subprocess.getoutput('grep "Buf/Inv Cell Count" '+rpt).split()[3]
            bufinv_area = subprocess.getoutput('grep "Buf/Inv Area" '+rpt).split()[2]
        except:
            pass

        return bufinv_cnt, bufinv_area

    def __get_cstr(self, rpt):
        """extract max_transition and max_capacitance vio"""
        max_tran = max_cap = np.nan
        try:
            max_tran = subprocess.getoutput('grep " max_transition" '+rpt).split()[1]
            max_cap = subprocess.getoutput('grep " max_capacitance" '+rpt).split()[1]
        except:
            pass

        return max_tran, max_cap

    def __get_cpu_mem(self, rpt):
        """extract CPU and PEAK_MEM"""
        cpu = mem = np.nan
        try:
            # cpu = subprocess.getoutput('grep "Place_opt cpu is:" '+rpt).split()[3]
            cpu = subprocess.getoutput("awk '{a[NR]=$0;if((a[NR-1]~/set popt_cpu/)&&(a[NR]!~/# NEXT IS TCL/)){print a[NR]}}' "+rpt)
            mem = subprocess.getoutput('grep "Maximum memory usage for this session:" '+rpt).split()[6]
        except:
            pass

        return cpu, mem

if __name__ == "__main__":
    import argparse
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('-case_list', required=True, help='SH case list')       
        parser.add_argument('-base_dir', required=True, help='Base run root dir')
        parser.add_argument('-test_dir', required=True, help='Test run root dir')
        parser.add_argument('-dump_csv', required=True, help='Output result to csv.')
        args = parser.parse_args()
        # print(args.base_dir)
        qor_ext = QorExtractor(args.case_list, args.base_dir, args.test_dir, args.dump_csv)
        qor_ext.comp_qor()

    except OSError as e:
        import traceback
        traceback.print_exc()
        print("I/O error({0}): {1} {2}".format(e.errno, e.strerror, e.filename))
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(e)