#############################################
# �հ��ˬd�{��
# $Id: checknote.pl,v 1.1.1.1 2003/05/05 04:04:55 ray Exp $
#
# V0.1 (2001/08/11)	�Ĥ@��
# V0.2 (2001/08/12)	1.�B�z �� �аO
#					2.�N�����P�P�����P�_��@��, ���P���i���b��������, ��:
#					 ((?:\s*�i.*�j\s*)+)((?:��)?)  ==> �i���j�i�T�j�i���j�� (�P���u�b�᭱)
#					 �令
#					 ((?:\s*�i.*�j\s*(?:��)?)+)((?:��)?)  ==> �i���j���i�T�j�i���j�� (�P���i�b����)
#					 �o�˿��~�|����, �� $ver ���x�s�h���ǤF
#					3.�N��r���P�_��@��, ���K�����, �u�O�L�k�P�_�O�_�P�g��ۦX, ��:
#					 if (($oldword !~ /(�K)|(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)| /) and ($newword !~ /(�K)|(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)| /))
#					 �令
#					 if (($oldword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)| /) ....
#					4.���\�榡 2, 3 �[�W xx �r
# 					 �榡 2. �ʦr: 14 �e���f�Сi�T�j��
#					 �榡 3. �e�[�r: 12 �]���^�ϩ�h�i�T�j��
# 					 �榡 4. ��[�r: 28 ���ϡ]�̡^�i�T�j��
#					 �ܦ�
# 					 �榡 2. �ʦr: 14 �e���fxx�r�Сi�T�j��
#					 �榡 3. �e�[�r: 12 �]���^xx�r�ϩ�h�i�T�j��
#					 �榡 4. ��[�r: 28 ���ϡ]�̡^xx�r�i�T�j��
# V0.3 (2001/08/13)	1.�B�z ���@ �w�w ���P (���G���ίS�O�z��, �u�n���D�����s�b�Y�i)
#					2.�B�z�]�]�^�^�w �P�װt�X�ϥ�
#					3.�P������m, ���ɤ]�|�� "�U�P"
#					4.���\�@�Ǥ����n��m���Ů�(�]�A���b��)
#					5.���\�Y�� "����" ���X�{
#					6.�榡8. ���\�@�ǯS���y�l
# V0.4 (2001/08/15)	1.�榡 6 �ѤF�B�z�������������
#					  0379003 : �n�L���w��۫n�L������i���j�i���j�i�c�j
#					  18 �]�n�L�ӡK�T��^�Q�T�r�۫n�L���T��i�T�j�i�c�j
# V0.5 (2001/08/22)	1.�ק��X�榡, �H�t�X�~�Ѫ� .search
# V0.6 (2001/09/03)	1.���հ� xml ��
####  �}�l�ϥ� CVS
# V3.0 (2001/09/09) 1.��F�ܦh....
# V3.2 (2001/09/13)
# V3.3 (2001/09/17) 1.�B�z�ۭq���аO <n><x><a><d><?><~>
#					2.�B�z�h�h�������A��
#					3.�۰ʳB�z�ˤK�Ÿ�(��)���հ� (�ĤG�շ|�۰ʴ���m)
# V3.4 (2001/09/17) 1.��W�@���p bug
####  ����s��m, �ҥH���� 1.2 ��
# V1.2 (2001/09/20) 1.��ڤ�r�ܦ� &xxxx; �X�F
# V1.3 (2001/09/20)	1.�W�[����Ѽ�, �H��K�w�]�ܼ�, �Ҧp rd �i��J checknote.pl rd
# V1.4 (2001/09/20)	1.�ʦr�i�H���� CB �X�F.
# V1.5 (2001/09/24)	1.�p�A���n���� <note place=inline>
#                   2.�M�� xml ����ǽd��
# V1.6 �Q�O�H��F   Id: checknote.pl,v 1.6 2001/09/25 02:55:16 vinking Exp
# V1.7 (2001/09/27) 1.�ץ���X�� bug
#					2.�洫 <n> <x> �G�̪��N�q
# V1.8 (2001/10/02) 1.�ק��ڪ��榡
# V1.9 (2001/10/03) 1.�b�P�_�g�媺�հɽd�򤧫�, �̫�]�P�_�O�_�� </corr>
# V1.10(2001/10/12) 1.�[�J <r> ���B�z
#                   2.�[�J <o> ���B�z
#                   3.[A>B]<resp="CBETA.xxx cf1="xxx" cf2="xxx"> ���B�z
#                   4.��(�w�T�{)��(�ݬd) ���B�z
# V1.11(2001/10/12) 1.�ɻ~�ѤF²��аO���������B�z
# V1.13(2001/10/16) 1.�B�z "�ɻ~" �Ÿ����a�観���D, �w�ץ�
# V1.15(2001/10/21) 1."������" , ����xx�� , ����xx��, ��ĥ� <a> 
#					2.�B�z <c>
#					3.�B�z <k>
#					4.�B�z�q�ε�
#					5.�B�z "�֡B�סB�ءB�١B�ڡB�ۡB��"�A�o�C�Ӧr�OBIG5��W���s�r�A�n�ϥ�&M�X
# V1.18(2001/11/09) 1.�b "�����P�����" ���䴩 "�F" �o�ӲŸ�		# V1.20 ����󦹶�
#					2.�B�z�аO <m> , xml �O <note n="xxxxxx" place="foot">
#					3.�B�z�аO <e> , xml �O <note n="xxxxxx" place="foot" type="equivalent">
#					4.�B�z�аO <f> , xml �O <note n="xxxxxx" place="foot" type="cf.">
#					5.�B�z�аO <l> , xml �O <note n="xxxxxx" place="foot" type="<l>"> , ���ժ���m�n��� <lem> �᭱
#					6.��ڪ��аO ��<~><s><p>, �H�ΦP�ɦh�ձ��, �p ��pali<s>sk<p>pali<~>unknown
# V1.19(2001/11/09) 1.�B�z <z> �y����l�g�夣�X�����D
# V1.20(2001/11/15) 1.�B�z���٭� <,>, ���ϥ� '�F' �N�� '�A' �����k
#					2.���o������ڥi�H�q�L ��sp or pali�]�̫�i�H�Υ����A���A�@�q��r�^
#					3.�B�z <u> �аO, ���� <a> , ���O���� <tt> ���榡
# V1.21(2001/11/29) 1.�ȮɳB�z <g> , ��ڤW <g> �����e���O�W�� note ���� orig ..... ��Ӧn���S�� <g> �F
# V1.22(2002/01/18) 1.�B�z�ĤG�լO�[�r�����D.
# V1.23(2002/02/19) 1.��Υ~�����Ѽ��� checknote.cfg
#					2.�ק��X��, ������зǤ�
#					3.½�׳B�z [xx...xx]xx�r���B�z�k
# V1.25(2002/03/20) 1.�B�z <oo>
#                   2.�Ȯɤ����p�A��, �H�Q�K�г���� (�G�X)(��)...
# V1.26(2002/03/20) 1.���N�x��r�����Ӥ��.
#					2.�������Ÿ��~(c77e)�Aǧ(c7a7)
# V1.27(2002/03/22) 1.�A�[�@�Ӥ��Ÿ���(c6ea), ��(c6f1)
#					2.²��аO�g��ѤG���ܦ��T��ӧP�_, �]���K�г����ɷ|�����@��x��r, �G�n�h�@��
# V1.28(2002/04/11) 1.�N <term> �令 <t>
# V1.29(2002/04/12) 1.T44p0137 [11] �U�׮��H  �ȮɳB�z�� <rdg wit="�H">...</rdg>
#					  �z�פW���B�z�� <sic n="xxxxxxx" resp="Taisho" cert="?" corr="��">�U</sic>
# V1.30(2002/04/16) 1.�ץ� [[01]>] �� [[01]>>] �o�G�ؤ����Ӧb�ˬd²��аO���ɥX�{���D. (�H�e�N���ӥ��T��, �i���S�g�n)
# V1.31(2002/04/30) 1.�׶}�g�夤 [�g], [��] �y�������D.
#					2.�]�� T49 �g�妳���ֲ���, �ҥH���ˬd�o�譱�����D.
# V1.32(2002/05/02) 1.�ק�@�ǿ��~
# V1.33(2002/05/03) 1.�Y�հɸ��U�@��, �h���յ���, ���n�z�Z��U�@��
#					2.�S��Ÿ��令ĵ�i, ���n��������, �]�����ǬO�G�Ӥ��媺�����X�y����.
# V1.34(2002/05/03) 1.�Y�հɦ����S����, �����Ȯɩ���, �[�W <n> , �H��A��
# V1.35(2002/05/03) 1.�ɨ��G�� : �Y�հɸ��U�@��, �h���յ���, ���n�z�Z��U�@��
# V1.36(2002/05/07) 1.�O�_�i�H���U�@�Ӯհ�, ��ΰѼƨM�w multi_anchor
# V1.37(2002/05/07) 1.�׶}�g�夤 �i�g�j, �i�סj�y�������D. V1.88 ���s�B�z
# V1.38(2002/05/08) 1.���� multi_anchor , �令�u���b���̫᪺ tag �ɹJ�쪺 anchor �~����, 
#                     �]���o�ɪ�ܤ�r���S�F, �A���u�|�}�a�аO
# V1.39(2002/05/08) 1.�B�z�հɱ��دS�� ... �Ÿ�
# V1.40(2002/05/13) 1.�B�z��ڤ大�᪺ "?", "(?)", �]����r�^, �ϥΫ�B�z�{��
#                   2.��Ӫ� orig ���W�ߥX���ܦ� note
#                   3.�B�z�����O�H�����D�A�ϥ� <sic> , �W�ߥX��
#                   4.�B�z�S�����媺��ڤ�, �ϥ� <foreign> �W�ߥX��
#                   5.�B�z�S��ƥu�� <note..></note> �����D, �n�令 &lac;
#                   6.�B�z�����P�ĵ�
# V1.41(2002/05/13) 1.cert="�H" �令 cert="?"
# V1.42(2002/05/14) 1.�ĤG�դ���հɤ��e���K����, ���Xĵ�i
#                   2.�Y���G�եH�W���հɡA�������O�H�A���Xĵ�i
#                   3.�������P��,�U�P,�V��....����, �b wit="" ������, �u�d�b desc ��.
# V1.43(2002/05/15) 1.�B�z "<sic> �� ... �٨S�B�z"
# V1.44(2002/05/20) 1.�ק�h�Ӫ����]�|�X�{ desc �����D.
# V1.45(2002/05/21) 1.�B�z�i���n�áj���D <rdg wit="�i���n�áj<resp="�i���j">"> �ܦ� 
#                     <rdg wit="�i���n�áj" resp="�i���j">
# V1.46(2002/05/22) 1.�쥻���˦� <n> , �{�b�٬O�令�������A��, �A�ݬݦ��S��������D.
# V1.47(2002/05/28) 1.�b xml �հɤ�����ۦ�[�J \n, �|�y���䥦�a��P�_���~, �{�w�令�e�{�ɤ~�[�F.
# V1.48(2002/05/28) 1.����٬O�o���˦� <n> �~��.
# V1.49(2002/06/04) 1.�Y�O��ڤ�, �@�ߦb�ݩʥ[�W resp="Taisho"
#                   2.�Y�����O (?xx) �� (xx?) �h�A�[�W cert="?"
# V1.50(2002/06/06) 1.�B�z��ڵ����O ? (?) (?xxx) ���t��
# V1.51(2002/06/07) 1.�ѨM�����Ӷ]�X�Ӫ� <tt> ���D.
# V1.52(2002/06/10) 1.�B�z�@�ǼаO�W�[�ݩʩҲ��ͪ����D.
# V1.53(2002/06/11) 1.�ȮɱN��ڶ}�Y���հɼЦ� <n>
#                   2.�B�z�i���j�P�i�ϡj,�קK�P�����V�c, �N�O���N������ &xxx;
# V1.56(2002/06/24) 1.�B�z�x��r�� bug
# V1.57(2002/06/25) 1.�B�z "����" �����D
# V1.58(2002/07/02) 1.�B�z <y> , �M <c><o><oo> ����
#                   2.�B�z�ɻ~�L�k�B�z &xx-xxxx; �����D
#					3.�B�z���媺���D
# V1.59(2002/07/10) 1.²��аO�����ˬd�令����
# V1.60(2002/07/13) 1.�B�z xml ��, �n�׶} log �ɪ����
# V1.61(2002/07/16) 1.�ק� <u> <a> �����G
# V1.62(2002/07/19) 1.�s�W <cm> , �M <m> �ۦP, ���o�O CBETA ��g��
# V1.63(2002/07/22) 1.�W�[�ĤG�h�� Note , <note resp="CBETA" type="mod">
#                   2.�B�z�饻����[��-�G] C77E "�~"
# V1.64(2002/07/26) 1.�ק�@��p�F�F
# V1.65(2002/07/29) 1.�B�z�Ϫ�����, �Ϧ��G��, �@�جO�i�ϡj, �@�جO <figure .....>
#                   2.���� desc �ݩ�, ��� <note n="xxxxxx" resp="CBETA" type="mod">
#                     �� desc ���@�w�O�b <d> �аO, �P���βV�P�������F��H�e�]�|���� desc ���� , V1.42
#                   3.<rdg> ���[ resp="Taisho"
# V1.66(2002/07/29) 1.�հɪ���ڤ嵲���p�G���ݸ��u?�v�A��X xml �ɤ���u?�v�d�b<t>�̭�
# V1.67(2002/07/29) 1.�饻����[�O]  "ǧ"(C7A7), "��"(C6F1) 
# V1.68(2002/07/31) 1.�ɻ~���B�z
# V1.69(2002/08/01) 1.�B�z <note ....>&lac;</note> ==> &lac;
# V1.70(2002/08/01) 1.�g���ƪ��ɻ~�n���B�z.
# V1.71(2002/08/02) 1.�ҽk�����i���j�Ρiunknown�j���
#                   2.�ʡ��G��&lac;��� 
#                   3.�ҽk�r���G��&unrec;���
#                   4.�P�@�ժ� n="xxxx" �̥����� abcd �ӰϧO�F, �H�e�����n�M��
#                   5.�B�z�ݩʸ̭����ʦr (&xxxx; �ܦ� xxxx)
#                   6.�B�z <l> �аO, �����ͪ� note �n��b <lem> ���᭱, �ܦ� <lem><note..type="l"..
#                   7.�B�z �i��X�áj, <rdg wit="�iX�j�i��X�áj<resp="�i���j">"...> �ܦ� <rdg wit="�iX�j>...<rdg wit="�i��X�áj" resp="�i���j"...>
# V1.72(2002/08/05) 1.�վ�W�� 7. �i��X�áj�����D, �ӥB�b modify stack �����n�d�� <resp="�i���j">
#                   2.�i���j�n�� �� ���B�z
#                   3.<?> �令�b modify stack �[�W <todo type="i">
#                   4.�Y�S�� <o><y><c> �аO��, �N�۰ʱN��հɩ�J orig stack
#                   5.�N²��аO���q�M��.
#                   6.���H�@���r�B�z
#                   7.�B�z <mg><sic corr="���̤l" resp="�i���j" orig="����[��*��]����̷�@���̤l">����</sic>
# V1.74(2002/08/05) 1.�]����ڥ��i����g, �ҥH�b�P�_�����n�[�J & �Ÿ�
# V1.75(2002/08/09) 1.��G�ռаO, �B�� <z> ��, �[�W xxxx �ݩʪ�ĵ�i
#                   2.<z> ���аO�b modify stack �����e�n�ܦ� <corr sic="lac">...</corr>
#                   3.<c> �аO�� modify stack �n�[�W <todo type="c"/>
#                   4.modify stack  �� <s><~> �ন�b���ť�, <��> �ন ��
# V1.76(2002/08/09) 1.�W�@���u�B�z <z> �t�X <s><p><~> , �ѤF�B�z <z> �t�X ��
# V1.77(2002/08/09) 1.�ʡ��G���&lac-space;��ܡA�H�e��&lac;��ܡA�����A�X�C
# V1.78(2002/08/14) 1.�Ʀr�P�_�i�H�W�L 1000 , �åB�B�z�F�զX�r.
#                   2.�B�z�饻����, ��j�p�g��[��-�G] ���G��, �b���P���g���n���O�B�z
# V1.79(2002/08/15) 1.�W�[�饻����[�O]   "��"(C7F1), ��ӥu�� "ǧ"(C7A7), "��"(C6F1)
#                   2.�ק�p bug
# V1.80(2002/08/16) 1.<y> ���榡�令 <y>....�A<oo>or<o>.......
# V1.81(2002/08/20) 1.�j�g��岤�ŭn�����~���i, �ӥB�p�g��岤�ŭn�令 entity �榡
# V1.82(2002/08/21) 1.�ݩʤ��� &xxxx; �令 ��xxxx�F, �ӭ�ӭY�����h�令��big-amp�F
#                   2.A��B�i�T�j�A<c>B��A�i�T�j�Ʊ�ĤG�h�� <note type="mod"><todo type="c"/>���e�O  B��A�i�T�j�G
# V1.83(2002/08/22) 1.�ĤG�h note ���ɻ~�]�n�[�W <resp....>
#                   2.�� �� �]�ܦ��榡 5. �����g�r���@����
#                   3.�b�p��r�Ʈ�, �] (a15d) �� �^(a15e) ����r
# V1.84(2002/08/22) 1. <c> �аO���հɧ令 <n> ���B�z�覡.
#                   2. <s><~> �b�����ťծ�, �Y�O�b�Ĥ@�Ӧr, �h���n��.
# V1.85(2002/08/22) 1. �ק�W�@�� bug �A<s><~> �b�����ťծ�, �Y�O�b�Ĥ@�Ӧr, �h���n��.
#                   2. ���� <sup> �аO
#                   3. �N <,> ���� �A
# V1.86(2002/08/23) 1. �ק�W�@�� bug �A<s><~> �b�����ťծ�, �Y�O�b </corr> �᭱, �@�˯d�Ů�
# V1.87(2002/08/27) 1. ²��аO�����h��� <no_nor> ���v�T
#                   2. ��ڦr�[�J = ���Ÿ�
# V1.88(2002/08/27) 1. V1.37 �׶}�g�夤 �i�g�j, �i�סj�y�������D. V1.88 ���s�B�z
# V1.89(2002/09/03) 1. �����i�g�j, �i�סj�B�z������
# V1.90(2002/09/04) 1. �B�z�i�g�j�i�סj���l�r
# V1.91(2002/09/26) 1. �p�G�� �K ���Ÿ�, �h�[�W���հɦb�g�媺�ƥ�, ���H�i�H�P�_.
#                   2. �����ĥέ�l�հ��ɷ��Ĥ@�� note
# V1.92(2002/09/26) 1. ��l�հɪ���ڧ� entitiy ��չ���S�g�n, �w��L.
# V1.93(2002/09/28) 1. �[�J ray �g�� y2mod.pl �{��, �H�B�z <y> �аO.
#                   2. �[�J ray �g�� jap2ent.pl �{��, �H�B�z���.
#                   3. ���F�Ĥ@�h�� note ���~�A�i�T�j�����i���j�i���j�i���j
# V1.94(2002/10/04) 1. �ĤG�h note �� </todo> �n����
#                   2. �B�z��l�հɩM��o�ծհɪ��t�����D, �]�A�x��r�έק�Ÿ�
# V1.95(2002/10/07) 1. �ק�@�Ǥp���D�j
# V1.96(2002/10/11) 1. �B�z <z> �����D, ����l���P��o�ժ��ݤ���t��
# V1.97(2002/10/11) 1. �B�z�x��r���t�����D
# V1.98(2002/10/11) 1. �B�z���r���t�����D
# V1.99(2002/10/11) 1. �����B�z���r���t�����D, �B�z���������D
############################################

use strict;

#---------------------------------------------------
# �M�ǤJ�ѼƦ������ܼ�
#---------------------------------------------------

# �ثe�� rd, heaven �Y���S��ݨD��, �Чi�D��
my $Iam = "heaven";	
$Iam = $ARGV[0] if($ARGV[0]);	# �Y���ǤJ�Ѽ�, �h�Φ��Ѽ�

#---------------------------------------------------
# �i�ק諸�ܼ�, �Y�� checknote.cfg , �h�H cfg �ɬ��D
#---------------------------------------------------

my $vol = "T01";

my $infile = "${vol}�հɱ���.txt";				# �հɱ�����
my $originfile = "${vol}��l�հɱ���.txt";		# ��l�հɱ�����
my $sutra = "c:/cbwork/simple/${vol}/new.txt";	# ��l�g���ɡ]²��аO���^
my $xml_dir = "c:/cbwork/xml/$vol/";			# xml �g�媺�ؿ�

#if($Iam eq "rd")
#{
#	$infile = "${vol}�հɱ���.txt";					# �հɱ�����
#	$sutra = "c:/cbwork/work/maha/${vol}maha.txt";	# ��l�g���ɡ]²��аO���^
#	$xml_dir = "c:/cbwork/xml/$vol/";				# xml �g�媺�ؿ�
#}

my $outfile = "${vol}out.txt";			# �򥻿�X���G��
my $xmlout = "${vol}xml.txt";			# ���� xml �аO����X��
my $xmllogout = "${vol}xmllog.txt";		# ���� xml ���հ��ˬd�����G

my $jap_ent_file = "c:/cbwork/xml/dtd/jap.ent";

# ���U�O�P�_�O�_�n�B�z? 0 ��ܤ��B�z, 1 ��ܭn�B�z

my $show_no_word_error = 0;				# �Y��ڤ�r�S�t�X�����, �n���n�q�X���~?
my $run_check_with_sutra = 1;			# �O�_�t�X²��аO���g���e�ˬd?

my $useODBC = 1;						# �ϥ�ODBC, �~��N�ʦr���� &CB �X, �]�~��t�X xml �ˬd.
my $run_check_with_xml = 1;				# �O�_�t�X xml ���g���e�ˬd? (�ثe�u�ˬd�i���J���F��)

# my $multi_anchor = 1;					# ���ռаO�O�_�i�H���U�@�ժ� anchor �аO (0 �� 1)

#---------------------------------------------------
# �L�ݭק諸�Ѽ�
#---------------------------------------------------

#---------------------------------------------------
# �`��(patten)
#---------------------------------------------------

