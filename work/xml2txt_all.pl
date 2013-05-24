use File::Path;
use Cwd;

my $orig_path = getcwd;	# ���{�����ؿ�

######################################################
# �P�_�������Φ۰ʰ���
######################################################

$ENV{"PATH"} = "C:\\CBWORK\\WORK\\BIN;" .  $ENV{"PATH"};	# �[�J path c:\cbwork\work\bin
if($ARGV[0])	# ���ǤJ�Ѽ�
{
	print "you input $ARGV[0]\n";
}
else
{
	$mw = gui_class->new();
	$mw->show();
}

######################################################
# �D�{��
######################################################

sub main
{
	local * argv = shift;	# �ǤJ�Ҧ����Ѽ�, �o�O�@�� hash

	$source_path = $argv{sText1};
	my $Tfrom = $argv{sText3};
	my $Tto = $argv{sText4};
	my $Xfrom = $argv{sText5};
	my $Xto = $argv{sText6};
	my $Jfrom = $argv{sText7};
	my $Jto = $argv{sText8};
	my $Hfrom = $argv{sText9};
	my $Hto = $argv{sText10};
	my $Wfrom = $argv{sText11};
	my $Wto = $argv{sText12};
	my $Ifrom = $argv{sText13};
	my $Ito = $argv{sText14};
	
	my $Afrom = $argv{sText15};
	my $Ato = $argv{sText16};
	my $Bfrom = $argv{sText17};
	my $Bto = $argv{sText18};
	my $Cfrom = $argv{sText19};
	my $Cto = $argv{sText20};
	my $Dfrom = $argv{sText21};
	my $Dto = $argv{sText22};
	my $Ffrom = $argv{sText23};
	my $Fto = $argv{sText24};
	my $Gfrom = $argv{sText25};
	my $Gto = $argv{sText26};
	my $Kfrom = $argv{sText27};
	my $Kto = $argv{sText28};
	my $Lfrom = $argv{sText29};
	my $Lto = $argv{sText30};
	my $Mfrom = $argv{sText31};
	my $Mto = $argv{sText32};
	my $Pfrom = $argv{sText33};
	my $Pto = $argv{sText34};
	my $Sfrom = $argv{sText35};
	my $Sto = $argv{sText36};
	my $Ufrom = $argv{sText37};
	my $Uto = $argv{sText38};

	my $para = $argv{para};
	
	$Tfrom =~ s/\s//g;
	$Tto =~ s/\s//g;
	$Xfrom =~ s/\s//g;
	$Xto =~ s/\s//g;
	$Jfrom =~ s/\s//g;
	$Jto =~ s/\s//g;
	$Hfrom =~ s/\s//g;
	$Hto =~ s/\s//g;
	$Wfrom =~ s/\s//g;
	$Wto =~ s/\s//g;

	$Afrom =~ s/\s//g;
	$Ato =~ s/\s//g;
	$Cfrom =~ s/\s//g;
	$Cto =~ s/\s//g;
	$Ffrom =~ s/\s//g;
	$Fto =~ s/\s//g;
	$Gfrom =~ s/\s//g;
	$Gto =~ s/\s//g;
	$Kfrom =~ s/\s//g;
	$Kto =~ s/\s//g;
	$Lfrom =~ s/\s//g;
	$Lto =~ s/\s//g;
	$Mfrom =~ s/\s//g;
	$Mto =~ s/\s//g;
	$Pfrom =~ s/\s//g;
	$Pto =~ s/\s//g;
	$Sfrom =~ s/\s//g;
	$Sto =~ s/\s//g;
	$Ufrom =~ s/\s//g;
	$Uto =~ s/\s//g;
	
	parser_num($Tfrom, $Tto, "T", $para);	# �Ĥ@����, �B�z�j����
	parser_num($Xfrom, $Xto, "X", $para);	# �ĤG����, �B�z������
	parser_num($Jfrom, $Jto, "J", $para);
	parser_num($Hfrom, $Hto, "H", $para);
	parser_num($Wfrom, $Wto, "W", $para);
	parser_num($Ifrom, $Ito, "I", $para);

	parser_num($Afrom, $Ato, "A", $para);
	parser_num($Bfrom, $Bto, "B", $para);
	parser_num($Cfrom, $Cto, "C", $para);
	parser_num($Dfrom, $Dto, "D", $para);
	parser_num($Ffrom, $Fto, "F", $para);
	parser_num($Gfrom, $Gto, "G", $para);
	parser_num($Kfrom, $Kto, "K", $para);
	parser_num($Lfrom, $Lto, "L", $para);
	parser_num($Mfrom, $Mto, "M", $para);
	parser_num($Pfrom, $Pto, "P", $para);
	parser_num($Sfrom, $Sto, "S", $para);
	parser_num($Ufrom, $Uto, "U", $para);
	
	print "\n" . "="x70 . "\nOK!\n\n";
}

sub parser_num
{
	# �U�ժ���ƶǶi�ӳB�z
	
	my $from = shift;
	my $to = shift;
	my $book = shift;
	my $para = shift;
	
	if($from =~ /[,\(\.]/)
	{
		my @nums = split(/,/,$from);
		for $i (@nums)
		{
			if($i =~ /^\((\d+)\.\.(\d+)\)$/)
			{
				my @nums2 = ($1..$2);
				for $j (@nums2)
				{
					run_dir($book,$j,$para);
				}
			}
			elsif($i =~ /^\d+$/)
			{
				run_dir($book,$i,$para);
			}
		}
	}
	elsif($from =~ /^\d+$/ && $to =~ /^\d+$/)		# ���G�ռƦr
	{
		my @nums = ($from..$to);
		for $j (@nums)
		{
			run_dir($book,$j,$para);
		}
	}
	elsif($from =~ /^\d+$/ && $to eq "")		# �u���Ĥ@��
	{
		run_dir($book,$from,$para);
	}
}

sub run_dir
{
	my $TX = shift;
	my $vol = shift;
	my $para = shift;
	
	# �L�o�� T56~T84 , X86~ , X06, X52 , X89..
	############################################################################################################################
	if($TX eq "T")
	{
		return if($vol > 55 && $vol < 85);
		return if($vol > 85);
	}
	if($TX eq "X")
	{
		return if($vol == 6 || $vol == 52);
		return if($vol > 88);
	}
	if($TX eq "J")
	{
		return if($vol > 1 && $vol < 7);
		return if($vol > 7 && $vol < 10);
		return if($vol > 10 && $vol < 15);
		return if($vol > 15 && $vol < 19);
		return if($vol > 40);
	}
	if($TX eq "H")
	{
		return if($vol > 1);
	}
	if($TX eq "W")
	{
		return if($vol > 9);
	}

	my $TXvol;
	
	if($TX =~ /[ACGLMPU]/)	# �U�ƤT�X���øg
	{
		$TXvol = $TX . sprintf("%03d",$vol);		# �зǤ�
	}
	else
	{
		$TXvol = $TX . sprintf("%02d",$vol);		# �зǤ�
	}
	
	print "-"x70 . "\n$TXvol\n" . "-"x70 . "\n";

	chdir ("${source_path}/$TXvol");
	system ("xml2txt -v $TXvol $para");
	chdir ($orig_path);
}

# �����{�� ###################################################################

##############################################################################
# ������������
package gui_class;
##############################################################################

use Tk;
use Tk::ROText;
use Tk::LabFrame;
use Tk::BrowseEntry;

######################################################
# �ݩ�
######################################################
my %argv;

######################################################
# �򥻤�k
######################################################

sub new 						# ����غc
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	$this->_initialize();		# �����Ȥ�
	return $this;
}

sub DESTROY						# �Ѻc��
{
	my $self = shift;
	save2ini();		# �⵲�G�s�J ini �ɮפ�
	printf("�� �D�������� ��\n");
}

sub _initialize					# �����Ȥ�
{
	my $this = shift;
}

sub run_main					# ����D�{��
{
	# ���P�_�O���O�u�n����
	
	my $run = $mw->messageBox(-title => '�T�{', 
		-message => '�T�w�n����ܡH', 
		-type => 'YesNo', -icon => 'question', -default => 'no');
	
	return if($run eq "no");
	
	return if(!check_data(\$entry3, 3));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry4, 4));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry5, 5));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry6, 6));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry7, 7));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry8, 8));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry9, 9));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry10, 10));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry11, 11));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry12, 12));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry13, 13));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry14, 14));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry15, 15));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry16, 16));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry17, 17));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry18, 18));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry19, 19));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry20, 20));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry21, 21));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry22, 22));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry23, 23));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry24, 24));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry25, 25));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry26, 26));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry27, 27));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry28, 28));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry29, 29));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry30, 30));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry31, 31));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry32, 32));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry33, 33));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry34, 34));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry35, 35));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry36, 36));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry37, 37));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry38, 38));			# �ˬd�ܼƬO�_�X�z

	push_alldata_2_entry();	# �� Entry ��J���s�J�U�Կ�椤
	
	# �ǳƦ������
	
	$argv{"sText1"} = $sText[1];
	
	$argv{"sText3"} = $sText[3];
	$argv{"sText4"} = $sText[4];
	$argv{"sText5"} = $sText[5];
	$argv{"sText6"} = $sText[6];
	$argv{"sText7"} = $sText[7];
	$argv{"sText8"} = $sText[8];
	$argv{"sText9"} = $sText[9];
	$argv{"sText10"} = $sText[10];
	$argv{"sText11"} = $sText[11];
	$argv{"sText12"} = $sText[12];

	$argv{"sText13"} = $sText[13];
	$argv{"sText14"} = $sText[14];
	$argv{"sText15"} = $sText[15];
	$argv{"sText16"} = $sText[16];
	$argv{"sText17"} = $sText[17];
	$argv{"sText18"} = $sText[18];
	$argv{"sText19"} = $sText[19];
	$argv{"sText20"} = $sText[20];
	$argv{"sText21"} = $sText[21];
	$argv{"sText22"} = $sText[22];
	$argv{"sText23"} = $sText[23];
	$argv{"sText24"} = $sText[24];
	$argv{"sText25"} = $sText[25];
	$argv{"sText26"} = $sText[26];
	$argv{"sText27"} = $sText[27];
	$argv{"sText28"} = $sText[28];
	$argv{"sText29"} = $sText[29];
	$argv{"sText30"} = $sText[30];
	$argv{"sText31"} = $sText[31];
	$argv{"sText32"} = $sText[32];
	$argv{"sText33"} = $sText[33];
	$argv{"sText34"} = $sText[34];
	$argv{"sText35"} = $sText[35];
	$argv{"sText36"} = $sText[36];
	$argv{"sText37"} = $sText[37];
	$argv{"sText38"} = $sText[38];

	$argv{"para"} = "$IsNormal $IsApp $IsBig5 $IsSan $IsNormalWord $IsAppSign $IsJuanHead $IsPDA -o ";
	$argv{"para"} =~ s/ {2,}/ /g;
	$argv{"para"} = $argv{"para"} . $sText[2];
	
	$main::{'main'}(\%argv);
}

