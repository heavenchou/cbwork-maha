@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
goto endofperl
@rem ';
#!perl
#line 14

#－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
# html-jk.bat
# 校勘 HTML 版
#
# 輸出目錄：cbeta.cfg 裏的 outdir 下的 html-jk 目錄
# 執行例：c:\cbwork\work\bin>html-jk t01
#
# v0.1, 2002/9/23 01:32PM by Ray
# v0.2, 2002/10/31 03:56PM by Ray
# v0.3, 編碼改 utf8, 2002/11/1 10:35AM by Ray
# v0.4, <lem> 裏有 <corr> 分 大正藏版跟 CBETA 版顯示, 2002/11/14 11:49AM by Ray
# v0.5, <note type="mod"> 裏的勘誤呈現
# v0.6, 解決 <note type="inline"> 包 <note type="orig"> 的問題, 2002/12/11 10:02AM by Ray
# v0.7, 版本編號改2碼
# v0.8, 2002/12/16 04:21PM by Ray
# v0.9, 一條校勘兩個某本, 2002/12/16 05:06PM by Ray
# v0.10, 【Ａ】【Ｂ】, 2002/12/16 06:06PM by Ray
# v0.11, <note type="mod"> 裏有雙引號
# v0.12, 不用通用字, 2002/12/19 12:03PM by Ray
# v0.13, 某本，某本Ｂ, 2002/12/20 02:52PM by Ray
# v0.14, 【unknown】不出現在左下角下拉式功能表, 2002/12/20 03:21PM by Ray
# v0.15, 悉曇字以 TTF 呈現, 2002/12/20 06:07PM by Ray
# v0.16, debug <p> 前的換新段落, 2002/12/24 05:29PM by Ray
# v0.17, 2002/12/25 05:35PM by Ray
# v0.18, 轉寫字用 Lucida Sans Unicode, 2003/1/7 03:28PM by Ray
# v0.19, 2003/1/8 11:43AM by Ray
#－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

$xml_root = "c:/cbwork/xml";
$imgpath = "../images/";
$scriptpath = "../script/";
$csspath = "../";
$fontpath = "../gaiji-CB/";
$absFontPath = "x:/cbeta/html/fontimg";
$debug=0;

open O, ">c:/cbwork/err.txt";
close O;

$chm;
$nid=0;
$vol = shift;
$inputFile = shift;
$vol = uc($vol);
$dir = $vol;
$vol = substr($vol,0,3);

$file = "CBETA.CFG";
if ($vol eq ""){
	print "\t$0: Produces CBETA HTML Files from XML source\nUsage: \n\t$0 T10\n";
	print "T10 is the subdirectory where the XML files are found\n";
	print "The program also needs a config file CBETA.CFG\n";
	print "The config file should to be in the current directory or in the directory of this program\n";
	print "\tConfig File Format SAMPLE:\n\nDIR=C:\\CBETA\\T10\n";
	print "OUTDIR=C:\\RELEASE\n";
	print "#CHAR can be NOR or ORG\n";
	print "CHAR=NOR\n";   
	exit;
}
if (open (CFG, $file)){
} else {
	$f = $0;
	$f =~ s/\/.*//;
	open (CFG, "$f\\$file") || die "can't open neither $file nor $f\\$file!!\n";
}


