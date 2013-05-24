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

#
# Project: CBETA
# normal.bat
# charset: utf8
# Author: Zhou, Bangxin
#
# command line options
# -v 冊數
# -n 經號 例：normal -n T01n0001.xml
# -e output encoding
# -i input directory
# -o output directory
# -s 精簡版
# -p ++精簡版
# -j normalize for Japanese
# -d 以經為目錄單位, 目錄名稱使用中文長檔名
# -z 不使用通用字
# -m 使用 M 碼
# -c 內碼轉換表路徑

open O, ">c:/cbwork/err.txt";
close O;

setInc();
use Getopt::Std; # MacPerl 沒有 Getopt Module
require "subutf8.pl" or die;
getopts('v:e:n:i:o:pjsdzmc:');

$dia_format = 1;

$outEncoding = $opt_e;

if ($opt_o eq '') { $opt_o = "c:/release"; }

$vol = $opt_v;
if ($opt_n ne '') {
	$infile = $opt_n;
	$vol = substr($infile,0,3);
}
$vol = uc($vol);

$vol = uc($vol);
if ($vol eq ""){
	my $f = $0;
	$f =~ s#.*/(.*)\..*$#$1#;
	print "$f: 由 XML 經文檔產生 CBETA Normal 版\n";
	print "使用方法: \n";
	print "\t指定冊數：$f -v T10\n";
	print "\t指定經號：$f -n T10n0279.xml\n";
	exit;
}
print STDERR "$vol $infile $outEncoding $opt_o\n";

$outEncoding = lc($outEncoding);
if ($outEncoding eq '') { $outEncoding = 'big5'; }


mkdir($opt_o, MODE);
if ($opt_s) {
	$outPath = $opt_o . "/simple"; # 精簡版
} else {
	$outPath = $opt_o . "/normal";
}
mkdir($outPath, MODE);

if ($opt_p) {
	print STDERR "PDA Version\n";
}
print STDERR "Initialising....\n";

#utf8 pattern
	$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

