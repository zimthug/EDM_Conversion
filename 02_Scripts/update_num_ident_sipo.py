import cx_Oracle
srccon = cx_Oracle.connect('edmgalatee/edmgalatee@tamla')
cursor = srccon.cursor()
cursor.execute("SELECT COUNT(*) FROM User_Tables")