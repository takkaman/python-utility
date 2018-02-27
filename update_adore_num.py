#!/remote/us01home40/phyan/depot/python/bin/python

import xlrd     
import MySQLdb
import datetime

conn = MySQLdb.connect(host="ltg-pv01",user="root",db="osqa")
cursor = conn.cursor(cursorclass=MySQLdb.cursors.DictCursor)
time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print time

#data = xlrd.open_workbook('/remote/us01home40/phyan/user_skill.xlsx')                                            
#table = data.sheets()[0]                                                                                                    
#nrows = table.nrows
sql = "select * from forum_skillownership"
n = cursor.execute(sql)

for row in cursor.fetchall():

	skillownership_id = row['id']
	
	sql = "select id from forum_skillownership_adores where skillownership_id=%s"
	param = (skillownership_id,)
	n = cursor.execute(sql,param)

	adore_num = int(n)
	print "adore_num:", adore_num

	sql = "update forum_skillownership set adore_num=%s where id=%s"
	param = (adore_num,skillownership_id,)
	n = cursor.execute(sql,param)

	print "update", n