while(<CFG>){
	next if (/^#/); #comments
	chomp;
	($key, $val) = split(/=/, $_);
	$key = uc($key);
	$cfg{$key}=$val; #store cfg values
	print "$key\t$cfg{$key}\n";
}

$outDir = $cfg{"OUTDIR"};
mkdir($outDir, MODE);
$outDir .= "/html-jk";
mkdir($outDir, MODE);
mkdir($outDir . "/$dir", MODE);

$in_dir = $xml_root . "/$dir";
opendir (INDIR, $in_dir);
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
$pattern = '%big5%.*?%/big5%|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "hhead.pl";
require "b52utf8.plx";
require "subutf8.pl";

# 校勘版呈現雙圈 ◎
#$utf8out{"\xe2\x97\x8e"} = '';
$utf8out{"\xe2\x97\x8e"} = "\xa1\xb7";

#openOF();    # 全冊經文 T99.htm

#use Encode;
use XML::Parser;
#use Image::Size;

my %Entities = ();
my $ent;
my $val;
my $text;
my $headText;
my $div1head;
my $juanText;
my $juanNum;
my $juanURL;
my $flagSource=0;
local $no_nor;  # 缺字不用通用字
my $source;
my $column="";    # 記錄目前頁碼，如：0001a
my $preColumn=""; # 上一頁
my $sutraNum="";  # 記錄目前經號，如：1111
my $sutraName=""; # 經名
my $div1Type="";
my $div2Type="";
my $headId="";
my @saveatt=();   # 儲存 attribute
my @lines=();     # 儲存上一欄的經文
my @elements=();
my %saveXu=();
my %saveJuan=();
my %savePin=();   # 品
my %savePin2=();  # 品 (div2)
my %saveHui=();   # 會
my %saveFen=();   # 分
my %saveJing=();  # 經
my %saveOther=();
my $version;
my %vers=();
my $firstLineOfSutra;
my $firstLineOfPage;
my $saveof = "";
my $CorrCert;

%version = (
	"CBETA"  => "000",
	"大"     => "010", 
	"宋"     => "020", 
	"元"     => "030", 
	"明"     => "040",
	"明異"   => "041",
	"麗"     => "050",
	"麗乙"   => "051",
	"聖"     => "060",
	"聖乙"   => "061",
	"聖丙"   => "062",
	"宮"     => "070",
	"宮乙"   => "071",
	"德"     => "080",
	"万"     => "090",
	"石"     => "100",
	"知"     => "110",
	"醍"     => "120",
	"和"     => "130",
	"東"     => "140",
	"中"     => "150",
	"久"     => "160",
	"森"     => "170",
	"敦"     => "180",
	"敦乙"   => "181",
	"敦丙"   => "182",
	"敦方"   => "183",
	"福"     => "190",
	"福乙"   => "191",
	"博"     => "200",
	"縮"     => "210",
	"金"     => "220",
	"高"     => "230",
	"原"     => "240",
	"甲"     => "250",
	"乙"     => "251",
	"丙"     => "252",
	"丁"     => "253",
	"戊"     => "254",
	"己"     => "255",
	"內"     => "a04",
	"西"     => "a06",
	"別"     => "a07",
	"南"     => "a09",
	"Ａ"     => "b00",
	"Ｂ"     => "b01",
	"大曆"   => "b03",
	"日光"   => "b04",
	"北藏"   => "b05",
	"南藏"   => "b09",
	"流布本" => "b10",
	"某本"   => "b11",
	"某本Ｂ" => "b12",
	"獅谷"   => "b13",
	"unknown" => "zzz"
);

#my %dia = (
# "Amacron","A^",
# "amacron","a^",
# "ddotblw","d!",
# "Ddotblw","D!",
# "hdotblw","h!",
# "imacron","i^",
# "ldotblw","l!",
# "Ldotblw","L!",
# "mdotabv","m%",
# "mdotblw","m!",
# "ndotabv","n%",
# "ndotblw","n!",
# "Ndotblw","N!",
# "ntilde","n~",
# "rdotblw","r!",
# "sacute","s/",
# "Sacute","S/",
# "sdotblw","s!",
# "Sdotblw","S!",
# "tdotblw","t!",
# "Tdotblw","T!",
# "umacron","u^"
#);      

my %dia = (
 "acirc","a^",
 "Amacron","#AA",
 "amacron","aa",
 "ddotblw",".d",
 "Ddotblw",".D",
 "ecirc","e^",
 "hdotblw",".h",
 "imacron","ii",
 "icirc","i^",
 "ldotblw",".l",
 "Ldotblw",".L",
 "mdotabv","%%m",
 "mdotblw",".m",
 "ndotabv","%%n",
 "ndotblw",".n",
 "Ndotblw",".N",
 "ntilde","~n",
 "ocirc","o^",
 "rdotblw",".r",
 "sacute","`s",
 "Sacute","`S",
 "sdotblw",".s",
 "Sdotblw",".S",
 "tdotblw",".t",
 "Tdotblw",".T",
 "ucirc","u^",
 "umacron","uu"
);      

my %lucida = (
 "Amacron","&#256;",
 "amacron","&#257;",
 "ddotblw","d&#x0323;",
 "Ddotblw","D&#x0323;",
 "hdotblw","h&#x0323;",
 "imacron","i&#x0304;",
 "ldotblw","l&#x0323;",
 "Ldotblw","L&#x0323;",
 "mdotabv","m&#x0307;",
 "mdotblw","m&#x0323;",
 "ndotabv","n&#x0307;",
 "ndotblw","n&#x0323;",
 "Ndotblw","N&#x0323;",
 "ntilde","n&#x0303;",
 "rdotblw","r&#x0323;",
 "sacute","s&#x0301;",
 "Sacute","S&#x0301;",
 "sdotblw","s&#x0323;",
 "Sdotblw","S&#x0323;",
 "tdotblw","t&#x0323;",
 "Tdotblw","T&#x0323;",
 "umacron","u&#x0304;"
);

%romanNum = (
	"aBigone", "I",
	"aBigtwo", "II",
	"aBigthree", "III",
	"aBigfour", "IV",
	"aBigfive", "V",
	"aBigsix",  "VI",
	"aBigseven", "VII",
	"aBigeight", "VIII",
	"aBignine",  "IX",
	"aBigten",   "X",
	"aSmallone", "i",
	"aSmalltwo", "ii",
	"aSmallthree", "iii",
	"aSmallfour",  "iv",
	"aSmallfive",  "v",
	"aSmallsix",   "vi",
	"aSmallseven", "vii",
	"aSmalleight", "viii",
	"aSmallnine",  "ix",
	"aSmallten",   "x"
);

my %lastpage = (
  "T01","0924c",
  "T02","0884b",
  "T03","0975c",
  "T04","0802b",
  "T05","1074c",
  "T06","1073b",
  "T07","1110b",
  "T08","0917b",
  "T09","0788b",
  "T10","1047b",
  "T11","0977a",
  "T12","1119b",
  "T13","0998a",
  "T14","0968c",
  "T15","0807a",
  "T16","0857c",
  "T17","0963a",
  "T22","1072a",
  "T23","1057b",
  "T24","1122a",
  "T25","0914a",
  "T26","1031c",
  "T27","1004a",
  "T28","1001b",
  "T29","0977c",
  "T30","1035b",
  "T31","0896b",
  "T32","0790c"
);

#my $parser = new XML::Parser(Style => Stream, NoExpand => True);
my $parser = new XML::Parser(NoExpand => True);
        

$parser->setHandlers (
	Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default,
	Final => \&final_handler
);
        
$juan_text="";
if ($inputFile eq "") {
	open_toc();
	$first_juan=1;
	for $file (sort(@allfiles)){
		print STDERR "\n$file\n";
		$parser->parsefile("$in_dir/$file");
	}
	closeOF();
	close_toc();
} else {
  $file = $inputFile;
  print STDERR "\n$file\n";
  $parser->parsefile($file);
}       
write_tool();
print STDERR "Done!!\n";
unlink "c:/cbwork/err.txt";

sub open_toc {
	my $f="$outDir/$dir/toc.htm";
	open TOC, ">$f" or die "無法開啟 $f\n";
	select TOC;
	print <<"XXX";
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=big5">
	<base target="text">
</head>
<body>
XXX
}

sub close_toc {
	print TOC "</body>\n";
	print TOC "</html>";
	close TOC;
}

#-------------------------------------------------------------------
sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) { return; }
	#local($k) = "." . $cfg{"CHAR"};
	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
	#$file =~ s#/#\\#g;
	#$file =~ s/\.\./$cfg{"DIR"}/;
	#print STDERR "open Entity definition: $file\n";
	open(T, "$in_dir/$file") || die "can't open $file\n";
	while(<T>){
		chop;
		$_=b52utf8($_);
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
			/^(.+)\s+\"(.*)\".*/;
			$ent = $1;
			$val = $2;
			$ent =~ s/ //g;

			if ($file=~/jap\.ent/) { # 如果是日文
				if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # 優先使用 Unicode
				$no_nor{$ent} = $val;
			} elsif ($ent =~ /SD-(.{4})/) {
				my $s=$1;
				#$s=pack("H4", $s);
				#$s="&SD-$1;";
				#$Entities{$ent} = "◇";
				#$no_nor{$ent} = "◇";
				$s = "FigT00$1";
				#$s = "<font face='siddam'>$s</font>";
				$Entities{$ent} = $s;
				$no_nor{$ent} = $s;
				next;
			} else {
				# 不用 M 碼了
				#if ( $val=~/mojikyo=\'(.+?)\'/) {
				#	my $m=$1;  # 否則用 M 碼
				#	my $des = "";
				#	if ( $val=~/des=\'(.+?)\'/) { $des=$1; } # 否則用 M 碼
				#	else { $des = $m; }
				#	#if ($des=~/\[(.*)\]/) { $des = $1; }
				#	$m =~ s/^M//;
				#	push @mojikyo,$m;
				#	if (-e "$absFontPath/$m.gif") {
				#		my $href = "javascript:showpic(\"${fontpath}$m.gif\")";
				#		if ($des=~/^(.*?)\[(.*)\](.*)$/) {  # 可能是通用詞
				#			$no_nor{$ent} = $1 . "[<a href='$href'>$2</a>]" . $3;
				#		} else {
				#			$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				#		}
				#	} else {
				#		$no_nor{$ent} = $des;
				#	}
				#} elsif ( $val=~/des=\'(.+?)\'/) {  # 組字式
				if ( $val=~/des=\'(.+?)\'/) {  # 組字式
					my $des=$1;
					$no_nor{$ent} = $1;
					if ($ent =~ /^CB/) {
						my $s = substr($ent,2,2);
						my $href = "javascript:showpic(\"${fontpath}$s/$ent.gif\")";
						$no_nor{$ent} = "<a href='$href'>$des</a>";
					}
				} else { 
					$no_nor{$ent} = $ent; 
				} # 最後用 CB 碼
				
				# 校勘版不用通用字
				#if ($val=~/nor=\'(.+?)\'/) { # 優先使用通用字
				#	$val=$1; 
				#} else {
					$val = $no_nor{$ent};
				#}
			}
		} else {
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
			$no_nor{$ent} = $val;
		}    
		$Entities{$ent} = $val;
	}     
}       
        
        
sub default {
    my $p = shift;
    my $string = shift;

	# added by Ray 1999/11/23 05:25PM
	# <note type="sk">, <note type="foot"> 的內容不顯示
	my $parent = lc($p->current_element);
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		#if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}     
        

	#if ($parent eq "note") {
	if ($in_note) {
		$string =~ s/^\&(.+);$/&rep3($1)/eg;
		$string =~ s#&SD\-(\w\w\w\w);#"%big5%&SD" . pack("H4",$1) . ";%/big5%"#e;
		if ($note_type eq "orig") {
			$jk_orig{$note_n} .= $string;
			#$jk_orig{$note_n} =~ s#<font face="CBDia">(.*?)</font>#$1#g;
			$jk_orig{$note_n} =~ s#<font face="Lucida Sans Unicode">(.*?)</font>#$1#g;
			return;
		}
		if ($note_type eq "mod") {
			$jk_mod{$note_n} .= $string;
			#$jk_mod{$note_n} =~ s#<font face="CBDia">(.*?)</font>#$1#g;
			$jk_mod{$note_n} =~ s#<font face="Lucida Sans Unicode">(.*?)</font>#$1#g;
			return;
		}
	}

	$string =~ s/^\&(.+);$/&rep($1)/eg;
    if ($bibl == 1){
		$bib .= $string ;
#		print STDERR "$bib\n";
	}

	rdg_add_char($string);
	
	$string =~ s#FigT00(\w{4})#<img src="../sd-gif/SD-$1.gif">#g;
	
	if ($$text_ref =~ /(.*)<\/font>$/) {
		my $s1 = $1;
		if ($string =~ /^<font face=\"CBDia\">(.*)/) {
			$$text_ref = $s1 . $1;
		} elsif ($string =~ /^(\w)$/) {
			$$text_ref = $s1 . $1 . "</font>";
		} else {
			$$text_ref .= $string if ($pass == 0); 
		}
	} else {
		$$text_ref .= $string if ($pass == 0); 
	}
}       
        
sub init_handler
{       
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$div1Type='';
	$fileopen = 0;
	$currentFont='';
	$in_note=0;
	%juan_links=();
	$juan_name="";
	@juan_names=();
	$num = 0;
	$oldof = "";
	$oldpath = "";
	$close = "";
	$no_nor=0;
	$note_type="";
	@note_type=();
	$title = "";
	@elements=();
	@close=();
	@no_nor=();
	@saveFont=();
	$text="";
	$text2 = '';
	$text3 = '';
	$text2_dirty = 0;
	$text3_dirty = 0;
	$text_ref = \$text;
	$twoLineModeLine = 0;
	$xu=0;
	%jk=();
	%current_wit=();
	@apps=();
	%word_count=();
}       
        
