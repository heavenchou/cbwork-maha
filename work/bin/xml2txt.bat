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


#----------------------------------------------------------------
# xml2txt.bat
# encoding: utf8
#
# 功能:
#      由 cbeta xml 產生純文字版, 含 normal, app, 一經一檔或一卷一檔
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
# Authors:
#  Christian Wittern
#  Ray B. X. Zhou (ray.chou@url.com.tw)
#
# command line options:
#  -a app version, 預設不做 app 移位
#  -b 輸出檔案使用部類目類、中文檔名
#  -c 內碼轉換表路徑
#  -d 產生2碼 id 字數, 例如 <01>
#  -e output encoding
#  -g 去除行首(或段首)資訊的選項(edith modify 2005/1/13, 目前僅用於app版)
#  -h 不要檔頭資訊
#  -i input directory
#  -j normalize for Japanese
#  -k 顯示校勘符號、＊、◎
#  -m 使用 M 碼
#  -n 要執行的經號 例：c:\cbwork\xml\T01>xml2txt -n T01n0001.xml
#  -o output directory
#  -p ++精簡版
#  -s 精簡版
#  -u 一卷一檔, 預設是一經一檔
#  -v 要執行的冊數, 例：c:\cbwork\xml\T01>xml2txt -v T01
#  -x 悉曇字呈現方法: (預設使用轉寫)
#     -x 1 使用 entity &SD-xxxx;
#     -x 2 使用 ◇【◇】 
#  -z 不使用通用字
#
# 修訂記錄
# V 0.1, copied and modified from app1.bat, 2002/7/11 02:39PM by Ray
# V 0.2, -b 改成指定用部類目錄, -u 一卷一檔, 2002/7/19 09:54AM by Ray
# V 0.3, Debug: PDA 版 T55/2155_001.txt 第一卷應一卷一檔, 卻是一經一檔, 2002/10/9 03:56PM by Ray
# V 0.4, 產生 shift-jis 版, 2002/10/17 04:30PM by Ray
# V 0.5, zh=>chi, en=>eng, 2002/10/21 10:36AM by Ray
# V 0.6, <note type="orig"> 的內容不印出, 2002/11/25 03:20PM by Ray
# V 0.7, <note place="foot"> 的內容不印出, 2002/11/25 04:41PM by Ray
# V 0.8, <t place="foot"> 不顯示, 2002/11/25 06:20PM by Ray
# V 0.9, <t place="foot"> 結束時不加全形空白, 2002/11/25 06:47PM by Ray
# V 0.10, <foreign place="foot"> 不顯示, 2002/11/26 06:25PM by Ray
# V 0.11, 如果選用部類目錄就用中文檔名, 2002/11/27 03:13PM by Ray
# V 0.12, $pass==0 才顯示 <figure>, 2002/11/28 05:03PM by Ray
# v 0.13, 2002/12/30 03:13PM by Ray
# v 0.2.0, 加 Option -k 顯示校勘符號, 2003/4/7 05:01PM by Ray
# v 0.2.1, debug ◎沒轉出的問題, 2003/4/9 04:51下午 by Ray
# v 0.2.2, debug <note type="orig" place="text"> 的內容不該顯示, 2003/4/30 11:19上午 by Ray
# v 0.2.3, tei.2 => TEI.2, 2003/4/30 05:43下午 by Ray
# v 0.2.4, debug 2003/5/15 01:43下午 by Ray
# v 0.3.0, ○ 也當做分隔符號, 可以斷行, 2003/5/18 03:59下午 by Ray
# v 0.4.0, 原來 <note type="orig"> 顯示校勘符號, 改成 <note type="mod"> 顯示校勘<lb空白就加空白, 2003/7/18 10:50上午 by Ray
# v 1.3.2, debug 2003/8/4 03:14下午 by Ray
# v 1.4.1, 卍續藏, 2003/8/18 02:25下午 by Ray
# v 1.5.1, 偈頌後如果接 <p type="inline"> 就空兩格, 2003/9/29 05:08下午 by Ray
# v 1.6.1, 附文中的附文還是只多空一格, 2003/10/2 01:00下午 by Ray
# v 1.6.2, 2003/10/3 04:13下午 by Ray
#          X81n1571ap0402c06║　　　　京都古華嚴寺住持(臣)僧　(超揆)　較閱　進
#          X81n1571ap0402c07║　　　　呈
#          X81n1571ap0433a12║　　　　　　唐聖師李成眉賢者。中天竺人也。受般若多羅之後。
#          X81n1571ap0433a13║　長慶間。遊化至大理國。大弘祖道。昭成王。禮為師。為
# v 1.6.3, 附文中的附文還是只多空一格, 2003/10/14 05:56下午 by Ray
#          X81n1571ap0433a11║　　　　東土應化聖賢
# v 1.6.4, 2003/10/27 04:45下午 by Ray
#          X84n1584_p0652a21║　為冊六。行昱和南謹述。
#          X84n1580_p0170c18║微。誰分向背。佛祖來償口業債。問取南泉王老師。人人只喫一莖菜)。　　　○文殊所說般若
#          X84n1580_p0170c19║經。清淨行者。不入涅槃。破戒比丘。不入地獄(此山應頌云。飲
# v 1.6.5  2003/11/11 04:23下午
#          1.normal: T01n0005_p0175c22║　從佛般泥洹。到永興七年二月十一日。凡
#          2.品名一律空2格
#          3.<tt rend="inline"> 的 <t> 與 <t> 之間不空格.
#            T39n1796_p0756b26║同說也◇迦字(咽下)◇佉(上齶)◇哦(頸)◇重伽(頰也謂從
# v 1.6.6  2003/11/14 03:35下午 by Ray
#          T51n2084_p0826a10║
#          T51n2084_p0826a11║
#          T51n2084_p0826a12║　　No. 2084
# v 1.6.7  2003/11/17 11:05上午 by Ray
#          <tt rend="normal">
#          T54n2133Ap1194c17║　【◇】
#          T54n2133Ap1194c18║　作　阿闍梨多　聞　三藏　法師　勝
#          T54n2133Ap1194c19║　K.rtir AAcaarya-bahu-`sruta-tripi.ta [ka] bhadanta-param:
# v 1.7.1  2003/11/18 03:41下午 by Ray
#          </lg> 接 <p type="inline"> 不加空白加句點
#          T26n1523_p0227c27║　心不著名色。於有不起願故。不離寂滅法。
# v 1.8.1  2003/11/19 02:12下午 by Ray
#          悉曇字&SD-E347;以 "□" 呈現	(也許刪掉了, edith modify 2004/11/18)
# v 1.8.2  2003/11/21 01:41下午 by Ray
#          續藏還有 <anchor id="fnX....">
# v 1.9.1  2003/11/24 10:46上午 by Ray
#          X80n1568a, X81n1568b, X81n1571a , X82n1571b 產生的一卷一檔不要 a,b
# v 1.10.1 2003/12/4 09:29上午 by Ray
#          一條校勘拆成多條的 <note type="mod"> 不產生校勘數字符號
# v 1.11.1 2003/12/15 11:31上午 by Ray
#          增加 -x 選項, 悉曇字以 &SD-xxxx; 顯示
# v 1.12.1 2003/12/15 01:34下午 by Ray
#          不看 <juan> 只根據 <milestone> 切卷
# v 1.12.2 2003/12/26 04:54下午 by Ray
#          <t rend=""> 前不空格
#          T54n2133Ap1191a29║&SD-A441;&SD-A440;&SD-E3B0;&SD-E355;&SD-A5B5;&SD-A559;&SD-A557;&SD-E355;&SD-AABC;&SD-A656;&SD-E355;&SD-A5B9;&SD-E1B5;&SD-E355;&SD-A441;&SD-A440;&SD-E444;
#          T54n2133Ap1191a30║紙　落　浮　花　詩
# v 1.12.3 2003/12/29 11:01上午 by Ray
# v 1.13.1 校勘數字的大寫AB要顯示 [01A], [01B], 2003/12/31 02:42下午 by Ray
#          X81n1568_p0094b21║處舉前話。隆曰。[01A]〔冷〕如毛粟。[01B]〔細〕如冰雪)李相公特上。山問。如何是祖師西
# v 1.14.1 悉曇字優先用轉寫, 2004/1/19 09:12上午
# v 1.15.1 檔名前加 T 或 X, 2004/2/3 10:50上午 by Ray
# v 1.16.1 輸出 utf-8 格式, 2004/2/3 02:53下午 by Ray
# v 1.16.2 不用 siddam-utf8.plx 改用 siddam.plx, 2004/2/25 08:22上午 by Ray
# v 1.17.1 <div> 下的 <head> 只依 <div> 的層次空格, 不管 div type
# v 1.18.1 2004/3/26 02:44下午 by Ray
#          -x 1 悉曇字使用 entity &SD-xxxx;
#          -x 2 悉曇字使用 ◇【◇】 
# v 1.18.2 句號移到校勘數字前 2004/3/29 10:27上午 by Ray
# v 1.18.3 <item> 前的空格要加在校勘數字前 2004/3/29 01:57下午 by Ray
# v 1.19.1 悉曇轉寫之間以半形空白區隔 2004/3/29 04:01下午 by Ray
# v 1.20.1 <p type="inline"> 原來加句點改成加空格 2004/4/2 02:37下午 by Ray
# v 1.21.1 <p type="inline"> 如果有 rend 屬性就不加空格, 2004/4/13 09:43上午 by Ray
#          X86n1607_p0582b16║　　　韓愈　字退之官刑部侍郎唐憲宗遣使迎佛骨入
# v 1.21.2 2004/4/22 10:49上午 by Ray
#          ◎＋校勘＋「標記<head>、<byline>、<lg>、<l>、<list>、<item>、<p type="byline">、<title>....」的類型，
#          空格應移到 ◎ 前。
#          原書句號就在校勘數字後, 不能把句號移到校勘數字前 
#          T13n0397_p0014a03║量功德◎[01]。善男子。乃往過去無量無邊阿僧
# v 1.22.1 2004/5/10 04:27下午 by Ray
#          如果 <p place="inline"> 緊跟在 </lg> 之後、沒有空格, 那麼就加二個空格.
# v 1.23.1 2004/5/12 02:44下午 by Ray
#          <lg>
#              type屬性預設為normal
#              if 未指定 rend 屬性
#                  if type="normal" and place!="inline"
#                      預設為 rend="margin-left:1"
#                  end if
#                  if place="inline" and 前面的文字不是空格
#                      加一個空格
#                  end if
#              end if
#              if type="abnormal"
#                  <l> 皆不加空格 (除非<l>有指定rend屬性)
#              else
#                  每行第一個 <l> 不加空格, 其餘 <l> 加空二格 (除非<l>有指定rend屬性)
#              end if
# v 1.23.2 2004/5/13 10:47上午 by Ray
# v 1.23.3 2004/5/14 03:01下午 by Ray
#          X71n1420_p0620c06║　　　　第一位西瞿耶尼洲賓度羅跋羅墮闍尊
#          X71n1420_p0620c07║　　　　者
# v 1.23.4 2004/5/17 10:40上午 by Ray
# v 1.23.5 2004/5/18 05:11下午 by Ray
# v 1.23.6 2004/5/19 02:53下午 by Ray
# v 1.23.7 2004/6/10 10:56上午 by Ray
# v 1.24.1 行中 <list> 按 list 層次空格, 2004/6/15 11:38上午 by Ray
#          X72n1437_p0386c13║　卷第四　　小參
#          <lb ed="X" n="0386c13"/><item id="itemX72p0386c1301">卷第四<list><item id="itemX72p0386c1304">小參</item></list></item>
# v 1.24.2 2004/6/15 03:10下午 by Ray
# v 1.25.1 2004/7/9 01:58下午 by Ray
#	X69n1354_p0352c06║　　　　朝散大夫知太平州軍州兼管內觀農營
#	X69n1354_p0352c07║　　　　田事陳貴謙撰　　　　朝奉郎尚書禮部員外
#	X69n1354_p0352c08║　　　　郎陳　誼書　　　　朝請大夫真寶文閣兩浙
#	X69n1354_p0352c09║　　　　路計度轉運副使趙伸夫篆
# v 1.26.1 2007/06/20  by heaven , 支援蘭札體
# v 1.26.2 2007/11/28  by heaven , T2200 會變成 T220 , 修改 s/220\w/220/ -> s/220[a-zA-Z]/220/
# v 1.26.3 2007/11/29  by heaven , T57 開始有 <rt>..</rt> , 用小括號 ( ) 括起來即可.
# V 1.26.4 2009/02/28  by heaven , 新增嘉興、正史、藏外的支援
# V 1.26.5 2009/03/19  by heaven , 1.<p type="inline"> 在 <lg> 後面只空一格 , 因為 maha:單純的「行中段落 Ｐ or <p> 」，統統空一格好了。
#                                  2.<l> 原本在行首要空一格, 就算是附文, 前面已有空格, 還是要空一格.
# V 1.26.6 2010/07/19  by heaven , 支援冊數二位數以上
# V 1.26.7 2010/11/25  by heaven , <p place="inline"> 預設會空格, 但若有指定 rend , 應該依 rend 的空格數
#-----------------------------------------------------------------------------------------------