sub run_main_all					# ����D�{��
{
	#���P�_�O���O�u�n����
	
	my $run = $mw->messageBox(-title => '�T�{', 
		-message => '�T�w�n����ܡH', 
		-type => 'YesNo', -icon => 'question', -default => 'no');
	
	return if($run eq "no");
	
	return if(!check_data(\$entry3, 3));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry4, 4));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry5, 5));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry6, 6));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry7, 7));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry8, 8));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry9, 9));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry10, 10));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry11, 11));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry12, 12));			# �ˬd�ܼƬO�_�X�z
	
	return if(!check_data(\$entry13, 13));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry14, 14));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry15, 15));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry16, 16));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry17, 17));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry18, 18));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry19, 19));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry20, 20));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry21, 21));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry22, 22));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry23, 23));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry24, 24));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry25, 25));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry26, 26));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry27, 27));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry28, 28));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry29, 29));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry30, 30));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry31, 31));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry32, 32));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry33, 33));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry34, 34));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry35, 35));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry36, 36));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry37, 37));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry38, 38));			# �ˬd�ܼƬO�_�X�z
	
	push_alldata_2_entry();	# �� Entry ��J���s�J�U�Կ�椤
	
	# �ǳƦ������
	
	$argv{"sText1"} = $sText[1];

	$argv{"sText3"} = $sText[3];
	$argv{"sText4"} = $sText[4];
	$argv{"sText5"} = $sText[5];
	$argv{"sText6"} = $sText[6];
	$argv{"sText7"} = $sText[7];
	$argv{"sText8"} = $sText[8];
	$argv{"sText9"} = $sText[9];
	$argv{"sText10"} = $sText[10];
	$argv{"sText11"} = $sText[11];
	$argv{"sText12"} = $sText[12];

	$argv{"sText13"} = $sText[13];
	$argv{"sText14"} = $sText[14];
	$argv{"sText15"} = $sText[15];
	$argv{"sText16"} = $sText[16];
	$argv{"sText17"} = $sText[17];
	$argv{"sText18"} = $sText[18];
	$argv{"sText19"} = $sText[19];
	$argv{"sText20"} = $sText[20];
	$argv{"sText21"} = $sText[21];
	$argv{"sText22"} = $sText[22];
	$argv{"sText23"} = $sText[23];
	$argv{"sText24"} = $sText[24];
	$argv{"sText25"} = $sText[25];
	$argv{"sText26"} = $sText[26];
	$argv{"sText27"} = $sText[27];
	$argv{"sText28"} = $sText[28];
	$argv{"sText29"} = $sText[29];
	$argv{"sText30"} = $sText[30];
	$argv{"sText31"} = $sText[31];
	$argv{"sText32"} = $sText[32];
	$argv{"sText33"} = $sText[33];
	$argv{"sText34"} = $sText[34];
	$argv{"sText35"} = $sText[35];
	$argv{"sText36"} = $sText[36];
	$argv{"sText37"} = $sText[37];
	$argv{"sText38"} = $sText[38];
	
	if($sel_Big5Normal)		{ $argv{"para"} = '-u -o c:\release\normal';$main::{'main'}(\%argv);}
	if($sel_Big5App)		{ $argv{"para"} = '-a -o c:\release\app1';$main::{'main'}(\%argv);}
	if($sel_UTF8Normal)		{ $argv{"para"} = '-u -e utf8 -o c:\release\normal-utf8';$main::{'main'}(\%argv);}
	if($sel_UTF8App)		{ $argv{"para"} = '-a -e utf8 -o c:\release\app1-utf8';$main::{'main'}(\%argv);}
	if($sel_PDA)			{ $argv{"para"} = '-u -p -o c:\release\pda';$main::{'main'}(\%argv);}
	if($sel_Big5NormalDes)	{ $argv{"para"} = '-u -z -o c:\release\normal-des';$main::{'main'}(\%argv);}
	if($sel_Big5AppDes)		{ $argv{"para"} = '-a -z -o c:\release\app1-des';$main::{'main'}(\%argv);}
	if($sel_Big5AppJuan)	{ $argv{"para"} = '-u -a -o c:\release\app';$main::{'main'}(\%argv);}
	if($sel_Big5NoteSign)	{ $argv{"para"} = '-u -x 2 -z -k -h -o c:\release\normal';$main::{'main'}(\%argv);}
}

######################################################
# ��L��k
######################################################

# �w�]�����|
sub btSourcePath_click
{
	$sText[1] = "c:\\cbwork\\xml";
}
# �������
sub btAll_click
{
	$sText[3] = 1;
	$sText[4] = 85;
	$sText[5] = 1;
	$sText[6] = 88;
	$sText[7] = 1;
	$sText[8] = 40;
	$sText[9] = 1;
	$sText[10] = 1;
	$sText[11] = 1;	#W
	$sText[12] = 9;
	$sText[13] = 1;	#I
	$sText[14] = 1;
	
	$sText[15] = 91;	#A
	$sText[16] = 121;
	$sText[17] = 1;		#B
	$sText[18] = 36;	
	$sText[19] = 56;	#C
	$sText[20] = 106;
	$sText[21] = 1;		#D
	$sText[22] = 64;	
	$sText[23] = 1;		#F
	$sText[24] = 29;
	$sText[25] = 52;
	$sText[26] = 84;
	$sText[27] = 5;
	$sText[28] = 41;
	$sText[29] = 115;
	$sText[30] = 164;
	$sText[31] = 59;
	$sText[32] = 59;
	$sText[33] = 154;
	$sText[34] = 189;
	$sText[35] = 6;
	$sText[36] = 6;
	$sText[37] = 205;
	$sText[38] = 223;

}
# �����M��
sub btAll_clear_click
{
	$sText[3] = "";
	$sText[4] = "";
	$sText[5] = "";
	$sText[6] = "";
	$sText[7] = "";
	$sText[8] = "";
	$sText[9] = "";
	$sText[10] = "";

	$sText[11] = "";
	$sText[12] = "";
	$sText[13] = "";
	$sText[14] = "";
	$sText[15] = "";
	$sText[16] = "";
	$sText[17] = "";
	$sText[18] = "";
	$sText[19] = "";
	$sText[20] = "";
	$sText[21] = "";
	$sText[22] = "";
	$sText[23] = "";
	$sText[24] = "";
	$sText[25] = "";
	$sText[26] = "";
	$sText[27] = "";
	$sText[28] = "";
	$sText[29] = "";
	$sText[30] = "";
	$sText[31] = "";
	$sText[32] = "";
	$sText[33] = "";
	$sText[34] = "";
	$sText[35] = "";
	$sText[36] = "";
	$sText[37] = "";
	$sText[38] = "";
}

# �M���j��
sub btT_clear_click
{
	$sText[3] = "";
	$sText[4] = "";
}

# �M������
sub btX_clear_click
{
	$sText[5] = "";
	$sText[6] = "";
}
sub btJ_clear_click
{
	$sText[7] = "";
	$sText[8] = "";
}
sub btH_clear_click
{
	$sText[9] = "";
	$sText[10] = "";
}
sub btW_clear_click
{
	$sText[11] = "";
	$sText[12] = "";
}
sub btI_clear_click
{
	$sText[13] = "";
	$sText[14] = "";
}
# �M������
sub btA_clear_click
{
	$sText[15] = "";
	$sText[16] = "";
}
# �M���ɽs 
sub btB_clear_click
{
	$sText[17] = "";
	$sText[18] = "";
}
# �M�������� 
sub btC_clear_click
{
	$sText[19] = "";
	$sText[20] = "";
}
# �M����� 
sub btD_clear_click
{
	$sText[21] = "";
	$sText[22] = "";
}
# �M���Фs�۸g
sub btF_clear_click
{
	$sText[23] = "";
	$sText[24] = "";
}
# �M����Фj�øg
sub btG_clear_click
{
	$sText[25] = "";
	$sText[26] = "";
}
# �M�����R��
sub btK_clear_click
{
	$sText[27] = "";
	$sText[28] = "";
}
# �M��������
sub btL_clear_click
{
	$sText[29] = "";
	$sText[30] = "";
}
# �M���å���
sub btM_clear_click
{
	$sText[31] = "";
	$sText[32] = "";
}
# �M���ü֥_��
sub btP_clear_click
{
	$sText[33] = "";
	$sText[34] = "";
}
# �M�����ÿ��
sub btS_clear_click
{
	$sText[35] = "";
	$sText[36] = "";
}
# �M���x�Z�n��
sub btU_clear_click
{
	$sText[37] = "";
	$sText[38] = "";
}

