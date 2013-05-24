use File::Path;
use Cwd;

my $orig_path = getcwd;	# 本程式的目錄

######################################################
# 判斷視窗版或自動執行
######################################################

$ENV{"PATH"} = "C:\\CBWORK\\WORK\\BIN;" .  $ENV{"PATH"};	# 加入 path c:\cbwork\work\bin
if($ARGV[0])	# 有傳入參數
{
	print "you input $ARGV[0]\n";
}
else
{
	$mw = gui_class->new();
	$mw->show();
}

######################################################
# 主程式
######################################################

sub main
{
	local * argv = shift;	# 傳入所有的參數, 這是一個 hash

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
	
	parser_num($Tfrom, $Tto, "T", $para);	# 第一部份, 處理大正藏
	parser_num($Xfrom, $Xto, "X", $para);	# 第二部份, 處理卍續藏
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
	# 各組的資料傳進來處理
	
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
	elsif($from =~ /^\d+$/ && $to =~ /^\d+$/)		# 有二組數字
	{
		my @nums = ($from..$to);
		for $j (@nums)
		{
			run_dir($book,$j,$para);
		}
	}
	elsif($from =~ /^\d+$/ && $to eq "")		# 只有第一組
	{
		run_dir($book,$from,$para);
	}
}

sub run_dir
{
	my $TX = shift;
	my $vol = shift;
	my $para = shift;
	
	# 過濾掉 T56~T84 , X86~ , X06, X52 , X89..
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
	
	if($TX =~ /[ACGLMPU]/)	# 冊數三碼的藏經
	{
		$TXvol = $TX . sprintf("%03d",$vol);		# 標準化
	}
	else
	{
		$TXvol = $TX . sprintf("%02d",$vol);		# 標準化
	}
	
	print "-"x70 . "\n$TXvol\n" . "-"x70 . "\n";

	chdir ("${source_path}/$TXvol");
	system ("xml2txt -v $TXvol $para");
	chdir ($orig_path);
}

# 結束程式 ###################################################################

##############################################################################
# 視窗介面物件
package gui_class;
##############################################################################

use Tk;
use Tk::ROText;
use Tk::LabFrame;
use Tk::BrowseEntry;

######################################################
# 屬性
######################################################
my %argv;

######################################################
# 基本方法
######################################################

sub new 						# 物件建構
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	$this->_initialize();		# 物件初值化
	return $this;
}

sub DESTROY						# 解構式
{
	my $self = shift;
	save2ini();		# 把結果存入 ini 檔案中
	printf("★ 主視窗結束 ★\n");
}

sub _initialize					# 物件初值化
{
	my $this = shift;
}

