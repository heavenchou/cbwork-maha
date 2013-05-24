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
# hh5-jk.bat 
# 產生 cbeta html help version 右邊經文區
# 使用惠敏法師部類目錄
# 輸出目錄: cbeta.cfg 裏的 hh_out_root
# 執行範例: c:\cbwork\work\bin>hh5-jk 1 (一次一個部類)
#
# written by Ray 2001/2/28 04:16下午
#
# 程式改為 utf8 2001/8/17 by Ray

# 產生記錄檔, 程式正常結束時刪除, 用來判斷程式是否正確執行完畢
open O, ">c:/cbwork/err.txt";
close O;
open LOG, ">hh5-jk.log" or die;

### command line parameter ###
$BuLei=shift;
$BuLei = sprintf("%3.3d",$BuLei);

use Getopt::Std; # MacPerl 沒有 Getopt Module
getopts('e:');
$outEncoding = $opt_e;
$outEncoding = lc($outEncoding);
if ($outEncoding eq '') { $outEncoding = 'big5'; }

### 設定值 ###

open CFG,"cbeta.cfg" or die "cannot open cbeta.cfg\n";
while (<CFG>) {
	next if (/^#/); #comments
	chomp;
	($key, $val) = split(/=/, $_);
	$cfg{$key}=$val; #store cfg values
	print STDERR "$key\t$cfg{$key}\n";
}
close CFG;
$inDir = $cfg{"xml_root"};
$outDir = $cfg{"hh_out_root"};
if ($outEncoding eq "gbk") {
	$outDir .= "-gbk";
}

local @chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhongGuan 14Yogacara 15LunJi 16PureLand 17Chan 18History 19Misc 20Apoc 21ZhongGuan 22PureLand 23DunHuang);
local $chm=$chms[$BuLei-1];
local $nextChm=$chms[$BuLei];
mkdir("$outDir/$chm", MODE);
$nid=0;

print STDERR "Initialising....\n";


#big5 pattern
  $big5zi = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "b52utf8.plx";  ## this is needed for handling the big5 entity replacements
if ($outEncoding eq "gbk") {
	require "utf8gbk.plx";
	require "utf8.pl";
} else {
	require "utf8b5o.plx";
}
require "hhead.pl";
require "subutf8.pl";
require "cbetasub.pl";
#$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;
use Image::Size;

my $debug=0;
local @pages = ();
my %Entities = ();
local %no_nor = ();
local $no_nor = 0;
my $ent;
my $val;
my $text;
my $headText;
my $div1head;
my $div2head;
my %jk=();
my @jk_n=();
my $juanText;
my $juanNum;
my $juanURL;
my $juanOld="";
my $flagSource=0;
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
my @tagBeforeLine=();
my @elements=();
my @mulu=();      # $mulu[$i][0] 目錄類別
                  # $mulu[$i][1] 目錄層級
                  # $mulu[$i][2] 對應的 URL
                  # $mulu[$i][3] 目錄標題
                  # $mulu[$i][4] 是否有子目錄
                  # $mulu[$i][5] 目錄所在卷數
                  # $mulu[$i][6] 所在卷數對應的 URL
local @close=();

my %saveXu=();
my %saveJuan=();
my %savePin=();   # 品
my %savePin2=();  # 品 (div2)
my %saveHui=();   # 會
my %saveFen=();   # 分
my %saveJing=();  # 經
my %saveOther=();
my %span=();
my $version;
my $firstLineOfSutra;
my $firstLineOfPage;
my $saveof = "";
my $CorrCert;
my $juanOpen=0;
my $mostDeepLevel="";
my $jingURL="";
my $jingLabel="";
local $lastChm='';

my %dia = (
 "Amacron","A^",
 "amacron","a^",
 "ddotblw","d!",
 "Ddotblw","D!",
 "hdotblw","h!",
 "imacron","i^",
 "ldotblw","l!",
 "Ldotblw","L!",
 "mdotabv","m%",
 "mdotblw","m!",
 "ndotabv","n%",
 "ndotblw","n!",
 "Ndotblw","N!",
 "ntilde","n~",
 "rdotblw","r!",
 "sacute","s/",
 "Sacute","S/",
 "sdotblw","s!",
 "Sdotblw","S!",
 "tdotblw","t!",
 "Tdotblw","T!",
 "umacron","u^"
);      

my %lucida = (
 "acirc","a&#x0302;",
 "Amacron","&#256;",
 "amacron","&#257;",
 "ddotblw","d&#x0323;",
 "Ddotblw","D&#x0323;",
 "ecirc","ea&#x0302;",
 "hdotblw","h&#x0323;",
 "icirc","i&#x0302;",
 "imacron","i&#x0304;",
 "ldotblw","l&#x0323;",
 "Ldotblw","L&#x0323;",
 "mdotabv","m&#x0307;",
 "mdotblw","m&#x0323;",
 "ndotabv","n&#x0307;",
 "ndotblw","n&#x0323;",
 "Ndotblw","N&#x0323;",
 "ntilde","n&#x0303;",
 "ocirc","o&#x0302;",
 "rdotblw","r&#x0323;",
 "sacute","s&#x0301;",
 "Sacute","S&#x0301;",
 "sdotblw","s&#x0323;",
 "Sdotblw","S&#x0323;",
 "tdotblw","t&#x0323;",
 "Tdotblw","T&#x0323;",
 "ucirc","u&#x0302;",
 "umacron","u&#x0304;"
);

local @LastPageOfVol = (
 "T010924c",
 "T020884b",
 "T030975c",
 "T040802b",
 "T051074c",
 "T061073b",
 "T071110b",
 "T080917b",
 "T090788b",
 "T101047b",
 "T110977a",
 "T121119b",
 "T130998a",
 "T140968c",
 "T150807a",
 "T160857c",
 "T170963a",
 "T180946a",
 "T190744b",
 "T200940a",
 "T210968c",
 "T221072a",
 "T231057b",
 "T241122a",
 "T250914a",
 "T261031c",
 "T271004a",
 "T281001b",
 "T290977c",
 "T301035b",
 "T310896b"
);
        
#my $parser = new XML::Parser(Style => Stream, NoExpand => True);
my $parser = new XML::Parser(NoExpand => True);
        
        
$parser->setHandlers(
	Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default
);

readGaiji();
readBuLei();
my $s;
my $olds='';
my $hhcLevel=1;
my $pre;
foreach $s (keys %BuLeiDir) {
	if ( not exists($BuLeiDir{$s."001"})) { # 如果沒有下一層
		$BuLeiDir{$s} =~ /^(\d{4}\w?)(.*)$/;
		$sutraNum = $1;
		$sutraName = $2;
		$sutras{$sutraNum} = $sutraName;
	}
}

foreach $s (sort keys %sutras) {
	$sutraNum = $s;
	$sutraName = $sutras{$s};
	$vol = num2vol($sutraNum);
	chdir("$inDir/$vol");
	$file = "$inDir/$vol/${vol}n$sutraNum.xml";
	print STDERR "$file\n";
	$parser->parsefile($file);
}
printPageBottom('');

