
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
# hh4.bat
# 產生 cbeta html help version *.hhp, *.hhc, T??n????.htm(各經目錄)
# 使用惠敏法師部類目錄
# written by Ray 2001/2/28 04:16下午
#

### command line parameter ###
$BuLei=shift;
$BuLei = sprintf("%3.3d",$BuLei);

use Getopt::Std; # MacPerl 沒有 Getopt Module
getopts('e:');
$outEncoding = $opt_e;
$outEncoding = lc($outEncoding);
if ($outEncoding eq '') { $outEncoding = 'big5'; }

### 設定值 ###
$buildNumber = 13;
open CFG,"cbeta.cfg" or die "cannot open cbeta.cfg\n";
while (<CFG>) {
	next if (/^#/); #comments
	chomp;
	($key, $val) = split(/=/, $_);
	$cfg{$key}=$val; #store cfg values
	print STDERR "$key\t$cfg{$key}\n";
}
close CFG;

$inDir = "c:/cbwork/xml";
if ($ENV{"COMPUTERNAME"} eq "BSIN-RAY-D") {
	$outDir = "u:/work/hh2001";
} else {
	$outDir = $cfg{"hh_out_root"};
	#$outDir = "u:/work/hh2001";
}

if ($outEncoding eq "gbk") {
	$outDir .= "-gbk";
}

local @chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhongGuan 14Yogacara 15LunJi 16PureLand 17Chan 18History 19Misc 20Apoc 21ZhongGuan 22PureLand 23DunHuang);
local $chm=$chms[$BuLei-1];
local $nextChm=$chms[$BuLei];
mkdir("$outDir/$chm", MODE);
$nid=0;

print STDERR "Initialising....\n";

#utf8 pattern
	$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

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
$utf8out{"\xe2\x97\x8e"} = '';

openVTOC();  # 全冊目錄 T99.hhc

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
my $version;
my $firstLineOfSutra;
my $firstLineOfPage;
my $saveof = "";
my $CorrCert;
my $juanOpen=0;
my $mostDeepLevel="";
my $jingURL="";
my $jingLabel="";
local $author;
local $lastChm='';
local $extent='';
local $text_buffer = '';
local $text_buffer_flag = 0;

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
        
        
$parser->setHandlers (
	Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default
);

readSutraList();
readGaiji();
openent("c:/cbwork/xml/dtd/cbeta.ent");
readBuLei();
openBTOC();  # 全部目錄 *Toc.htm
openHHP();   # HTML Help Project T99.hhp
my $s;
my $olds='';
my $hhcLevel=1;
my $pre;
select VTOC;
$btoc_block_open=0;
$btoc_open_needed=1;
foreach $s (sort keys %BuLeiDir) {
	$hhcLevel = length($s)/3 - 1;
	$oldLevel = length($olds)/3 - 1;
	#print VTOC "<!-- s=$s olds=$olds level=$level oldLevel=$oldLevel -->\n";
	while($hhcLevel < $oldLevel) {
		$pre = "\t" x $oldLevel;
		print VTOC $pre,"</UL>\n"; 
		$oldLevel--;
	}
	if (exists($BuLeiDir{$s."001"})) { # 如果還有下一層
		$pre = "\t" x $hhcLevel;
		select VTOC;
		print VTOC $pre, '<LI><OBJECT type="text/sitemap">', "\n";
		print VTOC $pre, "\t", '<param name="Name" value="', myOut($BuLeiDir{$s}) ,'">',"\n";
		print VTOC $pre,"\t",'<param name="ImageNumber" value="1">',"\n";
		print VTOC $pre,"</OBJECT>\n";
		print VTOC $pre,"<UL>\n";
		select BTOC;
		if ($btoc_block_open) {
			print BTOC "</table>";
			$btoc_block_open--;
		}
		$dirName = $BuLeiDir{$s};
		if ($hhcLevel<3) {
			print BTOC "<h" . ($hhcLevel+1) . ">";
			$dirName =~ s#([\d\-Tab,]{2,})#<font face=\"Times New Roman\">$1</font>#g;
		} else {
			print BTOC "<p>" . myOut("　") x ($hhcLevel-2);
		}
		print myOut($dirName);
		$btoc_open_needed=1;
		if ($hhcLevel<3) {
			print BTOC "</h" . ($hhcLevel+1) . ">\n";
		} else {
			print BTOC "<p>\n";
		}
	} else {
		$BuLeiDir{$s} =~ /^(\d{4}\w?)(.*)$/;
		$sutraNum = $1;
		$sutraName = $2;
		$vol = num2vol($sutraNum);
		$pre = "\t" x $hhcLevel;
		chdir("$inDir/$vol");
		$file = "$inDir/$vol/${vol}n$sutraNum.xml";
		print STDERR "$file\n";
		$parser->parsefile($file);
		if ($btoc_open_needed) {
			print BTOC '<table border="1" cellpadding="6" cellspacing="0" bordercolor="#E1E9CB" style="margin-left: ' . ($hhcLevel-1) . 'em">';
			$btoc_open_needed=0;
			$btoc_block_open++;
		}
		select BTOC;
		#print BTOC "　　" x $hhcLevel;
		print "<tr><td nowrap valign='top'>";
		print "<a href=\"$chm.chm::/$chm/${vol}N$sutraNum.htm\">No. $sutraNum</a>";
		print myOut("<td>$sutraName<td>$extent<td>$author\n");
	}
	$olds = $s;
}
if ($btoc_block_open) {
	print BTOC "</table>";
	$btoc_block_open--;
}