# 產生記錄檔, 程式正常結束時刪除, 用來判斷程式是否正確執行完畢
open O, ">c:/cbwork/err.txt";
close O;

use Getopt::Std;
use File::Path;
getopts('ab:c:de:ghi:jkmn:o:psuv:x:z');

$dia_format = 1;
$outEncoding = $opt_e;
$outEncoding = lc($outEncoding);
if ($outEncoding eq '') { $outEncoding = 'big5'; }
print STDERR "Output encoding: $outEncoding\n";

$vol = $opt_v;
$infile = $opt_n;
if ($infile ne '') {
	#$vol = substr($infile,0,3);	# 冊數會超過2碼
	$infile =~ /^(.\d*)/;
	$vol = $1;
}
$vol = uc($vol);
#$ed = substr($vol,0,1);
$ed = $vol;
$ed =~ s/\d+$//;

if ($opt_o eq '') { 
	$opt_o = "c:/release"; 
	mkdir($opt_o, MODE);
	if ($opt_s) {
		$outPath = $opt_o . "/simple"; # 精簡版
	} elsif ($opt_p) {
		$outPath = $opt_o . "/pda"; # PDA 精簡版
	} else {
		if ($opt_a) {
			$outPath = "$opt_o/app";
		} else {
			$outPath = $opt_o . "/normal";
		}
	}
} else {
	$outPath = $opt_o;
}

if ($infile eq '') {
	$outPath_zip=$outPath . "-zip"; 	#edith modify 2005/1/13 xxx-zip 資料夾名稱
	print STDERR "Clear old files $outPath/$vol\n";
	rmtree(["$outPath/$vol"]);
	rmtree(["$outPath_zip/$vol"]);		#edith modify 2005/1/13 順便移除 xxx-zip 資料夾檔案
}

print STDERR "output dir: $outPath\n";
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

if ($opt_p) {
	print STDERR "PDA Version\n";
}

local %bulei = ();
local %sutra2bulei = ();
if ($opt_b) {
	$BuLei=$opt_b;
	$BuLei = sprintf("%3.3d",$BuLei);
	read_bulei();
}

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
require "siddam-utf8.plx";	#edith note:2005/2/22 解決悉曇字有一些轉寫的問題, 例如 %sd2b5 的悉曇字  
require "ranjana-utf8.plx";	#  解決蘭札體有一些轉寫的問題, 例如 %rj2b5 的蘭札字  
#require "siddam.plx";
require "${opt_c}b52utf8.plx";  ## this is needed for handling the big5 entity replacements
require "${opt_c}b5jpiz.plx" if ($opt_j);
require "${opt_c}head.pl";
require "${opt_c}utf8.pl";  #for unicode->utf8 conversion
require "${opt_c}cbetasub.pl";  #for unicode->utf8 conversion
if ($outEncoding eq "big5") {
	require "${opt_c}utf8b5o.plx"; #utf-tabelle fuer big5, jis..
	$line_head_seperator = "║";
} elsif ( $outEncoding eq "gbk"){
	require "${opt_c}utf8gbk.plx";
	#require "${opt_c}headgb.pl";
	#require "utf8.pl";  #for unicode->utf8 conversion
	$line_head_seperator = "║";
} elsif ( $outEncoding eq "sjis"){
	require "${opt_c}utf8sjis.plx";
	#require "${opt_c}headsjis.pl";
	$line_head_seperator = "｜";
} elsif ( $outEncoding eq "utf8"){
	$line_head_seperator = "║";
} else{
	die "unknown output encoding! \nPlease revise the file CBETA.CFG\n";
}
#if (not $opt_k) {
#	$utf8out{"\xe2\x97\x8e"} = ''; # ◎
#}

use XML::Parser;

$bibl = 0;
my %Entities = ();
my %ent2uni = ();
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
local $juanNum;
my $version;
my $pRend;
my $div2Type="";
my $CorrCert;
my $heads;
my $div1Type="";
$divType='';
local $no_nor;
local %ZuZiShi = ();
$lg_flag = 0;
$date;
$first_juan_of_vol=1; # 本冊第1卷
$sd_count = 0;
local $delimiter = "　。．、，！；：,. （）【】「」『』—…《》〈〉“”[]Ｐ◎＠◇□○";  # 間隔字元

sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) { return; }
	#print STDERR "open entity $file\n";
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
			
			#edith modify 2005/3/4
			#若uni_flag是 0 , 表示這個看不到, 不要使用 unicode.
			#若uni_flag是 1 , 表示這個字看的, 請使用 unicode .
			if ($val=~/uniflag=\'(.+?)\'/) {$uni_flag=$1;}
			
			if ($ent =~ /SD-(.{4})/) {		
				my $sd=$1;
				if ($opt_x eq "1") {
					$Entities{$ent} = "&$ent;";
				} elsif ($opt_x eq "2") {
					$Entities{$ent} = "◇";
					#edith modify 2004/11/18:悉曇字&SD-E347;以 "□" 呈現
					if ($sd eq "E347")
					{
						$Entities{$ent} = "□";
					}
				} else {
					if (exists $sd2b5{$sd}) {
						$Entities{$ent}=$sd2b5{$sd};	
						if ($ent =~ /E3BA/ || $ent =~ /E36C/ || $ent =~ /E459/) 
						{
							#watch("370|" . $sd2b5{$sd} . "[$sd]\n");
							#watch("371|$ent → ". $Entities{$ent} . "\n[$_][$vol]\n");
						}
					} elsif (exists $sd2dia{$sd}) {
						$Entities{$ent} = cbdia2smdia($sd2dia{$sd});
					} else {
						$Entities{$ent} = "◇";
						#edith modify 2004/11/18:悉曇字&SD-E347;以 "□" 呈現
						if ($sd eq "E347")
						{
							$Entities{$ent} = "□";
						}
					}					
				}
				next;
			}
			
			if ($ent =~ /RJ-(.{4})/) {		
				my $rj=$1;
				if ($opt_x eq "1") {
					$Entities{$ent} = "&$ent;";
				} elsif ($opt_x eq "2") {
					$Entities{$ent} = "◇";
				} else {
					if (exists $rj2b5{$rj}) {
						$Entities{$ent}=$rj2b5{$rj};	
					} elsif (exists $rj2dia{$rj}) {
						$Entities{$ent} = cbdia2smdia($rj2dia{$rj});
					} else {
						$Entities{$ent} = "◇";
					}					
				}
				next;
			}
			
			if ($val=~/des=\'(.+?)\'/) { 
				$ZuZiShi{$ent} = $1;
			}
			# 輸出 utf8 格式時優先用 unicode $uni_flag
			#edith modify 2005/3/4
			#若uni_flag是 0 , 表示這個看不到, 不要使用 unicode.
			#若uni_flag是 1 , 表示這個字看的, 請使用 unicode .
			#if ($opt_e eq "utf8" and $val=~/uni=\'(.+?)\'/) {
			if ($opt_e eq "utf8" and $val=~/uni=\'(.+?)\'/ and $uni_flag) {
				$val=$1;
				if ($ent =~ /CI\d{4}/) { # added by Ray 2005/7/29 9:37
					@u = split /;/, $val;
					$val = '';
					foreach $u (@u) {
						$u = pack "H4", $u;
						$val .= toutf8($u);
					}
				} else {
					$val=pack "H4", $val;
					$val=toutf8($val);
				}
				$ent2uni{$ent} = $val;
			} elsif (not $opt_z and $val=~/nor=\'(.+?)\'/) { # 優先用通用字
				$val=$1; 
			} elsif (not $opt_m and $val=~/des=\'(.+?)\'/) { # 否則用組字式
				$val=$1; 
			} elsif ($opt_m and $val=~/mojikyo=\'(.+?)\'/) { 
				$val= "&$1;"; 
			} # 用 M 碼
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

	if ($$text_ref=~/　$/) {  
		$siddam=0;
		$ranjana=0;
	}
	#edith modify 2005/2/18、2005/2/21 
	#例一:T07n0220o.xml 悉曇字後面有 &CBxxxxx;→pa後面不空半形空格(CB0042是"缽")
	#<tt place="inline"><t lang="san-sd">&SD-A5B5;</t><t lang="chi">&CB00425;</t></tt>
	#T07n0220_p1110a27║ga伽te帝pa 缽ra囉ga伽te帝
	#例二:T18n0850 連續悉曇字要空半形空格
	#<lb n="0087a14"/><list type="ordered" lang="san-sd"><item n="（一）">&SD-E074;&SD-A5A9;&SD-A5E5;&SD-A67A;&SD-B7A3;&SD-A557;&SD-A564;&SD-A458;&SD-A557;&SD-A440;&SD-A5F1;&SD-A661;&SD-A6B6;&SD-CF55;
	if ($string =~ /SD-(.{4})/) {	
		$siddam_current=1;
		$sd_count ++;
	} else {
		$siddam_current=0;
	}
	if ($string =~ /RJ-(.{4})/) {	
		$ranjana_current=1;
		$rj_count ++;
	} else {
		$ranjana_current=0;
	}
	#除錯
	#if ($1 =~ /E35B/) {$debug2=1;}
	#else {$debug2=0;}
	
	if ($debug2 ) {watch("462|[$string][$sd_count]\n");}	
	$string =~ s/^\&(.+);$/&rep($1)/eg;
	if ($debug2) {watch("464|[$string][$sd_count]\n"); getc;}
	$bib .= $string if ($bibl == 1);

	# modified by Ray 2000/2/14 09:58AM
	#$text .= $string if ($pass == 0  && $inp != 1);
	#$px .= $string if ($pass == 0 && $inp == 1);
	$$text_ref .= $string if ($pass == 0);
}

sub init_handler
{
	$head2=0;
	$app=0;
	@app=();
	$bibl = 0;
	@chars=();
	@chars1=();
	@chars2=();
	$close = "";
	$current_margin_left=0;
	@current_margin_left=();
	@pass=();
	$pass = 1;
	$fileopen = 0;
	$firstLb=1;
	@fuwen=();
	$inFuwen=0;
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
	$listLevel=0;
	$new_row=0;
	@no_nor=();
	$out_buf='';
	$siddam=0;			
	$siddam_current=0;  
	$ranjana=0;			
	$ranjana_current=0;	
	$text='';
	$text2 = '';
	$text3 = '';
	$text2_dirty = 0;
	$text3_dirty = 0;
	$text_ref = \$text;
	$old_tt_lb='';
	$twoLineMode = 0;
	$twoLineModeLine = 0;
	$version = ''; # 先清除, 才不會每部典籍的版本都一樣 2005/2/16 09:33上午 by Ray
}