$oldLevel--;
while($oldLevel > 0) {
	$pre = "\t" x $oldLevel;
	$oldLevel--;
}
unlink "c:/cbwork/err.txt";



        
#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	if ($file =~ /gif$/) { return; }
	#print STDERR "open Entity definition: $file\n";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chomp;
		if ($debug) { print STDERR "251 $_\n"; }
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
			/^(.+)\s+\"(.*)\".*/;
			$ent = $1;
			$val = $2;
			$ent =~ s/ //g;
			$gaiji{$ent} = $val;
			if ($file=~/jap\.ent/) { # 如果是日文
		 		if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # 優先使用 Unicode
				$no_nor{$ent} = $val;
			} elsif($ent=~/^SD/) {
				#$val = b52utf8($val);
				#$val =~ s#<gaiji .* big5=\'(.+?)\'/>#$1#;
				#$val = "<font face=\"siddam\">$val</font>";
				$val = "<img src=\"sd-gif/$ent.gif\"></img>";
			} else {
				$val = b52utf8($val);
				# 不用 M 碼了
				#if ( $val=~/mojikyo=\'(.+?)\'/) {
				#	my $m=$1;  # 否則用 M 碼
				#	my $des = "";
				#	if ( $val=~/des=\'(.+?)\'/) { 
				#		$des=$1; 
				#		$ent2ZuZiShi{$ent}=$des;
				#	} else { $des = $m; }
				#	#if ($des=~/\[(.*)\]/) { $des = $1; }
				#	$m =~ s/^M//;
				#	$mojikyo{$m}=0;
				#	if (-e "$outDir/fontimg/$m.gif") {
				#		my $href = "javascript:showpic(\"fontimg/$m.gif\")";
				#		if ($des=~/^(.*?)\[(.*)\](.*)$/) {  # 可能是通用詞
				#			$no_nor{$ent} = $1 . "[<a href='$href'>$2</a>]" . $3;
				#		} else {
				#			$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				#		}
				#	} else {
				#		link_to_cb_img($ent, $des);
				#	}
				#} elsif ( $val=~/des=\'(.+?)\'/ ) {
				if ( $val=~/des=\'(.+?)\'/ ) {
					$des = $1;
					link_to_cb_img($ent, $des);
				} else { $no_nor{$ent}=$ent; } # 最後用 CB 碼

				# modified by Ray 2002/2/11
				if ($outEncoding eq "gbk" and $val=~/uni=\'(.+?)\'/) {  # GBK版可以用 unicode
					$uni = pack("H*", $1);
					$uni = toutf8($uni);
					# 不能通用的缺字, 在GBK版仍可用 unicode
					$no_nor{$ent} = $uni;
				}
				
				# 校勘版不用通用字
				#if ($val=~/nor=\'(.+?)\'/) {  # 優先使用通用字
				#	$val=$1; 
				#	$ent2nor{$ent}=$val;
				#} elsif ($outEncoding eq "gbk" and $val=~/uni=\'(.+?)\'/) {  # GBK版如果沒有通用字的話用 unicode
				if ($outEncoding eq "gbk" and $val=~/uni=\'(.+?)\'/) {  # GBK版如果沒有通用字的話用 unicode
					$val = $uni;
					$ent2nor{$ent}=$uni;
				} else { 
					$val = $no_nor{$ent}; 
				}
			}
		} else {
			$_ = b52utf8($_);  # added by Ray 2001/11/27
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
			$no_nor{$ent} = $val;
		}
		$Entities{$ent} = $val;
		#print STDERR "Entity: $ent -> $val\n";
	}
	if ($debug) { print STDERR "~314 end of openent()\n"; }
}
        
        
sub default {
	my $p = shift;
	my $string = shift;
        
	my $parent = lc($p->current_element);

	# added by Ray 2000/5/11 09:13AM T10,n299,p892c09, rdg 裏的梵文轉寫不應出現
	if ($parent eq "rdg") { return; }
  
	# added by Ray 1999/11/23 05:25PM
	# <note type="sk">, <note type="foot"> 的內容不顯示
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		#if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}
        
	if ($debug) { print STDERR "306 string=[$string]\n"; }
	#$string =~ s/^\&(.+);$/&rep($1)/eg;
	if ($bibl == 1){
		$bib .= $string ;
		if ($debug) { print STDERR "310 bib=$bib\n"; }
	}

	if ($in_note) {
		if ($note_type eq "orig" or $note_type eq "mod") {
			$jk{$note_n} .= $string;
			return;  
		}
	}

	# added by Ray 2000/2/17 03:24PM
	if ($parent eq "head") { $headText .= $string; }
	if ($parent eq "title") { $title .= $string; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $string; }

	if ($pass==0) {
		if ($$text_ref =~ /^(.*)<\/font>$/) {
			my $s1 = $1;
			#print LOG "406 text=[$$text_ref]\n";
			if ($string =~ /^<font face=\"CBDia\">(.*)/) {
				$$text_ref = $s1 . $1;
			} elsif ($string =~ /^(\w)$/) {
				$$text_ref = $s1 . $1 . "</font>";
				if ($debug) { print STDERR "320 text=[$$text_ref]\n"; }
			} else { $$text_ref .= $string; }
			#print LOG "413 text=[$$text_ref]\n";
		} else { $$text_ref .= $string; }
	}
}
        
sub init_handler
{       
#	print "CBETA donokono";
	$bibl = 0;
	$close = "";
	@elements=();
	$fileopen = 0;
	$firstLineOfSutra = 1;
	$in_note=0;
	$inLg = 0;
	$inTable=0;
	$juanOpen=0;
	@mulu=();
	$no_nor = 0;
	@no_nor = ();
	$note_type="";
	@note_type=();
	$num = 0;
	$oldof = "";
	@openTags=();
	$pass = 1;
	$title = "";
	$text="";
	$text2 = '';
	$text2_dirty = 0;
	$text_ref = \$text;
	$twoLineModeLine = 0;
}

sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	
	push @pass, $pass;
	push @no_nor, $no_nor;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);
        
	$elementChar="";
	
	### <anchor> ###
	if ($el eq "anchor") {
		if ($att{"id"} =~ /^fx/) {
			$$text_ref .= "<span class='star' type='star'></span>";
		}
	}

	if ($el eq "bibl") {
		if ($debug) { print STDERR "369 head=[$head]\n"; }
		if ($head) {
			$bibl = 1;
		}
	}
        
	### <body> ###
	$pass = 0 if $el eq "body";
       
	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>　　　　" ;
		#$indent = "<br>　　　　";
		$$text_ref .= "<p><span class='byline'>　　　　" ;
		     
		# marked by Ray 1999/11/30 10:26AM
		#$indent = "　　　　";
	}     
       
	### <cell>
	if ($el eq "cell" and $pass==0) {
		$s = "<td";
		if ($att{"rows"} ne '') {
			$s .= ' rowspan="' . $att{"rows"} . '"';
		}
		if ($att{"cols"} ne '') {
			$s .= ' colspan="' . $att{"cols"} . '"';
		}
		$s .= ">";
		push @openTags, $s;
		$$text_ref .= $s;
		$textInCell = 0;
	}
	
	### <corr>
	if ($el eq "corr") {
		$CorrCert = lc($att{"cert"});
		if ($CorrCert ne "" and $CorrCert ne "100") {
			my $sic = myDecode(lc($att{"sic"}));
			$$text_ref .= $sic;
		} else {
			$$text_ref .= "<span class='corr'>";
			if ($in_note and $note_type eq "mod") {
				$jk{$note_n} .= "<span class='corr'>";
			}
		}
	}
       
	### <div1> ###
	if ($el eq "div1"){
		$div1head = "";
		$div2head = "";
		# div1 的 type 屬性可以延續上一個 div1
		if ($att{"type"} ne "") {	$div1Type = lc($att{"type"}); }
		if (div1Type eq "xu"){
			$xu = 1;
			$num = 0;
		} elsif ($div1Type eq "w") {  # added by Ray 2000/5/24 11:09AM
			$$text_ref .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		} elsif ($num == 0 && (div1Type eq "juan" || div1Type eq "jing" || div1Type eq "pin" || div1Type eq "other")) {
			$num = 1;
		}    
	}     
       
	### <div2> ###
	if ($el eq "div2"){
		$div2head='';
		# div2 的 type 屬性可以延續上一個 div2
		if ($att{"type"} ne "") {	$div2Type = lc($att{"type"}); }
		if ($div2Type eq "w") {  # added by Ray 2000/5/24 11:09AM
			$$text_ref .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		}
	}     
       
	### <figure>
	if ($el eq "figure") {
		my $ent = $att{"entity"};
		#my ($x, $y) = imgsize($outDir . '/' . $figure{$ent});
		#$x = int($x/2);
		#$y = int($y/2);
		#$$text_ref .= '<img src="' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
		my $s='<img src="' . $figure{$ent} . "\">";
		if ($pass==0) {
			$$text_ref .= $s;
		}
		if ($in_note) {
			if ($note_type eq "orig" or $note_type eq "mod") {
				$jk{$note_n} .= $s;
			}
		}			
	}

	### <foreign>
	if ($el eq "foreign") {
		if ($att{"place"} =~ /foot/) {
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
			if ($inTable) {
				$$text_ref .=	"<caption align=\"left\">" ;
			} else {
				$$text_ref .=	"<p><b>　　" ;
			}
			$bibl = 1;
			$bib = "";
			$nid++;
			$$text_ref .= "<A NAME=\"n$nid\"></A>";
		}
	}
	      
	if ($head == 1){
		#$bibl = 1 if ($el =~ /^bibl|title|p$/);
		$bibl = 1 if ($el =~ /^(bibl|title)$/);
	}     
       
	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}    
	}     
       
	### <item> ###
	if ($el eq "item"){
		if ($listType eq "ordered") {
			if ($att{"n"} ne '') { $$text_ref .= "<br>" . myDecode($att{'n'}); }
		}
		$itemLang = $att{"lang"};
		if ($itemLang eq '' and $parent eq "list") { $itemLang = $listLang; }
		if ($pass==0) {
			if ($itemLang eq 'sk-sd') { 
				my $s = "<font face=\"siddam\">";
				push @openTags, $s;
				$$text_ref .= $s;
			}
			if ($listType ne "ordered") {
				my $s = "<li>";
				push @openTags, $s;
				$$text_ref .= $s;
			}
		}
	}

	### <juan> ###
	if ($el eq "juan"){
		$xu = 0;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$juanOpen = 1;
			if ($juanNum ne $att{"n"}) {
				#$juanURL = "/$vol$column.htm#$lb";
				$juanText="";
			}
			$num = "001" if ($att{"n"} eq "");
			$num = $att{"n"};
			$juanNum = $num;
			$bibl = 1;
			$bib = "";
			$nid++;
			#$text .= "<A NAME=\"n$nid\"></A>";
		} elsif ($fun eq "close") {
			$juanOpen = 0;
		}
		$$text_ref .= "<p class='juan'>\n";
	}     
       
	### <l> ###
	if ($el eq "l"){
		if ($lgType ne "inline") { 
			$$text_ref .= "<td>";
			$$text_ref .= "　";
		}
		my $rend = $att{"rend"};
		$rend = parseRend($rend);
		if ($rend eq "" and $lgType ne "inline") { $rend = "　"; }
		# 如果偈頌前有 (
		if ($$text_ref =~ /(.*║.*)\($/s) {
			$$text_ref = $1 . $rend . "(";
		} else { $$text_ref .= $rend; }
	}
       
	### <lb> ###
	if ($el eq "lb"){
		$lb = $att{"n"};
		#if ($lb=~/0238a02/ and $vol eq "T32") { $debug=1; }
		if ($debug) { 
			myWatch("<lb n=$lb> pass=$pass text_ref=[" . $$text_ref . "]\n");
			getc; 
		}
		#if ($column eq "") { $column = substr($lb,0,5); }
		if ($twoLineModeLine == 2) {
			$text_ref = \$text2;
			$$text_ref .= "<br>";
		} elsif ($twoLineModeLine == 1) {
			$text_ref = \$text;
			$$text_ref .= "<br>";
		} else {
			$text_ref = \$text;
		}
		printOneLine();
		$$text_ref = '';
		     
		if ($twoLineModeLine==1) {
			$twoLineModeLine=2;
		} elsif ($twoLineMode and $twoLineModeLine==2){
			$twoLineModeLine=1;
		} else {
			$twoLineModeLine=0;
		}
		
		if ($firstLineOfSutra) {
			if (substr($lb,0,5) ne $pb) {
				$pb = substr($lb,0,5);
				newPage($pb);
			}
			$firstLineOfPage = 0; 
			my $num = $sutraNum;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$jingURL = "$vol$column.htm";
			print STDERR "549 jingURL: $jingURL\n";
			$firstLineOfSutra = 0;
		}
		
		if ($twoLineModeLine==2){
			$text2 = "$br<a name=\"$lb\" id=\"$lb\">$indent" . $text2;
		} elsif ($pass==0) {
			$text = "$br<a name=\"$lb\" id=\"$lb\">$indent";
		}
		
		if ($twoLineMode) {
			if ($count_t > 1) {
				$text_ref = \$text2;
			} else {
				$text_ref = \$text;
			}
		} else {
			if ($twoLineModeLine==2) {
				$text_ref = \$text2;
			} else {
				$text_ref = \$text;
			}
		}

		if ($inLg and $lgType ne "inline") { $$text_ref .= "<tr>"; }
		#if ($debug) { getc; }
	}
       
	### <lg> ###
	if ($el eq "lg" ){
		#$$text_ref =~ s/^(.*)(<a name=.+? id=.+?>.*)$/$1<p class='lg'>$2/;
		$lgType = $att{"type"};
		if ($att{"rend"} eq "inline") {
			$lgType = "inline";
		}
		$s='';
		if ($lgType eq "inline") {
			$s = '<p>';
		} else {
			$s = '<p><table border="0" cellspacing="5"><tr>';
			push @openTags, $s;
		}
		$$text_ref .= $s;
		#$text .= "<p class='lg'>";
		$br = "";
		$inLg = 1;
	}

	if ($el eq "mulu" ) {
		my $typeOfMulu = myDecode($att{"type"});
		my $i=@mulu;
		if ($typeOfMulu eq "卷") {
			my $label = myDecode($att{"label"});
			$juanURL = "/$vol$column.htm#$lb";
			my $n = $att{"n"};
			if ($n !~ /\d+/) { die "mulu n 不是數字"; }
			$juanNum = $n;
			if ($label eq '') { $saveJuan{$juanURL}= "第" . cNum($n); }
			else { $saveJuan{$juanURL}= $label; }
		} else {
			my $url = "/$vol$column.htm#$lb";
			my $label = myDecode($att{"label"});
			my $level = int($att{"level"});
			if ($level == 0) { 
				die "level 不能為 0, lb=$lb";
			}
			$mulu[$i][0] = $typeOfMulu;
			$mulu[$i][1] = $level;
			$mulu[$i][2] = $url;
			$mulu[$i][3] = $label;
			$mulu[$i][4] = 0;
			$mulu[$i][5] = int($juanNum);
			$mulu[$i][6] = $juanURL;
			# 如果到了一下層, 記錄上一層有子目錄
			if ($level > $mulu[$i-1][1]) { $mulu[$i-1][4] = 1; }
			if ($level > $mostDeepLevel) { $mostDeepLevel = $level; }
		}
	}
	      
	### <list> ###
	if ($el eq "list"){
		$listLang = $att{"lang"};
		$listType = $att{"type"};
		push @listType, $listType;
		$s="";
		if ($att{"type"} eq "ordered") {
		} else {
			if ($pass==0) {
				$s = "<ul>";
				push @openTags, $s;
				$$text_ref .= $s;
			}
		}
	}

	### <milestone>
	if ($el eq "milestone") {
		$rend = $att{"rend"};
		$$text_ref .= $rend;
	}

	### <note> ###
	if ($el eq "note") {
		$in_note++;
		push @note_type, $note_type; # 把上一層的 note_type 存起來, 因為 <note> 可能包 <note>
		$note_type = $att{"type"};
		$note_n = $att{"n"};
		$close='';
		if ($att{"type"} =~ /^(orig|mod)$/) {
			if (not exists($jk{$note_n})) {
				$jk{$note_n} = '';
				push @jk_n, $note_n;
			} else {
				$jk{$note_n} = '';
			}
		} else {
			# CBETA 加的 note 不顯示
			if ($att{"resp"} =~ /^CBETA/) {
				$pass++;
			}
			if (lc($att{"type"}) eq "inline" or lc($att{"place"}) eq "inline"){
				if ($pass==0) {
					$$text_ref .= "<font size=-1";
					if ($att{"lang"} eq "zh") {
						$$text_ref .= ' face="新細明體"';
						if ($debug) { myWatch("719|$$text_ref\n"); }
					}
					$$text_ref .= ">(";
					$close = ")</font>";
				}
			}
		}
		if ($att{"place"}=~/foot/) {
			$pass++;
		}
		push @close, $close;
	}

	### <p> ###
	if ($el eq "p" and $pass==0){
		$ptype = lc($att{"type"});
		if ($ptype eq "w" or $ptype eq "winline") {
			$$text_ref .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		} else {
			$$text_ref .= "<p>";
		}   
		if ($att{"lang"} eq "sk-sd") { 
			my $s = "<font face=\"siddam\">"; 
			push @openTags, $s;
			$$text_ref .= $s;
		}
		if ($ptype eq "ly" && $head==1) { $flagSource=1; }
	}     
	      
	### <pb> ###
	if ($el eq "pb") {
		if ($debug) {
			print STDERR "<pb n=" . $att{"n"} . "> pass=$pass\n";
		}
		if ($pass==0) {
			$firstLineOfPage = 1;
			$id = $att{"id"};
			$vl = $id;
			$vl =~ s/\./n/;
			$vl =~ s/\..*/_p/;
			$vl =~ s/([A-Za-z])_/$1/;
			$vl =~ s/^t/T/;
			     
			printOneLine();
			$pb = $att{"n"};
			newPage($pb);
		}
	}

       
	### <rdg> ###
	$pass++ if $el eq "rdg";
       
	### <row> ###
	if ($el eq "row" and $pass==0) {
		$s = "<tr>";
		push @openTags, $s;
		$$text_ref .= $s;
	}
	
	### <sg> ###
	if ($el eq "sg") {
		$close='';
		if ($pass==0) {
			$$text_ref .= "<font size=-1>(";
			$close = ")</font>";
		}
		push @close, $close;
	}

	### <t> ###
	if ($el eq "t"){
		if ($att{"place"} eq "foot") {
			$pass++;
		}
		$count_t ++;
		if ($twoLineMode==1 and $count_t > 1) {
			$text2_dirty = 1;
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
		if (defined($att{"rend"})) { 
			$$text_ref .= $att{"rend"};
		} elsif (not $tt_inline and $$text_ref !~ /<br>|<p>$/ and $$text_ref ne '' and $tt_type ne "app") {
			$$text_ref .= "　";
		}
		if ($att{"lang"} eq "sk-sd") { $$text_ref .= "<font face=\"siddam\">"; }
	}


	### <table> ###
	if ($el eq "table") {
		if ($pass==0) {
			$s = '<table border="1" cellspacing="0" cellpadding="5" width="100%">';
			push @openTags, $s;
			unshift @closeTags, "</table>";
			$$text_ref .= $s;
			$inTable++;
		}
	}
	
	### <teiHeader> ###
	$head = 1 if $el eq "teiHeader";  #We are in the header now!
       
	### <term>
	if ($el eq "term") {
		if ($att{"lang"} eq "sk-sd" or $att{"lang"} eq "sk-rj") { 
			$$text_ref .= "<font face=\"siddam\">"; 
		}
	}
	
	### <trailer>
	if ($el eq "trailer") {
		$$text_ref .= "<p class='trailer'>";
	}
	

	### <tt> ###
	if ($el eq "tt") {
		push @br, $br;
		$tt_type = $att{"type"};
		if ($att{"rend"} eq "inline" or $att{"type"} eq "inline") {
			$tt_inline = 1;
		} else {
			$tt_inline=0;
		}
		if (not $tt_inline and $tt_type ne "app" and $att{"rend"} ne "normal") {
			$twoLineMode = 1;
			$twoLineModeLine = 1;
			$count_t = 0;
		} else {
			$twoLineMode = 0;
			$twoLineModeLine = 0;
		}
		if ($att{"rend"} eq "normal") {
			$br="<br>";
			$$text_ref .= "<br>";
		}
	}
} #end start_handler

sub rep1 {
	my $s = shift;
	$s =~ s/&(lac);/&rep($1)/eg;
	$s =~ s/&(M\d{6});/&rep($1)/eg;
	$s =~ s/&(CB\d{5});/&rep($1)/eg;
	$s =~ s/&(CBa\d{4});/&rep($1)/eg;
	$s =~ s/&(CI\d{4});/&rep($1)/eg;
	$s =~ s/&(SD.+);/&rep($1)/eg;
	return $s;
}

sub rep{
	local($x) = $_[0];
	if ($x =~ /#x\w{4}/) {
		return "&$x;";
	}
	if ($debug) { print STDERR "rep($x)="; }
	local $str='';
	local $got=0;

	if (defined($lucida{$x})) {
		$str = "<font face=\"Lucida Sans Unicode\">" . $lucida{$x} . "</font>";
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
		#if (defined($dia{$exp})) {
		if (defined($lucida{$exp})) {
			#$str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
			$str = "<font face=\"Lucida Sans Unicode\">" . $lucida{$exp} . "</font>";
			if ($debug) { print STDERR "689 $str\n"; }
			return $str;
		}
	}   
	if ($debug) { print STDERR "$str\n"; }
	if ($got) {
		return $str;
	} else {
		 die "896 Unknkown entity $x!! no_nor=$no_nor lb=$lb\n";
	}
	if ($debug) { print STDERR "697 $x\n"; }
	return $x;
}       

        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
       
	### </bibl> ###
	if ($el eq "bibl"){ endBibl(); }
	
	# </body>
	if ($el eq "body") {
	  printOneLine();
	}
	
	### </byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:34AM
		#$text .= "</span>" ;
		$$text_ref .= "</span><br>" ;
		$indent = "";
	}     
	
	## </cell> ###
	if ($el eq "cell" and $pass==0) {
		if (not $textInCell) {
			$$text_ref .= "　　";
		}
		$$text_ref .= "</td>";
		pop @openTags;
	}
	
	## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { 
			$$text_ref .= "</span>"; 
			if ($in_note and $note_type eq "mod") {
				$jk{$note_n} .= "</span>";
			}
		}
	}     
	
	### </div> ###
	if ($el =~ /div/i){
		$xu = 0;
		# added by Ray 2000/5/24 11:11AM
		my $s='';
		if ($el eq "div1") {
			$s = $div1Type;
		} elsif ($el eq "div2") {
			$s = $div2Type;
		}
		if ($s eq "w" and $pass==0) { 
			$$text_ref .= "</blockquote>"; 
			$BlockquoteOpen --;
		}
	}     
	
	# </edition>
	if ($el eq "edition") {
		$version =~ /\b(\d+\.\d+)\b/;
		$version = $1;
	}     
       
	# </foreign>
	if ($el eq "foreign") {
	}
	
	$head = 0 if $el eq "teiHeader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";
	      
	### </head> ###
	if ($el eq "head" ) { endHead(); }
	
	### </item> ###
	if ($el eq "item") {
		if ($pass==0) {
			if ($itemLang eq "sk-sd") { 
				$$text_ref .= "</font>"; 
				pop @openTags;
			}
			if ($listType ne "ordered") {
				$$text_ref .= "</li>";
				pop @openTags;
			}
		}
	}

	### </juan> ###
	if ($el eq "juan" ){
		$bibl = 0;
		$bib =~ s/\[[0-9]{2,3}\]//g;
		$bib =~ s/#[0-9]{2,3}#//g;
		$bib = "";
		$$text_ref .= "</p>\n";
		     
		if (lc($att->{"fun"}) eq "open" and $div1Type ne "w") {
			my $num = $juanNum;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
			$juanText =~ s/\[＊\]//g;
		} elsif (lc($att->{"fun"}) eq "close" and $div1Type ne "w") {
			$juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
			$juanText =~ s/\[＊\]//g;
			my $i = cNum($juanNum);
		}    
	}

	### </l> ###
	if ($el eq "l") {
		#$text .= "　" if $el eq "l";
		if ($lgType ne "inline") { $$text_ref .= '</td>'; }
	}
	
	### </lg> ###
	if ($el eq "lg" ){
		#$text .= "</table></p>";
		if ($lgType ne "inline") { 
			$$text_ref .= "</table>"; 
			pop @openTags;
		}
		$br = "";
		$inLg=0;
	}

	### </list> ###
	if ($el eq "list" ){
		#if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
		if ($att->{"type"} eq "ordered") {
		} else {
			if ($pass==0) {
				$$text_ref .= "</ul>";
				pop @openTags;
			}
		}
		$listType = pop @listType;
	}


	## </note> ###
	if ($el eq "note"){
		$close = pop @close;
		if ($close ne "") {
			# 19 History T54, p. 1187c
			#if ($$text_ref =~ /(.*)<\/font>$/) {
			#	$$text_ref = $1 . $close . "</font>";
			#} else { 
				$$text_ref .= $close;
				#print LOG "1140 $$text_ref\n";
			#}
		}
		if ($att->{"type"} eq "orig" or $att->{"type"} eq "mod") {
			if (not exists $span{$note_n}) {
				$$text_ref .= '<span id="n' . $note_n . '" class="note"></span>';
				$span{$note_n}='';
			}
		} elsif ($att->{"resp"} =~ /^CBETA/) {
			$pass--;
		}
		$close = "";
		$in_note--;
		$note_type = pop @note_type;
	}
	      
	## </p> ###
	if ($el eq "p"){
		$indent = "";
		if ($head == 1) {
			$bib =~ s/^\t+//;
			#$ly{$lang} = $bib;
			$source =~ s/^\t+//;
			$ly{$lang} = $source;
			$flagSource = 0;
			$source="";
		}    
		if ($att->{"lang"} eq "sk-sd") { 
			$$text_ref .= "</font>"; 
			pop @openTags;
		}
		if (lc($att->{"type"}) eq "w" and $pass==0) { 
			$$text_ref .= "</blockquote>"; 
			$BlockquoteOpen --;
		}
	}     
       
	### </row> ###
	if ($el eq "row" and $pass==0) {
		$$text_ref .= "</tr>";
		pop @openTags;
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
		$close = "";
	}

	### </t> ###
	if ($el eq "t") {
		if ($att->{"lang"} eq "sk-sd") { 
			$$text_ref .= "</font>"; 
		}
	}

	### </table> ###
	if ($el eq "table" and $pass==0) {
		$$text_ref .= "</table>";
		pop @openTags;
		shift @closeTags;
		$inTable--;
	}
	
	### </term> ###
	if ($el eq "term") {
		if ($att->{"lang"} eq "sk-sd" or $att->{"lang"} eq "sk-rj") { 
			$$text_ref .= "</font>"; 
		}
	}
	
	### </title> ###
	if ($el eq "title"){
		#$bib =~ s/^\t+//;
		#$title = $bib;
		if ($debug) { print STDERR "title=$title\n"; }
	}     
       
	if ($el eq "teiHeader"){
	}     
	
	$lang = "" if ($el eq "p");
       
	## </tei.2> ###
	if ($el eq "tei.2"){
		$$text_ref = myReplace($$text_ref);
       
		$$text_ref =~ s/　$//;
		$$text_ref =~ s/　\)$/)/;
		     
		select OF;
		print myOut($$text_ref);
		$$text_ref = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>▲</a>" if ($prevof ne "");
		#print "</html>\n";
		#close (OF);
		$vl = "";
		$num = 0;
		&endSutra;
	}     
	      
	      
	# </tt>
	if ($el eq "tt"){
		$twoLineMode = 0;
		$text_ref = \$text;
		$br = pop @br;
	}

	$bib = "";
	$no_nor = pop @no_nor;
	$pass=pop @pass;
}