$oldLevel--;
while($oldLevel > 0) {
	$pre = "\t" x $oldLevel;
	print VTOC $pre,"</UL>\n"; 
	$oldLevel--;
}
print VTOC "</UL>\n";
print VTOC "</BODY></HTML>";

print BTOC "<hr></body></html>";

#foreach $m (sort keys %mojikyo) { print HHP "fontimg\\$m.GIF\n"; }
foreach $s (sort keys %ifont) { print HHP "$s\n"; }
print HHP "\n\n[INFOTYPES]\n";

        
#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	if ($file =~ /gif$/) { return; }
	#local($k) = "." . $cfg{"CHAR"};
	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
	#$file =~ s#/#\\#g;
	#$file =~ s/\.\./$cfg{"DIR"}/;
	print STDERR "252 open: $file\n";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chomp;
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
			} elsif($ent=~/^SD/) {
				$val = b52utf8($val);
				$val =~ s#<gaiji .* big5=\'(.+?)\'/>#$1#;
				#$val = "<font face=\"siddam\">$val</font>";
			} else {
				$val = b52utf8($val);
				if ( $val=~/mojikyo=\'(.+?)\'/) {
					my $m=$1;  # 否則用 M 碼
					my $des = "";
					if ( $val=~/des=\'(.+?)\'/) { 
						$des=$1; 
						$ent2ZuZiShi{$ent}=$des;
					} else { $des = $m; }
					if ($des=~/\[(.*)\]/) { $des = $1; }
					$m =~ s/^M//;
					my $href = "/fontimg/$m.gif";
					if (-e "$outDir/$href") {
						$ifont{$href}=0;
					}
					$href = "javascript:showpic(\"$href\")";
					$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				} elsif ( $ent =~ /^CB(\d\d)/ ) {
					my $href = "gaiji-CB/$1/$ent.gif";
					$ifont{$href}=0;
					if ( $val=~/des=\'\[(.+?)\]\'/) { 
						$des=$1; 
						$ent2ZuZiShi{$ent}=$des;
					} else { $des = $ent; }
					$href = "javascript:showpic(\"$href\")";
					$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				} else { $no_nor{$ent}=$ent; } # 最後用 CB 碼

				if ($outEncoding eq "gbk") {
					if ($val=~/nor=\'(.+?)\'/) {  # 優先使用通用字
						$val=$1; 
						$ent2nor{$ent}=$val;
					} elsif ($val=~/uni=\'(.+?)\'/) {  # 沒有通用字的話用 unicode
						$val = pack("H*", $1);
						$val = toutf8($val);
						$ent2nor{$ent}=$val;
					} else { 
						$val = $no_nor{$ent}; 
					}
				} else {
					if ($val=~/nor=\'(.+?)\'/) {  # 優先使用通用字
						$val=$1; 
						$ent2nor{$ent}=$val;
					} else { 
						$val = $no_nor{$ent}; 
					}
				}
			}
		} else {
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
			$val = b52utf8($val);
		}
		$Entities{$ent} = $val;
		if ($debug) { print STDERR "Entity: $ent -> $val\n"; }
  }
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
		if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}     
        
	$string =~ s/^\&(.+);$/&rep($1)/eg;
	if ($bibl == 1){
		$bib .= $string ;
		if ($debug) { print STDERR "bib=$bib\n"; getc;}
	}

	# added by Ray 2000/2/17 03:24PM
	if ($parent eq "head") { $headText .= $string; }
	if ($parent eq "title") { $title .= $string; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $string; }

	if ($text =~ /(.*)<\/font>$/) {
		my $s1 = $1;
		if ($string =~ /^<font face=\"CBDia\">(.*)/) {
			$text = $s1 . $1;
		} elsif ($string =~ /^(\w)$/) {
			$text = $s1 . $1 . "</font>";
		} else {
			$text .= $string if ($pass == 0); 
		}
	} else { 
		$text .= $string if ($pass == 0); 
	}
}       
        
