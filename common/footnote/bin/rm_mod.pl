# rm_mod.pl
# �p�G <note type="mod"> �����e�P <note type="orig"> �ۦP,
# �N�⥦����
# v0.1, 2002/11/4 05:35PM by Ray
# v0.2, 2002/11/11 04:08PM by Ray
# v0.3, 2002/11/11 04:48PM by Ray

$in="d:/work/T05xml.txt";
$out="d:/work/T05xml-new.txt";
open I, $in or die;
open O, ">$out" or die;
select O;
while (<I>) {
	if (m#<note n="(.*?)" [^>]*?type="orig"[^>]*?>(.*?)</note>#) {
		$n=$1;
		$t=$2;
	}
	if (m#<note n="(.*?)" [^>]*?type="mod"[^>]*?>(.*?)</note>#) {
		if ($1 eq $n and $2 eq $t) {
			next;
		}
	}
	
	# �h�� <n> ��X�� <note n="..." place="foot">
	if (m#<note n="[^"]*" place="foot">#) {
		next;
	}
	
	# ���F�ϧO�H�U�T�ر��p, �N place="foot" �令 place="foot text"
	# 1.�հ���S�հɲŸ�
	# 2.�հ��榳�հɲŸ����S���e
	s/(type="orig" place="foot)"/$1 text"/;
	
	print;
}
close I;
close O;