my $roma = '(?:(?:(?:��)|(?:<~>)|(?:<[pP]>)|(?:<[sS]>))(?:(?:[0-9a-zA-Z=&\.\-~`\(\)\^\[\]\'\"\;\|\:,\? <>])|(?:�X)|(?:��)|(?:�K))+(?:\xa1\x5d.*?\s?\xa1\x5e)?)';	# ù����g�r
my $cnum = '(?:(?:�@)|(?:�G)|(?:�T)|(?:\xa5\x7c)|(?:��)|(?:��)|(?:�C)|(?:�K)|(?:�E)|(?:�Q)|(?:��)|(?:��)|(?:��)|(?:�d))';	# ����Ʀr
my $notestar = '(?:(?:\s*��\s*)|(?:\s*�U\s*)|(?:\s*��\s*)|(?:\s*�H�U\s*)|(?:\s*���U\s*)|(?:\s*����\s*)|(?:\s*�P\s*)|(?:\s*�ҦP\s*)|(?:\s*�V��\s*)|(?:\s*�ٲ�\s*)|(?:\s*�A\s*)|(?:\s*<,>\s*))';		# �U�P�Ϊ��P�� ~V0.3 , V1.42
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
#�ʦr�̭��S��>[]  0-9 a-z A-Z
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x21-\x2f]|[\x3a-\x3d]|[\x3f-\x40]|\x5c|[\x5e-\x60]|[\x7b-\x7f])';
my $fullspace = '(?:�@)';
my $allspace = '(?:(?:�@)|\s)';
my $sppattern = '(?:(?:��)|(?:<[pP]>)|(?:<[sS]>)|(?:<~>))';
my $smallnote = '(?:(?:����)|(?:���`)|(?:�Ӯ�)|(?:�ӵ�)|(?:�Ӫ`)|(?:�ĵ�)|(?:�Ī`)|(?:�ǵ�)|(?:�Ǫ`)|(?:����)|(?:���`)|(?:�p��)|(?:�p�`)|(?:�Ӧr))';  # �������˦�
my $allsmallnote = '(?:(?:����)|(?:���`)|(?:�Ӯ�)|(?:�ӵ�)|(?:�Ӫ`)|(?:�ĵ�)|(?:�Ī`)|(?:�ǵ�)|(?:�Ǫ`)|(?:����)|(?:���`)|(?:�p��)|(?:�p�`)|(?:�Ӧr)|(?:����))';  # �������˦�
my $interlinear_note = '(?:(?:�ĵ�)|(?:�Ī`)|(?:����)|(?:���`)|(?:�ǵ�)|(?:�Ǫ`))';  		# �������˦�
my $max_line_xml = 5;		# �B�z xml �հɮ�, �̦h���X��Ӥ��? �Ӧh�F�h���Ӧn��, �Ӧh�̦n�Τ��.
my $manyver = '(?:(?:(?:�i.*?�j)|(?:�H))(?:(?:�i.*?�j)|(?:�H)|(?:<resp=".*?">))*)'; 	# �U�ت����|�����Ÿ�
my $DEBUG = 1;

#my $jp0 = '(?:(?:�})|(?:�~))';			# �饻����[��-�G]  "�}"(C77D), "�~"(C77E)
#my $jp1 = '(?:(?:��)|(?:��))';			# �饻����[��-�G]  "��"(C6E9), "��"(C6EA) 
#my $jp2 = '(?:(?:ǧ)|(?:��)|(?:��))';		# �饻����[�O]  "ǧ"(C7A7), "��"(C6F1), "��"(C7F1)

my $jp0 = '(?:�})';			# �饻����[��-�G]  "�}"(C77D), �᭱�o�Ӥ��ΤF "�~"(C77E)
my $jp1 = '(?:��)';			# �饻����[��-�G]  "��"(C6E9), �᭱�o�Ӥ��ΤF "��"(C6EA) 
my $jp2 = '(?:(?:��)|(?:��))';		# �饻����[�O]  "��"(C6F1), "��"(C7F1) �᭱�o�Ӥ��ΤF "ǧ"(C7A7)

my $big_jp = '(?:(?:�~)|(?:��)|(?:ǧ))';		# ���ӥX�{�����j�g���� "�~"(C77E), "��"(C6EA), "ǧ"(C7A7)

#---------------------------------------------------
# �ɮ� handle
#---------------------------------------------------

local *IN;
local *SUTRA;
local *XMLIN;
local *XMLOUT;		# ���� XML �հɪ���X
local *XMLLOGOUT;	# ���զb XML �ɴM��հɻP�Ÿ����ƥ�
local *OUT;
local *CFG;

#---------------------------------------------------
# �հɸ��
#---------------------------------------------------

my @note;		# �հɱ���
my %note;		# �B�z�L���հɱ��� ���ޥΪ� ID �O "�|�쭶�X" �[ "�T��s�X"
my %has_note;	# �Y���հɦ��X�{�b�g��, �h�]�w�� 1, �ΥH�ˬd�Y�ӮհɬO�_�X�{�b�g�夤.

my @orig_note;		# �̭�l���հɱ���
my %orig_note;		# ��l�հɱ��� ���ޥΪ� ID �O "�|�쭶�X" �[ "�T��s�X"
my %orig_note_line;	# ��l�հɥX�{�b��l�ɮת����

my %note_form;		# ���R�հɮ榡
my %note_old;		# ��g�媺���e
my %note_new;		# �հɪ��g�夺�e
my %note_ver;		# �հɪ�����
my %note_star;		# �O�_���հɬP��
my %note_word_num;	# �r��, �Ҧp [�p�O...�ڻD]�Q�K�r (���ܼƴN�O 18)
my %note_spell;		# �հɪ���ڸ��

my %note_line;		# �հɥX�{�b��l�ɮת����
my %note_xml;		# XML �榡���հ�
my %note_total;		# �հɪ��ռ� (�Υ����r���j�}���ƥ�)
my %note_stack_total;	# note stack ���հɪ��ռ� (�Υ����r���j�}���ƥ�)
my %note_add_desc;	# �O�_�N��հɥ[�J desc �ݩʤ�
my %note_add_xxxx;	# �O�_�N��հɥ[�J xxxx �ݩ�, �ثe�o�O���F <?> �ӳ]�p��
my %note_add_resp;	# �N <k> �аO���᪺�аO���e, �ثe�o�O���F <k> �ӳ]�p��
my %xml_err_msg;	# �ন xml �Ҳ��ͪ����~�T��
my @sutra_err;		# �g�媺���~�ڥ���b�o��
my @both_sutra_note_err;	# �g��P�հɨS���P�B
my %eight_note;		# �ΨӳB�z�۲Ÿ����հ� (�ǤJ�հ�, �Ĥ@���ǤJ�N���� 1 , �ĤG������ = 0)
my %interlinear;	# �ΨӰO���հɬO�p���ΰ���.	V1.40
my %note_ztag;		# �p�G�� <z> �аO, �h�n�O���b�o��. V1.49

my %orig_stack;		# �N <o> �аO���᪺�F�������b�o��, �ثe�o�O���F <o><oo><c> �ӳ]�p��
my %modify_stack;	# �o�O���F <o> ���~, �䥦���F��.
my %note_stack;		# �հɤ@��ݭn�ϥ� <note> ��b�᭱���F��, ����b�o��, �o�O���F <m><e><r>
my %note_stack_total;	# note stack ���հɪ��ռ� (�Υ����r���j�}���ƥ�)
my %sic_stack;		# �W�ߪ� <sic> �аO���e, �o�O���F A=B�H �o�بS���������հ�
my %foreign_stack;	# �W�ߪ� <foreign> �аO���e, �o�O���F���ǨS�����媺��ڤ�r
my %foreign_stack_total;	# foreign stack ���հɪ��ռ� (�Υ����r���j�}���ƥ�)

my %has_japan0;		# �P�_���S���饻����[��-�G]  "�}"(C77D), �᭱�o�Ӥ��ΤF "�~"(C77E)
my %has_japan1;		# �P�_���S���饻����[��-�G]  "��"(C6E9), �᭱�o�Ӥ��ΤF "��"(C6EA) 
my %has_japan2;		# �P�_���S���饻����[�O]  "��"(C6F1), "��"(C7F1), �᭱�o�Ӥ��ΤF "ǧ"(C7A7)

my %jap;			# �B�z���r�Ϊ�;

#-------------------------------------------
# �B�z xml �ɥΪ��ܼ�
#-------------------------------------------

my $note_count = 0;				# �հɼƥ�
my $note_found_count = 0;		# �հɯ�B�z���ƥ�
my $note_no_found_count = 0;	# �հɤ���B�z���ƥ�
my $note_star_count = 0;		# �P���ƥ�
my $note_star_found_count = 0;	# �P����B�z���ƥ�

##################### �B�z��ƪ��ܼ�
my @xmls;			# xml �����g��
my $pre_anchor; 	# <anchor �аO���e���r
my $anchor_ok;		# <anchor �аO����w�T�w���r
my $anchor_other;	# �٨S�B�z�����
	
my $note_old_head;	# �հɱ��ؤ�, ��l�g�媺�e�b�q
my $note_old_tail;	# �հɱ��ؤ�, ��l�g�媺��b�q

my $xml_start_line;	# �}�l�M�䪺���
my $xml_now_line;	# �ثe�Ҧb�����

my $xml_word_num;	# xml �Ҩ��X���Ʀr, �t�X [xx...xx]xx�r ���p��Ʀr�Ϊ�
my $xml_last_word_num;	# �̫�@���X�檺�r��, xml �Ҩ��X���Ʀr, �t�X [xx...xx]xx�r ���p��Ʀr�Ϊ�
my $note_word_num;	# �ثe�o�@�ժ��r��

my @xml_tag_stack;	# �x�s tag �Ϊ�, �n�B�z�O�_���������аO�n���X
my $xml_pure_data;	# �x�s�¤�r���

my $xml_err_message;	# ��@�Ǯe�\�����~�T��

#-------------------------------------------
# ���ù����g�r
#-------------------------------------------

my %s2ref = (
	"aa", "&amacron;", 
	"AA", "&Amacron;", 
	"^a", "&acirc;", 
	".d", "&ddotblw;", 
	".D", "&Ddotblw;", 
	".h", "&hdotblw;", 
	"ii", "&imacron;", 
	".l", "&ldotblw;", 
	".L", "&Ldotblw;", 
	"^m", "&mdotabv;", 
	".m", "&mdotblw;", 
	"^n", "&ndotabv;", 
	".n", "&ndotblw;", 
	".N", "&Ndotblw;", 
	"~n", "&ntilde;", 
	".r", "&rdotblw;", 
	"'s", "&sacute;", 
	".s", "&sdotblw;", 
	".S", "&Sdotblw;", 
	".t", "&tdotblw;", 
	".T", "&Tdotblw;", 
	"uu", "&umacron;", 
	"^u", "&ucirc;", 
	"~S", "&Sacute;",
	"`S", "&Sacute;",);
	
#-------------------------------------------
# �ʦr��Ʈw�Ϊ�
#-------------------------------------------

#my %gaiji_nr;	# ��J ent , �ǥX�q�Φr
my %gaiji_cb;	# �ǤJ�զr��, �ǥX CB �X
my %gaiji_zu;	# �ǤJentity(���O CIxxxx �q�ε��X), �ǥX�զr��
#my %gaiji_ent;	# �ǤJ CB �X, �ǥX ent

#-------------------------------------------
# �䥦
#-------------------------------------------

my @sutra;	# ���U�g��
my $line;	# �Y����

##############################################################################
#  �D �{ ��
##############################################################################
print "read config....\n";
read_config();
print "read japan entity....\n";
read_jap_ent();

#��Ū��l�����

open OUT, ">$outfile" || die "open $outfile error";
open IN, $originfile;

my @orig_note = <IN>;	# �հɸ��
close IN;
if($#orig_note >= 0)
{
	print "analysis orig note file\n";
	orignote_analysis();	# ²����R�հɱ���, �æs�J %orignote
	print OUT "\n$originfile : found => \[\n\n";
}
else
{
	print "\nError : open $originfile error!\n";
	close IN;	
}

# �AŪ��L���հɱ���

open IN, $infile || die "open $infile error";
@note = <IN>;	# �հɸ��
close IN;

print "analysis note file\n";
note_analysis();	# ²����R�հɱ���, �æs�J %note

print "analysis note form\n";
analysis_note_form();	# ���R�հɱ��ت��榡

if($run_check_with_sutra)
{
	print "check with sutra\n";
	check_with_sutra();	# �t�X�g�尵²����R
	print "check lose note\n";
	check_lose_note();	# �ˬd���S���հɰt����g�媺
}
print OUT "$infile : found => \[\n\n";

print "make the sk-pali standard form\n";
#sk_pali_normalize();	# �N��ڤ�зǤ� , #V1.72 �令�@�}�l�N���F

# �q�o�̥H��, �|�Ψ� access (ODBC mode) �ʦr��Ʈw

if($useODBC)	# Ū�J�ʦr
{
	readGaiji();
	print "make the loseword to \$CBxxxxx;\n";
	note_gaiji_normalize();		# �N�հɪ��ʦr����&CB�X�зǮ榡
}

note_inline_normalize();		# �N�p�A���ܦ� <note inline

print "make xml format footnote\n";
make_xml_formate();			# ���� xml �榡

if($run_check_with_xml)
{
	print "check with xml sutra\n";
	check_with_xmls();		# �յۻP xml �g����ݬ�
}

other_output();		# ���G��X (���@�������G�O�b�W�����Ƶ{������X��)

close OUT;
print "ok [any key to exit]\n";
<>;
exit;

##############################################################################
# Ū�J config ��
#####################

sub read_config
{
	my %cfg;
	
	open CFG, "checknote.cfg";
	
	while(<CFG>){
		next if (/^#/); 	#comments
		chomp;
		my ($key, $val) = split(/\s*=\s*/, $_);
		$key = lc($key);
		$cfg{$key}=$val;	#store cfg values
	}
	close CFG;

	if (defined($cfg{"vol"})) {
		$vol = $cfg{"vol"};
	}

	if (defined($cfg{"infile"})) {
		$infile = $cfg{"infile"};
		$infile =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"originfile"})) {
		$originfile = $cfg{"originfile"};
		$originfile =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"sutra"})) {
		$sutra = $cfg{"sutra"};
		$sutra =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"xml_dir"})) {
		$xml_dir = $cfg{"xml_dir"};
		$xml_dir =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"outfile"})) {
		$outfile = $cfg{"outfile"};
		$outfile =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"xmlout"})) {
		$xmlout = $cfg{"xmlout"};
		$xmlout =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"xmllogout"})) {
		$xmllogout = $cfg{"xmllogout"};
		$xmllogout =~ s/\$\{vol\}/$vol/g;
	}

	if (defined($cfg{"show_no_word_error"})) {
		$show_no_word_error = $cfg{"show_no_word_error"};
	}

	if (defined($cfg{"run_check_with_sutra"})) {
		$run_check_with_sutra = $cfg{"run_check_with_sutra"};
	}

	if (defined($cfg{"useodbc"})) {
		$useODBC = $cfg{"useodbc"};
	}

	if (defined($cfg{"run_check_with_xml"})) {
		$run_check_with_xml = $cfg{"run_check_with_xml"};
	}
	
#	if (defined($cfg{"multi_anchor"})) {
#		$multi_anchor = $cfg{"multi_anchor"};
#	}
}

##############################################
# ���R��l�հɱ���, �æs�J %orig_note
# �ˬd����
# 1. ���Ƥp��e�@�� (���i�᭱�����X�p��ε���e����)
# 2. �ˬd�榡�O�_���T
# 3. �ˬd�s���O�_�s��
##############################################

