######################################################
# �P�_�������Φ۰ʰ���
######################################################
use Cwd;
my $orig_path = getcwd;	# ���{�����ؿ�

$ENV{"PATH"} = "C:\\CBWORK\\work\\BIN;" .  $ENV{"PATH"};	# �[�J path c:\cbwork\work\bin
if($ARGV[0])	# ���ǤJ�Ѽ�
{
	print "you input $ARGV[0]\n";
}
else
{
	$mw = gui_class->new();
	$mw->show();
	#print "�� �D�{������\n";
}

######################################################
# �D�{��
######################################################

sub main
{
	local * argv = shift;	# �ǤJ�Ҧ����Ѽ�, �o�O�@�� hash

	my $Tfrom = $argv{sText1};
	my $Tto = $argv{sText2};
	my $Xfrom = $argv{sText3};
	my $Xto = $argv{sText4};
	my $Jfrom = $argv{sText5};
	my $Jto = $argv{sText6};
	my $Hfrom = $argv{sText7};
	my $Hto = $argv{sText8};
	my $Wfrom = $argv{sText9};
	my $Wto = $argv{sText10};
	my $Ifrom = $argv{sText11};
	my $Ito = $argv{sText12};
	
	my $Afrom = $argv{sText13};
	my $Ato = $argv{sText14};
	my $Bfrom = $argv{sText15};
	my $Bto = $argv{sText16};
	my $Cfrom = $argv{sText17};
	my $Cto = $argv{sText18};
	my $Dfrom = $argv{sText19};
	my $Dto = $argv{sText20};
	my $Ffrom = $argv{sText21};
	my $Fto = $argv{sText22};
	my $Gfrom = $argv{sText23};
	my $Gto = $argv{sText24};
	my $Kfrom = $argv{sText25};
	my $Kto = $argv{sText26};
	my $Lfrom = $argv{sText27};
	my $Lto = $argv{sText28};
	my $Mfrom = $argv{sText29};
	my $Mto = $argv{sText30};
	my $Pfrom = $argv{sText31};
	my $Pto = $argv{sText32};
	my $Sfrom = $argv{sText33};
	my $Sto = $argv{sText34};
	my $Ufrom = $argv{sText35};
	my $Uto = $argv{sText36};
	
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
	$Ifrom =~ s/\s//g;
	$Ito =~ s/\s//g;
	
	$Afrom =~ s/\s//g;
	$Ato =~ s/\s//g;
	$Bfrom =~ s/\s//g;
	$Bto =~ s/\s//g;
	$Cfrom =~ s/\s//g;
	$Cto =~ s/\s//g;
	$Dfrom =~ s/\s//g;
	$Dto =~ s/\s//g;
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
	
	# �Ĥ@����, �B�z�j����
	
	# �B�z�S�O�Ʀr
	parser_num($Tfrom, $Tto, "T");
	parser_num($Xfrom, $Xto, "X");
	parser_num($Jfrom, $Jto, "J");
	parser_num($Hfrom, $Hto, "H");
	parser_num($Wfrom, $Wto, "W");
	parser_num($Ifrom, $Ito, "I");
	
	parser_num($Afrom, $Ato, "A");
	parser_num($Bfrom, $Bto, "B");
	parser_num($Cfrom, $Cto, "C");
	parser_num($Dfrom, $Dto, "D");
	parser_num($Ffrom, $Fto, "F");
	parser_num($Gfrom, $Gto, "G");
	parser_num($Kfrom, $Kto, "K");
	parser_num($Lfrom, $Lto, "L");
	parser_num($Mfrom, $Mto, "M");
	parser_num($Pfrom, $Pto, "P");
	parser_num($Sfrom, $Sto, "S");
	parser_num($Ufrom, $Uto, "U");
	
	print "\n" . "="x70 . "\nOK!\n\n";
}

sub parser_num
{
	# �U�ժ���ƶǶi�ӳB�z
	
	my $from = shift;
	my $to = shift;
	my $book = shift;
	
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
					run_dir($book,$j);
				}
			}
			elsif($i =~ /^\d+$/)
			{
				run_dir($book,$i);
			}
		}
	}
	elsif($from =~ /^\d+$/ && $to =~ /^\d+$/)		# ���G�ռƦr
	{
		my @nums = ($from..$to);
		for $j (@nums)
		{
			run_dir($book,$j);
		}
	}
	elsif($from =~ /^\d+$/ && $to eq "")		# �u���Ĥ@��
	{
		run_dir($book,$from);
	}
}