sub init_handler
{       
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$fileopen = 0;
	$num = 0;
	$oldof = "";
	$close = "";
	$date = '';
	$title = "";
	$juanOpen=0;
	@elements=();
	@mulu=();
	$inLg = 0;
	@openTags=();
	$firstLineOfSutra = 1;
}
        
        
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);
        
	$elementChar="";
        
	### <author>
	if ($el eq "author") {
		$author = '';
		$text_buffer_flag = 1;
		$text_buffer = \$author;
	}
		
	### <body> ###
	$pass = 0 if $el eq "body";
       
	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>　　　　" ;
		#$indent = "<br>　　　　";
		$text .= "<p><span class='byline'>　　　　" ;
		     
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
		$text .= $s;
	}
	
	### <corr>
	if ($el eq "corr") {
		$CorrCert = lc($att{"cert"});
		if ($CorrCert ne "" and $CorrCert ne "100") {
			my $sic = myDecode(lc($att{"sic"}));
			$text .= $sic;
		} else {
			$text .= "<span class='corr'>";
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
			$text .= "<blockquote class='FuWen'>";
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
			$text .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		}
	}     
       
	### <extent>
	if ($el eq "extent") {
		$extent = '';
		$text_buffer = \$extent;
		$text_buffer_flag = 1;
	}
	
	### <figure>
	if ($el eq "figure") {
		my $ent = $att{"entity"};
		my ($x, $y) = imgsize($outDir . '/' . $figure{$ent});
		$x = int($x/2);
		$y = int($y/2);
		$text .= '<img src="' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
		#$text .= '<img src="' . $figure{$ent} . '">';
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
			$text .=	"<p><b>　　" ;
			$bibl = 1;
			$bib = "";
			$nid++;
			$text .= "<A NAME=\"n$nid\"></A>";
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
	if ($el eq "item"){
		if ($att{"n"} ne '') { $text .= myDecode($att{'n'}); }
		$itemLang = $att{"lang"};
		if ($itemLang eq '' and $parent eq "list") { $itemLang = $listLang; }
		if ($pass==0) {
			if ($itemLang eq 'sk-sd') { 
				my $s = "<font face=\"siddam\">";
				push @openTags, $s;
				$text .= $s;
			}
			my $s = "<li>";
			push @openTags, $s;
			$text .= $s;
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
		$text .= "<p class='juan'>\n";
	}     
       
	### <l> ###
	if ($el eq "l"){
		$text .= "<td>";
		$text .= "　";
		my $rend = $att{"rend"};
		#$rend =~ s/($pattern)/$utf8out{$1}/g;
		$rend = parseRend($rend);
		if ($rend eq "") { $rend = "　"; }
		# 如果偈頌前有 (
		if ($text =~ /(.*║.*)\($/s) {
			$text = $1 . $rend . "(";
		} else { $text .= $rend; }
	}
       
	### <lb> ###
	if ($el eq "lb"){
		$lb = $att{"n"};
		#if ($lb =~ /1463a05/) { $debug=1; }
		#if ($column eq "") { $column = substr($lb,0,5); }
		     
		if ($firstLineOfSutra) {
			if (substr($lb,0,5) ne $pb) {
				$pb = substr($lb,0,5);
				$column = $pb;
			}
			$firstLineOfPage = 0; 
			my $num = $sutraNum;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$jingURL = "$vol$pb.htm";
			print STDERR "549 jingURL: $jingURL pb=$pb\n";
			$firstLineOfSutra = 0;
		}
		
		$text = "$br<a name=\"$lb\" id=\"$lb\">$indent";

		if ($inLg) { $text .= "<tr>"; }
	}
       
	### <lg> ###
	if ($el eq "lg" ){
		#$text =~ s/^(.*)(<a name=.+? id=.+?>.*)$/$1<p class='lg'>$2/;
		my $s = '<p><table border="0" cellspacing="5"><tr>';
		push @openTags, $s;
		$text .= $s;
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
		if ($pass==0) {
			$s = "<ul>";
			push @openTags, $s;
			$text .= $s;
		}
	}

	### <note> ###
	if ($el eq "note") {
		if(lc($att{"type"}) eq "inline" or lc($att{"place"}) eq "inline"){
			$close='';
	  		if ($pass==0) {
				$text .= "<font size=-1>(";
				$close = ")</font>";
			}
			push @close, $close;
		}
	}

	### <p> ###
	if ($el eq "p"){
		$ptype = lc($att{"type"});
		if ($pass==0) {
			if ($ptype eq "w" or $ptype eq "winline") {
				$text .= "<blockquote class='FuWen'>";
				$indent = "";
				$BlockquoteOpen ++;
			} else {
				$text .= "<p>";
			}   
			if ($att{"lang"} eq "sk-sd") { 
				my $s = "<font face=\"siddam\">"; 
				push @openTags, $s;
				$text .= $s;
			}
		}
		if ($ptype eq "ly") {
			if ($head==1) { $flagSource=1; }
		}
	}     
	      
	### <pb> ###
	if ($el eq "pb") {
		$firstLineOfPage = 1;
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
		     
		$pb = $att{"n"};
		$column = $pb;
	}

       
	### <rdg> ###
	$pass++ if $el eq "rdg";
       
	### <row> ###
	if ($el eq "row" and $pass==0) {
		$s = "<tr>";
		push @openTags, $s;
		$text .= $s;
	}
	
	### <t> ###
	if ($el eq "t") {
		if ($att{"lang"} eq "sk-sd") { $text .= "<font face=\"siddam\">"; }
	}

	### <table> ###
	if ($el eq "table" and $pass==0) {
		$s = '<table border="1" cellspacing="0" cellpadding="5">';
		push @openTags, $s;
		$text .= $s;
	}
	
	### <teiHeader> ###
	$head = 1 if $el eq "teiHeader";  #We are in the header now!
       
	if ($el eq "term") {
		if ($att{"lang"} eq "sk-sd") { $text .= "<font face=\"siddam\">"; }
	}
	
	#end startchar
}       
        
sub rep{
	local($x) = $_[0];
	if ($debug) { print STDERR "rep($x)="; }
	# modified by Ray 1999/10/13 07:16PM
	#return $Entities{$x} if defined($Entities{$x});
	local $str='';
	if ($no_nor) {
		if (defined($no_nor{$x})) { $str = $no_nor{$x}; }
	} else {
		if (defined($Entities{$x})) { $str = $Entities{$x}; }
	}

	if ($str =~ /^\[(.*)\]$/) {
		my $exp = $1;
		if (defined($dia{$exp})) {
			$str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
			if ($debug) { print STDERR "$str\n"; }
			return $str;
		}
	}   
	if ($debug) { print STDERR "$str\n"; }
	return $str;
	die "Unknkown entity $x!!\n";
	if ($debug) { print STDERR "$x\n"; }
	return $x;
}       

        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);

	# </author>
	if ($el eq "author") {
		$text_buffer_flag = 0;
	}
	
	### </bibl> ###
	if ($el eq "bibl"){ endBibl(); }
	
	# </body>
		if ($el eq "body") {
	}
	
	### </byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:34AM
		#$text .= "</span>" ;
		$text .= "</span><br>" ;
		$indent = "";
	}     
	
	## </cell> ###
	if ($el eq "cell" and $pass==0) {
		$text .= "</td>";
		pop @openTags;
	}
	
	## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { $text .= "</span>"; }
	}     
	
	# </date>
	if ($el eq "date") {
		if (lc($parent) eq "publicationstmt") {
			$date =~ s#^.*(..../../..).*$#$1#;
			print STDERR "756 完成日期：$date\n";
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
			$text .= "</blockquote>"; 
			$BlockquoteOpen --;
		}
	}     
	
	# </edition>
	if ($el eq "edition") {
		$version =~ /\b(\d+\.\d+)\b/;
		$version = $1;
	}     
       
	# </extent>
	if ($el eq "extent") {
		$text_buffer_flag = 0;
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
				$text .= "</font>"; 
				pop @openTags;
			}
			$text .= "</li>";
			pop @openTags;
		}
	}

	### </juan> ###
	if ($el eq "juan" ){
		$bibl = 0;
		#$bib =~ s/\[[0-9（[0-9珠\]//g;
		$bib =~ s/\[[0-9]{2,3}\]//g;
		#$bib =~ s/#[0-9][0-9]#//g;
		$bib =~ s/#[0-9]{2,3}#//g;
		$bib = "";
		$text .= "</p>\n";
		     
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
			#print FTOC "<TD><A HREF=\"$chm.chm::$juanURL\">卷第$i</A>\n";
			#print FTOC "<TR>\n";
		}    
	}     
       

	### </l> ###
	if ($el eq "l") {
		#$text .= "　" if $el eq "l";
		$text .= '</td>';
	}
	
	### </lg> ###
	if ($el eq "lg" ){
		#$text .= "</table></p>";
		$text .= "</table>";
		$br = "";
		$inLg=0;
		pop @openTags;
	}

	### </list> ###
	if ($el eq "list" ){
		#if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
		if ($pass==0) {
			$text .= "</ul>";
			pop @openTags;
		}
	}


	## </note> ###
	if ($el eq "note"){
		$close = pop @close;
		if ($close ne "") {
			if ($text =~ /(.*)<\/font>$/) {
				$text = $1 . $close . "</font>";
			} else { 
				$text .= $close 
			}
		}
		$close = "";
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
			$text .= "</font>"; 
			pop @openTags;
		}
		if (lc($att->{"type"}) eq "w" and $pass==0) { 
			$text .= "</blockquote>"; 
			$BlockquoteOpen --;
		}
	}     
       
	### </row> ###
	if ($el eq "row" and $pass==0) {
		$text .= "</tr>";
		pop @openTags;
	}
	
	### </t> ###
	if ($el eq "t") {
		if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}

	### </table> ###
	if ($el eq "table" and $pass==0) {
		$text .= "</table>";
		pop @openTags;
	}
	
	### </term> ###
	if ($el eq "term") {
		if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}
	
	### </title> ###
	if ($el eq "title"){
		#$bib =~ s/^\t+//;
		#$title = $bib;
		if ($debug) { print STDERR "title=$title\n"; getc; }
	}     
       
	if ($el eq "teiHeader"){
#	&head;
	}     
	$lang = "" if ($el eq "p");
       
  ## </tei.2> ###
	if ($el eq "tei.2"){
		$text = myReplace($text);
       
		$text =~ s/　$//;
		$text =~ s/　\)$/)/;
		     
		select OF;
		print myOut($text);
		$text = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>▲</a>" if ($prevof ne "");
		#print "</html>\n";
		#close (OF);
		$vl = "";
		$num = 0;
		&endSutra;
		     
		# marked by Ray 1999/11/9 12:07PM
		#print HHP "\n\n[INFOTYPES]\n";
		#close HHP;
	}     
	      
	      
	$bib = "";
