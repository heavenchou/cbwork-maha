#####################################################################
# multigrep.pl                                             ~by heaven
# �U�ηj�M�{��
# CVS���� $Id: multigrep.pl,v 1.2 2004/11/16 13:33:03 heaven Exp $
# �����G
#   �U�ηj�M�{��, �ѼƽШ̤U�C�����ǿ�J.
#
# �Ѽƨ̧Ǧp�U :
#   �ӷ��ؿ� : �j�M���_�l�ؿ�, �Х� / ���N \ �ϥ�, �Y�ؿ������ť�, �Х����޸� " " �N�ؿ��W�A�_��.
#   �ɦW�˦� : �i�Φh�ոU�Φr��, ���j�ХΥΥb���Ů�, �~�������޸� " " �N�ؿ��W�A�_��, �Ҧp : "a*.txt b*.dat"
#   ��X�ɦW : ��X�����G�ɦW, �i�t�X�~�ѷj�M.
#   �j�M�r���� (�Φr��) : �i����@�r��, �άO���h�r�ꪺ�ɦW, ��̭n�� -f: ���}�Y, �Ҧp -f:a.txt
#   �O�_�]�t�l�ؿ� : 1 ��ܷj�M�]�t�l�ؿ� , 0 ��ܤ��]�t�l�ؿ�
#   �O�_�����W���j�M : 1 ��ܥ��W��(regular expression)�j�M, �Ъ`�N������D, 0 ��ܤ@���r�j�M
#   �Ϥ��j�p�g : 1 ��ܰϤ��j�p�g,���t�פ���C, 0 ��ܤ��Ϥ��j�p�g
#   ��� (�٨S��, �H��A��)
#   �j�p (�٨S��, �H��A��)
# Copyright (C) 1998-2004 CBETA
# Copyright (C) 2004 Heaven Chou
#####################################################################
#2004/11/15 V0.1 : ���ժ�����
#2004/11/11 V0.0 : �}�l
#####################################################################

use strict;
use Cwd;

my $SourcePath = shift;
my $FilePattern = shift;
my $OutputFileName = shift; 
my $SearchFileName = shift; 
my $IsIncludeSubDir = shift;
my $IsRegEx = shift; 
my $IsCaseSen = shift; 
my $DateRange = shift; 
my $SizeRange = shift; 

#$SourcePath = "D:/cbeta.src/";
#$FilePattern = "\"so*.txt re*\"";
#$OutputFileName = "findlog.txt";
#$SearchFileName = "-f:findword.txt";
#$SearchFileName = "Ĥ";
#$IsIncludeSubDir = 1;
#$IsRegEx = 0;
#$IsCaseSen = 1;

#####################################################################
# �ܼ�
#####################################################################

local *IN;
local *OUT;
local *DIR;

my @SearchWord = ();		# �s��j�M���r��
my @SearchWordU = ();		# �s��j�M���r��, �Y���Ϥ��j�p�g, �h�����j�g, �ӥB�n�[ \Q\E �B�z���W��

my $TotalSearchFileNum = 0;		# �`�@�j�M�ɮ׼�
#my $TotalMatchFileNum = 0;		# �ŦX�n�D�ɮ׼�
#my $TotalMatchLineNum = 0;		# �ŦX�n�D���`���, �n�� @LineData , @FoundLines �Ϊ�

#��X�ɪ��[�c
#�M�� '��' �� 'C:\cbwork\xml\T54\T54n2130.xml' :
#3579: <lb n="1027a02"/><item>���G<note place="inline">�������G�C�@Ķ��n��</note></item>
#��� '��' 1 ���C

my @FoundFiles = ();	# �C�@�ӧ�쪺�ɦW C:\cbwork\xml\T54\T54n2130.xml
my @LineData = ();		# �C�@�ӧ�쪺�檺�������, <fn><n><n>...., <fn>�ĴX���ɮ�, <n>�ĴX�ӭn�䪺�r
my @FoundLines = ();	# �C�@�ӧ�쪺��, 3579: <lb n="1027a02"/><item>���G<note place="inline">�������G�C�@Ķ��n��</note></item>


