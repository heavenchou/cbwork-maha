# -*- coding: big5 *-*
"""
	�p�G mulu �� label �e��O���άA��, �N�h�����άA��
	�����U mulu.py t01
	������� mulu.py
	2005/11/29 13:56 by Ray
"""
import codecs, dircache, os, re, sys
import datetime

dir_in = '/cbwork/xml' # ��J��Ƨ�
dir_out = '/temp11' # ��X��Ƨ�

def rep(mo):
	g = mo.groups()
	s = g[0]
	if not s.endswith(u'�ʡ^"/>'): # �p�G�аO�̫�O �u�ʡ^"/>�v �N���h���A��
		s = re.sub(ur'label="�](.*?)�^"', r'label="\1"', s)
		# label �̫e���i�঳�Ʀr
		# T42n1828, 0587c06, label="4 �]���ķ���B�^"
		# T45n1900, 0896c07, label="1-3 �]�T��^"
		s = re.sub(ur'label="([\d\-]+ )�](.*?)�^"', r'label="\1\2"', s)
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