sub endBibl {
	if ($debug) { print STDERR "1000 bib=[$bib] head=[$head] bibl=[$bibl]\n"; }
	if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
		$prevof = "";
		$sutraNum = $2;
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
		$$text_ref = myReplace($$text_ref);
		select OF;
		print myOut($$text_ref);
		$$text_ref = "";
		$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
		$od = sprintf("t%2.2d", $1);
		mkdir($outDir . "\\htmlhelp\\$od", MODE);
       
		$xu = 0;
		$num = 0;
		$bof = $outDir . "\\";
		$bof =~ tr/A-Z/a-z/;
		$fhead = $outDir . sprintf("\\htmlhelp\\$od\\%4.4dh", $2, $3);
		$fhead =~ tr/A-Z/a-z/;
			   
		my $s='';
		# 5,6,7 冊都是 220經
		#if ($vol eq "T06" or $vol eq "T07") {
		#	$s = ">>$outDir/T05n0220.htm";
		#} else {
			$s = ">$outDir/$chm/${vol}" . "N" . $sutraNum . ".htm";
		#}
		if ($debug) { print "1045 title=[$title]\n"; }
		$mtit = $title;
		$mtit =~ s/Taisho Tripitaka, Electronic version, //;
		$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
		$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
		if ($debug) { print "1050 mtit=[$mtit]\n"; }
		$sutraName = $mtit;
		$sutraName =~ s/No\. \d*\w* //;
		$jingLabel = "No. $sutraNum " . filterAnchor($sutraName);
       
		$firstLineOfSutra = 1;
		$firstLineOfPage = 1;
     
		# added by Ray 1999/12/15 10:50AM
		if ($vol eq "T06") { $juanNum = 201; }
		elsif ($vol eq "T07") { $juanNum = 401; }
		else { $juanNum = 1; }
	}    
	$bib =~ s/^\t+//;
	$ebib = $bib;
	&changeSutra;
	$newSutra=1;
	$bibl = 0;
}