sub final_handler {
	my $old = select();
	select TOC;
	if ((scalar @juan_names) < 2) {
		my_print("<p>No. $sutraNum<br>《<a href=\"");
		$juan_name = $juan_names[0];
		my_print($juan_links{$juan_name});
		my_print("\">$sutraName</a>》\n");
	} else {
		print "<p>No. $sutraNum<br>";
		my_print("《$sutraName》\n<ul>\n");
		foreach $juan_name (@juan_names) {
			print "<li><a href=\"";
			print $juan_links{$juan_name};
			my_print("\">$juan_name</a>\n");
		}
		print "</ul>\n";
	}
	select $old;
	closeOF();
}

sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	
	push @no_nor, $no_nor;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	
	my $parent = lc($p->current_element);
        
	$elementChar="";
        
	### <anchor> ###
	if ($el eq "anchor") {
		if ($att{"id"} =~ /^fx/) {
			$$text_ref .= "<font face='新細明體'>[＊]</font>";
		}
	}
	
	### <app> ###
	if ($el eq "app") {
		my $app_n = $att{"n"};
		push @apps, $app_n;
		$word_count{$app_n} = $att{"word-count"};
		#$$text_ref .= "<app n=\"$app_n\">";
	}
	
	### <body> ###
	$pass = 0 if $el eq "body";
       
	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>　　　　" ;
		#$indent = "<br>　　　　";
		#$$text_ref .= "<p><span class='byline'>　　　　" ;
		$$text_ref .= "<p class='byline'>" ;
		     
		# marked by Ray 1999/11/30 10:26AM
		#$indent = "　　　　";
	}     
       
	### <cell>
	if ($el eq "cell" and not $pass) {
		$$text_ref .= "<td";
		if ($att{"rows"} ne '') {
			$$text_ref .= ' rowspan="' . $att{"rows"} . '"';
		}
		if ($att{"cols"} ne '') {
			$$text_ref .= ' colspan="' . $att{"cols"} . '"';
		}
		$$text_ref .= ">";
	}
	
	### <corr>
	if ($el eq "corr") {
		$in_corr=1;
		$corr="";
		$CorrCert = lc($att{"cert"});
		$sic = resolveEntInAtt($att{"sic"});
		#$sic = myDecode($sic);
		my $vc;
		if ($CorrCert ne "" and $CorrCert ne "100") {
			$$text_ref .= $sic;
			$vc=$sic;
		} else {
			if ($in_note and $note_type eq "mod") {
				$jk_mod{$note_n} .= "{{";
			}
			#$$text_ref .= "<span class='corr'>";
			$vc="";
		}
		my $n=@apps;  # 取得上層已累積幾層 app
		if ($n > 0) { # 如果這個 <corr> 在 <app> 裏
			foreach $n (@apps) {
				if ($current_wit{$n} eq "大 CBETA") { # 如果本組 app 進行到 <lem>
					$app{$n}{"大"} .= $sic; # 大正藏版內容
					$app{$n}{"CBETA"} .= $vc; # CBETA 版內容
				}
			}
		}		
	}
       
	### <div1> ###
	if ($el eq "div1"){
		$div1head = "";
		# div1 的 type 屬性可以延續上一個 div1
		if ($att{"type"} ne "") { 
			$div1Type = lc($att{"type"}); 
		}
		if ($div1Type eq "xu"){
			if ($xu != 1 and $num==0) { changefile(); }
			$xu = 1;
			$num = 0;
		#} elsif ($num == 0 && (div1Type eq "juan" || div1Type eq "jing" || div1Type eq "pin" || div1Type eq "other")) {
		} elsif ($num == 0 && div1Type ne "w") {
			if ($juanNum == 0) {
				if ($vol eq "T06") { $juanNum = 201; }
				elsif ($file eq "T07n0220c.xml") { $juanNum = 401; }
				elsif ($file eq "T07n0220d.xml") { $juanNum = 538; }
				elsif ($file eq "T07n0220e.xml") { $juanNum = 566; }
				elsif ($file eq "T07n0220f.xml") { $juanNum = 574; }
				elsif ($file eq "T07n0220g.xml") { $juanNum = 576; }
				elsif ($file eq "T07n0220h.xml") { $juanNum = 577; }
				elsif ($file eq "T07n0220i.xml") { $juanNum = 578; }
				elsif ($file eq "T07n0220j.xml") { $juanNum = 579; }
				elsif ($file eq "T07n0220k.xml") { $juanNum = 584; }
				elsif ($file eq "T07n0220l.xml") { $juanNum = 589; }
				elsif ($file eq "T07n0220m.xml") { $juanNum = 590; }
				elsif ($file eq "T07n0220n.xml") { $juanNum = 591; }
				elsif ($file eq "T07n0220o.xml") { $juanNum = 593; }
				else { $juanNum = 1; }
			}
			changefile();
			$num = 1;
		}    
	}     
       
	### <div2> ###
	if ($el eq "div2"){
	  # div2 的 type 屬性可以延續上一個 div2
	  if ($att{"type"} ne "") {	$div2Type = lc($att{"type"}); }
	}     
       
	### <figure>
	if ($el eq "figure") {
		my $ent = $att{"entity"};
		#my ($x, $y) = imgsize("$outDir/" . $figure{$ent});
		#$x = int($x/2);
		#$y = int($y/2);
		if ($pass==0) {
			#$$text_ref .= '<img src="../' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
			$$text_ref .= '<img src="../' . $figure{$ent} . "\">";
		}
		rdg_add_char($ent);
		if ($in_note) {
			if ($note_type eq "orig") {
				$jk_orig{$note_n} .= $ent;
				return;  
			}
			if ($note_type eq "mod") {
				$jk_mod{$note_n} .= $ent;
				return;  
			}
		}
	}

	### <foreign>
	if ($el eq "foreign") {
		if ($att{"place"} eq "foot") {
			$pass++;
		}
	}
	
	### <gloss> ###
	$pass++ if $el eq "gloss";
	      
	### <head> ###
	if ($el eq "head") { 
		$headText=""; 
		if (lc($att{"type"}) eq "added"){
			$pass++;
			$added = 1;
		} else {
			if ($debug) { watch("717 $$text_ref\n"); }
			if ($$text_ref =~ m#^(.*)(<span.*?</span>)$#) {
				$$text_ref = $1 . "<p>　　" . $2 . "<b>";
			} else {
				$$text_ref .=	"<p><b>　　" ;
			}
			if ($debug) { watch("723 $$text_ref\n"); }
			$bibl = 1;
			$bib = "";
			$nid++;
			$$text_ref .= "<A NAME=\"n$nid\"></A>";
		}   
	      
	  # 越過 <lem>, <term> <corr> 找 parent
	  my $i = @elements - 2;
  while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
    if ($parent eq "lem") {
      $i -= 2;
       $parent = $elements[$i];
     } elsif ($parent eq "term") {
       if ($elements[$i-1] eq "skgloss") { 
         $i -= 2;
         $parent = $elements[$i];
       } else { last; }
     }	elsif ($parent eq "corr") {
       $i--;
       $parent = $elements[$i];
     } 
   }   
	      
	  if ($parent eq "div1") {
       $headId = "/$vol$column.htm#$lb";
   }   
  	   
  	# 如果是般若部的div2的品
  	if ($chm eq "BoRuo" and $parent eq "div2" and $div2Type eq "pin") {
     my $id = keys(%savePin2) + 1;
     if ($id < 10) { $id = "0" . $id; }
     $headId = "/$vol$column.htm#$lb";
  	}  
	}     
	      
	if ($head == 1){
		#$bibl = 1 if ($el =~ /^bibl|title|p$/);
		$bibl = 1 if ($el =~ /^bibl$/);
	}     
       
	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}    
	}     
       

	### <item> ###
	if ($el eq "item" and $pass==0){
		if ($listType eq "ordered") {
			$$text_ref .= "<br>" . $att{"n"};
		} else {
			$$text_ref .= "<li>";
		}
	}
	
	### <juan> ###
	if ($el eq "juan"){
		$juanText="";
		$xu = 0;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
			$juanNum = $num;
			$bibl = 1;
			$bib = "";
			$nid++;
			#$text .= "<A NAME=\"n$nid\"></A>";
			$juan_name = "第" . cNum($num) . "卷";
			if ($div1Type ne "w") { changefile(); }
		} else {
		}    
		$$text_ref .= "<p class='juan'>\n";
	}     
       
	### <l> ###
	if ($el eq "l"){
		#$text .= "　";
		my $rend = $att{"rend"};
		$rend =~ s/($pattern)/$utf8out{$1}/g;
		$rend = parseRend($rend);
		if ($rend eq "" and $lgType ne "inline" and $lgRend ne "inline") { 
			$rend = "　"; 
		}
		# 如果偈頌前有 (
		if ($$text_ref =~ /(.*║.*)\($/s) {
			$$text_ref = $1 . $rend . "(";
		} else { $$text_ref .= $rend; }
	}     
       
	### <lb> ###
	if ($el eq "lb"){
		$lb = $att{"n"};
		if ($column eq "") { $column = substr($lb,0,5); }
		#if ($lb =~ /0198a12/) { $debug=1; }
		if ($debug) {
			print STDERR "lb=$lb twoLineModeLine=$twoLineModeLine\n";
			watch("744 text_ref=$$text_ref\n");
			watch("807 text=$text\n");
			watch("808 text2=$text2\n");
			#print STDERR "809 length of juan_text: " . length($juan_text) . "\n";
			#print STDERR "juan_text=$juan_text\n";
			getc;
		}
		
		if ($twoLineModeLine == 3) {
			$text_ref = \$text3;
			$$text_ref = "<br>" . $$text_ref;
		} elsif ($twoLineModeLine == 2) {
			$text_ref = \$text2;
			$$text_ref = "<br>" . $$text_ref;
		} elsif ($twoLineModeLine == 1) {
			$text_ref = \$text;
			$$text_ref = "<br>" . $$text_ref;
		} else {
			$text_ref = \$text;
		}
		
		if ($fileopen == 1) {
			#the whole line has been cached to $text, print it now!
			printOneLine();
			$$text_ref = '';
		}

		if ($twoLineModeLine==1) {
			$twoLineModeLine=2;
		} elsif ($twoLineMode and $twoLineModeLine==2){
			$twoLineModeLine=1;
		} else {
			$twoLineModeLine=0;
		}
		     
		if ($twoLineModeLine==3){
			$text3 = "$br$indent" . $text3;
		} elsif ($twoLineModeLine==2){
			$text2 = "$br$indent" . $text2;
		} elsif ($pass==0) {
			$text .= "$br$indent";
		}

		if ($twoLineMode and $count_t > 1) {
			if ($count_t > 2) {
				$text_ref = \$text3;
			} else {
				$text_ref = \$text2;
			}
		} else {
			$text_ref = \$text;
		}

		if ($firstLineOfPage) { 
			$firstLineOfPage = 0; 
		} else { 
			#$text = "</a>" . $text; 
		}

	  if ($firstLineOfSutra) {
	    my $num = $sutraNum;
	    $num =~ s/^0//;
	    $num =~ s/^0//;
	    $num =~ s/^0//;
	    #print FTOC "<a href=\"$chm.chm::/$vol$column.htm\">No. $num $sutraName</A></TH>\n";
      #print FTOC "</THEAD>\n<TR><TD>\n";
      $firstLineOfSutra = 0;
   }
	}     
       
	### <lem> ###
	if ($el eq "lem" ){
		my $n=@apps;  # 取得上層已累積幾層 app
		my $app_n=$apps[$n-1];  # 取得上層最近的校勘編號
		$current_wit{$app_n} = "大 CBETA"; # 記錄本組 app 進行到哪一個版本
		$app{$app_n}{"大"}=""; # 大正藏版內容給初值
		$app{$app_n}{"CBETA"}=""; # CBETA 版內容給初值
	}
	
	### <lg> ###
	if ($el eq "lg" ){
		$lgType = $att{"type"};
		$lgRend = $att{"rend"};
		$$text_ref .= "<p class='lg'>";
		if ($lgType ne "inline" and $lgRend ne "inline") {
			$br = "<br>";
		}
	}     
	      
	### <list> ###
	if ($el eq "list" and $pass==0) {
		if ($att{"id"} ne '') {
			$$text_ref .= '<a name="' . $att{"id"} . '"></a>';
		}
		$listType = $att{"type"};
		push @listType, $listType;
		if ($att{"type"} eq "ordered") {
		} else {
			$$text_ref .= "<ul>";
		}
	}
	
	### <milestone>
	if ($el eq "milestone") {
		$rend = $att{"rend"};
		$rend =~ s/($pattern)/$utf8out{$1}/g;
		$$text_ref .= $rend;
		if ($att{"unit"} eq "juan") {
			$juan_name = "第" . cNum($att{"n"}) . "卷";
			$juanNum = sprintf("%3.3d",$att{"n"});
			$juanNum = "001" if ($att{"n"} eq "");
			&changefile;
		}
	}

	### <mulu> ###
	if ($el eq "mulu") {
		if ($att{"rend"} eq "卷") {
			if ($att{"label"} ne "") {
				$juan_name = $att{"label"};
			}
		}
	}

	### <note> ###
	if ($el eq "note") {
		$in_note++;
		push @note_type, $note_type; # 把上一層的 note_type 存起來, 因為 <note> 可能包 <note>
		$note_type = $att{"type"};
		$note_n = $att{"n"};
		$close="";

		push @saveFont, $currentFont;
		if ($att{"lang"} eq "chi") {
			if ($currentFont eq "siddam") {
				$$text_ref .= "<font face='新細明體'>";
				$currentFont = "新細明體";
				$close .= "</font>";
			}
		}

		if ($att{"type"} eq "orig") {
			$jk_orig{$note_n} = '';
			$pass++;
		} elsif ($att{"type"} eq "mod") {
			$jk_mod{$note_n} = '';
			$pass++;
		} else {
			# CBETA 加的 note 不顯示
			if ($att{"resp"} =~ /^CBETA/ or $att{"place"} =~ /foot/) {
				$pass++;
			}
			if (lc($att{"type"}) eq "inline" or lc($att{"place"}) =~ /^inline|interlinear$/){
				if ($pass==0) {
					if ($in_corr) {
						$corr .= "(";
					} else {
						$$text_ref .= "(";
					}
					$close = ")$close";
				}
				rdg_add_char("(");
			}
		}
		push @close, $close;
		
	}
       
	### <p> ###
	if ($el eq "p"){
		$ptype = lc($att{"type"});
		if ($ptype eq "w" or $ptype eq "winline") {
			$$text_ref .= "<blockquote class='FuWen'>";
			$indent = "";
		} else {
			my $s=substr($lb,0,4);
			$s =~ s/^0*//;
			if ($s ne $old_page) {
				$old_page = $s;
				$s = "p. $s, " . substr($lb,4);
				$$text_ref .= "<p align='right'>$s";
			}
			$$text_ref .= "<p>";
		}   
		if ($ptype eq "ly" && $head==1) { $flagSource=1; }
		$close="";
		if ($att{"lang"} eq "san-sd") {
			$$text_ref .= "<font face='siddam'>";
			$close="</font>";
		}
		push @close, $close;
	}     
	      
	### <pb> ###
	if ($el eq "pb") {
		$firstLineOfPage = 1;
		$id = $att{"id"};
		if ($debug) {
			print STDERR "974 pb $id\n";
		}
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
		     
		if ($twoLineModeLine == 3) {
			$text_ref = \$text3;
			$$text_ref = "<br>" . $$text_ref;
		} elsif ($twoLineModeLine == 2) {
			$text_ref = \$text2;
			$$text_ref = "<br>" . $$text_ref;
		}
		printOneLine();
	 
		#changefile($att{"n"});
       
		$preColumn = $column;
		$column = $att{"n"};

		#print "<font face='Arial'><h2>$mtit</font> ";
		$juanNum =~ s/^0{1,2}(\d{1,2})/$1/;
		#if ($juanNum ne "") { print "<font face='Arial'>(卷$juanNum)</font>" };
		if ($div1head ne "") { 
			if ($div1head =~ /^#\d\d#(.*)/) { $div1head = $1; }
			if ($div1head =~ /(.*分)初$/) { $div1head = $1; }

			# "一" = \xa4\x40
			if ($div1head =~ /(.*誦)第\xa4\x40$/) { $div1head = $1; }

			if ($div1head =~ /^（.+）(第.+分)$/) { $div1head = $1; }

			# "（一）第一分" -> "第一分"
			# \xa1\x5d = "（" ,  \xa1\x5e = "）"
			if ($div1head =~ /^\xa1\x5d.+\xa1\x5e(第.+分)$/) { $div1head = $1; }
			#print " $div1head"; 
		}
		#print " <font face='Arial'>$vol, p$column</h2></font><hr>\n";
	}     
	      
       
	### <rdg> ###
	if ($el eq "rdg" ){
		$pass++;
		my $app_n= pop @apps; # 取得上層最近 app 的校勘編號
		push @apps, $app_n;
		
		my $v = $att{"wit"};
		$v =~ s/【三】/【宋】【元】【明】/g;
		$v =~ s/】【/ /g;
		$v =~ s/^【//;
		$v =~ s/】$//;
		@b = split / /, $v;
		$current_wit{$app_n}="";
		foreach $v (@b) {
			if ($current_wit{$app_n} ne "") {
				$current_wit{$app_n} .= " ";
			}
			if ($v eq "？") {
				$v="某本";
				if (exists $app{$app_n}{$v}) {
					$v = "某本Ｂ";
				}
			}
			$current_wit{$app_n} .= $v;
			$app{$app_n}{$v} = "";
		}
	}
	
	### <ref> ###
	if ($el eq "ref" and not $pass) {
		$$text_ref .= '<a href="#' . $att{"target"} . '">';
	}
	
	### <row> ###
	if ($el eq "row" and not $pass) {
		$$text_ref .= "<tr>";
	}
       
	### <sg> ###
	if ($el eq "sg") {
		my $close='';
		if ($pass==0){
			$$text_ref .= "(";
			$close = ")";
		}
		push @close, $close;
	}     

	### <table> ###
	if ($el eq "table" and not $pass) {
		$$text_ref .= '<table border="1" cellspacing="0" cellpadding="5">';
	}
	
	### <teiHeader> ###
	$head = 1 if $el eq "teiHeader";  #We are in the header now!

	### <t> ###
	if ($el eq "t"){
		$count_t ++;
		if ($att{"place"} eq "foot") {
			$pass++;
		}
		if ($twoLineMode==1 and $count_t > 1) {
			if ($count_t > 2) {
				$text3_dirty = 1;
				$text_ref = \$text3;
			} else {
				$text2_dirty = 1;
				$text_ref = \$text2;
			}
		} else {
			$text_ref = \$text;
		}
		$close="";
		push @saveFont, $currentFont;
		if ($debug) { watch("1134 [$$text_ref]\n"); }
		if ($pass==0) {
			if (defined($att{"rend"})) { 
				$$text_ref .= $att{"rend"};
			} elsif (not $tt_inline and $$text_ref !~ /(<p>|<br>)$/ and $$text_ref ne '') {
				$$text_ref .= "　";
			}
			if ($att{"lang"} eq "san-sd") {
				$$text_ref .= "<font face='siddam'>";
				$currentFont = "siddam";
				$close="</font>";
			}
		}
		if ($debug) { watch("1147 [$$text_ref]\n"); }
		push @close, $close;
	}
	
	### <tt> ###
	if ($el eq "tt") {
		if ($att{"rend"} eq "inline" or $att{"type"} eq "inline" or $att{"type"} eq "app") {
			$tt_inline = 1;
		} else {
			$tt_inline=0;
		}
		if (not $tt_inline and $att{"rend"} ne "normal") {
			$twoLineMode = 1;
			$twoLineModeLine = 1;
			$count_t = 0;
		} else {
			$twoLineMode = 0;
			$twoLineModeLine = 0;
		}
		if ($att{"rend"} eq "normal") {
			$br="<br>";
			if ($$text_ref !~ /<p>$/) {
				$$text_ref .= "<br>";
			}
		}
	}
} # end start_handler
        
sub rep{
	local($x) = $_[0];
	local $got=0;

	#print STDERR "[$x]";
	if (defined($romanNum{$x})) {
		return $romanNum{$x};
	}
	
	if ($x =~ /^#x[0-9A-Z]{4}$/) {
		return "&$x;";
	}
	
	if ($no_nor) {
		if (defined($no_nor{$x})) { 
			$str = $no_nor{$x}; 
			$got = 1;
		}
	} else {
		if (defined($Entities{$x})) { 
			$str = $Entities{$x}; 
			$got=1;
		}
	}

	if ($str =~ /^\[(.*)\]$/) {
		my $exp = $1;
		#if (defined($dia{$exp})) {
		if (defined($lucida{$exp})) {
			#$str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
			$str = "<font face=\"Lucida Sans Unicode\">" . $lucida{$exp} . "</font>";
			if ($debug) { print STDERR "689 $str\n"; }
			return $str;
		}
	}   
	
	if ($got) {
		return $str;
	} else {
		die "667 Unknkown entity [$x]!! no_nor=$no_nor lb=$lb text=[$$text_ref]\n";
	}

	return $x;
}       
        

sub rep3{
	local($x) = $_[0];
	local $got=0;

	if (defined($romanNum{$x})) {
		return $romanNum{$x};
	}

	if (defined($dia{$x})) {
		$str = $dia{$x};
		return $str;
	}

	if ($no_nor) {
		if (defined($no_nor{$x})) { 
			$str = $no_nor{$x}; 
			$got = 1;
		}
	} else {
		if (defined($Entities{$x})) { 
			$str = $Entities{$x}; 
			$got=1;
		}
	}

	if ($str =~ /^\[(.*)\]$/) {
		my $exp = $1;
		if (defined($dia{$exp})) {
			$str = $dia{$exp};
			if ($debug) { print STDERR "689 $str\n"; }
			return $str;
		}
	}   
	
	if ($got) {
		$str =~ s#<a[^>]*?>(.*?)</a>#$1#g;
		return $str;
	} else {
		die "1234 Unknkown entity $x!! no_nor=$no_nor\n";
	}

	return $x;
}       

sub resolveEntInAtt {
	my $s=shift;
	$s =~ s/(CB\d{5})/&rep3($1)/eg;
	return $s;
}

sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
	
	## </app> ###
	if ($el eq "app") {
		my $app_n = pop(@apps);
		my $s=process_jk($app_n);
		if ($debug) {
			watch("1080 text_ref=" . $$text_ref . "\n");
		}
		if ($$text_ref =~ m#^(.*?)<span id=n$app_n[^>]*?>.*?</span>(.*)$#s) {
			$$text_ref = $1 . $s . $2 . "</span>";
		#} elsif ($juan_text =~ /^(.*?)<app n="$app_n">(.*)$/) {
		} else {
			$juan_text .= $$text_ref;
			$$text_ref = "";
			if ($juan_text =~ m#^(.*?)<span id=n$app_n[^>]*?>.*?</span>(.*)$#s) {
				$juan_text = $1 . $s . $2 . "</span>";
			}
		}
	}

	## </cell> ###
	if ($el eq "cell" and not $pass) {
		$$text_ref .= "</td>";
	}
       
	# </edition>
	if ($el eq "edition") {
	  $version =~ /\b(\d+\.\d+)\b/;
	  $version = $1;
	}     
       
	### </foreign>
	if ($el eq "foreign") {
		if ($att->{"place"} eq "foot") {
			$pass--;
		}
	}

	$head = 0 if $el eq "teiheader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";
	      
	### </juan> ###
	if ($el eq "juan" ){
		$bibl = 0;
		#$bib =~ s/\[[0-9（[0-9珠\]//g;
		#$bib =~ s/\[\d{2,3}\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$bib = "";
		$$text_ref .= "</p>\n";
		     
		if (lc($att->{"fun"}) eq "open" and $div1Type ne "w") {
     my $id = %saveJuan + 1;
     $id = "/$vol$column.htm#$lb";
     my $num = $juanNum;
     $num =~ s/^0//;
     $num =~ s/^0//;
     $juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
     $juanText =~ s/\[＊\]//g;
     #$saveJuan{$id}=$num . " " . $juanText;
     $saveJuan{$id}= "第" . cNum($juanNum);
     $juanURL = $id;
		} elsif (lc($att->{"fun"}) eq "close" and $div1Type ne "w") {
     $juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
     $juanText =~ s/\[＊\]//g;
     my $i = cNum($juanNum);
		  #print FTOC "<TD><A HREF=\"$chm.chm::$juanURL\">卷第$i</A>\n";
		  #print FTOC "<TR><TD>\n";
		}    
	}     
       
	### </head> ###
	if ($el eq "head" ) {
	  if ($added == 1) {
		  $pass--;
		  $added = 0;
	  }   
       
   my $i = @elements - 1;
  while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
    if ($parent eq "lem") {
      $i -= 2;
       $parent = $elements[$i];
     } elsif ($parent eq "term") {
       if ($elements[$i-1] eq "skgloss") { 
         $i -= 2;
         $parent = $elements[$i];
       } else { last; }
     }	elsif ($parent eq "corr") {
       $i--;
       $parent = $elements[$i];
     } 
   }   
       
   # </div1>
   if ($parent eq "div1") {
     $headText =~ s/\[\d\d\]//g;  # 去掉校勘符號
     $headText =~ s/\[＊\]//g;
     $div1head = $headText;
     if ($debug) { print STDERR "div1Type=[$div1Type]\n"; }
     if ($div1Type eq "xu") {
       #$text .= "</a>";
       $saveXu{$headId}=$headText;
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$headText</A><BR>\n";
     } elsif ($div1Type eq "pin") {
       #$text .= "</a>";
       $headText =~ s/^(.*品)(第.*)$/$1/;
       $savePin{$headId}=$headText;
       my $i = keys(%savePin);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
       if ($debug) {
         print STDERR "headId=[$headId]\n";
         print STDERR "headText=[$headText]\n";
       }
     } elsif ($div1Type eq "hui") {
       #$text .= "</a>";
       $headText =~ s/^(.*會)(第.*)$/$1/;
       $saveHui{$headId}=$headText;
       my $i = keys(%saveHui);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
     } elsif ($div1Type eq "fen") {
       #$text .= "</a>";
       $headText =~ s/^(.*分)(第.*)$/$1/;
       $saveFen{$headId}=$headText;
       my $i = keys(%saveFen);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
     } elsif ($div1Type eq "other" or $div1Type eq "jing") {
       #$text .= "</a>";
       $saveOther{$headId}=$headText;
       
       my $aa = quotemeta("（");
       my $bb = quotemeta("）");
       if ($headText =~ /^$aa.*$bb$/) {
         #print FTOC "<A HREF=\"$chm.chm::$headId\">$headText</A><BR>\n";
       } else {
         my $i = keys(%saveOther);
         #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
       }
       
       #print STDERR "[$headId,$headText]\n";
     } 
   }   
       
   # </div2>
   if ($parent eq "div2" and $chm eq "BoRuo" and $div2Type eq "pin") {
       $$text_ref .= "</a>";
       #$headText =~ s/^(.*品)(第.*)$/$1/;
       $savePin2{$headId}=$headText;
       my $i = keys(%savePin2);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
   }   
       
   $$text_ref .= "</b>";
		$bibl = 0;
		$bib =~ s/\n//g;
		#$bib =~ s/\[[0-9（[0-9珠\]//g;
		$bib =~ s/\[\d{2,3}\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$bib = "";
		$indent = "" ;
	}     
	      
	### </lg> ###
	if ($el eq "lg" ){
		$$text_ref .= "</p>";
		$br = "";
	}     
       
	### </byline> ###
	if ($el eq "byline"){
		#$$text_ref .= "</span><br>" ;
		$$text_ref .= "</p>" ;
	}
       
  ## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { 
			if ($in_note and $note_type eq "mod") {
				$jk_mod{$note_n} .= "}}";
			} else {
				#$$text_ref .= "<span id='corr$lb' class='corr' vt='$sic' vc='$corr' ver='ct'>";
				#$$text_ref .= "<span id='corr$lb' class='corr' vda='$sic' vcb='$corr' ver='cb da'>";
				$$text_ref .= "<span id='corr$lb' class='corr' v010='$sic' v000='$corr' ver='000 010'>";
				$$text_ref .= "$corr</span>"; 
			}
		}
		$in_corr=0;
	}     
       
	$indent = "" if ($el eq "byline");
	$indent = "" if ($el eq "p");

	## </l>
	#$text .="　" if $el eq "l";
	if ($el eq "l") {
		if ($lgType ne "inline" and $lgRend ne "inline") {
			$$text_ref .= "　";
		}
	}
       
	## </list> ###
	if ($el eq "list") {
		if ($att->{"type"} eq "ordered") {
		} else {
			$$text_ref .= "</ul>";
		}
		$listType = pop @listType;
	}

	## </note> ###
	if ($el eq "note"){
		$close = pop @close;
		if ($close ne "") {
			if ($in_corr) {
				$corr .= $close;
			} else {
				if ($$text_ref =~ /(.*)<\/font>$/) {
					$$text_ref = $1 . $close . "</font>";
				} else { 
					$$text_ref .= $close 
				}
			}
		}
		if ($att->{"place"} =~ /^inline|interlinear$/) {		
			rdg_add_char(")");
		}
		$close = "";
		if ($att->{"type"} eq "orig") {
			$$text_ref .= "<span id=n" . $note_n;
			$$text_ref .= ' class=note orig="' . $jk_orig{$note_n} . '"';
			#$$text_ref .= ' title="' . $jk_orig{$note_n} . '">';
			$$text_ref .= '>';
			$$text_ref .= "[<a id=\"a$note_n\" href=\"\" ";
			$$text_ref .= "onfocus='abc(\"n$note_n\",sr)' ";
			$$text_ref .= "onblur='abc(\"n$note_n\",xr)' ";
			$$text_ref .= "onClick=\"return aOnClick('" . $note_n . "')\">";
			my $n=substr($note_n,4);
			$n=int($n);
			$$text_ref .= $n . "</a>]";
			$$text_ref .= '</span>';
			$pass--;
		} elsif ($att->{"type"} eq "mod") {
			if ($debug) {
				watch("1323 " . $jk_mod{$note_n} . "\n");
			}
			$jk_mod{$note_n} =~ s/"/&quot;/g;
			if ($$text_ref =~ m#^(.*?<span id=n$note_n class=note[^>]*?)(>.*?</span>.*$)#s) {
				$$text_ref = $1 . ' mod="' . $jk_mod{$note_n} . '"' . $2;
			}
			$pass--;
		} elsif ($att->{"resp"} =~ /^CBETA/ or $att->{"place"} =~ /foot/) {
			$pass--;
		}
		$in_note--;
		$note_type = pop @note_type;
		$currentFont = pop @saveFont;
	}     
	      
	### </bibl> ###
	if ($el eq "bibl"){
		$bibl = 0;
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			$prevof = "";
			$sutraNum = $2;
			$chm = getchm($sutraNum);
			if ($3 eq ""){
				$c = "_";
			} else {
				$c = $3;
			  $sutraNum .= $c;
			}  
      
			# 將經號補滿四位數
			if ($sutraNum =~ /\d$/) {
				$sutraNum = "0" x (4-length($sutraNum)) . $sutraNum;
			} else {
				$sutraNum = "0" x (5-length($sutraNum)) . $sutraNum;
			}
			#print the rest of the line of the old file!
			printOneLine();
			$$text_ref = "";
			$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("t%2.2d", $1);
			#mkdir($cfg{"OUTDIR"} . "\\htmlhelp\\$od", MODE);
			#		$c = "n" if ($c eq "_");
			#		$oof = $of;
			#base name for file
       
			$xu = 0;
			#$fileopen = 0;
			$num = 0;
			$bof = "$outDir/$vol/$sutraNum";
			$bof =~ tr/A-Z/a-z/;
			if (length($sutraNum)<5) { $bof .= "_"; }
			print STDERR "764 bof=$bof\n";
			$fhead = $outDir . sprintf("/$od/%4.4dh", $2, $3);
			$fhead =~ tr/A-Z/a-z/;
			   
			$mtit = $title;
			$mtit =~ s/Taisho Tripitaka, Electronic version, //;
			$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
			$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
			$sutraName = $mtit;
			$sutraName =~ s/No\. \d*\w* //;
       
			$firstLineOfSutra = 1;
			$firstLineOfPage = 1;
     
			# added by Ray 1999/12/15 10:50AM
			if ($vol eq "T06") { $juanNum = 201; }
			elsif ($sutraNum eq "0220c") { $juanNum = 401; }
			elsif ($sutraNum eq "0220d") { $juanNum = 538; }
			elsif ($sutraNum eq "0220e") { $juanNum = 566; }
			elsif ($sutraNum eq "0220f") { $juanNum = 574; }
			elsif ($sutraNum eq "0220g") { $juanNum = 576; }
			elsif ($sutraNum eq "0220h") { $juanNum = 577; }
			elsif ($sutraNum eq "0220i") { $juanNum = 578; }
			elsif ($sutraNum eq "0220j") { $juanNum = 579; }
			elsif ($sutraNum eq "0220k") { $juanNum = 584; }
			elsif ($sutraNum eq "0220l") { $juanNum = 589; }
			elsif ($sutraNum eq "0220m") { $juanNum = 590; }
			elsif ($sutraNum eq "0220n") { $juanNum = 591; }
			elsif ($sutraNum eq "0220o") { $juanNum = 593; }
			else { $juanNum = 1; }
		}    
		$bib =~ s/^\t+//;
		$ebib = $bib;
		#&changeSutra;
		#openOF();
		#changefile();
	}
       
	### </div> ###
	if ($el =~ /div/i){
		$xu = 0;
	}     
       
	## </item> ###
	if ($el eq "item") {
		$$text_ref .= "</li>";
	}
	
	## </p> ###
	if ($el eq "p"){
		if ($head == 1) {
			$bib =~ s/^\t+//;
			#$ly{$lang} = $bib;
			$source =~ s/^\t+//;
			$ly{$lang} = $source;
			$flagSource = 0;
			$source="";
		}    
		if (lc($att->{"type"}) eq "w") { $$text_ref .= "</blockquote>"; }
		$close = pop @close;
		$$text_ref .= $close;
	}
       
	if ($el eq "teiHeader"){
#	&head;
	}     
	$lang = "" if ($el eq "p");
	
	### </ref> ###
	if ($el eq "ref" and not $pass) {
		$$text_ref .= "</a>";
	}
	
	### </row> ###
	if ($el eq "row" and not $pass) {
		$$text_ref .= "</tr>";
	}
       
	## </sg> ###
	if ($el eq "sg"){
		$close = pop @close;
		if ($close ne "") {
			if ($$text_ref =~ /(.*)<\/font>$/) {
				$$text_ref = $1 . $close . "</font>";
			} else { 
				$$text_ref .= $close 
			}
		}
	}

	### </t> ###
	if ($el eq "t") {
		if ($att->{"place"} eq "foot") {
			$pass--;
		}
		$close = pop @close;
		$currentFont = pop @saveFont;
		$$text_ref .= $close;
	}

	### </table> ###
	if ($el eq "table" and not $pass) {
		$$text_ref .= "</table>";
	}

  ## </tei.2> ###
	if ($el eq "tei.2"){
		#$$text_ref =~ s/\[[0-9（[0-9珠\]//g;
		$$text_ref =~ s/\[\d{2,3}\]//g;
		$$text_ref =~ s/#[0-9][0-9]#//g;
       
		$$text_ref =~ s/\xa1\x40$//;
		$$text_ref =~ s/\xa1\x40\)$/)/;
		     
		printOneLine();
		$$text_ref = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>▲</a>" if ($prevof ne "");
		#print "</html>\n";
		closeOF();
		$vl = "";
		$num = 0;
	}     
	      
	# </tt>
	if ($el eq "tt"){
		$twoLineMode = 0;
		$text_ref = \$text;
		$br='';
	}
	      
	$bib = "";
	$no_nor = pop @no_nor;