sub bt_Big5Normal_click
{
	$IsNormal = '-u';
	$IsApp = '';
	$IsBig5 = '';
	$IsSan = '';
	$IsNormalWord = '';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\normal';
}
sub bt_Big5App_click
{
	$IsNormal = '';
	$IsApp = '-a';
	$IsBig5 = '';
	$IsSan = '';
	$IsNormalWord = '';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\app1';
}
sub bt_UTF8Normal_click
{
	$IsNormal = '-u';
	$IsApp = '';
	$IsBig5 = '-e utf8';
	$IsSan = '';
	$IsNormalWord = '';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\normal-utf8';
}
sub bt_UTF8App_click
{
	$IsNormal = '';
	$IsApp = '-a';
	$IsBig5 = '-e utf8';
	$IsSan = '';
	$IsNormalWord = '';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\app1-utf8';
}
sub bt_PDA_click
{
	$IsNormal = '-u';
	$IsApp = '';
	$IsBig5 = '';
	$IsSan = '';
	$IsNormalWord = '';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '-p';
	$sText[2] = 'c:\release\pda';
}
sub bt_Big5NormalDes_click
{
	$IsNormal = '-u';
	$IsApp = '';
	$IsBig5 = '';
	$IsSan = '';
	$IsNormalWord = '-z';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\normal-des';
}
sub bt_Big5AppDes_click
{
	$IsNormal = '';
	$IsApp = '-a';
	$IsBig5 = '';
	$IsSan = '';
	$IsNormalWord = '-z';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\app1-des';
}
sub bt_Big5AppJuan_click
{
	$IsNormal = '-u';
	$IsApp = '-a';
	$IsBig5 = '';
	$IsSan = '';
	$IsNormalWord = '';
	$IsAppSign = '';
	$IsJuanHead = '';
	$IsPDA = '';
	$sText[2] = 'c:\release\app';
}
# xml2txt -v $vol -u -h -k -x 2 -z  c:\release\normal
sub bt_Big5NoteSign_click
{
	$IsNormal = '-u';
	$IsApp = '';
	$IsBig5 = '';
	$IsSan = '-x 2';
	$IsNormalWord = '-z';
	$IsAppSign = '-k';
	$IsJuanHead = '-h';
	$IsPDA = '';
	$sText[2] = 'c:\release\normal';
}

sub bt_checkall_click
{
	if(!($sel_Big5Normal && $sel_Big5App && $sel_UTF8Normal && $sel_UTF8App && $sel_PDA && $sel_Big5NormalDes && 
	   $sel_Big5AppDes  && $sel_Big5AppJuan && $sel_Big5NoteSign))
	{
		$sel_All = 0;
	}
	else
	{
		$sel_All = 1;
	}
}

sub sel_All_click
{
	$sel_Big5Normal = $sel_All;
	$sel_Big5App = $sel_All;
	$sel_UTF8Normal = $sel_All;
	$sel_UTF8App = $sel_All;
	$sel_PDA = $sel_All;
	$sel_Big5NormalDes = $sel_All;
	$sel_Big5AppDes = $sel_All;
	$sel_Big5AppJuan = $sel_All;
	$sel_Big5NoteSign = $sel_All;
}

# ���\���榡�� 1~3 �쪺�¼Ʀr, �γo�خ榡  1,2,(6..9),10,12
# �Y�Ǧ^ 0 �N��ܦ����D�F
sub check_data
{
	local * widget = shift;
	my $i = shift;
	my $data = $sText[$i];
	
	return 1 if($data =~ /^\d{1,3}$/);		# �¤@�ΤG�ΤT��Ʀr, ok
	
	my @nums = split(/,/,$data);
	
	for $i (@nums)
	{
		if($i =~ /^\((\d{1,3})\.\.(\d{1,3})\)$/)
		{
			# (1..4) �o�خ榡
			my $tmp1 = $1;
			my $tmp2 = $2;
			
			if($tmp2 < $tmp1)
			{
				my $errmsg = "�Ѽ� $i �����D";
				$mw->messageBox(-title => '���~', -message => $errmsg, -type => 'OK');
				$widget->focus();
				return 0;
			}
		}
		elsif($i =~ /^\d{1,3}$/)
		{
		}
		else
		{
			my $errmsg = "�Ѽ� $i �����D";
			$mw->messageBox(-title => '���~', -message => $errmsg, -type => 'OK');
			$widget->focus();
			return 0;
		}
	}
	return 1;
}

sub show
{
	my $this = shift;

	Tk::CmdLine::SetArguments(-font, "�ө��� 12");			# �]�w�w�]�r��
	$mw = MainWindow->new;
	$mw->title("CBETA �U���g�岣�͵{��");
	load_ini();					# �� ini �̭����F���J�}�C��
	make_all_frame();	# ���X 4 �� frame	

	######################################################
	# �B�z�C�@�� frame �̭�������
	######################################################

	show_top_frame();
	show_bottom_frame();
	show_left_frame();
	show_mid_frame();
	show_right_frame();

	MainLoop;		# �@�w�n���������T���j��
}

sub make_all_frame
{	
	$fmTop = $mw->Frame(-borderwidth => 4, -relief => 'groove')->pack(	# 'flat' | 'groove' | 'raised' | 'ridge' | 'sunken'
		-side => 'top',
		-fill => 'both',
		-padx => 5,
		-pady => 5,
		);
	
	$fmBottom = $mw->Frame(-borderwidth => 4, -relief => 'groove')->pack(
		-side => 'bottom',
		-fill => 'both',
		-padx => 5,
		-pady => 5,
		);
	$fmLeft = $mw->Frame(-borderwidth => 4, -relief => 'groove')->pack(
		-side => 'left',
		-fill => 'both',
		-padx => 5,
		-pady => 5,
		);
	$fmMid = $mw->Frame(-borderwidth => 4, -relief => 'groove')->pack(
		-side => 'left',
		-fill => 'both',
		-expand => 1,
		-padx => 5,
		-pady => 5,
		);
		
	$fmRight = $mw->Frame(-borderwidth => 4, -relief => 'groove')->pack(
		-side => 'right',
		-fill => 'both',
		-padx => 5,
		-pady => 5,
		);
}

