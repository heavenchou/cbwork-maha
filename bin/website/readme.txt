���ؿ����{���D�n�O�g��W����s�ϥ�

	1. Xnor2Rnor.pl	�@�N normal/app X ���ন normal/app R ��.
 	   Xnor2Rnor_uni.pl	�@�N unicode normal/app X ���ন unicode normal/app R ��.

		�H�W�n�U���ѼƥD�n���G��
		
		$from_vol = 11; # �}�l�U��
		$to_vol = 16; # �����U��
		
		�ӥB�U������ normal �� app1 �n�B�z�A�ҥH�G��{���@�|���ͥ|�Ӫ����Gnormal, app1, normal_utf8, app1_utf8 
		
		�]�����o�G�հѼƭn���O����C (unicode ���̦�����)
		
		$source_path = "c:/release/normal/";
		$out_path = "c:/release/normal_R/";
		
		$source_path = "c:/release/app1/";
		$out_path = "c:/release/app1_R/";

	2.�� c:\cbwork\bin\website\make_Txxhtm.pl �O�N�j���èC�@�U���ؿ����ް��� html ��
	   �� c:\cbwork\bin\website\make_Xnnhtm.pl �O�N�����èC�@�U���ؿ����ް��� html ��

		�n����{��������ܼơA��ܤW��������C
		
		my $updatedate = '2006/06/23'; # �������
		
		�åB�n�O�o�[�W�U�U�����W��
		
		sub get_part()
		{
		$part[0] = '�L�׼��z�@';
		...... 
		$part[87] = '�v�ǳ��Q�|';
		}
		
		����ɭn�U�ѼơA���O�O�_�l�U�βפ�U�A�_�h�N�O�����C���U�O�� 11 �U�ܲ� 16 �U���Ҥl�G

		perl make_Xnnhtm.pl 11 16 
	  
	  
	3.�ϥε{�� c:\cbwork\bin\website\make_Ttoc.pl �O�N�j���èC�@�g���ؿ����ް��� html ��.
	  �ϥε{�� c:\cbwork\bin\website\make_Xtoc.pl �O�N�����èC�@�g���ؿ����ް��� html ��.

		�n����{��������ܼơA��ܤW��������C
		
		my $updatedate = '2006/06/23'; # �������
		
		�Y���S����Τ��s����A�n�b�{�����S�O�B�z�C
		
		����ɭn�U�ѼơA���O�O�_�l�U�βפ�U�A�_�h�N�O�����C���U�O�� 11 �U�ܲ� 16 �U���Ҥl�G
		
		perl make_Xtoc.pl 11 16 

	4.normal2htm.pl   �N normal(app) ������ html �u�W��.

		�D�n�i��|�ק諸�ѼƦp�U:
		
		$TX = "X"; # �j���å� "T" , �����å� "X"
		$from_vol = 11; # �_�l�U��
		$to_vol = 16; # �פ�U��
		$run_x2r = 1; # 1: �n, 0: ���O, �O�_�n�B�z������X���ഫR�����ʧ@
		$out_path = "d:/cbeta.www/result/normal/"; # ��X�ؿ�

		�ѼƳ]�w�n����A��������Y�i�C