#	print STDERR "$pass\n";
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	my $att = '';
	# <note type="sk"> 的內容不顯示
	if ($parent eq "note") {
		$att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		#if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}     

	#$char =~ s/($pattern)/$utf8out{$1}/g;
	$char =~ s/\n//g;

	if ($debug) {
		watch("1704 $char in_corr=$in_corr CorrCert=$CorrCert\n");
	}
	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($in_corr) {
	 	if ($CorrCert ne "" and $CorrCert ne "100") { 
			return;
		}
		$corr .= $char;
	}  		     
	if ($debug) {
		watch("1715 $corr\n");
	}
	if ($in_note) {
		if ($note_type eq "orig") {
			$jk_orig{$note_n} .= $char;
			return;  
		}
		if ($note_type eq "mod") {
			$jk_mod{$note_n} .= $char;
			return;  
		}
	}
	      
	my $i = @elements - 1;
	while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
		if ($parent eq "lem") {
			$i -= 2;
			$parent = $elements[$i];
		} elsif ($parent eq "term") {
			if ($elements[$i-1] eq "skgloss") {
				$i -= 2;
				$parent = $elements[$i];
			}  else { last; }
		}	elsif ($parent eq "corr") {
			$i--;
			$parent = $elements[$i];
		}   
	}     
	      
	if ($parent eq "head") { $headText .= $char; }
	if ($parent eq "title") { $title .= $char; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $char; }
	if ($parent eq "edition") { $version .= $char; }
        
	$bib .= $char if ($bibl == 1);
	$source .= $char if ($flagSource);

	rdg_add_char($char);
	
	if ($pass == 0 and $el ne "pb" and not $in_corr) {
		if ($$text_ref =~ /(.*)<\/font>$/) {
			my $s1 = $1;
			if ($char =~ /^([\w\s]+)(.*)$/) { $$text_ref = $s1 . $1 . "</font>" . $2; }
			else { $$text_ref .= $char; }
		} else { $$text_ref .= $char; }
	}