sub endHead {
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
		} elsif ($parent eq "corr") {
			$i--;
			$parent = $elements[$i];
		} 
	} # end of while
       
	# </head> 在 <div1> 裏
	if ($parent eq "div1") {
		$headText =~ s/\[\d\d\]//g;  # 去掉校勘符號
		$headText =~ s/\[＊\]//g;
		$div1head = $headText;
		if ($debug) { print STDERR "div1Type=[$div1Type]\n"; }
	}

	# </div2>
	if ($parent eq "div2") {
		$headText =~ s/\[\d\d\]//g;  # 去掉校勘符號
		$headText =~ s/\[＊\]//g;
		$div2head = $headText;
	}

	if ($inTable) {
		$$text_ref .= "</caption>";
	} else {
		$$text_ref .= "</b>";
	}
	$bibl = 0;
	$bib =~ s/\n//g;
	$bib =~ s/\[[0-9]{2,3}\]//g;
	$bib =~ s/#[0-9]{2,3}#//g;
	$bib = "";
	$indent = "" ;
}
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
	
	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	if ($parent eq "app") { return; }

	# <note type="sk"> 的內容不顯示
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		#if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}

	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }
  		     
	$char =~ s/\n//g;

	if ($in_note) {
		if ($note_type eq "orig" or $note_type eq "mod") {
			$jk{$note_n} .= $char;
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
		} elsif ($parent eq "corr") {
			$i--;
			$parent = $elements[$i];
		}   
	}     
	      
	if ($parent eq "head") { $headText .= $char; }
	if ($parent eq "title") { $title .= $char; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $char; }
	if ($parent eq "edition") { $version .= $char; }
        
	if ($bibl == 1) {
		$bib .= $char ;
		if ($debug) { print STDERR "1175 bib=[$bib]\n"; }
	}

	$source .= $char if ($flagSource);
	
	if ($pass>0) { return; }
	
	if ($parent eq "cell" and $char ne '') { $textInCell = 1; }
	
	if ($pass == 0 && $el ne "pb") {
		#if ($$text_ref =~ /(.*)<\/font>$/) {
		#	print LOG "1442 $$text_ref\n";
		#	my $s1 = $1;
		#	if ($char =~ /^([\w\s]+)(.*)$/) { 
		#		$$text_ref = $s1 . $1 . "</font>" . $2; 
		#	} else { $$text_ref .= $char; }
		#	print LOG "1447 $$text_ref\n";
		#} else { $$text_ref .= $char; }
		$$text_ref .= $char;
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
	return 1;
}       
        
        
        
        
        