sub start_handler 
{
	local $p = shift;
	$el = shift;
	local (%att) = @_;

	if ($debug) { 
		watch("496 <$el>");
	}
	
	push @pass, $pass;
	push @app, $app;	
	push @no_nor, $no_nor;
	push @fuwen, $inFuwen;
	push @current_margin_left, $current_margin_left;
	
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
		# T54n2133Ap1194c17 <tt rend="normal">
		if ($att{"rend"} !~ /^(inline|normal)$/) {
			$rend = parseRend($att{"rend"}); 
			$att{"rend"} = $rend;
		}
	} else {
		$rendMarginLeft=0;
		$rendTextIndent=0;
	}
	$current_margin_left += $rendMarginLeft;
	push @saveatt , { %att };

	if ($debug2) {
		#watch("532 <$el> rendMarginLeft=$rendMarginLeft rendTextIndent=$rendTextIndent current_margin-left=$current_margin_left\n");
	}

	if ($opt_d) {
		if (exists $att{'id'} and $el ne 'pb' and $el ne 'anchor' and $el ne 'list') {
			$$text_ref .= "<" . substr($att{'id'}, -2) . '>';
		}
	}

	### <anchor>
	if ($el eq "anchor")  {
		if ($opt_k and $pass==0) {
			if ($att{"id"} =~ /^fx$ed/) {
				$$text_ref .= "[＊]";
			} elsif ($att{"id"} =~ /^fn$ed\d\dp\d{4}[a-z](\d\d[A-Z]?)/) {
				$$text_ref .= "[$1]";
			}
			if ($att{"type"} eq "◎") {
				$$text_ref .= "◎";
			}
		}
	}

	### <app>
	if ($el eq "app")  {
		if ($opt_k) {
			if ($att{"type"} eq "＊") {
				$$text_ref .= "[＊]";
			}
		}
	}
	
	### <body>
	if ($el eq "body")  { $pass = 0 ; }

	### <byline>
	if ($el eq "byline"){
		if ($debug) { 
			watch("549 text=[$text]");
		}
		# 如果不是 PDA 版
		#2004/7/9 01:48下午
		## 如果還沒出現過其他<byline>
		#if (not $opt_p and $parent ne "item" and $indentOfThisLine !~/　　　　/) {
		if (not $opt_p and $parent ne "item") {
			#$text .= "　　　　" ;
			if ($opt_a) { # app 版
				if ($text =~ /$line_head_seperator$/) {
					$indentOfThisLine.="　　　　";
					$indent = "　　　　";
				} else {
					$text = add_space($text,"　" x 4);
				}
			} else {
				$current_margin_left += 4;
				if ($debug) { 
					watch("565 current_margin_left=$current_margin_left\n");
				}
				# X72n1433_p0226b05║　　　　　杭州徑山嗣法曾孫　道盛　撰
				#$text = add_space($text,"　" x $current_margin_left);
				$text = add_space($text,"　" x 4);
				$indent = "　" x $current_margin_left;
			}
			#$text .= "＠";  # byline 接在其他東西的後面，要可以切開
		} elsif ($text !~ /$line_head_seperator$/) {
			$text = add_space($text,"　");
		}
		$inByline=1;
		if ($debug) { 
			watch("244 indentOfThisLine=[$indentOfThisLine]"); 
			watch("571 text=[$text]");
		}
	}
	
	# <bibl>	
	if ($el eq "bibl"){
		
	}
	### <cell> ###
	# added by Ray 2001/6/18
	#edith modify 2005/1/17	每列前面空一格，<cell>與<cell>之間空三格，
	#若是前面或中間欄位沒有表格內容，也要空格。
	#X78n1546_p0165a06║□□戒珠淨土往生傳□□□王古寶珠集□□□新修往生傳
	#X78n1546_p0165a07║□□卷上一僧顯□□□卷第一二僧顯□□□卷上二僧顯
	#X78n1546_p0165a14║□□□□□□□□同八闕公則
	#X78n1546_p0165b24║□□卷中十五善導□□□□□□卷中廿五善導(出于五祖傳)	
	if ($el eq "cell"){
		$cell_n ++;		#edith modify 2005/1/17 主要作用在於判斷是不是第1個cell
		if ($pass==0) {
			#edith modify 2005/1/17: hide舊的作法
			#if (not defined($att{"rend"}) and $text !~ /($line_head_seperator|　|。|）|Ｐ)$/) { 
			#	if ($text =~ /$line_head_seperator$/) {
			#		$rend="　"; 	
			#	} else {
			#		$rend="　　　"; 
			#	}
			#}
			if ($cell_n eq 1) {$rend="　"; }	#edith modify 2005/1/17 每列前面空一格
			else {$rend="　　　";} #<cell>與<cell>之間空三格			
			
			$text .= $rend;			
			
			#edith modify 2005/1/17	每列前面空一格
			#→X78n1546_p0165a06║□□戒珠淨土往生傳□□□王古寶珠集□□□新修往生傳	
			#附文裡的標記(標題除外), 先空1格, 所以此例子剛好空2格(加 <cell> 空1格)
			#if ($rend eq '') {
			#	$text .= "＠";
			#}
			if ($cell_n eq 1) {$text .= "＠"; }
		}
		if ($debug) { print STDERR watch("704 $text"); }
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

	### <div?>
	if ($el =~ /^div(\d*)$/) {
		$div_level = $1;
		if (lc($att{"type"}) eq "w") {
			my $s="";
			if (defined($att{"rend"})) { 
				$s = $att{"rend"}; 
			#} elsif (not $inFuwen) { # 附文中的附文還是只多空一格
			} else {
				$s = "　"; 
			}
			
			# T21n1343
			# lb n="0848c09"/>[12]經</jhead></juan></div1><div1 type="W">
			# lb n="0849c25"/>一卷</p></div1>
			# lb n="0849c26"/><div1 type="W"><div2 type="other"><head>[11]尊勝菩薩所問經譯師傳</head>
			#if ($divType ne "w")	{ # 前一個div不是附文才加空白
			# X81n1571ap0433a11║　　　　東土應化聖賢
			if (not $inFuwen) { # 還不在裏附文才加空白
				$text = add_space($text,$s);
				$current_margin_left ++;
			}
			$indent = $s;
			$indentOfThisLine=$indent;
			if ($debug) {
				watch("471 <$el> indent=[$indent] inFuwen=$inFuwen current_margin_left=$current_margin_left\n");
			}
			$inFuwen=1;
		}
		if (lc($att{"type"}) ne "") { $divType = lc($att{"type"}); }
		if ($debug2) 	{watch("695|<div>{$$text_ref}\n");}
	}

	### <div1>
	if ($el eq "div1"){
		if ($num == 0 && lc($att{"type"}) ne "w") {
			if ($juanNum == 0) {
				if ($vol eq "T06") { $juanNum = 201; }
				elsif ($xml_file eq "T07n0220c.xml") { $juanNum = 401; }
				elsif ($xml_file eq "T07n0220d.xml") { $juanNum = 538; }
				elsif ($xml_file eq "T07n0220e.xml") { $juanNum = 566; }
				elsif ($xml_file eq "T07n0220f.xml") { $juanNum = 574; }
				elsif ($xml_file eq "T07n0220g.xml") { $juanNum = 576; }
				elsif ($xml_file eq "T07n0220h.xml") { $juanNum = 577; }
				elsif ($xml_file eq "T07n0220i.xml") { $juanNum = 578; }
				elsif ($xml_file eq "T07n0220j.xml") { $juanNum = 579; }
				elsif ($xml_file eq "T07n0220k.xml") { $juanNum = 584; }
				elsif ($xml_file eq "T07n0220l.xml") { $juanNum = 589; }
				elsif ($xml_file eq "T07n0220m.xml") { $juanNum = 590; }
				elsif ($xml_file eq "T07n0220n.xml") { $juanNum = 591; }
				elsif ($xml_file eq "T07n0220o.xml") { $juanNum = 593; }
				else { $juanNum = 1; }
			}
			if ($opt_u) {
				&changefile;
			}
			$num = 1;
		}

		if (lc($att{"type"}) eq "xu"){
			$inxu = 1;
		}

		
		if (lc($att{"type"}) ne "") { $div1Type = lc($att{"type"}); }
		if ($div1Type ne "w" and $text =~ /$line_head_seperator$/) { $indentOfThisLine=""; }
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

	### <entry>
	if ($el eq "entry") {
		if ($debug) {
			watch("783|{$current_margin_left}\n");
			watch("784|{$$text_ref}\n");
		}
		if ($$text_ref =~ /║(　)*$/) {
			##edith modify:2005/2/1 xml→normal : <entry>行首不空格
			#例1:X88n1643_p0058b06Wn#豔
			#<lb ed="X" n="0058b06"/><div3 type="note"><entry><form>豔</form>	
			#例2:X88n1643_p0074a10W##佛。五分證即佛。六究竟即佛)<n>四悉<d><p>(四悉檀也。悉者偏也。檀是梵語。此云施也。謂佛以此四法。偏施
			#<lb ed="X" n="0074a10"/>佛。五分證即佛。六究竟即佛</note></p></def></entry><entry place="inline"><form>四悉</form><def><p id="pX88p0074a1014" place="inline"><note place="inline">四悉檀也。悉者偏也。檀是梵語。此云施也。謂佛以此四法。偏施
			#X88n1643_p0074a10║　佛。五分證即佛。六究竟即佛)　　　四悉　(四悉檀也。悉者偏也。檀是梵語。此云施也。謂佛以此四法。偏施

			if (not defined $att{"rend"}) 
			{
				$temp_margin_left=$current_margin_left;		#值暫存至$temp_margin_left
				$current_margin_left=0;
				$temp_flag=1;
			} else {			
				$$text_ref = add_space($$text_ref,"　" x $rendMarginLeft);
			}
			
			if ($temp_flag) ##edith modify:2005/2/1 配合上面的 <entry>行首不空格
			{
				$current_margin_left=$temp_margin_left;		#還原$current_margin_left值
				$temp_flag=0;
			}
			
			if ($debug) {watch("747|{$current_margin_left}\n");}
		} else {
			$$text_ref = add_space($$text_ref,"　　　"); # 行中預設空三格
		}
		if ($debug) {watch("813|{$$text_ref}\n");}
	}

	### <figure>
	if ($el eq "figure") {
		if ($pass==0) {
			$$text_ref .= "【圖】";
		}
	}

	### <foreign>
	if ($el eq "foreign") {
		if ($att{"place"} eq "foot") {
			$pass++;
		}
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
		if ($parent eq "list") { 
			$addSpace=0; # <list>的<head>不空格
		} elsif ($parent eq "lg") { 
			$addSpace=0; # <lg>的<head>不空格
		} elsif ($parent eq "juan") {
			if ($att{"type"} ne "ping") { $addSpace = 0; }
		}
		
		#if ($text !~ /║(　)*$/) { $addSpace=0; }
		if (defined($att{"rend"})) { 
			$text = add_space($text,$rend);
		} elsif ($addSpace) {
			my $sp="　　";
			#edith modify 2004/12/14
			#隔行接續的<head type="no">，要空二格
			if (lc($att{"type"}) eq "no"){$head_start=1;}
			
			if (lc($att{"type"}) ne "no") {
				my $i;
				if ($parent =~ /^div(\d+)$/) {
					$i=$1;
					$i = $i % 3;
					if ($i==0) { $i=3; }
					$i++;
					if ($debug2) {
						watch("782<head> 前空$i格\n");
					}
					$current_margin_left += $i;
					$sp = "　" x $i;					
				}
			}
			if ($opt_a) { # app 版
				# 特例：T01n0023_p0302a23_##乃如是　　[13]大樓炭經三小劫品第十一
				if (not $textInThisLine) {
					$indent .= $sp;
					$indentOfThisLine.=$sp;
				} else {
					$text = add_space($text,$sp); 
				}
			} else {				
				# X79n1560_p0554a16║　　　No. 1560-1
				# X79n1560_p0554a17║　　　 補禪林僧寶傳
				# X84n1580_p0170c18║微。誰分向背。佛祖來償口業債。問取南泉王老師。人人只喫一莖菜)。　　　○文殊所說般若
				# X84n1580_p0170c19║經。清淨行者。不入涅槃。破戒比丘。不入地獄(此山應頌云。飲
				if (not $textInThisLine) {
					$indent .= $sp;
				}
				##edith modify 2004/12/16 <head>沒空格,比照"<head> 只依 <div> 的層次空格"
				##<lb n="1187b26"/><div2 type="other"><mulu type="其他" level="2" label="（悉曇十二韻）"/><head>悉曇</head>
				#$text = add_space($text,$sp);
				$$text_ref = add_space($$text_ref,$sp); 
			}
		}
		
		if ($text !~ /　$/) {
			$text .= "＠";
		}
		
		$heads++;
		$inHead=1;		
	}

	### <jhead>
	if ($el eq "jhead"){
	  $inJhead=1;
	}

	### <item> ###
	if ($el eq "item"){
		$app=1;
		
		if ($pass==0) {
			if ($debug) { watch("400 textInThisLine=[$textInThisLine]"); }
			$item_count ++;
			# 2004/9/8 04:37下午
			if (not defined($att{"rend"})) {
				#if ($$text_ref!~/(　|║|＠)$/) {  # 行中 <item> 之間空一格
				my $r = "　" x $listLevel;				
				if ($first_item) { # 如果 item 出現在 list 的第一行
					# 2004/9/13 04:04下午
					if ($$text_ref =~ /(　|║)$/) {
						$rend = "　";
					} else {
						# 行中開始下一層次的 <list>
						# X63n1244_p0376b01║　　西序　　　一禪堂(首座。西堂。後堂。堂主。書記。知藏。藏主。維那。悅眾。參頭。清眾。香燈。司水)
						$rend = "　" x $listLevel;
					}
				##edith modify 2004/12/16:行中的<item><title>要空1格
				##T55n2145_p0083a18║　略論諸經{{||　}}勝鬘經序(釋慧觀) 
				##<lb n="0083a18"/><item><title>略論諸經</title></item><item><title>勝鬘經序</title><note place="inline">釋慧觀</note></item>
				#} elsif ($$text_ref!~/(　|＠)$/) {  # 行中 <item> 之間空一格
				#(＠)?→代表有@或沒有@, 字串裡有空一格就不會再進來(有@或沒有@都會進來)
				#} elsif ($$text_ref!~/　(＠)?$/) {  # 行中 <item> 之間空一格
				} elsif ($$text_ref!~/　$/) {
					if ($$text_ref =~ /＠$/) { # </list> 之後的行中 <item>
						$rend = "　" x $listLevel;
					} else {
						$rend="　"; # 行中 <item> 之間空一格
					}	
				}
			}
			$text = add_space($text,$rend);
			$indent .= $rend;
			if ($att{"n"} ne '') { $$text_ref .= $att{'n'}; }
		}
		
		$first_item=0;
	}

	# <juan>
	if ($el eq "juan"){
		$app = 1;
		$fun = lc($att{"fun"});
		if ($att{"place"} eq "inline") {
			$text = add_space($text,"　");
		}
		#if ($fun eq "open"){
		#	print STDERR ".";
		#	$juanNum = $att{"n"};
		#	$juanNum = "001" if ($att{"n"} eq "");
		#	# added by Ray 2002/10/9 03:53PM
		#	if (($opt_u and $div1Type ne "w") or (not $fileopen)){
		#		&changefile;
		#	}
		#}
	}

	if ($el eq "l") { start_l(); }
	if ($el eq "lb") { start_lb(); }

	### <lg>  start lg
	if ($el eq "lg") {
		$lgType = $att{"type"};
		$lgRend = $rend;
		$lgPlace = $att{"place"};
		# T46有 <lg rend="inline">
		if ( ($att{"place"} eq "inline") or ($rend eq "inline") ) {
			if ($$text_ref !~ /　$/) {
				$$text_ref = add_space($$text_ref,"　");
			}
		} else {
			# <lb n="0135c15"/><lg type="v4"><l>文殊師利</l><l>導師何故</l><l>眉間白毫</l>
			#if ($lgType eq '') {
			if ($lgType eq '' or $lgType=~/^v\d+$/ or $lgType=~/^note/) {
				if (not defined $att{"rend"}) {
					$current_margin_left++;
					$rendMarginLeft=$current_margin_left;
					$rendTextIndent=1;
				}
			}
			$$text_ref = add_space($$text_ref,"　" x $rendTextIndent);
			$indent .= "　" x $rendTextIndent;
		}
		
		if ($opt_p){
			$$text_ref = myReplace($$text_ref);
			myPrint($$text_ref);
			if ($debug2) {watch("\n1111 <lg>textref=[$$text_ref]\n");getc;}
			$$text_ref="";
			#print "\n[$lb]";	#edith modify 2005/1/13 hide in <lg> 改為
			if ($opt_g)	#$opt_g 去除行首(或段首)資訊的選項
			{
				$$text_ref ="\n\n";
			}
			else
			{
				$$text_ref ="\n[$lb]\n";
			}
						
			$lg_flag = 1;
			$l_count = 0;
		}

		# 偈頌開頭可以切開，所以加分隔字元
		if ($$text_ref !~ /(　|。|）|Ｐ|＠)$/) {
			$$text_ref .= "＠";
		}
		if ($att{"type"} =~ /^note/) {
			$$text_ref .= '(';
		}
		$first_l=1;
		if ($debug) {watch("1124 <lg>textref=[$$text_ref]\n");}
		if ($opt_p){$$text_ref .= "　";}
		if ($debug) {watch("1126 <lg>textref=[$$text_ref]\n");}
	}

	# <list>
	if ($el eq "list") {
		# 2004/6/15 03:02下午
		#$$text_ref .= "＠";
		$listLevel ++;
		# 2004/9/8 04:39下午
		$current_margin_left++;
		#if ($$text_ref =~ /　$/) {
		#	$$text_ref = add_space($$text_ref, "　");
		#} else {
		#	$$text_ref = add_space($$text_ref, "　" x $listLevel);
		#}
		$first_item=1;
	}
	
	### <milestone>
	if ($el eq "milestone") {
		$$text_ref .= $rend;
		$juanNum = sprintf("%3.3d",$att{"n"});
		$juanNum = "001" if ($att{"n"} eq "");
		if ($opt_u) {
			#print STDERR "\n\n1239|$juanNum\n";
			&changefile;
		}
	}

	### <note>
	if ($el eq "note") {
		#if ($opt_k and $att{"type"} eq "orig") {
		if ($opt_k) {
			$temp = $att{"n"};
			if ($att{"type"} eq "orig") {
				$$text_ref .= "<jk $temp>";
				$temp = substr($temp,4);
				$temp =~ s/^0//;
				if ($$text_ref !~ /\[$temp\]$/) {
					#$$text_ref .= "[$temp]";
				}
			} elsif ($att{"type"} eq "mod") {
				if ($temp!~/[a-z]$/) {
					$$text_ref =~ s/<jk $temp>//;
					$out_buf =~ s/<jk $temp>//s;
					$$text_ref .= "<jk $temp>";
				}
			}
		}
		# marked by Ray 2003/7/8 05:22下午
		#$app = 1;
		if ($att{"type"} eq "orig" or $att{"resp"} =~ /^CBETA/ or $att{"place"} =~ /foot/) {
			$pass++;
		}
		
		if ($pass==0) {
			#edith modify 2005/4/27 <note place="interlinear"> (側註) 要比照 <note place="inline"> (夾註) 轉成小括號 
			if (lc($att{"type"}) eq "inline" or lc($att{"place"}) eq "inline" or lc($att{"place"}) eq "interlinear") {
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
		if ($att{"lang"} eq "chi"){
			$lang = "chi";
		} else {
			$lang = "eng";
		}
	}

	### <p> start p
	if ($el eq "p") {
		
		# debug 用的
		#$pidid = $att{"id"};
		#if($pidid eq "pF03p0336b1446")
		#{
		#	my $idid = 1;
		#}
		
		$pType = lc($att{"type"});
		##edith modify 2004/12/21 <tt>悉漢隔行對照，行首不用空格
		#例1:<lb n="0357a11"/><p type="dharani"><tt><t>...
		#會使該行多一個空格 → T21n1287_p0357a13║　&SD-A442; 
		#例2:<lb n="0201b15"/><p>金剛手。</p><p type="dharani" place="inline"><tt><t lang="san-sd">&SD-A656;</t>
		#會使該行多一個空格 → T18n0864Ap0201b15║金剛手。　{{　||}}&SD-A656;　
		##所以$p_start來記錄第一次處理<p>,之後第一次處理<t>就設為$p_start =0;就不會多空一格了
		if ($pType eq "dharani" )
		{
			$p_start =1;
		}
		
		my $type = lc($att{"type"});
		#$inp = 1 if (lc($att{"rend"}) ne "nopunc");
		if ($nopunc) {
			$app=0;
		} elsif ($type =~ /^w?dharani$/) { # 咒語不做 app 處理
			$app=0;
		} else {
			$app=1;
		}
		
		if ($opt_p){
			$$text_ref = myReplace($$text_ref);
			#watch("1254<p>|$$text_ref");
			#getc;
			myPrint($$text_ref);
			$$text_ref="";			
			#print "\n[$lb]\n";	#edith modify 2005/1/13 hide 改為
			if ($opt_g)	#$opt_g 去除行首(或段首)資訊的選項
			{
				$$text_ref ="\n\n";
			}
			else
			{
				$$text_ref ="\n[$lb]\n";
			}
		}
		
		if ($att{"type"} =~ /^head(\d+)$/) {
			my $i=$1;
			$i = $i % 3;
			if ($i==0) { $i=3; }
			$i++;
			my $sp = "　" x $i;
			$text = add_space($text,$sp);
			$indent .= $sp;
			$current_margin_left += $i; # 2005/6/24 14:42 by Ray
		} elsif (lc($att{"place"}) eq "inline") {
			if ($debug) { watch("1296 $text\n"); }
			if (defined($att{"rend"})) {
				# 2004/8/31 04:43下午
				#if ($rendTextIndent==0) {
				# 上層若是 <sp> 就不加空格
				
				#if ($rendTextIndent==0 and $parent ne "sp") {
				#	$rendTextIndent=1;
				#}
				
				# 上面三行有點奇怪, 我就移除了 by heaven , 2010/11/25
				# 否則 F03n0100.xml <div1 type="w"><p id="pF03p0336b1446" place="inline" rend="margin-left:0em"> 就會空二格
				
				$text = add_space($text,"　" x $rendTextIndent);
				$indent .= "　" x $rendMarginLeft;
			} elsif ($text =~ /^(.*)<\/lg>\)?$/s) {
				if ($text !~ /　<\/lg>$/) {
					$text = add_space($text, "　");
				}
			} else {
				#2004/8/31 04:46下午
				#if ($$text_ref ne "" and $$text_ref !~ /($line_head_seperator|　)$/ and $pass == 0) { 
				# 上層若是 <sp> 就不加空格
				#if ($$text_ref ne "" and $$text_ref !~ /($line_head_seperator|　)$/ and $pass == 0 and $parent ne "sp") { 
				# 上層是 <sp> 仍要空格 2004/9/24 03:30下午
				if ($$text_ref ne "" and $$text_ref !~ /($line_head_seperator|　)$/ and $pass == 0) { 
					$$text_ref = add_space($$text_ref,"　");
				}
			}
		} elsif (lc($att{"type"}) eq "winline") {
			if ($text ne "" and $pass == 0) {
				#$text = add_period($text,"。");
				$text = add_space($text,"　");
			}
			if ($rendMarginLeft==0) { $rendMarginLeft = 1; }
			$indent .= "　" x $rendMarginLeft;
		} elsif ($type eq "dharani" or $type eq "idharani") {
			if ($debug)
			{
				print STDERR "1252 magin-left:$rendMarginLeft text-indent:$rendTextIndent\n";
			}
			if ($rendTextIndent >0) {
				$$text_ref = add_space($$text_ref, "　" x $rendTextIndent); 
			} elsif ($text !~ /($line_head_seperator|　|。)$/)	{
				$text = add_space($text, "　");
			}
			if ($debug)
			{
				print STDERR "1226 text{$text}\n";				
			}
		} elsif (lc($att{"type"}) eq "w") {
			# T01n0005_p0175c22║　從佛般泥洹。到永興七年二月十一日。凡
			if ($rendMarginLeft==0) { 
				$rendMarginLeft = 1; 
				$rendTextIndent++;
			}
			if ($text =~ /$line_head_seperator$/) { 
				$indentOfThisLine .= "　" x $rendTextIndent; 
			}
			$indent .= "　" x $rendMarginLeft;
			$current_margin_left += $rendMarginLeft; # added 2004/12/9 02:46下午 by Ray
			$text = add_space($text, "　"); # added 2004/12/9 02:40下午 by Ray
		} else {
			# 20080120 by heaven
			# 有些 <p> 在 <note> 卻有 rend, 這些不可以呈現
			# 例如 X14n0288.xml <lb ed="X" n="0018a05"/>生。從無始來。<note ... type="orig"><p type="訂解總論" rend="margin-left:1em">按種種顛倒。
			# 例如 X25n0488.xml <lb ed="X" n="0327a09"/>....<note n="0327001" resp="Xuzangjing" place="margin-top" type="orig">...<p rend="margin-left:1em">知見。知識之見。非正見也。
			
			my $in_note = 0;		# 先假設不在 note 中
			my $parent = lc($p->current_element);
			if ($parent eq "note") {
				my $att2 = pop(@saveatt);
				my $att = pop(@saveatt);
				my $noteType = $att->{"type"};
				push @saveatt, $att;
				push @saveatt, $att2;
				if ($noteType eq "orig" or $noteType eq "mod") {$in_note = 1;}
			}

			if ($debug2) { watch("1276 <p> text_ref=[$$text_ref]\n"); }
			if ($rendTextIndent==0 and $opt_a) {
				#if ($$tex ne '' and $$text_ref !~ /($line_head_seperator|　|。|　|）|#Ｐ#)$/) { 
				#	$$text_ref .= "#Ｐ#"; 
				#if ($$text_ref ne '' and $$text_ref !~ /($line_head_seperator|　|。|　|）|Ｐ|＠)$/) { 
				if ($$text_ref ne '' and $$text_ref !~ /($line_head_seperator|　|。|\(|　|）|Ｐ|＠)$/) { 
					#$$text_ref .= "Ｐ"; 	#edith modify 2005/1/21 不用主動加圈點記號(。)
				}
			} else {
				$$text_ref = add_space($$text_ref,"　" x $rendTextIndent) if($in_note == 0);
			}
			$indent .= "　" x $rendMarginLeft if($in_note == 0);
		}
		if ($debug2) 
		{
			watch("1292 <p> margin-left:$rendMarginLeft text-indent:$rendTextIndent text_ref=[$$text_ref]\n");
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
		if ($att{"ed"} eq "T") {
			$vl =~ s/\.0220\w\./\.0220\./;
		} else {
			$vl =~ s/\.(1568|1571)\w\./\.$1\./;
		}
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
	}

	### <rdg>
	if ($el eq "rdg") { $pass++ ; }
	
	### <row>
	if ($el eq "row") {
		$new_row=1;
		$cell_n=0;	#edith modify 2005/1/17
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
	
	### <rt>	<rt> 及 </rt> 要用括號括起來
	if ($el eq "rt") {
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
		$sd_count=0;		#edith modify 2005/2/24 新的xml要重新計算悉曇字的數目,以防多半形空格 
		$rj_count=0;		# 新的xml要重新計算蘭札體的數目,以防多半形空格 
	}
	
	### <title>
	if ($el eq "title"){
		
	}
	
	### <trailer>
	if ($el eq "trailer") { $inTrailer=1; }
	
	### <t> ###		
	if ($el eq "t"){
		$sd_count = 0;	#edith modify 2005/2/21 <t>xxx</t> 有幾個悉曇字
		$rj_count = 0;	#  <t>xxx</t> 有幾個蘭札體
		if (defined($att{"rend"})) {
			if ($debug) {
				watch("1137 rend=[" . $att{"rend"} . "]\n");
			}
			$t_rend = $att{"rend"};
		} else {
			#2004/9/30 01:36下午
			#if ($tt_rend=~/^(inline|normal)$/ or $att{"type"}=~/inline|app/) {
			if ($tt_rend=~/^(inline|normal)$/ or $att{"type"}=~/inline|app/ or $tt_place eq "inline") {
				$t_rend = "";
			} else {
				$t_rend = "　";
			}
		}
		$count_t ++;
		if ($count_t > $tt_max) {
			$tt_max=$count_t;
		}
		if ($twoLineMode and $count_t > 2) {
			$text3_dirty = 1;
			$text_ref = \$text3;
		} elsif ($twoLineMode and $count_t > 1) {
			$text2_dirty = 1;
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
		if ($att{"place"} eq "foot") {
			$pass++;
		}
		
		if ($tt_type!~/^(inline|app)$/ and $$text_ref !~ /$line_head_seperator$/ and $$text_ref ne '') {
			##edith modify 2004/12/14 <tt>悉漢隔行對照，行首不用空格
			#$p_start來記錄第一次處理<p>
			#之後第一次處理<t>就設為$p_start =0; 而且不處理$$text_ref .= $t_rend;就不會多空一格
			if ($p_start)
			{
				$p_start=0;
			}		
			else
			{
				$$text_ref .= $t_rend;
			}
		} elsif (defined($att{"rend"})) {
			$$text_ref .= $att{"rend"};
		}
		if ($debug2) { 
			watch("1507 <t> text_ref=[$$text_ref]\n");
			watch("1508 <t> text=[$text]\n");
		}
	}

	### <tt> ###
	if ($el eq "tt") {
		$tt_rend = $att{"rend"};
		$tt_type = $att{"type"};
		$tt_place = $att{"place"};
		if ($lb ne $old_tt_lb) {
			$tt_max=0;
			$old_tt_lb=$lb;
		}
		# 2004/9/30 09:55上午
		#if ($tt_rend=~/^(inline|normal)$/ or $att{"type"}=~/inline|app/) {
		if ($tt_rend=~/^(inline|normal)$/ or $att{"type"}=~/inline|app/ or $tt_place eq "inline") {
			$twoLineMode = 0;
			$twoLineModeLine = 0;
		} else {
			$twoLineMode = 1;
			$twoLineModeLine = 1;
			$count_t = 0;
		}
		if ($debug2) { 
			#watch("1428 <tt>{$p_start}\n"); 
			#watch("1429 <tt> text_ref=[$$text_ref]\n");
			#watch("954 <tt> text=[$text] twoLineMode=$twoLineMode tt_rend=[$tt_rend]\n");
		}
	}

	# <xref>
	if ($el eq "xref") {
		$app = 1;
	}
}

sub rep{
	local($x) = $_[0];
	my $ent=$x;
	
	if ($debug2 ) {watch("1571 rep[$x]\n");	}
	
	if ($no_nor) {  # 如果指定不用通用字
		if (defined($ent2uni{$x})) {
			$x = $ent2uni{$x};
		} elsif (defined($ZuZiShi{$x})) {
			$x=$ZuZiShi{$x};
			if ($debug2 ) {watch("1576 rep[$x]\n");}
		} elsif (substr($x,0,2) eq "SD") {
			$x = "&" . $x . ";";	# SD 碼直接呈現 &SD-xxxx;
		} else {
			die "Unkown entity2 $x!!\n";
		}
	} else {
		if (defined($Entities{$x})) {
			if ($debug2 ) {watch("1584 rep[$x]\n");}
			$x=$Entities{$x};
			if ($debug2 ) {watch("1586 rep[$x]\n");}
		} else {
			die "538 Unknown entity $x!!\n";
		}
	}
	
	# 如果悉曇字以轉寫顯示		
	if (not $opt_x) {
		# 悉曇轉寫之間以半形空白區隔
		#edith modify 2005/2/18、2005/2/21 
		#例一:T07n0220o.xml  悉曇字後面有 &CBxxxxx;→pa後面不空半形空格(CB0042是"缽")
		#<tt place="inline"><t lang="san-sd">&SD-A5B5;</t><t lang="chi">&CB00425;</t></tt>
		#T07n0220_p1110a27║ga伽te帝pa 缽ra囉ga伽te帝
		#例二:T18n0850 連續悉曇字要空半形空格
		#<lb n="0087a14"/><list type="ordered" lang="san-sd"><item n="（一）">&SD-E074;&SD-A5A9;&SD-A5E5;&SD-A67A;&SD-B7A3;&SD-A557;&SD-A564;&SD-A458;&SD-A557;&SD-A440;&SD-A5F1;&SD-A661;&SD-A6B6;&SD-CF55;
		#if ($siddam) {
		if (($siddam && $siddam_current) || ($ranjana && $ranjana_current)) {  
			$x = ' ' . $x;	
			if ($debug2) {watch("1567|[$siddam][$x][$siddam_current]\n");}
		}
		else
		{
			if (($sd_count > 1)||($rj_count > 1)) {$x = ' ' . $x;}	#edith modify 2005/2/21 <t>xxx</t> 有幾個悉曇字
			if ($debug2) {watch("1598|[$sd_count][$x][$siddam_current]\n");}
		}
	}
	if ($ent =~ /SD-(.{4})/) {		
		$siddam=1;
	} else {
		$siddam=0;
	}
	if ($ent =~ /RJ-(.{4})/) {		
		$ranjana=1;
	} else {
		$ranjana=0;
	}
	#watch("1620|[$sd_count][$x][$siddam_current]\n");
	#getc;
	return $x;
}

sub rep_encode {
	local($x) = $_[0];
	if ($no_nor) {  # 如果指定不用通用字
		return myEncode($ZuZiShi{$x}) if defined($ZuZiShi{$x});
		die "Unkown entity $x!!\n";
	} else {
		return myEncode($Entities{$x}) if defined($Entities{$x});
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
		#$bib =~ s/No. 220\w/No. 220/;
		$ebib = $bib;
		if ($ed eq "T") {
			$ebib =~ s/No. 220[a-zA-Z]/No. 220/;	# 原本用 220\w , 但 \w 也可以是 0-1 , 會造成 T2200 變成 T220
		} elsif ($ed eq "X") {
			$ebib =~ s/No. (1568|1571)\w/No. $1/;
		}
		if ($bib =~ /Vol\.\s+$ed?([0-9]+).*?([0-9]+)([A-Za-z])?/){
			$s1=$1;
			$s2=$2;
			$s3=$3;
			$sutraNum1 = sprintf("%4.4d",$s2);
			$c = $s3;
			$sutraNum2 = $sutraNum1 . $c;
			if ($ed eq "T") {
				if ($sutraNum1 eq "0220") {
					$c = '';
				}
			} elsif ($ed eq "X") {
				if ($sutraNum1 =~ /^(0714|1568|1571)$/) {
					$c = '';
				}
			}
			$sutraNum = $sutraNum1 . $c;
			if ($c eq "") {
				$c = "_";
			}

			#print the rest of the line of the old file!
			#$vl = $ed . sprintf("%2.2dn%4.4d%sp", $s1, $s2, $c);
			$vl = $vol . sprintf("n%4.4d%sp", $s2, $c);
			
			#$od = $ed . sprintf("%2.2d", $s1);
			$od = $vol;
			
			if ($opt_b) {
				$b = $sutra2bulei{$sutraNum2};
				watch("929 $b\n");
				$s = "";
				$i = 0;
				$curOutPath = $outPath;
				while ($s ne $b) {
					$s .= substr($b, $i, 3);
					$n = $BuLeiDir{$s};
					$n =~ s/\&([^;]+);/&rep($1)/eg; # 部類中可能有缺字
					$n =~ s/\*/＊/g; # 檔案名稱不允許 *
					$n =~ s/\//／/g; # 檔案名稱不允許 /
					$n =~ s/\?/？/g; # 檔案名稱不允許 ?
					$n = myEncode($n);
					$curOutPath .= "/$n";
					mkdir($curOutPath, MODE);
					$i += 3;
				}
			} else {
				mkdir("$outPath/$od", MODE);
				#if ($opt_d) {
				#	$curOutPath = "$outPath/$od/$sutraNum" . $sutraName{$sutraNum} . '(' . $sutraJuan{"$sutraNum"} . '卷)';
				#} else {
					$curOutPath = "$outPath/$od";
				#}
				mkdir($curOutPath, MODE);
			}

			# modified by Ray 2001/6/13 02:48下午
			#$of = sprintf("$outPath/$od/T%2.2d$c%4.4d.txt", $1, $2);
			#$of = sprintf("$outPath/$od/$ed%2.2dn%4.4d$3.txt", $1, $2);
			$of = sprintf("$outPath/$od/${od}n%4.4d$3.txt", $2);
			#print STDERR "1086 of=$of\n";
			$text =~ s/\n//;
			$text =~ s/\x0d$//;
			#$text =~ s/#Ｐ#$//;
			$text =~ s/Ｐ$//;
			#$text =~ s/#Ｐ#/。/g;
			$text =~ s/Ｐ/。/g;
			myPrint("$text\n");
			
			if ($opt_u) { # 一卷一檔
				$fileopen = 0;
				$num = 0;
				$juanNum = 0;
				if ($opt_b) {
					my $s=$title;
					$s =~ s/\*/＊/g; # 檔案名稱不允許 *
					$s =~ s/\//／/g; # 檔案名稱不允許 /
					$s =~ s/\?/？/g; # 檔案名稱不允許 ?
					$bof = "$curOutPath/$ed$sutraNum1" . myEncode($s);
				} else {
					print STDERR "1690 curOutPath=[$curOutPath] ed=[$ed] sutraNum1=[$sutraNum1] c=[$c]\n";				
					$bof = "$curOutPath/$ed$sutraNum1$c";
				}
				print STDERR "1692 bof=[$bof]\n";				
			} else {
				if ($of ne $old_of) {
					$old_of = $of;
					open (OF, ">$of");
					$fileopen=1;
					select OF;
					print STDERR "1102 > $of\n";
					$printJuanHead = 1;
					$out_buf='';
				} else {
					open (OF, ">>$of");
					$fileopen=1;
					print STDERR "1106 >> $of\n";
					$printJuanHead = 0;
				}
				select(OF);
			}
		}
		$bib =~ s/^\t+//;
	}

	# </byline>
	if ($el eq "byline"){
		$indent = "";
		$inByline=0;
		if ($opt_p) {
		  #print "\n"; #edith modify 2005/1/20 hide 改為
		  $out_buf .="\n";
		}
		$$text_ref .= "＠";
	}
	
	#</cell>
	if ($el eq "cell") {
		
	}
	# </date>
	if ($el eq "date") {
		if ($parent eq "publicationStmt") {
			$date =~ s#^.*(..../../..).*$#$1#;
		}
	}
	
	# </div1>
	if ($el eq "div1"){
		$div_level= 0;
		$inxu = 0;
	}

	# </edition>
	if ($el eq "edition") {
		$version =~ /\b(\d+\.\d+)\b/;
		$version = $1;
		print STDERR "1737 version=$version\n";
	}

	### </foreign>
	if ($el eq "foreign") {
		if ($att->{"place"} eq "foot") {
			$pass--;
		}
	}

	# </head>
	if ($el eq "head"){
		$head_start=0;
		$indent = "" ;
		$inHead=0;
		if ($added == 1){
			$pass--;
			$added = 0;
		}
		if ($opt_p and $pass==0) {
			myPrint("\n");		
		}
	}

	# </item>
	if ($el eq "item") {
	}

	# </jhead>
	if ($el eq "jhead") {
		$inJhead=0;
	}
	
	# </juan>
	if ($el eq "juan") {
		if ($opt_p) {
		  #print "\n";	#edith modify 2005/1/20 hide 改為
		  $out_buf .="\n";
		}
	}
	
	# </list>
	if ($el eq "list") {
		# X84n1584_p0652a21║　為冊六。行昱和南謹述。
		if ($$text_ref !~ /。$/) {
			$$text_ref .= "＠";
		}
		$listLevel--;
	}

	### </l> ###
	#$text .="　" if $el eq "l";
	if ($el eq "l") {
		#if ( (not defined($att->{"rend"})) and ($lgType ne "inline") and $lgRend ne "inline") {
		#	$text .="　";
		#}
		#edith modify 2005/1/13
		$l_=$l_count%2;	##取餘數, 若餘數為0 才須要換行
		if ($opt_p && $lg_flag && !$first_l && !($l_)){ #PDA版 && <lg>開始 && 不是第1個<l> && 餘數為0 
			$$text_ref .="\n";	#edith modify 2005/1/13 
			if ($debug2) {
				print STDERR "\n892|$l_\n";
				getc;
			}
		}
	}

	# added by Ray 2001/6/20
	# </lg>
	if ($el eq "lg") {
		# 偈頌結束不留空白
		# a140 是全形空白
		if ($$text_ref =~ /^(.*)　$/s) { $$text_ref = $1; }
		if ($att->{"type"} =~ /^note/) { $$text_ref .= ')'; }
		$$text_ref .= "</lg>";
		if ($opt_p){ # 精簡版
			$$text_ref = myReplace($$text_ref);
			myPrint($$text_ref);
			$$text_ref="";
			#edith modify 2005/1/13
			$lg_flag = 0; 
			$l_count = 0;
		}
	}
	
	# </note>
	if ($el eq "note") {
		$close = pop @close;
		if ($close ne "") {
			$$text_ref .= $close if ($pass == 0);
			$close = "";
		}
		if ($att->{"resp"} =~ /^CBETA/ or $att->{"place"} =~ /foot/) {
			$pass--;
		}
		if ($debug2) {watch("1785</note>|$$text_ref\n");getc;}
	}

	# </p>
	if ($el eq "p"){
		$p_start=0;
		if ($head == 1) {  # 如果在 <teiheader> 裏
			$bib =~ s/^\t+//;
			$ly{$lang} = $bib;
			$bibl = 0;
		} else {
		  #$text .= "-";
		}
		#$inp = 0;
		
		# modified by Ray 2001/6/20
		if ($px ne "") { $px .= "Ｐ"; }
		#if ($px ne "") { $px .= "#Ｐ#"; }
		
		# added by Ray 1999/12/1 10:22AM
		$indent =~ s/$pRend//;
		
		# modified by Ray 2003/9/8 12:54下午
		if ($$text_ref != /。$/) {
			$$text_ref .= "＠";  # <p> 結束的地方可以切
		}
		
		if ($debug2) {watch("1813</p>|$$text_ref\n");getc;}		
	}

	### </sg>
	if ($el eq "sg"){
		$close = pop @close;
		$$text_ref .= $close;
	}
	
	### </rt>	<rt> 及 </rt> 要用括號括起來
	if ($el eq "rt"){
		$close = pop @close;
		$$text_ref .= $close;
	}

	# </t>
	if ($el eq "t") {			
		$sd_count = 0;
		$rj_count = 0;
		#if ($pass==0 and $tt_type ne "app" and $tt_rend ne "inline") {
		#	$$text_ref .= "　";
		#	if ($debug) { 
		#		watch("1226 </t> text_ref=[$$text_ref]\n");
		#		watch("1371 </t> text2=[$text2]\n");
		#	}
		#}
		if ($att->{"place"} =~ /foot/) {
			$pass--;
		}
		if ($debug2) {
			watch("1883 </t> text_ref=[$$text_ref]\n");
			watch("1885 </t> text=[$text]\n");
			getc;
		}
	}
	
	# </title>
	if ($el eq "title"){
		if ($titleStmt_title) {$head2 = 1; }		
		if ($head == 1) {  # 如果在 <teiheader> 裏
			$bib =~ s/^[\t ]+//;
			$title = $bib;
			#watch("1947 title=[$title]\n");
			$title =~ /.* ([^ ]*)$/;
			$title = $1; 
			#watch("1950 title=[$title]\n");
			$bibl = 0;
			watch("806 title=[$title]\n");
		}
		if ($parent ne "jhead") {
			$$text_ref .= "＠";  # title 結束的地方可以切
		}
		
		if ($titleStmt_title) {$head2 = 0; }
	}

	# </teiheader>
	if ($el eq "teiHeader"){
		#print STDERR "date=[$date]\n";
		if ($printJuanHead and !$opt_h) {
			if ($opt_a) {
				$out_buf='';
				myPrint(head("App普及版","App-Format",$version));
			} else {
				$out_buf='';
				myPrint(head("普及版","Normal-Format",$version));
			}
			#myPrint("\n");
		}
		$text = "";
	}

	$lang = "" if ($el eq "p");
	
	# </tei.2>
	if ($el eq "TEI.2"){
		&out;
		$text = "";
		myPrint("\n");
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
	}

	$bib = "";
	pop(@saveElement);
	$indent = pop(@saveIndent);
	$no_nor = pop(@no_nor);
	$pass = pop @pass;
	$app = pop(@app);
	$inFuwen = pop @fuwen;
	$current_margin_left = pop @current_margin_left;
	if ($debug) {
		watch("1373 </$el> indent=[$indent]\n");
	}
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
		if ($noteType eq "sk" or $noteType eq "foot" or $att->{"place"}=~/foot/) {  
			return;  
		}
	}

	# added by Ray 1999/12/15 10:14AM
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }

	
	# marked by Ray 2001/6/21
	#$char =~ s/($utf8)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	
	if ($char ne '') {
		$new_row = 0;
	}
	
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
		#watch("1965 parent=[$parent] bibl=[$bibl] bib=[$bib]");
		#getc;
	}
	
	# modified by Ray 2000/2/14 10:02AM
	#$text .= $char if ($pass == 0 && $el ne "pb" && $inp != 1);
	#$px .= $char if ($pass == 0 && $el ne "pb" && $inp == 1);
	if ($pass == 0 && $el ne "pb") {
		$$text_ref .= $char;
		$siddam=0;  
		$ranjana=0;  
	}
	if (not $inHead and $char ne '') { $textInThisLine = 1; }
	#if ($debug2) {watch("1988 char|{$char}\n")}
	#if ($debug2) {watch("1989 char|\n$$text_ref\n");getc;}
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

$parser->setHandlers(
	Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default,
	Final => \&final_handler,
	Comment => \&comment,
);

if ($opt_b) { # 部類目錄
	foreach $s (sort keys %sutras) {
		$sutraNum = $s;
		$sutraName = $sutras{$s};
		$vol = num2vol($sutraNum);
		chdir("$opt_i/$vol");
		$xml_file = "${vol}n$sutraNum.xml";
		$file = "$opt_i/$vol/${vol}n$sutraNum.xml";
		print STDERR "$file\n";
		$parser->parsefile($file);
	}
} else {
	foreach $xml_file (sort @allfiles){
		print STDERR "$file\n";
		$parser->parsefile($xml_file);
	}
}
print STDERR "\nDone!!";
unlink "c:/cbwork/err.txt";

sub shead{	
	#watch("\n2018|\n$short");
	myPrint($short);	
}

sub out{
	#如果偈頌之間沒有空白，就插入空白
	# T48n2004_p0243a21║　玄沙大剛(當機不讓父)　長慶少勇(見義不為)　南山[敝/黽]鼻死
	# T85n2845 <lb n="1297b17"/><lg type="inline"><l>常嗟多劫處輪迴</l><l>　末法世中多障難</l><l>　慚愧
	
	$$text_ref =~ s/║<l>/║/sg;  #2004/9/13 09:25上午
	$$text_ref =~ s/<l>　/<l>/sg;
	$$text_ref =~ s/<l>/　/sg;

	# 如果不用 app 移位
	if (not $opt_a) {		
		$$text_ref = myReplace($$text_ref);
		$$text_ref =~ s/(　)+(＠)?\n/\n/sg;
		$$text_ref =~ s/(　)+(＠)?$//;
		
		# added by Ray 2005/7/29 9:05
		# 行末 ◎ 前的空格 要去掉
		# SM: X60n1120_p0410c03_##責。意念不休。忽能言苕[竺-二+帚]。於此大悟。得無礙辨才。<p,1>◎
		# Normal: X60n1120_p0410c03║　責。意念不休。忽能言苕帚。於此大悟。得無礙辨才。　
		
		if (not $opt_k) {
			#$$text_ref =~ s/(　)+(◎)?\n/\n/sg;
			#$$text_ref =~ s/(　)+(◎)?$//;
			
			$$text_ref =~ s/(?:　)+((?:◎)?\n)/$1/sg;
			$$text_ref =~ s/(?:　)+((?:◎)?)$/$1/;
		}
		if ($debug) {
			watch("1312 out(\"$$text_ref\")\n");
		}
		myPrint($$text_ref);
		$$text_ref="";
		return;
	}
	
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
	
	# ◎ 可能在行首, 上一行不必折行, 所以能在這裏取代掉, 等 myPrint() 再去掉 2001/6/26
	#$$text_ref =~ s/◎//g;  # added by Ray 2001/6/22
	
	# 取出行首資訊
	# added by Ray 1999/12/1 11:52AM
	#$$text_ref =~ /^(.*?)\xf9\xf8(.*)$/s;  					# xf9f8 是║
	$$text_ref =~ /^(.*?)\Q$line_head_seperator\E(.*)$/s;
	$lineHead = $1;
	my $rend = $indentOfThisLine;
	$$text_ref = $2;
	
	# 2006/6/30 13:51 marked by Ray
	## added by Ray 2001/12/10
	## ◎ 不在行首的話不當做分隔符號
	#if (not $opt_k and $$text_ref !~ /^◎/) {		
	#	$$text_ref =~ s/◎//g;		
	#}	

	if ($debug) { print STDERR "1272 lineHead=[$lineHead]\n"; }#印出行首

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
	$char = $nextLineChars[0];
	#$cc = quotemeta($char);
	$cc = $char;
	if (is_delimiter($cc) or $$text_ref eq "") { 
		if ($debug) { 
			watch("下一行第一個字元 $char 是分隔字元\n"); 
		}
		if (@chars > 0) {
			if ($debug) { 
				watch("999 印出上一行的內縮: [$indentOfLastLine]\n"); 
			}
			myPrint($indentOfLastLine);
			if ($debug) { 
				watch("954 " . @chars . "\n"); 
			}
			if ($cc eq "　" and $chars[$#chars] eq "　") {
				pop @chars;
			}
			if ($debug) { 
				watch("958 " . @chars . "\n"); 
			}
			my $temp = join('',@chars);
			if ($debug) { 
				watch("印出上一行:[$temp]\n"); 
			}
			myPrint($temp); # 印出上一行
			@chars=();
			$count="(00"; # 折到下一行的字數為0
		}
	}
	
	# 印出下一行行號
	if ($lineHead ne "") { 
		myPrint("${lineHead}$count)$line_head_seperator"); 
	}

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
			#$cc = quotemeta($c);                      #為什麼這裡要多用一個$cc？quotemeta
			if (is_delimiter($c)) {
				if ($c eq "　" or $c eq "＠") { 
					while ($chars[$i-1] eq "　" or $chars[$i-1] eq "＠") { # 可能連續兩個全形空白
						$i--;
					}
					$cut = $i;
				} elsif ($c =~/^(【|（|○|\[|「|『|《|〈)$/ and $c ne '[○─○]') {
					$cut = $i; 
				} else { 
					$cut = $i+1;
				}
				last;
			}
		}
		if ($debug) { print STDERR "2169 cut=[$cut]\n"; }
		for ($i=0; $i<$cut; $i++) {                   #從這裡印出本文
			$c = shift (@chars);
			if ($i==($cut-1) and $c eq "　") { next; }
			if ($c ne "$line_head_seperator" and $c ne "Ｐ") {
				if ($firstChar) { 
					myPrint($rend); $firstChar=0; 
				}
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
		
		if ($debug) { 
			watch("1116 印出 rend=[$rend]\n"); 
		}
		myPrint($rend);
		
		# 如果這一行是空的，要把上一行剩下的印出去 added by Ray 1999.10.8
		#if ($text =~ /$line_head_seperator$/) { print @chars; @chars=(); }
		my $temp = join('',@chars);
		#$temp =~ s/#Ｐ#$//s;
		$temp =~ s/Ｐ$//s;
		if ($temp =~ /Ｐ/) { print STDERR "910 [$temp]\n"; }
		$temp = myReplace($temp);
		if ($debug) { 
			watch("1029 準備印出上一行剩下的：[$indentOfLastLine$temp]\n"); 
		}
		#myPrint($indentOfLastLine);
		myPrint($temp);
		@chars=();
		
		#print "${text}";
		#$$text_ref =~ s/#Ｐ#$//s;
		$$text_ref =~ s/Ｐ$//s;
		if ($$text_ref =~ /Ｐ/) { 
			print STDERR "915 [$$text_ref]\n"; 
		}
		$$text_ref = myReplace($$text_ref);
		$$text_ref =~ s/　$//;
		if ($debug) { 
			watch("1034 準備印出這一行：[$$text_ref]\n"); 
		}
		myPrint($$text_ref);
	}
	#$px = "";
	$$text_ref = "";
	
	# 這一行是空行，把indent存起，下一行要印時用
	if ($thisLineIsEmpty) { 
		$indentOfLastLine = $indentOfThisLine; 
	}
	else { 
		$indentOfLastLine = ""; 
	}
	if ($debug) { 
		watch("indentOfLastLine=[$indentOfLastLine]\n"); 
	}
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

sub jk_rep {
	my $s=shift;
	$s = substr($s,4);
	$s =~ s/^0//;
	$s =~ s/[a-z]$//;
	return "[$s]";
}

sub myReplace {
	my $s = shift;
	if ($debug) { watch("865 myReplace(\"$s\")\n"); }
	#my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my $big5 = '[\x80-\xff][\x00-\xff]|[\x00-\x7f]';
	my @a = ();
	my $c='';
	if ($opt_k) {
	} else {
		# marked by Ray 2001/6/20
		#$s =~ s/\[[0-9（[0-9珠\]//g;
		$s =~ s/\[[0-9]{2,3}\]//g;
		#$s =~ s/#[0-9][0-9]#//g;
		$s =~ s/#[0-9]{2,3}#//g;
	}

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

sub parseRend {
	my $s = shift;
	
	# 如果 rend 屬性裏只有空格
	if ($s=~/^(　)*$/) {
		return $s;
	}

	if ($debug) {
		watch("1807 rend=$s\n");
	}
	my $r = '';
	#$s =~ s/($utf8)/$utf8out{$1}/g;
	$rendMarginLeft=0;
	if ($s =~ /margin\-left:(\-?\d+)/) {
		$rendMarginLeft = $1;
		$r = "　" x $1;
	}
	$rendTextIndent=$rendMarginLeft;
	if ($s =~ /text\-indent:(\-?\d+)/) {
		$rendTextIndent = $1 + $rendMarginLeft;
	}
	return $r;
}

sub myPrint {
	my $s = shift;
	if ($opt_k) {
		# 2004-04-22 不能把句號移到校勘數字前
		#	T13n0397_p0014a03║量功德◎[01]。善男子。乃往過去無量無邊阿僧
		# 句號移到校勘數字前
		# T02n0099_p0032c11║說。此亦無記。[14]又問。如來死後有無耶。非有
		#$s=~s/(<jk [^>]*?>)。/。$1/g;
		# 空格移到校勘數字前
		$s=~s/(<jk [^>]*?>)　/　$1/g;
	} else {
		# 2006/6/30 13:51 markedy by Ray
		#$s =~ s/◎//g;
	}
	
	$s =~ s/＠//g;
	
	# 轉換一些 perl 預設會轉錯的字.
	$s =~ s/�/／/g;
	$s =~ s/∼/～/g;
	$s =~ s/☉/⊙/g;
	$s =~ s/♁/⊕/g;
	$s =~ s/•/‧/g;
	
	$s = myEncode($s);
	$out_buf .= $s;	#edith note 2005/1/20 PDA Version
}

sub myEncode {
	my $s = shift;
	if ($outEncoding eq "utf8") {
		return $s;
	}	
	#if ($debug2) {watch("\n2508myEncode|$s\n");getc;}	
	my @a=();
	push(@a, $s =~ /$utf8/gs);
	#if ($debug2) {watch("\n2511myEncode|$s\n");getc;}	
	my $c;
	$s = '';
	foreach $c (@a) { 
		if ($c ne "\n") {
			if (exists $utf8out{$c}) { 
				$c =  $utf8out{$c}; 
			} else { 
				#$len = length($c);
				#print STDERR "Error:859 lb=$lb s=$s {$c} not in conversion table\n"; 
				#print STDERR "length: $len\n";
				#for ($i=0; $i<$len; $i++) {
				#$s = unpack("H2",substr($c,$i,1));
				#	print STDERR "\\x$s";
				#}
				#exit;
				$c = toucs2($c);
				$c = unpack("H*", $c);
				$c = "&#x$c;";
			}
		}
		$s.=$c; 
	}
	#print STDERR "2427myEncode|[$s]\n";
	
	return $s;
}

sub watch {
	my $s = shift;
	$s=~s/　/＿/g;
	$s=myEncode($s);
	print STDERR "$s";
}

sub changefile{
  
	# added by Ray 1999/11/9 11:29AM
	my $oldof = $of;
	#print STDERR "2555|$oldof\n";
	$of = sprintf("$bof%3.3d.txt", $juanNum);
	#print STDERR "2557|$of\n";
	if ($of eq $oldof) { return; }
	if ($debug) {
		print STDERR "fileopen=$fileopen\n";
	}
	if ($fileopen) {
		if (not $opt_u) {
			$text = myReplace($text);
			myPrint($text);			
			$text="";
		}
		printBuf();
		print STDERR " (1753 close)\n";
		close (OF);
		$firstLb=1;
	}
	open OF, ">$of" or die "open $of error";
	$fileopen = 1;
	print STDERR "1851 --> $of";
	select(OF);
			
	# modified by Ray 1999/12/3 09:32AM
	#if ($num == 0 || ($xu == 0 && $num == 1)){
	if ($debug) { print STDERR "num=[$num]\n"; }
	#if ($num == 0 and $xu==0){
	if (!$opt_h) {
		if ($opt_p){
			if ($num == 0){
				$out_buf='';
				#edith note 2005/1/20 每冊每經的抬頭資訊
				head("PDA版","PDA Version",$version);
			}
			shead();
		} elsif (not $opt_s) {
			if ($num == 0){ # 這個 xml 檔的第一卷
				# 卷首資訊要放最前面
				my $temp=$out_buf;
				$temp =~ s/^\n//; # 每卷的第一行前不要換行
				$out_buf='';
				my $file_head = head("普及版","Normalized Version",$version);
				# T85n2742 是由第2卷開始
				if ($juanNum==1 or $first_juan_of_vol or $xml_file!~/[a-z]\.xml/) {
					myPrint($file_head);
				} else {
					shead();
				}
				$out_buf .= $temp;
				$first_juan_of_vol=0;
			} else {
				shead();
			}
		}
	}
	
	#$text =~ s/^\n//;  # added by Ray 1999/11/9 11:27AM			
	#$text =~ s/\[[0-9]{2,3}\]//g; # added by Ray 2000/1/28 11:10AM
	#$text = myReplace($text);
	#myPrint("\n$text");
	#$text = "";
	$oldbof = $bof;
}

sub read_bulei {
	print STDERR "read bulei.txt....";
	open I, "c:/cbwork/work/bin/BuLei.txt" or die "1026 open bulei.txt error";
	while (<I>) {
		chomp;
		($b, $s) = split /##/;
		if ($b =~ /^$BuLei/) {
			$BuLeiDir{$b}=$s;
			if ($s =~ /^(\d{4}[a-zA-Z]?) .*$/) {
				$sutra2bulei{$1} = $b;
			}
		}
	}
	close I;
	print STDERR "ok\n";

	foreach $s (keys %BuLeiDir) {
		if ( not exists($BuLeiDir{$s."001"})) { # 如果沒有下一層
			$BuLeiDir{$s} =~ /^(\d{4}\w?)(.*)$/;
			$sutraNum = $1;
			$sutraName = $2;
			$sutras{$sutraNum} = $sutraName;
		}
	}
}

sub final_handler {
	$text = myReplace($text);
	myPrint($text);
	printBuf();
	$text="";
	#print STDERR " (1828 close)\n";
	close (OF);
	$fileopen=0;
}

# This event is generated when a comment is recognized.
sub comment {
}

sub printBuf {
	if ($opt_k) {
		$out_buf=~s/<jk ([^>]*?)>/&jk_rep($1)/eg;
	}
	$out_buf =~ s/<\/lg>//gs;	
	$out_buf .= "\n";	# 如果最後沒換行, 要加上換行
	$out_buf =~ s/\n*$/\n/s;
	print $out_buf ;	#edith note 2005/1/20 $out_buf 暫存所以欲轉出的文字, 最後寫入檔案
	$out_buf='';
}

# 加圈點
sub add_period {
	my $s1=shift;
	my $s2=shift;
	if ($s1=~/）/) {
		return $s1;
	}
	# T24n1462_p0710c22║足毘蘭若因緣竟[32]。[33]迦蘭陀品
	#if ($s1 =~ /^(.*?)((<jk[^>]*?>|＠)+)$/s) {
	#	$s1 = "$1$s2$2";
	#} else {
		$s1 .= $s2;
	#}
	return $s1;
}

# 加空白
sub add_space {
	my $s1=shift;
	my $s2=shift;
	if ($s1 =~ /^(.*?)((<jk[^>]*?>|＠|◎)+)$/s) {
		$s1 = "$1$s2$2";
	} else {
		$s1 .= $s2;
	}
	return $s1;
}

sub start_l {
	#edith modify 2005/1/13 PDA T0001_001.txt  [0001c03]
	#比丘集法堂　　講說賢聖論　如來處靜室　　天耳盡聞知　佛日光普照　　分別法界義　亦知過去事　　三佛般泥洹　名號姓種族　　受生分亦知　隨彼之處所　　淨眼皆記之　諸天大威力　　容貌甚端嚴　亦來啟告我　　三佛般泥洹　記生名號姓　　哀鸞音盡知　無上天人尊　　記於過去佛
	#改成
	#比丘集法堂　　講說賢聖論
	#如來處靜室　　天耳盡聞知 (類推...)
	$l_count ++;	#在 </l> 時計算它的餘數, 若餘數為0 才須要換行

	$app = 1;
	#if ($debug2) {watch("884 <l>lgType=[$lgType]\n");}
	if (defined($att{"rend"})) {
		$rend = "　" x $rendTextIndent;
	} elsif ($lgType eq "abnormal") {
		$rend = '';
	} elsif ($lgPlace eq "inline") {
		my $temp=$text;
		$temp =~ s/<jk.*?>//g; # 先把校勘符號去掉, 不然會多空格
		if ($temp =~ /$line_head_seperator(　)*$/) {	# 原本沒有 "(　)*" , 因為若在附文中, 己經會有空格, 所以還是要再空 2009/03/19 by heaven
			$rend = "　"; 
		} elsif ($temp !~ /(　|＠)$/) {
			$rend = "　　"; 
		}
	} else {			
		# T01n0023_p0309c08║　[21]諸人民行種姓　　剎利種為人尊
		my $temp=$text;
		if ($debug) {watch("912 <l>temp=[$text]\n");}
		$temp =~ s/<jk.*?>//g; # 先把校勘符號去掉, 不然會多空格
		if ($debug) {watch("914 <l>temp=[$temp]\n");getc;}
		if ($temp !~ /($line_head_seperator|　|＠)$/) {
			if ($rend eq '' and $lgType ne "inline" and $lgRend ne "inline") { 
				#edith modify 2004/12/21 不是第1個<l> 多空2格(換句話說, 第1個<l>不空格)
				#edith modify 2005/1/21 若是PDA版, 不是第1個<l> 只空1格, 其它版則空2格
				#$rend = "　　"; 
				#if (!$first_l ) {$rend = "　　";}
				if (!$first_l ) 
				{
					if ($opt_p) {$rend = "　";}
					else {$rend = "　　";}
				}
				
			}
		}
	}
	if ($debug) { watch("924 <l> text=[$text]\n"); }
	# 如果偈頌前有小括號 (
	if ($text =~ /^(.*$line_head_seperator.*)\($/s) {
		#X74n1467_p0089b24║　(極樂世界清淨土　　無諸惡道及眾苦　　願如老身病苦者　　同生無量壽佛所)
		$s = $1;
		if ($s !~ /　$/) {
			$text = "$s　(";
		}
	} else { 
		$text = add_space($text,$rend); 
	}
	if ($debug) { watch("931 <l> text=[$text]\n");}
	# T03n0159_p0296b05(00)║　[02]令住堅固不退心　　我於佛所深隨喜
	if ($text !~ /(　|\(|＠(<jk[^>]*?>)*|Ｐ|。|　<jk[^>]*?>)$/) {
		#$text .= "＠";
		if ($debug) {	watch("935 <l> text=[$text]\n");}
		#edith modify 2004/12/14
		#<l>多空一格，lg type="abnormal"的<l>預設皆不空格
		if ($lgType ne "abnormal") 
		{
			#edith modify 2004/12/21 不是第1個<l> 多空1格(換句話說, 第1個<l>不空格)
			#$text .= "<l>";
			if (!$first_l) 
			{
				$text .= "<l>";
				if ($debug) {	watch("945 <l> text=[$text]\n");}
			}
		}
	}
	$first_l=0;
}

sub is_delimiter {
	my $char = shift;
	if ($debug) { print STDERR "2729 $char "; }
	if ($char eq '[○─○]') { return 1; }
	$char = quotemeta($char);
	if ($delimiter =~ /$char/) {
		if ($debug) { print STDERR " 2732 "; }
		return 1;
	}
	return 0;
}

sub start_lb {
	$lb = $att{"n"};
	$heads = 0;
	$first_item=0;
	$sd_count=0;		# edith modify 2005/2/22 新的一行要重新計算悉曇字的數目,以防多半形空格  
	$rj_count=0;		# 新的一行要重新計算蘭札體的數目,以防多半形空格  
	#if ($lb =~ /425c13/) { $debug=1; }
	if ($debug) { 
		print STDERR "\n<lb n='$lb'>\n";  #現在到了哪一行
		watch("446 textref=[$$text_ref]\n");
		watch("447 text=[$text]\n");
		watch("448 text2=[$text2]\n");
		watch("606 firstLb=$firstLb inFuwen=$inFuwen\n");
		#watch("662 twoLineModeLine=$twoLineModeLine tt_max=$tt_max\n");
		#watch("695 indent=[$indent]\n");
		getc;
	}
	#the whole line has been cached to $text, print it now!
			
	#if ($twoLineModeLine == 2) {
	if ($twoLineModeLine > $tt_max) {
		$text_ref = \$text;
		&out;
		$text='';
	} elsif ($twoLineModeLine > 2) {
		$text_ref = \$text3;
		&out;
		$text3='';
	} elsif ($twoLineModeLine > 1) {
		$text_ref = \$text2;
		&out;
		$text2='';
	} else {
		$text_ref = \$text;
		&out;
		$text='';
	}

	#if ($twoLineModeLine==1) {
	#	$twoLineModeLine=2;
	#} elsif ($twoLineMode and $twoLineModeLine==2){
	#	$twoLineModeLine=1;
	#} else {
	#	$twoLineModeLine=0;
	#}
	
	if ($twoLineModeLine>0) {
		if ($twoLineModeLine >= $tt_max){
			$twoLineModeLine=0;
		} else {
			$twoLineModeLine++;
		}
	}
	
	if ($opt_s) {
		$lineHead = "\n";
	} elsif ($opt_p) {
		if ($parent eq 'item' or $parent eq 'list') {
			$lineHead = "\n"; # pda 版 list 下有換行比較好看 2006/5/2 10:44 Ray
		} else {
			$lineHead = "";
		}
	} else {
		$lineHead = "$vl$lb$line_head_seperator";
		#if (!$firstLb) {
			$lineHead = "\n" . $lineHead;
		#}			
	}
	
	if ($debug2) 	{watch("1066|{$lineHead}\n");	}	
	##edith note:2005/1/31這個空格是因為在附文裏
	if (not $opt_a) { # 如果不是 app 版
		#$lineHead .= $indent;			
		$lineHead .= "　" x $current_margin_left;
	}
	if ($debug2) 	{watch("1071|{$lineHead}\n");	getc;}	
	
	#if ($twoLineModeLine==2){
	if ($tt_max==3 and $twoLineModeLine > 2){
		$text3 = "$lineHead" . $text3;
		$text_ref = \$text3;
	} elsif ($twoLineModeLine > 1){
		$text2 = "$lineHead" . $text2;
		$text_ref = \$text2;
	} elsif ($pass==0) {
		$text = "$lineHead";
		if ($twoLineMode and $count_t>2) {
			$text_ref = \$text3;
		} elsif ($twoLineMode and $count_t>1) {
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
	}

	$textInThisLine = 0;
	#$text = "\n$vl$lb║$indent";
	$indentOfThisLine=$indent;
	#} else {
	#	$text .= "\n$vl$lb║$indent";
	#}
	
	# marked by ray 2006/8/30 10:11 table 每列前的空格已在 <cell> 根據 cell_n 處理	
	#if ($new_row) {
	#	$$text_ref .= "　";
	#}	
	$firstLb=0;
	#edith modify 2004/12/14
	#隔行接續的<head type="no">，要空二格
	if ($head_start) 	{$text = add_space($text,"　　");}
	
	if ($debug) { 
		watch("539 textref=[$$text_ref]\n");
		watch("540 text=[$text]\n");
		watch("text2=[$text2]\n");
		watch("669 firstLb=$firstLb\n");
		watch("743 twoLineModeLine=$twoLineModeLine\n");
		watch("988 inFuwen=$inFuwen current_margin_left:$current_margin_left\n");			
	}
}

__END__
:endofperl