sub run_dir
{
	my $TX = shift;
	my $vol = shift;
	
	my $TXvol;
	if($TX =~ /[ACGLMPU]/)       # 3 ��ƪ��U��
	{
		$TXvol = $TX . sprintf("%03d",$vol);		# �зǤ�
	}
	else
	{
		$TXvol = $TX . sprintf("%02d",$vol);		# �зǤ�
	}
	
	if(-d "c:\\cbwork\\xml\\$TXvol")	# ���L���s�b���U��
	{
		print "-"x70 . "\n$TXvol\n" . "-"x70 . "\n";
		chdir ("c:\\cbwork\\xml\\$TXvol");
		system("call cbent");
		chdir ($orig_path);
	}
}

# �����{�� ###################################################################

##############################################################################
# ������������
package gui_class;
##############################################################################

use Tk;
use Tk::ROText;
use Tk::NoteBook;
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
	
	return if(!check_data(\$entry1, 1));			# �ˬd�ܼƬO�_�X�z
	return if(!check_data(\$entry2, 2));			# �ˬd�ܼƬO�_�X�z
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
	
	push_alldata_2_entry();	# �� Entry ��J���s�J�U�Կ�椤
	
	# �ǳƦ������
	
	$argv{"sText1"} = $sText[1];
	$argv{"sText2"} = $sText[2];
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
	
	$main::{'main'}(\%argv);
}

######################################################
# ��L��k
######################################################

# �������
sub btAll_click
{
	$sText[1] = 1;
	$sText[2] = 85;
	$sText[3] = 1;
	$sText[4] = 88;
	$sText[5] = 1;
	$sText[6] = 40;
	$sText[7] = 1;
	$sText[8] = 1;
	$sText[9] = 1;
	$sText[10] = 9;
	$sText[11] = 1;		#I
	$sText[12] = 1;
	
	$sText[13] = 91;	#A
	$sText[14] = 121;
	$sText[15] = 1;		#B
	$sText[16] = 36;
	$sText[17] = 56;	#C
	$sText[18] = 106;
	$sText[19] = 1;		#D
	$sText[20] = 64;
	$sText[21] = 1;		#F
	$sText[22] = 29;
	$sText[23] = 52;
	$sText[24] = 84;
	$sText[25] = 5;
	$sText[26] = 41;
	$sText[27] = 115;
	$sText[28] = 164;
	$sText[29] = 59;
	$sText[30] = 59;
	$sText[31] = 154;
	$sText[32] = 189;
	$sText[33] = 6;
	$sText[34] = 6;
	$sText[35] = 205;
	$sText[36] = 223;
}
# �����M��
sub btAll_clear_click
{
	$sText[1] = "";
	$sText[2] = "";
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
}

# �M���j��
sub btT_clear_click
{
	$sText[1] = "";
	$sText[2] = "";
}

# �M������
sub btX_clear_click
{
	$sText[3] = "";
	$sText[4] = "";
}
# �M���ſ�
sub btJ_clear_click
{
	$sText[5] = "";
	$sText[6] = "";
}
# �M�����v
sub btH_clear_click
{
	$sText[7] = "";
	$sText[8] = "";
}
# �M���å~
sub btW_clear_click
{
	$sText[9] = "";
	$sText[10] = "";
}
# �M���ʫ~
sub btI_clear_click
{
	$sText[11] = "";
	$sText[12] = "";
}
# �M������
sub btA_clear_click
{
	$sText[13] = "";
	$sText[14] = "";
}
# �M���ɽs 
sub btB_clear_click
{
	$sText[15] = "";
	$sText[16] = "";
}
# �M�������� 
sub btC_clear_click
{
	$sText[17] = "";
	$sText[18] = "";
}
# �M����� 
sub btD_clear_click
{
	$sText[19] = "";
	$sText[20] = "";
}
# �M���Фs�۸g
sub btF_clear_click
{
	$sText[21] = "";
	$sText[22] = "";
}
# �M����Фj�øg
sub btG_clear_click
{
	$sText[23] = "";
	$sText[24] = "";
}
# �M�����R��
sub btK_clear_click
{
	$sText[25] = "";
	$sText[26] = "";
}
# �M��������
sub btL_clear_click
{
	$sText[27] = "";
	$sText[28] = "";
}
# �M���å���
sub btM_clear_click
{
	$sText[29] = "";
	$sText[30] = "";
}
# �M���ü֥_��
sub btP_clear_click
{
	$sText[31] = "";
	$sText[32] = "";
}
# �M�����ÿ��
sub btS_clear_click
{
	$sText[33] = "";
	$sText[34] = "";
}
# �M���x�Z�n��
sub btU_clear_click
{
	$sText[35] = "";
	$sText[36] = "";
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
	$mw->title("CBETA cbent");
	load_ini();			# �� ini �̭����F���J�}�C��
	make_all_frame();	# ���X 4 �� frame	

	######################################################
	# �B�z�C�@�� frame �̭�������
	######################################################

	show_top_frame();
	show_bottom_frame();
	show_left_frame();
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
		-text => "�� CBENT_ALL ���@�� XML �ίʦr��Ʈw���� ent ��",
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
		-text => "����", 
		-command => \&run_main,			# ����D�{�� , �öǤJ�Ҧ��Ѽ�
		)->pack(
			-side => 'right',
			-padx => 20,			# �ե󥪥k�d�Ťj�p 20
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
}