# 取得目前程式所在路徑
if ($0 =~ /\//) {
	@temp = split(/\//, $0);
} else {
	@temp = split(/\\/, $0);
}
pop @temp;
$path = join('/',@temp);
$path =~ s#\\#/#g;
print STDERR "path=$path\n";
push (@INC, $path);

foreach $s (@INC) { print STDERR "$s\n"; }

if ($opt_c ne '') { $opt_c .= "/"; }
require "${opt_c}subutf8.pl";
require "${opt_c}b52utf8.plx";  ## this is needed for handling the big5 entity replacements
require "${opt_c}head.pl";
require "${opt_c}b5jpiz.plx" if ($opt_j);
if ($outEncoding eq "big5") {
	require "${opt_c}utf8b5o.plx" or die; #utf-tabelle fuer big5, jis..
} elsif ( $outEncoding eq "gbk"){
	require "${opt_c}utf8gbk.plx";
	require "${opt_c}utf8.pl";  #for unicode->utf8 conversion
} elsif ( $outEncoding eq "sjis"){
	require "${opt_c}utf8sjis.plx";
	require "${opt_c}utf8.pl";  #for unicode->utf8 conversion
} elsif ( $outEncoding eq "utf8"){
	require "${opt_c}utf8.pl";  #for unicode->utf8 conversion
} else{
	die "unknown output encoding! \nPlease revise the file CBETA.CFG\n"; 
}
#we don't want to see this character!
$utf8out{"\xe2\x97\x8e"} = '';
$temp = keys %utf8out;
print STDERR "Length of conversion table: $temp\n";

if ($opt_i eq '') { $opt_i = "c:/cbwork/xml"; }
else { chdir("$opt_i/$vol") or die; }

#opendir (INDIR, "$opt_i/$vol");
opendir (INDIR, ".");
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

readSutraList();

use XML::Parser;

my $debug=0;
my %Entities = ();
my $ent;
my $indent;
my $val;
my $text;
my $noteType="";
my $notePlace='';
my $version;
my $juanNum;
my $inDiv1=0;
my @saveIndent=();
my @saveElement=();
my $CorrCert;
local $no_nor;
local %ZuZiShi = ();
$date="";

sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) { return; }
	#my $big5 = '\[|\]|\*|[\xa1-\xfe][\x40-\xfe]';
	my $big5 = '[\x00-\x7f]|[\x80-\xff][\x00-\xff]';
	my $des;
	print STDERR "Read entity $file...";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		$_ = b52utf8($_);
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
			/^(.+)\s+\"(.*)\".*/;
			$ent = $1;
			$val = $2;
			$ent =~ s/ //g;
			
			if ($ent =~ /SD-.{4}/) {
				$Entities{$ent} = "◇";
				next;
			}
		
			if ($val=~/des=\'(.+?)\'/) { 
				$ZuZiShi{$ent} = $1;
			}

			#big5
			if ($outEncoding eq "big5") {
				if (not $opt_z and $val=~/nor=\'(.+?)\'/) { $val=$1; }
				elsif (not $opt_m and $val=~/des=\'(.+?)\'/) { $val=$1; }
				elsif ($opt_m and $val=~/mojikyo=\'(.+?)\'/) { $val=$1; }
				else { $val=$ent; }
			#gbk, utf8
			} elsif ($outEncoding =~ /(gbk)|(utf8)/){
				if ($val=~/uni=\'(.+?)\'/) {
					$val=$1; 
					$val=&toutf8(pack("H*", $val));
				} elsif (not $opt_z and $val=~/nor=\'(.+?)\'/) {  # 使用通用字
					$val=$1; 
				} elsif (not $opt_m and $val=~/des=\'(.+?)\'/) { # 使用組字式
			  		$val=$1; 
				} elsif ($opt_m and $val=~/mojikyo=\'(.+?)\'/) { # 使用 M 碼
					$val=$1; 
				} else { $val=$ent; }
			#sjis
			} elsif ($outEncoding eq "sjis"){
				# SJIS 版缺字一律用 M 碼
				if ($val=~/mojikyo=\'(.+?)\'/) {
					$val="&$1;";
				} elsif ($val=~/des=\'(.+?)\'/) { 
			  		$val=$1; 
				} else { $val=$ent; }
			} else {
			#unknown;
				die "unknown output encoding! \nPlease revise the file CBETA.CFG\n"; 
			}
		} else {
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
		}
		#print STDERR "ent=[$ent] val=[$val]\n"; getc;
		$Entities{$ent} = $val;
	}
	
	if ($dia_format == 1) {
		$Entities{"Amacron"} = "AA";
		$Entities{"amacron"} = "aa";
		$Entities{"ddotblw"} = ".d";
		$Entities{"Ddotblw"} = ".D";
		$Entities{"hdotblw"} = ".h";
		$Entities{"imacron"} = "ii";
		$Entities{"ldotblw"} = ".l";
		$Entities{"Ldotblw"} = ".L";
		$Entities{"mdotabv"} = "^m";
		$Entities{"mdotblw"} = ".m";
		$Entities{"ndotabv"} = "^n";
		$Entities{"ndotblw"} = ".n";
		$Entities{"Ndotblw"} = ".N";
		$Entities{"ntilde"}  = "~n";
		$Entities{"rdotblw"} = ".r";
		$Entities{"sacute"}  = "`s";
		$Entities{"Sacute"}  = "`S";
		$Entities{"sdotblw"} = ".s";
		$Entities{"Sdotblw"} = ".S";
		$Entities{"tdotblw"} = ".t";
		$Entities{"Tdotblw"} = ".T";
		$Entities{"umacron"} = "uu";
	}
		
	print STDERR "ok\n";
}


sub default {
    my $p = shift;
    my $string = shift;

	# added by Ray 1999/12/11 03:34PM
	# 不顯示 <note type="sk">, <note type="foot">
	my $parent = lc($p->current_element);
	if ($parent eq "note" and $noteType eq "sk") { return; }
	if ($parent eq "note" and $noteType eq "foot") { return; }
	if ($parent eq "note" and $notePlace eq "foot") { return; }

	$string =~ s/^\&(.+);$/&rep($1)/eg;
	if ($bibl == 1){
		$bib .= $string ;
		#print STDERR "$bib\n";
	}
	
	$$text_ref .= $string if ($pass == 0);
}

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$fileopen = 0;
	$num = 0;
	$inxu=0;
	$inHead=0;
	$text="";
	$text2 = '';
	$text2_dirty = 0;
	$text_ref = \$text;
	$date="";
	$item_count = 0;
	$items_of_this_line = 0;
	
	#$close = "";
	@close=();
	@no_nor=();
	@save_item_count = ();
}

