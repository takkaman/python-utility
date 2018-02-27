#!/remote/us01home40/phyan/depot/python/bin/python

import xlrd     
import MySQLdb
import datetime

conn = MySQLdb.connect(host="pvicc004",user="root",db="osqa")
cursor = conn.cursor(cursorclass=MySQLdb.cursors.DictCursor)
time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print time

#data = xlrd.open_workbook('/remote/us01home40/phyan/user_skill.xlsx')                                            
#table = data.sheets()[0]                                                                                                    
#nrows = table.nrows
sql = "select * from forum_skill"
n = cursor.execute(sql)

for row in cursor.fetchall():

	skill_id = row['id']
	skillname = row['skillname']

	print skillname

	sql = "select id from forum_skillownership where skill_id=%s"
	param = (skill_id,)
	n = cursor.execute(sql,param)

	popularity = int(n)
	print "popularity:", popularity

	sql = "update forum_skill set popularity=%s where skillname=%s"
	param = (popularity,skillname,)
	n = cursor.execute(sql,param)

	print "update", n