#	print $char if ($pass == 0 && $el ne "pb");
}       
        
        
sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	if ($ent =~ /Fig/) {
		$figure{$ent} = $next;
	} else {
		&openent($next);
	}
#	print STDERR "$ent\t$entval\t$next\n";
	return 1;
}       
        
        
        
        
        
#-----------------------------------------------------------------------
sub shead{
	print $short;
}       
        
      
        
#-----------------------------------------------------------------------
sub changefile{
	#my $col = shift;
	$$text_ref =~ s/\n//;
	$$text_ref =~ s/\x0d$//;

	$of = sprintf("$bof%3.3d.htm", $juanNum);
	if ($of eq $oldof) { return; }
	
	$mof = $of;
	$mof =~ s/.*\\//;
	#print STDERR "1206 of=$of mof=$mof oldof=$oldof\n";
	#getc;
	if ($oldof ne $mof){
		if ($newpath ne $oldpath) {
			mkdir($newpath, MODE);
			$oldpath = $newpath;
		}
		#$xtoc = "${bof}toc.htm";
		$xtoc = "${bof}${vol}toc.hhc";
		$xtoc =~ s/.*\\//;
		$xtoc =~ tr/A-Z/a-z/;
		$ytoc = $bof;
		$ytoc =~ s/.*\\//;
		$ytoc =~ s/_//;
				
		if ($fileopen) {
			closeOF();
		}
		
		# 記錄各卷卷名、檔名
		$of =~ m#/([^/]*?)$#;
		$f=$1;
		if ($juan_name eq "") {
			$juan_name="第一卷";
		}
		push @juan_names, $juan_name;
		$juan_links{$juan_name}=$f;
		if ($first_juan) {
			print_index($f);
			$first_juan=0;
		}
		
		$fh = sprintf("$fhead%3.3d.htm", $num);
		open (OF, ">$of") or die;
		$fileopen = 1;
		$old_page="#";
		print STDERR "--> $of\n";
		select(OF);
		if ($num == 0 || ($xu == 0 && $num == 1)){
			#&head;
		} else {
			#&head;
		}
		#open(FHED, ">$fh");
		#print FHED $fhed;
       
		$html_head =<< "XXX";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<link rel="stylesheet" href="../cbeta.css">
<script LANGUAGE="JAVASCRIPT" SRC="../script/search.js"></script>
<script LANGUAGE='JAVASCRIPT' SRC='../script/shownote.js'></script>
<script LANGUAGE='JAVASCRIPT' SRC='../script/showfoot.js'></script>
<TITLE>CBETA $vol $col</TITLE>
</head>
<BODY>
<div id=t1>目前顯示的是 <span class=explain id=vers>中華電子佛典協會．大正新脩大藏經電子版 2003</span><BR>
說明：除CBETA版外，其餘版本(如宋、元、明)係由大正藏校勘中所列資料呈現。
</div>
XXX
		my_print($html_head);
		printOneLine();
		$$text_ref = "";
		$prevof = $oldof;
		$oldof = $mof;
		$oldbof = $bof;
	}
}

