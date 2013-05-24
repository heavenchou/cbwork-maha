# go.pl
# 編碼: utf-8
#
#edith modify: 2005/1/7 add ZIP、File Modules
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Path;

my $zipit = 0;		###################### 要不要壓縮 ######################

#edith test
$xml_root="c:/cbwork/xml";			###################### 來源目錄 ######################
$outPath="c:/release/app1-utf8";		# 輸出目錄
$outPath_zip="c:/release/app-zip";

mkdir($outPath,MODE);

opendir DIR, "$xml_root" or die;
@alldir = grep /^[TX]/, readdir DIR;
closedir DIR;
foreach $vol (@alldir) {
	#if($vol eq "Txx")			######################## 全部都要 ########################
	#if($vol !~ /X5[79]/)			######################## 只要這一冊 ######################
	if($vol !~ /X05/)		######################## 只要這一冊 ######################
	{
		#if($vol !~ /X8[0124]/)		######################## 只要這一冊 ######################
		#{
			print "skip $vol\n";
			next;
		#}
	}
	$dir = "$xml_root/$vol";
	chdir($dir);
	do_vol();
}
chdir ("c:/cbwork");

sub do_vol  {
	chdir($dir);
	
	#system "\"c:/program files/winzip/wzzip\" \\\\C880318053\\mo\\2001-07-27\\$vol.zip c:/cbwork/xml/$vol/*.xml";

	### Normal Format
	##$opt_g 去除行首(或段首)資訊的選項
	#  -a app version, 預設不做 app 移位
	#  -h 不要檔頭資訊
	#  -k 顯示校勘符號、＊、◎
	#  -u 一卷一檔, 預設是一經一檔
	#  -z 不使用通用字
	#  -o 輸出目錄
	#  -v 冊別
	#  -p: PDA Version
	#  -e output encoding
	
		####system "xml2txt  -a -v $vol -o c:/release/normal -u"; # 光碟用
		####system "xml2txt -v $vol -o e:/release/normal -u -z";
		####system "xml2txt -v $vol -b -u"; # 給惠敏法師的, 用部類目錄
		####system("normal -v $vol -e gbk -o $outPath");
		####system "\"c:/program files/winzip/wzzip\" c:/release/normal-zip/$vol.zip c:/release/normal/$vol";
	
	# normal
	
	#system("xml2txt -z -u -v $vol -o c:/release/normal-des");		# 標準 normal, big5, 用組字式
	
	system("xml2txt -u -v $vol -o c:/release/normal");					# 標準 normal, big5
	#system("xml2txt -e utf8 -u -v $vol -o c:/release/normal-utf8"); 	# 標準 normal, utf8 
		
	# app1
	
		####system("xml2txt -a -j -m -e sjis -o c:/release/shift-jis"); ### app1 s-jis format
		####if (-e "c:/cbwork/err.txt") { die; }
		####system("xml2txt -v $vol -a -o c:/release/app1"); #edith 2005/1/5 轉 big5 app 版		
		####-e output encoding
		####system("xml2txt -e utf8 -v $vol -a -o c:/release/app1-utf8"); #edith 2005/1/6 轉 utf8 app 版
		####system "\"c:/program files/winzip/wzzip\" c:/release/app1-utf8-zip/$vol.zip c:/release/app1-utf8/$vol";
		####-g 去除行首(或段首)資訊的選項
	
	#system("xml2txt -z -v $vol -a -o c:/release/app1-des");			# big5 app1 版 一經一檔, 用組字式
	####system("xml2txt -u -z -v $vol -a -o c:/release/app-des");		# big5 app 版 一卷一檔, 用組字式
	
	#system("xml2txt -v $vol -a -o c:/release/app1");					# big5 app1 版 一經一檔
	#system("xml2txt -e utf8 -v $vol -a -o c:/release/app1-utf8");		# utf8 app1 版 一經一檔
	
	#system("xml2txt -u -v $vol -a -o c:/release/app");					# big5 app 版 一卷一檔
	####system("xml2txt -u -e utf8 -v $vol -a -o c:/release/app-utf8");	# utf8 app 版 一卷一檔
		
	# PDA Version
	
		#### -p: PDA Version, -u: 一卷一檔, -b: 部類目錄
		####system("xml2txt -p -u -b $i -o c:/release/pda-bulei");
		####system("xml2txt -v $vol -p -u"); # PDA Version, 一卷一檔
		####if (-e "c:/cbwork/err.txt") { die; }
		
		####system "\"c:/program files/winzip/wzzip\" c:/release/pda-zip/$vol.zip c:/release/pda/$vol";		
		####-g 去除行首(或段首)資訊的選項
		####system("xml2txt -g -v $vol -p -u -o c:/release/pda" );	#edith 2005/1/21 轉 big5 pda 版(去除行首(或段首)資訊)
		
	#system("xml2txt -v $vol -p -u -o c:/release/pda" );	#edith 2005/1/21 轉 big5 pda 版

		
		#edith note:2005/2/2 大陸版
		#-z 不使用通用字
		#1. 使用組字式, 不用通用字.
		#2. 一段一行.
		#3. 沒有任何行首, 卷首及段首等資料.
		#4. 偈頌能依原書切行 (不要像 PDA 版那種格式)
		#system("xml2txt -g -v $vol -p -u -z -o c:/release/dalu" );	#edith 2005/2/2 轉 big5 大陸版(去除行首(或段首)資訊)

	### HTML Format
	#system "html1 $vol";
	#system "\"c:/program files/winzip/wzzip\" k:/temp(¨C¬P´d@²M°£)/ray/$vol.zip c:/release/html/$vol";
	#if (-e "c:/cbwork/err.txt") { die; }
	
	### HH-JK
	#chdir("c:/cbwork/work/bin");
	#system "hh4-jk $i";
	#if (-e "c:/cbwork/err.txt") { die "hh4 i=$i"; }
	#system "hh5-jk $i";
	#if (-e "c:/cbwork/err.txt") { die "hh5 i=$i"; }

	### RTF Format
	#chdir("c:/cbwork/work/bin");
	#system "perl /cbwork/work/bin/x2rtf.pl -v $vol -t";
	#system "\"c:/program files/winzip/wzzip\" y:/cbeta/rtf/$vol.zip c:/release/doc/$vol";
	#if (-e "c:/cbwork/err.txt") { die; }
	
	# backup
	#system "\"c:/program files/winzip/wzzip\" b:/simple/20021021/$vol.zip c:/cbwork/simple/$vol/new.txt";
	#system "\"c:/program files/winzip/wzzip\" u:/xml/20021104/$vol.zip c:/cbwork/xml/$vol/*.xml";

	# Restore
	#system "\"c:/program files/winzip/wzunzip\" -o u:/simple/20021021/$vol.zip c:/cbwork/simple/$vol";
	
	if (-e "/cbwork/err.txt") { die; }
}

exit if($zipit == 0) ;

#edith modify: 2005/1/7 add ZIP Module
$xml_in_dir=$outPath;
$xml_out_dir=$outPath_zip;

opendir DIR, "$xml_in_dir" or die;
@alldir = grep /^[TX]/, readdir DIR;
closedir DIR;
rmtree(["$xml_out_dir"]);			#刪除 -zip 目錄
#print STDERR "Clear old files $xml_out_dir\n";
mkdir($outPath_zip,MODE);	#再建 -zip 目錄
foreach $vol (@alldir) {
	$dir = "$xml_in_dir/$vol";
	zip();
}

sub zip {
	my $zip = Archive::Zip->new();

	opendir THISDIR, "$xml_in_dir/$vol" or die "serious dainbramage: $!";
	@allfiles = grep /\.(txt)$/, readdir THISDIR;
	closedir THISDIR;
	
	my $file;
	foreach $file (@allfiles) {
		print STDERR "\n> $file ";
		$zip->addFile("$xml_in_dir/$vol/$file", $file);
	}
	print STDERR "\n111 > $xml_out_dir/$vol.zip\n";
	die 'write error' if $zip->writeToFileNamed( "$xml_out_dir/$vol.zip" ) != AZ_OK;
}