sub run_main					# 執行主程式
{
	# 先判斷是不是真要執行
	
	my $run = $mw->messageBox(-title => '確認', 
		-message => '確定要執行嗎？', 
		-type => 'YesNo', -icon => 'question', -default => 'no');
	
	return if($run eq "no");
	
	return if(!check_data(\$entry3, 3));			# 檢查變數是否合理
	return if(!check_data(\$entry4, 4));			# 檢查變數是否合理
	return if(!check_data(\$entry5, 5));			# 檢查變數是否合理
	return if(!check_data(\$entry6, 6));			# 檢查變數是否合理
	return if(!check_data(\$entry7, 7));			# 檢查變數是否合理
	return if(!check_data(\$entry8, 8));			# 檢查變數是否合理
	return if(!check_data(\$entry9, 9));			# 檢查變數是否合理
	return if(!check_data(\$entry10, 10));			# 檢查變數是否合理
	return if(!check_data(\$entry11, 11));			# 檢查變數是否合理
	return if(!check_data(\$entry12, 12));			# 檢查變數是否合理
	return if(!check_data(\$entry13, 13));			# 檢查變數是否合理
	return if(!check_data(\$entry14, 14));			# 檢查變數是否合理
	return if(!check_data(\$entry15, 15));			# 檢查變數是否合理
	return if(!check_data(\$entry16, 16));			# 檢查變數是否合理
	return if(!check_data(\$entry17, 17));			# 檢查變數是否合理
	return if(!check_data(\$entry18, 18));			# 檢查變數是否合理
	return if(!check_data(\$entry19, 19));			# 檢查變數是否合理
	return if(!check_data(\$entry20, 20));			# 檢查變數是否合理
	return if(!check_data(\$entry21, 21));			# 檢查變數是否合理
	return if(!check_data(\$entry22, 22));			# 檢查變數是否合理
	return if(!check_data(\$entry23, 23));			# 檢查變數是否合理
	return if(!check_data(\$entry24, 24));			# 檢查變數是否合理
	return if(!check_data(\$entry25, 25));			# 檢查變數是否合理
	return if(!check_data(\$entry26, 26));			# 檢查變數是否合理
	return if(!check_data(\$entry27, 27));			# 檢查變數是否合理
	return if(!check_data(\$entry28, 28));			# 檢查變數是否合理
	return if(!check_data(\$entry29, 29));			# 檢查變數是否合理
	return if(!check_data(\$entry30, 30));			# 檢查變數是否合理
	return if(!check_data(\$entry31, 31));			# 檢查變數是否合理
	return if(!check_data(\$entry32, 32));			# 檢查變數是否合理
	return if(!check_data(\$entry33, 33));			# 檢查變數是否合理
	return if(!check_data(\$entry34, 34));			# 檢查變數是否合理
	return if(!check_data(\$entry35, 35));			# 檢查變數是否合理
	return if(!check_data(\$entry36, 36));			# 檢查變數是否合理
	return if(!check_data(\$entry37, 37));			# 檢查變數是否合理
	return if(!check_data(\$entry38, 38));			# 檢查變數是否合理

	push_alldata_2_entry();	# 把 Entry 輸入欄位存入下拉選單中
	
	# 準備成員函數
	
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

sub run_main_all					# 執行主程式
{
	#先判斷是不是真要執行
	
	my $run = $mw->messageBox(-title => '確認', 
		-message => '確定要執行嗎？', 
		-type => 'YesNo', -icon => 'question', -default => 'no');
	
	return if($run eq "no");
	
	return if(!check_data(\$entry3, 3));			# 檢查變數是否合理
	return if(!check_data(\$entry4, 4));			# 檢查變數是否合理
	return if(!check_data(\$entry5, 5));			# 檢查變數是否合理
	return if(!check_data(\$entry6, 6));			# 檢查變數是否合理
	return if(!check_data(\$entry7, 7));			# 檢查變數是否合理
	return if(!check_data(\$entry8, 8));			# 檢查變數是否合理
	return if(!check_data(\$entry9, 9));			# 檢查變數是否合理
	return if(!check_data(\$entry10, 10));			# 檢查變數是否合理
	return if(!check_data(\$entry11, 11));			# 檢查變數是否合理
	return if(!check_data(\$entry12, 12));			# 檢查變數是否合理
	
	return if(!check_data(\$entry13, 13));			# 檢查變數是否合理
	return if(!check_data(\$entry14, 14));			# 檢查變數是否合理
	return if(!check_data(\$entry15, 15));			# 檢查變數是否合理
	return if(!check_data(\$entry16, 16));			# 檢查變數是否合理
	return if(!check_data(\$entry17, 17));			# 檢查變數是否合理
	return if(!check_data(\$entry18, 18));			# 檢查變數是否合理
	return if(!check_data(\$entry19, 19));			# 檢查變數是否合理
	return if(!check_data(\$entry20, 20));			# 檢查變數是否合理
	return if(!check_data(\$entry21, 21));			# 檢查變數是否合理
	return if(!check_data(\$entry22, 22));			# 檢查變數是否合理
	return if(!check_data(\$entry23, 23));			# 檢查變數是否合理
	return if(!check_data(\$entry24, 24));			# 檢查變數是否合理
	return if(!check_data(\$entry25, 25));			# 檢查變數是否合理
	return if(!check_data(\$entry26, 26));			# 檢查變數是否合理
	return if(!check_data(\$entry27, 27));			# 檢查變數是否合理
	return if(!check_data(\$entry28, 28));			# 檢查變數是否合理
	return if(!check_data(\$entry29, 29));			# 檢查變數是否合理
	return if(!check_data(\$entry30, 30));			# 檢查變數是否合理
	return if(!check_data(\$entry31, 31));			# 檢查變數是否合理
	return if(!check_data(\$entry32, 32));			# 檢查變數是否合理
	return if(!check_data(\$entry33, 33));			# 檢查變數是否合理
	return if(!check_data(\$entry34, 34));			# 檢查變數是否合理
	return if(!check_data(\$entry35, 35));			# 檢查變數是否合理
	return if(!check_data(\$entry36, 36));			# 檢查變數是否合理
	return if(!check_data(\$entry37, 37));			# 檢查變數是否合理
	return if(!check_data(\$entry38, 38));			# 檢查變數是否合理
	
	push_alldata_2_entry();	# 把 Entry 輸入欄位存入下拉選單中
	
	# 準備成員函數
	
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
# 其他方法
######################################################

# 預設的路徑
sub btSourcePath_click
{
	$sText[1] = "c:\\cbwork\\xml";
}
# 全部選取
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
# 全部清除
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

# 清除大正
sub btT_clear_click
{
	$sText[3] = "";
	$sText[4] = "";
}

# 清除卍續
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
# 清除金藏
sub btA_clear_click
{
	$sText[15] = "";
	$sText[16] = "";
}
# 清除補編 
sub btB_clear_click
{
	$sText[17] = "";
	$sText[18] = "";
}
# 清除中華藏 
sub btC_clear_click
{
	$sText[19] = "";
	$sText[20] = "";
}
# 清除國圖 
sub btD_clear_click
{
	$sText[21] = "";
	$sText[22] = "";
}
# 清除房山石經
sub btF_clear_click
{
	$sText[23] = "";
	$sText[24] = "";
}
# 清除佛教大藏經
sub btG_clear_click
{
	$sText[25] = "";
	$sText[26] = "";
}
# 清除高麗藏
sub btK_clear_click
{
	$sText[27] = "";
	$sText[28] = "";
}
# 清除乾隆藏
sub btL_clear_click
{
	$sText[29] = "";
	$sText[30] = "";
}
# 清除卍正藏
sub btM_clear_click
{
	$sText[31] = "";
	$sText[32] = "";
}
# 清除永樂北藏
sub btP_clear_click
{
	$sText[33] = "";
	$sText[34] = "";
}
# 清除宋藏遺珍
sub btS_clear_click
{
	$sText[35] = "";
	$sText[36] = "";
}
# 清除洪武南藏
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

# 予許的格式為 1~3 位的純數字, 或這種格式  1,2,(6..9),10,12
# 若傳回 0 就表示有問題了
sub check_data
{
	local * widget = shift;
	my $i = shift;
	my $data = $sText[$i];
	
	return 1 if($data =~ /^\d{1,3}$/);		# 純一或二或三位數字, ok
	
	my @nums = split(/,/,$data);
	
	for $i (@nums)
	{
		if($i =~ /^\((\d{1,3})\.\.(\d{1,3})\)$/)
		{
			# (1..4) 這種格式
			my $tmp1 = $1;
			my $tmp2 = $2;
			
			if($tmp2 < $tmp1)
			{
				my $errmsg = "參數 $i 有問題";
				$mw->messageBox(-title => '錯誤', -message => $errmsg, -type => 'OK');
				$widget->focus();
				return 0;
			}
		}
		elsif($i =~ /^\d{1,3}$/)
		{
		}
		else
		{
			my $errmsg = "參數 $i 有問題";
			$mw->messageBox(-title => '錯誤', -message => $errmsg, -type => 'OK');
			$widget->focus();
			return 0;
		}
	}
	return 1;
}

sub show
{
	my $this = shift;

	Tk::CmdLine::SetArguments(-font, "細明體 12");			# 設定預設字體
	$mw = MainWindow->new;
	$mw->title("CBETA 各版經文產生程式");
	load_ini();					# 把 ini 裡面的東西放入陣列中
	make_all_frame();	# 做出 4 個 frame	

	######################################################
	# 處理每一個 frame 裡面的元件
	######################################################

	show_top_frame();
	show_bottom_frame();
	show_left_frame();
	show_mid_frame();
	show_right_frame();

	MainLoop;		# 一定要有的視窗訊息迴圈
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
	# 最上方的說明
	$fmTop->Label(
		-text => "◆ XML2TXT_ALL ◆　由 XML 產生各種版本的經文",
		)->pack(
			-side => 'left',
			-padx => 10,			# 組件左右留空大小 10
			-pady => 10,			# 組件上下留空大小 10
			);
}

sub show_bottom_frame
{
	# 下方的執行, 取消, 結束
	
	$fmBottom->Button(
		-text => "結束", 
		-command => sub {$mw->destroy},
		)->pack(
			-side => 'right',
			-padx => 5,			# 組件左右留空大小 10
			-pady => 10,			# 組件上下留空大小 10
			);
			
	$fmBottom->Button(
		-text => "說明", 
		-command => \&show_readme,
		)->pack(
			-side => 'right',
			-padx => 10,			# 組件左右留空大小 10
			-pady => 10,			# 組件上下留空大小 10
			);
			
	$fmBottom->Button(
		-text => "執行上方所選參數", 
		-command => \&run_main,			# 執行主程式 , 並傳入所有參數
		)->pack(
			-side => 'right',
			-padx => 20,			# 組件左右留空大小 20
			-pady => 10,			# 組件上下留空大小 10
			);
			
	$fmBottom->Button(
		-text => "執行上方所選預設各組", 
		-command => \&run_main_all,			# 執行主程式 , 並傳入所有參數
		)->pack(
			-side => 'left',
			-padx => 20,			# 組件左右留空大小 20
			-pady => 10,			# 組件上下留空大小 10
			);
}

sub show_mid_frame
{
	# 再建一個 frame , 把底下用 grid 的變數集中在上方 ------------------------------
	
	$fmMidTop = $fmMid->Frame()->pack(
		-side => 'top',
		-fill => 'both',
		-padx => 10,
		-pady => 10,
		);
	
	# 主要的變數 ###################################
	
	$bt1 = $fmMidTop->Button(-text => '清除',-command => \&btT_clear_click);
	$bt2 = $fmMidTop->Button(-text => '清除',-command => \&btX_clear_click);
	$bt3 = $fmMidTop->Button(-text => '清除',-command => \&btJ_clear_click);
	$bt4 = $fmMidTop->Button(-text => '清除',-command => \&btH_clear_click);
	$bt5 = $fmMidTop->Button(-text => '清除',-command => \&btW_clear_click);
	$bt6 = $fmMidTop->Button(-text => '清除',-command => \&btI_clear_click);
	$bt7 = $fmMidTop->Button(-text => '清除',-command => \&btA_clear_click);
	$bt8 = $fmMidTop->Button(-text => '清除',-command => \&btB_clear_click);
	$bt9 = $fmMidTop->Button(-text => '清除',-command => \&btC_clear_click);
	$bt10 = $fmMidTop->Button(-text => '清除',-command => \&btD_clear_click);
	$bt11 = $fmMidTop->Button(-text => '清除',-command => \&btF_clear_click);
	$bt12 = $fmMidTop->Button(-text => '清除',-command => \&btG_clear_click);
	$bt13 = $fmMidTop->Button(-text => '清除',-command => \&btK_clear_click);
	$bt14 = $fmMidTop->Button(-text => '清除',-command => \&btL_clear_click);
	$bt15 = $fmMidTop->Button(-text => '清除',-command => \&btM_clear_click);
	$bt16 = $fmMidTop->Button(-text => '清除',-command => \&btP_clear_click);
	$bt17 = $fmMidTop->Button(-text => '清除',-command => \&btS_clear_click);
	$bt18 = $fmMidTop->Button(-text => '清除',-command => \&btU_clear_click);	

	# 第一組
	$label[1] = $fmMidTop->Label(-text => "來源目錄 ：",);
	$entry1 = $fmMidTop->BrowseEntry(-variable => \$sText[1], -choices => \@sText1);				# 輸入文字的變數	
	#Tk::grid($label[1], $entry1, -sticky => "ew",-padx => 1,-pady => 0,);
	# 第二組
	$label[2] = $fmMidTop->Label(-text => "輸出目錄 ：",);
	$entry2 = $fmMidTop->BrowseEntry(-variable => \$sText[2], -choices => \@sText2);				# 輸入文字的變數		
	Tk::grid($label[1], $entry1, $label[2], $entry2, -sticky => "ew",-padx => 1,-pady => 5,);
	
	# 第三組
	$label[3] = $fmMidTop->Label(-text => "(T)大正藏　從：",);
	$entry3 = $fmMidTop->BrowseEntry(-variable => \$sText[3], -choices => \@sText3);				# 輸入文字的變數		
	# Tk::grid($label[3], $entry3, -sticky => "ew",-padx => 1,-pady => 10,);
	# 第四組
	$label[4] = $fmMidTop->Label(-text => "到：",);
	$entry4 = $fmMidTop->BrowseEntry(-variable => \$sText[4], -choices => \@sText4);				# 輸入文字的變數		
	Tk::grid($label[3], $entry3, $label[4], $entry4, $bt1, -sticky => "ew",-padx => 1,-pady => 0,);

	# 第五組
	$label[5] = $fmMidTop->Label(-text => "(X)卍續藏　從：",);
	$entry5 = $fmMidTop->BrowseEntry(-variable => \$sText[5], -choices => \@sText5);				# 輸入文字的變數		
	#Tk::grid($label[5], $entry5, -sticky => "ew",-padx => 1,-pady => 10,);
	# 第六組
	$label[6] = $fmMidTop->Label(-text => "到：",);
	$entry6 = $fmMidTop->BrowseEntry(-variable => \$sText[6], -choices => \@sText6);				# 輸入文字的變數		
	Tk::grid($label[5], $entry5, $label[6], $entry6, $bt2, -sticky => "ew",-padx => 1,-pady => 0,);

	# 第七組
	$label[7] = $fmMidTop->Label(-text => "(J)嘉興藏　從：",);
	$entry7 = $fmMidTop->BrowseEntry(-variable => \$sText[7], -choices => \@sText7);				# 輸入文字的變數		
	#Tk::grid($label[7], $entry7, -sticky => "ew",-padx => 1,-pady => 10,);
	# 第八組
	$label[8] = $fmMidTop->Label(-text => "到：",);
	$entry8 = $fmMidTop->BrowseEntry(-variable => \$sText[8], -choices => \@sText8);				# 輸入文字的變數		
	Tk::grid($label[7], $entry7, $label[8], $entry8, $bt3, -sticky => "ew",-padx => 1,-pady => 0,);

	# 第九組
	$label[9] = $fmMidTop->Label(-text => "(H)　正史　從：",);
	$entry9 = $fmMidTop->BrowseEntry(-variable => \$sText[9], -choices => \@sText9);				# 輸入文字的變數		
	#Tk::grid($label[9], $entry9, -sticky => "ew",-padx => 1,-pady => 10,);
	# 第十組
	$label[10] = $fmMidTop->Label(-text => "到：",);
	$entry10 = $fmMidTop->BrowseEntry(-variable => \$sText[10], -choices => \@sText10);				# 輸入文字的變數		
	Tk::grid($label[9], $entry9, $label[10], $entry10, $bt4, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[11] = $fmMidTop->Label(-text => "(W)　藏外　從：",);
	$entry11 = $fmMidTop->BrowseEntry(-variable => \$sText[11], -choices => \@sText11);				# 輸入文字的變數		
	$label[12] = $fmMidTop->Label(-text => "到：",);
	$entry12 = $fmMidTop->BrowseEntry(-variable => \$sText[12], -choices => \@sText12);				# 輸入文字的變數		
	Tk::grid($label[11], $entry11, $label[12], $entry12, $bt5, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[13] = $fmMidTop->Label(-text => "(I)　百品　從：",);
	$entry13 = $fmMidTop->BrowseEntry(-variable => \$sText[13], -choices => \@sText13);				# 輸入文字的變數		
	$label[14] = $fmMidTop->Label(-text => "到：",);
	$entry14 = $fmMidTop->BrowseEntry(-variable => \$sText[14], -choices => \@sText14);				# 輸入文字的變數		
	Tk::grid($label[13], $entry13, $label[14], $entry14, $bt6, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[15] = $fmMidTop->Label(-text => "(A)　金藏　從：",);
	$entry15 = $fmMidTop->BrowseEntry(-variable => \$sText[15], -choices => \@sText15);				# 輸入文字的變數		
	$label[16] = $fmMidTop->Label(-text => "到：",);
	$entry16 = $fmMidTop->BrowseEntry(-variable => \$sText[16], -choices => \@sText16);				# 輸入文字的變數		
	Tk::grid($label[15], $entry15, $label[16], $entry16, $bt7, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[17] = $fmMidTop->Label(-text => "(B)　補編　從：",);
	$entry17 = $fmMidTop->BrowseEntry(-variable => \$sText[17], -choices => \@sText17);				# 輸入文字的變數		
	$label[18] = $fmMidTop->Label(-text => "到：",);
	$entry18 = $fmMidTop->BrowseEntry(-variable => \$sText[18], -choices => \@sText18);				# 輸入文字的變數		
	Tk::grid($label[17], $entry17, $label[18], $entry18, $bt8, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[19] = $fmMidTop->Label(-text => "(C)中華藏　從：",);
	$entry19 = $fmMidTop->BrowseEntry(-variable => \$sText[19], -choices => \@sText19);				# 輸入文字的變數		
	$label[20] = $fmMidTop->Label(-text => "到：",);
	$entry20 = $fmMidTop->BrowseEntry(-variable => \$sText[20], -choices => \@sText20);				# 輸入文字的變數		
	Tk::grid($label[19], $entry19, $label[20], $entry20, $bt9, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[21] = $fmMidTop->Label(-text => "(D)　國圖　從：",);
	$entry21 = $fmMidTop->BrowseEntry(-variable => \$sText[21], -choices => \@sText21);				# 輸入文字的變數		
	$label[22] = $fmMidTop->Label(-text => "到：",);
	$entry22 = $fmMidTop->BrowseEntry(-variable => \$sText[22], -choices => \@sText22);				# 輸入文字的變數		
	Tk::grid($label[21], $entry21, $label[22], $entry22, $bt10, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[23] = $fmMidTop->Label(-text => "(F)房山石經從：",);
	$entry23 = $fmMidTop->BrowseEntry(-variable => \$sText[23], -choices => \@sText23);				# 輸入文字的變數		
	$label[24] = $fmMidTop->Label(-text => "到：",);
	$entry24 = $fmMidTop->BrowseEntry(-variable => \$sText[24], -choices => \@sText24);				# 輸入文字的變數		
	Tk::grid($label[23], $entry23, $label[24], $entry24, $bt11, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[25] = $fmMidTop->Label(-text => "(G)佛教藏　從：",);
	$entry25 = $fmMidTop->BrowseEntry(-variable => \$sText[25], -choices => \@sText25);				# 輸入文字的變數		
	$label[26] = $fmMidTop->Label(-text => "到：",);
	$entry26 = $fmMidTop->BrowseEntry(-variable => \$sText[26], -choices => \@sText26);				# 輸入文字的變數		
	Tk::grid($label[25], $entry25, $label[26], $entry26, $bt12, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[27] = $fmMidTop->Label(-text => "(K)高麗藏　從：",);
	$entry27 = $fmMidTop->BrowseEntry(-variable => \$sText[27], -choices => \@sText27);				# 輸入文字的變數		
	$label[28] = $fmMidTop->Label(-text => "到：",);
	$entry28 = $fmMidTop->BrowseEntry(-variable => \$sText[28], -choices => \@sText28);				# 輸入文字的變數		
	Tk::grid($label[27], $entry27, $label[28], $entry28, $bt13, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[29] = $fmMidTop->Label(-text => "(L)乾隆藏　從：",);
	$entry29 = $fmMidTop->BrowseEntry(-variable => \$sText[29], -choices => \@sText29);				# 輸入文字的變數		
	$label[30] = $fmMidTop->Label(-text => "到：",);
	$entry30 = $fmMidTop->BrowseEntry(-variable => \$sText[30], -choices => \@sText30);				# 輸入文字的變數		
	Tk::grid($label[29], $entry29, $label[30], $entry30, $bt14, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[31] = $fmMidTop->Label(-text => "(M)卍正藏　從：",);
	$entry31 = $fmMidTop->BrowseEntry(-variable => \$sText[31], -choices => \@sText31);				# 輸入文字的變數		
	$label[32] = $fmMidTop->Label(-text => "到：",);
	$entry32 = $fmMidTop->BrowseEntry(-variable => \$sText[32], -choices => \@sText32);				# 輸入文字的變數		
	Tk::grid($label[31], $entry31, $label[32], $entry32, $bt15, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[33] = $fmMidTop->Label(-text => "(P)永樂北藏從：",);
	$entry33 = $fmMidTop->BrowseEntry(-variable => \$sText[33], -choices => \@sText33);				# 輸入文字的變數		
	$label[34] = $fmMidTop->Label(-text => "到：",);
	$entry34 = $fmMidTop->BrowseEntry(-variable => \$sText[34], -choices => \@sText34);				# 輸入文字的變數		
	Tk::grid($label[33], $entry33, $label[34], $entry34, $bt16, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[35] = $fmMidTop->Label(-text => "(S)宋藏遺珍從：",);
	$entry35 = $fmMidTop->BrowseEntry(-variable => \$sText[35], -choices => \@sText35);				# 輸入文字的變數		
	$label[36] = $fmMidTop->Label(-text => "到：",);
	$entry36 = $fmMidTop->BrowseEntry(-variable => \$sText[36], -choices => \@sText36);				# 輸入文字的變數		
	Tk::grid($label[35], $entry35, $label[36], $entry36, $bt17, -sticky => "ew",-padx => 1,-pady => 0,);

	$label[37] = $fmMidTop->Label(-text => "(U)洪武南藏從：",);
	$entry37 = $fmMidTop->BrowseEntry(-variable => \$sText[37], -choices => \@sText37);				# 輸入文字的變數		
	$label[38] = $fmMidTop->Label(-text => "到：",);
	$entry38 = $fmMidTop->BrowseEntry(-variable => \$sText[38], -choices => \@sText38);				# 輸入文字的變數		
	Tk::grid($label[37], $entry37, $label[38], $entry38, $bt18, -sticky => "ew",-padx => 1,-pady => 0,);

	$fmMidTop->gridColumnconfigure(1, -weight => 1);

	# 再建一個 frame , 設置各種選項 ------------------------------------------------
		
	$fmLeftThird = $fmMid->LabFrame(-label => "其他選項",
		-labelside => 'acrosstop')->pack(-side => 'top', -anchor => 'w', -padx => 15, -pady => 5);
		
	$fmLeftThird->Checkbutton( -text => '使用通用字', -variable => \$IsNormalWord, -onvalue => '', -offvalue => '-z',
		)->grid(
		$fmLeftThird->Checkbutton( -text => '顯示校勘符號＊◎', -variable => \$IsAppSign, -onvalue => '-k', -offvalue => ''),
		-padx => 5, -pady => 5, -sticky => "w");
		
	$fmLeftThird->Checkbutton( -text => '顯示檔頭資訊', -variable => \$IsJuanHead, -onvalue => '', -offvalue => '-h',
		)->grid(
		$fmLeftThird->Checkbutton( -text => '精簡格式 (for PDA)', -variable => \$IsPDA, -onvalue => '-p', -offvalue => ''),
		-padx => 5, -pady => 5, -sticky => "w");
}

sub show_right_frame
{
	# 右方的控制按鈕
	
	$fmRight->Button(
		-text => '預設來源路徑',
		-command => \&btSourcePath_click,
		)->pack(
			-side => 'top',
			-padx => 10,		# 組件左右留空大小 10
			-pady => 10,			# 組件上下留空大小 10
			);
			
	$fmRight->Button(
		-text => '選取全部冊數',
		-command => \&btAll_click,
		)->pack(
			-side => 'top',
			-padx => 10,		# 組件左右留空大小 10
			-pady => 5,			# 組件上下留空大小 10
			);
	$fmRight->Button(
		-text => '清除全部冊數',
		-command => \&btAll_clear_click,
		)->pack(
			-side => 'top',
			-padx => 10,		# 組件左右留空大小 10
			-pady => 5,			# 組件上下留空大小 10
			);

	# 選擇 一卷一檔或一經一檔 的 labframe (radiogroup)
	
	$lfNormal = $fmRight->LabFrame(-label => "檔案格式",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');
	
	$lfNormal->Radiobutton(
		-text => '一卷一檔', 
		-variable => \$IsNormal, 
		-value => '-u',
		)->pack;

	$lfNormal->Radiobutton(
		-text => '一經一檔', 
		-variable => \$IsNormal, 
		-value => '',
		)->pack;
	
	# 選擇 normal 或 app 的 labframe (radiogroup)
	
	$lfApp = $fmRight->LabFrame(-label => "檔案版本",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');

	$lfApp->Radiobutton(
		-text => '普及版', 
		-variable => \$IsApp, 
		-value => '',
		)->pack;

	$lfApp->Radiobutton(
		-text => 'App 版', 
		-variable => \$IsApp, 
		-value => '-a',
		)->pack;
		
	# 選擇 Big5 或 utf8 的 labframe (radiogroup)
	
	$lfBig5 = $fmRight->LabFrame(-label => "字集",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');
	
	$lfBig5->Radiobutton(
		-text => 'Big5 版', 
		-variable => \$IsBig5, 
		-value => '',
		)->pack;

	$lfBig5->Radiobutton(
		-text => 'UTF8 版', 
		-variable => \$IsBig5, 
		-value => '-e utf8',
		)->pack;
		
	# 選擇梵文(悉曇、蘭札)呈現的的 labframe (radiogroup)
	
	$lfSan = $fmRight->LabFrame(-label => "悉曇蘭札呈現",
		-labelside => 'acrosstop')->pack(-side => 'top', -padx => 5, -pady => 5, -fill => 'both');
	
	$lfSan->Radiobutton(
		-text => '羅馬轉寫字', 
		-variable => \$IsSan, 
		-value => '',
		)->pack(-anchor => "w");

	$lfSan->Radiobutton(
		-text => '&SD-xxxx;', 
		-variable => \$IsSan, 
		-value => '-x 1',
		)->pack(-anchor => "w");
		
	$lfSan->Radiobutton(
		-text => '◇【◇】', 
		-variable => \$IsSan, 
		-value => '-x 2',
		)->pack(-anchor => "w");
}

sub show_left_frame
{
	$fmLeft2 = $fmLeft->Frame()->pack(-padx => 10);
	
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5Normal, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5普及版',-command => \&bt_Big5Normal_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5App, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 App版', -command => \&bt_Big5App_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_UTF8Normal, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'UTF8普及版',-command => \&bt_UTF8Normal_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_UTF8App, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'UTF8 App版',-command => \&bt_UTF8App_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_PDA, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'PDA 版',-command => \&bt_PDA_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	
	
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5NormalDes, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 普及版(組字)',-command => \&bt_Big5NormalDes_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5AppDes, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 App版(組字)',-command => \&bt_Big5AppDes_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5AppJuan, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => 'Big5 App版(單卷)',-command => \&bt_Big5AppJuan_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	# xml2txt -v $vol -u -h -k -x 2 -z  c:\release\normal
	$fmLeft2->Checkbutton( -text => '', -variable => \$sel_Big5NoteSign, -command => \&bt_checkall_click,
		)->grid(
		$fmLeft2->Button(-text => '校注比對版(單卷)',-command => \&bt_Big5NoteSign_click),
		-padx => 0, -pady => 5, -sticky => "ew");
	$fmLeft2->Checkbutton( -text => '全部', -variable => \$sel_All, -command => \&sel_All_click,
		)->grid("-",
		-padx => 0, -pady => 5, -sticky => "w");
}

# 把 Entry 輸入欄位存入下拉選單中

sub push_alldata_2_entry
{
	if (!$sText1{$sText[1]} && $sText[1] ne "") 
	{
		$entry1->insert(0, $sText[1]);
		unshift(@sText1 , $sText[1]);
	 	$sText1{$sText[1]}++;
	 	if($#sText1 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText2 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText3 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText4 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText5 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText6 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText7 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText8 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText9 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText10 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText11 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText12 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText13 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText14 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText15 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText16 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText17 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText18 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText19 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText20 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText21 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText22 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText23 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText24 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText25 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText26 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText27 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText28 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText29 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText30 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText31 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText32 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText33 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText34 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText35 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText36 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText37 == 30)		# 超過 30 個就移除最後一個
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
	 	if($#sText38 == 30)		# 超過 30 個就移除最後一個
	 	{
	 		$entry38->delete($#sText38,$#sText38);
	 		$sText38{$sText38[$#sText38]} = 0;
	 		pop(@sText38);
	 	}
	}
}

# 把 Entry 的資料存入 ini 檔
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
	
	# 儲存變數
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
	
	# 儲存最左方的選取
	
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
	
	# 儲存中下方的選項
	
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

# 把 Entry 的資料由 ini 檔載入
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
		$win_readme->deiconify();		# 會由最小化恢復
		$win_readme->raise();			# 大概是會跑到最前面, 但不會取得焦點
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

【程式說明】

　　本程式是呼叫 c:\cbwork\work\bin\xml2txt.bat ，程式目的是由 XML 檔
　　產生各種版本的經文。

【右方按鈕工具】

　　程式右方的工具按鈕，方便提供基本的預設值。
　　第一個是預設 XML 的來源路徑，其餘是大正與卍續冊數的預設值。

【左方按鈕工具】

　　左方按鈕是產生各種版本的預設參數。
　　按鈕旁邊有一個可勾選的選項，此功能在【使用說明】中解釋。

【參數說明】

　　參數有三種，第一種是 XML 來源目錄與成果輸出目錄，第二種是冊數的輸入，
　　第三種是產生各種版本的參數。
	
　　冊數的輸入有大正、卍續、嘉興、正史、藏外...等，用法相同。以大正藏為例，共有三種輸入法：

　　1. 只處理一冊，在「大正藏 從」輸入某一冊的數字即可。

　　2. 處理連續冊，例如由大正藏第 10 冊至第 20 冊，即在「大正藏 從」輸入 10，
　　  「大正藏 到」輸入 20 即可。

　　3. 處理指定冊數，可用半型逗號分開數字，也可用 (數字..數字) 來表示連續範圍。
　　   這種格式只能出現在「大正藏 從」，此時會忽略「大正藏 到」的欄位內容。
　　   例如在「大正藏 從」輸入：
　　   5,7,(10..14),20,(40..42)
　　   表示處理的冊數為 5,7,10,11,12,13,14,20,40,41,42
   
　　　 不存在的冊數會自動忽略，所以處理大正藏全部可以用方法 2 的由 1 到 85 冊，
　　　 也可以用方法 3 輸入 (1..55),85 或 (1..85) 甚至 (1..99) 都可以。
　　　 三位數以上的數字則不會通過檢查。

【使用說明】

　　程式主要有二種使用模式：
	
　　1. 設定來源與輸出目錄、設定冊數、設定各種參數後，按下「執行上方所選參數」，
　　   即可依參數設定產生指定冊數的經文。
	
　　2. 勾選最左方的選項，再按下左下方的「執行上方所選預設各組」，即可依各組
　　   預設參數產生各種經文。預設的參數是輸出目錄與經文格式，但不包括來源目錄
　　   及冊數。
	
　　解釋：
	
　　第一種方式只能產一種經文，例如設定的參數是普及版，則可以產生各冊普及版
　　的經文。
	
　　第二種方式可以產生很多種經文，例如勾設普及版、App版、PDA 版，並指定
　　全部冊數，即可產生上述三種版本的全部經文。

【程式特色】

　　本程式會將使用過的參數及上次最後執行的參數存在 xml2txt_all.ini 該檔之中，
　　此檔請勿隨意手動修改，至少不要破壞順序，歷史記錄最多30筆，下次再次執行
　　程式時，可以呈現上次最後開啟的畫面，而且可以很方便找到經常使用到的參數。

【版本歷史】

　　2007/06/22 V1.0    第一版
　　2009/03/19 V1.1    加入嘉興藏、正史、藏外的選項
　　2010/12/25 V1.2    加入 金藏,中華藏,房山石經,佛教大藏經,高麗藏,乾隆藏,卍正藏,永樂北藏,宋藏遺珍,洪武南藏
　　2011/01/23 V1.3    處理冊數三碼的藏經
　　2011/05/14 V1.4    加入 百品, 補編, 國圖
------------------------------------------------------------------------------
EOD
		);
	}
}