sub print_index {
	$f=shift;
	open FIDX, ">$outDir/$dir/index.htm" or die;
	select FIDX;
	print <<"XXX";
<HTML>
<HEAD>
<frameset rows="34,2*,*">
	<FRAME src="tool.htm" name="tool">
	<FRAMESET COLS="160,*">
		<FRAME SRC="toc.htm" NAME="toc">
		<FRAME SRC="$f" NAME="text">
	</FRAMESET>
	<FRAMESET COLS="*,*">
		<FRAME SRC="jk.htm" NAME="jk">
		<FRAME SRC="foot.htm" NAME="foot">
	</FRAMESET>
</frameset>
</HTML>
XXX
	close FIDX;
}
#-----------------------------------------------------------------------
sub getof {
  my $num = $sutraNum;
  my $str = "T09,T12,T26,T30";
  if ($str !~ /$vol/) { return $vol . ".htm"; }
  if ($num < 278) { return "T09-1.htm"; }
  if ($num < 279) { return "T09-2.htm"; }
  if ($num < 374) { return "T12-1.htm"; }
  if ($num < 397) { return "T12-2.htm"; }
  if ($num < 1536) { return "T26-1.htm"; }
  if ($num < 1545) { return "T26-2.htm"; }
  if ($num < 1579) { return "T30-1.htm"; }
  return "T30-2.htm";
}       
        