sub start_handler 
{
	my $p = shift;
	$el = shift;
	
	my (%att) = @_;
	
	push @no_nor, $no_nor;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	
	local $rend = '';
	if (defined($att{"rend"})) { 
		$rend = parseRend($att{"rend"}); 
		$att{"rend"} = $rend;
	}
	push @saveatt , { %att };
	
	push @saveElement, $el;
	push @saveIndent, $indent;
	
	if ($debug) { watch("262 [$text] [$indent]\n");  getc;  }
	
	$pass++ if $el eq "rdg";
	$pass++ if $el eq "gloss";
	
	if ($el eq "head" && lc($att{"type"}) eq "added"){
		$pass++;
		$added = 1;
	}
	
	#We are in the header now!
	if ($el eq "teiHeader") {  
	  $head = 1 
	}
	
	$pass = 0 if $el eq "body";
	
	if ($head == 1)	{
		if ($el =~ /^bibl|title|p$/) {
			$bibl = 1;
			$bib ='';
		}
	}

	### <cell> ###
	# added by Ray 2001/6/18
	if ($el eq "cell"){
		if ($pass==0) {
			if (not defined($att{"rend"}) and $text !~ /(║|　|。|）|#Ｐ#)$/) { 
				$rend="　"; 
			}
			$text .= $rend;
		}
	}

	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}
	}

	### <corr>
	if ($el eq "corr") {
		$CorrCert = lc($att{"cert"});
		if ($CorrCert ne "" and $CorrCert ne "100") {
			my $sic = lc($att{"sic"});
			$text .= $sic;
		}
	}

	### <corr>
	if ($el eq "corr") {
	}

	### <figure>
	if ($el eq "figure") {
		$$text_ref .= "【圖】";
	}

	### <milestone>
	if ($el eq "milestone") {
		$text .= $rend;
		$juanNum = sprintf("%3.3d",$att{"n"});
		$juanNum = "001" if ($att{"n"} eq "");
		&changefile;
	}

	### <note>
	if ($el eq "note") {
		$noteType = lc($att{"type"});
		$notePlace = lc($att{"place"});
		
		# CBETA 加的 note 不顯示
		if ($att{"resp"} =~ /^CBETA/) {
			$pass++;
		}
		my $close='';
		if ($noteType eq "inline" or $notePlace eq "inline") {
			# 不在 <rdg> 裏才要顯示 <note>
			if ($pass==0) {
				$$text_ref .= "(";
				$close = ")";
			}
		}
		push @close, $close;
	}

	### <p> ###
	if ($el eq "p" and not $head) {
		my $type = lc($att{"type"});
		if ($debug) { watch("329 <p type=\"$type\">\n"); }
		if ($rend eq "nopunc") { $rend=""; }
		if ($rend ne "") {
			$text .= $rend;
			$indent .= $rend;
		}
		if ($opt_p){
			$text = myReplace($text);
			myPrint($text);
			$text="";
			print "\n[$lb]";
		}
		
		# <p type="inline">
		if ($type eq "inline") {
			if ($text !~ /(║|　|。|#Ｐ#)$/) { $text .= "#Ｐ#"; }
		# <p type="winline">
		} elsif ($type eq "winline" ) {
			if ($text !~ /(║|　|。|#Ｐ#)$/) { $text .= "#Ｐ#"; }
			if ($rend eq "") { $indent = "　"; }
		# <p type="w">
		} elsif ($type eq "w" ) {
			if ($rend eq "") { 
				$text .= "　";
				$indent .= "　";
			}
		# <p type="dharani">
		} elsif ($type eq "dharani" or $type eq "idharani") {
			if ($text !~ /(║|　|。)$/) { $text .= "　"; }
		} else {
			if ($text !~ /(║|　|。|）|#Ｐ#)$/) { $text .= "#Ｐ#"; }
		}
		if ($debug) { watch("354 $text\n"); getc; }
	}

	### <item> ###
	# added by Ray 1999.10.7
	if ($el eq "item"){
		if ($pass==0) {
			$item_count ++;
			$items_of_this_line ++;
			if (not defined($att{"rend"})) { 
				# 上一行如果有多個 <item>, 這一行的第一個 <item> 前要多空一格
				#if ($item_count > 1 and $items_of_last_line>1 and $text =~ /(║|　)$/) { 
				#	$text .= "　"; 
				#}
				$rend="　"; 
			}
			$text .= $rend;
			$indent .= $rend;
			if ($att{"n"} ne '') { $text .= $att{'n'}; }
		}
	}
	
	### <lg> ###
	if ($el eq "lg") {
		$lgType = $att{"type"};
		$lgRend = $rend;
		# T46有 <lg rend="inline">
		if ($rend ne "inline") {
			$text .= $rend;
			$indent .= $rend;
		}
		if ($opt_p){
			$text = myReplace($text);
			myPrint($text);
			$text="";
			print "\n[$lb]";
		}
	}

	### <l> ###
	if ($el eq "l") {
		if ($rend eq '' and $lgType ne "inline" and $lgRend ne "inline") { $rend = "　"; }
		
		# 如果偈頌前有 (
		if ($text =~ /(.*║.*)\($/s) {
			$text = "$1　(";
		} else { $text .= $rend; }
	}

	### <list> ###
	# added by Ray 1999.10.7
	if ($el eq "list"){
		push @save_item_count, $item_count;
		$item_count = 0;
		if ($rend ne "table") {
			$text .= $rend;
			$indent .= $rend;
			if ($debug) { print STDERR "379 indent={$indent}\n"; }
		}
	}

	### <byline> ###
	if ($el eq "byline"){
		my $parent = lc($p->current_element);
		# 如果還沒出現過其他<byline>
		if ($parent ne "item" and $text !~/　　　　/) {
			$text .= "　　　　" ;
			$indent .= "　　　　";
		} elsif ($text !~ /║$/) {
			$text .= "　";
		}
	}

	### <head> ###
	if ($el eq "head") {
		$inHead = 1;
	
		if ($rend ne '') {
			$text .= $rend;
		} else {
			my $parent = lc($p->current_element);
			my $addSpace = 1;
			if (lc($att{"type"}) eq "added") { $addSpace = 0; }
			
			if ($parent eq "juan") {
				if ($att{"type"} ne "ping") { $addSpace = 0; }
			} elsif ($parent =~ /lg|list/) {  # <lg>,<list>的<head>不空格
				$addSpace=0;
			} else {
				#if ($parent eq "juan") {
				#	my $len = @saveElement;
				#	my $grandFather = $saveElement[$len-3];
				#	print STDERR "$grandFather\n";
				#	if ($grandFather =~ /^div\d*$/) {
				#		$parent = $grandFather;
				#	}
				#}
				#print STDERR "parent=$parent\n";
				if ($parent eq "div1") {
					if ($type{"div1"} eq "jing") { $addSpace=0; }
					elsif ($type{"div1"} eq "xu") { $addSpace=0; }  # 序的<head>不空格
					elsif ($type{"div1"} eq "hui") { $addSpace=0; }  # 會的<head>不空格
				} elsif ($parent eq "div2") {
					if ($type{"div2"} eq "jing" or $type{"div2"} eq "xu") {
						$addSpace=0; 
						# 如果行首已空兩格，去掉空格
						if ($text =~/^(.*║)　　(.*)$/s) {	$text =	$1 . $2; }
					}
				}
			}
			# T01n0023_p0302a23_##乃如是　　[13]大樓炭經三小劫品第十一
			# T36n1736_p0315b29║也。餘義多同須彌頂品　　夜摩宮中偈讚品第
			# T36n1736_p0315c01║二十。疏。表十行建立故者。此有五義大意
			if ($addSpace) {
				if (not $textInThisLine) {
					$indent .= "　" x 2;
				}
				#if ($text =~/║(\xa1\x40)*$/ or $text =~/║乃如是$/ or $text eq "") 
				#  {	$text .= "　　" ; }
				$text .= "　" x 2;
			}
		}
	}

	### <lb> ###
	if ($el eq "lb"){
		$items_of_last_line = $items_of_this_line;
		$items_of_this_line = 0;
		$old_lb = $lb;
		$lb = $att{"n"};
		#if ($lb=~/710a06/) {$debug=1; }
		if ($debug) { myPrint("lb=$lb indent=[$indent]\n"); }
		#the whole line has been cached to $text, print it now!
		  $text =~ s/　$//;
		  $text =~ s/　\)$/)/;
		  
		  # added by Ray 1999/12/29 01:55PM
		  $text =~ s/#Ｐ#$//;
		  $text =~ s/#Ｐ#/。/g;

		  # 空白行先不印, 可能屬於下一卷
		if ($fileopen == 1 and $text !~ /║$/){
			#print STDERR $text; getc;
			$text = myReplace($text);
			#print "\ntext\n";
			myPrint($text);
			$text = '';
		}
		
		if ($opt_s) {
			$lineHead = "\n$indent";
			$lineHead2 = "\n$indent";
		} elsif ($opt_p) {
			$lineHead = "";
			$lineHead2 = "";
		} else {
			$lineHead = "\n$vl$lb║$indent";
			#$lb =~ /(\d{4}\D)(\d\d)/;
			#my $lb2 = sprintf("$1%2.2d",$2+1);
			#$lineHead2 = "\n$vl$lb2║$indent";
		}
		
		if ($fileopen == 1 and $text2_dirty){
			$text2 = $lineHead . $text2;
			$text2 = myReplace($text2);
			#print "\ntext2\n";
			myPrint($text2);
			$text2 = '';
			$text2_dirty = 0;
		} elsif ($pass==0) {
			$text .= $lineHead;
		}
		
		$textInThisLine = 0;
		
		if (not $text2_dirty) {
			$text2 = '';
		}
		
		#$text2 .= $lineHead2;
	}
	
	### <pb> ###
	if ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\.0220\w\./\.0220\./;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
#		die;
	}
	
	### <div?> ###
	if ($el =~ /div\d*/) {
		if (lc($att{"type"}) eq "w") {
			if (not defined($att{"rend"})) { $rend = "　"; }
		    
			# modified by Ray 2000/2/10 03:28PM
			# T21n1343
			# <lb n="0848c09"/>[12]經</jhead></juan></div1><div1 type="W">
			# <lb n="0849c25"/>一卷</p></div1>
			# <lb n="0849c26"/><div1 type="W"><div2 type="other"><head>[11]尊勝菩薩所問經譯師傳</head>
			#if ($div1Type ne "w")	{ $text .= $s; }  # 前一個div1不是附文才加空白
			if ($type{$el} ne "w" or $text !~ /║　/)
				{ $text .= $rend; }  # 前一個div1不是附文才加空白
		    
			$indent .= $rend;
			if ($debug) { print STDERR "<$el type='w'> rend=[$rend] text=[$text]\n"; }
			if ($debug) { print STDERR "indent=[$indent]\n"; }
		}
		if (lc($att{"type"}) ne "") { $type{$el} = lc($att{"type"}); }
	}
	
	### <div1> ###
	if ($el eq "div1"){
		$inDiv1 = 1;
		if (lc($att{"type"}) eq "xu"){

			# 前序才開新檔，後序不開新檔 modified by Ray 1999.10.6
			#&changefile if ($xu != 1);
			#if ($xu != 1 && $num==0) { &changefile;	}
			
			#$xu = 1;
			$inxu = 1;
			#$num = 0;  # marked by Ray 1999/12/6 03:44PM
		}
		# modified by Ray 1999/12/7 03:47PM <div1> 可能還有其他的 type
		#if ($num == 0 && (lc($att{"type"}) eq "juan" || lc($att{"type"}) eq "jing" || lc($att{"type"}) eq "pin" || lc($att{"type"}) eq "other")) {
		if ($num == 0 && lc($att{"type"}) ne "w") {
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
			&changefile;
			$num = 1;
		}
	}

	### <juan> ###
	if ($el eq "juan"){
		$fun = lc($att{"fun"});
		if ($fun eq "open" and $type{"div1"} ne "w"){
			$juanNum = $att{"n"};
			$juanNum = "001" if ($att{"n"} eq "");
			&changefile;
		} else {
		}
	}
	

	### <sg>
	if ($el eq "sg") {
		my $close='';
		# 不在 <rdg> 裏才要顯示
		if ($pass==0) {
			$$text_ref .= "(";
			$close = ")";
		}
		push @close, $close;
	}
	
	### <t> ###
	if ($el eq "t"){
		$count_t ++;
		if ($twoLineMode==1 and $count_t > 1) {
			$text2_dirty = 1;
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
		if (defined($att{"rend"})) { 
			$$text_ref .= $rend;
		} elsif (not $tt_inline and $$text_ref !~ /║$/ and $$text_ref ne '') {
			$$text_ref .= "　";
		}
	}
	
	### <tt> ###
	if ($el eq "tt") {
		if ($att{"rend"} eq "inline" or $att{"type"} eq "inline") {
			$tt_inline = 1;
		} else {
			$tt_inline=0;
		}
		if (not $tt_inline) {
			$twoLineMode = 1;
			$count_t = 0;
		} else {
			$twoLineMode = 0;
		}
	}
	
	### <xref> ###
	if ($el eq "xref") {
		$text .= $rend;
	}
	#end startchar
}

sub rep{
	local($x) = $_[0];
	if ($no_nor and $x !~ /^M/) {  # 如果指定不用通用字
		return $ZuZiShi{$x} if defined($ZuZiShi{$x});
		die "564 Unknkown entity $x!!\n";
	} else {
		return $Entities{$x} if defined($Entities{$x});
		err();
		print STDERR "725 Unknkown entity $x!!\n";
		exit 1;
	} 
	return $x;
}


sub end_handler 
{
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	my $parent = $p->current_element;
	
	if ($debug) { print STDERR "</$el> indent=[$indent]\n"; }
	
	
	# </date>
	if ($el eq "date") {
		if ($parent eq "publicationStmt") {
			$date =~ s#^.*(..../../..).*$#$1#;
		}
	}
	
	# </edition>
	if ($el eq "edition") {
	  $version =~ /\b(\d+\.\d+)\b/;
	  $version = $1;
	}

	$head = 0 if $el eq "teiHeader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";


	### </head> ###
	if ($el eq "head"){
		if ($added == 1){
		 $pass--;
		 $added = 0;
		}
		$inHead=0;
		if ($opt_p) {
		  print "\n";
		}
	}

	# </byline>
	if ($el eq "byline"){
		$indent = "";
		if ($opt_p) {
		  print "\n";
		}
	}

	
	# </juan>
	if ($el eq "juan"){
		if ($opt_p) {
		  print "\n";
		}
	}


	#$indent = "" if ($el eq "p");

	### </l> ###
	if ($el eq "l") {
		if ( (not defined($att->{"rend"})) and ($lgType ne "inline") and $lgRend ne "inline") {
			$text .="　";
		}
	}

	if ($el eq "head"){
		$indent = "" ;
	}

	# </lg>
	if ($el eq "lg") {
		# 偈頌結束不留空白
		# a140 是全形空白
		if ($text =~ /(.*)　$/s) { $text = $1; }
		if ($opt_p){
			$text = myReplace($text);
			myPrint($text);
			$text="";
#			print "\n[$lb]";
		}
	}

	
	### </list>
	if ($el eq "list") {
		$item_count = pop(@save_item_count);
	}

	### </note>
	if ($el eq "note"){
		$close = pop @close;
		$$text_ref .= $close;
		if ($att->{"resp"} =~ /^CBETA/) {
			$pass--;
		}
	}
	
	### </bibl>
	if ($el eq "bibl"){
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			$sutraNum1 = sprintf("%4.4d",$2);
			$c = $3;
			if ($sutraNum1 eq "0220") {
				$c = '';
			}
			$sutraNum = $sutraNum1 . $c;
			if ($c eq "") {
				$c = "_";
			}
			print STDERR "751 c=$c\n";
			
			#print the rest of the line of the old file!
			$text = myReplace($text);
			myPrint($text);
			$text = "";
			#$vl = sprintf("T%2.2dn%4.4d%sp", $1, $2, $c);
			$vl = sprintf("T%2.2dn%s%sp",$1,$sutraNum1,$c);
			print STDERR "762 vl=$vl\n";
			$od = sprintf("T%2.2d", $1);
			mkdir("$outPath/$od", MODE);
			if ($opt_d) {
				$curOutPath = "$outPath/$od/$sutraNum" . $sutraName{$sutraNum} . '(' . $sutraJuan{"$sutraNum"} . '卷)';
			} else {
				$curOutPath = "$outPath/$od";
			}
			mkdir($curOutPath, MODE);
#			$c = "n" if ($c eq "_");
#			$oof = $of;
			#base name for file
			#$xu = 0;
			$fileopen = 0;
			$num = 0;
			$juanNum = 0;
			$bof = "$curOutPath/$sutraNum1$c";
			print STDERR "bof=[$bof]\n";
		} else { die "bibl=[$bibl] bib=[$bib]\n"; }
		$bib =~ s/^\t+//;
		$bib =~ s/No. 220\w/No. 220/;
		$ebib = $bib;
		$bibl = 0;
	}
	
	### </sg>
	if ($el eq "sg"){
		$close = pop @close;
		$$text_ref .= $close;
	}
	
	### </title>
	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
	}

	# </p>
	if ($el eq "p"){
		$bib =~ s/^\t+//;
		$ly{$lang} = $bib;
	}

	# </div?>
	if ($el =~ /div\d*/){
		$inxu = 0;
		$indent="";
		$inDiv1=0;
	}

	
	if ($el eq "teiHeader"){
#		&head;
	}
	$lang = "" if ($el eq "p");
	
	# </tei.2>
	if ($el eq "tei.2"){
		$text =~ s/　$//;
		$text =~ s/　\)$/)/;
		
		$text = myReplace($text);
		myPrint($text);
		$text = "";
		close (OF);
		$vl = "";
		$num = 0;
	}
	
	# </tt>
	if ($el eq "tt"){
		$twoLineMode = 0;
		$text_ref = \$text;
	}
	
	$bib = "";
	pop(@saveElement);
	$indent = pop(@saveIndent);
	$no_nor = pop(@no_nor);

	if ($debug) { print STDERR "</$el> indent=[$indent]\n"; }
}