#	print STDERR "$pass\n";
	$no_nor=0;
}       
        
sub endBibl {
	$bibl = 0;
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
		#$text =~ s/\[[0-9（[0-9珠\]//g;
		#$text =~ s/#[0-9][0-9]#//g;
		$text = myReplace($text);
		select OF;
		print myOut($text);
		$text = "";
		$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
		$od = sprintf("t%2.2d", $1);
		mkdir($outDir . "\\htmlhelp\\$od", MODE);
#		$c = "n" if ($c eq "_");
#		$oof = $of;
		#base name for file
       
		$xu = 0;
		#$fileopen = 0;
		$num = 0;
		#$bof = $ourDir . sprintf("\\htmlhelp\\$od\\%4.4d$c", $2, $3);
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
		open (FTOC, $s);
		print STDERR "-> $s\n";
		if ($debug) { print "title=[$title]\n"; }
		$mtit = $title;
		$mtit =~ s/Taisho Tripitaka, Electronic version, //;
		$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
		$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
		if ($debug) { print "mtit=[$mtit]\n"; }
		$sutraName = $mtit;
		$sutraName =~ s/No\. \d*\w* //;
		$jingLabel = "No. $sutraNum " . filterAnchor($sutraName);
		$jingLabel .= " (" . $juansOfSutra{$sutraNum} . "卷)";
       
		printTocHead();
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
	#&changefile;
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

	$text .= "</b>";
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
		if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}     

	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }
  		     
	#$char =~ s/($pattern)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	      
	if ($parent eq "date") {
		my $len = @elements;
		if ($elements[$len-2] eq "publicationStmt") {
			$date .= $char;
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
	if ($text_buffer_flag) { $$text_buffer .= $char; }
        
	$bib .= $char if ($bibl == 1);
	$source .= $char if ($flagSource);
	if ($pass == 0 && $el ne "pb") {
		if ($text =~ /(.*)<\/font>$/) {
			my $s1 = $1;
			if ($char =~ /^([\w\s]+)(.*)$/) { $text = $s1 . $1 . "</font>" . $2; }
			else { $text .= $char; }
		} else { $text .= $char; }
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
	print VTOC $pre, "<LI><OBJECT type=\"text/sitemap\">\n";
	print VTOC $pre, "\t<param name=\"Name\" value=\"";
	print VTOC myOut($jingLabel);
	print VTOC "\">\n";
	print VTOC $pre, "\t<param name=\"Local\" value=\"$chm.chm::/$chm/${vol}N${sutraNum}.htm\">\n";
	print VTOC $pre, "\t<param name=\"ImageNumber\" value=\"1\">\n";
	print VTOC $pre, "</OBJECT>\n";
	print HHP "$chm/${vol}N${sutraNum}.htm\n";
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

	# marked by Ray 2000/3/7 09:09PM
	#$column="";
	#$preColumn="";
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
		#print FTOC "（<A HREF=\"$chm.chm::$url\">$label</A>）\n";
		print FTOC myOut("（$label）\n");
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

	#for $array_ref (@mulu) {
	#  print STDERR "\t [@$array_ref],\n";
	#}

	my $oldFile = select();
	select FTOC;
	$i = int($mostDeepLevel) + 1;
	if ($i > 4) { $i = 4; }
	#if ($vol ne "T06" and $vol ne "T07") {
		print STDERR "jingURL: $jingURL\n";
		print "<A HREF=\"$chm.chm::/$jingURL\">", myOut($jingLabel), "</A>\n";
	#}
	$lastLevel = 0;
	$juanOld = "";
	my $len = @mulu;
	for ($i=0; $i<$len; $i++) {
		$level = $mulu[$i][1];
		$url   = $mulu[$i][2];
		my $label = $mulu[$i][3];
		$label =~ s#\[<a href=.+?>(.+?)</a>\]#\[$1\]#g;
		print "<BR>";
		print myOut("　　") x $level;
		print "<A HREF=\"$chm.chm::$url\">", myOut($label), "</A>\n";
		printJuan($i);
		$lastLevel = $level;
	}
	if ($len>0) { printJuan($len-1); }

	my $tabs = "\t" x $hhcLevel;
	select VTOC;
	print "$tabs<UL>\n";

	### 一經單卷 ###
	my $i = keys(%saveJuan);
	if ($i == 1) {
		my @keys = keys(%saveJuan);
		$value=filterAnchor($sutraName);
		$key = $keys[0];
		print $tabs, "<LI><OBJECT type=\"text/sitemap\">\n";
		print $tabs, "\t<param name=\"Name\" value=\"", myOut($value), "\">\n";
		print $tabs, "\t<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		print $tabs, "</OBJECT>\n";
	}
  
	my $i = @mulu;
	if ($i > 0) {
		print $tabs, "\t<LI><OBJECT type=\"text/sitemap\">\n";
		print $tabs, "\t\t<param name=\"Name\" value=\"", myOut("目錄"), "\">\n";
		print $tabs, "\t\t<param name=\"ImageNumber\" value=\"1\">\n";
		print $tabs, "\t</OBJECT>\n";
		print $tabs, "\t<UL>\n";
    
		for ($j=0; $j<$i; $j++) {
			$level = $mulu[$j][1];
			$url   = $mulu[$j][2];
			$label = $mulu[$j][3];
			$child = $mulu[$j][4];
			$label =~ s#<a href='.*?'>(.*?)</a>#$1#g;  # added by Ray 2000/6/2 11:20AM
			if ($j>0 and $level < $mulu[$j-1][1]) {
				while ($openUL >= $level ) {
					print "\t" x ($openUL) . "</UL><!-- 1267 end of Level $openUL -->\n";
					$openUL --;
				}
			}
			print $tabs, "\t" x ($level+1) . "<LI><OBJECT type=\"text/sitemap\">\n";
			print $tabs, "\t" x ($level+1) . "\t<param name=\"Name\" value=\"";
			print myOut($label);
			print "\">\n";
			print $tabs, "\t" x ($level+1) . "\t<param name=\"Local\" value=\"$chm.chm::$url\">\n";
			if ($child) {
				print $tabs, "\t" x ($level+1) . "\t<param name=\"ImageNumber\" value=\"1\">\n";
			}
			print $tabs, "\t" x ($level+1) . "</OBJECT>\n";
			if ($child) {
				print $tabs, "\t" x ($level) . "<UL><!-- Level $level -->\n";
				$openUL ++;
			}
		}
		while ($openUL > 0) { 
			print $tabs, "\t" x ($openUL) . "</UL><!-- 1284 end of Level $openUL -->\n";
			$openUL --;
		}
		print "$tabs\t</UL><!-- end of Mulu -->\n";
	}
        
	### 一經多卷 ###
	my $i = keys(%saveJuan);
	if ($i>1) {
		print $tabs, "\t<LI><OBJECT type=\"text/sitemap\">\n";
		print $tabs, "\t\t<param name=\"Name\" value=\"", myOut("卷"), "\">\n";
		print $tabs, "\t\t<param name=\"ImageNumber\" value=\"1\">\n";
		print $tabs, "\t</OBJECT>\n";
		print $tabs, "\t<UL>\n";
        
		for $key (sort(keys(%saveJuan))) {
			$value = $saveJuan{$key};
			$value=filterAnchor($value);
			print "$tabs\t\t<LI><OBJECT type=\"text/sitemap\">\n";
			print "$tabs\t\t\t<param name=\"Name\" value=\"", myOut($value), "\">\n";
			print "$tabs\t\t\t<param name=\"Local\" value=\"$chm.chm::$key\">\n";
			print "$tabs\t\t</OBJECT>\n";
		}    
		print "$tabs\t</UL><!-- end of Juan -->\n";
	}
        
	print "$tabs</UL><!-- end of Jing -->\n";
	select $oldFile;
	closeToc();
}       
        
        
#------------------------------------------------------------------------
# 一經目錄
sub printTocHead {
	my $cvol = $vol;
	$cvol =~ s/T//;
	$cvol = cNum($cvol);
        
	my $num = $sutraNum;
	$num =~ s/^0//;
	$num =~ s/^0//;
	$num =~ s/^0//;
  
	#if ($vol eq "T06" or $vol eq "T07") { return; }

	my $oldfh = select();
	select FTOC;
	
print << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>  
<HEAD>  
<script LANGUAGE="JAVASCRIPT" SRC="../common/search.js"></script>
XXX

	print "<TITLE>$sutraNum  ", myOut("目錄--${sutraName}"), "</TITLE>";
	print '<meta http-equiv="Content-Type" content="text/html; charset=', $outEncoding, "\">\n";
	print '<meta name="GENERATOR" content="PERL HH4.bat">',"\n";
	print "</HEAD><BODY>\n";
	print '<H2><IMG align="center" SRC="common/logo1.jpg"> ', myOut("電子大藏經"), '</H2>';
	print "<P>\n";
	print "<HR>\n";
	print "<H3>", myOut("目錄"), '<font face="Times New Roman">Contents</font></H3>',"\n";
	select $oldfh;
}
        
#------------------------------------------------------------------------
# 結束一經目錄
sub closeToc {
	my $nvol = $vol;
	$nvol =~ s/T//;
	$cvol = cNum($nvol);
	$nvol =~ s/^0//;
  
	if ($vol eq "T05" or $vol eq "T06") { return; }
  
	my $oldfh = select();
	select FTOC;

	print "<HR><UL>\n";
	print '<LI>', myOut("大正新脩大藏經第${cvol}冊 $mtit\n");
	print '<LI>V', ${version}, " (", uc($outEncoding), ") HTMLHelp", myOut("版"), ' Build ',$buildNumber, myOut("，完成日期："),$date,"\n";
	print myOut("<LI>本資料庫由中華電子佛典協會（CBETA）依大正新脩大藏經所編輯\n");
	print myOut("<LI>比對資料來源：$ly{'zh'}\n");
	print myOut("<LI>本資料庫可自由免費流通，詳細內容請參考<A HREF=\"../common/cbintr.htm\">【中華電子佛典協會資料庫基本介紹】</A>\n");
	print "</UL>\n";
	print "<UL>\n";
	print "<LI> Taisho Tripitaka Vol. $nvol, ", myOut($mtit), "</A>\n";
	print "<LI> V${version} (", uc($outEncoding), ") HTMLHelp Build ${buildNumber}, Release Date: $date\n";
	print "<LI> Distributor: Chinese Buddhist Electronic Texts Association (CBETA)\n";
	print "<LI> Source material obtained from: $ly{'en'}\n";
	print "<LI> Distributed free of charge. For details, please refer to <A HREF=\"../common/cbintr_e.htm\">The Brief Introduction of CBETA DATABASE</A>\n";
	print "</UL>\n";

	select $oldfh;
}       

#-----------------------------------------------------------------------
### 全冊目錄 ###
sub openVTOC {
	my $s = ">" . $outDir . "\\$chm.hhc";
	open (VTOC, $s);
	print STDERR "open $s\n";

print VTOC << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>  
<HEAD>  
        
<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">
<meta http-equiv="Content-Type" content="text/html; charset=$outEncoding">
<!-- Sitemap 1.0 -->
</HEAD><BODY>
<OBJECT type="text/site properties">
	<param name="ImageType" value="Folder">
</OBJECT>
<UL>
XXX
}       
        
        
        
#-----------------------------------------------------------------------
### HTML Help Project ###
# 不要用 binary TOC, 否則目錄會錯, ex: 瑜伽部 n1579
#
sub openHHP {
	my $oldFile = select();
	my $num = substr($vol,1,2);
	$num = cNum($num);  # cNum() is in sub.pl
	open (HHP, ">" . $outDir . "\\$chm.hhp");
	select(HHP);
print << "XXX";
[OPTIONS]
Compatibility=1.1 or later
Compiled file=$chm.chm
Contents file=${chm}.hhc
Default Window=win1
Default topic=common/default.htm
Display compile progress=Yes
Error log file=log$chm.txt
Full-text search=Yes
XXX

	if ($outEncoding eq "gbk") {
		print "Default Font=,10,134\n";
		print "Language=0x804\n";
	} else {
		print "Default Font=,10,136\n";
		print "Language=0x404 Chinese (Taiwan)\n";
	}

	print "Title=", myOut($cchm), "\n";
      
	print "[WINDOWS]\n";
	
	# 沒有 auto sync
	#print 'win1="', myOut($cchm), '","',$chm,'.hhc",,"common/Default.htm","common/Default.htm","common/toc_t.htm","', myOut("大正藏經目"), '","common/goto.htm","Goto",0x23420,211,0xc304e,,,,,,2,,0', "\n";
	
	# 有 auto sync
	#print 'win1="', myOut($cchm), '","',$chm,'.hhc",,"common/Default.htm","common/Default.htm","common/toc_t.htm","', myOut("大正藏經目"), '","common/goto.htm","Goto",0x23520,211,0xc304e,,,,,,2,,0', "\n";
	print 'win1="', myOut($cchm), '","',$chm,'.hhc",,"common/Default.htm","common/Default.htm","common/goto.htm","Goto",,"Goto",0x23520,211,0x4304e,,,,,,2,,0', "\n";

print << "XXX";
[FILES] 
common/cbeta.css
common/cbintr.htm
common/cbintr_e.htm
common/cbtoc.htm
common/default.htm
common/down.gif
common/fellow.htm
common/logo1.jpg
common/popbackground-yellow1.jpg
common/search.js
common/toc_t.htm
common/up.gif
${chm}Toc.htm
$chm.htm
XXX
  select ($oldFile);
}       

       
        
sub myDecode {
	my $s = shift;
	#$s =~ s/($pattern)/$utf8out{$1}/g;
	#$s =~ s/M010527/恒/g;
	$s =~ s/(M\d{6})/&rep($1)/eg;
	$s =~ s/(M\d\d\d\d)/&rep($1)/eg;
	$s =~ s/(CB\d{5})/&rep($1)/eg;
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
	if ($debug) { print STDERR "{$s}\n"; }
	$s =~ s/\[[0-9]{2,3}\]//g;
	$s =~ s/#[0-9]{2,3}#//g;
	
	if ($debug) { print STDERR "{$s}\n"; getc;}
	return $s;
}

sub printPageBottom {
	if (not $bottomNeeded) { return; }
	
	my $nextPage = shift;
	if ($inLg) { print "</table>"; }
	print "<hr><br><br>";
	print "\n<DIV id=waterMark style=\"position:absolute;right:0;bottom:0\">\n";
	print "<table align=\"right\"><tr><td>\n";
	my $len = @pages;
	if ($len > 1) {
		my $page = shift @pages;
		print "<a href='$page.htm'><img src='common/up.gif' border=0></a>\n";
		$lastChm = '';
	}

	if ($column ne "") {
		print "<a href='$nextPage.htm'><img src='common/down.gif' border=0></a>\n";
	}  
	print "</td></tr></table>\n";
	print "</DIV>\n";
	print "<SCRIPT language=JavaScript1.2 src=\"water.js\"></SCRIPT>\n";
}

# 讀取部類目錄
sub readBuLei {
	my $cb, $s;
	print STDERR "read BuLei.txt\n";
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
			if ($temp[1] =~ /&(M\d{6});/) {
				my $ent = $1;
				if (not defined($Entities{$ent})) { die "$ent 不存在"; }
				$temp[1] =~ s/&M\d{6};/$s/g;
			}
			$BuLeiDir{$temp[0]}=$temp[1];
		}
	}
	close I;
	$cchm = substr($BuLeiDir{$BuLei},2);
	delete $BuLeiDir{$BuLei};
}