#-----------------------------------------------------------------------
sub getchm {
  my $num = shift;
  if ($num < 152) { return "AHan"; }
  if ($num < 220) { return "BenYuan"; }
  if ($num < 262) { return "BoRuo"; }
  if ($num < 278) { return "FaHua"; }
  if ($num < 310) { return "HuaYan"; }
  if ($num < 374) { return "BaoJi"; }
  if ($num < 397) { return "NiePan"; }
  if ($num < 425) { return "DaJi"; }
  if ($num < 848) { return "JingJi"; }
  if ($num < 1421) { return "MiJiao"; }
  if ($num < 1505) { return "Vinaya"; }
  if ($num < 1536) { return "JingLun"; }
  if ($num < 1564) { return "PiTan"; }
  if ($num < 1579) { return "ZhonGuan"; }
  if ($num < 1628) { return "YogaCara"; }
  if ($num < 1693) { return "LunJi"; }
}       
        
        
#-----------------------------------------------------------------------
# Created by Ray 1999/11/30 08:38AM
#-----------------------------------------------------------------------
sub printOneLine {
	my $big5 = '[\x00-\x7f]|[\x80-\xff][\x00-\xff]';
	if ($$text_ref eq "") { return; }
	$$text_ref =~ s/\xa1\x40$//;
	$$text_ref =~ s/\xa1\x40\)$/)/;
	#$$text_ref =~ s/\[[0-9（[0-9珠\]//g;
	#$$text_ref =~ s/\[\d{2,3}\]//g;
	$$text_ref =~ s/#[0-9][0-9]#//g;
	#if ($debug) { watch("1296 [$$text_ref]\n"); }
	while ($$text_ref =~ /^($big5)*◇((◇)|( )|(　))*◇/) {
		$$text_ref =~ s/^(($big5)*?)◇((◇)|( )|(　))*◇/$1【◇】/;
	}
	if ($debug) { watch("1300 [$$text_ref]\n"); getc; }
	#print "$$text_ref";
	$juan_text .= $$text_ref;
	#if (@lines > 1) { shift @lines; }
	#push @lines, $text;
	$$text_ref = "";
}

