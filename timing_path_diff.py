#!/remote/pv/web/util/opt/depot/anaconda3/envs/tensorflow/bin/python
import os, re

def is_buf_inv(cell):
    mark = False
    # exclude SGI* *BUF* *INV* *RLB* 
    if 'SGI' in cell:
        mark = True
    if 'BUF' in cell:
        mark = True
    if 'INV' in cell:
        mark = True
    if 'RLB' in cell:
        mark = True

    return mark

class ICC2Node():
    def __init__(self, image, design_path, output, rpt_input=None):
        self.image = image
        self.rpt_input = rpt_input
        print(self.rpt_input)
        self.output = output
        self.design_path = os.path.abspath(design_path)
        self.root_dir = os.getcwd()

    def generate_timing_info(self):
        print("Running ICC2 to fetching timing info from", self.output)
        self.__generate_tun_tcl()
        self.__run()

    def __generate_tun_tcl(self):
        try:
            os.mkdir(self.output)
        except:
            pass
        os.chdir(self.output)
        print(os.getcwd())

        if self.output == 'test':
            with open(self.output+'.tcl','w+') as fp:
                TCL = '''
set sh_continue_on_error true
read_lib_package -overwrite %s
report_timing -nosplit > test_timing.rpt
exit
''' % self.design_path
                fp.write(TCL)

        if self.output == 'base':
            self.__process_rpt()

    def __process_rpt(self):
        f = open(self.rpt_input,).readlines()
        for line in f:
            start_match = re.search('Startpoint:\s+(\S+)\s+\(', line)
            if start_match:
                startpoint = start_match.group(1)
                print('Startpoint:', startpoint)
            end_match = re.search('Endpoint:\s+(\S+)\s+\(', line)
            if end_match:
                endpoint = end_match.group(1)
                print('Endpoint:', endpoint)

            match = re.search('(.*\/\w+) \((.*)\)\s+(\S+)\s+(\S+)', line)
            if match:               
                
                cell_pin, ref_name = match.group(1), match.group(2)       
                if not is_buf_inv(ref_name): 
                    print(cell_pin, ref_name)

    def __run(self):       
        # os.system(self.image+' -f '+self.output+'.tcl | tee log_'+self.output)
        os.chdir(self.root_dir)
        os.chmod(self.output, 0o777)

if __name__ == "__main__":
    import argparse
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('-base_design', help="ICC2 base package/nlib path")
        parser.add_argument('-test_design', help="ICC2 test package/nlib path")
        parser.add_argument('-base_image', help='ICC2 binary to run base design') 
        parser.add_argument('-test_image', help='ICC2 binary to run test design') 
        parser.add_argument('-rpt_file', help='test timing imfo')

        args = parser.parse_args()
        # test = ICC2Node(image=args.test_image, design_path=args.test_design, output='test')
        # test.generate_timing_info()
        if not args.rpt_file:
            rpt_file = os.path.abspath('test/test_timing.rpt')
        else:
            rpt_file = args.rpt_file
        base = ICC2Node(image=args.base_image, design_path=args.base_design, rpt_input=rpt_file, output='base')
        base.generate_timing_info()

        print("Done!")

    except OSError as e:
        import traceback
        traceback.print_exc()
        print("I/O error({0}): {1} {2}".format(e.errno, e.strerror, e.filename))
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(e)