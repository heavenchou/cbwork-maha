#######################################################################
# $Id: check20.pl,v 1.4 2003/09/21 15:16:35 heaven Exp $
#
# �ˬd���øg�O�_�C�� 20 �r���{��
# �����ѼƽЭק� check20_pre.pl �o��{��
# maha:
# 
# ���èC�椣�O20�r�����p�A�ڥثe�Q�쪺���G
# �g����A�g�W��A�@�̽s�̦�A���D��A�U�|��A�t�p�r����A�q���̫�@��
# �p��r�Ʈɻݭn�������A�ڥثe�Q�쪺���G
# ���ΰ��I"�C"�A���ζ��I"�D"�A��
# �u�զr���v�B�u�Ʀr�հɡv�B�u���Ϊťաv�n��@�@�Ӧr�Ӻ�C
# �d�N²��аO�����Y�ƼаO�]�аO�ĤT�檺�b�Ϊ��ԧB�Ʀr�^�C
# 
# kaitser:
# 
# �Y�O�H�ڭ̼Цn��²��аO�����h���R�A�i�H����������check-p.pl�o��{���@��
# �i�ۦ�W�[�δ�֩����Ӧ���R���аO�Ÿ��C
# �e�D�A�Y���D²��аO�������A��{���S����J���󪺼аO�Ÿ��ɡA�h�C�泣�|�h�����R�ˬd�C
# �o�i�H���{�����h���ƪ��γ~�C
# �H�W�O�w�靈�аO�P�L�аO�����A��M�Ӧ椤�A�@�ǰ򥻭n�������A�٬O�n���C
# �������F�F�A�̦n�]�i�H��ʼW�[��C
# �ڦҼ{�쪺�r���A"��B�ߡB��B���B�e�B�f�B�x�B�ޡB�D�B�@�B�C"���r�C
# �٦��@�ӬO�_�n�Ҽ{�����O�H����"�i�ϡj"�A��ĳ�]�i�H�]����ٲŸ������@�r�Ω����A�|�Ҧp�U�G
# �i��ʳ]�w��ٲŸ����@�Ӧr����"[]" �����e�D�A�������]�t�Ʀr�h��������r�A
# �]���D�զr�����p��[��/10]�B[01]�C
# �i��ʳ]�w�w���檺��ٲŸ��A���C�J�ˬd����"()"  �������ηN�O�����s��檺�����p�r�P�_�C
#
# �B�z��h:
#
# �p�G�U�@��O�ťզ�, �h��������.
# �p�G����O�ťզ�, ������
# �p�G����O�u���@��"�i�ϡj", ������
# �N�զr���ܦ��@�ӳ�@���r (�o�ˤ@�ӴN�S���զr�����A���F, �Y���A�����O����p��)
# �Z�O�Ӧ��ݩ��檺����p��, �@�ߩ�����.
# �Y���榳����p��, �@�ߩ���
# ���榳�S��аO, �h����, �Ҧp "Q"
# �Y�U�@�榳�S��аO, �h����, �Ҧp�U�@��O "P"
# �p�G���榳�S���r, �h����, �Ҧp "�i�Ȯɧ䤣��Ҥl�j"
# �N����ΰɻ~�٭�, �H���o���T�Ʀr
# �N�S���r�ܦ��@�Ӧr, �Ҧp "�i�g�j"
# �N�S���r�ε��ܦ��S���r, �Ҧp "�C"
# �N²��аO�����Ʀr�[�J�r�Ƥ�
# �p�G�r�Ƥ��O�b���w���d�� , �h�L�X��
# 
#
# Copyright (C) CBETA, 1998-2003
# Copyright (C) Heaven Chou, 2003
#######################################################################

#use strict;

#######################################
# �i�վ㪺�Ѽ�
#######################################

# �����ѼƽЭק� check20_pre.pl �o��{��

require "check20_pre.pl";

#######################################
# �ܼ�
#######################################

my $big5='(?:(?:[\xa1-\xfe][\x40-\xfe])|[\x00-\x7f])';
# $losebig5 ���� 0-9, > [ ] �o�ǲŸ�
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x00-\x2f]|[\x3a-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])';

my $simple;			# �P�_�O���O²��аO��, 1: �O, 0: �@�몺��r��, �S��²��аO
my $hasnote=0;		# �P�_�O���O����檺����p��, 1: �O, 0: ���O

my $data_pos;		# �]�����P�����p, �p���ƪ��_�I
my @line;			# ���������
my @outline;		# ��X�����
my $sign;			# �歺��²��аO
my $linehead;		# �ثe���歺
my $nextsign="";	# �U�@�檺�歺
my $nextdata="";	# �U�@�檺���
my $num;			# ���
my $startline;		# �Ĥ@������ƪ����

my $line1921=-999;	# �S�O���ˬd�O���O�e�@��19�U�@��21�����.

local *IN;
local *OUT;