sub show_top_frame
{
	# �̤W�誺����
	$fmTop->Label(
		-text => "�� XML2TXT_ALL ���@�� XML ���ͦU�ت������g��",
		)->pack(
			-side => 'left',
			-padx => 10,			# �ե󥪥k�d�Ťj�p 10
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
}

sub show_bottom_frame
{
	# �U�誺����, ����, ����
	
	$fmBottom->Button(
		-text => "����", 
		-command => sub {$mw->destroy},
		)->pack(
			-side => 'right',
			-padx => 5,			# �ե󥪥k�d�Ťj�p 10
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
			
	$fmBottom->Button(
		-text => "����", 
		-command => \&show_readme,
		)->pack(
			-side => 'right',
			-padx => 10,			# �ե󥪥k�d�Ťj�p 10
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
			
	$fmBottom->Button(
		-text => "����W��ҿ�Ѽ�", 
		-command => \&run_main,			# ����D�{�� , �öǤJ�Ҧ��Ѽ�
		)->pack(
			-side => 'right',
			-padx => 20,			# �ե󥪥k�d�Ťj�p 20
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
			
	$fmBottom->Button(
		-text => "����W��ҿ�w�]�U��", 
		-command => \&run_main_all,			# ����D�{�� , �öǤJ�Ҧ��Ѽ�
		)->pack(
			-side => 'left',
			-padx => 20,			# �ե󥪥k�d�Ťj�p 20
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
}

sub show_mid_frame
{
	# �A�ؤ@�� frame , �⩳�U�� grid ���ܼƶ����b�W�� ------------------------------
	
	$fmMidTop = $fmMid->Frame()->pack(
		-side => 'top',
		-fill => 'both',
		-padx => 10,
		-pady => 10,
		);
	
	# �D�n���ܼ� ###################################
	
	$bt1 = $fmMidTop->Button(-text => '�M��',-command => \&btT_clear_click);
	$bt2 = $fmMidTop->Button(-text => '�M��',-command => \&btX_clear_click);
	$bt3 = $fmMidTop->Button(-text => '�M��',-command => \&btJ_clear_click);
	$bt4 = $fmMidTop->Button(-text => '�M��',-command => \&btH_clear_click);
	$bt5 = $fmMidTop->Button(-text => '�M��',-command => \&btW_clear_click);
	$bt6 = $fmMidTop->Button(-text => '�M��',-command => \&btI_clear_click);
	$bt7 = $fmMidTop->Button(-text => '�M��',-command => \&btA_clear_click);
	$bt8 = $fmMidTop->Button(-text => '�M��',-command => \&btB_clear_click);
	$bt9 = $fmMidTop->Button(-text => '�M��',-command => \&btC_clear_click);
	$bt10 = $fmMidTop->Button(-text => '�M��',-command => \&btD_clear_click);
	$bt11 = $fmMidTop->Button(-text => '�M��',-command => \&btF_clear_click);
	$bt12 = $fmMidTop->Button(-text => '�M��',-command => \&btG_clear_click);
	$bt13 = $fmMidTop->Button(-text => '�M��',-command => \&btK_clear_click);
	$bt14 = $fmMidTop->Button(-text => '�M��',-command => \&btL_clear_click);
	$bt15 = $fmMidTop->Button(-text => '�M��',-command => \&btM_clear_click);
	$bt16 = $fmMidTop->Button(-text => '�M��',-command => \&btP_clear_click);
	$bt17 = $fmMidTop->Button(-text => '�M��',-command => \&btS_clear_click);
	$bt18 = $fmMidTop->Button(-text => '�M��',-command => \&btU_clear_click);	

	# �Ĥ@��
	$label[1] = $fmMidTop->Label(-text => "�ӷ��ؿ� �G",);
	$entry1 = $fmMidTop->BrowseEntry(-variable => \$sText[1], -choices => \@sText1);				# ��J��r���ܼ�	
	#Tk::grid($label[1], $entry1, -sticky => "ew",-padx => 1,-pady => 0,);
	# �ĤG��
	$label[2] = $fmMidTop->Label(-text => "��X�ؿ� �G",);
	$entry2 = $fmMidTop->BrowseEntry(-variable => \$sText[2], -choices => \@sText2);				# ��J��r���ܼ�		
	Tk::grid($label[1], $entry1, $label[2], $entry2, -sticky => "ew",-padx => 1,-pady => 5,);
	
	# �ĤT��
	$label[3] = $fmMidTop->Label(-text => "(T)�j���á@�q�G",);
	$entry3 = $fmMidTop->BrowseEntry(-variable => \$sText[3], -choices => \@sText3);				# ��J��r���ܼ�		
	# Tk::grid($label[3], $entry3, -sticky => "ew",-padx => 1,-pady => 10,);
	# �ĥ|��
	$label[4] = $fmMidTop->Label(-text => "��G",);
	$entry4 = $fmMidTop->BrowseEntry(-variable => \$sText[4], -choices => \@sText4);				# ��J��r���ܼ�		
	Tk::grid($label[3], $entry3, $label[4], $entry4, $bt1, -sticky => "ew",-padx => 1,-pady => 0,);

	# �Ĥ���
	$label[5] = $fmMidTop->Label(-text => "(X)�����á@�q�G",);
	$entry5 = $fmMidTop->BrowseEntry(-variable => \$sText[5], -choices => \@sText5);				# ��J��r���ܼ�		
	#Tk::grid($label[5], $entry5, -sticky => "ew",-padx => 1,-pady => 10,);
	# �Ĥ���
	$label[6] = $fmMidTop->Label(-text => "��G",);
	$entry6 = $fmMidTop->BrowseEntry(-variable => \$sText[6], -choices => \@sText6);				# ��J��r���ܼ�		
	Tk::grid($label[5], $entry5, $label[6], $entry6, $bt2, -sticky => "ew",-padx => 1,-pady => 0,);

	# �ĤC��
	$label[7] = $fmMidTop->Label(-text => "(J)�ſ��á@�q�G",);
	$entry7 = $fmMidTop->BrowseEntry(-variable => \$sText[7], -choices => \@sText7);				# ��J��r���ܼ�		
	#Tk::grid($label[7], $entry7, -sticky => "ew",-padx => 1,-pady => 10,);
	# �ĤK��
	$label[8] = $fmMidTop->Label(-text => "��G",);
	$entry8 = $fmMidTop->BrowseEntry(-variable => \$sText[8], -choices => \@sText8);				# ��J��r���ܼ�		
	Tk::grid($label[7], $entry7, $label[8], $entry8, $bt3, -sticky => "ew",-padx => 1,-pady => 0,);

	# �ĤE��
	$label[9] = $fmMidTop->Label(-text => "(H)�@���v�@�q�G",);
	$entry9 = $fmMidTop->BrowseEntry(-variable => \$sText[9], -choices => \@sText9);				# ��J��r���ܼ�		
	#Tk::grid($label[9], $entry9, -sticky => "ew",-padx => 1,-pady => 10,);
	# �ĤQ��
	$label[10] = $fmMidTop->Label(-text => "��G",);
	$entry10 = $fmMidTop->BrowseEntry(-variable => \$sText[10], -choices => \@sText10);				# ��J��r���ܼ�		
	Tk::grid($label[9], $entry9, $label[10], $entry10, $bt4, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[11] = $fmMidTop->Label(-text => "(W)�@�å~�@�q�G",);
	$entry11 = $fmMidTop->BrowseEntry(-variable => \$sText[11], -choices => \@sText11);				# ��J��r���ܼ�		
	$label[12] = $fmMidTop->Label(-text => "��G",);
	$entry12 = $fmMidTop->BrowseEntry(-variable => \$sText[12], -choices => \@sText12);				# ��J��r���ܼ�		
	Tk::grid($label[11], $entry11, $label[12], $entry12, $bt5, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[13] = $fmMidTop->Label(-text => "(I)�@�ʫ~�@�q�G",);
	$entry13 = $fmMidTop->BrowseEntry(-variable => \$sText[13], -choices => \@sText13);				# ��J��r���ܼ�		
	$label[14] = $fmMidTop->Label(-text => "��G",);
	$entry14 = $fmMidTop->BrowseEntry(-variable => \$sText[14], -choices => \@sText14);				# ��J��r���ܼ�		
	Tk::grid($label[13], $entry13, $label[14], $entry14, $bt6, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[15] = $fmMidTop->Label(-text => "(A)�@���á@�q�G",);
	$entry15 = $fmMidTop->BrowseEntry(-variable => \$sText[15], -choices => \@sText15);				# ��J��r���ܼ�		
	$label[16] = $fmMidTop->Label(-text => "��G",);
	$entry16 = $fmMidTop->BrowseEntry(-variable => \$sText[16], -choices => \@sText16);				# ��J��r���ܼ�		
	Tk::grid($label[15], $entry15, $label[16], $entry16, $bt7, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[17] = $fmMidTop->Label(-text => "(B)�@�ɽs�@�q�G",);
	$entry17 = $fmMidTop->BrowseEntry(-variable => \$sText[17], -choices => \@sText17);				# ��J��r���ܼ�		
	$label[18] = $fmMidTop->Label(-text => "��G",);
	$entry18 = $fmMidTop->BrowseEntry(-variable => \$sText[18], -choices => \@sText18);				# ��J��r���ܼ�		
	Tk::grid($label[17], $entry17, $label[18], $entry18, $bt8, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[19] = $fmMidTop->Label(-text => "(C)�����á@�q�G",);
	$entry19 = $fmMidTop->BrowseEntry(-variable => \$sText[19], -choices => \@sText19);				# ��J��r���ܼ�		
	$label[20] = $fmMidTop->Label(-text => "��G",);
	$entry20 = $fmMidTop->BrowseEntry(-variable => \$sText[20], -choices => \@sText20);				# ��J��r���ܼ�		
	Tk::grid($label[19], $entry19, $label[20], $entry20, $bt9, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[21] = $fmMidTop->Label(-text => "(D)�@��ϡ@�q�G",);
	$entry21 = $fmMidTop->BrowseEntry(-variable => \$sText[21], -choices => \@sText21);				# ��J��r���ܼ�		
	$label[22] = $fmMidTop->Label(-text => "��G",);
	$entry22 = $fmMidTop->BrowseEntry(-variable => \$sText[22], -choices => \@sText22);				# ��J��r���ܼ�		
	Tk::grid($label[21], $entry21, $label[22], $entry22, $bt10, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[23] = $fmMidTop->Label(-text => "(F)�Фs�۸g�q�G",);
	$entry23 = $fmMidTop->BrowseEntry(-variable => \$sText[23], -choices => \@sText23);				# ��J��r���ܼ�		
	$label[24] = $fmMidTop->Label(-text => "��G",);
	$entry24 = $fmMidTop->BrowseEntry(-variable => \$sText[24], -choices => \@sText24);				# ��J��r���ܼ�		
	Tk::grid($label[23], $entry23, $label[24], $entry24, $bt11, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[25] = $fmMidTop->Label(-text => "(G)����á@�q�G",);
	$entry25 = $fmMidTop->BrowseEntry(-variable => \$sText[25], -choices => \@sText25);				# ��J��r���ܼ�		
	$label[26] = $fmMidTop->Label(-text => "��G",);
	$entry26 = $fmMidTop->BrowseEntry(-variable => \$sText[26], -choices => \@sText26);				# ��J��r���ܼ�		
	Tk::grid($label[25], $entry25, $label[26], $entry26, $bt12, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[27] = $fmMidTop->Label(-text => "(K)���R�á@�q�G",);
	$entry27 = $fmMidTop->BrowseEntry(-variable => \$sText[27], -choices => \@sText27);				# ��J��r���ܼ�		
	$label[28] = $fmMidTop->Label(-text => "��G",);
	$entry28 = $fmMidTop->BrowseEntry(-variable => \$sText[28], -choices => \@sText28);				# ��J��r���ܼ�		
	Tk::grid($label[27], $entry27, $label[28], $entry28, $bt13, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[29] = $fmMidTop->Label(-text => "(L)�����á@�q�G",);
	$entry29 = $fmMidTop->BrowseEntry(-variable => \$sText[29], -choices => \@sText29);				# ��J��r���ܼ�		
	$label[30] = $fmMidTop->Label(-text => "��G",);
	$entry30 = $fmMidTop->BrowseEntry(-variable => \$sText[30], -choices => \@sText30);				# ��J��r���ܼ�		
	Tk::grid($label[29], $entry29, $label[30], $entry30, $bt14, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[31] = $fmMidTop->Label(-text => "(M)�å��á@�q�G",);
	$entry31 = $fmMidTop->BrowseEntry(-variable => \$sText[31], -choices => \@sText31);				# ��J��r���ܼ�		
	$label[32] = $fmMidTop->Label(-text => "��G",);
	$entry32 = $fmMidTop->BrowseEntry(-variable => \$sText[32], -choices => \@sText32);				# ��J��r���ܼ�		
	Tk::grid($label[31], $entry31, $label[32], $entry32, $bt15, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[33] = $fmMidTop->Label(-text => "(P)�ü֥_�ñq�G",);
	$entry33 = $fmMidTop->BrowseEntry(-variable => \$sText[33], -choices => \@sText33);				# ��J��r���ܼ�		
	$label[34] = $fmMidTop->Label(-text => "��G",);
	$entry34 = $fmMidTop->BrowseEntry(-variable => \$sText[34], -choices => \@sText34);				# ��J��r���ܼ�		
	Tk::grid($label[33], $entry33, $label[34], $entry34, $bt16, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[35] = $fmMidTop->Label(-text => "(S)���ÿ�ñq�G",);
	$entry35 = $fmMidTop->BrowseEntry(-variable => \$sText[35], -choices => \@sText35);				# ��J��r���ܼ�		
	$label[36] = $fmMidTop->Label(-text => "��G",);
	$entry36 = $fmMidTop->BrowseEntry(-variable => \$sText[36], -choices => \@sText36);				# ��J��r���ܼ�		
	Tk::grid($label[35], $entry35, $label[36], $entry36, $bt17, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[37] = $fmMidTop->Label(-text => "(U)�x�Z�n�ñq�G",);
	$entry37 = $fmMidTop->BrowseEntry(-variable => \$sText[37], -choices => \@sText37);				# ��J��r���ܼ�		
	$label[38] = $fmMidTop->Label(-text => "��G",);
	$entry38 = $fmMidTop->BrowseEntry(-variable => \$sText[38], -choices => \@sText38);				# ��J��r���ܼ�		
	Tk::grid($label[37], $entry37, $label[38], $entry38, $bt18, -sticky => "ew",-padx => 1,-pady => 0,);

	$fmMidTop->gridColumnconfigure(1, -weight => 1);

	# �A�ؤ@�� frame , �]�m�U�ؿﶵ ------------------------------------------------
		
	$fmLeftThird = $fmMid->LabFrame(-label => "��L�ﶵ",
		-labelside => 'acrosstop')->pack(-side => 'top', -anchor => 'w', -padx => 15, -pady => 5);
		
	$fmLeftThird->Checkbutton( -text => '�ϥγq�Φr', -variable => \$IsNormalWord, -onvalue => '', -offvalue => '-z',
		)->grid(
		$fmLeftThird->Checkbutton( -text => '��ܮհɲŸ�����', -variable => \$IsAppSign, -onvalue => '-k', -offvalue => ''),
		-padx => 5, -pady => 5, -sticky => "w");
		
	$fmLeftThird->Checkbutton( -text => '������Y��T', -variable => \$IsJuanHead, -onvalue => '', -offvalue => '-h',
		)->grid(
		$fmLeftThird->Checkbutton( -text => '��²�榡 (for PDA)', -variable => \$IsPDA, -onvalue => '-p', -offvalue => ''),
		-padx => 5, -pady => 5, -sticky => "w");
}

sub show_right_frame
{
	# �k�誺������s
	
	$fmRight->Button(
		-text => '�w�]�ӷ����|',
		-command => \&btSourcePath_click,
		)->pack(
			-side => 'top',
			-padx => 10,		# �ե󥪥k�d�Ťj�p 10
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
			
	$fmRight->Button(
		-text => '��������U��',
		-command => \&btAll_click,
		)->pack(
			-side => 'top',
			-padx => 10,		# �ե󥪥k�d�Ťj�p 10
			-pady => 5,			# �ե�W�U�d�Ťj�p 10
			);
	$fmRight->Button(
		-text => '�M�������U��',
		-command => \&btAll_clear_click,
		)->pack(
			-side => 'top',
			-padx => 10,		# �ե󥪥k�d�Ťj�p 10
			-pady => 5,			# �ե�W�U�d�Ťj�p 10
			);

	# ��� �@���@�ɩΤ@�g�@�� �� labframe (radiogroup)
	
	$lfNormal = $fmRight->LabFrame(-label => "�ɮ׮榡",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');
	
	$lfNormal->Radiobutton(
		-text => '�@���@��', 
		-variable => \$IsNormal, 
		-value => '-u',
		)->pack;

	$lfNormal->Radiobutton(
		-text => '�@�g�@��', 
		-variable => \$IsNormal, 
		-value => '',
		)->pack;
	
	# ��� normal �� app �� labframe (radiogroup)
	
	$lfApp = $fmRight->LabFrame(-label => "�ɮת���",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');

	$lfApp->Radiobutton(
		-text => '���Ϊ�', 
		-variable => \$IsApp, 
		-value => '',
		)->pack;

	$lfApp->Radiobutton(
		-text => 'App ��', 
		-variable => \$IsApp, 
		-value => '-a',
		)->pack;
		
	# ��� Big5 �� utf8 �� labframe (radiogroup)
	
	$lfBig5 = $fmRight->LabFrame(-label => "�r��",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');
	
	$lfBig5->Radiobutton(
		-text => 'Big5 ��', 
		-variable => \$IsBig5, 
		-value => '',
		)->pack;

	$lfBig5->Radiobutton(
		-text => 'UTF8 ��', 
		-variable => \$IsBig5, 
		-value => '-e utf8',
		)->pack;
		
	# ��ܱ��(�x��B����)�e�{���� labframe (radiogroup)
	
	$lfSan = $fmRight->LabFrame(-label => "�x�������e�{",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');
	
	$lfSan->Radiobutton(
		-text => 'ù����g�r', 
		-variable => \$IsSan, 
		-value => '',
		)->pack(-anchor => "w");

	$lfSan->Radiobutton(
		-text => '&SD-xxxx;', 
		-variable => \$IsSan, 
		-value => '-x 1',
		)->pack(-anchor => "w");
		
	$lfSan->Radiobutton(
		-text => '���i���j', 
		-variable => \$IsSan, 
		-value => '-x 2',
		)->pack(-anchor => "w");
}

sub show_left_frame
{
	$fmLeft2 = $fmLeft->Frame()->pack(-padx => 10);
	
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5Normal, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5���Ϊ�',-command => \&bt_Big5Normal_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5App, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 App��', -command => \&bt_Big5App_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_UTF8Normal, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'UTF8���Ϊ�',-command => \&bt_UTF8Normal_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_UTF8App, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'UTF8 App��',-command => \&bt_UTF8App_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_PDA, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'PDA ��',-command => \&bt_PDA_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	
	
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5NormalDes, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 ���Ϊ�(�զr)',-command => \&bt_Big5NormalDes_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5AppDes, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 App��(�զr)',-command => \&bt_Big5AppDes_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5AppJuan, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 App��(���)',-command => \&bt_Big5AppJuan_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	# xml2txt -v $vol -u -h -k -x 2 -z  c:\release\normal
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5NoteSign, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => '�ժ`��睊(���)',-command => \&bt_Big5NoteSign_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '����', -variable => \$sel_All, -command => \&sel_All_click,
		)->grid("-",
		-padx => 0, -pady => 5, -sticky => "w");
}

# �� Entry ��J���s�J�U�Կ�椤

sub push_alldata_2_entry
{
	if (!$sText1{$sText[1]} && $sText[1] ne "") 
	{
		$entry1->insert(0, $sText[1]);
		unshift(@sText1 , $sText[1]);
	 	$sText1{$sText[1]}++;
	 	if($#sText1 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry1->delete($#sText1,$#sText1);
	 		$sText1{$sText1[$#sText1]} = 0;
	 		pop(@sText1);
	 	}
	}
	if (!$sText2{$sText[2]} && $sText[2] ne "") 
	{
		$entry2->insert(0, $sText[2]);
		unshift(@sText2 , $sText[2]);
	 	$sText2{$sText[2]}++;
	 	if($#sText2 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry2->delete($#sText2,$#sText2);
	 		$sText2{$sText2[$#sText2]} = 0;
	 		pop(@sText2);
	 	}
	}
	if (!$sText3{$sText[3]} && $sText[3] ne "") 
	{
		$entry3->insert(0, $sText[3]);
		unshift(@sText3 , $sText[3]);
	 	$sText3{$sText[3]}++;
	 	if($#sText3 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry3->delete($#sText3,$#sText3);
	 		$sText3{$sText3[$#sText3]} = 0;
	 		pop(@sText3);
	 	}
	}
	if (!$sText4{$sText[4]} && $sText[4] ne "") 
	{
		$entry4->insert(0, $sText[4]);
		unshift(@sText4 , $sText[4]);
	 	$sText4{$sText[4]}++;
	 	if($#sText4 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry4->delete($#sText4,$#sText4);
	 		$sText4{$sText4[$#sText4]} = 0;
	 		pop(@sText4);
	 	}
	}
	if (!$sText5{$sText[5]} && $sText[5] ne "") 
	{
		$entry5->insert(0, $sText[5]);
		unshift(@sText5 , $sText[5]);
	 	$sText5{$sText[5]}++;
	 	if($#sText5 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry5->delete($#sText5,$#sText5);
	 		$sText5{$sText5[$#sText5]} = 0;
	 		pop(@sText5);
	 	}
	}
	if (!$sText6{$sText[6]} && $sText[6] ne "") 
	{
		$entry6->insert(0, $sText[6]);
		unshift(@sText6 , $sText[6]);
	 	$sText6{$sText[6]}++;
	 	if($#sText6 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry6->delete($#sText6,$#sText6);
	 		$sText6{$sText6[$#sText6]} = 0;
	 		pop(@sText6);
	 	}
	}
	if (!$sText7{$sText[7]} && $sText[7] ne "") 
	{
		$entry7->insert(0, $sText[7]);
		unshift(@sText7 , $sText[7]);
	 	$sText7{$sText[7]}++;
	 	if($#sText7 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry7->delete($#sText7,$#sText7);
	 		$sText7{$sText7[$#sText7]} = 0;
	 		pop(@sText7);
	 	}
	}
	if (!$sText8{$sText[8]} && $sText[8] ne "") 
	{
		$entry8->insert(0, $sText[8]);
		unshift(@sText8 , $sText[8]);
	 	$sText8{$sText[8]}++;
	 	if($#sText8 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry8->delete($#sText8,$#sText8);
	 		$sText8{$sText8[$#sText8]} = 0;
	 		pop(@sText8);
	 	}
	}
	if (!$sText9{$sText[9]} && $sText[9] ne "") 
	{
		$entry9->insert(0, $sText[9]);
		unshift(@sText9 , $sText[9]);
	 	$sText9{$sText[9]}++;
	 	if($#sText9 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry9->delete($#sText9,$#sText9);
	 		$sText9{$sText9[$#sText9]} = 0;
	 		pop(@sText9);
	 	}
	}
	if (!$sText10{$sText[10]} && $sText[10] ne "") 
	{
		$entry10->insert(0, $sText[10]);
		unshift(@sText10 , $sText[10]);
	 	$sText10{$sText[10]}++;
	 	if($#sText10 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry10->delete($#sText10,$#sText10);
	 		$sText10{$sText10[$#sText10]} = 0;
	 		pop(@sText10);
	 	}
	}
	if (!$sText11{$sText[11]} && $sText[11] ne "") 
	{
		$entry11->insert(0, $sText[11]);
		unshift(@sText11 , $sText[11]);
	 	$sText11{$sText[11]}++;
	 	if($#sText11 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry11->delete($#sText11,$#sText11);
	 		$sText11{$sText11[$#sText11]} = 0;
	 		pop(@sText11);
	 	}
	}
	if (!$sText12{$sText[12]} && $sText[12] ne "") 
	{
		$entry12->insert(0, $sText[12]);
		unshift(@sText12 , $sText[12]);
	 	$sText12{$sText[12]}++;
	 	if($#sText12 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry12->delete($#sText12,$#sText12);
	 		$sText12{$sText12[$#sText12]} = 0;
	 		pop(@sText12);
	 	}
	}
	if (!$sText13{$sText[13]} && $sText[13] ne "") 
	{
		$entry13->insert(0, $sText[13]);
		unshift(@sText13 , $sText[13]);
	 	$sText13{$sText[13]}++;
	 	if($#sText13 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry13->delete($#sText13,$#sText13);
	 		$sText13{$sText13[$#sText13]} = 0;
	 		pop(@sText13);
	 	}
	}
	if (!$sText14{$sText[14]} && $sText[14] ne "") 
	{
		$entry14->insert(0, $sText[14]);
		unshift(@sText14 , $sText[14]);
	 	$sText14{$sText[14]}++;
	 	if($#sText14 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry14->delete($#sText14,$#sText14);
	 		$sText14{$sText14[$#sText14]} = 0;
	 		pop(@sText14);
	 	}
	}
	if (!$sText15{$sText[15]} && $sText[15] ne "") 
	{
		$entry15->insert(0, $sText[15]);
		unshift(@sText15 , $sText[15]);
	 	$sText15{$sText[15]}++;
	 	if($#sText15 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry15->delete($#sText15,$#sText15);
	 		$sText15{$sText15[$#sText15]} = 0;
	 		pop(@sText15);
	 	}
	}
	if (!$sText16{$sText[16]} && $sText[16] ne "") 
	{
		$entry16->insert(0, $sText[16]);
		unshift(@sText16 , $sText[16]);
	 	$sText16{$sText[16]}++;
	 	if($#sText16 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry16->delete($#sText16,$#sText16);
	 		$sText16{$sText16[$#sText16]} = 0;
	 		pop(@sText16);
	 	}
	}
	if (!$sText17{$sText[17]} && $sText[17] ne "") 
	{
		$entry17->insert(0, $sText[17]);
		unshift(@sText17 , $sText[17]);
	 	$sText17{$sText[17]}++;
	 	if($#sText17 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry17->delete($#sText17,$#sText17);
	 		$sText17{$sText17[$#sText17]} = 0;
	 		pop(@sText17);
	 	}
	}
	if (!$sText18{$sText[18]} && $sText[18] ne "") 
	{
		$entry18->insert(0, $sText[18]);
		unshift(@sText18 , $sText[18]);
	 	$sText18{$sText[18]}++;
	 	if($#sText18 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry18->delete($#sText18,$#sText18);
	 		$sText18{$sText18[$#sText18]} = 0;
	 		pop(@sText18);
	 	}
	}
	if (!$sText19{$sText[19]} && $sText[19] ne "") 
	{
		$entry19->insert(0, $sText[19]);
		unshift(@sText19 , $sText[19]);
	 	$sText19{$sText[19]}++;
	 	if($#sText19 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry19->delete($#sText19,$#sText19);
	 		$sText19{$sText19[$#sText19]} = 0;
	 		pop(@sText19);
	 	}
	}
	if (!$sText20{$sText[20]} && $sText[20] ne "") 
	{
		$entry20->insert(0, $sText[20]);
		unshift(@sText20 , $sText[20]);
	 	$sText20{$sText[20]}++;
	 	if($#sText20 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry20->delete($#sText20,$#sText20);
	 		$sText20{$sText20[$#sText20]} = 0;
	 		pop(@sText20);
	 	}
	}
	if (!$sText21{$sText[21]} && $sText[21] ne "") 
	{
		$entry21->insert(0, $sText[21]);
		unshift(@sText21 , $sText[21]);
	 	$sText21{$sText[21]}++;
	 	if($#sText21 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry21->delete($#sText21,$#sText21);
	 		$sText21{$sText21[$#sText21]} = 0;
	 		pop(@sText21);
	 	}
	}
	if (!$sText22{$sText[22]} && $sText[22] ne "") 
	{
		$entry22->insert(0, $sText[22]);
		unshift(@sText22 , $sText[22]);
	 	$sText22{$sText[22]}++;
	 	if($#sText22 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry22->delete($#sText22,$#sText22);
	 		$sText22{$sText22[$#sText22]} = 0;
	 		pop(@sText22);
	 	}
	}
	if (!$sText23{$sText[23]} && $sText[23] ne "") 
	{
		$entry23->insert(0, $sText[23]);
		unshift(@sText23 , $sText[23]);
	 	$sText23{$sText[23]}++;
	 	if($#sText23 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry23->delete($#sText23,$#sText23);
	 		$sText23{$sText23[$#sText23]} = 0;
	 		pop(@sText23);
	 	}
	}
	if (!$sText24{$sText[24]} && $sText[24] ne "") 
	{
		$entry24->insert(0, $sText[24]);
		unshift(@sText24 , $sText[24]);
	 	$sText24{$sText[24]}++;
	 	if($#sText24 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry24->delete($#sText24,$#sText24);
	 		$sText24{$sText24[$#sText24]} = 0;
	 		pop(@sText24);
	 	}
	}
	if (!$sText25{$sText[25]} && $sText[25] ne "") 
	{
		$entry25->insert(0, $sText[25]);
		unshift(@sText25 , $sText[25]);
	 	$sText25{$sText[25]}++;
	 	if($#sText25 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry25->delete($#sText25,$#sText25);
	 		$sText25{$sText25[$#sText25]} = 0;
	 		pop(@sText25);
	 	}
	}
	if (!$sText26{$sText[26]} && $sText[26] ne "") 
	{
		$entry26->insert(0, $sText[26]);
		unshift(@sText26 , $sText[26]);
	 	$sText26{$sText[26]}++;
	 	if($#sText26 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry26->delete($#sText26,$#sText26);
	 		$sText26{$sText26[$#sText26]} = 0;
	 		pop(@sText26);
	 	}
	}
	if (!$sText27{$sText[27]} && $sText[27] ne "") 
	{
		$entry27->insert(0, $sText[27]);
		unshift(@sText27 , $sText[27]);
	 	$sText27{$sText[27]}++;
	 	if($#sText27 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry27->delete($#sText27,$#sText27);
	 		$sText27{$sText27[$#sText27]} = 0;
	 		pop(@sText27);
	 	}
	}
	if (!$sText28{$sText[28]} && $sText[28] ne "") 
	{
		$entry28->insert(0, $sText[28]);
		unshift(@sText28 , $sText[28]);
	 	$sText28{$sText[28]}++;
	 	if($#sText28 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry28->delete($#sText28,$#sText28);
	 		$sText28{$sText28[$#sText28]} = 0;
	 		pop(@sText28);
	 	}
	}
	if (!$sText29{$sText[29]} && $sText[29] ne "") 
	{
		$entry29->insert(0, $sText[29]);
		unshift(@sText29 , $sText[29]);
	 	$sText29{$sText[29]}++;
	 	if($#sText29 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry29->delete($#sText29,$#sText29);
	 		$sText29{$sText29[$#sText29]} = 0;
	 		pop(@sText29);
	 	}
	}
	if (!$sText30{$sText[30]} && $sText[30] ne "") 
	{
		$entry30->insert(0, $sText[30]);
		unshift(@sText30 , $sText[30]);
	 	$sText30{$sText[30]}++;
	 	if($#sText30 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry30->delete($#sText30,$#sText30);
	 		$sText30{$sText30[$#sText30]} = 0;
	 		pop(@sText30);
	 	}
	}
	if (!$sText31{$sText[31]} && $sText[31] ne "") 
	{
		$entry31->insert(0, $sText[31]);
		unshift(@sText31 , $sText[31]);
	 	$sText31{$sText[31]}++;
	 	if($#sText31 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry31->delete($#sText31,$#sText31);
	 		$sText31{$sText31[$#sText31]} = 0;
	 		pop(@sText31);
	 	}
	}
	if (!$sText32{$sText[32]} && $sText[32] ne "") 
	{
		$entry32->insert(0, $sText[32]);
		unshift(@sText32 , $sText[32]);
	 	$sText32{$sText[32]}++;
	 	if($#sText32 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry32->delete($#sText32,$#sText32);
	 		$sText32{$sText32[$#sText32]} = 0;
	 		pop(@sText32);
	 	}
	}
	if (!$sText33{$sText[33]} && $sText[33] ne "") 
	{
		$entry33->insert(0, $sText[33]);
		unshift(@sText33 , $sText[33]);
	 	$sText33{$sText[33]}++;
	 	if($#sText33 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry33->delete($#sText33,$#sText33);
	 		$sText33{$sText33[$#sText33]} = 0;
	 		pop(@sText33);
	 	}
	}
	if (!$sText34{$sText[34]} && $sText[34] ne "") 
	{
		$entry34->insert(0, $sText[34]);
		unshift(@sText34 , $sText[34]);
	 	$sText34{$sText[34]}++;
	 	if($#sText34 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry34->delete($#sText34,$#sText34);
	 		$sText34{$sText34[$#sText34]} = 0;
	 		pop(@sText34);
	 	}
	}
	if (!$sText35{$sText[35]} && $sText[35] ne "") 
	{
		$entry35->insert(0, $sText[35]);
		unshift(@sText35 , $sText[35]);
	 	$sText35{$sText[35]}++;
	 	if($#sText35 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry35->delete($#sText35,$#sText35);
	 		$sText35{$sText35[$#sText35]} = 0;
	 		pop(@sText35);
	 	}
	}
	if (!$sText36{$sText[36]} && $sText[36] ne "") 
	{
		$entry36->insert(0, $sText[36]);
		unshift(@sText36 , $sText[36]);
	 	$sText36{$sText[36]}++;
	 	if($#sText36 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry36->delete($#sText36,$#sText36);
	 		$sText36{$sText36[$#sText36]} = 0;
	 		pop(@sText36);
	 	}
	}
	if (!$sText37{$sText[37]} && $sText[37] ne "") 
	{
		$entry37->insert(0, $sText[37]);
		unshift(@sText37 , $sText[37]);
	 	$sText37{$sText[37]}++;
	 	if($#sText37 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry37->delete($#sText37,$#sText37);
	 		$sText37{$sText37[$#sText37]} = 0;
	 		pop(@sText37);
	 	}
	}
	if (!$sText38{$sText[38]} && $sText[38] ne "") 
	{
		$entry38->insert(0, $sText[38]);
		unshift(@sText38 , $sText[38]);
	 	$sText38{$sText[38]}++;
	 	if($#sText38 == 30)		# �W�L 30 �ӴN�����̫�@��
	 	{
	 		$entry38->delete($#sText38,$#sText38);
	 		$sText38{$sText38[$#sText38]} = 0;
	 		pop(@sText38);
	 	}
	}
}

# �� Entry ����Ʀs�J ini ��
sub save2ini
{
	open OUT, ">xml2txt_all.ini";
	print OUT "[xml2txt_all]\n";
	for $i (0..$#sText1)
	{
		print OUT "sText1_$i=" . $sText1[$i] . "\n";
	}
	for $i (0..$#sText2)
	{
		print OUT "sText2_$i=" . $sText2[$i] . "\n";
	}
	for $i (0..$#sText3)
	{
		print OUT "sText3_$i=" . $sText3[$i] . "\n";
	}
	for $i (0..$#sText4)
	{
		print OUT "sText4_$i=" . $sText4[$i] . "\n";
	}
	for $i (0..$#sText5)
	{
		print OUT "sText5_$i=" . $sText5[$i] . "\n";
	}
	for $i (0..$#sText6)
	{
		print OUT "sText6_$i=" . $sText6[$i] . "\n";
	}
	for $i (0..$#sText7)
	{
		print OUT "sText7_$i=" . $sText7[$i] . "\n";
	}
	for $i (0..$#sText8)
	{
		print OUT "sText8_$i=" . $sText8[$i] . "\n";
	}
	for $i (0..$#sText9)
	{
		print OUT "sText9_$i=" . $sText9[$i] . "\n";
	}
	for $i (0..$#sText10)
	{
		print OUT "sText10_$i=" . $sText10[$i] . "\n";
	}
	for $i (0..$#sText11)
	{
		print OUT "sText11_$i=" . $sText11[$i] . "\n";
	}
	for $i (0..$#sText12)
	{
		print OUT "sText12_$i=" . $sText12[$i] . "\n";
	}
	for $i (0..$#sText13){print OUT "sText13_$i=" . $sText13[$i] . "\n";}
	for $i (0..$#sText14){print OUT "sText14_$i=" . $sText14[$i] . "\n";}
	for $i (0..$#sText15){print OUT "sText15_$i=" . $sText15[$i] . "\n";}
	for $i (0..$#sText16){print OUT "sText16_$i=" . $sText16[$i] . "\n";}
	for $i (0..$#sText17){print OUT "sText17_$i=" . $sText17[$i] . "\n";}
	for $i (0..$#sText18){print OUT "sText18_$i=" . $sText18[$i] . "\n";}
	for $i (0..$#sText19){print OUT "sText19_$i=" . $sText19[$i] . "\n";}
	for $i (0..$#sText20){print OUT "sText20_$i=" . $sText20[$i] . "\n";}
	for $i (0..$#sText21){print OUT "sText21_$i=" . $sText21[$i] . "\n";}
	for $i (0..$#sText22){print OUT "sText22_$i=" . $sText22[$i] . "\n";}
	for $i (0..$#sText23){print OUT "sText23_$i=" . $sText23[$i] . "\n";}
	for $i (0..$#sText24){print OUT "sText24_$i=" . $sText24[$i] . "\n";}
	for $i (0..$#sText25){print OUT "sText25_$i=" . $sText25[$i] . "\n";}
	for $i (0..$#sText26){print OUT "sText26_$i=" . $sText26[$i] . "\n";}
	for $i (0..$#sText27){print OUT "sText27_$i=" . $sText27[$i] . "\n";}
	for $i (0..$#sText28){print OUT "sText28_$i=" . $sText28[$i] . "\n";}
	for $i (0..$#sText29){print OUT "sText29_$i=" . $sText29[$i] . "\n";}
	for $i (0..$#sText30){print OUT "sText30_$i=" . $sText30[$i] . "\n";}
	for $i (0..$#sText31){print OUT "sText31_$i=" . $sText31[$i] . "\n";}
	for $i (0..$#sText32){print OUT "sText32_$i=" . $sText32[$i] . "\n";}
	for $i (0..$#sText33){print OUT "sText33_$i=" . $sText33[$i] . "\n";}
	for $i (0..$#sText34){print OUT "sText34_$i=" . $sText34[$i] . "\n";}
	for $i (0..$#sText35){print OUT "sText35_$i=" . $sText35[$i] . "\n";}
	for $i (0..$#sText36){print OUT "sText36_$i=" . $sText36[$i] . "\n";}
	for $i (0..$#sText37){print OUT "sText37_$i=" . $sText37[$i] . "\n";}
	for $i (0..$#sText38){print OUT "sText38_$i=" . $sText38[$i] . "\n";}
	
	# �x�s�ܼ�
	print OUT "sText1=" . $sText[1] . "\n";
	print OUT "sText2=" . $sText[2] . "\n";
	print OUT "sText3=" . $sText[3] . "\n";
	print OUT "sText4=" . $sText[4] . "\n";
	print OUT "sText5=" . $sText[5] . "\n";
	print OUT "sText6=" . $sText[6] . "\n";
	print OUT "sText7=" . $sText[7] . "\n";
	print OUT "sText8=" . $sText[8] . "\n";
	print OUT "sText9=" . $sText[9] . "\n";
	print OUT "sText10=" . $sText[10] . "\n";
	print OUT "sText11=" . $sText[11] . "\n";
	print OUT "sText12=" . $sText[12] . "\n";
	print OUT "sText13=" . $sText[13] . "\n";
	print OUT "sText14=" . $sText[14] . "\n";
	print OUT "sText15=" . $sText[15] . "\n";
	print OUT "sText16=" . $sText[16] . "\n";
	print OUT "sText17=" . $sText[17] . "\n";
	print OUT "sText18=" . $sText[18] . "\n";
	print OUT "sText19=" . $sText[19] . "\n";
	print OUT "sText20=" . $sText[20] . "\n";
	print OUT "sText21=" . $sText[21] . "\n";
	print OUT "sText22=" . $sText[22] . "\n";
	print OUT "sText23=" . $sText[23] . "\n";
	print OUT "sText24=" . $sText[24] . "\n";
	print OUT "sText25=" . $sText[25] . "\n";
	print OUT "sText26=" . $sText[26] . "\n";
	print OUT "sText27=" . $sText[27] . "\n";
	print OUT "sText28=" . $sText[28] . "\n";
	print OUT "sText29=" . $sText[29] . "\n";
	print OUT "sText30=" . $sText[30] . "\n";
	print OUT "sText31=" . $sText[31] . "\n";
	print OUT "sText32=" . $sText[32] . "\n";
	print OUT "sText33=" . $sText[33] . "\n";
	print OUT "sText34=" . $sText[34] . "\n";
	print OUT "sText35=" . $sText[35] . "\n";
	print OUT "sText36=" . $sText[36] . "\n";
	print OUT "sText37=" . $sText[37] . "\n";
	print OUT "sText38=" . $sText[38] . "\n";
	
	# �x�s�̥��誺���
	
	print OUT "sel_Big5Normal=" . $sel_Big5Normal . "\n";
	print OUT "sel_Big5App=" . $sel_Big5App . "\n";
	print OUT "sel_UTF8Normal=" . $sel_UTF8Normal . "\n";
	print OUT "sel_UTF8App=" . $sel_UTF8App . "\n";
	print OUT "sel_PDA=" . $sel_PDA . "\n";
	print OUT "sel_Big5NormalDes=" . $sel_Big5NormalDes . "\n";
	print OUT "sel_Big5AppDes=" . $sel_Big5AppDes . "\n";
	print OUT "sel_Big5AppJuan=" . $sel_Big5AppJuan . "\n";
	print OUT "sel_Big5NoteSign=" . $sel_Big5NoteSign . "\n";
	print OUT "sel_All=" . $sel_All . "\n";
	
	# �x�s���U�誺�ﶵ
	
	print OUT "IsNormal=" . $IsNormal . "\n";
	print OUT "IsApp=" . $IsApp . "\n";
	print OUT "IsBig5=" . $IsBig5 . "\n";
	print OUT "IsSan=" . $IsSan . "\n";
	print OUT "IsNormalWord=" . $IsNormalWord . "\n";
	print OUT "IsAppSign=" . $IsAppSign . "\n";
	print OUT "IsJuanHead=" . $IsJuanHead . "\n";
	print OUT "IsPDA=" . $IsPDA . "\n";
	
	close OUT;
}

# �� Entry ����ƥ� ini �ɸ��J
sub load_ini
{
	local $_;
	open IN, "xml2txt_all.ini";
	$_ = <IN>;
	unless(/\[xml2txt\_all\]/)
	{
		return;
	}
	while(<IN>)
	{
		chomp;
		if(/sText1_.*?=(.*)/)
		{
			push(@sText1,$1);
			$sText1{$1} = 1;
		}
		elsif(/sText2_.*?=(.*)/)
		{
			push(@sText2,$1);
			$sText2{$1} = 1;
		}
		elsif(/sText3_.*?=(.*)/)
		{
			push(@sText3,$1);
			$sText3{$1} = 1;
		}
		elsif(/sText4_.*?=(.*)/)
		{
			push(@sText4,$1);
			$sText4{$1} = 1;
		}
		elsif(/sText5_.*?=(.*)/)
		{
			push(@sText5,$1);
			$sText5{$1} = 1;
		}
		elsif(/sText6_.*?=(.*)/)
		{
			push(@sText6,$1);
			$sText6{$1} = 1;
		}
		elsif(/sText7_.*?=(.*)/)
		{
			push(@sText7,$1);
			$sText7{$1} = 1;
		}
		elsif(/sText8_.*?=(.*)/)
		{
			push(@sText8,$1);
			$sText8{$1} = 1;
		}
		elsif(/sText9_.*?=(.*)/)
		{
			push(@sText9,$1);
			$sText9{$1} = 1;
		}
		elsif(/sText10_.*?=(.*)/)
		{
			push(@sText10,$1);
			$sText10{$1} = 1;
		}
		elsif(/sText11_.*?=(.*)/)
		{
			push(@sText11,$1);
			$sText11{$1} = 1;
		}
		elsif(/sText12_.*?=(.*)/)
		{
			push(@sText12,$1);
			$sText12{$1} = 1;
		}
		elsif(/sText13_.*?=(.*)/){push(@sText13,$1); $sText13{$1} = 1;}
		elsif(/sText14_.*?=(.*)/){push(@sText14,$1); $sText14{$1} = 1;}
		elsif(/sText15_.*?=(.*)/){push(@sText15,$1); $sText15{$1} = 1;}
		elsif(/sText16_.*?=(.*)/){push(@sText16,$1); $sText16{$1} = 1;}
		elsif(/sText17_.*?=(.*)/){push(@sText17,$1); $sText17{$1} = 1;}
		elsif(/sText18_.*?=(.*)/){push(@sText18,$1); $sText18{$1} = 1;}
		elsif(/sText19_.*?=(.*)/){push(@sText19,$1); $sText19{$1} = 1;}
		elsif(/sText20_.*?=(.*)/){push(@sText20,$1); $sText20{$1} = 1;}
		elsif(/sText21_.*?=(.*)/){push(@sText21,$1); $sText21{$1} = 1;}
		elsif(/sText22_.*?=(.*)/){push(@sText22,$1); $sText22{$1} = 1;}
		elsif(/sText23_.*?=(.*)/){push(@sText23,$1); $sText23{$1} = 1;}
		elsif(/sText24_.*?=(.*)/){push(@sText24,$1); $sText24{$1} = 1;}
		elsif(/sText25_.*?=(.*)/){push(@sText25,$1); $sText25{$1} = 1;}
		elsif(/sText26_.*?=(.*)/){push(@sText26,$1); $sText26{$1} = 1;}
		elsif(/sText27_.*?=(.*)/){push(@sText27,$1); $sText27{$1} = 1;}
		elsif(/sText28_.*?=(.*)/){push(@sText28,$1); $sText28{$1} = 1;}
		elsif(/sText29_.*?=(.*)/){push(@sText29,$1); $sText29{$1} = 1;}
		elsif(/sText30_.*?=(.*)/){push(@sText30,$1); $sText30{$1} = 1;}
		elsif(/sText31_.*?=(.*)/){push(@sText31,$1); $sText31{$1} = 1;}
		elsif(/sText32_.*?=(.*)/){push(@sText32,$1); $sText32{$1} = 1;}
		elsif(/sText33_.*?=(.*)/){push(@sText33,$1); $sText33{$1} = 1;}
		elsif(/sText34_.*?=(.*)/){push(@sText34,$1); $sText34{$1} = 1;}
		elsif(/sText35_.*?=(.*)/){push(@sText35,$1); $sText35{$1} = 1;}
		elsif(/sText36_.*?=(.*)/){push(@sText36,$1); $sText36{$1} = 1;}
		elsif(/sText37_.*?=(.*)/){push(@sText37,$1); $sText37{$1} = 1;}
		elsif(/sText38_.*?=(.*)/){push(@sText38,$1); $sText38{$1} = 1;}
		
		elsif(/sText[1]=(.*)/)
		{
			$sText[1] = $1;
		}
		elsif(/sText[2]=(.*)/)
		{
			$sText[2] = $1;
		}
		elsif(/sText[3]=(.*)/)
		{
			$sText[3] = $1;
		}
		elsif(/sText[4]=(.*)/)
		{
			$sText[4] = $1;
		}
		elsif(/sText[5]=(.*)/)
		{
			$sText[5] = $1;
		}
		elsif(/sText[6]=(.*)/)
		{
			$sText[6] = $1;
		}
		elsif(/sText[7]=(.*)/)
		{
			$sText[7] = $1;
		}
		elsif(/sText[8]=(.*)/)
		{
			$sText[8] = $1;
		}
		elsif(/sText[9]=(.*)/)
		{
			$sText[9] = $1;
		}
		elsif(/sText[10]=(.*)/)
		{
			$sText[10] = $1;
		}
		elsif(/sText[11]=(.*)/)
		{
			$sText[11] = $1;
		}
		elsif(/sText[12]=(.*)/)
		{
			$sText[12] = $1;
		}
		elsif(/sText[13]=(.*)/) {$sText[13] = $1;}
		elsif(/sText[14]=(.*)/) {$sText[14] = $1;}
		elsif(/sText[15]=(.*)/) {$sText[15] = $1;}
		elsif(/sText[16]=(.*)/) {$sText[16] = $1;}
		elsif(/sText[17]=(.*)/) {$sText[17] = $1;}
		elsif(/sText[18]=(.*)/) {$sText[18] = $1;}
		elsif(/sText[19]=(.*)/) {$sText[19] = $1;}
		elsif(/sText[20]=(.*)/) {$sText[20] = $1;}
		elsif(/sText[21]=(.*)/) {$sText[21] = $1;}
		elsif(/sText[22]=(.*)/) {$sText[22] = $1;}
		elsif(/sText[23]=(.*)/) {$sText[23] = $1;}
		elsif(/sText[24]=(.*)/) {$sText[24] = $1;}
		elsif(/sText[25]=(.*)/) {$sText[25] = $1;}
		elsif(/sText[26]=(.*)/) {$sText[26] = $1;}
		elsif(/sText[27]=(.*)/) {$sText[27] = $1;}
		elsif(/sText[28]=(.*)/) {$sText[28] = $1;}
		elsif(/sText[29]=(.*)/) {$sText[29] = $1;}
		elsif(/sText[30]=(.*)/) {$sText[30] = $1;}
		elsif(/sText[31]=(.*)/) {$sText[31] = $1;}
		elsif(/sText[32]=(.*)/) {$sText[32] = $1;}
		elsif(/sText[33]=(.*)/) {$sText[33] = $1;}
		elsif(/sText[34]=(.*)/) {$sText[34] = $1;}
		elsif(/sText[35]=(.*)/) {$sText[35] = $1;}
		elsif(/sText[36]=(.*)/) {$sText[36] = $1;}
		elsif(/sText[37]=(.*)/) {$sText[37] = $1;}
		elsif(/sText[38]=(.*)/) {$sText[38] = $1;}
		
		elsif(/^(.*?)=(.*)/)
		{
			my $tmp1 = $1;
			my $tmp2 = $2;
			eval "\$$tmp1 = '$tmp2'";
		}
	}
	close IN;
}

sub show_readme
{
	if (Exists($win_readme))
	{
		$win_readme->deiconify();		# �|�ѳ̤p�ƫ�_
		$win_readme->raise();			# �j���O�|�]��̫e��, �����|���o�J�I
		$win_readme->focus();
	}
	else 
	{
		$win_readme = $mw->Toplevel();
		$win_readme->focus();
		$win_readme->title("Toplevel");
		$txtReadme = $win_readme->Scrolled('ROText', -scrollbars => 'osoe')
			->pack(-expand => 1, -fill => 'both');
		$txtReadme->insert('end', << 'EOD'
------------------------------------------------------------------------------
XML2TXT.PL                                             by heaven  2007/06/22

�i�{�������j

�@�@���{���O�I�s c:\cbwork\work\bin\xml2txt.bat �A�{���ت��O�� XML ��
�@�@���ͦU�ت������g��C

�i�k����s�u��j

�@�@�{���k�誺�u����s�A��K���Ѱ򥻪��w�]�ȡC
�@�@�Ĥ@�ӬO�w�] XML ���ӷ����|�A��l�O�j���P����U�ƪ��w�]�ȡC

�i������s�u��j

�@�@������s�O���ͦU�ت������w�]�ѼơC
�@�@���s���䦳�@�ӥi�Ŀ諸�ﶵ�A���\��b�i�ϥλ����j�������C

�i�Ѽƻ����j

�@�@�ѼƦ��T�ءA�Ĥ@�جO XML �ӷ��ؿ��P���G��X�ؿ��A�ĤG�جO�U�ƪ���J�A
�@�@�ĤT�جO���ͦU�ت������ѼơC
	
�@�@�U�ƪ���J���j���B����B�ſ��B���v�B�å~...���A�Ϊk�ۦP�C�H�j���ì��ҡA�@���T�ؿ�J�k�G

�@�@1. �u�B�z�@�U�A�b�u�j���� �q�v��J�Y�@�U���Ʀr�Y�i�C

�@�@2. �B�z�s��U�A�Ҧp�Ѥj���ò� 10 �U�ܲ� 20 �U�A�Y�b�u�j���� �q�v��J 10�A
�@�@  �u�j���� ��v��J 20 �Y�i�C

�@�@3. �B�z���w�U�ơA�i�Υb���r�����}�Ʀr�A�]�i�� (�Ʀr..�Ʀr) �Ӫ�ܳs��d��C
�@�@   �o�خ榡�u��X�{�b�u�j���� �q�v�A���ɷ|�����u�j���� ��v����줺�e�C
�@�@   �Ҧp�b�u�j���� �q�v��J�G
�@�@   5,7,(10..14),20,(40..42)
�@�@   ��ܳB�z���U�Ƭ� 5,7,10,11,12,13,14,20,40,41,42
   
�@�@�@ ���s�b���U�Ʒ|�۰ʩ����A�ҥH�B�z�j���å����i�H�Τ�k 2 ���� 1 �� 85 �U�A
�@�@�@ �]�i�H�Τ�k 3 ��J (1..55),85 �� (1..85) �Ʀ� (1..99) ���i�H�C
�@�@�@ �T��ƥH�W���Ʀr�h���|�q�L�ˬd�C

�i�ϥλ����j

�@�@�{���D�n���G�بϥμҦ��G
	
�@�@1. �]�w�ӷ��P��X�ؿ��B�]�w�U�ơB�]�w�U�ذѼƫ�A���U�u����W��ҿ�Ѽơv�A
�@�@   �Y�i�̰ѼƳ]�w���ͫ��w�U�ƪ��g��C
	
�@�@2. �Ŀ�̥��誺�ﶵ�A�A���U���U�誺�u����W��ҿ�w�]�U�աv�A�Y�i�̦U��
�@�@   �w�]�ѼƲ��ͦU�ظg��C�w�]���ѼƬO��X�ؿ��P�g��榡�A�����]�A�ӷ��ؿ�
�@�@   �ΥU�ơC
	
�@�@�����G
	
�@�@�Ĥ@�ؤ覡�u�ಣ�@�ظg��A�Ҧp�]�w���ѼƬO���Ϊ��A�h�i�H���ͦU�U���Ϊ�
�@�@���g��C
	
�@�@�ĤG�ؤ覡�i�H���ͫܦh�ظg��A�Ҧp�ĳ]���Ϊ��BApp���BPDA ���A�ë��w
�@�@�����U�ơA�Y�i���ͤW�z�T�ت����������g��C

�i�{���S��j

�@�@���{���|�N�ϥιL���ѼƤΤW���̫���檺�ѼƦs�b xml2txt_all.ini ���ɤ����A
�@�@���ɽФ��H�N��ʭק�A�ܤ֤��n�}�a���ǡA���v�O���̦h30���A�U���A������
�@�@�{���ɡA�i�H�e�{�W���̫�}�Ҫ��e���A�ӥB�i�H�ܤ�K���g�`�ϥΨ쪺�ѼơC

�i�������v�j

�@�@2007/06/22 V1.0    �Ĥ@��
�@�@2009/03/19 V1.1    �[�J�ſ��áB���v�B�å~���ﶵ
�@�@2010/12/25 V1.2    �[�J ����,������,�Фs�۸g,��Фj�øg,���R��,������,�å���,�ü֥_��,���ÿ��,�x�Z�n��
�@�@2011/01/23 V1.3    �B�z�U�ƤT�X���øg
�@�@2011/05/14 V1.4    �[�J �ʫ~, �ɽs, ���
------------------------------------------------------------------------------
EOD
		);
	}
}