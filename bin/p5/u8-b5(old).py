# -*- coding: utf-8 *-*
"""
u8-b5.py
功能: 將目錄下(含子目錄)所有 utf-8 檔案轉為 CP950, 若缺字, 則查 cbeta gaiji-m.mdb, 以組字式呈現
需求: PythonWin
作者: ray
"""

dir_in="/release/temp"
dir_out='/release/temp1'

gaiji = 'C:/cbwork/work/bin/gaiji-m.mdb' # 缺字資料庫路徑

import dircache, os, codecs
import win32com.client # 要安裝 PythonWin

def trans_file(fn1, fn2):
	print fn1 + ' => ' + fn2
	f1=codecs.open(fn1, "r", "utf-8")
	f2=codecs.open(fn2, "w", "cp950", 'cbeta')
	for line in f1:
		print >> f2, line,
	f1.close()
	f2.close()

def trans_dir(source, dest):
	if not os.path.exists(dest): os.makedirs(dest)
	l=dircache.listdir(source)
	for s in l:
		if os.path.isdir(source+'/'+s):
			trans_dir(source+'/'+s, dest+'/'+s)
		else:
			trans_file(source+'/'+s, dest+'/'+s)

def my_err_handler(exc):
	global high_word
	rs = win32com.client.Dispatch(r'ADODB.Recordset')
	l = [] 
	for c in exc.object[exc.start:exc.end]:
		i = ord(c)
		if high_word != 0:
			i = (i & 0x3FF) + high_word
			high_word = 0
		elif i >= 0xD800:
			high_word = ((i & 0x3FF) + 0x40) << 10
			continue
		u = u"%x" % i
		sql = "SELECT des FROM gaiji WHERE uni='%s'" % u
		rs.Open('[' + sql + ']', conn, 1, 3)
		if rs.RecordCount > 0:
			l.append(rs.Fields.Item('des').Value)
		else:
			l.append('&#x%s;' % u)
	return (u"".join(l), exc.end)

# main
high_word = 0
codecs.register_error('cbeta', my_err_handler) # 先登記遇到缺字時的 error handler

# 準備存取 gaiji-m.mdb
conn = win32com.client.Dispatch(r'ADODB.Connection')
DSN = 'PROVIDER=Microsoft.Jet.OLEDB.4.0;DATA SOURCE=%s;' % gaiji
conn.Open(DSN)

trans_dir(dir_in, dir_out)