sub orignote_analysis()
{
	my $ID;				# %note ��ID
	my $note_page;		# �հɪ���
	my $note_num;		# �հɪ��s��
	my $note_data;		# �հɪ����e

	my $note_pre_page = 0;	# �W�@�Ӯհɪ�����
	my $note_pre_num = 0;	# �W�@�Ӯհɪ��s��

	for(my $i = 0;$i <= $#orig_note; $i++)
	{
		my $linenum = sprintf("%05d",$i+1);
		next if $orig_note[$i] eq "" ;
		next if $orig_note[$i] =~ /^#/;
		last if $orig_note[$i] =~ /^<eof>/i;		#���եΪ�, �Y�հɥX�{ <eof> �h���~��U�h

		if($orig_note[$i] =~ /^p(\d{4})/)
		{
			$note_page = $1;
			if ($note_page <= $note_pre_page)	# ���Ƥ���
			{
				print OUT "${linenum}:err2: �������j��e�@��==> p$note_page <= p$note_pre_page";
			}

			$note_pre_num = 0;		# �o�G�ӭn���]
			$note_pre_page = $note_page;

			next;
		}

		if($orig_note[$i] =~ /^\s*(?:��)?(\d+)\s*(.+)$/)	# �зǮ榡���հ�
		{
			$note_num = $1;
			$note_data = $2;
			if($note_num != $note_pre_num+1)
			{
				print OUT "${linenum}:err3: �հɼƦr���s��==> p$note_page, $note[$i]";
			}
			$note_pre_num = $note_num;

			# �P�_�@�U�U�@��O�_�O���򥻦檺

			for(my $j = $i+1; $j<= $#orig_note; $j++)
			{
				if($orig_note[$j] =~ /^    \s*(.*)$/)
				{
					$note[$j] = $1;
					chomp($note_data);
					if($note[$j] =~ /^[a-z]/i)
					{
						$note_data .= " $orig_note[$j]";
					}
					else
					{
						$note_data .= $orig_note[$j];
					}
					$orig_note[$j] = "";
				}
				else
				{
					$j = $#orig_note + 1;	# �j�����X�j��
				}
			}

			$ID = $note_page . sprintf("%03d",$note_num);
			$orig_note{$ID} = $note_data;

			# �B�z�i�ϡj�i���j, ���n�����M�����V�c

			# $note{$ID} =~ s/�i�ϡj/&pic;/g;
			# $note{$ID} =~ s/�i���j/&manysk;/g;
			# $note{$ID} =~ s/�i�g�j/&jing;/g;
			# $note{$ID} =~ s/�i�סj/&lum;/g;
			
			# �N �����g�r�@���������� V1.72
			
			$orig_note{$ID} = sp_pali_to_CB($orig_note{$ID});
			#$orig_note{$ID} =~ s/($big5)/&jap_rep($1)/eg;		# �N����ܦ� entity V1.93 (by ray)

			# �ȮɳB�z�� <n> , ���A�� V1.34  , V1.63 �}�l�ʤ�B�z��岤��

			#if($note{$ID} =~ /^$big5*?(ǧ)|(��)|(��)/)
			#{
			#	$note{$ID} = "<n>$note{$ID}";
			#}

			# ��媺�}�Y�]�ȮɳB�z�� <n>, ���A�� V1.53
			
			#if($note{$ID} =~ /^(?:(?:��)|(?:&manysk;)|(?:��))/)
			#if($note{$ID} =~ /^(?:(?:��)|(?:&manysk;))/)			# V1.72 ���� �� , ���H�@���r�B�z
			#{
			#	$note{$ID} = "<n>$note{$ID}";
			#}

=begin
			# �Ȯɲ������Ÿ�, �~(c77e)�Aǧ(c7a7) �H��n�B�z�� (V1.26) 

			while($note{$ID} =~ /^$big5*?�~/)
			{
				$note{$ID} =~ s/^($big5*?)�~/$1/;
			}
			while($note{$ID} =~ /^$big5*?ǧ/)
			{
				$note{$ID} =~ s/^($big5*?)ǧ/$1/;
			}
			# �Ȯɲ������Ÿ�, ��(c6ea), ��(c6f1)�H��n�B�z�� (V1.27) 
			while($note{$ID} =~ /^$big5*?��/)
			{
				$note{$ID} =~ s/^($big5*?)��/$1/;
			}
			while($note{$ID} =~ /^$big5*?��/)
			{
				$note{$ID} =~ s/^($big5*?)��/$1/;
			}
=end
=cut
			$orig_note_line{$ID} = $linenum;	# �O���b���ɪ��X�{���
		}
		else					# �D�зǮ榡�հ�
		{
			print OUT "${linenum}:err1: �հɮ榡����==> p$note_page, $orig_note[$i]";
		}
	}
}

##############################################
# ���R�հɱ���, �æs�J %note
# �ˬd����
# 1. ���Ƥp��e�@�� (���i�᭱�����X�p��ε���e����)
# 2. �ˬd�榡�O�_���T
# 3. �ˬd�s���O�_�s��
##############################################

sub note_analysis()
{
	my $ID;				# %note ��ID
	my $note_page;		# �հɪ���
	my $note_num;		# �հɪ��s��
	my $note_data;		# �հɪ����e

	my $note_pre_page = 0;	# �W�@�Ӯհɪ�����
	my $note_pre_num = 0;	# �W�@�Ӯհɪ��s��

	for(my $i = 0;$i <= $#note; $i++)
	{
		my $linenum = sprintf("%05d",$i+1);
		next if $note[$i] eq "" ;
		next if $note[$i] =~ /^#/;
		last if $note[$i] =~ /^<eof>/i;		#���եΪ�, �Y�հɥX�{ <eof> �h���~��U�h

		if($note[$i] =~ /^p(\d{4})/)
		{
			$note_page = $1;
			if ($note_page <= $note_pre_page)	# ���Ƥ���
			{
				print OUT "${linenum}:err2: �������j��e�@��==> p$note_page <= p$note_pre_page";
			}

			$note_pre_num = 0;		# �o�G�ӭn���]
			$note_pre_page = $note_page;

			next;
		}

		if($note[$i] =~ /^\s*(?:��)?(\d+)\s*(.+)$/)	# �зǮ榡���հ�
		{
			$note_num = $1;
			$note_data = $2;
			if($note_num != $note_pre_num+1)
			{
				print OUT "${linenum}:err3: �հɼƦr���s��==> p$note_page, $note[$i]";
			}
			$note_pre_num = $note_num;

			# �P�_�@�U�U�@��O�_�O���򥻦檺

			for(my $j = $i+1; $j<= $#note; $j++)
			{
				if($note[$j] =~ /^    \s*(.*)$/)
				{
					$note[$j] = $1;
					chomp($note_data);
					if($note[$j] =~ /^[a-z]/i)
					{
						$note_data .= " $note[$j]";
					}
					else
					{
						$note_data .= $note[$j];
					}
					$note[$j] = "";
				}
				else
				{
					$j = $#note + 1;	# �j�����X�j��
				}
			}

			$ID = $note_page . sprintf("%03d",$note_num);
			$note{$ID} = $note_data;

			# �B�z�i�ϡj�i���j, ���n�����M�����V�c

			$note{$ID} =~ s/�i�ϡj/&pic;/g;
			$note{$ID} =~ s/�i���j/&manysk;/g;
			$note{$ID} =~ s/�i�g�j/&jing;/g;
			$note{$ID} =~ s/�i�סj/&lum;/g;
			
			# �N �����g�r�@���������� V1.72
			
			$note{$ID} = sp_pali_to_CB($note{$ID});

			# �ȮɳB�z�� <n> , ���A�� V1.34  , V1.63 �}�l�ʤ�B�z��岤��

			#if($note{$ID} =~ /^$big5*?(ǧ)|(��)|(��)/)
			#{
			#	$note{$ID} = "<n>$note{$ID}";
			#}

			# ��媺�}�Y�]�ȮɳB�z�� <n>, ���A�� V1.53
			
			#if($note{$ID} =~ /^(?:(?:��)|(?:&manysk;)|(?:��))/)
			if($note{$ID} =~ /^(?:(?:��)|(?:&manysk;))/)			# V1.72 ���� �� , ���H�@���r�B�z
			{
				$note{$ID} = "<n>$note{$ID}";
			}

=begin
			# �Ȯɲ������Ÿ�, �~(c77e)�Aǧ(c7a7) �H��n�B�z�� (V1.26) 

			while($note{$ID} =~ /^$big5*?�~/)
			{
				$note{$ID} =~ s/^($big5*?)�~/$1/;
			}
			while($note{$ID} =~ /^$big5*?ǧ/)
			{
				$note{$ID} =~ s/^($big5*?)ǧ/$1/;
			}
			# �Ȯɲ������Ÿ�, ��(c6ea), ��(c6f1)�H��n�B�z�� (V1.27) 
			while($note{$ID} =~ /^$big5*?��/)
			{
				$note{$ID} =~ s/^($big5*?)��/$1/;
			}
			while($note{$ID} =~ /^$big5*?��/)
			{
				$note{$ID} =~ s/^($big5*?)��/$1/;
			}
=end
=cut
			$note_line{$ID} = $linenum;	# �O���b���ɪ��X�{���
		}
		else					# �D�зǮ榡�հ�
		{
			print OUT "${linenum}:err1: �հɮ榡����==> p$note_page, $note[$i]";
		}
	}
}

########################################################################
# ���R�հɱ��ت��榡
# �榡 1. ���r: 21 �ʯ����ʲ��i�T�j����Kha.n.daa.
# �榡 2. �ʦr: 14 �����e���fxx�r or �����Сi�T�j��
# �榡 3. �e�[�r: 12 �����]���^xx�r or �����ϩ�h�i�T�j��
# �榡 4. ��[�r: 28 ���ϧ����]�̡^xx�r or �����i�T�j��
# �榡 5. ����g�r: 12 �ٽá�Saavatthii.
#                   32 ��Vessava.na.
# �榡 6. �g���m�洫: 0379002 : �n�L���w��۫n�L������i���j�i���j�i�c�j
#			0379003 : �n�L���w��۫n�L������i���j�i���j�i�c�j
#			18 �]�n�L�ӡK�T��^�Q�T�r�۫n�L���T��i�T�j�i�c�j�i���j
# �榡 7. ���������r: 06 �]�]�i��K�M�w �^�^�Q�r�ס]�]�w�i��W�W�O�G�Ѧ��M �^�^�Q�r�i���j
# �榡 8. �S���y�r: �������i�T�j�i�c�j, ���Ĥ@�סi�T�j�i�c�j, ���ĤG���i�T�j�i�c�j
# �榡 9. �L�k�B�z���y�l: �u�n�O <x> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, �|�b xxxx �ݩʵ��O
# �榡 10. �L�k�B�z���y�l: �u�n�O <n> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, �B���|�� xxxx �ݩ�
# �榡 11. �L�k�B�z���y�l: �u�n�O <a> �}�Y���y�l, �ڴN���B�z, xml �|��J app ��, �|�b xxxx �ݩʵ��O
# �榡 12. <?> �}�l���Ӳդ��B�z: �����o�ת���ù�i�T�j���A<?>�ײ�V�Ρi���j, �����|��b desc ��.
# �榡 13. <r>A. IX. 3. Meghiya. ==> <note n="0491004" place="foot" type="resource">A. IX. 3. Meghiya.</note>
#################### �ĤG�h����~�|�X�{�� ##############################
# �榡 100. ���r: 21 �ק����]�]�ʲ��^�^xx�r �� �����i�T�j����Kha.n.daa.
# �榡 101. �ʦr: 14 �Сi�T�j��
# �榡 102. ���A�������r:  �����]�]�ʲ��^�^xx�r or �����i�T�j����Kha.n.daa.
# �榡 103 , �[�r���ܧ�, ���S���ϡA�]�S��Ӫ��r: 12 �����]���^xx�r or �����i�T�j��
# �榡 104. <o> , �Y�o�{ <o> , �h���Ҧ����F�賣��� orig �ݩʤ���

# �榡 999, �L�k���R���榡
########################################################################

sub analysis_note_form()
{
	my $oldword;	# ��Ӫ��g��
	my $newword;	# ��L���g��
	my $ver;		# ����
	my $star;		# ���հɬP��
	my $word_num;	# �r��, �Ҧp [�p�O...�ڻD]�Q�K�r (���ܼƴN�O 18)
	my $spell;		# �䥦��g������T
	my $sp_note;	# �S������, �榡 8 �}�l����
	my $ID;
	my $note;
	my $this_note;		# �ثe�n���R���հ�
	my $other_note;		# �|���Q���R���հ�
	my $notenum;		# �հɦb�ĴX�թO?
	my $subID;			# �C�@�ծհɪ��p�ժ��s��,�]�N�O $ID_xxx

	foreach $ID (sort(keys(%note)))
	{
		$note = $note{$ID};

		if($note =~ /<c>/)		# V1.84 <c> �аO���հɧ令 <n> ���B�z�覡, �ӥB���n�O <c> �᭱���@��
		{
			if($note !~ /<n>/)
			{
				$note{$ID} =~ /^.*?�A<c>(.*)$/;
				$note{$ID} = "<n>$1�A<c>$1";
				$note = $note{$ID};
			}
		}

		my $find_oc = 0;		# �P�_���S�� <o><c> �аO V1.72
		my $find_y = 0;			# �P�_���S�� <y> �аO V1.80
		
		# �Y�o�{ <o> or <oo>, �h���Ҧ����F�賣��� orig �ݩʤ���
			
		if($note =~ /<o{1,2}>/)
		{
			$orig_stack{$ID} = $note{$ID};				# �O������!  # V1.91 �Q�����F
			$orig_stack{$ID} =~ s/^.*?<o{1,2}>//;		
			
			# V1.91 ���s����l�հ�, �ҥH�N���� <o> �аO�F
			my $difftmp = diff($orig_stack{$ID},$orig_note{$ID});
			if($difftmp eq "")
			{
				# ��l�հɻP <o> �аO���հɤ��P
				print OUT "$ID : $orig_note{$ID}\nVS\n";
				print OUT "$ID : $orig_stack{$ID}\n\n";
			}
			else
			{
				$orig_note{$ID} = $difftmp;		# �Ǧ^�Ӫ����G
			}
			$orig_stack{$ID} = $orig_note{$ID};		# V1.91 ��l�հɱĥ� $orig_note �����e

			$modify_stack{$ID} = $note{$ID};			# �O������!
			$modify_stack{$ID} =~ s/(?:�A)?<o{1,2}>.*$//;
			$find_oc = 1;
		}

		# �Y�o�{ <c> , �h���Ҧ����F�賣��� orig �ݩʤ���
			
		if($note =~ /<c>/)
		{
			$orig_stack{$ID} = $note{$ID};				# �O������!
			$orig_stack{$ID} =~ s/^.*?<c>//;

			# V1.91 ���s����l�հ�, �ҥH�N���� <o> �аO�F
			my $difftmp = diff($orig_stack{$ID},$orig_note{$ID});
			if($difftmp eq "")
			{
				# ��l�հɻP <o> �аO���հɤ��P
				print OUT "$ID : $orig_note{$ID}\nVS\n";
				print OUT "$ID : $orig_stack{$ID}\n\n";
			}
			else
			{
				$orig_note{$ID} = $difftmp;		# �Ǧ^�Ӫ����G
			}
			$orig_stack{$ID} = $orig_note{$ID};		# V1.91 ��l�հɱĥ� $orig_note �����e
				
			#$modify_stack{$ID} = $note{$ID};			# �O������!
			#$modify_stack{$ID} =~ s/(?:�A)?<c>.*$//;
			$modify_stack{$ID} = $orig_stack{$ID};		# V1.82 �M�Ĥ@�դ@��.
			$modify_stack{$ID} = "<todo type=\"c\"/>" . $modify_stack{$ID};		# V 1.75  <c> �аO�� modify stack �n�[�W <todo type="c"/>
			#$note_total{$ID}--;						# ����@��
			$find_oc = 1;
		}

		# �Y�o�{ <y> , �h���Ҧ����F�賣��� orig �ݩʤ���
			
		if($note =~ /<y>/)
		{
			# <y> �аO���M�w orig �����e, �]�� <y> �᭱�٥i�঳ <o> �� <oo>
			# $orig_stack{$ID} = $note{$ID};				# �O������!
			# $orig_stack{$ID} =~ s/^.*?<y>//;

			$modify_stack{$ID} = $note{$ID};			# �O������!
			$modify_stack{$ID} =~ s/^.*?<y>//;
			$modify_stack{$ID} =~ s/�A<o{1,2}>.*$//;
			
			# $modify_stack{$ID} = "wait for ray";		# �ȮɥΪ� V1.80 , V1.93 ����

			# $note_total{$ID}--;						# ����@��
			$find_y = 1;
		}

		if($find_oc == 0)		# V 1.72 �S�� <o><c> �аO, �h orig = modify = �հɱ���
		{
			# V1.91 ���s����l�հ�, �ҥH�N���� <o> �аO�F
			$orig_stack{$ID} = $note{$ID};				# �O������!
			if($find_y)
			{
				$orig_stack{$ID} =~ s/^.*?<y>//;		# V1.95 �Y�� <y> , �u�� <y> ����Ӫ����
			}
			
			# �]�������O�u�� orig , �ҥH�n�h���аO
			$orig_stack{$ID} =~ s/<z>.*?((?:<[sp~]>)|(?:��))/$1/;	# �����@�ǼаO. V1.96
			$orig_stack{$ID} =~ s/<resp=".*?">//g;		# �����@�ǼаO.
			$orig_stack{$ID} =~ s/�A<.{1,2}>/�A/g;		# �����@�ǼаO.
			$orig_stack{$ID} =~ s/<,>/�A/g;				# �����@�ǼаO.
			$orig_stack{$ID} =~ s/^<.{1,2}>//g;			# �����@�ǼаO.
			$orig_stack{$ID} =~ s/<p>/��/g;				# �����@�ǼаO.
			$orig_stack{$ID} =~ s/><[s~]>/>/g;			# �����@�ǼаO.
			$orig_stack{$ID} =~ s/^<[s~]>//g;			# �����@�ǼаO.
			$orig_stack{$ID} =~ s/�A<[s~]>/�A/g;		# �����@�ǼаO.
			$orig_stack{$ID} =~ s/<[s~]>/ /g;			# �����@�ǼаO.
			$orig_stack{$ID} =~ s/<t>//g;				# �����@�ǼаO.
			$orig_stack{$ID} = get_corr_left($orig_stack{$ID});		# ��X��l����r
			
			my $difftmp = diff($orig_stack{$ID},$orig_note{$ID});
			if($difftmp eq "")
			{
				# ��l�հɻP <o> �аO���հɤ��P
				print OUT "$ID : $orig_note{$ID}\nVS\n";
				print OUT "$ID : $orig_stack{$ID}\n\n";
			}
			else
			{
				$orig_note{$ID} = $difftmp;		# �Ǧ^�Ӫ����G
			}
			$orig_stack{$ID} = $orig_note{$ID};			# �O������!
			
			# V1.91 ����, �o�ǳ����ΤF
			#$orig_stack{$ID} = $note{$ID};				# �O������!
			#if($find_y == 1)
			#{
			#	$orig_stack{$ID} =~ s/^.*<y>//;			# �p�G�� <y> �L <o> , �Ĥ@�h�Ȯɥ� <y> ��
			#}

			if($find_y == 0)
			{
				$modify_stack{$ID} = $note{$ID};			# �O������!
			}
			$find_oc = 1;
			$find_y = 1;
		}

		if($modify_stack{$ID} =~ /<\?>/)		# V1.72
		{
			$modify_stack{$ID} = "<todo type=\"i\"/>" . $modify_stack{$ID};
		}
		
		$modify_stack{$ID} =~ s/<z>(.*?)((?:<)|(?:��))/<corr sic="&lac;">$1<\/corr>$2/g;		# V1.75, <z> ���аO�b modify stack �����e�n�ܦ� <corr sic="lac">...</corr> # ��ӨM�w�ݩʪ��n�令 ��lac�G
		# $modify_stack{$ID} =~ s/><[s~]>/>/g;				# V1.75 <s><~> �ন�b���ť�, # V1.84 ���Y�O�Ĥ@�Ӧr, �N���n��
		$modify_stack{$ID} =~ s/^<[s~]>//g;					# V1.75 <s><~> �ন�b���ť�, # V1.84 ���Y�O�Ĥ@�Ӧr, �N���n��
		$modify_stack{$ID} =~ s/�A<[s~]>/�A/g;				# V1.75 <s><~> �ন�b���ť�, # V1.84 ���Y�O�Ĥ@�Ӧr, �N���n��
		$modify_stack{$ID} =~ s/<[s~]>/ /g;					# V1.75 <s><~> �ন�b���ť�, # V1.84 ���Y�O�Ĥ@�Ӧr, �N���n��
		$modify_stack{$ID} =~ s/<p>/��/g;					# V1.75 <p>�@�ন ��
		$modify_stack{$ID} =~ s/<todo\/>//g;				# V1.94 <todo/> ����
		while ($modify_stack{$ID} =~ /^($big5*?)��/)		# V1.95 �� ����, �]�����|�ܦ� <todo/>
		{
			$modify_stack{$ID} =~ s/^($big5*?)��/$1/;
		}
		# $modify_stack{$ID} =~ s/<resp=".*?">//g;			# �����@�ǼаO. # V1.83 �o�椣�n�F.
		
		$modify_stack{$ID} =~ s/�A<.{1,2}>/�A/g;			# �����@�ǼаO.
		$modify_stack{$ID} =~ s/^<.{1,2}>//g;				# �����@�ǼаO.

		$orig_stack{$ID} =~ s/�i�T�j/&three_ver;/g;			# V1.93 �Ĥ@�h���i�T�j������, �̫�A���^��

		# V1.81 �N��岤�ŧ令 entity
		
		if($orig_stack{$ID} =~ /^$big5*?$jp0/)		# �o�̵o�{��岤�� "�}"(C77D)
		{
			while($orig_stack{$ID} =~ /^$big5*?$jp0/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)$jp0/$1&M062403;/;
			}
		}		

		if($orig_stack{$ID} =~ /^$big5*?$jp1/)		# �o�̵o�{��岤�� "��"(C6E9)
		{
			while($orig_stack{$ID} =~ /^$big5*?$jp1/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)$jp1/$1&M062303;/;
			}
		}

		if($orig_stack{$ID} =~ /^$big5*?��/)		# �o�̵o�{��岤�� "��"(C6F1)
		{
			while($orig_stack{$ID} =~ /^$big5*?��/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)��/$1&M062311;/;
			}
		}

		if($orig_stack{$ID} =~ /^$big5*?��/)		# �o�̵o�{��岤�� "��"(C7F1)
		{
			while($orig_stack{$ID} =~ /^$big5*?��/)
			{
				$orig_stack{$ID} =~ s/^($big5*?)��/$1&M062485;/;
			}
		}

		if($modify_stack{$ID} =~ /^$big5*?$jp0/)		# �o�̵o�{��岤�� "�}"(C77D)
		{
			while($modify_stack{$ID} =~ /^$big5*?$jp0/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)$jp0/$1&M062403;/;
			}
		}		

		if($modify_stack{$ID} =~ /^$big5*?$jp1/)		# �o�̵o�{��岤�� "��"(C6E9)
		{
			while($modify_stack{$ID} =~ /^$big5*?$jp1/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)$jp1/$1&M062303;/;
			}
		}
		
		# V1.93 �ݨ�հɤ����u��v�A�N�N���ন [��>��] ���ɻ~�Φ�
		if($modify_stack{$ID} =~ /^$big5*?��/)		# �o�̵o�{��岤�� "��"(C6F1)
		{
			while($modify_stack{$ID} =~ /^$big5*?��/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)��/$1<corr sic="&M062311;">&M062485;<\/corr>/;
			}
		}

		if($modify_stack{$ID} =~ /^$big5*?��/)		# �o�̵o�{��岤�� "��"(C7F1)
		{
			while($modify_stack{$ID} =~ /^$big5*?��/)
			{
				$modify_stack{$ID} =~ s/^($big5*?)��/$1&M062485;/;
			}
		}

		$other_note = $note;
		$notenum = 0;
		$note_total{$ID} = 0;
		$note_stack_total{$ID} = 0;			# �[�J�̫᪺ note stack ���ƶq
		$foreign_stack_total{$ID} = 0;		# �[�J�̫᪺ foreign stack ���ƶq

		while($other_note)
		{
			if ($other_note =~ /^(<y>${big5}*?)�A(<o{1,2}>${big5}*)$/)	# V1.80 , �]�� <y> �榡����S�O
			{
				$this_note = $1;
				$other_note = $2;
			}
			elsif ($other_note =~ /^(<y>${big5}*?)$/)	# V1.80 , �]�� <y> �榡����S�O
			{
				$this_note = $1;
				$other_note = "";
			}			
			elsif ($other_note =~ /^(${big5}*?)�A(${big5}*)$/)
			{
				$this_note = $1;
				$other_note = $2;
			}
			else
			{
				$this_note = $other_note;
				$other_note = "";
			}
			$this_note =~ s/<,>/�A/g;			# �٭� <,>
			$notenum++;
			$note_total{$ID} = $notenum;		# �P�_���X�եΪ�
			$subID = "${ID}_$notenum";

#=begin
			if ($ID eq "0695002")
			{
				my $debug_ = 1;
			}
#=end
#=cut

			# �Y�o�{ <o> or <oo>, �h���Ҧ����F�賣��� orig �ݩʤ���
			
			if($this_note =~ /^<o{1,2}>/)
			{
				$note_total{$ID}--;
				$notenum--;
				last;
			}

			# �Y�o�{ <c> , �h���Ҧ����F�賣��� orig �ݩʤ���
			
			if($this_note =~ /^<c>/)
			{
				$note_total{$ID}--;
				$notenum--;
				last;
			}

			# �Y�o�{ <y> , �h���Ҧ����F�賣��� orig �ݩʤ���
			
			if($this_note =~ /^<y>/)
			{
				$note_total{$ID}--;
				$notenum--;
				last;
			}

			# �Y�O <d> �}�Y��, �̥��`�覡�B�z, ���n�[�J desc �ݩʤ�
			
			if ($this_note =~ /^<d>/)
			{
				$note_add_desc{$ID} = 1;
				$this_note =~ s/^<d>//;
			}

			# �Y�O <k> �}�Y��, ��ܳo�@���O�B�~�[�J��, �̥��`�覡�B�z, �� <k> ���᪺�аO�n�[�J rdg �� resp �ݩʤ�
			
			if ($this_note =~ /^<k>/)
			{
				$this_note =~ s/^<k>//;
				if ($this_note =~ /^<([^>]*resp[^>]*)>/)
				{
					$note_add_resp{$subID} = $1;
					$this_note =~ s/^<[^>]*>//;
				}
			}
			
			# �Y�O <mg> �}�Y��, �n�W�߳B�z
			# <mg><sic corr="���̤l" resp="�i���j" orig="����[��*��]����̷�@���̤l">����</sic>
			
			if ($this_note =~ /^<mg>/)
			{
				$this_note =~ s/^<mg>//;
				$this_note =~ s/ orig="(.*?)"//;
				$modify_stack{$ID} = $1;
				unless($orig_stack{$ID})
				{
					$orig_stack{$ID} = $modify_stack{$ID};
				}
				$sic_stack{$ID} = $this_note;
				$sic_stack{$ID} =~ s/<sic/<sic n="$ID"/;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			##################### �o�ǳ��O���ڭn�[�W note ���F�� #####################

			# �榡 a. <m> �}�Y��, �n�[�@�� <note n="xxxxxx" place="foot" type="rest">

			if($this_note =~ /^<m>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<m>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"rest\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			# �榡 a.a <cm> �}�Y��, �n�[�@�� <note n="xxxxxx" resp="CBETA" type="rest">

			if($this_note =~ /^<cm>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<cm>//;
				$note_stack{$subID} = "<note n=\"$ID\" resp=\"CBETA\" type=\"rest\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			# �榡 b. <e> �}�Y��, �n�[�@�� <note n="xxxxxx" place="foot" type="equivalent">

			if($this_note =~ /^<e>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<e>//;		#��Ÿ��i���٨S�h��...����: ���h���F
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"equivalent\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			# �榡 c. <f> �}�Y��, �n�[�@�� <note n="xxxxxx" place="foot" type="cf.">

			if($this_note =~ /^<f>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<f>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"cf.\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			# �榡 d. <l> �}�Y��, �n�[�@�� <note n="xxxxxx" place="foot" type="l">  # �Ȯɩ�b�o��

			if($this_note =~ /^<l>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<l>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"l\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			# �榡 e. <g> �}�Y��, �ȮɻP <e> ���P, ��ڤW�O�n���W�� note �� orig ����....��Ӧn���S�� g �F...

			if($this_note =~ /^<g>/)
			{
				$note_stack_total{$ID} = $note_stack_total{$ID}+1;
				my $subID = "${ID}_$note_stack_total{$ID}";
				$note_stack{$subID} = $this_note;
				$note_stack{$subID} =~ s/^<g>//;
				$note_stack{$subID} = "<note n=\"$ID\" place=\"foot\" type=\"g\">" . $note_stack{$subID} . "</note>" ;
				$note_total{$ID}--;			# ����@��
				$notenum--;
				next;
			}

			# �榡 9. �L�k�B�z���y�l: �u�n�O <x> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, �çt�b <todo> ��(�H�e�O:�|�b xxxx �ݩʵ��O)

			if($this_note =~ /^<x>(.*)$/ and $notenum == 1)		# �u���Ĥ@�եX�{
			{
				# �ŦX�榡9

				$note_form{$subID} = 9;
				$note_old{$subID} = $note{$ID};		# �O������!
				$note_old{$subID} =~ s/^<x>//;
				$note_old{$ID} = "";
				last;
			}

			# �榡 10. �L�k�B�z���y�l: �u�n�O <n> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, �B���|�� xxxx �ݩ�

			if($this_note =~ /^<n>(.*)$/ and $notenum == 1)		# �u���Ĥ@�եX�{
			{
				# �ŦX�榡10

				$note_form{$subID} = 10;
				$note_old{$subID} = $note{$ID};		# �O������!
				$note_old{$subID} =~ s/^<n>//;
				$note{$ID} =~ s/^<n>//;
				$note_old{$ID} = "";
				last;
			}

			# �榡 11. �L�k�B�z���y�l: �u�n�O <a> �}�Y���y�l, �ڴN���B�z, xml �|��J app ��, �|�b xxxx �ݩʵ��O

			if($this_note =~ /^<a>(.*)$/ and $notenum == 1)		# �u���Ĥ@�եX�{
			{
				# �ŦX�榡11

				$note_form{$subID} = 11;
				$note_old{$subID} = $note{$ID};		# �O������!
				$note_old{$subID} =~ s/^<a>//;
				$note_add_desc{$ID} = 1;
				$note_old{$ID} = "";
				last;
			}

			my $sp_word = "(?:������)|(?:����$cnum+��)|(?:����$cnum+��)";
			if($this_note =~ /^(${sp_word})((?:\s*${manyver}\s*${notestar}*)+)${allspace}*$/ and $notenum == 1)
			{
				# �ŦX�榡11

				$note_form{$subID} = 11;
				$note_old{$subID} = $note{$ID};		# �O������!
				$note_add_desc{$ID} = 1;
				$note_old{$ID} = "";
				last;
			}

			# �榡 12. <?> �}�l���Ӳդ��B�z: �����o�ת���ù�i�T�j���A<?>�ײ�V�Ρi���j

			if($this_note =~ /^<\?>(.*)$/)
			{
				$oldword = $1;

				# �ŦX�榡12

				$note_form{$subID} = 12;
				$note_old{$subID} = $oldword;
				$note_add_desc{$ID} = 1;
				#$note_add_xxxx{$ID} .= "�������հɨS�B�z�C";		# V1.72 ����
				$note_old{$ID} = "";
				next;
			}

			# �榡 13. <r>A. IX. 3. Meghiya. ==> <note n="0491004" type="resource">A. IX. 3. Meghiya.</note>

			if( $notenum == 1 and $this_note =~ /^<r>/)
			{
				# �ŦX�榡13
				
				$note_form{$subID} = 13;
				$note_old{$subID} = $note{$ID};		# �O������!
				$note_old{$subID} =~ s/^<r>//;
				$note_old{$ID} = "";
				last;
			}

			# �榡 14. �L�k�B�z���y�l: �u�n�O <u> �}�Y���y�l, �ڴN���B�z, xml �|��J tt ��, �|�b xxxx �ݩʵ��O

			if($this_note =~ /^<u>(.*)$/ and $notenum == 1)		# �u���Ĥ@�եX�{
			{
				# �ŦX�榡14

				$note_form{$subID} = 14;
				$note_old{$subID} = $note{$ID};		# �O������!
				$note_old{$subID} =~ s/^<u>//;
				$note_add_desc{$ID} = 1;
				$note_old{$ID} = "";
				last;
			}
			
			# V1.63 ���B�z��岤��
			
			if($this_note =~ /^$big5*?$jp0/)		# �o�̵o�{
			{
				while($this_note =~ /^$big5*?$jp0/)
				{
					$this_note =~ s/^($big5*?)$jp0/$1/;
				}
				$has_japan0{$subID} = 1;	# �o�̦� $jp0 ������
			}

			if($this_note =~ /^$big5*?$jp1/)		# �o�̵o�{
			{
				while($this_note =~ /^$big5*?$jp1/)
				{
					$this_note =~ s/^($big5*?)$jp1/$1/;
				}
				$has_japan1{$subID} = 1;	# �o�̦� $jp1 ������
			}

			# V1.67 ���B�z��岤��
			
			if($this_note =~ /^$big5*?$jp2/)		# �o�̵o�{
			{
				while($this_note =~ /^$big5*?$jp2/)
				{
					$this_note =~ s/^($big5*?)$jp2/$1/;
				}
				$has_japan2{$subID} = 1;	# �o�̦� $jp2 ������
			}

			if($this_note =~ /^$big5*?$big_jp/)		# V1.81 �o�̵o�{���ӥX�{�����j�g����
			{
				$xml_err_msg{$ID} .= "�o�{���j�g����,";
				print OUT "$note_line{$ID}: �o�{���j�g���� [$ID] : $this_note\n";		#v1.33
			}

			# �榡 1. ���r: 21 �ʯ����ʲ��i�T�j����Kha.n.daa.
			# �榡 1. ���r: 21 �����]�]�ʯ��^�^xx�r or �����ק����]�]�ʲ��^�^xx�r or �����i�T�j����Kha.n.daa.

			if($this_note =~ /^(.+?)��(.+?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$newword = $2;
				$ver = $3;
				#$star = $4;
				$spell = $4;
				$word_num = 0;	#���P�� 0 , ���@�U�A�ˬd

				# �B�z�A�����S����
				# �����]���^xx�r or ����
				
				if($oldword =~ /^${allsmallnote}?(?:\Q�]\E){1,2}(.+?)(?:\Q�^\E){1,2}${allsmallnote}?(${cnum}*)(?:�r)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$word_num = $2;
					$tmp = "($tmp)" if ($oldword =~ /${smallnote}/);		# �Y�������h�[�W�A��
					#$tmp = "<{$tmp}>" if ($oldword =~ /����/);				# �Y������h�[�W�A��
					$oldword = $tmp;
				}

				if($newword =~ /^${allsmallnote}?(?:\Q�]\E){1,2}(.+?)(?:\Q�^\E){1,2}${allsmallnote}?${cnum}*(?:�r)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($newword =~ /${smallnote}/);		# �Y�������h�[�W�A��
					$tmp = "<{$tmp}>" if ($newword =~ /����/);				# �Y������h�[�W�A��
					$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# �O������
					$newword = $tmp;
				}

				# �Y�зǡA�h�B�z�U�h

				if (($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/) and ($newword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/))
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword �� $newword\n";		#v1.33
				}
					
				# �ŦX�榡1

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=1,old=$oldword,new=$newword,ver=$ver,star=$star,spell=$spell";
				
				$note_form{$subID} = 1;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				$note_word_num{$subID} = $word_num;

				$note_old{$subID} = get_corr_right($note_old{$subID});		# V1.70 �ɻ~�n�����~��

				if($notenum == 1)
				{
					$note_old{$ID} = $note_old{$subID};
					# �N�K�����i��諸���
					$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
					$note_word_num{$ID} = $word_num;
				}
				next;
			}

			# �榡 2. �ʦr: 14 �����e���fxx�r or �����Сi�T�j��

			if($this_note =~ /^${allsmallnote}?�e(.+?)�f${allsmallnote}?(${cnum}*)(?:�r)*${allsmallnote}?��((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$word_num = $2;
				$ver = $3;
				$spell = $4;

				if ($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/)
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword\n";
				}
				
				# �ŦX�榡2

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				# �B�z����
				if($this_note =~ /${smallnote}/) { $oldword = "($oldword)";}	# �[�W�A��

				#$note_form{"$ID_$notenum"} = "form=2,old=$oldword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 2;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = "";
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				$note_word_num{$subID} = $word_num;
				
				$note_old{$subID} = get_corr_right($note_old{$subID});		# V1.70 �ɻ~�n�����~��

				if($notenum == 1)
				{
					$note_old{$ID} = $note_old{$subID};
					#�N�K�����i��諸���
					$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
					$note_word_num{$ID} = $word_num;
				}
				next;
			}

			# �榡 3. �e�[�r: 12 �����]���^xx�r or �����ϩ�h�i�T�j��

			if($this_note =~ /^${allsmallnote}?\Q�]\E(.+?)\Q�^\E${allsmallnote}?(${cnum}*)(?:�r)*${allsmallnote}?��(.*?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $3;
				$newword = $1;
				$word_num = $2;
				$ver = $4;
				$spell = $5;

				if (($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/) and ($newword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/))
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword �� $newword\n";
				}
				
				# �ŦX�榡3

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				# �B�z����, �O�ѤF�P�_��Ӫ��O�_�]�b������
				if($this_note =~ /${smallnote}/) { $newword = "($newword)";}	# �[�W�A��
				if($this_note =~ /����/) { $newword = "<{$newword}>";}			# �[�W���媺�O��
				$interlinear{$subID} = 1 if($this_note =~ /$interlinear_note/);	# �O������
					
				#$note_form{"$ID_$notenum"} = "form=3,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 3;
					
				$oldword = get_corr_right($oldword);		# V1.70 �ɻ~�n�����~��
					
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword . $oldword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				$note_word_num{$subID} = $word_num;

				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#�N�K�����i��諸���
					$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
					$note_word_num{$ID} = $word_num;
				}
				next;
			}

			# �榡 4. ��[�r: 28 ���ϧ����]�̡^xx�r or �����i�T�j��

			if($this_note =~ /^(.*?)��${allsmallnote}?\Q�]\E(.+?)\Q�^\E${allsmallnote}?${cnum}*(?:�r)*${allsmallnote}?((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$newword = $2;
				$ver = $3;
				#$star = $4;
				$spell = $4;

				if (($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/) and ($newword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/))
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword �� $newword\n";
				}
				
				# �ŦX�榡4

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				# �B�z����, �O�ѤF�P�_��Ӫ��O�_�]�b������
				if($this_note =~ /${smallnote}/) { $newword = "($newword)";}	# �[�W�A��
				if($this_note =~ /����/) { $newword = "<{$newword}>";}			# �[�W���媺�O��
				$interlinear{$subID} = 1 if($this_note =~ /$interlinear_note/);	# �O������
					
				#$note_form{"$ID_$notenum"} = "form=4,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 4;
					
				$oldword = get_corr_right($oldword);		# V1.70 �ɻ~�n�����~��
					
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $oldword . $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#�N�K�����i��諸���
					$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
				}
				next;
			}

			# �榡 5. ����g�r: 12 �ٽá�Saavatthii.
			#                   32 ��Vessava.na.

			if($this_note =~ /^(?:<z>)?(.*?)(${roma}(?:��)?)${allspace}*$/)		# V1.83 �� �� �]�ܦ��榡 5. �����g�r���@����
			{				
				$oldword = $1;
				$spell = $2;
				$word_num = 0;	#���P�� 0 , ���@�U�A�ˬd
				
				if($this_note =~ /^<z>/)	# �n�O���U�� V1.49
				{
					$note_ztag{$ID} = "<z>";
				}

				# �B�z�A�����S����
				# �����]���^xx�r or ����
				
				if($oldword =~ /^(?:\Q�]\E){1,2}(.+?)(?:\Q�^\E){1,2}(${cnum}*)(?:�r)*$/)
				{
					$oldword  = $1;
					$word_num = $2;
				}

				if ($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/)
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword\n";
				}
				
				# �ŦX�榡5

				#$note_form{"$ID_$notenum"} = "form=5,old=$oldword,spell=$spell";
					
				if($oldword eq "")		# �Y�S������, �h�[�J foreign stack �̭�
				{
					$foreign_stack_total{$ID} = $foreign_stack_total{$ID}+1;
					my $subID = "${ID}_$foreign_stack_total{$ID}";
					$foreign_stack{$subID} = $spell;
					$foreign_stack{$subID} =~ s/^($sppattern)//;	# (?:(?:��)|(?:<[pP]>)|(?:<[sS]>)|(?:<~>))
					my $lang = $1;
						
					if($lang =~ /(?:��)|(?:<[pP]>)/)
					{
						$lang = "pli";
					}
					elsif($lang =~ /(?:<~>)/)
					{
						$lang = "unknown";
					}
					elsif($lang =~ /<[sS]>/)
					{
						$lang = "san";
					}
						
					# <foreign n="xxxxxxx" place="foot" lang="pli" resp="Taisho">�K�K</foreign>
					# V1.49
					# �p�G�̫�O (?xxx) �� (xxx?) �� (?) �h�W cert="?"
					# �p�G�u�� ? �b�̫�, �h�[�Wĵ�i
						
					if($foreign_stack{$subID} =~ /(?:\(\?[^\)]*?\)\.?$)|(?:\([^\)]*?\?\)\.?$)/)
					{
						if($foreign_stack{$subID} =~ / /)	# ���Ů�N�nĵ�i
						{
							$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\" cert=\"?\" xxxx=\"��ڤ夤���Ů�,�i��O���y\">" . $foreign_stack{$subID} . "</foreign>";
							print OUT "$note_line{$ID}: ĵ�i:��ڤ夤���Ů�,�i��O���y [$ID] : $note{$ID}\n";
						}
						else
						{
							my $tmp = $foreign_stack{$subID};
							$tmp =~ s/\(\?\)(\.?)$/$1/;
							$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\" cert=\"?\">" . $tmp . "</foreign>";
						}
					}
					elsif($foreign_stack{$subID} =~ /\?\.?$/)
					{
						$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\" cert=\"?\" xxxx=\"?�b��ڤ媺�̫�\">" . $foreign_stack{$subID} . "</foreign>";
						print OUT "$note_line{$ID}: ĵ�i:?�b��ڤ媺�̫� [$ID] : $note{$ID}\n";
					}
					else
					{
						$foreign_stack{$subID} = "<foreign n=\"$ID\" lang=\"$lang\" resp=\"Taisho\" place=\"foot\">" . $foreign_stack{$subID} . "</foreign>";
					}
						
					$note_total{$ID}--;			# ����@��
					$notenum--;
				}
				else
				{
					# ������α�ڪ��հ�
						
					$note_form{$subID} = 5;
					$oldword = get_corr_right($oldword);		# V1.70 �ɻ~�n�����~��
					$note_old{$subID} = $oldword;
					$note_spell{$subID} = $spell;
					$note_word_num{$subID} = $word_num;
				
					if($notenum == 1)
					{
						$note_old{$ID} = $oldword;
						#�N�K�����i��諸���
						$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
						$note_word_num{$ID} = $word_num;
					}
				}
				next;
			}

			# �榡 6. �g���m�洫: 0379002 : �n�L���w��۫n�L������i���j�i���j�i�c�j
			#			0379003 : �n�L���w��۫n�L������i���j�i���j�i�c�j
			#			18 �]�n�L�ӡK�T��^�Q�T�r�۫n�L���T��i�T�j�i�c�j�i���j ~V0.4
			# �o�حY�� ... �N���F, �n��ʤ~��

			#if($this_note =~ /^(?:\Q�]\E){0,2}(.+?)(?:\Q�^\E){0,2}${cnum}*(?:�r)*��(?:\Q�]\E){0,2}(.+?)(?:\Q�^\E){0,2}${cnum}*(?:�r)*((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			if($this_note =~ /^(.+?)��(.+?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = $1;
				$newword = $2;
				$ver = $3;
				$spell = $4;

				# �B�z�A�����S����
				# �����]���^xx�r or ����

				if($oldword =~ /^${allsmallnote}?(?:\Q�]\E){1,2}(.+?)(?:\Q�^\E){1,2}${allsmallnote}?${cnum}*(?:�r)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($oldword =~ /${smallnote}/);		# �Y�������h�[�W�A��
					$oldword = $tmp;
				}

				if($newword =~ /^${allsmallnote}?(?:\Q�]\E){1,2}(.+?)(?:\Q�^\E){1,2}${allsmallnote}?${cnum}*(?:�r)*${allsmallnote}?$/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($newword =~ /${smallnote}/);		# �Y�������h�[�W�A��
					$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# �O������
					$newword = $tmp;
				}

				# �Y�зǡA�h�B�z�U�h

				if (($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/) and ($newword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/))
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword �� $newword\n";
				}
				
				# ����P�_���榳�S���X�{�L
				if($eight_note{$this_note})
				{
					my $tmp = $oldword;
					$oldword = $newword;
					$newword = $tmp;
					$eight_note{$this_note} = 0;
				}
				else {$eight_note{$this_note} = 1};
							
				# �ŦX�榡6
				
				if($ver =~ /��/) {$star = 1;} else {$star = 0;}
				
				#$note_form{"$ID_$notenum"} = "form=6,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 6;
				$oldword = get_corr_right($oldword);		# V1.70 �ɻ~�n�����~��
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#$note_new{$ID} = $newword;
					#�N�K�����i��諸���
					$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
					#$note_new{$ID} = "" if $note_new{$ID} =~ /�K/;
				}
				next;
			}

			# �榡 7. ���������r: 06 �]�]�i��K�M�w �^�^�Q�r�ס]�]�w�i��W�W�O�G�Ѧ��M �^�^�Q�r�i���j

			# ���ӨS�ΤF, �Q�榡 1 �X�֤F
			#if($this_note =~ /^\Q�]�]\E(.+?)\s*\Q�^�^\E${cnum}*(?:�r)*��\Q�]�]\E(.+?)\s*\Q�^�^\E${cnum}*(?:�r)*((?:\s*�i.*�j\s*${notestar}*)+)(${roma}?)${allspace}*$/)
		 	#{
			#	$oldword = $1;
			#	$newword = $2;
			#	$ver = $3;
			#	#$star = $4;
			#	$spell = $4;

			#	if (($oldword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/) and ($newword !~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/))
			#	{
			#		# �ŦX�榡7

			#		if($ver =~ /��/) {$star = 1;} else {$star = 0;}

					#$note_form{"$ID_$notenum"} = "form=7,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
			#		$note_form{$subID} = 7;
			#		$note_old{$subID} = $oldword;
			#		$note_new{$subID} = $newword;
			#		$note_ver{$subID} = $ver;
			#		$note_star{$subID} = $star;
			#		$note_spell{$subID} = $spell;

			#		if($notenum == 1)
			#		{
			#			$note_old{$ID} = $oldword;
			#			#�N�K�����i��諸���
			#			$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
			#		}
			#		next;
			#	}
			#}

			# �榡 8. �S���y�r: �������i�T�j�i�c�j, ���Ĥ@�סi�T�j�i�c�j, ���ĤG���i�T�j�i�c�j

			$sp_word = "(?:�����ӦZ�@��)|(?:�L����)|(?:������)|(?:����$cnum+��)|(?:����$cnum+��)";
			if($this_note =~ /^(${sp_word})((?:\s*${manyver}\s*${notestar}*)+)${allspace}*$/)
			{
				$sp_note = $1;
				$ver = $2;
				#$star = $3;

				# �ŦX�榡8

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=8,sp_note=$sp_note,ver=$ver,satr=$star";
				$note_form{$subID} = 8;
				$note_old{$subID} = $sp_note;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_old{$ID} = "";
				next;
			}

			#################### �ĤG�h����~�|�X�{�� ##########################

			# �榡 100. ���r: 21 �ק����]�]�ʲ��^�^xx�r �� �����i�T�j����Kha.n.daa.

			if($this_note =~ /^��(.+?)((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = "";
				$newword = $1;
				$ver = $2;
				#$star = $4;
				$spell = $3;

				# �B�z�A�����S����
				# �����]���^xx�r or ����
				
				if($newword =~ /^${allsmallnote}?(?:\Q�]\E){1,2}(.+?)(?:\Q�^\E){1,2}${allsmallnote}?${cnum}*(?:�r)*${allsmallnote}?/)
				{
					my $tmp = $1;
					$tmp = "($tmp)" if($newword =~ /${smallnote}/);		# �Y�������h�[�W�A��
					$tmp = "<{$tmp}>" if($newword =~ /����/);			# �Y������h�[�W�O��
					$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# �O������
					$newword = $tmp;
				}

				if ($newword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/)
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $newword\n";
				}
				
				# �ŦX�榡 100

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=100,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 100;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				next;
			}

			# �榡 101. �ʦr: 14 �Сi�T�j��

			if($this_note =~ /^��((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = "";
				$ver = $1;
				#$star = $3;
				$spell = $2;

				if ($oldword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/)
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $oldword\n";
				}
				
				# �ŦX�榡 101

				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				#$note_form{"$ID_$notenum"} = "form=101,old=$oldword,ver=$ver,satr=$star,spell=$spell";
				$note_form{$subID} = 101;
				$note_old{$subID} = $oldword;
				$note_new{$subID} = "";
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;
				if($notenum == 1)
				{
					$note_old{$ID} = $oldword;
					#�N�K�����i��諸���
					$note_old{$ID} = "" if $note_old{$ID} =~ /�K/;
				}
				next;
			}

			# �榡 102. ���A�������r:  �����]�]�ʲ��^�^xx�r or �����i�T�j����Kha.n.daa.
			
			# �榡 103 , �[�r���ܧ�, ���S���ϡA�]�S��Ӫ��r: 12 �����]���^xx�r or �����i�T�j��
			# ��ӭn�̾ڲĤ@�ժ���ƨӽT�{�O�e�[�r�Ϋ�[�r

			if($this_note =~ /^${allsmallnote}?\Q�]\E(.+?)\Q�^\E${allsmallnote}?${cnum}*(?:�r)*${allsmallnote}?((?:\s*${manyver}\s*${notestar}*)+)(${roma}?)${allspace}*$/)
			{
				$oldword = "";
				$newword = $1;
				$ver = $2;
				$spell = $3;

				# �ŦX�榡 102 or 103 (103 �u���@�h�A��)
				if($newword =~ /^\Q�]\E.+\Q�^\E$/)
				{
					# ���G�h�A��, ���� 102 
					$newword =~ s/^\Q�]\E(.+)\Q�^\E$/$1/;
					$note_form{$subID} = 102;
				}
				else
				{
					$note_form{$subID} = 103;
				}

				if ($newword =~ /(\s*�i.*�j\s*)|(\Q�^\E)|(�e)|(�f)|(��)|(��)|(��)|(��)/)
				{
					print OUT "$note_line{$ID}: �p�ߩǲŸ� [$ID] : $newword\n";
				}
				
				if($ver =~ /��/) {$star = 1;} else {$star = 0;}

				# �B�z����, �O�ѤF�P�_��Ӫ��O�_�]�b������
				if($this_note =~ /${smallnote}/) { $newword = "($newword)";}	# �[�W�A��
				if($this_note =~ /����/) { $newword = "<{$newword}>";}			# �[�W���媺�O��
				$interlinear{$subID} = 1 if($newword =~ /$interlinear_note/);	# �O������

				#$note_form{"$ID_$notenum"} = "form=3,old=$oldword,new=$newword,ver=$ver,satr=$star,spell=$spell";

				$note_old{$subID} = $oldword;
				$note_new{$subID} = $newword;
				$note_ver{$subID} = $ver;
				$note_star{$subID} = $star;
				$note_spell{$subID} = $spell;

				next;
			}

			# �榡 999, �L�k���R���榡

			#$note_form{"$ID_$notenum"} = "form=999,sp_note=$this_note";
			$note_form{$subID} = 999;
			$note_old{$subID} = $this_note;
			if($notenum == 1)
			{
				$note_old{$ID} = "";
			}

			# push(@unknown_note, "$note_line{$ID}:�L�k�������R���հ�: $ID : $note\n");
			# print OUT2 "$note_line{$ID}:�L�k�������R���հ�: $ID : $note\n";
		}
	}
}