sub show_left_frame
{
	# �A�ؤ@�� frame , �⩳�U�� grid ���ܼƶ����b�W��
	
	$fmLeftTop = $fmLeft->Frame()->pack(
		-side => 'top',
		-fill => 'both',
		-padx => 10,
		-pady => 10,
		);
	
	# �D�n���ܼ� ###################################
	
	
	$bt1 = $fmLeftTop->Button(-text => '�M��',-command => \&btT_clear_click);
	$bt2 = $fmLeftTop->Button(-text => '�M��',-command => \&btX_clear_click);
	$bt3 = $fmLeftTop->Button(-text => '�M��',-command => \&btJ_clear_click);
	$bt4 = $fmLeftTop->Button(-text => '�M��',-command => \&btH_clear_click);
	$bt5 = $fmLeftTop->Button(-text => '�M��',-command => \&btW_clear_click);
	$bt6 = $fmLeftTop->Button(-text => '�M��',-command => \&btI_clear_click);
	$bt7 = $fmLeftTop->Button(-text => '�M��',-command => \&btA_clear_click);
	$bt8 = $fmLeftTop->Button(-text => '�M��',-command => \&btB_clear_click);
	$bt9 = $fmLeftTop->Button(-text => '�M��',-command => \&btC_clear_click);
	$bt10 = $fmLeftTop->Button(-text => '�M��',-command => \&btD_clear_click);
	$bt11 = $fmLeftTop->Button(-text => '�M��',-command => \&btF_clear_click);
	$bt12 = $fmLeftTop->Button(-text => '�M��',-command => \&btG_clear_click);
	$bt13 = $fmLeftTop->Button(-text => '�M��',-command => \&btK_clear_click);
	$bt14 = $fmLeftTop->Button(-text => '�M��',-command => \&btL_clear_click);
	$bt15 = $fmLeftTop->Button(-text => '�M��',-command => \&btM_clear_click);
	$bt16 = $fmLeftTop->Button(-text => '�M��',-command => \&btP_clear_click);
	$bt17 = $fmLeftTop->Button(-text => '�M��',-command => \&btS_clear_click);
	$bt18 = $fmLeftTop->Button(-text => '�M��',-command => \&btU_clear_click);
	
	# �Ĥ@��
	$label[1] = $fmLeftTop->Label(-text => "(T)�j���á@�q�G",);
	$entry1 = $fmLeftTop->BrowseEntry(-variable => \$sText[1], -choices => \@sText1);				# ��J��r���ܼ�	
	#Tk::grid($label[1], $entry1, -sticky => "w",-padx => 1,-pady => 5,);
	# �ĤG��
	$label[2] = $fmLeftTop->Label(-text => "��G",);
	$entry2 = $fmLeftTop->BrowseEntry(-variable => \$sText[2], -choices => \@sText2);				# ��J��r���ܼ�
	Tk::grid($label[1], $entry1, $label[2], $entry2, $bt1, -sticky => "ew",-padx => 1,-pady => 0,);

	# �ĤT��
	$label[3] = $fmLeftTop->Label(-text => "(X)�����á@�q�G",);
	$entry3 = $fmLeftTop->BrowseEntry(-variable => \$sText[3], -choices => \@sText3);				# ��J��r���ܼ�		
	# Tk::grid($label[3], $entry3, -sticky => "ew",-padx => 1,-pady => 10,);
	# �ĥ|��
	$label[4] = $fmLeftTop->Label(-text => "��G",);
	$entry4 = $fmLeftTop->BrowseEntry(-variable => \$sText[4], -choices => \@sText4);				# ��J��r���ܼ�		
	Tk::grid($label[3], $entry3, $label[4], $entry4, $bt2, -sticky => "ew",-padx => 1,-pady => 0,);

	# �Ĥ���
	$label[5] = $fmLeftTop->Label(-text => "(J)�ſ��á@�q�G",);
	$entry5 = $fmLeftTop->BrowseEntry(-variable => \$sText[5], -choices => \@sText5);				# ��J��r���ܼ�		
	#Tk::grid($label[5], $entry5, -sticky => "ew",-padx => 1,-pady => 10,);
	# �Ĥ���
	$label[6] = $fmLeftTop->Label(-text => "��G",);
	$entry6 = $fmLeftTop->BrowseEntry(-variable => \$sText[6], -choices => \@sText6);				# ��J��r���ܼ�		
	Tk::grid($label[5], $entry5, $label[6], $entry6, $bt3, -sticky => "ew",-padx => 1,-pady => 0,);

	# �ĤC��
	$label[7] = $fmLeftTop->Label(-text => "(H)�@���v�@�q�G",);
	$entry7 = $fmLeftTop->BrowseEntry(-variable => \$sText[7], -choices => \@sText7);				# ��J��r���ܼ�		
	#Tk::grid($label[7], $entry7, -sticky => "ew",-padx => 1,-pady => 10,);
	# �ĤK��
	$label[8] = $fmLeftTop->Label(-text => "��G",);
	$entry8 = $fmLeftTop->BrowseEntry(-variable => \$sText[8], -choices => \@sText8);				# ��J��r���ܼ�		
	Tk::grid($label[7], $entry7, $label[8], $entry8, $bt4, -sticky => "ew",-padx => 1,-pady => 0,);

	# �ĤE��
	$label[9] = $fmLeftTop->Label(-text => "(W)�@�å~�@�q�G",);
	$entry9 = $fmLeftTop->BrowseEntry(-variable => \$sText[9], -choices => \@sText9);				# ��J��r���ܼ�		
	#Tk::grid($label[9], $entry9, -sticky => "ew",-padx => 1,-pady => 10,);
	# �ĤQ��
	$label[10] = $fmLeftTop->Label(-text => "��G",);
	$entry10 = $fmLeftTop->BrowseEntry(-variable => \$sText[10], -choices => \@sText10);				# ��J��r���ܼ�		
	Tk::grid($label[9], $entry9, $label[10], $entry10, $bt5, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[11] = $fmLeftTop->Label(-text => "(I)�@�ʫ~�@�q�G",);
	$entry11 = $fmLeftTop->BrowseEntry(-variable => \$sText[11], -choices => \@sText11);				# ��J��r���ܼ�		
	$label[12] = $fmLeftTop->Label(-text => "��G",);
	$entry12 = $fmLeftTop->BrowseEntry(-variable => \$sText[12], -choices => \@sText12);				# ��J��r���ܼ�		
	Tk::grid($label[11], $entry11, $label[12], $entry12, $bt6, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[13] = $fmLeftTop->Label(-text => "(A)�@���á@�q�G",);
	$entry13 = $fmLeftTop->BrowseEntry(-variable => \$sText[13], -choices => \@sText13);				# ��J��r���ܼ�		
	$label[14] = $fmLeftTop->Label(-text => "��G",);
	$entry14 = $fmLeftTop->BrowseEntry(-variable => \$sText[14], -choices => \@sText14);				# ��J��r���ܼ�		
	Tk::grid($label[13], $entry13, $label[14], $entry14, $bt7, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[15] = $fmLeftTop->Label(-text => "(B)�@�ɽs�@�q�G",);
	$entry15 = $fmLeftTop->BrowseEntry(-variable => \$sText[15], -choices => \@sText15);				# ��J��r���ܼ�		
	$label[16] = $fmLeftTop->Label(-text => "��G",);
	$entry16 = $fmLeftTop->BrowseEntry(-variable => \$sText[16], -choices => \@sText16);				# ��J��r���ܼ�		
	Tk::grid($label[15], $entry15, $label[16], $entry16, $bt8, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[17] = $fmLeftTop->Label(-text => "(C)�����á@�q�G",);
	$entry17 = $fmLeftTop->BrowseEntry(-variable => \$sText[17], -choices => \@sText17);				# ��J��r���ܼ�		
	$label[18] = $fmLeftTop->Label(-text => "��G",);
	$entry18 = $fmLeftTop->BrowseEntry(-variable => \$sText[18], -choices => \@sText18);				# ��J��r���ܼ�		
	Tk::grid($label[17], $entry17, $label[18], $entry18, $bt9, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[19] = $fmLeftTop->Label(-text => "(D)�@��ϡ@�q�G",);
	$entry19 = $fmLeftTop->BrowseEntry(-variable => \$sText[19], -choices => \@sText19);				# ��J��r���ܼ�		
	$label[20] = $fmLeftTop->Label(-text => "��G",);
	$entry20 = $fmLeftTop->BrowseEntry(-variable => \$sText[20], -choices => \@sText20);				# ��J��r���ܼ�		
	Tk::grid($label[19], $entry19, $label[20], $entry20, $bt10, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[21] = $fmLeftTop->Label(-text => "(F)�Фs�۸g�q�G",);
	$entry21 = $fmLeftTop->BrowseEntry(-variable => \$sText[21], -choices => \@sText21);				# ��J��r���ܼ�		
	$label[22] = $fmLeftTop->Label(-text => "��G",);
	$entry22 = $fmLeftTop->BrowseEntry(-variable => \$sText[22], -choices => \@sText22);				# ��J��r���ܼ�		
	Tk::grid($label[21], $entry21, $label[22], $entry22, $bt11, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[23] = $fmLeftTop->Label(-text => "(G)����á@�q�G",);
	$entry23 = $fmLeftTop->BrowseEntry(-variable => \$sText[23], -choices => \@sText23);				# ��J��r���ܼ�		
	$label[24] = $fmLeftTop->Label(-text => "��G",);
	$entry24 = $fmLeftTop->BrowseEntry(-variable => \$sText[24], -choices => \@sText24);				# ��J��r���ܼ�		
	Tk::grid($label[23], $entry23, $label[24], $entry24, $bt12, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[25] = $fmLeftTop->Label(-text => "(K)���R�á@�q�G",);
	$entry25 = $fmLeftTop->BrowseEntry(-variable => \$sText[25], -choices => \@sText25);				# ��J��r���ܼ�		
	$label[26] = $fmLeftTop->Label(-text => "��G",);
	$entry26 = $fmLeftTop->BrowseEntry(-variable => \$sText[26], -choices => \@sText26);				# ��J��r���ܼ�		
	Tk::grid($label[25], $entry25, $label[26], $entry26, $bt13, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[27] = $fmLeftTop->Label(-text => "(L)�����á@�q�G",);
	$entry27 = $fmLeftTop->BrowseEntry(-variable => \$sText[27], -choices => \@sText27);				# ��J��r���ܼ�		
	$label[28] = $fmLeftTop->Label(-text => "��G",);
	$entry28 = $fmLeftTop->BrowseEntry(-variable => \$sText[28], -choices => \@sText28);				# ��J��r���ܼ�		
	Tk::grid($label[27], $entry27, $label[28], $entry28, $bt14, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[29] = $fmLeftTop->Label(-text => "(M)�å��á@�q�G",);
	$entry29 = $fmLeftTop->BrowseEntry(-variable => \$sText[29], -choices => \@sText29);				# ��J��r���ܼ�		
	$label[30] = $fmLeftTop->Label(-text => "��G",);
	$entry30 = $fmLeftTop->BrowseEntry(-variable => \$sText[30], -choices => \@sText30);				# ��J��r���ܼ�		
	Tk::grid($label[29], $entry29, $label[30], $entry30, $bt15, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[31] = $fmLeftTop->Label(-text => "(P)�ü֥_�ñq�G",);
	$entry31 = $fmLeftTop->BrowseEntry(-variable => \$sText[31], -choices => \@sText31);				# ��J��r���ܼ�		
	$label[32] = $fmLeftTop->Label(-text => "��G",);
	$entry32 = $fmLeftTop->BrowseEntry(-variable => \$sText[32], -choices => \@sText32);				# ��J��r���ܼ�		
	Tk::grid($label[31], $entry31, $label[32], $entry32, $bt16, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[33] = $fmLeftTop->Label(-text => "(S)���ÿ�ñq�G",);
	$entry33 = $fmLeftTop->BrowseEntry(-variable => \$sText[33], -choices => \@sText33);				# ��J��r���ܼ�		
	$label[34] = $fmLeftTop->Label(-text => "��G",);
	$entry34 = $fmLeftTop->BrowseEntry(-variable => \$sText[34], -choices => \@sText34);				# ��J��r���ܼ�		
	Tk::grid($label[33], $entry33, $label[34], $entry34, $bt17, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[35] = $fmLeftTop->Label(-text => "(U)�x�Z�n�ñq�G",);
	$entry35 = $fmLeftTop->BrowseEntry(-variable => \$sText[35], -choices => \@sText35);				# ��J��r���ܼ�		
	$label[36] = $fmLeftTop->Label(-text => "��G",);
	$entry36 = $fmLeftTop->BrowseEntry(-variable => \$sText[36], -choices => \@sText36);				# ��J��r���ܼ�		
	Tk::grid($label[35], $entry35, $label[36], $entry36, $bt18, -sticky => "ew",-padx => 1,-pady => 0,);

	$fmLeftTop->gridColumnconfigure(1, -weight => 1);
}

sub show_right_frame
{
	# �k�誺������s
	
	$fmRight->Button(
		-text => '�������',
		-command => \&btAll_click,
		)->pack(
			-side => 'top',
			-padx => 10,			# �ե󥪥k�d�Ťj�p 10
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);

	$fmRight->Button(
		-text => '�����M��',
		-command => \&btAll_clear_click,
		)->pack(
			-side => 'top',
			-padx => 10,			# �ե󥪥k�d�Ťj�p 10
			-pady => 10,			# �ե�W�U�d�Ťj�p 10
			);
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
}

# �� Entry ����Ʀs�J ini ��
sub save2ini
{
	open OUT, ">cbent_all.ini";
	print OUT "[cbent_all]\n";
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
	for $i (0..$#sText11){print OUT "sText11_$i=" . $sText11[$i] . "\n";}
	for $i (0..$#sText12){print OUT "sText12_$i=" . $sText12[$i] . "\n";}
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
	
	close OUT;
}

# �� Entry ����Ʀs�J ini ��
sub load_ini
{
	local $_;
	open IN, "cbent_all.ini";
	$_ = <IN>;
	unless(/\[cbent\_all\]/)
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
		elsif(/sText11_.*?=(.*)/){push(@sText11,$1); $sText11{$1} = 1;}
		elsif(/sText12_.*?=(.*)/){push(@sText12,$1); $sText12{$1} = 1;}
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
		elsif(/sText[11]=(.*)/) {$sText[11] = $1;}
		elsif(/sText[12]=(.*)/) {$sText[12] = $1;}
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
		$win_readme = $mw->Toplevel( );
		$win_readme->focus();
		$win_readme->title("Toplevel");
		$txtReadme = $win_readme->Scrolled('ROText', -scrollbars => 'osoe')
			->pack(-expand => 1, -fill => 'both');
		$txtReadme->insert('end', << 'EOD'
------------------------------------------------------------------------------
CBETA_ALL.PL                                             by heaven  2007/06/20

�i�{�������j

�@�@���{���O�I�s c:\cbwork\work\bin\cbent.pl �A�{���ت��O�� XML �ɤ�
�@�@�ʦr��Ʈw���ͦU XML �ɮשҷf�t�� ent �ɡC

�i�Ѽƻ����j

�@�@�ѼƦb�{����������A���j���B����B�ſ��B���v�B�å~�U�աA�Ϊk�ۦP�C���B�H�j���ì��ҡA
�@�@�ѼƦ��T�ؿ�J�k�G

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

�i���s�u��j

�@�@�{����������O�u����s�A��K���Ѱ򥻪��w�]�ȡC

�i�{���S��j

�@�@���{���|�N�ϥιL���ѼƤΤW���̫���檺�ѼƦs�b cbent_all.ini ���ɤ����A
	���ɽФ��H�N��ʭק�A�ܤ֤��n�}�a���ǡA���v�O���̦h30���A�U���A������
�@�@�{���ɡA�i�H�e�{�W���̫�}�Ҫ��e���A�ӥB�i�H�ܤ�K���g�`�ϥΨ쪺�ѼơC

�i�������v�j

�@�@2007/06/20 V1.0    �Ĥ@��
�@�@2009/03/14 V1.1    �[�J�ſ��áB���v�B�å~���ﶵ
�@�@2010/12/25 V1.2    �[�J ����,������,�Фs�۸g,��Фj�øg,���R��,������,�å���,�ü֥_��,���ÿ��,�x�Z�n��
------------------------------------------------------------------------------
EOD
		);
	}
}