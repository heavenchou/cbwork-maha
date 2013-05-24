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

open O, ">c:/cbwork/err.txt";
close O;

# copy and modified from app.bat by Ray 1999.10.6
# -z 不使用通用字
# -m 使用 M 碼
# -c 內碼轉換表路徑
use Getopt::Std;
getopts('v:e:n:i:o:szmc:');

$dia_format = 1;

if ($opt_o eq '') { $opt_o = "c:/release"; }

$outEncoding = $opt_e;
$outEncoding = lc($outEncoding);
if ($outEncoding eq '') { $outEncoding = 'big5'; }


$vol = $opt_v;
$infile = $opt_n;
if ($infile ne '') {
	$vol = substr($infile,0,3);
}

mkdir($opt_o, MODE);
$outPath = "$opt_o/app1";
mkdir($outPath, MODE);

if ($opt_i eq '') { $opt_i = "c:/cbwork/xml"; }
else { chdir("$opt_i/$vol") or die; }
opendir (INDIR, ".");

if ($infile eq ""){
	@allfiles = grep(/\.xml$/i, readdir(INDIR));
} else {
	@allfiles = grep(/$infile$/i, readdir(INDIR));
}


die "No files to process\n" unless @allfiles;

#print STDERR "Initialising....\n";

#utf8 pattern
	$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
	$big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';

#big5 pattern
$big5zi = "[\xa1-\xfe][\x40-\xfe]";

if ($0 =~ /\//) {
	@temp = split(/\//, $0);
} else {
	@temp = split(/\\/, $0);
}
pop @temp;
$path = join('/',@temp);
push (@INC, $path);

if ($opt_c ne '') { $opt_c .= "/"; }
require "${opt_c}b52utf8.plx";  ## this is needed for handling the big5 entity replacements
if ($outEncoding eq "big5") {
	require "${opt_c}utf8b5o.plx"; #utf-tabelle fuer big5, jis..
	require "${opt_c}head.pl";
} elsif ( $outEncoding eq "gbk"){
	require "${opt_c}utf8gbk.plx";
	require "${opt_c}headgb.pl";
	require "utf8.pl";  #for unicode->utf8 conversion
} elsif ( $outEncoding eq "sjis"){
	require "${opt_c}utf8sjis.plx";
	require "${opt_c}headsjis.pl";
	require "${opt_c}utf8.pl";  #for unicode->utf8 conversion
} else{
	die "unknown output encoding! \nPlease revise the file CBETA.CFG\n"; 
}
$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;

$bibl = 0;
my %Entities = ();
my $ent;
my $val;
my $text;
my $debug=0;
my @saveatt=();
my @saveElement=();
my @saveIndent=();

my $pass;          # 在<body>裏是0,
                   # 在<rdg>或<gloss>或<head type="added">裏 $pass 會累加
my $inp=0;           # 在 <p> 裏是1, 在 <p> 外是0
my $inTrailer;
my $inHead;
my $inByline;
my $inJhead;
my $version;
my $pRend;
my $div2Type="";
my $CorrCert;
my $heads;
my $div1Type="";
local $no_nor;
local %ZuZiShi = ();
$date;

sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) { return; }
	print STDERR "open entity $file\n";
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
			if (not $opt_z and $val=~/nor=\'(.+?)\'/) { $val=$1; }  # 優先用通用字
			elsif (not $opt_m and $val=~/des=\'(.+?)\'/) { $val=$1; } # 否則用組字式
			elsif ($opt_m and $val=~/mojikyo=\'(.+?)\'/) { $val=$1; } # 否則用組字式
		} else {
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
			$ZuZiShi{$ent} = $val;
		}
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

}


sub default {
	my $p = shift;
	my $string = shift;
    
	# added by Ray 1999/11/23 05:25PM
	my $parent = lc($p->current_element);
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
	}

	$string =~ s/^\&(.+);$/&rep($1)/eg;
	$bib .= $string if ($bibl == 1);

	# modified by Ray 2000/2/14 09:58AM
	#$text .= $string if ($pass == 0  && $inp != 1);
	#$px .= $string if ($pass == 0 && $inp == 1);
	$$text_ref .= $string if ($pass == 0);
}

sub init_handler
{
	$app=0;
	@app=();
	$bibl = 0;
	@chars=();
	@chars1=();
	@chars2=();
	$close = "";
	$pass = 1;
	$fileopen = 0;
	$num = 0;
	$inxu = 0;
	$indent="";
	$indentOfThisLine="";
	$indentOfLastLine="";
	$date="";
	$heads=0;
	$inTrailer=0;
	$inHead=0;
	$inByline=0;
	$inJhead=0;
	@no_nor=();
	$text='';
	$text2 = '';
	$text2_dirty = 0;
	$text_ref = \$text;
	$line_feed = '';
	$twoLineMode = 0;
	$twoLineModeLine = 0;
}