sub myDecode {
	my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}


sub getlast {
  my $lastvol = substr($vol,1,2) - 1;
  if ($lastvol < 10) { $lastvol = '0' . $lastvol; }
  $lastvol = 'T' . $lastvol;
  my $page = $lastpage{$lastvol};
  return "../../$lastvol/" . substr($page,0,2) . "/" . $page;
}

sub closeOF {
	if ($debug) {
		print STDERR "begin closeOF()\n";
	}
	select OF;
	printOneLine();
	my_print($juan_text);
	$juan_text='';
	#my_print("\n<div class=footnote id=footnote></div>\n</body></html>\n");
	my_print("\n<script>window.setTimeout(\"showFoot()\",300);</script>\n</body></html>\n");
	close (OF);
	if ($debug) {
		print STDERR "end closeOF()\n";
	}
}

sub my_print {
	my $s=shift;
	$s =~ s/($pattern)/&rep2($1)/eg;
	$s =~ s#&SD\-(\w{4});#pack("H4",$1)#ge;
	#$s=Encode::encode("big5", $s);
	$s =~ s/([a-zA-Z \(\)\-',]+)(<font face="Lucida Sans Unicode">)/$2$1/g;
	while ($s =~ m#^(.*<font face="Lucida Sans Unicode">[^<]+?)</font><font face="Lucida Sans Unicode">(.*)$#s) {
		$s=$1 . $2;
	}
	$s =~ s#(<font face="Lucida Sans Unicode">[^<]+)(</font>)([a-zA-Z \(\)\[\]\-:',]+)#$1$3$2#g;
	print $s;
}

sub rep2 {
	my $s=shift;
	if ($s =~ m#^%big5%(.*?)%/big5%$#) {
		return $1;
	}
	return $utf8out{$s};
}

sub parseRend {
	my $s = shift;
	if ($s =~ /margin-left:(\d+)/) {
		$s = "　" x $1;
	}
	return $s;
}
        
sub process_jk {
	my $app_n=shift;
	#my $ret = "<span class=note onmouseover=ftshowx(this) id=n$app_n";
	my $ret = "<span class=note id=n$app_n";
	my $t, $v, $ver='';
	my $rdg;
	foreach $v (keys %{ $app{$app_n} }) {
		#watch($v . "=>" . $version{$v});
		$ver .= $version{$v} . " ";
		$rdg = $app{$app_n}{$v};
		$rdg =~ s/&SD\-(\w{4});/"&SD" . pack("H4",$1) . ";"/ge;
		$rdg =~ s#<a[^>]*?>(.*?)</a>#$1#g;
		$ret .= " v" . $version{$v} . '="' . $rdg . '"';
		$vers{$v} = $version{$v};
	}
	$ver =~ s/^(.*)010 (.*)$/010 $1$2/;
	$ver =~ s/^(.*)000 (.*)$/000 $1$2/;
	$ret .= " ver=\"$ver\"";
	
	if (not exists $jk_mod{$app_n}) {
		$jk_mod{$app_n} = $jk_orig{$app_n};
	}
	$ret .= ' orig="' . $jk_orig{$app_n} . '"';
	$jk_mod{$app_n}=~s/】【unknown】【/】　【/g;
	$jk_mod{$app_n}=~s/【unknown】//g;
	$ret .= ' mod="' . $jk_mod{$app_n} . '"';
	
	$jk_mod{$app_n} =~ s/\{\{//g;
	$jk_mod{$app_n} =~ s/\}\}//g;
	$jk_mod{$app_n} =~ s/FigT\d{8}/【圖】/g;
	#$ret .= " title=\"" . $jk_mod{$app_n} . '"';
	
	if (int($word_count{$app_n}) > 30) {
		$ret .= " table='0'";
	}
	
	$ret .= ">";
	
	$ret .= "[<a id=\"a$app_n\" href=\"\" ";
	$ret .= "onfocus='abc(\"n$app_n\",sr)' onblur='abc(\"n$app_n\",xr)' ";
	$ret .= "onClick=\"return aOnClick('" . $app_n . "')\">";
	my $n=substr($app_n,4);
	$n=int($n);
	$ret .= $n . "</a>]";
	
	delete $jk_mod{$app_n};
	delete $jk_orig{$app_n};
	
	return $ret;
}

sub watch {
	$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
	my $s = shift;
	my @a=();
	push(@a, $s =~ /$utf8/gs);
	my $c;
	$s = '';
	foreach $c (@a) { 
		if ($c ne "\n") {
			if (exists $utf8out{$c}) { $c =  $utf8out{$c}; }
			else { 
				$len = length($c);
				print STDERR "Error:859 lb=$lb {$c} not in conversion table\n"; 
				print STDERR "length: $len\n";
				for ($i=0; $i<$len; $i++) {
					$s = unpack("H2",substr($c,$i,1));
					print STDERR "\\x$s";
				}
				exit;
			}
		}
		$s.=$c; 
	}
	print STDERR $s;
}

# 記錄不同版本的用字
sub rdg_add_char {
	my $char=shift;
	$char =~ s#<font face="CBDia">(.*?)</font>#$1#g;
	my $wit="";
	my @a=();
	my $c="";
	foreach $n (@apps) {
		$wit=$current_wit{$n};
		@a=split / /,$wit;
		foreach $wit (@a) {
			$c=$char;
			if ($in_corr and ($wit eq "大")) {
				$c = "";
			}
			if ($wit eq "大" or $wit eq "CBETA") {
				if ($pass!=0) {
					$c="";
				}
			}
			$app{$n}{$wit} .= $c;
		}
	}
}

sub write_tool {
	my $fh = select();
	open TOOL, ">$outDir/$dir/tool.htm" or die;
	select TOOL;
	my $head =<< "XXX";
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=big5">
	<script LANGUAGE="JAVASCRIPT" SRC="../script/tool.js"></script>
	<script LANGUAGE="JAVASCRIPT" SRC="../script/showfoot.js"></script>
</head>
<body topmargin="0" leftmargin="0">
<table width="100%"><tr><td><table><tr>
<td valign="center"><font size="-1">底本選擇</font>
<td><input type="button" value="CBETA" name="VCB" onclick="javascript:selectDiBen('000')" title="中華電子佛典協會．大正新脩大藏經電子版 2003">
	<input type="button" value="大正" name="VDA"  onclick="javascript:selectDiBen('010')" title="大正新脩大藏經">
<td valign="center"><font size="-1">校勘轉換</font>
<td><select name="vv" id="vv" onChange='selectVer(this.value)'>
XXX
	my_print($head);
	my $k, $v;
	my %vers1=();
	foreach $k (keys %vers) {
		#if ($k !~ /^unknown|CBETA|大$/) {
		if ($k !~ /^unknown$/) {
			$v=$vers{$k};
			$vers1{$v}=$k;
		}
	}
	foreach $k (sort keys %vers1) {
		$v=$vers1{$k};
		if ($v !~ /^某本/) {
			$v = "【$v】";
		}
		my_print("\t\t<option value=\"$k\">$v</option>\n");
	}
	my $foot=<< "XXX";
	</select>
	<input type="button" value="隱藏校勘符號" name="SHOW2" id='show2' onclick="javascript:switchAnchor()" title="顯示校勘項目及校勘欄">
	<input type="hidden" id="jk_ver" value="000">
</table>
<td align="right"><a href="../index.htm" target="_parent">經錄</a> | <a href="../../../help/index.htm" target="blank">說明</a>
</table>
</body>
</html>
XXX
	my_print($foot);
	close TOOL;
	select $fh;
}
        
__END__ 
:endofperl