my @WordFoundFiles = (); 		# �C�ӵ��@�b�X���ɮפ��o�{
my @WordLastFoundFile = (); 	# �O������즹������, �Y�M�ثe���P, $WordFoundFiles[$] �N�[ 1
my @TotalSearchWordNum = ();	# �x�s�C�@�ӵ��@���X��
	
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
#####################################################################
# �D�{��
#####################################################################

AnalysisPara();					# �ˬd�@���Ѽ�
SearchDir($SourcePath);			# �}�l�j�M
OutputFile();					# �N���G��X

print STDOUT "OK, ���N�䵲��...";
<>;

# �D�{������

#####################################################################
# �ˬd�@���Ѽ�
#####################################################################
sub AnalysisPara
{
    CheckSourcePath();		# check source path
	CheckFilePattern();		# check File Pattern
	CheckOutputFile();		# check output file
	CheckSearchWord();		# check search word or file
	CheckIncludeSubDir();	# check is Include SubDir
	CheckIsRegEx();			# check is Regular Expression
	CheckIsCaseSen();		# check is case sensitive
}
#--------------------------------------------------------------------
sub CheckSourcePath
{
    unless(-d $SourcePath)
    {
        print STDERR "���~ : �䤣�� $SourcePath , ���N�����}...";
        <>;
        exit;
    }
    $SourcePath =~ s#/#\\#g;
    $SourcePath =~ s#\\$##g;
}
#--------------------------------------------------------------------
sub CheckFilePattern
{
	if($FilePattern =~ /^"(.*)"$/)
	{
		$FilePattern = $1;
	}

    if($FilePattern eq "")
    {
    	$FilePattern = "*.*";
    }
}
#--------------------------------------------------------------------
sub CheckOutputFile
{
    if($OutputFileName eq "")
    {
	    print STDERR "���~ : �S����X�ɦW, ���N�����}...";
        <>;
        exit;
    }
}
#--------------------------------------------------------------------
sub CheckSearchWord
{
	local $_;
    if($SearchFileName eq "")
    {
	    print STDERR "���~ : �S���n�d�ߪ��r��, ���N�����}...";
        <>;
        exit;
    }
    
	# �p�G�O -f: �}�Y, �N���ɮ�, �@��@�� searchword, �_�h�N�O�H�ѼƷ� searchword
	if($SearchFileName =~ /^\-f:/i)
	{
		$SearchFileName =~ s/^\-f://i;
		
		open IN, $SearchFileName || die "open $SearchFileName error. $!";
		while(<IN>)
		{
			chomp();
			push(@SearchWord, $_);
			push(@SearchWordU, $_);
			push(@TotalSearchWordNum, 0);	# �C�@����쪺�ƥ�
			push(@WordFoundFiles, 0);		# �C�@���b�X���ɮפ����
			push(@WordLastFoundFile, -1);	# �O������즹������, �Y�M�ثe���P, $WordFoundFiles[$] �N�[ 1
		}
		close IN;
	}
	else
	{
		$SearchWord[0] = $SearchFileName;
		$SearchWordU[0] = $SearchFileName;
		$TotalSearchWordNum[0] = 0;			# �C�@����쪺�ƥ�
		$WordFoundFiles[0] = 0;				# �C�@���b�X���ɮפ����
		$WordLastFoundFile[0] = -1;			# �O������즹������, �Y�M�ثe���P, $WordFoundFiles[$] �N�[ 1
	}
	
	#�P�_���S���ΰϤ��j�p�g
	if(!$IsCaseSen)
	{
			for(my $i = 0; $i<= $#SearchWordU; $i++)		# ���Ϥ��j�p�g, �N�����ܤj�g
			{
				$_ = $SearchWordU[$i];
				# ������y
				my $tmp = "";
				while(s/^($big5)//)
				{
					my $word = $1;
					if(length($word) == 1)
					{
						$tmp .= uc($word);		# �^��r���j�g
					}
					else
					{
						$tmp .= $word;			# ����r����
					}
				}
				$SearchWordU[$i] = $tmp;
			}
	}
	
		# �B�z���W��
		for(my $i=0; $i<=$#SearchWordU; $i++)
		{
			# �P�_���S���Υ��W��
			if($IsRegEx)
			{
				# ���W��, �Ҧ����大���n�[ \Q \E
				$_ = $SearchWordU[$i];
				# ������y
				my $tmp = "";
				while(s/^($big5)//)
				{
					my $word = $1;
					if(length($word) == 1)
					{
						$tmp .= $word;			# �^��r����
					}
					else
					{
						$tmp .= "\Q$word\E";	# ����r�[ \Q \E
					}
				}
				$SearchWordU[$i] = $tmp;
			}
			else
			{
				# �Y���O���W��, �h�n�N���媺�S���r�׶}
				$SearchWordU[$i] = "\Q$SearchWordU[$i]\E";
			}
		}
}
#--------------------------------------------------------------------
sub CheckIncludeSubDir
{
	if($IsIncludeSubDir eq "")
    {
	    $IsIncludeSubDir = 1;
    }
}
#--------------------------------------------------------------------
sub CheckIsRegEx
{
	if($IsRegEx eq "")
    {
	    $IsRegEx = 0;
    }
}
#--------------------------------------------------------------------
sub CheckIsCaseSen
{
	if($IsCaseSen eq "")
    {
	    $IsCaseSen = 1;
    }
}
#####################################################################
# �}�l�j�M
#####################################################################
sub SearchDir
{
	my $ThisDir = shift;
	
	my $myPath = getcwd();
	chdir($ThisDir);
	my @files = glob($FilePattern);
	chdir($myPath);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);
		$file = $ThisDir . "\\" . $file ;
		if (-f $file)
		{
			print "$file\n";
			$TotalSearchFileNum++;		# �j�M�ɮ׼� + 1
			SearchFile($file);
		}
	}
	
	return unless($IsIncludeSubDir);	# �Y���j�M�l�ؿ��N���}
	
	opendir (DIR, "$ThisDir");
	@files = readdir(DIR);
	closedir(DIR);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);
		$file = $ThisDir . "\\" . $file ;
		if (-d $file)
		{
			SearchDir($file);
		}
	}	
}
#####################################################################
# �b�ɮפ��j�M
#####################################################################
sub SearchFile
{
	my $file = shift;
	my $LineNum = 0;
	local $_;
	my $IsFound = 0;	# ���~�]�� 1
	
	open IN, "$file" || die "open $file error : $!";
	while(<IN>)
	{
		my $ThisLine = $_;	# �Y���Ϥ��j�p�g, $_ �|�ܦ��j�g, �� $ThisLine �h�O�n��X�Ϊ��зǥy�l
		$LineNum++;
		my $ThisLineRecord = 0;		# �Y���榳���, �h�]�� 1
		for(my $i=0; $i<= $#SearchWord; $i++)
		{
			my $SearchWord = $SearchWordU[$i];
						
			#�P�_���S���ΰϤ��j�p�g
			if(!$IsCaseSen)		# ���Ϥ��j�p�g, �N�����ܤj�g
			{
				# ������y
				my $tmp = "";
				while(s/^($big5)//)
				{
					my $word = $1;
					if(length($word) == 1)
					{
						$tmp .= uc($word);		# �^��r���j�g
					}
					else
					{
						$tmp .= $word;			# ����r����
					}
				}
				$_ = $tmp;
			}

			# �P�_�O�_��즹�r��
			if(/$SearchWord/)
			{
				if(/^(($big5)*?$SearchWord)/)
				{
					# �Y���ɲĤ@�����n�䪺, �N�N���ɰO���_��
					if($IsFound == 0)
					{
						$IsFound = 1;
						push(@FoundFiles , $file);		# �N�ɦW�s�_��
					}
					#my @FoundFiles = ();	# �C�@�ӧ�쪺�ɦW C:\cbwork\xml\T54\T54n2130.xml
					#my @LineData = ();		# �C�@�ӧ�쪺�檺�������, <fn><n><n>...., <fn>�ĴX���ɮ�, <n>�ĴX�ӭn�䪺�r
					#my @FoundLines = ();	# �C�@�ӧ�쪺��, 3579: <lb n="1027a02"/><item>���G<note place="inline">�������G�C�@Ķ��n��</note></item>
				
					# �Y����Ĥ@�����n�䪺, �N�N����O���_��
					if($ThisLineRecord == 0)
					{
						$ThisLineRecord = 1;
						my $tmp = sprintf("%06d:%s", $LineNum, $ThisLine);	# �n�έ�l�� $ThisLine
						push(@FoundLines , $tmp);		# �N�Ӧ�s�_��
						$LineData[$#FoundLines] = "<f$#FoundFiles>";
					}
					$LineData[$#FoundLines] .= "<$i>";
					
					if($WordLastFoundFile[$i] != $#FoundFiles)
					{
						$WordLastFoundFile[$i] = $#FoundFiles;
						$WordFoundFiles[$i]++;				# ���r�X�{���ɮ׼�
					}
					
					# �p�⦹��@�X�{�X������
					
					my $tmp = $_;
					while($tmp =~ /^($big5)*?$SearchWord/)
					{
						$tmp =~ s/^($big5)*?$SearchWord//;
						$TotalSearchWordNum[$i]++;	# �������ƥ� + 1
					}
				}
			}
		}
	}
	close IN;	
}
#####################################################################
# �N���G��X
#####################################################################
sub OutputFile
{
	print STDERR "�B�z��X��";

	#my @FoundFiles = ();	# �C�@�ӧ�쪺�ɦW C:\cbwork\xml\T54\T54n2130.xml
	#my @LineData = ();		# �C�@�ӧ�쪺�檺�������, <fn><n><n>...., <fn>�ĴX���ɮ�, <n>�ĴX�ӭn�䪺�r
	#my @FoundLines = ();	# �C�@�ӧ�쪺��, 3579: <lb n="1027a02"/><item>���G<note place="inline">�������G�C�@Ķ��n��</note></item>
	
	open OUT, ">$OutputFileName" || die "open $OutputFileName error :$!";
	
	print OUT "�`�@�j�M $TotalSearchFileNum ���ɮ�\n";
	
	# ���L�X�C�@�ӵ��@�X�{�X��
	for(my $i=0; $i<= $#SearchWord; $i++)
	{
		print OUT "$SearchWord[$i] : �X�{�b $WordFoundFiles[$i] ���ɮפ�, �@�X�{�L $TotalSearchWordNum[$i] ��\n";
	}
	print OUT "\n";
	
	# ���̵�, �A����, �A�̦�L�X���G
	
	for(my $i=0; $i<= $#SearchWord; $i++)
	{
		my $NowFile = -1;					# �ثe���b�B�z���ɮ�
		my $NowFileLineNum = 0;
		for(my $j=0; $j<= $#LineData; $j++)
		{
			# $j �榳�� $i �ӭn�d���r
			if($LineData[$j] =~ /<$i>/)
			{
				$LineData[$j] =~ /^<f(\d+)>/;	# ���X���檺�ɮ׸��
				my $tmp = $1;
				if($NowFile != $tmp)	# �Ĥ@���X�{�h�n�L�X�ɦW
				{
					print STDERR ".";
					if($NowFile != -1)
					{
						#C:\Documents and Settings\maha.MAHA1\�ୱ\B01_p0071.txt : found 4=> �g
						print OUT "$FoundFiles[$NowFile] : found $NowFileLineNum ==> $SearchWord[$i]\n\n";
					}
					$NowFile = $tmp;
					$NowFileLineNum = 0;	# ���ɪ���ƭp���k 0
				}
				$NowFileLineNum++;				# ���ɧ�쪺��� + 1
				print OUT $FoundLines[$j];
			}
		}
		print OUT "$FoundFiles[$NowFile] : found $NowFileLineNum ==> $SearchWord[$i]\n\n";
	}
	close OUT;	
	
	print STDERR "ok\n";
}
#####################################################################