sub char_handler 
{
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
	

	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	# <list>裏的文字只能出現在<head>或<item>裏
	if ($parent =~ /^(app|list)$/) { return; }

	# 不顯示 <note type="sk">, <note type="foot">
	if ($parent eq "note" and $noteType eq "sk") { return; }
	if ($parent eq "note" and $noteType eq "foot") { return; }
	if ($parent eq "note" and $notePlace eq "foot") { return; }

	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }
  

	$char =~ s/\n//g;

	# added by Ray 2000/1/25 03:12PM
	if ($parent eq "date") {
		my $len = @saveElement;
		if ($saveElement[$len-2] eq "publicationStmt") {
			$date .= $char;
			return;
		}
	}

	if ($parent eq "edition") { $version .= $char; }
	if ($bibl) { 
		$bib .= $char; 
	}
	
	$$text_ref .= $char if (($pass == 0 && $el ne "pb"));
	if (not $inHead) { $textInThisLine = 1; }
#	print $char if ($pass == 0 && $el ne "pb");
}


sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
#	print STDERR "$ent\t$entval\t$next\n";
	return 1;
}



#my $parser = new XML::Parser(Style => Stream, NoExpand => True);
my $parser = new XML::Parser(NoExpand => True);


$parser->setHandlers
	(Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default);