#-----------------------------------------------------------------------
### 全部目錄 ###
sub openBTOC {
	my $s = ">" . $outDir . "\\${chm}Toc.htm";
	open (BTOC, $s);
	print STDERR "open $s\n";
	my $name = $cchm;
	$name =~ s#([\d\-Tab,]{2,})#<font face=\"Times New Roman\">$1</font>#g;
	
	my $oldfh = select();
	select BTOC;
	print << "XXX";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=$outEncoding">
XXX

	print '<title>',myOut("$cchm--目錄"), "</title>\n";
	print '<script LANGUAGE="JAVASCRIPT" SRC="common/search.js"></script>';
	print "</head>\n";
	print "<body>\n";
	print '<h1 align="center">', myOut($name), "</h1>\n";
	select($oldfh);
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

sub readSutraList {
	my @a;
	open I, "C:/cbwork/work/bin/sutralst.txt";
	while (<I>) {
		$_ = b52utf8($_);
		@a = split /##/;
		$juansOfSutra{$a[1]}=$a[3];
	}
	close I;
}

sub myOut {
	my $s = shift;
	if ($outEncoding eq "utf8") {
		return $s;
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
				print STDERR "$s\n";
				for ($i=0; $i<$len; $i++) {
					$s = unpack("H2",substr($c,$i,1));
					print STDERR "\\x$s\n";
				}
				exit;
			}
		}
		$s.=$c; 
	}
	return $s;
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