########################################################
## �D�{��
########################################################

open IN, $infile or die "open $infile error!";
@line = <IN>;
close IN;

for($i=0;$i<=$#line;$i++)
{
	if($line[$i] ne "\n")
	{
		$startline = $i;
		last;
	}
}

$simple = check_simple();		# �P�_�O���O²��аO��
$data_pos = get_data_pos();		# �]�����P�����p, �p���ƪ��_�I

open OUT, ">$outfile" or die "open $outfile error!";
if ($simple == 1)
{
	simple_ver();				# ²��аO�����P�_
}
else
{
	none_simple_ver();			# �D²��аO�����P�_
}


foreach (@outline)
{
	print OUT;
}

print OUT "$infile : found => ";

close OUT;

#######################################
# �P�_�O���O²��аO��
#######################################

sub check_simple()
{
	$sign = substr($line[$startline], 17,3);

	if ($sign =~ /[a-zA-Z0-9_#\?]{3}/)
	{
		return 1;	# ²��аO��
	}
	else
	{
		return 0;	# �D²��аO��
	}
}

#######################################
# �]�����P�����p, �p���ƪ��_�I
#######################################

sub get_data_pos()
{
	if($simple == 1)	# ²��аO��
	{
		my $tmp = substr($line[$startline],20,2);
		if ($tmp eq "��")		# �����j�u
		{
			$data_pos = 22;
		}
		else
		{
			$data_pos = 20;
		}
	}
	else
	{
		my $tmp = substr($line[$startline],17,2);
		if ($tmp eq "��")		# �����j�u
		{
			$data_pos = 19;
		}
		else
		{
			$data_pos = 17;
		}
	}
}

#######################################
# ²��аO�����P�_
#######################################

sub simple_ver()
{
	my $data;
	
	for ($num = $startline; $num < $#line; $num++)		# �����ݳ̫�@��
	{
		
		if($line[$num] =~ /X84n1579_p0003a24/)
		{
			my $debug;
			$debug = 1;
		}
		# ������B�z²��аO, �]���n���B�z��檺����p��, �K�o�䤣���檺 ) �Ÿ�

		$sign = substr($line[$num], 17,3);			# ���X²��аO
		$nextsign = substr($line[$num+1], 17,3);	# ���X�U�@�檺²��аO

		# �p�G�U�@��O�ťզ�, ������
		
		$nextdata = substr($line[$num+1], $data_pos);		# ���X�U�@�檺���
		#next if ($nextdata eq "\n" or $nextdata eq "");		# �U�@��O�ťզ�, ������ (���i�{�b�B�z, �H�K���榳 ) �n�B�z)

		$linehead = substr($line[$num], 0, $data_pos);	# ���X�歺
		$data = substr($line[$num], $data_pos);			# ���X���
		check_data($data);								# �ˬd�O�_�O 20 �Ӧr
	}
	
	# �̫�@��, �n�B�z��?

	$sign = substr($line[$#line], 17,3);			# ���X²��аO
	$nextsign = "";								# ���X�U�@�檺²��аO
	if ($sign !~ /[${skip_sign}]/)				# �S���S��аO
	{
		$linehead = substr($line[$#line], 0, $data_pos);	# ���X�歺
		$data = substr($line[$#line], $data_pos);		# ���X���
		check_data($data);
	}
	
}

#######################################
# �D²��аO�����P�_
#######################################

sub none_simple_ver()
{
	my $data;
	
	for ($num = $startline; $num <= $#line; $num++)
	{
		# �p�G�U�@��O�ťզ�, ������
		
		$nextdata = substr($line[$num+1], $data_pos);		# ���X�U�@�檺���
		#next if ($nextdata eq "\n" or $nextdata eq "");		# �U�@��O�ťզ�, ������ (���i�{�b�B�z, �H�K���榳 ) �n�B�z)

		$linehead = substr($line[$num], 0, $data_pos);	# ���X�歺
		$data = substr($line[$num], $data_pos);			# ���X���
		check_data($data);								# �ˬd�O�_�O 20 �Ӧr
	}
}

#######################################
# �ˬd�Y��O�_�O 20 �Ӧr
#######################################

sub check_data()
{
	my $data = shift;
	
	my $linecount = 0;			# ���檺�r��
	my $data_other = $data;
	my $data_doing = "";

	chomp($data_other);

	return if ($data_other eq "");			# �����ťզ�
	return if ($data_other eq "�i�ϡj");	# ������@������

	# �A�N�զr���ܦ��@�Ӧr, �N�� "��" �r�n�F

	while($data_other =~ /^$big5*?\[$losebig5{2,}\]/)	# �ʦr�n�G�ӥH�W, �_�h [��] �|�P���զr��
	{
		$data_other =~ s/^($big5*?)\[$losebig5{2,}\]/$1��/;	# ���� "��" �o�Ӧr
	}
	
	# �p�G����檺����p��, �N����
	# �o��@�w�n�b�B�z�զr������, �~���|�Q�z�Z, �S�n�b�䥦�P�_���e, �K�o�䤣������p�����k�A��

	if($data_other =~ /\(/)
	{
		my $tmp = $data_other;
		while($tmp =~ /\([^\(]*?\)/)
		{
			$tmp =~ s/\([^\(]*?\)//;	# �N��٩ʪ�������
		}
		if($tmp =~ /\(/)
		{
			$hasnote = 1;			# ����檺����p��
			return;
		}
	}
	
	# �P�_��檺����p�������F�S?
	
	if($data_other =~ /\)/)
	{
		my $tmp = $data_other;
		while($tmp =~ /\([^\(]*?\)/)
		{
			$tmp =~ s/\([^\(]*?\)//;	# �N��٩ʪ�������
		}
		if($tmp =~ /\)/)
		{
			$hasnote = 0;				# ������檺����p��
			return;
		}
	}
	
	return if ($hasnote == 1);

	return if($data_other =~ /[\(\)]/);		# ���A���N���n

	if($simple ==1)
	{
		return if ($sign =~ /[${skip_sign}]/);		# ���S��аO, ������
		return if ($nextsign =~ /[$skip_next_sign]/);	# �U�@�榳�S��аO, ������
	}

	# �P�_�O���O��������

	return if(skip_this_line($data));


	return if ($nextdata eq "\n" or $nextdata eq "");		# �U�@��O�ťզ�, ������

	# �N [a>b] [a>>b] ���� a , �٭즨�g���Ӫ��r��
	
	if($data_other =~ />/)
	{
		$data_other =~ s/\[($losebig5*?)>>$losebig5*?\]/$1/g;
		$data_other =~ s/\[($losebig5*?)>$losebig5*?\]/$1/g;
	}
	
	# �N�S���r�ε��ܦ��@�Ӧr
	
	$data_other = equal_one($data_other);
	
	# �N�S���r�ε��ܦ��S���r
	
	$data_other = equal_zero($data_other);

	# �}�l�@�r�@�r�h���R
	
	my $data1921 = $data_other;		# ���s�_��, �n�P�_�Ĥ@�Ӧr�O���O�����Ů�

	while($data_other ne "")	# ����٨S����
	{	
		$data_other =~ s/^($big5)//;	# ���@�Ӧr�X��
		$data_doing = $1;
		
		if($data_doing eq "")			# ���_�ǲ{��, �ҥH�����W�L 20 �Ӧr
		{
			$linecount= 99;
			last;
		}
		$linecount++;
	}
	
	# �P�_²��аO�����S���Ʀr
	
	my $sign_tmp = $sign;
	while($sign_tmp =~ /\d/)
	{
		$sign_tmp =~ s/(\d)//;
		$linecount = $linecount + $1;
	}
	
	# ���O���w���Ӧr�ƽd��

	$min_count = 19 if($min_count==0);		# ��ߨϥΪ̨S���� check20_pre.pl
	$max_count = 21 if($max_count==0);

	if($linecount < $min_count or  $linecount > $max_count)
	{
		my $tmp = $num+1 . ":" . $linehead . $data;
		
		if($skip1921)		# �����Ĥ@��19�r, �ĤG��21�r, �B�ĤG��}�Y�������Ů�
		{

			if(($linecount == 21) and (substr($data1921,0,2) eq '�@') and ($num == $line1921))
			{
				pop(@outline);
			}
			else
			{
				if($linecount == 19)
				{
					$line1921 = $num+1;		# �O�U19�r�����
				}
				push(@outline, $tmp);
			}
		}
		else
		{
			push(@outline, $tmp);
		}
	}
}

#######################################
# �P�_�O���O��������
#######################################

sub skip_this_line()
{
	local $_ = shift;
	
	for (my $i = 0; $i<=$#skip_word; $i++)
	{
		return 1 if /^${big5}*?$skip_word[$i]/;		# ����]�t�n���L���檺�r
	}
	return 0;
}

#######################################
# �N�S���r�ε��ܦ��@�Ӧr
#######################################

sub equal_one()
{
	local $_ = shift;
	for (my $i = 0; $i<=$#equal_1; $i++)
	{
		while(/^$big5*?$equal_1[$i]/)
		{
			s/^($big5*?)$equal_1[$i]/$1�@/;			# ���� "�@" �o�Ӧr
		}
	}
	return $_;
}

#######################################
# �N�S���r�ε��ܦ��S���r
#######################################

sub equal_zero()
{
	local $_ = shift;
	for (my $i = 0; $i<=$#equal_0; $i++)
	{
		while(/^$big5*?$equal_0[$i]/)
		{
			s/^($big5*?)$equal_0[$i]/$1/;			# �����o�Ӧr
		}
	}
	return $_;
}

#######################################
# end
#######################################