if ($infile eq "") {
	for $file (sort(@allfiles)){
		print STDERR "$file\t";
		$type{"div1"}="";
		$parser->parsefile($file);
	}
} else {
	$parser->parsefile($infile);
}

print STDERR "Done!!\n";
unlink "c:/cbwork/err.txt";

sub shead{
	myPrint($short);
}

sub changefile{
  
	# added by Ray 1999/11/9 11:29AM
	my $oldof = $of;
	$of = sprintf("$bof%3.3d.txt", $juanNum);
	if ($of eq $oldof) { return; }

	if ($fileopen) {
		$text = myReplace($text);
		myPrint("\n$text");
		$text =~ s/\n//;
		$text =~ s/\x0d$//;
		close (OF);
	}
	open OF, ">$of" or die "open $of error";
	$fileopen = 1;
	print STDERR " --> $of\n";
	select(OF);
			
	# modified by Ray 1999/12/3 09:32AM
	#if ($num == 0 || ($xu == 0 && $num == 1)){
	if ($debug) { print STDERR "num=[$num]\n"; }
	#if ($num == 0 and $xu==0){
	if ($opt_p){
		if ($num == 0){
			head("普及版","Normalized Version",$version);
		}
 		shead();
	} elsif (not $opt_s) {
		if ($num == 0){
			myPrint(head("普及版","Normalized Version",$version));
		} else {
			shead();
		}
	}
	$text =~ s/^\n//;  # added by Ray 1999/11/9 11:27AM
			
	# modified by Ray 2000/3/13 08:46AM
	#$text =~ s/\[[0-9][0-9]\]//g; # added by Ray 2000/1/28 11:10AM
	$text =~ s/\[[0-9]{2,3}\]//g; # added by Ray 2000/1/28 11:10AM
	$text = myReplace($text);
	myPrint("\n$text");
	$text = "";
	$oldbof = $bof;
}