#-----------------------------------------------------------------------
sub shead{
	print $short;
}       
        
# --------------------------------------------------------------------------
# 切換到新的一經時呼叫
sub changeSutra {
	my $pre = "\t" x $hhcLevel;
	%saveXu=();
	%saveJuan=();
	%savePin=();
	%savePin2=();
	%saveHui=();
	%saveFen=();
	%saveOther=();
	@lines=();
	@tagBeforeLine=();
	$div1head="";
	$div2head="";
	$div1Type="";
	$BlockquoteOpen = 0;
	
	$mtit =~ /No. (\d+\S*) (.*)$/;
	print "\n</div>\n";
	my $heaven1 = $1;
	my $heaven2 = myOut($2);
	$heaven2 =~ s/<.*?>//g;
	#print "<div class=\"root\" id=\"$heaven1\" title=\"", $heaven2, "\">\n";
	print "<div class=\"root\" id=\"$heaven1\" sutra_name=\"", $heaven2, "\">\n";
}

#-----------------------------------------------------------------------
# created by Ray 2000/3/15 06:14PM
sub printJuan {
	my $a=shift;
	my $newCell = 0;
	my $deepest;
  
	$juanNum  = $mulu[$a][5];
  
	if ($juanOld eq "" or $juanNum ne $juanOld) {
		$label = "第" . cNum($juanNum) . "卷";
		$url = $mulu[$a][6];
		$juanOld = $juanNum;
	}
}
        
#-----------------------------------------------------------------------
# 一經結束時呼叫
sub endSutra {
	print STDERR "end sutra\n";
	my $i;
	my $key,$value;
	my $type, $level, $label, $url, $child;
	my $openUL=0;
	my $juanPrinted=0;
}       
        
        
#-----------------------------------------------------------------------
### 全冊經文 ###
sub openOF {
	my $of1 = getof();
	if ($of1 eq $saveof) { return; }
	if ($saveof ne "") { close OF; }
	$saveof = $of1;
	open (OF, ">" . $outDir . "\\$of1");
	print STDERR "\n-> " . $outDir . "\\$of1\n";
	select(OF);

#<style>\@import url(common/cbeta.css);</style>
#<link disabled rel="stylesheet" href="common/cbeta.css">

print << "XXX";
<html>  
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=$outEncoding">
<script LANGUAGE="JAVASCRIPT" SRC="common/search.js">
</script>
XXX

	print '<TITLE>CBETA ', myOut("電子佛典"), "</TITLE>\n";
	# cbeta.css 改成動態載入, 才能由使用者修改
	#print '<link rel="stylesheet" type="text/css" href="common/cbeta.css">',"\n";
	print "</head>\n";

	# 列印前隱藏上下頁的移動鈕
	#print "<BODY onbeforeprint='hide()' onafterprint='show()' onLoad='showAnchor()'>\n";
	print "<BODY onbeforeprint='hide()' onafterprint='show()'>\n";
	$bottomNeeded = 0;
}
        

