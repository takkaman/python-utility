#!/remote/pv/web/util/opt/depot/anaconda3/bin/python
import sys
import os
import subprocess

load_tcl = sys.argv[1]

link_library = load_tcl.split('/')[:-4]
#link_library = ('/').join(link_library)+'/GOLD/dump/design_setup.tcl'
link_library = ('/').join(link_library)+'/GOLD/dump/udc_setup_file_path'
link_library = subprocess.getoutput('cat '+link_library)
os.system("echo 'source "+link_library+"' >> setup.tcl ")
#os.system("cp "+link_library+" . ")
#os.system("echo 'source "+link_library+"' >> setup.tcl")
#os.system("echo 'source "+link_library+"' > link_library.tcl")