sub parseRend {
	my $s = shift;
	if ($s =~ /margin-left:(\d+)/) {
		$s = "　" x $1;
	}
	return $s;
}

# created by Ray 2000/3/1 10:20AM
sub myReplace {
	my $s = shift;
	#changed to include GBK -- CW, 2000/4/3
	my $big5 = '[0-9\x81-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	#$s =~ s/\[[0-9（[0-9珠\]//g;
	$s =~ s/\[ㄙ\]//g;
	$s =~ s/\[[0-9]{2,3}\]//g;
	#$s =~ s/#[0-9][0-9]#//g;
	$s =~ s/#[0-9]{2,3}#//g;

	$s =~ s/(　)+★/★/g;
	
	# 兩個以上的★, 換成〔◇〕
	$s =~ s/(★){2,}/【◇】/g;
	#$s =~ s/(◇){2,}/【◇】/g;
  
	# 單獨一個★, 換成◇
	my @a=();
	push(@a, $s =~ /$big5/gs);
	$s="";
	foreach $c (@a) {	$c =~ s/★/◇/; $s.=$c;}
	
	while ($s =~ /^($utf8)*◇((◇)|( )|(　))*◇/) {
		$s =~ s/^(($utf8)*?)◇((◇)|( )|(　))*◇/$1【◇】/;
	}
	if ($opt_j) {
		my @a=();
		push(@a, $s =~ /$utf8/gs);
		my $c;
		$s = '';
		foreach $c (@a) { 
			if ($c ne "\n") {
				if (exists $b5jpiz{$c}) { $c =  $b5jpiz{$c}; }
			}
			$s.=$c; 
		}
	}
	return $s;
}