##############################################
# �N�հɰ��� xml �榡
##############################################

sub make_xml_formate()
{
	local $_;
	my $ID;
	my $subID;
	my $note_total;
	my $errormessage;

	foreach $ID (sort(keys(%note)))
	{
		
#=begin
			if ($ID eq "0155018")
			{
				my $debug_ = 1;
			}
#=end
#=cut
		
		$note_xml{$ID} = "";
		$note_total = $note_total{$ID};		# �����հɪ��ƥ�

		next if $note_total == 0;		# �i��O�u�� note stack

		# �S�� 5 , �ˬd�O���O��@�������g�r

		if($note_form{"${ID}_1"} == 5 and $note_total == 1)
		{
			$subID = "${ID}_1";

			my $skpali = $note_spell{$subID};
=begin
			if ($note_old{$subID} eq "")	# �o�@�q�榡�|���� V1.40
			{
				# �S���۹������~��, XML�榡�O�G<t n="000101" place="foot" lang="san">���</t>

				while($skpali =~ /^${sppattern}.*/)
				{
					my $now;

					$skpali =~ s/^(${sppattern}.+?)((?:${sppattern})|$)/$2/;
					$now = $1;

					if($now =~ /^(��)|(<p>)/i)
					{
						$now =~ s/^(��)|(<p>)//i;
						$note_xml{$ID} .= "<t n=\"$ID\" place=\"foot\" lang=\"pli\">$now</t>";
					}
					elsif($now =~ /^<s>/i)
					{
						$now =~ s/^<s>//i;
						$note_xml{$ID} .= "<t n=\"$ID\" place=\"foot\" lang=\"san\">$now</t>";
					}
					elsif($now =~ /^<~>/i)
					{
						$now =~ s/^<~>//i;
						$note_xml{$ID} .= "<t n=\"$ID\" place=\"foot\" lang=\"unknown\">$now</t>";
					}
				}
				
				#if($orig_stack{$ID})		# V1.40 ����
				#{
				#	$note_xml{$ID} =~ s/place="foot"/place="foot" orig="$orig_stack{$ID}"/;
				#}
				
				if ($show_no_word_error)	# �O�_�n�q�X�S���g�媺����rĵ�i?
				{
					$xml_err_msg{$ID} = "�� 1 �մN�䤣��g��d��C";
				}
			}
			else
=end
=cut			
			{
				# ���۹���������
				if($note_ztag{$ID} eq "<z>")
				{
					$note_xml{$ID} = "<t lang=\"chi\" resp=\"CBETA\">$note_old{$subID}</t>";
				}
				else
				{
					$note_xml{$ID} = "<t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_old{$subID}</t>";
				}
				
				while($skpali =~ /^${sppattern}.*/)
				{
					my $now;
					
					$skpali =~ s/^(${sppattern}.+?)((?:${sppattern})|$)/$2/;
					$now = $1;
					
					if($now =~ /^(��)|(<p>)/i)
					{
						$now =~ s/^(��)|(<p>)//i;
						$note_xml{$ID} .= "<t lang=\"pli\" resp=\"Taisho\" place=\"foot\">$now</t>";
					}
					elsif($now =~ /^<s>/i)
					{
						$now =~ s/^<s>//i;
						$note_xml{$ID} .= "<t lang=\"san\" resp=\"Taisho\" place=\"foot\">$now</t>";
					}
					elsif($now =~ /^<~>/i)
					{
						$now =~ s/^<~>//i;
						$note_xml{$ID} .= "<t lang=\"unknown\" resp=\"Taisho\" place=\"foot\">$now</t>";
					}
				}
				
				$note_xml{$ID} = "<tt n=\"$ID\" type=\"app\">" . $note_xml{$ID} . "</tt>";
				
				#if($orig_stack{$ID})		# V1.40 ����
				#{
				#	$note_xml{$ID} =~ s/type="app"/type="app" orig="$orig_stack{$ID}"/;
				#}
			}
			
			# �@�ǫ�B�z���ʧ@, �n�B�z���O $note_xml
		
			last_process($ID);
			
			next;
		}

		# �S�� 999 , �ˬd�Ĥ@�լO���O�N���q�L�F

		if($note_form{"${ID}_1"} == 999)
		{
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" xxxx=\"��1�մN�����D�F\">$note{$ID}</note>";
			$xml_err_msg{$ID} .= "��1�մN�����D�F�C";
			next;
		}

		# �S�� 8 , �ˬd�Ĥ@�լO���O�N���q�L�F

		if($note_form{"${ID}_1"} == 8)
		{
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\">$note{$ID}</note>";
			next;
		}

		# �S�� 9 , �ϥΪ̫��w�L�k�ˬd��, �]�N�O�H <x> �}�Y���r

		if($note_form{"${ID}_1"} == 9)
		{
			$note_xml{$ID} = "<todo><note n=\"$ID\" place=\"foot\">$note{$ID}</note></todo>";
			next;
		}

		# �S�� 10 , �ϥΪ̫��w�L�k�ˬd��, �H <n> �}�Y���r , �ҥH�S�� xxxx �ݩ�

		if($note_form{"${ID}_1"} == 10)
		{
			my $tmp = $note{$ID};
			$tmp =~ s/�A<[ocy]o?>.*$//;		# �����᭱�����
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\">$tmp</note>";
			next;
		}
		
		# �榡 11. �L�k�B�z���y�l: �u�n�O <a> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, �|�b xxxx �ݩʵ��O

		if($note_form{"${ID}_1"} == 11)
		{
			#$note_xml{$ID} = "<app n=\"$ID\" desc=\"$note{$ID}\" xxxx=\"�S���B�z���հ�\"><lem>???</lem><rdg wit=\"�i???�j\">???</rdg></app>";		# V1.61 ����
			#$note_xml{$ID} = "<note n=\"$ID\" resp=\"CBETA\" type=\"mod\"><todo type=\"a\"/>$note{$ID}</note>";
			$modify_stack{$ID} = "<todo type=\"a\"/>" . $modify_stack{$ID};
			next;
		}

		# �榡 13. �L�k�B�z���y�l: �u�n�O <r> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, ���� type="resource"

		#if($note_form{"${ID}_1"} == 13)
		#{
		#	$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" type=\"resource\">$note{$ID}</note>";
		#	next;
		#}

		# �榡 14. �L�k�B�z���y�l: �u�n�O <u> �}�Y���y�l, �ڴN���B�z, xml �|��J note ��, �|�b xxxx �ݩʵ��O

		if($note_form{"${ID}_1"} == 14)
		{
			# $note_xml{$ID} = "<tt n=\"$ID\" desc=\"$note{$ID}\" xxxx=\"�S���B�z���հ�\"><t lang=\"chi\">???</t><t lang=\"unknown\">???</t><t lang=\"chi\" place=\"foot\">???</t></tt>";		# V1.61 ����
			#$note_xml{$ID} = "<note n=\"$ID\" resp=\"CBETA\" type=\"mod\"><todo type=\"u\"/>$note{$ID}</note>";
			$modify_stack{$ID} = "<todo type=\"u\"/>" . $modify_stack{$ID};
			next;
		}

		# �S�� 100 �H�W�� , ���ӥX�{�b�Ĥ@��, 

		if($note_form{"${ID}_1"} >= 100)
		{
			$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" xxxx=\"��1�մN�����D�F\">$note{$ID}</note>";
			$xml_err_msg{$ID} .= "��1�մN�����D�F�C";
			next;
		}

		# �䥦�U�ժ��ˬd

		for(my $i=1; $i<=$note_total; $i++)
		{
			$subID = "${ID}_$i";

			# �n���ˬd oldword

			# �榡 12. <?> �}�l���Ӳդ��B�z: �����o�ת���ù�i�T�j���A<?>�ײ�V�Ρi���j
			if($note_form{$subID} == 12)
			{
				next;	# ����U�@��
			}

			if($i==1 and $note_form{$subID} != 12)		# �Ĥ@�խn�ˬd����
			{
				if($note_old{$subID} eq "" and $note_form{$subID} != 3 and $note_form{$subID} != 4)	# �榡 3, 4 �O�[�r
				{
					$note_xml{$ID} = "<note n=\"$ID\" place=\"foot\" xxxx=\"�� 1 �մN�䤣��g��d��\">$note{$ID}</note>";
					$xml_err_msg{$ID} .= "�� 1 �մN�䤣��g��d��C";
					next;
				}
			}

			if($i != 1)		# �ĤG�դ���~�ˬd
			{
				my $tmp;
				if($note_old{$subID} ne $note_old{"${ID}_1"})
				{
					if($note_old{$subID} ne "")
					{
						# �Y�O����, �ӥB�O��g��d�򪺤@����, �h�i�H�B�z
						if($note_form{$subID} == 1 && $note_old{"${ID}_1"} =~ /\Q$note_old{$subID}\E/)
						{
							$tmp = $note_old{"${ID}_1"};
							$tmp =~ s/\Q$note_old{$subID}\E/$note_new{$subID}/;
							$note_new{$subID} = $tmp;
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
						# �Y�O�R��, �ӥB�O��g��d�򪺤@����, �h�i�H�B�z
						elsif($note_form{$subID} == 2 && $note_old{"${ID}_1"} =~ /\Q$note_old{$subID}\E/)
						{
							$note_new{$subID} = $note_old{"${ID}_1"};
							$note_new{$subID} =~ s/\Q$note_old{$subID}\E//;
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
						# �Y�O�e(�Ϋ�)�[�r, �ӥB�O��g��d�򪺤@����, �h�i�H�B�z
						elsif(($note_form{$subID} == 3 || $note_form{$subID} == 4) && $note_old{"${ID}_1"} =~ /\Q$note_old{$subID}\E/)
						{
							$tmp = $note_old{"${ID}_1"};
							$tmp =~ s/\Q$note_old{$subID}\E/$note_new{$subID}/;
							$note_new{$subID} = $tmp;
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
						elsif($note_form{$subID} == 999)
						{
							$xml_err_msg{$ID} .= "�� $i �լݤ����C";
						}
						else
						{
							$xml_err_msg{$ID} .= "�� $i �ժ��g��d��P�Ĥ@�դ��X�C";
						}
					}
					else		# ���M�¸�ƪť�, ���n�S�O�B�z
					{
						# �n���N���� 103 �B�z�� ���� 3 �� 4
						if($note_form{$subID} == 103)
						{
							if($note_form{"${ID}_1"} == 3)
							{
								$note_form{$subID} = 3;
							}
							elsif($note_form{"${ID}_1"} == 4)
							{
								$note_form{$subID} = 4;
							}
							else
							{
								$xml_err_msg{$ID} .= "�� $i �դ����[�r�n�[�b�e���Ϋ᭱�C";
							}
						}

						# ���� 102 (���A�������r) �@�w�n�t�X���� 1 (�зǴ��r)
						if($note_form{$subID} == 102)
						{
							if($note_form{"${ID}_1"} != 1)
							{
								$xml_err_msg{$ID} .= "�� $i �����ӭn�t�X���r(��1�����ӬO���r�~��)�C";
							}
						}
					
						# �e�[�r
						if($note_form{$subID} == 3 && $note_old{"${ID}_1"} ne "")
						{
							$note_new{$subID} = $note_new{$subID} . $note_old{"${ID}_1"};
							$note_old{$subID} = $note_old{"${ID}_1"};
						}

						# ��[�r
						if($note_form{$subID} == 4 && $note_old{"${ID}_1"} ne "")
						{
							$note_new{$subID} = $note_old{"${ID}_1"} . $note_new{$subID};
							$note_old{$subID} = $note_old{"${ID}_1"};
						}
					}
				}
			}

			# �o�̬O�ש�q�L�F

			if($note_form{$subID} != 5)		# ���O��ª�����ഫ
			{
				my $tmp = $note_new{$subID};
				my $add_resp = "";		# �w�����H�n�b rdg ���[�J resp �ά����ݩ�, �o�O���F <k> �ҳ]�p��
				
				$tmp = "&lac;" if $tmp eq "";
				if($note_add_resp{$subID})
				{
					$add_resp = " $note_add_resp{$subID}";
				}
				
				if($note_ver{$subID} =~ /$manyver.+/)	# �P���βV�P�������F��n���� desc ���� , V1.42
				{
					my $tmp = "";
					my $tmp2 = $note_ver{$subID};
					
					while($tmp2 =~ /$manyver/)
					{
						$tmp2 =~ s/($manyver)//;
						$tmp .= $1;
					}
					$note_ver{$subID} = $tmp;
					if($tmp2 ne "")
					{
						$note_add_desc{$ID} = 1;		# V1.44
					}
				}	
				
				if($has_japan0{$subID})			# ���饻���� V1.63
				{
					$note_xml{$ID} .= "<rdg wit=\"�i�H�ϡj\" resp=\"$note_ver{$subID}\"${add_resp}>$tmp</rdg>";
				}
				elsif($has_japan1{$subID})			# ���饻���� V1.63
				{
					$note_xml{$ID} .= "<rdg wit=\"�i�H�Сj\" resp=\"$note_ver{$subID}\"${add_resp}>$tmp</rdg>";
				}
				elsif ($has_japan2{$subID})			# ���饻���� V1.67, �ӥB�o�@�خ榡�٭n�A����B�z
				{
					$tmp =~ s/<note place="inline">(.*?)<\/note>/\($1\)/g;	# �b corr �����i�H���аO
					$tmp =~ s/<note place="interlinear">(.*?)<\/note>/\($1\)/g;	# �b corr �����i�H���аO

					$note_xml{$ID} .= "<jap2sic corr=\"$tmp\" resp=\"$note_ver{$subID}\">";
				}
				else
				{
					$note_xml{$ID} .= "<rdg wit=\"$note_ver{$subID}\" resp=\"Taisho\"${add_resp}>$tmp</rdg>";
				}
			}
		}

		# ���@�ǯS�ҭn�ܦ� <sic> , �Ҧp�����O �H ���W�߳�ծհ�
		if($note_ver{"${ID}_1"} eq "�H" and $note_total == 1)
		{
			#T44p0137 [11] �U�׮��H
			#<sic n="xxxxxxx" resp="Taisho" cert="?" corr="��">�U</sic>

			my $subID = "${ID}_1";
			$note_xml{$ID} =~ /<rdg [^>]*>(.*?)<\/rdg>/;
			my $tmp = $1;
			# �o�̦��I�M�I, �]���N sic �����O��զb�B�z
			$sic_stack{$ID} = "<sic n=\"$ID\" resp=\"Taisho\" cert=\"?\" corr=\"$tmp\">$note_old{$subID}</sic>";
			$note_xml{$ID} = "";
		}
		else
		{
			# ���B�z������, �N�̥~�h�� app �ФW�h
			# �[�J�n���n�ݩ�
			
			my $tmp = "${ID}_1";
			my $has_attrib = "";

			#$has_attrib .= " desc=\"$note{$ID}\"" if $note_add_desc{$ID};		# V1.65 ����
			#$has_attrib .= " orig=\"$orig_stack{$ID}\"" if $orig_stack{$ID};    	# V1.40 ����
			$has_attrib .= " xxxx=\"$note_add_xxxx{$ID}\"" if $note_add_xxxx{$ID};
			$note_xml{$ID} = "<app n=\"$ID\"${has_attrib}><lem>$note_old{$tmp}</lem>" . $note_xml{$ID} . "</app>";
		}

		$note_xml{$ID} =~ s/<lem><\/lem>/<lem>&lac;<\/lem>/;		# �Y�Ĥ@���S���

		# �ˬd�O���O���ڧQ��α��, �Y���n�N���]�b tt �аO��

		if(not $xml_err_msg{$ID})
		{
			my $gloss_count = 0;
			my $gloss_tmp = "";

			for(my $i=1; $i<=$note_total; $i++)
			{
				$subID = "${ID}_$i";
				if($note_spell{$subID})
				{
					my $skpali = $note_spell{$subID};
				
					while($skpali =~ /^${sppattern}.*/)
					{
						my $now;
					
						$skpali =~ s/^(${sppattern}.+?)((?:${sppattern})|$)/$2/;
						$now = $1;
					
						if($now =~ /^(��)|(<p>)/i)
						{
							$now =~ s/^(��)|(<p>)//i;
							$gloss_tmp .= "<t lang=\"pli\" resp=\"Taisho\" place=\"foot\">$now</t>";
						}
						elsif($now =~ /^<s>/i)
						{
							$now =~ s/^<s>//i;
							$gloss_tmp .= "<t lang=\"san\" resp=\"Taisho\" place=\"foot\">$now</t>";
						}
						elsif($now =~ /^<~>/i)
						{
							$now =~ s/^<~>//i;
							$gloss_tmp .= "<t lang=\"unknown\" resp=\"Taisho\" place=\"foot\">$now</t>";
						}
					}
					$gloss_count++;
				}	
			}

			if($gloss_count > 0)
			{
				# $note_xml{$ID} =~ s/<app n="$ID"/<app n="${ID}b"/;  	# ��ӨM�w���� abcd �F

				if($gloss_count == 1)			# �n��n���� 1 �~��.
				{
					if($note{$ID} =~ /<z>/)		# V1.75 , ��G�ռаO, �B�� <z> ��, �[�W xxxx �ݩʪ�ĵ�i
					{
						$note_xml{$ID} = "<tt n=\"${ID}\" type=\"app\" xxxx=\"�� z �аO\"><t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_xml{$ID}</t>$gloss_tmp</tt>";
					}
					else
					{
						$note_xml{$ID} = "<tt n=\"${ID}\" type=\"app\"><t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_xml{$ID}</t>$gloss_tmp</tt>";
					}
				}
				else
				{
					$note_xml{$ID} = "<tt n=\"${ID}\" type=\"app\" xxxx=\"��ڤ�r�W�L�G��\"><t lang=\"chi\" resp=\"Taisho\" place=\"foot\">$note_xml{$ID}</t>$gloss_tmp</tt>";
				}

				#if($orig_stack{$ID})			# V1.40 ����
				#{
				#	$note_xml{$ID} =~ s/type="app"/type="app" orig="$orig_stack{$ID}"/;
				#}
			}
		}

		# �@�ǫ�B�z���ʧ@, �n�B�z���O $note_xml

		last_process($ID);
	}

	######## �[�W stack  #######################

	foreach $ID (sort(keys(%note)))
	{
		my $all_stack = "";
		my $big5corr='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x5a]|\x5c|[\x5e-\x7f]))';

		# �[�W orig stack , �o�O��l���	V1.40
		$all_stack = "<note n=\"$ID\" resp=\"Taisho\" type=\"orig\" place=\"foot\">$orig_stack{$ID}</note>";

		# ���ק諸��Ʃ�ĤG�h�� Note	V1.63 , V1.65
		if(($orig_stack{$ID} ne $modify_stack{$ID}) or ($note_add_desc{$ID}==1))
		{
			$all_stack .= "<note n=\"$ID\" resp=\"CBETA\" type=\"mod\">$modify_stack{$ID}</note>";
		}

		# �[�W foreign stack , <foreign> �аO	V1.40

		for(my $i=1; $i<=$foreign_stack_total{$ID}; $i++)
		{
			$subID = "${ID}_$i";
			$all_stack .= "$foreign_stack{$subID}";		# �[�W foreign stack
		}
		
		# �[�W sic stack , <sic> �аO	V1.40
		if($sic_stack{$ID})
		{
			$all_stack .= "$sic_stack{$ID}";
		}

		# ���N�e���� stack �[�i�h
		$note_xml{$ID} =  $all_stack . $note_xml{$ID};

		# �̫�[�W note stack
		for(my $i=1; $i<=$note_stack_total{$ID}; $i++)
		{
			$subID = "${ID}_$i";
			$note_xml{$ID} .= $note_stack{$subID};
		}
	}
}

#################################################
#
# �@�ǫ�B�z���ʧ@, �n�B�z���O $note_xml	V1.40
#
#################################################

sub last_process()
{
	my $ID = shift;

=begin
	1.T02p0181? 06 <z>�m�F����<~>Pu.syadharman.�]�m�F�F���^
	
	<tt>
	    <t lang="chi">�m�F����</t>
	    <t lang="unknown">Pu.syadharman.�]�m�F�F���^</t>
	</tt>	
	
    "����ӫe�ҡA��������ù����r�]�[�i�uplace="foot"�v�A�ܦ��G
    
	<tt>
	    <t lang="chi">�m�F����</t>
	    <t lang="unknown" resp="Taisho" place="foot">Pu.syadharman</t>
	    <t lang="chi" resp="Taisho" place="foot">�m�F�F��</t>
	</tt>
=end
=cut

	while($note_xml{$ID} =~ /(.*?)<(t lang="[^c][^>]*)>(.*?)\Q�]\E(.+?)\Q�^\E<\/t>(.*)/)
	{
		my $head = $1;
		my $tag = $2;
		my $skpali = $3;
		my $chinese = $4;
		my $tail = $5;
		
		$note_xml{$ID} = $head . "<${tag} place=\"foot\">" . $skpali . "</t>" .
						 "<t lang=\"chi\" resp=\"Taisho\" place=\"foot\">" . $chinese . "</t>" . $tail;
	}

=begin
	2.T02p0635? 11 <z>�|��Udaana.(?xx) (�άO�S���A�����ݸ�)
	
	<tt n="0635011" type="app">
		<t lang="chi">�|</t>
		<t lang="pli" resp="Taisho">Ud&amacron;na.(?)</t>
	</tt>
	
	���{�b�n�N </todo> �����A�å[�W�uplace="foot" cert="?"�v���ݩʡA�ܦ��G
	
	<tt n="0635011" type="app">
		<t lang="chi">�|</t>
		<t lang="pli"  resp="Taisho" place="foot" cert="?">Ud&amacron;na.(?)</t>
	</tt>
	
	�p�G����ڤ�, �h�n�令

    T02p0635? 11 <z>�|��Udaana.(xx?) (�άO�S���A�����ݸ�)
	
	<tt n="0635011" type="app">
		<t lang="chi">�|</t>
		<t lang="pli"  resp="Taisho" place="foot">Ud&amacron;na</t>
		<t lang="pli"  resp="Taisho" place="foot" cert="?">xx?</t>
	</tt>
	
	
=end
=cut

	#�p�G��ڳ̫�O (?) , �h�n�[�W cert="?", �� (?) �n����
	$note_xml{$ID} =~ s/<(t lang="[^c][^>]*)>([^<]*?)\(\?\)(\.?<\/t>)/<$1 cert="?">$2$3/g;
	

	# �p�G�O ? �S���b () ��, �h�n���O��
	if($note_xml{$ID} =~ /<t lang="[^c][^>]*>[^<]*?\?\.?<\/t>/)
	{
		$note_xml{$ID} =~ s/<(t lang="[^c][^>]*)>([^<]*?\?\.?)<\/t>/<$1 cert="?" xxxx="?�b��ڤ媺�̫�">$2<\/t>/g;
		print OUT "$note_line{$ID}: ĵ�i:?�b��ڤ媺�̫� [$ID] : $note{$ID}\n";
	}

	while($note_xml{$ID} =~ /(.*?)<(t lang="[^c][^>]*)>([^<]*?)\(((?:\?[^\)]+?)|(?:[^\)]+?\?))\)(\.?)<\/t>(.*)/)
	{
		my $head = $1;
		my $tag = $2;
		my $skpali = $3 . $5;
		my $another = $4;
		my $tail = $6;
		
		my $hasspace = "";
		
		if ($skpali =~ / /)
		{
			$hasspace = " xxxx=\"��ڤ夤���Ů�,�i��O���y\"";
			print OUT "$note_line{$ID}: ĵ�i:��ڤ夤���Ů�,�i��O���y [$ID] : $note{$ID}\n";
		}
		else
		{
			$skpali =~ s/\.$//;		# �̫᪺�y�I�h��
		}
		
		$another =~ s/^\?//;
		$another =~ s/\?$//;	# �h���Y���� ? �ݸ� V1.66
		
		$note_xml{$ID} = $head . "<${tag}${hasspace}>" . $skpali . "</t>" .
						 "<${tag} cert=\"?\">" . $another . "</t>" . $tail;
	}

	# �N�@�Ǧ� <note place="inline"> �o�S��ƪ�, �N���ܦ� &lac;
	$note_xml{$ID} =~ s#><note[^>]*?place="inline"[^>]*?></note><#>&lac;<#g;
	$note_xml{$ID} =~ s#><note[^>]*?place="interlinear"[^>]*?></note><#>&lac;<#g;

	# �N <note place="inline">&lac;</note> �ܦ� &lac; �Y�i.
	$note_xml{$ID} =~ s#><note[^>]*?place="inline"[^>]*?>&lac;</note><#>&lac;<#g;
	$note_xml{$ID} =~ s#><note[^>]*?place="interlinear"[^>]*?>&lac;</note><#>&lac;<#g;

	$note_xml{$ID} =~ s#<note[^>]*?place="inline"[^>]*?>&lac;</note>##g;
	$note_xml{$ID} =~ s#<note[^>]*?place="interlinear"[^>]*?>&lac;</note>##g;
	
	# ĵ�i�����O�H���հɡ@V1.42
	
	if($note_xml{$ID} =~ /<rdg\s+wit="�H/)
	{
		$note_xml{$ID} =~ s/(<rdg\s+wit="�H.*?)>/$1 xxxx="ĵ�i:���H������">/g;
		print OUT "$note_line{$ID}: ĵ�i:���H������ [$ID] : $note{$ID}\n";
	}
	
	# ĵ�i�ĤG�ոg�妳�K�Ÿ���	V1.42
	if($note_xml{$ID} =~ /<rdg[^>]*>[^<]*?�K/)
	{
		$note_xml{$ID} =~ s/(<rdg[^>]*)(>[^<]*?�K)/$1 xxxx="ĵ�i:�հɧt���K"$2/g;
		print OUT "$note_line{$ID}: ĵ�i:�հɧt���K [$ID] : $note{$ID}\n";
	}
	
	# �B�z�����̭������� V1.71
	# <rdg wit="�i���j�i���n�áj<resp="�i���j">"...> �ܦ� <rdg wit="�i���j>...<rdg wit="�i���n�áj" resp="�i���j"...>
	
	if($note_xml{$ID} =~ /<rdg wit="(?:�i[^>]*?�j)+�i.*?�j<resp="�i.*?�j">"[^>]*>.*?<\/rdg>/)
	{
		$note_xml{$ID} =~ s/(<rdg wit="(?:�i[^>]*?�j)+)(�i.*?�j)<(resp="�i.*?�j")>"([^>]*)(>.*?<\/rdg>)/$1"$4$5<rdg wit="$2" $3$5/g;
	}
	
	# �B�z�����̭������� V1.45
	# <rdg wit="�i���n�áj<resp="�i���j">"...> �ܦ� <rdg wit="�i���n�áj" resp="�i���j"...>
	
	if($note_xml{$ID} =~ /(<rdg wit="�i.*?�j)<(resp="�i.*?�j")>"([^>]*?)(resp="Taisho")?([^>]*?>)/)
	{
		$note_xml{$ID} =~ s/(<rdg wit="�i.*?�j)<(resp="�i.*?�j")>"([^>]*?)(resp="Taisho")?([^>]*?>)/$1" $2$3$5/g;
		$note_xml{$ID} =~ s/(resp=".*?") resp="Taisho"/$1/g;	# ���o�w����U.
	}	
	
	#if($note_xml{$ID} =~ /<rdg wit="(�i.*?�j){2,}<resp="�i.*?�j">"[^>]*>/)
	#{
	#	#���G�� �i.*?�j, ���ųB�z��h
	#	print OUT "$note_line{$ID}: ĵ�i(�i��~�P):���G�� �i.*?�j : $note{$ID}\n";
	#}

	if($note_xml{$ID} =~ /<rdg wit="�i.*?�j<resp="�i.*?�j">[^"]+">/)
	{
		# <resp> �����٦��F��, ���ųB�z��h
		print OUT "$note_line{$ID}: ĵ�i: <resp> �����٦��F�� : $note{$ID}\n";
	}



=begin

	V 1.67
	
	����� [�O] ��, ���e�ڷ|������ ���� rdg , �����O rdg , �ӬO�� <jap2sic
	
	<jap2sic corr="xx" resp="�i�����j">
	
	�A�ɦA�B�z��թΦh��
	
	<sic corr="xx" resp="�i�����j">yy</sic> 
	
	
	��ժ�:
	
	[��*��]����[�O]�i�ҡj
	
	<sic corr="��" resp="�i�ҡj">[��*��]</sic>
	
	�h�ժ�:
	
	[��*��]���[[��-�G]�A��[�O]�i�ҡj

	<app>
    	<lem><sic corr="��" resp="�i�ҡj">[��*��]</sic></lem>
    	<rdg wit="?" resp="�i�ҡj">�[</rdg>
	</app>
	
=end
=cut

	if($note_xml{$ID} =~ /<jap2sic/)
	{
		if($note_xml{$ID} =~ /<rdg/)
		{
			# �h�ժ�
			$note_xml{$ID} =~ s/<lem>(.*?)<\/lem>(.*?)<jap2sic (.*?)>/<lem><sic $3>$1<\/sic><\/lem>$2/;
		}
		else
		{
			# ��ժ�
			$note_xml{$ID} =~ s/<app.*?(n=".*?").*?<lem>(.*?)<\/lem>.*?<jap2sic (.*?)>.*?<\/app>/<sic $1 $3>$2<\/sic>/;
		}
	}
}

##############################################
# �t�X�g�尵²����R
# �ˬd����
# 1.�g�孶���Ǥ����
# 2.�հɼƦr�M�e�@�Ӥ��X
# 3.�հ���S���������հɸ��
# 4.�ˬd�հɼƦr�᪺��r�P�հ����r���X
##############################################

sub check_with_sutra()
{
	my $line_page;		# �Ӧ檺��
	my $line_num;		# �Ӧ�հɪ��s��
	my $linenum;		# �g�媺���
	my $line_pre_page=0;	# �W�@�Ӯհɪ�����
	my $line_pre_num=0;	# �W�@�Ӯհɪ��s��

	open SUTRA, $sutra || die "open $sutra error";
	@sutra = <SUTRA>;
	close SUTRA;

	for(my $i = 0; $i <= $#sutra; $i++)
	{
		# T01n0001_p0001a02X##[01]�����t�g��
		# T01n0001_p0001a19_##�W�C�}[07]�R�׳~�C�ҰO�����C�G�H�����ءC��
		# T01n0001_p0001a20_##����̡C���g�y��C������[��]��C��p�ީ]�C��

		$linenum = sprintf("%05d", $i+1);		# �g�媺���

		$line = $sutra[$i];

		$line_page = substr($line, 10, 4);
		if($line_page < $line_pre_page)
		{
			if($line !~ /T49/)
			{
				push (@sutra_err, "${linenum}:err4: �g�孶�Ƥp��e�@��==> $line");
			}
			# print OUT "${linenum}:err4: �g�孶�Ƥp��e�@��==> $line";
		}
		elsif ($line_page > $line_pre_page)
		{
			# �����F, ���Ǹ�ƭn���]
			$line_pre_page = $line_page;	# �W�@�Ӯհɪ�����
			$line_pre_num=0;				# �W�@�Ӯհɪ��s��
		}

		my $lineTmp = $line;			# �B�z�Ϊ�
		#$lineTmp =~ s/\[�g\]/�g/g;
		#$lineTmp =~ s/\[��\]/��/g;	
		#$lineTmp =~ s/�i�g�j/�g/g;
		#$lineTmp =~ s/�i�סj/��/g;
		$lineTmp =~ s/<no_nor>//g;
		$lineTmp = get_corr_right($lineTmp);	# �]�����ǮհɼƦr�|���� [[xx]>>] , �ҥH�n���B�z

		while($lineTmp =~ /\[(\d{1,4})\]/)		#�o�{���Ʀr
		{
			$line_num = $1;
			if($line_num != $line_pre_num + 1)
			{
				push (@sutra_err, "${linenum}:err5: �հɼƦr���s��[$line_num]==> $line");
				#print OUT "${linenum}:err5: �հɼƦr���s��[$line_num]==> $line";
			}
			$line_pre_num = $line_num;

			my $ID = $line_page . sprintf("%03d",$line_num);

			if($note{$ID})
			{
				# ���հɸ��, �ˬd�հɤU����r�X���X
				if ($note_old{$ID} and $lineTmp !~ /\Q[$line_num]$note_old{$ID}\E/)
				{
					# ���i��O���@�����b�U�G��, �ҥH�n���_���ˬd

					my $next_line = "";
					if($i < $#sutra)
					{
						$next_line = $sutra[$i+1];
						$next_line =~ s/^T.{19}(��)?//;	# �����歺
						my $tmp = $line;
						chomp($tmp);
						$next_line = $tmp . $next_line;	# ���_��
						
						#�P�_�ĤG��
						
						if($i+1 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+2];
							$tmp =~ s/^T.{19}(��)?//;	# �����歺
							chomp($next_line);
							$next_line = $next_line . $tmp;	# ���_��
						}
						
						#�P�_�ĤT��
						
						if($i+2 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+3];
							$tmp =~ s/^T.{19}(��)?//;	# �����歺
							chomp($next_line);
							$next_line = $next_line . $tmp;	# ���_��
						}
								
						#�P�_�ĥ|��
						
						if($i+3 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+4];
							$tmp =~ s/^T.{19}(��)?//;	# �����歺
							chomp($next_line);
							$next_line = $next_line . $tmp;	# ���_��
						}
						
						#�P�_�Ĥ���
						
						if($i+4 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+5];
							$tmp =~ s/^T.{19}(��)?//;	# �����歺
							chomp($next_line);
							$next_line = $next_line . $tmp;	# ���_��
						}
						
						#�P�_�Ĥ���
						
						if($i+5 < $#sutra)
						{
							my $tmp;
							$tmp = $sutra[$i+6];
							$tmp =~ s/^T.{19}(��)?//;	# �����歺
							chomp($next_line);
							$next_line = $next_line . $tmp;	# ���_��
						}
					}
					else
					{
						$next_line = $line;
					}

					$next_line =~ s/\[��\]//g;
					$next_line =~ s/<no_nor>//g;
					$next_line =~ s/�C//g;
					$next_line =~ s/�D//g;
					$next_line =~ s/�i���j//g;		# ���N�x�貾��
					$next_line =~ s/$fullspace//g;
					
					#$next_line =~ s/\[�g\]/�g/g;
					#$next_line =~ s/\[��\]/��/g;
					#$next_line =~ s/�i�g�j/�g/g;
					#$next_line =~ s/�i�סj/��/g;
					
					$next_line =~ s/�i�ϡj/&pic;/g;

					$next_line =~ s/�i�g�j/&jing;/g;
					$next_line =~ s/�i�סj/&lum;/g;					
					
					
					while($next_line =~ /^$big5*?��/)
					{
						$next_line =~ s/^($big5*?)��/$1/;
					}
					while($next_line =~ /^$big5*?��/)
					{
						$next_line =~ s/^($big5*?)��/$1/;
					}					
					while($next_line =~ /^$big5*?��/)		# ���N�x�貾��
					{
						$next_line =~ s/^($big5*?)��/$1/;
					}
					#$next_line =~ s/\(//g;		# �|�z�Z�զr��, �n����
					#$next_line =~ s/\)//g;

					# �N�䥦���հ� [xx] �]���}

					$next_line =~ s/\[$line_num\]\(?/<<>>/;
					$next_line =~ s/\[\d+?]//g;
					$next_line =~ s/<<>>/\[$line_num\]/;

					# �N�ɻ~���L��

					$next_line = get_corr_right($next_line);
					
					my $tmp_note_old = get_corr_right($note_old{$ID});	# �B�z�հ�
					$tmp_note_old =~ s/^\(//;							# �Y�@�}�l�O�����A��, �]�h��, �H�Q���

					if ($next_line !~ /\Q[$line_num]${tmp_note_old}\E/)
					{
						# �o�O���F�榡 6 �ҳ]�p��, �]�����i��g��b�t�@�Ӧa��
						
						#my $tmp_note_new = get_corr_right($note_new{$ID});	# �B�z�հ�
						#$tmp_note_new =~ s/^\(//;							# �Y�@�}�l�O�����A��, �]�h��, �H�Q���
						#unless($note_new{$ID} and $next_line =~ /\Q[$line_num]${tmp_note_new}\E/)
						
						my $tmp1 = $next_line;
						my $tmp2 = $tmp_note_old;
						$tmp1 =~ s/[\(\)]//g;	# �Ȯɥh���A��, �H�Q���K�г��� (�G�X)(��)....
						$tmp2 =~ s/[\(\)]//g;
						while($tmp2 =~ /^$big5*?��/)	# ���N�x�貾��
						{
							$tmp2 =~ s/^($big5*?)��/$1/;
						}
						$tmp2 =~ s/&SD\-.*?;//g;		# ���N &SD-CFC1; �o�رx��r���� V1.56

						if ($tmp1 !~ /\Q[$line_num]${tmp2}\E/)
						{
							# print OUT "$note_line{$ID}:err6:${linenum}: �հɸg��P�հ��椣�X==> [$line_num\]$note_old{$ID} ==>  $next_line";
							push (@both_sutra_note_err, "$note_line{$ID}:err6: �հɸg��P�հ��椣�X==> [$line_num\]$note_old{$ID}\n");
							push (@both_sutra_note_err, "$infile : found => \[\n");
							push (@both_sutra_note_err, "${linenum}:err6:: �հɸg��P�հ��椣�X==> $next_line");
							push (@both_sutra_note_err, "$sutra : found => \[\n\n");
						}
					}
				}
			}
			else
			{
				# �S���հɸ��
				push (@sutra_err, "${linenum}:err7: �հ���S���������հɸ��[$line_num]==> $line");
				# print OUT "${linenum}:err7: �հ���S���������հɸ��[$line_num]==> $line";
			}
			$has_note{$ID} = 1;			# �N���հɰ��O��

			$lineTmp =~ s/\[$line_num\]//;		# �B�z�L���N����
		}
	}
}

##############################################
# �ˬd���S���հɰt����g�媺
# �ˬd����
# 1.�հɨS���X�{�b�g�夤
##############################################

sub check_lose_note()
{
	my $ID;

	foreach $ID (sort(keys(%note)))
	{
		unless ($has_note{$ID})
		{
			my $page = substr($ID, 0, 4);
			my $num = substr($ID, 4, 3);
			$num =~ s/^0//;
			print OUT "$note_line{$ID}:err8: �հɨS���X�{�b�g�夤==> p$page, [$num] , $note{$ID}\n";
		}
	}
}

##############################################
# �N���G��X
##############################################

sub other_output()
{
	local $_;
	my $ID;
	# �ɻ~�Ϊ��r��, �̭��S�� [ ]
	my $big5corr='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x5a]|\x5c|[\x5e-\x7f]))';
	
	#print OUT "$infile : found => \[\n\n";

	# �L�k���R���հɱ���

	#for(my $i=0; $i<= $#unknown_note; $i++)
	#{
	#	print OUT $unknown_note[$i];
	#}
	#print OUT "$infile : found => \[\n\n";

	# �L�X xml ��

	open XMLOUT ,">$xmlout";
	foreach $ID (sort(keys(%note_xml)))
	{
		last_proce($ID);			# �B�z�@�ǪF��

		my $xmltmp = $note_xml{$ID};	# �ȮɳB�z�ɻ~�Ϊ�
		my $notetmp = $note{$ID};
		
		while($xmltmp =~ /^($big5*?)\[($big5corr*?)>($big5corr*?)\]/)
		{
			# <lem> �����ɻ~�w�Q���N���g�媺, �ҥH�o�̥u�|���� rdg ��
			$xmltmp =~ s/^($big5*?)\[($big5corr*?)>($big5corr*?)\](?:<[^>]*(resp[^>]*)>)?/$1<corr sic="$2" $4>$3<\/corr>/;
			$xmltmp =~ s/(<corr[^>]*") >/$1>/g;		# �h�� <corr xxx="..." > �̫᪺�Ů� (�b > ���e��)
		}
		while($xmltmp =~ /^($big5*?)��/)
		{
			$xmltmp =~ s/^($big5*?)��/$1/;		# �B�z todo
		}			
		while($xmltmp =~ /^($big5*?)��/)
		{
			$xmltmp =~ s/^($big5*?)��/$1<todo\/>/;	# �B�z todo
		}
		$xmltmp =~ s/�i���j/�iunknown�j/g;
		while($xmltmp =~ /^($big5*?)��/)
		{
			$xmltmp =~ s/^($big5*?)��/$1&lac-space;/;		# �ʡ��G��&lac-space;��� 
		}
		while($xmltmp =~ /^($big5*?)��/)
		{
			$xmltmp =~ s/^($big5*?)��/$1&unrec;/;	# �ҽk�r���G��&unrec;���
		}
		
		$xmltmp =~ s/<t>/<todo\/>/g;				# �B�z todo
		$xmltmp =~ s/<,>/�A/g;						# �B�z <,>

		$xmltmp =~ s/&pic;/�i�ϡj/g;
		$xmltmp =~ s/&manysk;/�i���j/g;

		$xmltmp =~ s/&jing;/�i�g�j/g;
		$xmltmp =~ s/&lum;/�i�סj/g;
		
		$xmltmp =~ s/�i�T�j/�i���j�i���j�i���j/g;	# V1.93 �T�ܦ�������
		$xmltmp =~ s/&three_ver;/�i�T�j/g;	# V1.93 �T�ܦ�������,�Ĥ@�h������
		
		$notetmp =~ s/&pic;/�i�ϡj/g;
		$notetmp =~ s/&manysk;/�i���j/g;

		$notetmp =~ s/&jing;/�i�g�j/g;
		$notetmp =~ s/&lum;/�i�סj/g;
		
		$xmltmp =~ s/($big5)/&jap_rep($1)/eg;		# �N����ܦ� entity V1.93 (by ray)
		$xmltmp = rm_attr_entity($xmltmp);			# �N�ݩʸ̪� &xxx; ���� xxx V1.71
		$xmltmp = mv_type_l($xmltmp);				# �N <note type="l"> ���� <lem> �᭱ V1.71
		
		$xmltmp =~ s/<note/\n<note/g;				# ���X�}�G������
		$xmltmp =~ s/<sic/\n<sic/g;
		$xmltmp =~ s/<app/\n<app/g;
		$xmltmp =~ s/<foreign/\n<foreign/g;
		$xmltmp =~ s/<tt/\n<tt/g;
		
		#$xmltmp =~ s/\(\?\)/<todo\/>(?)/g;			# �B�z todo, V1.40 ��������
		print XMLOUT "\n\n<ID>$ID</ID>\n<XML>${xmltmp}\n</XML>\n<source>\n\t$notetmp\n</source>\n";
		if ($xml_err_msg{$ID})
		{
			print XMLOUT "<error>\n\t<line>$note_line{$ID}</line>\n\t<message>$xml_err_msg{$ID} ==> $notetmp</message>\n</error>";
			#print XMLOUT "$note_line{$ID}: error: $notetmp\n";
			print OUT "$note_line{$ID}: err: $xml_err_msg{$ID} ==> $notetmp\n" ;
		}
	}
	# print XMLOUT "$infile : found => �A\n\n";
	print OUT "$infile : found => \[\n\n";
	close XMLOUT;

	# �M²��аO���������g����~

	for(my $i=0; $i<= $#sutra_err; $i++)
	{
		print OUT $sutra_err[$i];
	}
	print OUT "$sutra : found => \[\n\n";

	# �հɻP�g�夣�k�X�����D

	for(my $i=0; $i<= $#both_sutra_note_err; $i++)
	{
		print OUT $both_sutra_note_err[$i];
	}

	# �� �Ÿ����հɨS������X�{
	
	print OUT "\n\n�� �H�U�O�o�ӲŸ��۪��հɨS������X�{�����D(�]�i��M�հɽs������) ��\n\n";
	foreach (keys(%eight_note))
	{
		print OUT "�� $_\n" if $eight_note{$_};
	}
	print OUT "\n�� == over == ��\n";
}

#######################################################################################
#
# �t�@�ǫ�B�z���ʧ@, �n�B�z���O $note_xml, �]�����Ǹ�ƬO�n�� xml ��l��Ƭd���~�వ
#
#######################################################################################

sub last_proce()
{
	my $ID = shift;

	# �B�z�@�ǩM�����P���妳�������D.
	# �p�G <lem> �O�� <note> �ҥ]�_�Ӫ�, ���� <rdg> �]�n��ӿ�z, ���D�� "����" , ���O <{ }> �ҬA�_�Ӫ�
	# ... �u�O���Y�j���@�ӳ��� .....
	
	if($note_xml{$ID} =~ /<lem[^>]*><note.*?<\/note><\/lem>/s)
	{
		while($note_xml{$ID} =~ /<rdg([^>]*>)(.*?)<\/rdg>/s)
		{
			my $rdg_head = $1;
			my $rdg_data = $2;
			my $rdg_data2 = $2;		# �ĤG��, �o�@�լO�n�N�̭��� note ����, �]�����ɷ|���� note �b�̭�
			
			$rdg_data2 =~ s/<note place="inline">(.*?)<\/note>/$1/g;	# �N�w���� note ������

			if($rdg_data2 =~ /^<{.*}>$/s)	# �����O����, ���n�z��
			{
				$rdg_data2 =~ s/^<{(.*)}>$/$1/s;
			}
			else
			{
				if($rdg_data2 =~ /^(.+)<{(.*)}>$/s)		# ��b�q�O����
				{
					$rdg_data2 = '<note place="inline">' . $1 . "</note>" . $2;
				}
				elsif ($rdg_data2 =~ /^<{(.*)}>(.+)$/s)		# �e�b�q�O����
				{
					$rdg_data2 = $1 . '<note place="inline">' . $2 . "</note>";
				}
				elsif ($rdg_data2 ne "&lac;")	# �S������, �B���O &lac;
				{
					$rdg_data2 = '<note place="inline">' . $rdg_data2 . "</note>";
				}
			}

			# ���N rdg ���� rrddgg , �H��A���^��.
			$note_xml{$ID} =~ s/<rdg\Q${rdg_head}${rdg_data}\E/<rrddgg${rdg_head}${rdg_data2}/;
		}
		$note_xml{$ID} =~ s/rrddgg/rdg/g;
	}
	$note_xml{$ID} =~ s/(<{)|(}>)//g;	# �̫��٬O�n�M������n
}

#######################################################################################
#
# �N�ݩʸ̪� &xxxx; ���� xxxx �N�n
#
#######################################################################################

sub rm_attr_entity()
{
	my $data = shift;
	my $big5_1='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x21])|(?:[\x23-\x7f]))';	# ���L " �Ÿ� \x22

	# �N�ݩʸ̪� &xxxx; �ܦ� xxxx �N�n. V1.71
	# V1.82 �ݩʤ��� &xxxx; �令 ��xxxx�F, �ӭ�ӭY�����h�令��big-amp�F

	my $head="";
	my $mid="";
	my $tail=$data;
	
	while($tail=~/^(.*?)<(.*?)>(.*)$/s)
	{
		$head .= $1;
		$mid = $2;
		$tail = $3;

		while($mid =~ /=\s*"${big5_1}*?��/)			# V1.82 �o�{�ݩʤ��� �� ���F��, ������ <&;>
		{
			$mid =~ s/(=\s*"${big5_1}*?)��/$1<&;>/;
		}
		$mid =~ s/<&;>/��big-amp�F/g;				# �A�N <&;> ���� ��big-amp�F

		while($mid =~ /=\s*"[^"]*?&[^"]*?;[^"]*?"/)	# �o�{�ݩʤ��� &xxx; ���F��
		{
			$mid =~ s/(=\s*"[^"]*?)&([^"]*?);([^"]*?")/$1��$2�F$3/;
		}

		$head = $head . "<" . $mid . ">";
	}

	$data = $head . $tail;
	return $data;
}

#######################################################################################
#
# <lem>...</lem>...<note .. type="l"> .... </note>
# �ܦ�
# <lem><note .. type="l"> .... </note>...</lem>...
#
#######################################################################################

sub mv_type_l()
{
	my $data = shift;
	my $tmp = "";

	if($data =~ /type="l"/)
	{	
		$data =~ s/(<note[^>]*type="l".*?<\/note>)//;
		$tmp = $1;
		$data =~ s/<lem>/<lem>$tmp/;
	}

	return $data;
}

###############################################
# ���ɻ~�r�ꪺ�k�䨺�@��
###############################################

sub get_corr_right()
{
	# �o�@�ծe�\�Ʀr, �]���ʦr�|���� :1: :2:
	
	my $loseb5='(?:(?:[\x80-\xff][\x40-\xff])|(?:&.*?;)|[\x21-\x3d]|[\x3f-\x40]|\x5c|[\x5e-\x60]|[\x7b-\x7f])';
	my $data = shift;
	
	if($data =~ />/)
	{
		# ���n�����զr��
		
		while($data =~ /^$big5*?\[($losebig5+?)\]/)
		{
			 $data =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
		}
		
		#�Ʀr�]�n����  V1.30
		
		$data =~ s/\[(\d{2,3})\]/:1:$1:2:/g;
		
		$data =~ s/\[$loseb5*?>>($loseb5*?)\]/$1/g;
		$data =~ s/\[$loseb5*?>($loseb5*?)\](?:<[^>]*resp[^>]*>)?/$1/g;
		$data =~ s/:1:/\[/g;
		$data =~ s/:2:/\]/g;
	}
	
	return $data;
}

###############################################
# ���ɻ~�r�ꪺ���䨺�@��, �]���n�٭즨��l�����p
###############################################

sub get_corr_left()
{
	# �o�@�ծe�\�Ʀr, �]���ʦr�|���� :1: :2:
	
	my $loseb5='(?:(?:[\x80-\xff][\x40-\xff])|(?:&.*?;)|[\x21-\x3d]|[\x3f-\x40]|\x5c|[\x5e-\x60]|[\x7b-\x7f])';
	my $data = shift;
	
	if($data =~ />/)
	{
		# ���n�����զr��
		
		while($data =~ /^$big5*?\[($losebig5+?)\]/)
		{
			 $data =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
		}
		
		#�Ʀr�]�n����  V1.30
		
		$data =~ s/\[(\d{2,3})\]/:1:$1:2:/g;
		
		$data =~ s/\[($loseb5*?)>>$loseb5*?\]/$1/g;
		$data =~ s/\[($loseb5*?)>$loseb5*?\](?:<[^>]*resp[^>]*>)?/$1/g;
		$data =~ s/:1:/\[/g;
		$data =~ s/:2:/\]/g;
	}
	
	return $data;
}

###############################################
# �N�հɪ���ڤ�зǤ�
###############################################

sub sk_pali_normalize()
{
	foreach my $key (keys(%note_spell))
	{
		$note_spell{$key} = sp_pali_to_CB($note_spell{$key});
	}
}

###############################################
# �N��ڤ�зǤ�
###############################################

sub sp_pali_to_CB()
{
	#$subpat = '[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|\[[0-9�][0-9�]\]|[\'`Aa\.\^iu~][AadhilmnrstuS]|[\x00-\xff\n]';
	my $subpat = '[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|\[[0-9�][0-9�]\]|aa|AA|ii|uu|\'s|[`\.\^~][AaDdhiLlmNnrSsTtu]|[\x00-\xff\n]';

	my @chars;	# ���ƪ����|

	local $_ = shift;

	push(@chars, /$subpat/g);
	foreach my $var (@chars){
		$var = $s2ref{$var} if ($s2ref{$var} ne "");
	}
	return join("", @chars);
}

###############################################
# �N�ʦr���Ū�J
###############################################

sub readGaiji()
{
	my $cb;
	my $zu;
	my $ent;
	#my $mojikyo;
	#my $uni;
	#my $ty;
	my %row;
	use Win32::ODBC;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow())
	{
		%row = $db->DataHash();

		$cb      = $row{"cb"};			# cbeta code
		#$mojikyo = $row{"mojikyo"};	# mojikyo code
		$zu      = $row{"des"};			# �զr��
		$ent     = $row{"entity"};		# �u�Φb�q�ε� (CIxxxx)
		#$uni     = $row{"uni"};
		#$ty      = $row{"nor"};		# �q�Φr

		next if ($cb =~ /^#/);

		#$ty = "" if ($ty =~ /none/i);
		#$ty = "" if ($ty =~ /\x3f/);

		#die "ty=[$ty]" if ($ty =~ /\?/);

		#$gaiji_nr{$ent} = $ty;
		$gaiji_cb{$zu} = $cb;
		if($ent =~ /^CI\d+/)	# ��ܳo�O�q�ε�
		{
			$gaiji_zu{$ent} = $zu;
		}
		#$gaiji_ent{$cb} = $ent;
	}
	$db->Close();
	print STDERR "ok\n";
}

###############################################
# �N�հɪ��ʦr����&CB�X�зǮ榡
###############################################

sub note_gaiji_normalize()
{
	local $_ = shift;
	my $key;
	
	foreach $key (keys(%note))
	{
		$note{$key} = loseword_to_CB($note{$key});
	}
	foreach $key (keys(%note_old))
	{
		$note_old{$key} = loseword_to_CB($note_old{$key});
	}
	foreach $key (keys(%note_new))
	{
		$note_new{$key} = loseword_to_CB($note_new{$key});
	}
	foreach $key (keys(%modify_stack))
	{
		$modify_stack{$key} = loseword_to_CB($modify_stack{$key});
	}
	foreach $key (keys(%orig_stack))
	{
		$orig_stack{$key} = loseword_to_CB($orig_stack{$key});
	}
	foreach $key (keys(%note_stack))
	{
		$note_stack{$key} = loseword_to_CB($note_stack{$key});
	}
}

###############################################
# �N�ʦr���� CB �X
###############################################

sub loseword_to_CB()
{
	my $tail = shift;
	my $head = "";
	my $mid;

	# �B�z�q�ε�

	$tail =~ s/����\[�I\/��\]\[�I\/��\]/\&CI0013\;/g;		# �o�Ӥ���S�O, �n���B�z

	foreach my $key (keys(%gaiji_zu))
	{
		$tail =~ s/\Q$gaiji_zu{$key}\E/\&$key\;/g;
	}

	# �B�z�q�Φr

	$head = "";
	while($tail =~ /^($big5*?)(\[$losebig5+?\])(.*\n?)/)
	{
		$head .= $1;
		$mid = $2;
		$tail = $3;
		
		my $cb = $gaiji_cb{$mid};
		if ($cb eq "")
		{
			print OUT "�զr�� $mid �S�� CB �X\n";
		}
		else
		{
			$mid = '&CB' . $cb . ';';
		}
		$head .= $mid;
	}
	$tail = $head . $tail;
	
	# �B�z�S�� Big5 �r
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M024261;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M040426;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M034294;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M005505;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M010527;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M026945;";
		$tail = $2;
	}
	$tail = $head . $tail;
	
	$head = "";
	while($tail =~ /^($big5*?)��(.*\n?)/)
	{
		$head = $head . $1 . "&M006710;";
		$tail = $2;
	}
	$tail = $head . $tail;

	return $tail;
}

###############################################
# �N�p�A���ܦ� <note place="inline">..</note>
###############################################

sub note_inline_normalize()
{
	local $_ = shift;
	my $key;
	my $purebig5='(?:(?:[\xa1-\xfe][\x40-\xfe])|(?:&[^;]*;)|(?:<[,t]>))';	# ����, �ʦr, <,>, <t>
	
	# print OUT "\n\n�� �o���U����ƬO���A���o�S���ܦ� <note place=\"inline\"> ���榡 ��\n\n";
	foreach $key (keys(%note))
	{
		$note{$key} =~ s/\(($purebig5*?)\)/<note place="inline">$1<\/note>/g;
		# print OUT "�� $note{$key}\n" if $note{$key}=~ /\([^\)]*?$purebig5+[^\)]*?\)/;
	}
	foreach $key (keys(%note_old))
	{
		$note_old{$key} =~ s/\(($purebig5*?)\)/<note place="inline">$1<\/note>/g;
		# print OUT "�� $note_old{$key}\n" if $note_old{$key}=~ /\([^\)]*?$purebig5+[^\)]*?\)/;
	}
	foreach $key (keys(%note_new))
	{
		if($interlinear{$key} == 1)		# ����
		{
			$note_new{$key} =~ s/\(($purebig5*?)\)/<note place="interlinear">$1<\/note>/g;
		}
		else
		{
			$note_new{$key} =~ s/\(($purebig5*?)\)/<note place="inline">$1<\/note>/g;
		}
		
		# print OUT "�� $note_new{$key}\n" if $note_new{$key}=~ /\([^\)]*?$purebig5+[^\)]*?\)/;
	}
	# print OUT "\n�� ==== over ==== ��\n\n";
}

##############################################
# �t�X XML �g����ˬd�ݬ�
##############################################

sub check_with_xmls()
{
	my $file;
	my @files = <${xml_dir}*.xml>;
	
	$note_count = 0;				# �հɼƥ�
	$note_found_count = 0;			# �հɯ�B�z���ƥ�
	$note_no_found_count = 0;		# �հɤ���B�z���ƥ�
	$note_star_count = 0;			# �P���ƥ�
	$note_star_found_count = 0;		# �P����B�z���ƥ�
	
	open XMLLOGOUT, ">$xmllogout" || die "open $xmllogout error!";
	foreach $file (sort(@files))
	{
		print "run $file\n" if $DEBUG;
		check_with_xml($file);
	}
	$note_found_count = $note_count - $note_no_found_count;
	print XMLLOGOUT "\n\n�@���հ� $note_count ��\n";
	print XMLLOGOUT "���Q���հ� $note_found_count ��\n";
	# print XMLLOGOUT "�հɬP���@�� $note_star_count ��\n";
	
	close XMLLOGOUT;
}

######################################################
# ��Ƶ��c�ܭ��n, �]�����I����
#
# xml ���, �̦h�B�z 5 ��
#
# �� $i   ��: $pre_anchor <anchor...> $anchor_ok....($anchor_doing) $anchor_other
# �� $i+1 ��: ......
# .....
# �� $i+5 ��: 
#
# ���Ϊ����
#
# xxx...xxx 
#
# $word_old_head, $word_old_tail; $word_old_mid �h�O���b�B�z�� "�r"
#
#	##################### �B�z��ƪ��ܼ�
#	my @xmls;			# xml �����g��
#	my $pre_anchor; 	# <anchor �аO���e���r
#	my $anchor_ok;		# <anchor �аO����w�T�w���r
#	my $anchor_other;	# �٨S�B�z�����
#	
#	my note_old_head;	# �հɱ��ؤ�, ��l�g�媺�e�b�q
#	my note_old_tail;	# �հɱ��ؤ�, ��l�g�媺��b�q
######################################################

sub check_with_xml()
{
	local $_;
	my $file = shift;

	my $n_x;	# �P�_�O�հɼƦr�άP�� (n �O�Ʀr, x �O�P��)
	my $ID;		# �հɪ��ߤ@�s��
	
	open XMLIN, $file;
	@xmls = <XMLIN>;
	close XMLIN;

	for(my $i = 0 ; $i <= $#xmls ; $i++)
	{
		if($xmls[$i] =~ /^\s*<!--\s*$/)
		{
			while($xmls[$i] !~ /^\s*-->\s*$/)
			{
				$i++
			}
			next;
		}
		
		# <lb n="0001a19"/>�W�C�}<anchor id="fnT01p0001a07"/>�R�׳~�C�ҰO�����C�G�H�����ءC��
		# <lb n="0001a20"/>����̡C���g�y��C������<anchor id="fxT01p0001a1"/>��C��p�ީ]�C��
		# while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([nx])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/)

		while ($xmls[$i] =~ /(.*?)<anchor\s+id="f([n])T\d\dp(\d{4}).(\d{1,3})"\/>(.*\n?)$/) 	# ���B�z n
		{
			$pre_anchor = $1;
			$n_x = $2;
			$ID = $3;

			my $IDtmp = $4;
			$anchor_other = $5;

			if ($n_x eq "n")		# �հ�
			{
				$note_count++;
				$IDtmp = "00".$IDtmp if length($IDtmp) == 1;
				$IDtmp = "0".$IDtmp if length($IDtmp) == 2;
				$ID = $ID.$IDtmp;
=begin
				if ($i >= 4990)
				{
					my $debug_ = 1;
				}
=end
=cut
				
#=begin
				if ($ID eq "0751001")
				{
					my $debug_ = 1;
				}
#=end
#=cut

				# �B�z�G�Ӥ��Ÿ� V1.78

				if($file =~ /T21n1203/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�ϡj/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�Сj/g;
				}
				elsif($file =~ /T21n1205/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�ϡj/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�Сj/g;
				}
				elsif($file =~ /T21n1249/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�ϡj/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�Сj/g;
				}
				elsif($file =~ /T40n1816/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�ϡj/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�Сj/g;
				}
				elsif($file =~ /T40n1819/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�ϡj/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�Сj/g;
				}
				elsif($file =~ /T44n1840/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�ϡj/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�Сj/g;
				}
				elsif($file =~ /T45n1898/)
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�H�j/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�R�j/g;
				}
				else
				{
					$note_xml{$ID} =~ s/�i�H�ϡj/�i�H�j/g;
					$note_xml{$ID} =~ s/�i�H�Сj/�i�H�j/g;
				}
				
				# V1.90 �B�z�i�g�j�i�סj���l�r
				
				$note_xml{$ID} =~ s/&jing;/�i�g�j/g;
				$note_xml{$ID} =~ s/&lum;/�i�סj/g;	
				$note_old{"${ID}_1"} =~ s/&jing;/�i�g�j/g;
				$note_old{"${ID}_1"} =~ s/&lum;/�i�סj/g;	
				
				# ���B�z�L�k�B�z��, �]�N�O�s�� 8,9,10,11,13,14,999
				
				if($note_form{"${ID}_1"} == 8 || $note_form{"${ID}_1"} == 9 || $note_form{"${ID}_1"} == 10 || $note_form{"${ID}_1"} == 11 || $note_form{"${ID}_1"} == 13 || $note_form{"${ID}_1"} == 14 || $note_form{"${ID}_1"} == 999)
				{
					# �N�g�媺 <anchor> �аO���� xml �����հɱ���
					$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>/$note_xml{$ID}/;
					next;
				}
				
				# �B�z�հɱ��ت��g��
				
				$note_old_head = $note_old{"${ID}_1"};
				$note_old_tail = "";

				# �B�z�ɻ~

				while($note_old_head =~ /^($big5*?)\[($big5*?)>($big5*?)\]/)
				{
					$note_old_head =~ s/^($big5*?)\[(?:$big5*?)>($big5*?)\](?:<[^>]*resp[^>]*>)?/$1$2/;		# �����B�z�ɻ~�����
				}

				if($note_old_head =~ /^(.*?)�K(.*)$/)
				{
					$note_old_head = $1;
					$note_old_tail = $2;
					if($note_old_tail eq "")	# ���ǥu�� ... ���S���᭱����� v1.39
					{
						$note_old_tail = "&noword;";		# �ȮɥΪ�
					}
				}
				
				### �}�l����, ���F�n�N�հɱ��ش��J xml ######################################

				# �̼зǪ��X�����
				
				if($note_old_head eq "" and $note_old_tail eq "")	
				{
					# �S���d�� (�i��O���J�r), �N�������� xml �X
					$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>/$note_xml{$ID}/;
					next;
				}
				elsif($anchor_other =~ /^(\Q$note_old_head\E)/ and $note_old_tail eq "")	
				{
					# ��²�檺�@��, �@�U�N���F.
					# ���P�_�O���O���
					
					if($note_xml{$ID} =~ /<sic/)		# sic ������ (�]�� sic �|�]�b lem �̭�, �ҥH�n�b�e��)
					{
						$note_xml{$ID} =~ s/(<sic[^>]*>).*?<\/sic>/$1$note_old_head<\/sic>/;
					}					
					elsif($note_xml{$ID} =~ /<lem>/)	# ���O�±��
					{
						# ���N�հɱ��ت��g�崫���зǪ�
						$note_xml{$ID} =~ s/<lem>.*?<\/lem>/<lem>$note_old_head<\/lem>/;
					}
					else		# �J���ª�����ഫ�F
					{
						# ���N�հɱ��ت��g�崫���зǪ�
						$note_xml{$ID} =~ s/(<t lang="chi"[^>]*>).*?<\/t>/$1$note_old_head<\/t>/;
					}
					
					# �A���� xml �g�夤
					$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>\Q$note_old_head\E/$note_xml{$ID}/;
					next;
				}
				else			# ���p�����F, �L�k���Q���J, �ε���
				{					
=begin
					/* �o�q���, �����b do_compare �B�z
					
					# ahchor_other �����^  n ����, �ó]�@�Ǫ��
					for(my $j = 1; $j<$max_line_xml; $j++)
					{
						if($i+$j <= $#xmls)
						{
							$anchor_other .= $xmls[$i+$j];
						}
					}
					*/
=end
=cut
					# �γo�ӰƵ{���Ӥ��, �Ǧ^ 1 ��ܳ��B�z ok �F
					# �n�ǤJ�ثe�b xml �����
					
					$anchor_ok = "";
					$note_word_num{$ID} = cn2an($note_word_num{$ID});
					$note_word_num = $note_word_num{$ID};
					$xml_start_line = $i;
					$xml_now_line = $i;
					$xml_word_num = 0;			# �Ҩ��o���r��
					$xml_last_word_num = 0;		# �̫�@���X�檺�r��, xml �Ҩ��X���Ʀr, �t�X [xx...xx]xx�r ���p��Ʀr�Ϊ�
					@xml_tag_stack = ();
					$xml_err_message = "";		# ��@�ǥi���\���~�T��
					$xml_pure_data = "";		# �h���аO�����誺�¤�r���
					
					if(do_compare())			# �i����
					{
						# ���F, �����@�w����, �n�ˬd $xml_err_message , �p���D�|�b�o�̤����X��
						# ���P�_�O���O���
					
						if($note_xml{$ID} =~ /<sic/)		# sic ������, �b lem ���e, �]���i��Q�]�b lem ����
						{
							$note_xml{$ID} =~ s/(<sic[^>]*>).*?<\/sic>/$1$anchor_ok<\/sic>/;
							#�[�J���U�T��
							if ($xml_err_message)
							{
								if($note_xml{$ID} =~ /xxxx=".*?"/)
								{
									$note_xml{$ID} =~ s/xxxx="(.*?)"/xxxx="$1; $xml_err_message"/;
								}
								else
								{
									$note_xml{$ID} =~ s/(<sic[^>]*)>/$1 xxxx="$xml_err_message">/;
								}
							}
						}
						elsif($note_xml{$ID} =~ /<lem>/)	# ���O�±��
						{
							# ���N�հɱ��ت��g�崫���зǪ�
							$note_xml{$ID} =~ s/<lem>.*?<\/lem>/<lem>$anchor_ok<\/lem>/;
							
							# �p�G�� �K ���Ÿ�, �h�[�W���հɦb�g�媺�ƥ�, ���H�i�H�P�_ V1.91
							if ($xml_word_num > 0 and $note_old_tail ne "")
							{
								$note_xml{$ID} =~ s/(<app[^>]*)>/$1 word-count="$xml_word_num">/;
							}
							
							#�[�J���U�T��
							if ($xml_err_message)
							{
								if($note_xml{$ID} =~ /xxxx=".*?"/)
								{
									$note_xml{$ID} =~ s/xxxx="(.*?)"/xxxx="$1; $xml_err_message"/;
								}
								else
								{
									$note_xml{$ID} =~ s/(<app[^>]*)>/$1 xxxx="$xml_err_message">/;
								}
							}
						}
						else		# �J���ª�����ഫ�F
						{
							# �p�G�� �K ���Ÿ�, �h�[�W���հɦb�g�媺�ƥ�, ���H�i�H�P�_ V1.91
							if ($xml_word_num > 0 and $note_old_tail ne "")
							{
								$note_xml{$ID} =~ s/(<tt [^>]*)>/$1 word-count="$xml_word_num">/;
							}
								
							# ���N�հɱ��ت��g�崫���зǪ�
							if ($xml_err_message)
							{
								# �n�[�@�ǻ��U�T��
								$note_xml{$ID} =~ s/(<t lang="chi"[^>]*)>.*?<\/t>/$1 xxxx="$xml_err_message">$anchor_ok<\/t>/;
							}
							else
							{
								$note_xml{$ID} =~ s/(<t lang="chi"[^>]*>).*?<\/t>/$1$anchor_ok<\/t>/;
							}
						}
						
						# �A�N�B�z�n�� n ���^�h xml ��
						
						$anchor_ok = $pre_anchor . $note_xml{$ID} . $anchor_other;
						for(my $j = 0; $j<$max_line_xml; $j++)
						{
							if($anchor_ok =~ s/^(.*\n)//)
							{
								$xmls[$i+$j] = $1;
							}
						}
						
						next;
					}
					else
					{
						# ��b�䤣��ǰt���a��
						if($note_xml{$ID} =~ /<sic/)		# sic ������, �b lem ���e, �]���i��Q�]�b lem ����
						{
							$note_xml{$ID} =~ s/(<sic[^>]*)>/$1 xxxx="�L�k�b xml �ɧ�쥿�T���d��; $xml_err_message">/;
						}
						elsif($note_xml{$ID} =~ /<lem>/)
						{
							$note_xml{$ID} =~ s/(<app n=".*?"[^>]*)/$1 xxxx="�L�k�b xml �ɧ�쥿�T���d��; $xml_err_message"/;
						}
						else
						{
							$note_xml{$ID} =~ s/(<tt n=".*?" type="app"[^>]*)/$1 xxxx="�L�k�b xml �ɧ�쥿�T���d��; $xml_err_message"/;
						}
						$xmls[$i] =~ s/<anchor\s+id="fnT\d\dp\d{4}.\d{1,3}"\/>/$note_xml{$ID}/;
						# �ÿ�X���~���i
						print XMLLOGOUT "$ID: $note_old_head <==> $xmls[$i]";
						$note_no_found_count++;
					}
				}
			}
			else		# �հɼƦr
			{
				$note_star_count++;
			}
			# $xmls[$i] =~ s/anchor//;		# �M�����հ�
		}
	}
}

########################
# ���ѴN�Ǧ^ 0
########################

sub do_compare()
{
	my $note_old_head1 = "";
	my $note_old_head2 = $note_old_head;
	my $note_old_tail1 = "";
	my $note_old_tail2 = $note_old_tail;
	my $note_old_mid = "";

	# ����e�������@��

	while($note_old_head2 ne "")
	{
		# ���@�Ӧr(�� patten )��J anchor_doing ��, �ۤv�]�|���
		$note_old_mid = get_a_pattern(\$note_old_head2);
		$note_old_head1 .= $note_old_mid;
		
		# �Y�䤣�� pattern �N�Ǧ^ 0
		return 0 if(!find_the_pattern($note_old_mid));
	}

	# �Y�S�ĤG��, �h����
	if($note_old_tail eq "")
	{
		# ���P�_�@�U�O�_�������Ϊ��аO
		
		if($#xml_tag_stack >= 0)	# �٦��аO�n���X��
		{
			get_other_tag();
		}
		return 1 ;
	}
	
	# �ܦ���ܦ��ĤG��
	
	return 0 if(!do_compare_tail());	# �Y�䤣����h����

	# �ܦ�, ���\�F
	# ���P�_�@�U�O�_�������Ϊ��аO, 
	if($#xml_tag_stack >= 0)	# �٦��аO�n���X��
	{
		get_other_tag();
	}
	return 1 ;
}

#####################################################

sub do_compare_tail
{
	#my $note_old_mid = shift;
	my $anchor_doing = "";
	my $pattern = '(?:(?:�i�ϡj)|(?:�i�g�j)|(?:�i�סj)|(?:[\xa1-\xfe][\x40-\xfe])|&[^;]*;|<[^>]*>|[\x00-\xff\n])';
	my $pass = '(?:�C|�D|�@|\xa1\x5d|\xa1\x5e|\n)';	# ���I�δ���i�H�q�L�@�@# V1.83�] (a15d) �� �^(a15e) ����r
	my $tag = '(?:<[^>]*>)';		# �аO, �i�H�q�L
	#my $tag_head = '(?:<[^>]*[^\/]>)';		# �Y�аO
	#my $tag_tail = '(?:<\/[^>]*>)';		# ���аO
	
	while(($anchor_other ne "") or ($xml_now_line != $#xmls))	# ����٨S����
	{
		while($anchor_other eq "")	# �S��ƤF, ���U��
		{
			if($xml_now_line != $#xmls)
			{
				$xml_now_line++;
				$anchor_other .= $xmls[$xml_now_line];
			}
			else
			{
				$xml_err_message .= "�S����ƤF; ";
				return 0;	# �S��ƤF, ���઱�F
			}
		}
		
		$anchor_other =~ s/^($pattern)//;	# ���@�� pattern �X��
		$anchor_doing = $1;

		if($anchor_doing =~ /$pass/)			# �����n���r�N�S���Y, ���L�h
		{
			$anchor_ok .= $anchor_doing;
		}
		elsif($anchor_doing =~ /$tag/)			# �J��F�аO
		{
			# V1.38 �����o�@�ت�
			#if($multi_anchor == 0 and $anchor_doing =~ /anchor\s+id\s*=\s*"fn/)		# v1.35 + V1.36
			#{
			#	$xml_err_message .= "�J��U�@�ժ� anchor, �ҥH����; ";
			#	return 0;
			#}

			$anchor_ok .= $anchor_doing;

			if($anchor_doing =~ /<[^>]*\/>/)	# �J��F�W�߼аO
			{ #���ޥ�
			}
			elsif($anchor_doing =~ /<([^\/][^>]*)>/)	# �J��F�_�l�аO
			{
				my $tmp = $1;
				$tmp =~ s/(\S*)\s*.*/$1/;
				push(@xml_tag_stack, $tmp);		# �N�аO���J���|
			}
			elsif($anchor_doing =~ /<\/([^>]*)>/)	# �J��F�����аO
			{
				my $tmp = $1;
				my $tmp2 = pop(@xml_tag_stack);		# ���X�аO���
				if($tmp ne $tmp2)				# �����D, tag �S������
				{
					if($tmp2)
					{
						$xml_err_message .= "���ӬO</$tmp2>�o�J��</$tmp>; ";
						push(@xml_tag_stack, $tmp2);	
					}
					else
					{
						$xml_err_message .= "�h�F�@��</$tmp>; ";
					}
				}
			}
		}
		else	# ����F�@�몺�r
		{
=begin
			�ˬd��k
			1.�r�ƦX, ��ƹ�, �@�� ok.
			2.�r�ƤӦh, ��Ƥ���, ����
			3.�r�ƤӦh, ��ƹ�, �O���å���
			4.�r�ƤӤ�, ��Ƥ���, �~��
			5.�r�ƤӤ�, ��ƹ�, �O�����~��
			6.�L�r��, ��ƹ�, ok
			7.�L�r��, �W�L n �r, ����
=end
=cut

			#my $tmp_anchor_ok = $anchor_ok . $anchor_doing;
			#my $tmp_pure_data = $xml_pure_data . $anchor_doing;
			
			$anchor_ok .= $anchor_doing;
			$xml_pure_data .= $anchor_doing;
			if($anchor_doing eq "&CI0013;")		# &CI0013; = ����[�I/��][�I/��], �|�Ӧr.
			{
				$xml_word_num = $xml_word_num + 4;
			}
			elsif($anchor_doing =~ /&CI.*?;/)	# �զX�r
			{
				$xml_word_num = $xml_word_num + 2;
			}
			#elsif($anchor_doing !~ /\xa1[\x5d\x5e]/)	# V1.83�] (a15d) �� �^(a15e) ����r
			else
			{
				$xml_word_num++;
			}
			my $note_old_tail2 = $note_old_tail;
			$note_old_tail2 =~ s/<\/note>$//;
			
			if($note_word_num == 0)		# �S�O���r��
			{
				if($xml_pure_data =~ /\Q${note_old_tail2}\E$/)	# �k�X, ���Ǹ�Ʒ|�� </note> ����
				{	
					$xml_err_message .= "���F,�ŦX�r�Ƭ�$xml_word_num,���ˬd; ";
					return 1;
				}
				else	# �~��V�O�a, �Y�W�L�Y�r�ƭn��, �N�g�b�o��
				{
					if($xml_word_num >= 200)
					{
						$xml_err_message .= "�W�L$xml_word_num�r�F�٧䤣�����; ";
						return 0;
					}
				}
			}
			else		# ���O���r��
			{
				if(($note_word_num == $xml_word_num) and ($note_old_tail2 eq "&noword;"))
				{
					return 1;					# �S��, �� ... ���S���̫᪺�r, �u���r��. V1.39
				}
				elsif($xml_pure_data =~ /\Q${note_old_tail2}\E$/)	# ���O���r��, �B��Ƨk�X
				{
					if($note_word_num == $xml_word_num)			# �̼зǪ�
					{
						return 1;
					}
					elsif($note_word_num > $xml_word_num)		# ���F, ���r�Ƥ���, �~��
					{
						$xml_last_word_num = $xml_word_num;
					}
					else		# ���F, ���r�ƶW�L, �O���a
					{
						$xml_err_message .= "���F,���r�ƬO$xml_word_num,�z�פW���ӬO$note_word_num; ";
						return 1;
					}
				}
				else				# ���O���r��, ���٨S��Ƨk�X
				{
					if($note_word_num <= $xml_word_num-20 )			# �p�G�W�L�r�ƤӦh, �N����a!
					{
						if($xml_last_word_num)
						{
							$xml_err_message .= "���ӬO$note_word_num,���ڤw�W�L$xml_word_num�F,�٧䤣��,���L�b$xml_last_word_num�r�o���ŦX�����,�Ф�ʳB�z; ";
						}
						else
						{
							$xml_err_message .= "���ӬO$note_word_num,���ڤw�W�L$xml_word_num�F,�٧䤣��,�Ф�ʳB�z; ";
						}
						return 0;
					}
				}
			}
		}
	}
	$xml_err_message .= "�S����ƤF; ";
	return 0;	# �S��ƤF; ��򪱤U�h?
}

#####################################################
# ���X�̫᪺�аO, �]�����ǼаO�����ڤ]�n���X��
#####################################################

sub get_other_tag
{
	#my $note_old_mid = shift;
	my $anchor_doing;
	my $pattern = '(?:(?:�i�ϡj)|(?:�i�g�j)|(?:�i�סj)|(?:[\xa1-\xfe][\x40-\xfe])|&[^;]*;|<[^>]*>|[\x00-\xff\n])';
	my $pass = '(?:�C|�D|�@|\xa1\x5d|\xa1\x5e|\n)';	# ���I�δ���i�H�q�L�@�@# V1.83�] (a15d) �� �^(a15e) ����r
	my $tag = '(?:<[^>]*>)';				# �аO, �i�H�q�L
	#my $tag_head = '(?:<[^>]*[^\/]>)';		# �Y�аO
	#my $tag_tail = '(?:<\/[^>]*>)';		# ���аO
	
	while(($anchor_other ne "") or ($xml_now_line != $#xmls))	# ����٨S����
	{
		while($anchor_other eq "")	# �S��ƤF, ���U��
		{
			if($xml_now_line != $#xmls)
			{
				$xml_now_line++;
				$anchor_other .= $xmls[$xml_now_line];
			}
			else
			{
				$xml_err_message .= "�S����ƤF,���ٯʼаO; ";
				return 1;	# �S��ƤF, ���઱�F (�]���u�O��аO, �ҥH�٬O�Ǧ^ 1)
			}
		}
		
		$anchor_other =~ s/^($pattern)//;	# ���@�� pattern �X��
		$anchor_doing = $1;

		if($anchor_doing =~ /$pass/)			# �����n���r�N�S���Y, ���L�h
		{
			$anchor_ok .= $anchor_doing;
		}
		elsif($anchor_doing =~ /$tag/)			# �J��F�аO
		{
			if($anchor_doing =~ /anchor\s+id\s*=\s*"fn/)		# v1.35 + V1.36 + V1.38	(�u���b get other tag ��, �Y�J�� anchor �~����
			{
				$xml_err_message .= "�J��U�@�ժ� anchor, �ҥH����; ";
				return 0;
			}
			$anchor_ok .= $anchor_doing;
			
			if($anchor_doing =~ /<[^>]*\/>/)	# �J��F�W�߼аO
			{ #���ޥ�
			}
			elsif($anchor_doing =~ /<([^\/][^>]*)>/)	# �J��F�_�l�аO
			{
				my $tmp = $1;
				$tmp =~ s/(\S*)\s*.*/$1/;
				push(@xml_tag_stack, $tmp);		# �N�аO���J���|
			}
			elsif($anchor_doing =~ /<\/([^>]*)>/)	# �J��F�����аO
			{
				my $tmp = $1;
				my $tmp2 = pop(@xml_tag_stack);		# ���X�аO���
				if($tmp ne $tmp2)				# �����D, tag �S������
				{
					if($tmp2)
					{
						$xml_err_message .= "���ӬO</$tmp2>�o�J��</$tmp>; ";
						push(@xml_tag_stack, $tmp2);	
					}
					else
					{
						$xml_err_message .= "�h�F�@��</$tmp>; ";
					}
				}
				
				return 1 if ($#xml_tag_stack < 0);
			}
		}
		else	# ����F�@�몺�r
		{
			my $tmp2 = pop(@xml_tag_stack);
			$xml_err_message .= "�֤F�аO</$tmp2>; ";
			return 1; 	#(�]���u�O��аO, �ҥH�٬O�Ǧ^ 1)
		}
	}
	$xml_err_message .= "�S����ƤF,���ٯʼаO; ";
	return 1;	# �S��ƤF; ��򪱤U�h? (�]���u�O��аO, �ҥH�٬O�Ǧ^ 1)
}

#####################################################

sub get_a_pattern()
{
	my $note_old = shift;		# �p��, �ǤJ���O����
	my $pattern = '(?:[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|[\x00-\xff\n])'; 	# �ʦr�n�B�z
	
	$$note_old =~ s/^($pattern)//;
	return $1;
}

#####################################################
#
# �b anchor_other ����. ��쪺�|��b anchor_ok ����
#
#####################################################

sub find_the_pattern()
{
	my $note_old_mid = shift;
	my $anchor_doing;
	my $pattern = '(?:(?:�i�ϡj)|(?:�i�g�j)|(?:�i�סj)|(?:[\xa1-\xfe][\x40-\xfe])|&[^;]*;|<[^>]*>|[\x00-\xff\n])';
	my $pass = '(?:�C|�D|�@|\xa1\x5d|\xa1\x5e|\n)';	# ���I�δ���i�H�q�L�@�@# V1.83�] (a15d) �� �^(a15e) ����r
	my $tag = '(?:<[^>]*>)';				# �аO, �i�H�q�L
	#my $tag_head = '(?:<[^>]*[^\/]>)';		# �Y�аO
	#my $tag_tail = '(?:<\/[^>]*>)';		# ���аO
	
	while(($anchor_other ne "") or ($xml_now_line != $#xmls))	# ����٨S����
	{
		while($anchor_other eq "")	# �S��ƤF, ���U��
		{
			if($xml_now_line != $#xmls)
			{
				$xml_now_line++;
				$anchor_other .= $xmls[$xml_now_line];
			}
			else
			{
				return 0;	# �S��ƤF, ���઱�F
			}
		}
		
		$anchor_other =~ s/^($pattern)//;	# ���@�� pattern �X��
		$anchor_doing = $1;

		if($anchor_doing eq $note_old_mid)		# bingo
		{
			$anchor_ok .= $anchor_doing;
			if($anchor_doing =~ /<note place="(?:(?:inline)|(?:interlinear))">/)		# ���i��O <note place="inline">
			{
				push(@xml_tag_stack, "note");
			}
			elsif($anchor_doing =~ /<\/note>/)		# ���i��O </note>	v1.32
			{
				my $tmp = "note";
				my $tmp2 = pop(@xml_tag_stack);		# ���X�аO���
				if($tmp ne $tmp2)				# �����D, tag �S������
				{
					if($tmp2)
					{
						$xml_err_message .= "���ӬO</$tmp2>�o�J��</$tmp>; ";
						push(@xml_tag_stack, $tmp2);	
					}
					else
					{
						$xml_err_message .= "�h�F�@��</$tmp>; ";
					}
				}
			}
			else
			{
				$xml_pure_data .= $anchor_doing;
				if($anchor_doing eq "&CI0013;")		# &CI0013; = ����[�I/��][�I/��], �|�Ӧr.
				{
					$xml_word_num = $xml_word_num + 4;
				}
				elsif($anchor_doing =~ /&CI.*?;/)	# �զX�r
				{
					$xml_word_num = $xml_word_num + 2;
				}
				#elsif($anchor_doing !~ /\xa1[\x5d\x5e]/)	# V1.83�] (a15d) �� �^(a15e) ����r
				else
				{
					$xml_word_num++;
				}
			}
			return 1;
		}
		elsif ($anchor_doing =~ /<figure/i and $note_old_mid eq "&pic;")		# V1.65 �B�z�ϫ�������(�@)
		{
			$anchor_ok .= $anchor_doing;
			if($anchor_doing =~ /<([^>]*[^\/])>/)	# �J��F�D�W�߼аO, �]�� figure ���W�߻P�D�W��
			{
				my $tmp = $1;
				$tmp =~ s/(\S*)\s*.*/$1/;
				push(@xml_tag_stack, $tmp);		# �N�аO���J���|				
			}
			return 1;
		}
		elsif ($anchor_doing eq "�i�ϡj" and $note_old_mid eq "&pic;")		# V1.65 �B�z�ϫ�������(�G)
		{
			$anchor_ok .= $anchor_doing;
			# $xml_word_num = $xml_word_num+3;
			$xml_pure_data .= $anchor_doing;
			return 1;
		}		
		else
		{
			if($anchor_doing =~ /$pass/)			# �����n���r�N�S���Y, ���L�h
			{
				$anchor_ok .= $anchor_doing;
			}
			elsif($anchor_doing =~ /$tag/)			# �J��F�аO
			{
				# V1.38 �����o�@�ت�
				#if($multi_anchor == 0 and $anchor_doing =~ /anchor\s+id\s*=\s*"fn/)		# v1.33 + V1.36
				#{
				#	$xml_err_message .= "�J��U�@�ժ� anchor, �ҥH����; ";
				#	return 0;
				#}
				$anchor_ok .= $anchor_doing;
				
				if($anchor_doing =~ /<[^>]*\/>/)	# �J��F�W�߼аO
				{ #���ޥ�
				}
				elsif($anchor_doing =~ /<([^\/][^>]*)>/)	# �J��F�_�l�аO
				{
					my $tmp = $1;
					$tmp =~ s/(\S*)\s*.*/$1/;
					push(@xml_tag_stack, $tmp);		# �N�аO���J���|
				}
				elsif($anchor_doing =~ /<\/([^>]*)>/)	# �J��F�����аO
				{
					my $tmp = $1;
					my $tmp2 = pop(@xml_tag_stack);		# ���X�аO���
					if($tmp ne $tmp2)				# �����D, tag �S������
					{
						if($tmp2)
						{
							$xml_err_message .= "���ӬO</$tmp2>�o�J��</$tmp>; ";
							push(@xml_tag_stack, $tmp2);	
						}
						else
						{
							$xml_err_message .= "�h�F�@��</$tmp>; ";
						}
					}
				}
			}
			else
			{
				$anchor_other = $anchor_doing . $anchor_other;
				$xml_err_message .= "��Ƥ���,�����ӬO'$anchor_doing'; ";
				# $xml_word_num++;	# ���X���r�ƥ[�@
				return 0;
			}
		}
	}
	$xml_err_message .= "�S����ƤF; ";
	return 0;	# �S��ƤF, ��򪱤U�h?
}

######################################################
# ����Ʀr -> ���ԧB�Ʀr
# created by Ray 2000/2/21 04:39PM
######################################################

sub cn2an {
	my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my %map = (
    "��",0,
    "�@",1,
 	  "�G",2,
 	  "�T",3,
 	  "�|",4,
 	  "��",5,
 	  "��",6,
 	  "�C",7,
 	  "�K",8,
 	  "�E",9
  );
	my @chars = ();
	push(@chars, $s =~ /$big5/g);
	
	my $result=0;
	my $n=0;
	my $old="";
	my $c=0;
	foreach $c (@chars) {
		if ($c eq "�d") {
			if ($n==0) { $result+=1000; } else { $result += $n*1000; $n=0;}
		} elsif ($c eq "��") { 
			# $result += $n*100; $n=0;
			if ($n==0) { $result+=100; } else { $result += $n*100; $n=0;}
		} elsif ($c eq "�Q") { 
			if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
		} elsif (exists $map{$c}) { 
			if (($n%10) != 0 or $old eq "��") { $n *= 10; }
			$n += $map{$c}; 
		}
		$old = $c;
	}
	$result += $n;
	if ($result == 0) { $result=""; }
	else { $result="$result"; }
	return $result;
}

######################################################
# V1.94 �����l�հɩM��o�ծհ�
# �p�G���P, �Ǧ^ "" , �p�G�ۦP, �Ǧ^�s�� maha ��
######################################################

sub diff
{
	my $patten='(?:(?:&.*?;)|(?:�i���j)|(?:�i���j)|(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
	my $fullspace = '�@';
	
	my $str1 = shift;		# ��o�ժ�
	my $str2 = shift;		# maha ����l�հɱ���
	
	return $str2 if($str1 eq $str2);	# �G�ܤ���, �Ǧ^ maha ��
	
	my @str1;
	my @str2;

	push(@str1, $str1 =~ /$patten/g);
	push(@str2, $str2 =~ /$patten/g);
	
	my $i = -1;
	#for my $j (0 .. $#str2)
	for (my $j=0; $j<=$#str2; $j++)
	{
		$i++;
		
		next if($str1[$i] eq $str2[$j]);
		next if(($str1[$i] eq " ") and (($str2[$j] eq "�C") or ($str2[$j] eq "�A") or
		       ($str2[$j] eq ",") or ($str2[$j] eq ".")));	# �b���ťչ�W�@�ǲŸ�
		next if((($str2[$j] eq " ")or($str2[$j] eq ",")or($str2[$j] eq ".")or($str2[$j] eq ";")or($str2[$j] eq "�F")) and ($str1[$i] eq "�A"));	# �b���ťչ�W�@�ǲŸ�

		# �o�̤��ӬۦP�F...
		
		if(($str1[$i] eq "��") or ($str1[$i] eq "��") or ($str1[$i] eq "�A") or ($str1[$i] eq " "))		# ���h�����n��, �N�|�۵��F
		{
			$i++;
		}

		next if($str1[$i] eq $str2[$j]);

		if(($str1[$i] eq "��") or ($str1[$i] eq "��") or ($str1[$i] eq "�A") or ($str1[$i] eq " "))		# ���h�����n��, �N�|�۵��F
		{
			$i++;
		}

		next if($str1[$i] eq $str2[$j]);

		if(($str2[$j] eq "�A")or($str2[$j] eq " "))		# ���h�����n��, �N�|�۵��F
		{
			$j++;
		}

		next if($str1[$i] eq $str2[$j]);

		if($str2[$j] eq $fullspace)		# �@�ӱx��r
		{
			if(($str1[$i] eq '�i���j') or ($str1[$i] eq '��'))
			{
				next;
			}
		}
				
		if($str2[$j] eq "��")		# �@�ӱx��r
		{
			if($str1[$i] =~ /&.*?;/)
			{
				$str2[$j] = $str1[$i];		# �ĥά�o�ժ�
				next;
			}
		}

		if($str2[$j] eq "��")		# �@�ӱx��r
		{
			if($str1[$i] =~ /&.*?;/)
			{
				$str2[$j] = $str1[$i];		# �ĥά�o�ժ�
				next;
			}
		}
	
		if($str2[$j] eq "�i���j")		# �@��x��r
		{
			if(($str1[$i] =~ /&.*?;/) or ($str1[$i] eq "��"))
			{
				my $tmp = $str1[$i];
				$i++;
				while(($str1[$i] =~ /&.*?;/) or ($str1[$i] eq "��"))
				{
					$tmp .= $str1[$i];
					$i++;
				}
				$i--;
				
				$str2[$j] = $tmp;		# �ĥά�o�ժ�
				next;
			}
		}
		
		return "";	# ���ۦP
	}
	
	if($i == $#str1)
	{
		my $tmp = join("",@str2);	# �զ��ڭ̻ݭn����l�հɪ�
		return $tmp;	# ���\�L��
	}
	else
	{
		# �p�G��o�ժ��٦�, �̵M����L��
		
		if($i+1 == $#str1)		# �Y�̫�@�լO�ťժ�, �@�˥i�L��
		{
			if(($str1[$i+1] eq '�i���j') or ($str1[$i+1] eq '��'))
			{
				my $tmp = join("",@str2);	# �զ��ڭ̻ݭn����l�հɪ�
				return $tmp;	# ���\�L��
			}
		}
		
		return "";
	}
}

########### wrote by ray #######################################

sub read_jap_ent {
	
	local *I;

	open I, $jap_ent_file or die "open $jap_ent_file error!";

	while (<I>) {
		chomp;
		if (/ENTITY (\S*?) .*big5=�i(.*?)�j/) {
			$jap{$2}=$1;
		}
	}
	close I;
}

sub jap_rep 
{
	my $s=shift;
	if (not exists $jap{$s}) {
		return $s;
	}
	return "&" . $jap{$s} . ";";
}

############### end #######################

