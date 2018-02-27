#!/remote/us01home40/phyan/depot/python/bin/python

import xlrd     
import MySQLdb
import datetime

conn = MySQLdb.connect(host="pvicc004",user="root",db="osqa")
cursor = conn.cursor(cursorclass=MySQLdb.cursors.DictCursor)
time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print time

data = xlrd.open_workbook('/remote/us01home40/phyan/user_skill.xlsx')                                            
table = data.sheets()[0]                                                                                                    
nrows = table.nrows

missing_user_skill = {}

for i in range(nrows ):
	skill = table.row_values(i)[0]
	user_list = [x.strip() for x in table.row_values(i)[1].split(',')]
	sql = "select id from forum_skill where skillname=%s"
	param = (skill,)
	n = cursor.execute(sql,param)

	if n == 1:
		print "Found %s in database" % skill
		skill_id =  cursor.fetchall()[0]['id']
	else:
		print "Not found %s in database, created now..." % skill
		sql = "insert into forum_skill(skillname,last_update_at) values(%s,%s)"
		param = (skill,time,)
		n = cursor.execute(sql,param)
		print 'insert',n  

		sql = "select id from forum_skill where skillname=%s"
		param = (skill,)
		n = cursor.execute(sql,param)
		skill_id =  cursor.fetchall()[0]['id']

	print "skill id:", skill_id

	print user_list
	for user in user_list:
		sql = "select id from auth_user where username=%s"
		param = (user,)
		n = cursor.execute(sql,param)

		if n:
			print "Found user %s in database" % user
			user_id = cursor.fetchall()[0]['id']
			print "user id:", user_id

			sql = "select id from forum_skillownership where skill_id=%s and owner_id=%s"
			param = (skill_id, user_id,)
			n = cursor.execute(sql,param)

			if n:
				skillownership_id = cursor.fetchall()[0]['id']
				print "Found user skill relation in database, skip..."
			else:
				print "Not found user skill relation in database, insert..."
				sql = "insert into forum_skillownership(skill_id, owner_id, time) values(%s,%s,%s)"
				param = (skill_id, user_id, time,)
				n = cursor.execute(sql,param)
		else:
			print "No user %s found in database, need create manually" % user
			missing_user_skill[user] = skill

	print "\n"

print missing_user_skill