sub readSutraList {
	open I, "<$path/sutralst.txt" or die "open $path/sutralst.txt error";
	while (<I>) {
		chomp;
		my @str = split /##/;
		my $n = $str[0];
		$sutraName{$n}=$str[1];
		$sutraJuan{$n}=$str[2];
	}
	close I;
}

sub myPrint {
	my $s = shift;
	$s =~ s/^。//g;
	$s =~ s/^#Ｐ#//g;
	if ($outEncoding eq "utf8") {
		print $s;
		return;
	}
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
	print $s;
}

sub watch {
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

# 設定搜尋路徑
sub setInc {
	my $path, @temp;
	# 判斷作業系統
	if ($^O =~ /Win/) {
		# 取得目前程式所在路徑
		if ($0 =~ /\//) {
			@temp = split(/\//, $0);
		} else {
			@temp = split(/\\/, $0);
		}
		pop @temp;
		$path = join('/',@temp);
		$path =~ s#\\#/#g;
		push (@INC, $path);
	} elsif ($^O =~ /linux/) {
		#my $path = `pwd`;
		#push (@INC, $path);
	} elsif ($^O =~ /Mac/) {
		exec "mac/setup.pl";
	}	
}

sub err {
	my $p = ">$outPath/err.txt";
	print STDERR "$p\n";
	open ERR, ">$p" or die;
	print ERR "err\n";
	close ERR;
}

__END__
:endofperl