#-----------------------------------------------------------------------
sub getof {
	my $num = $sutraNum;

	# 如果是某一部的第一經, 上一頁在另一個 CHM 檔
	if    ($num ==  152) { $lastChm = 'AHan.chm::/'; }
	elsif ($num ==  220) { 
	  if ($vol eq "T05") { $lastChm = 'BenYuan.chm::/'; }
	} elsif ($num ==  262) { $lastChm = 'BoRuo.chm::/'; }
	elsif ($num ==  278) { $lastChm = 'FaHua.chm::/'; }
	elsif ($num ==  310) { $lastChm = 'HuaYan.chm::/'; }
	elsif ($num ==  374) { $lastChm = 'BaoJi.chm::/'; }
	elsif ($num ==  397) { $lastChm = 'NiePan.chm::/'; }
	elsif ($num ==  425) { $lastChm = 'DaJi.chm::/'; }
	elsif ($num ==  848) { $lastChm = 'JingJi.chm::/'; }
	elsif ($num == 1421) { $lastChm = 'MiJiao.chm::/'; }
	elsif ($num == 1505) { $lastChm = 'Vinaya.chm::/'; }
	elsif ($num == 1536) { $lastChm = 'JingLun.chm::/'; }
	elsif ($num == 1564) { $lastChm = 'PiTan.chm::/'; }
	elsif ($num == 1579) { $lastChm = 'ZhongGuan.chm::/'; }
	elsif ($num == 1628) { $lastChm = 'Yogacara.chm::/'; }

	return "$chm.htm";
}       
        
        
#-----------------------------------------------------------------------
# Created by Ray 1999/11/30 08:38AM
#-----------------------------------------------------------------------
sub printOneLine {
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	if ($$text_ref eq "") { return; }

	$$text_ref =~ s/　$//;
	$$text_ref =~ s/　\)$/)/;
	$$text_ref = myReplace($$text_ref);

	if ($$text_ref =~ /<a name=.+ id=.+>/) { $$text_ref .= "</a>"; }
	print myOut($$text_ref);
	if (@lines > 1) { shift @lines; }
	if (@tagBeforeLine > 2) { shift @tagBeforeLine; }
	my $s = join('',@openTags);
	push @tagBeforeLine,$s;
	push @lines, $$text_ref;
	$$text_ref = "";
}       

sub myDecode {
	my $s = shift;
	#$s =~ s/M010527/恒/g;
	$s =~ s/(lac)/&rep($1)/eg;
	$s =~ s/(M\d{6})/&rep($1)/eg;
	$s =~ s/(M\d\d\d\d)/&rep($1)/eg;
	$s =~ s/(CB\d{5})/&rep($1)/eg;
	$s =~ s/(CBa\d{4})/&rep($1)/eg;
	$s =~ s/(CI\d{4})/&rep($1)/eg;
	return $s;
}

# created by Ray 2000/2/18 09:08AM
# 過濾缺字的連結標記
sub filterAnchor {
  my $s = shift;
  $s =~ s/<a.*?>(.*?)<\/a>/$1/g;
  return $s;
}

# created by Ray 2000/3/1 10:20AM
sub myReplace {
	my $s = shift;
	if ($debug) { print STDERR "myReplace {$s} => "; }
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	$s =~ s/\[[0-9]{2,3}\]//g;
	$s =~ s/#[0-9]{2,3}#//g;
	
	if ($debug) { print STDERR "{$s}\n"; }
	return $s;
}

sub rep2 {
	my $s=shift;
	if ($s=~ /^<font/) {
		return $s;
	}
	if ($s=~/^[\x80-\xff]/) {
		return $s;
	}
	$s="<font face=\"Lucida Sans Unicode\">$s</font>";
	return $s;
}

sub printPageBottom {
	if (not $bottomNeeded) { return; }
	
	my $nextPage = shift;
	my $s;
	
	if ($inLg) { print "</table>"; }
	
	foreach $s (@closeTags) {
		print $s;
	}
	
	if ((scalar @jk_n)>0) {
		print "<br><br><hr width='33%' align='left'>\n";
	}
	print "<div id='foot'>\n";
	# 不能 sort, 必須按原來順序, 例：T09, no. 262, p. 56c
	#foreach $n (sort keys %jk) {
	foreach $n (@jk_n) {
		$s=$jk{$n};
		$s =~ s/】【unknown】【/】　【/g;
		$s =~ s#【unknown】##g;
		$s=myOut($s . "　");
		$s =~ s#(<font[^>]*?>.*?</font>|[\x80-\xff][\x00-\xff]|.+)#&rep2($1)#eg;
		$s =~ s#(<font face="Lucida Sans Unicode">[^<].*?)</font><font face="Lucida Sans Unicode">#$1#g;
		$n=substr($n,4);
		$n=~s/^0*//;
		if ($n eq '') {
			$n='0';
		}
		print "[$n]$s";
	}
	%jk=();
	@jk_n=();
	print "\n</div><hr>\n";
	print "<DIV id=waterMark style=\"position:absolute;right:0;bottom:0\">\n";
	print "<table align=\"right\"><tr><td>\n";
	my $len = @pages;
	if ($len > 1) {
		my $page = shift @pages;
		print "<a href='$page.htm'><img src='common/up.gif' border=0></a>\n";
		$lastChm = '';
	}

	if ($nextPage ne "") {
		print "<a href='$nextPage.htm'><img src='common/down.gif' border=0></a>\n";
	}  
	print "</td></tr></table>\n";
	print "</DIV>\n";
	print "</div>\n";
	print "<SCRIPT language=JavaScript1.2 src=\"common/water.js\"></SCRIPT>\n";
	print "<SCRIPT language=JavaScript1.2>showAnchor();</SCRIPT>\n";
}

# 讀取部類目錄
sub readBuLei {
	my $cb, $s;
	open I, "c:/cbwork/work/bin/BuLei.txt" or die "open error";
	my @temp;
	while (<I>) {
		chomp;
		#$_ = b52utf8($_);
		@temp = split /##/;
		if ($temp[0] =~ /^$BuLei/) {
			if ($temp[1] =~ /&CB(\d{4});/) {
				$cb = '0' . $1;
				if (not defined($des{$cb})) { die "CB$cb 不存在"; }
				$s = $des{$cb};
				$temp[1] =~ s/&CB\d{4};/$s/g;
			}
			$BuLeiDir{$temp[0]}=$temp[1];
		}
	}
	close I;
	$cchm = substr($BuLeiDir{$BuLei},2);
	delete $BuLeiDir{$BuLei};
}