sub start_handler 
{
	my $p = shift;
	$el = shift;
	my (%att) = @_;
	
	push @no_nor, $no_nor;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	if ($att{"rend"} =~ /nopunc/) { 
		$nopunc=1;
		$att{"rend"} =~ s/nopunc//;
	} else {
		$nopunc=0;
	}
	
	push @saveElement, $el;
	push @saveIndent, $indent;
	my $parent = $p->current_element;

	local $rend = '';
	if (defined($att{"rend"})) { 
		$rend = parseRend($att{"rend"}); 
		$att{"rend"} = $rend;
	}
	push @saveatt , { %att };

	#watch("<$el> bibl=[$bibl]\n");

	### <body>
	if ($el eq "body")  { $pass = 0 ; }

	### <byline>
	if ($el eq "byline"){
		# 如果還沒出現過其他<byline>
		if ($parent ne "item" and $indentOfThisLine !~/　　　　/) {
			#$text .= "　　　　" ;
			if ($text =~ /║$/) {
				$indentOfThisLine.="　　　　";
				$indent = "　　　　";
			} else {
				$text .= "　" x 4;
			}
			#$text .= "＠";  # byline 接在其他東西的後面，要可以切開
		} elsif ($text !~ /║$/) {
			$text .= "　";
		}
		$inByline=1;
		if ($debug) { watch("244 indentOfThisLine=[$indentOfThisLine]"); }
	}

	### <cell> ###
	# added by Ray 2001/6/18
	if ($el eq "cell"){
		if ($pass==0) {
			#if (not defined($att{"rend"}) and $text !~ /(║|　|。|）|#Ｐ#)$/) { 
			if (not defined($att{"rend"}) and $text !~ /(║|　|。|）|Ｐ)$/) { 
				$rend="　"; 
			}
			$text .= $rend;
			if ($rend eq '') {
				$text .= "＠";
			}
		}
	}

	### <corr>
	if ($el eq "corr") {
		$CorrCert = lc($att{"cert"});
		if ($CorrCert ne "" and $CorrCert ne "100") {
			#my $sic = myDecode(lc($att{"sic"}));
			my $sic = lc($att{"sic"});
	    
			# modified by Ray 2000/2/14 09:59AM
			#$text .= $sic if ($pass == 0 && $inp != 1);
			#$px .= $sic if ($pass == 0 && $inp == 1);
			$text .= $sic if ($pass == 0);
		}
	}

	### <div1>
	if ($el eq "div1"){
		if (lc($att{"type"}) eq "xu"){
			$inxu = 1;
			$num = 0;
		} elsif ($num == 0 && (lc($att{"type"}) eq "juan" || lc($att{"type"}) eq "jing" || lc($att{"type"}) eq "pin" || lc($att{"type"}) eq "other")) {
			$num = 1;
		}
		  
		if (lc($att{"type"}) eq "w") {
			my $s="";
			#if (defined($att{"rend"})) { $s = myDecode($att{"rend"}); }
			if (defined($att{"rend"})) { $s = $att{"rend"}; }
			else { $s = "　"; }
		    
			# modified by Ray 2000/2/10 03:28PM
			# T21n1343
			# lb n="0848c09"/>[12]經</jhead></juan></div1><div1 type="W">
			# lb n="0849c25"/>一卷</p></div1>
			# lb n="0849c26"/><div1 type="W"><div2 type="other"><head>[11]尊勝菩薩所問經譯師傳</head>
			#if ($div1Type ne "w" or $text !~ /║　/)	{ # 前一個div1不是附文才加空白
			if ($div1Type ne "w")	{ # 前一個div1不是附文才加空白
				$text .= $s;
				$indent .= $s;
				$indentOfThisLine=$indent;
			}
		    
			#$+ .= $s;
			if ($debug) { print STDERR "<div1 type='w'> s=[$s] text=[$text]\n"; }
			if ($debug) { print STDERR "indent=[$indent]\n"; }
		}
		
		if (lc($att{"type"}) ne "") { $div1Type = lc($att{"type"}); }
		if ($div1Type ne "w" and $text =~ /║$/) { $indentOfThisLine=""; }
	}

	### <div2> ###
	if ($el eq "div2"){
		if (lc($att{"type"}) ne "") { $div2Type = lc($att{"type"}); }
		if ($div2Type eq "xu") { $inxu = 1; }
	}

	### <div3> ###
	if ($el eq "div3"){
		$div3Type = lc($att{"type"});
	}

	### <figure>
	if ($el eq "figure") {
		$$text_ref .= "【圖】";
	}

	### <gloss>
	if ($el eq "gloss") { $pass++ ; }
	
	### <head>
	if ($el eq "head") {
		if (lc($att{"type"}) eq "added"){
			$pass++;
			$added = 1;
		}
		#if ($heads == 0) {
		my $parent = lc($p->current_element);
		if ($debug) { print STDERR "<head> in <$parent> inxu=[$inxu]\n"; }
		my $addSpace = 1;
		if (lc($att{"type"}) eq "added") { $addSpace = 0; }
		#if ($inxu) { $addSpace=0; }  # 序的<head>不空格
		if ($parent eq "lg") { 
			$addSpace=0; # <lg>的<head>不空格
		} elsif ($parent eq "juan") {
			if ($att{"type"} ne "ping") { $addSpace = 0; }
		} elsif ($parent eq "div1") {
			if ($div1Type eq "jing") { $addSpace=0; }
			elsif ($div1Type eq "xu") { $addSpace=0; }  # 序的<head>不空格
			elsif ($div1Type eq "hui") { $addSpace=0; }  # 會的<head>不空格
		} elsif ($parent eq "div2") {
			if ($div2Type eq "jing" or $div2Type eq "xu") { 
				$addSpace=0; 
				# 如果行首已空兩格，去掉空格
				if ($text =~/^(.*║)　　(.*)$/s) {	$text =	$1 . $2; }
				if ($indentOfThisLine eq "　　") { $indentOfThisLine = ''; }
				if ($indent eq "　　") { $indent = ''; }
			}
		} elsif ($parent eq "div3") {
			if ($div3Type eq "jing") { 
				$addSpace=0; 
				# 如果行首已空兩格，去掉空格
				if ($text =~/^(.*║)　　(.*)$/s) {	$text =	$1 . $2; }
				if ($indentOfThisLine eq "　　") { $indentOfThisLine = ''; }
				if ($indent eq "　　") { $indent = ''; }
			}
		}
		if ($debug) { print STDERR "addSpace=[$addSpace]\n"; }
		#if ($text !~ /║(　)*$/) { $addSpace=0; }
		if ($addSpace) {
			# 特例：T01n0023_p0302a23_##乃如是　　[13]大樓炭經三小劫品第十一
			if (not $textInThisLine) {
				$indent .= "　" x 2;
				$indentOfThisLine.="　　";
			} else {
				$text .= "　　" ; 
			}
			#if ($text =~/║乃如是$/) { 
			#	$text .=	"　　" ; 
			#} else {
			#	$indent .= "　　" ;
			#}
  		} else {
			$text .= "＠";
		}
  		
		$heads++;
		$inHead=1;
		if ($debug) { print STDERR "indentOfThisLine=[$indentOfThisLine]\n"; }
	}

	### <jhead>
	if ($el eq "jhead"){
	  $inJhead=1;
	}

	### <item> ###
	if ($el eq "item"){
		push @app, $app;
		$app=1;
		if ($pass==0) {
			if ($debug) { watch("400 textInThisLine=[$textInThisLine]"); }
			$item_count ++;
			$items_of_this_line ++;
			if (not defined($att{"rend"})) { 
				$rend="　"; 
			}
			#if ($textInThisLine) {
			#	$text .= $rend;
			#}
			$text .= $rend;
			$indent .= $rend;
			#$indentOfThisLine.="　　";
			if ($att{"n"} ne '') { $$text_ref .= $att{'n'}; }
		}
	}

	# <juan>
	if ($el eq "juan"){
		push @app, $app;
		$app = 1;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			print STDERR ".";
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
		} else {
		}
	}

	### <l>
	if ($el eq "l") {
		push @app, $app;
		$app = 1;
		
		if ($rend eq '' and $lgType ne "inline" and $lgRend ne "inline") { $rend = "　"; }
		
		# 如果偈頌前有 (
		if ($text =~ /^(.*║.*)\($/s) {
			$text = "$1　(";
		} else { $text .= $rend; }
		if ($text != /(　|\(|＠|Ｐ|。)$/) {
			$text .= "＠";
		}
	}

	### <lb>
	if ($el eq "lb"){
		$lb = $att{"n"};
		$heads = 0;
		#if ($lb =~ /216b13/) { $debug=1; }
		if ($debug) { 
			print STDERR "\n<lb n='$lb'>\n";  #現在到了哪一行
			watch("446 textref=[$$text_ref]\n");
			watch("447 text=[$text]\n");
			watch("448 text2=[$text2]\n");
		}
		#the whole line has been cached to $text, print it now!
		
		# marked by Ray 2001/6/22
		#if ($px eq "") { $$text_ref =~ s/　$//; } # xa140 是全型空白, 偈頌的結尾會多一個全形空白
		#else { $px =~ s/　$//; }
		#$$text_ref =~ s/　\)$/)/;
		
		#if ($debug) { print STDERR "307 text=[$text]\n"; getc;}#取代掉全形空白後的$text
		#if ($fileopen == 1){
		if ($twoLineModeLine == 2) {
			$text_ref = \$text2;
			&out;
			$text2='';
		} else {
			$text_ref = \$text;
			&out;
			$text='';
		}
		
		if ($twoLineModeLine==1) {
			$twoLineModeLine=2;
		} elsif ($twoLineMode and $twoLineModeLine==2){
			$twoLineModeLine=1;
		} else {
			$twoLineModeLine=0;
		}

		if ($twoLineModeLine==2){
			$text2 = "$line_feed$vl$lb║" . $text2;
			$text_ref = \$text2;
		} elsif ($pass==0) {
			$text = "$line_feed$vl$lb║";
			if ($twoLineMode and $count_t>1) {
				$text_ref = \$text2;
			} else {
				$text_ref = \$text;
			}
		}

		#$text = "\n$vl$lb║$indent";
		$indentOfThisLine=$indent;
		$textInThisLine = 0;
		#} else {
		#	$text .= "\n$vl$lb║$indent";
		#}
		if ($line_feed eq '') {
			$line_feed = "\n";
		}

		if ($debug) { 
			watch("539 textref=[$$text]\n");
			watch("540 text=[$text]\n");
			watch("text2=[$text2]\n");
			getc;
		}
		
	} 

	# added by Ray 2001/6/20
	### <lg> ###
	if ($el eq "lg") {
		$lgType = $att{"type"};
		$lgRend = $rend;
		# T46有 <lg rend="inline">
		if ($rend ne "inline") {
			$$text_ref .= $rend;
			$indent .= $rend;
		}
		
		# 偈頌開頭可以切開，所以加分隔字元
		if ($$text_ref !~ /(　|。|）|Ｐ|＠)$/) {
			$$text_ref .= "＠";
		}
	}

	# <list>
	if ($el eq "list") {
		$$text_ref .= "＠";
	}
	
	### <milestone>
	if ($el eq "milestone") {
		$$text_ref .= $rend;
	}

	### <note>
	if ($el eq "note") {
		push @app, $app;
		$app = 1;
		if ($att{"resp"} =~ /^CBETA/) {
			$pass++;
		}
		
		if ($pass==0) {
			if (lc($att{"type"}) eq "inline" or lc($att{"place"}) eq "inline") {
				$$text_ref .= "(";
				$close = ")";
			}
		}
		push @close, $close;
	}

	if ($head == 1){
		$bibl = 1 if ($el =~ /^(bibl|title|p)$/);
	}
	if ($head == 1 && lc($att{"type"}) eq "ly"){   # 判斷語言
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}
	}

	### <p>
	if ($el eq "p") {
		push @app, $app;
		#$inp = 1 if (lc($att{"rend"}) ne "nopunc");
		if ($nopunc) {
			$app=0;
		} else {
			$app=1;
		}
		if ($debug) { print STDERR "610 app=$app rend=$att{'rend'}\n"; }
		$pRend = "";
		my $type = $att{"type"};
		if (lc($att{"type"}) eq "inline") {
			if ($text !~ /(║|　|。)$/ and $pass == 0) { $text .= "。"; }
		} elsif (lc($att{"type"}) eq "winline") {
			$text .= "。" if ($pass == 0);
		  
			$pRend = $att{"rend"};
			#$pRend =~ s/($utf8)/$utf8out{$1}/g;
			$pRend =~ s/nopunc//;
			if ($pRend eq "") { $pRend = "　"; }
			$indent .= $pRend;
		} elsif ($type eq "dharani" or $type eq "idharani") {
			if ($text !~ /(║|　|。)$/)	{ $text .= "　"; }
		} elsif (lc($att{"type"}) eq "w") {
			$pRend = $att{"rend"};
			#$pRend =~ s/($utf8)/$utf8out{$1}/g;
			$pRend =~ s/nopunc//;
			if ($pRend eq "") { $pRend = "　"; }
			if ($text =~ /║$/) { $indentOfThisLine .= $pRend; }
			else { $text .= $pRend; }
			$indent .= $pRend;
		} else {
			if ($debug) { watch("485 text=[$$text_ref]\n"); }
			if ($rend eq '') {
				#if ($$tex ne '' and $$text_ref !~ /(║|　|。|　|）|#Ｐ#)$/) { 
				#	$$text_ref .= "#Ｐ#"; 
				#if ($$text_ref ne '' and $$text_ref !~ /(║|　|。|　|）|Ｐ|＠)$/) { 
				if ($$text_ref ne '' and $$text_ref !~ /(║|　|。|\(|　|）|Ｐ|＠)$/) { 
					$$text_ref .= "Ｐ"; 
				}
			} else {
				$$text_ref .= $rend;
			}
			$indent .= $rend;
			if ($debug) { watch("487 text=[$$text_ref]\n"); }
		}
		
		# 段落前可以切開, 所以加分隔字元
		if ($$text_ref ne '' and $$text_ref !~ /(　|。|）|Ｐ|＠)$/) {
			$$text_ref .= "＠";
		}
	}
	
	# <pb>
	if ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\.0220\w\./\.0220\./;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
	}

	### <rdg>
	if ($el eq "rdg") { $pass++ ; }
	
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

	### <teiHeader>
	if ($el eq "teiHeader") { 
		$head = 1 ;   #We are in the header now!
		$bibl = 0;
	}
	
	### <trailer>
	if ($el eq "trailer") { $inTrailer=1; }
	
	### <t> ###
	if ($el eq "t"){
		$count_t ++;
		if ($twoLineMode and $count_t > 1) {
			$text2_dirty = 1;
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
		#if ($tt_type ne "inline" and $$text_ref !~ /║$/ and $$text_ref ne '') {
		#	$$text_ref .= "　";
		#}
	}

	### <tt> ###
	if ($el eq "tt") {
		$tt_rend = $att{"rend"};
		if ($tt_rend eq "inline" or $att{"type"} eq "inline") {
			$twoLineMode = 0;
			$twoLineModeLine = 0;
		} else {
			$twoLineMode = 1;
			$twoLineModeLine = 1;
			$count_t = 0;
		}
	}

	# <xref>
	if ($el eq "xref") {
		push @app, $app;
		$app = 1;
	}
}

sub rep{
	local($x) = $_[0];
	if ($no_nor) {  # 如果指定不用通用字
		return $ZuZiShi{$x} if defined($ZuZiShi{$x});
		die "Unknkown entity $x!!\n";
	} else {
		return $Entities{$x} if defined($Entities{$x});
		die "538 Unknown entity $x!!\n";
	}
	return $x;
}


sub end_handler 
{
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	my $parent = $p->current_element;
	
	$head = 0 if $el eq "teiHeader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";

	# </bibl>
	if ($el eq "bibl"){
		$bibl = 0;
		$bib =~ s/No. 220\w/No. 220/;
		$ebib = $bib;
		print STDERR "605 bib=$bib\n";
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			if ($3 eq ""){
				$c = "_";
			} else {
				$c = $3;
			}
			#print the rest of the line of the old file!
			$vl = sprintf("T%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("T%2.2d", $1);
			mkdir("$outPath/$od", MODE);
			$c = "n" if ($c eq "_");
			# modified by Ray 2001/6/13 02:48下午
			#$of = sprintf("$outPath/$od/T%2.2d$c%4.4d.txt", $1, $2);
			$of = sprintf("$outPath/$od/T%2.2dn%4.4d$3.txt", $1, $2);
			$text =~ s/\n//;
			$text =~ s/\x0d$//;
			#$text =~ s/#Ｐ#$//;
			$text =~ s/Ｐ$//;
			#$text =~ s/#Ｐ#/。/g;
			$text =~ s/Ｐ/。/g;
			myPrint("$text\n");

			if ($of ne $old_of) {
				$old_of = $of;
				open (OF, ">$of");
				select OF;
				print STDERR "> $of\n";
				$printJuanHead = 1;
			} else {
				open (OF, ">>$of");
				print STDERR ">> $of\n";
				$printJuanHead = 0;
			}
			select(OF);
		}
		$bib =~ s/^\t+//;
	}

	# </byline>
	if ($el eq "byline"){
	  $indent = "";
	  $inByline=0;
		$$text_ref .= "＠";
	}

	# </date>
	if ($el eq "date") {
		if ($parent eq "publicationStmt") {
			$date =~ s#^.*(..../../..).*$#$1#;
		}
	}
	
	# </div1>
	if ($el eq "div1"){
		$inxu = 0;
	}

	# </edition>
	if ($el eq "edition") {
	  $version =~ /\b(\d+\.\d+)\b/;
	  $version = $1;
	}

	# </head>
	if ($el eq "head"){
		$indent = "" ;
		$inHead=0;
		if ($added == 1){
			$pass--;
			$added = 0;
		}
	}

	# </item>
	if ($el eq "item") {
		$app = pop(@app);
	}

	# </jhead>
	if ($el eq "jhead") {
		$inJhead=0;
	}
	
	# </juan>
	if ($el eq "juan") {
		$app = pop(@app);
	}
	
	# </list>
	if ($el eq "list") {
		$$text_ref .= "＠";
	}

	### </l> ###
	#$text .="　" if $el eq "l";
	if ($el eq "l") {
		if ( (not defined($att->{"rend"})) and ($lgType ne "inline") and $lgRend ne "inline") {
			$text .="　";
		}
		$app = pop(@app);
	}

	# added by Ray 2001/6/20
	# </lg>
	if ($el eq "lg") {
		# 偈頌結束不留空白
		# a140 是全形空白
		if ($$text_ref =~ /^(.*)　$/s) { $$text_ref = $1; }
	}
	
	# </note>
	if ($el eq "note") {
		$close = pop @close;
		if ($close ne "") {
			$$text_ref .= $close if ($pass == 0);
			$close = "";
		}
		if ($att->{"resp"} =~ /^CBETA/) {
			$pass--;
		}
		$app = pop(@app);
	}


	# </p>
	if ($el eq "p"){
		if ($head == 1) {  # 如果在 <teiheader> 裏
			$bib =~ s/^\t+//;
			$ly{$lang} = $bib;
			$bibl = 0;
		} else {
		  #$text .= "-";
		}
		#$inp = 0;
		$app = pop(@app);
		
		# modified by Ray 2001/6/20
		if ($px ne "") { $px .= "Ｐ"; }
		#if ($px ne "") { $px .= "#Ｐ#"; }
		
		# added by Ray 1999/12/1 10:22AM
		$indent =~ s/$pRend//;
		
		$$text_ref .= "＠";  # <p> 結束的地方可以切
	}

	### </sg>
	if ($el eq "sg"){
		$close = pop @close;
		$$text_ref .= $close;
	}

	# </t>
	if ($el eq "t") {
		$$text_ref .= "　";
	}
	
	# </title>
	if ($el eq "title"){
		if ($head == 1) {  # 如果在 <teiheader> 裏
			$bib =~ s/^[\t ]+//;
			$title = $bib;
			$bibl = 0;
			watch("806 title=[$title]\n");
		}
		if ($parent ne "jhead") {
			$$text_ref .= "＠";  # title 結束的地方可以切
		}
	}



	# </teiheader>
	if ($el eq "teiHeader"){
		#print STDERR "date=[$date]\n";
		if ($printJuanHead) {
			myPrint(head("App普及版","App-Format",$version));
			myPrint("\n");
		}
		$text = "";
	}

	$lang = "" if ($el eq "p");
	
	# </tei.2>
	if ($el eq "tei.2"){
		&out;
		$text = "";
		myPrint("\n");
		close (OF);
		$vl = "";
		$num = 0;
	}

	# </trailer>
	if ($el eq "trailer") { $inTrailer=0; }
	
	# </tt>
	if ($el eq "tt"){
		$twoLineMode = 0;
		$count_t=0;
		$text_ref = \$text;
	}

	# </xref>
	if ($el eq "xref") {
		$app = pop(@app);
	}

	$bib = "";
	pop(@saveElement);
	$indent = pop(@saveIndent);
	$no_nor = pop(@no_nor);
}


sub char_handler 
{
	my $p = shift;
	my $char = shift;
	
	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	my $parent = lc($p->current_element);
	if ($parent eq "app") { return; }
  
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk" or $noteType eq "foot" or $att->{"place"} eq "foot") {  
			return;  
		}
	}

	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }

	# marked by Ray 2001/6/21
	#$char =~ s/($utf8)/$utf8out{$1}/g;
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
	if ($bibl == 1) {
		$bib .= $char;
		#watch("910 parent=[$parent] bibl=[$bibl] bib=[$bib]");
		#getc;
	}
	
	# modified by Ray 2000/2/14 10:02AM
	#$text .= $char if ($pass == 0 && $el ne "pb" && $inp != 1);
	#$px .= $char if ($pass == 0 && $el ne "pb" && $inp == 1);
	$$text_ref .= $char if ($pass == 0 && $el ne "pb");
	if (not $inHead and $char ne '') { $textInThisLine = 1; }
}


sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
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

for $file (sort(@allfiles)){
	print STDERR "$file\n";
	$parser->parsefile($file);
#	die;
}
print STDERR "Done!!\n";
unlink "c:/cbwork/err.txt";


sub shead{
	myPrint($short);
}

sub out{
	my $lineHead;
	my $firstChar=1;
	my $thisLineIsEmpty=1;
	
	#if ($text =~ /860c10/) { $debug=1; }
	if ($debug) { print STDERR "begin out() px=[$px] twoLineModeLine=$twoLineModeLine app=$app\n"; }
	if ($debug) { watch("741 text_ref=[$$text_ref] indent=[$indent] indentOfThisLine=[$indentOfThisLine] indentOfLastLine=[$indentOfLastLine]\n"); }

	#$$text_ref =~ s/#Ｐ#$//;
	my $endWithP = 0;
	if ($$text_ref =~ /Ｐ$/) {
		$endWithP = 1;
		$$text_ref =~ s/Ｐ$//;
	}
	#$$text_ref =~ s/#Ｐ#/。/g;
	$$text_ref =~ s/Ｐ/。/g;
	
	# ◎ 可能在行首, 上一行不必折行, 所以不能在這裏取代掉, 等 myPrint() 再去掉 2001/6/26
	#$$text_ref =~ s/◎//g;  # added by Ray 2001/6/22
	
	# 取出行首資訊
	# added by Ray 1999/12/1 11:52AM
	#$$text_ref =~ /^(.*?)\xf9\xf8(.*)$/s;  # xf9f8 是║
	$$text_ref =~ /^(.*?)║(.*)$/s;  # xf9f8 是║
	$lineHead = $1;
	my $rend = $indentOfThisLine;
	$$text_ref = $2;
	
	# added by Ray 2001/12/10
	# ◎ 不在行首的話不當做分隔符號
	if ($$text_ref !~ /^◎/) {
		$$text_ref =~ s/◎//g;
	}

	if ($debug) { print STDERR "lineHead=[$lineHead]\n"; }#印出行首

	#$count = @chars;
	if ($debug) { watch("1052 twoLineModeLine=$twoLineModeLine\n"); }
	if ($twoLineModeLine ==2) {
		@chars = @chars2;
	} else {
		@chars = @chars1;
	}
	$count = 0;
	foreach $c (@chars) {
		if ($count==0 and $c eq "　") { next; }
		if ($c ne "＠") { $count++; }
	}
	
	if ($count > 99){
		$count = sprintf("%2.2d", $count);
	} else {
		$count = sprintf("(%2.2d", $count);
	}

	if ($debug) { 
		my $temp = join('',@chars);
		watch("870 chars=[$temp]\n");
		watch("735 count=$count text=[$$text_ref]\n"); 
	}
		
	$$text_ref = myReplace($$text_ref);
		
	# 下一行拆成矩陣
	my @nextLineChars=();
	#push(@nextLineChars, $$text_ref =~ /$big5/g);
	push(@nextLineChars, $$text_ref =~ /$utf8/g);

	# 組字式視為同一字
	my @temp = @nextLineChars;
	@nextLineChars = ();
	while (@temp>0) {
		$cc = shift @temp;
		if ($cc eq "[") {
			$s1 = join("", @temp);
			if ($s1 =~ /\]/) {
				$c = "##";          
				while ($c ne "]" and @temp>0) {
					$c = shift @temp;
					$cc .= $c;
				}
			}
			push @nextLineChars, $cc;
			next;
		}
		if ($cc =~ /^(.{2})(\[.*\])$/) {
			push @nextLineChars, $1;
			push @nextLineChars, $2;
		} else { push @nextLineChars, $cc; }
	}

	# 下一行第一個字元是否分隔字元
	#my $delimiter = "　。．、,. （）【】()[]Ｐ";  # 間隔字元
	my $delimiter = "　。．、,. （）【】()[]Ｐ◎＠◇□";  # 間隔字元
	$char = $nextLineChars[0];
	$cc = quotemeta($char);
	if ($delimiter =~ /$cc/ or $$text_ref eq "") { 
		if ($debug) { 
			watch("下一行第一個字元 $char 是分隔字元\n"); 
		}
		if (@chars > 0) {
			if ($debug) { watch("999 印出上一行的內縮: [$indentOfLastLine]\n"); }
			myPrint($indentOfLastLine);
			if ($debug) { watch("954 " . @chars . "\n"); }
			if ($cc eq "　" and $chars[$#chars] eq "　") {
				pop @chars;
			}
			if ($debug) { watch("958 " . @chars . "\n"); }
			my $temp = join('',@chars);
			if ($debug) { watch("印出上一行:[$temp]\n"); }
			myPrint($temp); # 印出上一行
			@chars=();
			$count="(00"; # 折到下一行的字數為0
		}
	}
	
	# 印出下一行行號
	if ($lineHead ne "") { myPrint("${lineHead}$count)║"); }

	# modified by Ray 2000/2/14 10:09AM
	#if ($px ne ""){
	if ($debug) { watch("inp=$inp inTrailer=$inTrailer inHead=$inHead\n"); }
	if ($debug) { watch("Line:677 text=[$$text_ref]\n"); }
	
	
	# 如果是行行對照就不用移位
	#if ($twoLineModeLine==0 and not $endWithP and ($app or $inp or $inTrailer or $inHead or $inByline or $inJhead) and $$text_ref ne "") {
	if ($twoLineModeLine==0 and not $endWithP and ($app or $inTrailer or $inHead or $inByline or $inJhead) and $$text_ref ne "") {
		# 要進行 app 移位

		if ($debug) { watch("923 text=[$text]\n"); }
      		
		push(@chars, @nextLineChars);
      		
		if ($debug) {
			watch("928\n");
			$i=0;
			foreach $cc (@chars) { 
				watch("$i$cc,"); 
				$i++;
			}
			getc;
		}
      		
		my $cut=0;  # 切到下一行的位置
		for ($i=@chars-1; $i>=0; $i--) {
			$c = $chars[$i];
			$cc = quotemeta($c);                      #為什麼這裡要多用一個$cc？quotemeta
			if ($delimiter =~ /$cc/) {
				# modified by Ray 2000/2/24 10:15AM
				#if ($c eq "（" or $c eq "(" or $c eq "[") { $cut = $i; }
				if ($c eq "　" or $c eq "＠") { 
					#if ($i > 0) {
					#	if ($chars[$i-1] eq "　") { # 可能連續兩個全形空白
					#		$cut = $i-1;
					#	}
					#} else {
					#	$cut = $i;
					#}
					while ($chars[$i-1] eq "　" or $chars[$i-1] eq "＠") { # 可能連續兩個全形空白
						$i--;
					}
					$cut = $i;
				} elsif ($c eq "【" or $c eq "（" or $c eq "(" or $c eq "[") { 
					$cut = $i; 
				} else { 
					$cut=$i+1;
				}
				last;
			}
      		}
		if ($debug) { print STDERR "cut=[$cut]\n"; }
		for ($i=0; $i<$cut; $i++) {                   #從這裡印出本文
			$c = shift (@chars);
			if ($i==($cut-1) and $c eq "　") { next; }
			if ($c ne "║" and $c ne "Ｐ") {
				if ($firstChar) { myPrint($rend); $firstChar=0; }
				myPrint($c);
				$thisLineIsEmpty=0; # 有印出東西，這一行不是空行
			}
		}
		
		# 如果要折到下一行的只有空格或分隔字元，就不用折了
		my $temp = join('',@chars);
		$temp =~ s/　//g;
		$temp =~ s/＠//g;
		if ($temp eq '') {
			@chars = ();
		}
	} else {
		# 不必進行 app 移位
		if ($debug) { 
			watch("716 不必app indent=[$indent]\n"); 
			my $i = @chars;
			watch("chars $i\n");
		}
		if ($$text_ref ne "" or @chars > 0) { 
			# marked by Ray 2001/6/27
			#if ($debug) { watch("721 印出rend=[$rend]\n"); }
			#myPrint($rend); 
			$thisLineIsEmpty=0;
		}
		
		if ($debug) { watch("1116 印出 rend=[$rend]\n"); }
		myPrint($rend);
		
		# 如果這一行是空的，要把上一行剩下的印出去 added by Ray 1999.10.8
		#if ($text =~ /║$/) { print @chars; @chars=(); }
		my $temp = join('',@chars);
		#$temp =~ s/#Ｐ#$//s;
		$temp =~ s/Ｐ$//s;
		if ($temp =~ /Ｐ/) { print STDERR "910 [$temp]\n"; }
		$temp = myReplace($temp);
		if ($debug) { watch("1029 準備印出上一行剩下的：[$indentOfLastLine$temp]\n"); }
		#myPrint($indentOfLastLine);
		myPrint($temp);
		@chars=();
		
		#print "${text}";
		#$$text_ref =~ s/#Ｐ#$//s;
		$$text_ref =~ s/Ｐ$//s;
		if ($$text_ref =~ /Ｐ/) { print STDERR "915 [$$text_ref]\n"; }
		$$text_ref = myReplace($$text_ref);
		$$text_ref =~ s/　$//;
		if ($debug) { watch("1034 準備印出這一行：[$$text_ref]\n"); }
		myPrint($$text_ref);
	}
	#$px = "";
	$$text_ref = "";
	
	# 這一行是空行，把indent存起，下一行要印時用
	if ($thisLineIsEmpty) { $indentOfLastLine = $indentOfThisLine; }
	else { $indentOfLastLine = ""; }
	if ($debug) { watch("indentOfLastLine=[$indentOfLastLine]\n"); }
	if ($twoLineModeLine==2) {
		@chars2 = @chars;
	} else {
		@chars1 = @chars;
	}
}

