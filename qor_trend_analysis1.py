#!/remote/us01home40/phyan/depot/python/bin/python 

import re
import os
import sys  
import MySQLdb
import datetime
from jinja2 import Environment, PackageLoader, FileSystemLoader

#=============================
# Back-end data collection
#=============================

rpt = sys.argv[2]
date = sys.argv[1]
file_lines = open(rpt).readlines()

#database connection
conn = MySQLdb.connect(host="pvicc015",user="user",db="preroute_random") 
cursor = conn.cursor(cursorclass=MySQLdb.cursors.DictCursor) 

#global var init
extract_value = False
target_metrics = {
  'ICP': ['ICPWNS', 'ICPTNSPM', 'ICPMaxTCostPM', 'ICPBufInvCnt', 'ICPOPTMEM', 'ICPMvArea'],
  'ICC': ['ICCWNS', 'ICCTNSPM', 'ICCMaxTCostPM', 'ICCBufInvCnt', 'ICCOPTMEM', 'ICCMvArea'],
  'ICF': ['ICFWNS', 'ICFTNSPM', 'ICFMaxTCostPM', 'ICFBufInvCnt', 'ICFOPTMEM', 'ICFMvArea'] 
}

qor_metrics = {}
target_metrics_dict = {'ICP':{},'ICC':{},'ICF':{}}

for (k1,v1) in target_metrics.items():
  for k2 in v1:
    target_metrics_dict[k1][k2] = 1
#print target_metrics_dict

PRS_KEYS = ['ICP', 'ICC', 'ICF']
PRS_KEYS_COMMENTS = {key:None for key in PRS_KEYS}

sql = "select * from qor_reg where date=%s"
param = (date,)
n = cursor.execute(sql,param)
if n == 1:
  print "Found record of date: %s, skip record..." % date

else:
  for line in file_lines:
    match = re.search(r'Histgrm_(\S+)_flow_(\d+).html',line)
    if match:
      qor_column =  match.group(1)
      match = re.search(r'(IC.)\S+', qor_column)
      qor_key = match.group(1)
      #print qor_key
      extract_value = True
      continue
  
    if extract_value:
      match = re.search(r'<td><a.*>(\S+)%|--</a></td>',line)
      #print match.group(1)
      extract_value = False
      if qor_column in target_metrics[qor_key]:
        #qor_metrics[qor_column] = match.group(1)
        #print match.group(1)
        if match.group(1) == None:
          target_metrics_dict[qor_key][qor_column] = 1
        else:
          target_metrics_dict[qor_key][qor_column] = float(match.group(1))/100 + 1 
  
  print target_metrics_dict

  sql = "insert into qor_reg(ICPWNS,ICPTNSPM,ICPBufInvCnt,ICPOPTMEM,ICPMaxTCostPM,ICPMvArea,ICCWNS,ICCTNSPM,ICCBufInvCnt,ICCOPTMEM,ICCMaxTCostPM,ICCMvArea,ICFWNS,ICFTNSPM,ICFBufInvCnt,ICFOPTMEM,ICFMaxTCostPM,ICFMvArea,date) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"     
  param = (
    target_metrics_dict['ICP']['ICPWNS'], target_metrics_dict['ICP']['ICPTNSPM'], target_metrics_dict['ICP']['ICPBufInvCnt'], 
    target_metrics_dict['ICP']['ICPOPTMEM'], target_metrics_dict['ICP']['ICPMaxTCostPM'], target_metrics_dict['ICP']['ICPMvArea'],
    target_metrics_dict['ICC']['ICCWNS'], target_metrics_dict['ICC']['ICCTNSPM'], target_metrics_dict['ICC']['ICCBufInvCnt'], 
    target_metrics_dict['ICC']['ICCOPTMEM'], target_metrics_dict['ICC']['ICCMaxTCostPM'], target_metrics_dict['ICC']['ICCMvArea'],
    target_metrics_dict['ICF']['ICFWNS'], target_metrics_dict['ICF']['ICFTNSPM'], target_metrics_dict['ICF']['ICFBufInvCnt'], 
    target_metrics_dict['ICF']['ICFOPTMEM'], target_metrics_dict['ICF']['ICFMaxTCostPM'], target_metrics_dict['ICF']['ICFMvArea'],
    date)      
  n = cursor.execute(sql,param)      
  print 'insert',n 

#=============================
# Font-end data display
#=============================
n = cursor.execute("select * from qor_reg")      
qor_by_date = sorted(list(cursor.fetchall()), key=lambda t:t['date'])

print qor_by_date

#initialize qor metrics
qor_metrics = {}
qor_metrics['date'] = []
for k in target_metrics_dict:
  for metrics in target_metrics[k]:
    qor_metrics[metrics] = []

for data in qor_by_date:
  for (k,v) in data.items():
    if k == "id":
      continue
    else:
      if len(qor_metrics[k]) and k != 'date':
        v = float('%.4f' % (qor_metrics[k][-1] * v))
      elif k == 'date':
        v = str(v)
      qor_metrics[k].append(v)

print qor_metrics

#font-end web page display
COLOR_LIST = ["#FF6384","#36A2EB","#FFCE56","#99CC33","#CC9933", "#666699", "#006633", "#cce2ff"]
env = Environment(loader = FileSystemLoader('/remote/us01home40/phyan/qor_regression/utility/templates'))
templates = env.get_template('qor_trend_1.html')
output = templates.render(
			qor_metrics = qor_metrics,
			metrics_dict = target_metrics,
      color_list = COLOR_LIST,
      prs_keys = PRS_KEYS,
      prs_keys_comments = PRS_KEYS_COMMENTS
)

msg = "Output qor URL: " + " http://clearcase"+os.getcwd()+"/qor_trend_analysis.html"
print msg
file_name = 'qor_trend_analysis.html'

f = open(file_name, 'w')
f.write(output.encode("utf-8"))
f.close()

cursor.close() 
conn.close()