sub newPage {
	my ($newPage) = @_;
	if ($chm eq $oldChm) { 
		$temp = ''; 
	} else { 
		$temp = "$chm.chm::/"; 
		$oldChm = $chm;
	}
	printPageBottom ( $temp . $vol . $newPage );
	%span=();

	$preColumn = $column;
	$column = $newPage;
	push @pages, "$vol$column";

	if ($newSutra) { openOF(); $newSutra=0; }
  
	print "<!---New Topic--->\n";
	print "<OBJECT type='application/x-oleobject' classid='clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e'>\n";
	print "\t<param name='New HTML file' value='$vol$column.htm'>\n";
	my $sutraNameWithoutAnchor = $sutraName;
	$sutraNameWithoutAnchor =~ s#\[<a.*?>(.*?)</a>\]#\[$1\]#g;
	print "\t<param name='New HTML title' value='$sutraNum ", myOut($sutraNameWithoutAnchor,1), " $column'>\n";
	print "</OBJECT>\n";
	print "<OBJECT type='application/x-oleobject' classid='clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e'>\n";
	print "\t<param name='ALink Name' value='$vol-$column'>\n";
	print "\t<param name='ALink Name' value='$column'>\n";
	print "\t<param name='ALink Name' value='$vol.$sutraNum.$column'>\n";
	print "</OBJECT>\n";
	
	$mtit =~ /No. (\d+\S*) (.*)$/;
	my $heaven1 = $1;
	my $heaven2 = myOut($2);
	$heaven2 =~ s/<.*?>//g;
	#print "<div class=\"root\" id=\"$heaven1\" title=\"", $heaven2, "\">\n";
	print "<div class=\"root\" id=\"$heaven1\" sutra_name=\"", $heaven2, "\">\n";
	
	print "<h2><font face='Arial'>", myOut($mtit), "</font> ";
	$juanNum =~ s/^0{1,2}(\d{1,2})/$1/;
	if ($juanNum ne "") { print "<font face='Arial'>(", myOut("卷"), "$juanNum)</font>" };
	if ($div1head ne "") { 
		if ($div1head =~ /^#\d\d#(.*)/) { $div1head = $1; }
		if ($div1head =~ /(.*分)初$/) { $div1head = $1; }
	
		# "一" = \xa4\x40
		if ($div1head =~ /(.*誦)第\xa4\x40$/) { $div1head = $1; }
		
		if ($div1head =~ /^（.+）(第.+分)$/) { $div1head = $1; }
		
		# "（一）第一分" -> "第一分"
		# \xa1\x5d = "（" ,  \xa1\x5e = "）"
		if ($div1head =~ /^\xa1\x5d.+\xa1\x5e(第.+分)$/) { $div1head = $1; }
		print myOut(" $div1head"); 
	}

	if ($div2head ne "") { 
		print myOut(" $div2head");
	}
	print " <font face='Arial'>$vol, p$column</font></h2><hr>\n";

	# 處理附文跨欄 added by Ray 2000/5/24 08:37AM
	my $s = join('',@lines);
	my $i = $BlockquoteOpen;
	while ($s =~ m#</blockquote#) {
		if ($s =~ /<blockquote/) { $s =~ s/<blockquote//; }
		else { $i++; }
		$s =~ s#</blockquote##;
	}
	while ($i) { 
		$i --;
		if ($s =~ /<blockquote/) {
			$s =~ s/<blockquote//;
			next;
		}
		print "<blockquote class='FuWen'>"; 
	}

	print "<span class='old'>\n";
	print shift @tagBeforeLine;
	@tagBeforeLine='';
	my $i;
	for ($i=1; $i<=2; $i++) {
		my $s = shift @lines;
		$s =~ s#<td>(.*?)</td>#<td><span class='old'>$1</span></td>#g;
		print myOut($s);
	}
	print "</span>";
	$bottomNeeded = 1;
}

sub readGaiji {
	use Win32::ODBC;
	my $cb,$zu,$ent,$mojikyo;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code
		$zu      = $row{"des"};      # 組字式

		next if ($cb =~ /^#/);

		$des{$cb} = b52utf8($zu);
	}
	$db->Close();
	print STDERR "ok\n";
}

sub parseRend {
	my $s = shift;
	if ($s =~ /margin-left:(\d+)/) {
		$s = "　" x $1;
	}
	return $s;
}

sub myOut {
	my $s = shift;
	$s =~ s/&lac;//g;
	#print LOG "1824 $s\n";
	
	my $filterAnchor=0;
	if (scalar @_ != 0) {  # 如果還有第二個參數
		$filterAnchor = shift;
	}
	
	#utf8 pattern
	# 日文字用 &#x????; 不必再跑 rep()
	# <font face="新細明體"> 也要轉換
	#$utf8 = "\&[^;#]+;|\<[^\>]*\>|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]";
	$utf8 = "\&[^;# ]+;|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]";
	#$utf8 = "\&SD\-....;|\&M[0-9]{6};|\&CB[0-9]{5};|\&CBa[0-9]{4};|\&CI[0-9]{4};|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]";
	
	if ($outEncoding eq "utf8") {
		return $s;
	}
	
	my @a=();
	push(@a, $s =~ /$utf8/gs);
	if ($debug) {
		print STDERR "1553 **";
		foreach $c (@a) { 
			print STDERR "[$c]";
		}
		print STDERR " **\n";
	}
	my $c;
	$s = '';
	foreach $c (@a) { 
		if ($c =~ /^\&[^ ]+;$/) {
		#if ($c =~ /^\&(M|CB|CBa|CI|SD\-)\w+;$/) {
			if ($debug) { print STDERR "1556 $c\n"; }
			if ($c =~ /&SD.+;$/) {
				$c =~ s/^\&(.+);$/&rep($1)/eg;
			} else {
				$c =~ s/^\&([^ ]+);$/&rep($1)/eg;
				if ($filterAnchor) {
					$c =~ s#\[<a.*?>(.*?)</a>\]#\[$1\]#g;
				}
				$c = myOut($c);
			}
			if ($debug) { print STDERR "1563 $c\n";  }
		} elsif ($c =~ /^\<[^\>]*\>$/) {
		} elsif ($c ne "\n") {
			$c = myEncode($c);
		}
		$s.=$c; 
	}
	#print LOG "1871 $s\n";
	while ($s =~ /^($big5zi*?)([a-zA-Z0-9 \(\)\-\.',]+)(<font face="Lucida Sans Unicode">)(.*)$/) {
		$s = $1 . $3 . $2 . $4;
	}
	while ($s =~ m#^(.*<font face="Lucida Sans Unicode">[^<]+?)</font><font face="Lucida Sans Unicode">(.*)$#s) {
		$s=$1 . $2;
	}
	$s =~ s#(<font face="Lucida Sans Unicode">[^<]+)(</font>)([a-zA-Z \(\)\[\]\-:',]+)#$1$3$2#g;
	#print LOG "1876 $s\n";  
	return $s;
}

sub myEncode {
	my $c = shift;
	if (exists $utf8out{$c}) { $c =  $utf8out{$c}; }
	else { 
		$len = length($c);
		print STDERR "Error:1711 lb=$lb {$c} not in conversion table\n"; 
		print STDERR "length: $len\n";
		for ($i=0; $i<$len; $i++) {
			$s = unpack("H2",substr($c,$i,1));
			print STDERR "\\x$s";
		}
		exit;
	}
	return $c;
}

sub myWatch {
	my $s = shift;
	my @a=();
	push(@a, $s =~ /$utf8/gs);
	my $c;
	$s = '';
	my $utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
	foreach $c (@a) { 
		if ($c =~ /&SD-\w{4};/) {
		} elsif ($c ne "\n") {
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

# 沒有 M 碼的缺字連到 CB 圖檔
sub link_to_cb_img {
	my $ent = shift;
	my $des = shift;
	if ($ent =~ /^CB(\d\d)/) {
		my $href= $1;
		my $href = "javascript:showpic(\"gaiji-CB/$href/$ent.gif\")";
		if (-e "$outDir/$href") {
			die "缺字圖檔不存在 $outDir/$href";
		}
		if ($des=~/^(.*?)\[(.*)\](.*)$/) {  # 可能是通用詞
			$no_nor{$ent} = $1 . "[<a href='$href'>$2</a>]" . $3;
		} else {
			$no_nor{$ent} = "[<a href='$href'>$des</a>]";
		}
	} else {
		$no_nor{$ent} = "$des";
	}
}

__END__ 
:endofperl