#sub myDecode {
#  my $s = shift;
#  $s =~ s/($utf8)/$utf8out{$1}/g;
#	return $s;
#}

sub myReplace {
	my $s = shift;
	if ($debug) { watch("865 [$s]\n"); }
	#my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my $big5 = '[\x80-\xff][\x00-\xff]|[\x00-\x7f]';
	my @a = ();
	my $c='';
	# marked by Ray 2001/6/20
	#$s =~ s/\[[0-9（[0-9珠\]//g;
	$s =~ s/\[[0-9]{2,3}\]//g;
	#$s =~ s/#[0-9][0-9]#//g;
	$s =~ s/#[0-9]{2,3}#//g;

	# 單獨一個★, 換成◇
	#$s =~ s/(?:$big5zi|[0-9])*?(★)(?:$big5zi|[0-9])*?/◇/g;
	#push(@a, $s =~ /$big5/g);
	push(@a, $s =~ /$utf8/g);
	$s='';
	foreach $c (@a) {
		$c =~ s/★/◇/;
		$s .= $c;
	}

	
	# 兩個以上的◇, 換成〔◇〕
	#while ($s =~ /^($big5)*◇((◇)|( )|(　)|(【◇】))*((◇)|(【◇】))/) {
	while ($s =~ /^($utf8)*◇((◇)|( )|(　)|(【◇】))*((◇)|(【◇】))/) {
		#$s =~ s/^(($big5)*)◇((◇)|( )|(　)|(【◇】))*((◇)|(【◇】))/$1【◇】/;
		$s =~ s/^(($utf8)*)◇((◇)|( )|(　)|(【◇】))*((◇)|(【◇】))/$1【◇】/;
	}

	if ($debug) { watch("889 [$s]\n"); }
	return $s;
}

sub parseRend {
	my $s = shift;
	#$s =~ s/($utf8)/$utf8out{$1}/g;
	if ($s =~ /margin-left:(\d+)/) {
		$s = "　" x $1;
	}
	return $s;
}

sub myPrint {
	my $s = shift;
	$s =~ s/◎//g;
	$s =~ s/＠//g;
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


__END__
:endofperl
