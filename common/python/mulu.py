# -*- coding: big5 *-*
"""
	如果 mulu 的 label 前後是全形括號, 就去掉全形括號
	執行單冊 mulu.py t01
	執行全部 mulu.py
	2005/11/29 13:56 by Ray
"""
import codecs, dircache, os, re, sys
import datetime

dir_in = '/cbwork/xml' # 輸入資料夾
dir_out = '/temp11' # 輸出資料夾

def rep(mo):
	g = mo.groups()
	s = g[0]
	if not s.endswith(u'缺）"/>'): # 如果標記最後是 「缺）"/>」 就不去掉括號
		s = re.sub(ur'label="（(.*?)）"', r'label="\1"', s)
		# label 最前面可能有數字
		# T42n1828, 0587c06, label="4 （次第瑜伽處）"
		# T45n1900, 0896c07, label="1-3 （三衣）"
		s = re.sub(ur'label="([\d\-]+ )（(.*?)）"', r'label="\1\2"', s)
	return s

def do_file(source, dest):
	print source + ' => ' + dest
	fi = codecs.open(source, 'r', 'cp950')
	fo = codecs.open(dest, 'w', 'cp950')
	for line in fi:
		line = re.sub('(<mulu.*?>)', rep, line)
		fo.write(line)
	fi.close()
	fo.close()
	
def do_dir(source, dest):
	if not os.path.exists(dest): os.makedirs(dest)
	if os.path.isdir(source):
		os.chdir(source)
	l=dircache.listdir(source)
	for s in l:
		if s == 'dtd' or s=='CVS':
			continue
		if os.path.isdir(source+'/'+s):
			do_dir(source+'/'+s, dest+'/'+s)
		elif re.match(r'^[TX]\d\d.*?\.xml$', s, re.I) != None:
			do_file(source+'/'+s, dest+'/'+s)

if len(sys.argv)>1:
	vol = sys.argv[1].upper()
	print vol
	do_dir(dir_in+'/'+vol, dir_out+'/'+vol)
else:
	do_dir(dir_in, dir_out)