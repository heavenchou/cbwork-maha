# -*- coding: utf-8 *-*
# 將 cp950 encoding xml 轉為 utf8
# 2005/2/2 08:56上午 by Ray

dir_in="/cbwork/xml/x88"
dir_out='/release/utf8-xml/x88'

import dircache, os, codecs
def trans_file(fn1, fn2):
	print fn1 + ' => ' + fn2
	f1=codecs.open(fn1, "r", "cp950")
	f2=codecs.open(fn2, "w", "utf-8")
	for line in f1:
		line = line.replace('encoding="big5"','encoding="UTF-8"')
		line = line.replace('(Big5)','(UTF-8)')
		f2.write(line)
	f1.close()
	f2.close()

def trans_dir(source, dest):
	print source + ' => ' + dest
	if not os.path.exists(dest): os.makedirs(dest)
	l=dircache.listdir(source)
	for s in l:
		if s == 'dtd':
			continue
		if os.path.isdir(source+'/'+s):
			trans_dir(source+'/'+s, dest+'/'+s)
		elif s.endswith('xml') or s.endswith('ent'):
			trans_file(source+'/'+s, dest+'/'+s)

trans_dir(dir_in, dir_out)