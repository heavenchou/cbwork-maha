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

# basicx.pl
# ================================================================================================
# ■ 簡單說明 by heaven (不一定正確)
# %open 用來存放有開啟標記的數量, 例如 : $open{"head"} = 2 , 表示 head 還有二層未關閉
# sub readSutra : 讀入BM版經文, 有任何行首的基礎標記都在此處理
# sub inline_tag : 處理行中簡單標記
# sub checkopen : 用來判斷還有沒有未 close 的標記, 若有, 就 close 它.

# closeSutra 及 final 都是結束後的處理, 或許可以合併, final 就不用再 open 一次了.
# sub closeSutra();
# sub final();
# ================================================================================================
# A <byline type="Author">
# B <byline type="Other">
# C <byline type="Collector">
# E <byline type="Editor">
# Y <byline type="Translator">
#
#2004/12/9、2004/12/10 modify by edith
# v 2.1.1, 卍續藏開始, <list> 用 L, <item> 用 I, Ｉ,  modified by Ray 2003/7/15 03:27下午
# v 2.1.2, 2003/8/12 09:53上午 by ray
# v 2.1.3, 2003/10/16 10:36上午 by Ray
#          <lb ed="X" n="0404c05"/><byline type="Collector">那羅延窟學人　瞿汝稷槃談集</byline>
#          <lb ed="X" n="0404c06"/><byline type="Other">吳郡天池山人　嚴澂道澈甫較</byline>
#          <lb ed="X" n="0404c07"/><byline type="Other">後學梅巖釋　開慧　捐資重梓</byline>
#          <lb ed="X" n="0404c08"/><byline type="Other">後學　　釋　義行　重　　閱</byline>
# v 2.1.4, 2003/10/20 10:18上午 by Ray
#          X84n1579_p0012a11LQ1續指月錄凡[倒>例]二十則
#          X84n1584_p0652a21_##為冊六。</L>Ｐ行昱和南謹述。</Q1>
# v 2.1.5, 2003/10/27 01:19下午 by Ray
#          X85n1591_p0229b11r## [[巳>已]>>]
#          X85n1591_p0229b12r##　[>>[巳>已]]
#          X85n1592_p0281b14_##[(廉-(前-刖))-〦+立)]纖如此)
#          X84n1581_p0358b12I##楚石琦禪師Ｉ毒[山/夆]善禪師Ｉ空谷隆禪師
# v 2.1.6, 2003/10/28 05:45下午 by Ray
# v 2.1.7, 2003/11/7 05:06下午 by Ray
# v 2.2.1, 修訂 [A>B] 轉成 <app><lem wit="..." resp="CBETA.maha"> 2004/2/9 02:17下午 by Ray
# v 2.3.1, 2004/4/21 10:53上午 by Ray
#          cvs 自動更新的版本編號、日期 放在 <editionStmt>
#          簡單標記 x,X 後面的數字 表示 div 層次
#          type="inline" 改用 place="inline"
# v 2.3.2, xml:stylesheet => xml-stylesheet
# v 2.3.3, 2004/4/30 03:45下午 by Ray
# v 2.4.1, 2004/5/5 11:29上午 by Ray
#          X71, No. 1420
#          <lb ed="X" n="0655c06"/><div1 type="other"><mulu type="其他" level="1" label="＆CB01614；著"/><head>&CB01614;著<note place="inline">附水陸陞座及行狀塔銘</note></head> 
#          maha 覺得這裡的「夾註小字」自動轉入 mulu label 會比較好。
#          轉入後，再由 xml 人員去編輯，若有必要就保留，若太囉嗦就砍掉。
# v 2.4.2 2004/5/13 02:22下午 by Ray
#         X71n1414_p0397b15Q#2無言住能仁江Ｂ南堂疏
# v 2.4.3 2004/5/28 04:15下午 by Ray
# v 2.5.1, 2004/7/7 09:21上午 by Ray
#	X64 處理 e, <e>, </e>
# v 2.5.2, 2004/7/22 11:13上午 by Ray
#	X 切卷錯誤 X64n1271_p0777a02X##No. 1271-A
# 2004/9/3 09:36上午 by Ray
#	<n> 繼承上一個 n 的縮排
# 2008/04/11 by heaven
#	支援 <annals><date><event> 標記
# 2008/06/16 by heaven : <□> -> &unrec;
# 2008/06/17 by heaven : 支援不通用的標記 <no_chg>[金*巢]</no_chg> --> <term rend="no_nor">&CB07460;</term>
# 2008/06/19 by heaven : 處理 [<□>>邸] 無法自動轉成 XML 的問題. 做法是提前處理 <□> -> &unrec;
# 2009/02/21 by heaven : 支援第三期經文的代碼 C , C01n0001_p0001a01
# 2009/02/28 by heaven : 支援H及W開頭代碼，取消支援第三期經文的代碼 C , C01n0001_p0001a01
# 2009/03/14 by heaven : wit 屬性支援正史與藏外
# 2010/07/19 by heaven : 修改支援頁碼可能大於 3
# 2010/11/25 by heaven : 支援<tt>標記
# 2010/12/06 by heaven : 支援<tt>標記, <tt> 標記可能會跨行
# 2010/12/04 by heaven : <app> 中沒有文字的部份要換成 &lac;
# 2010/12/05 by heaven : <T> 標記不要中止 list 及 item .
#-------------------------------------------------------------------------------------------------
#$xml_root="/cbwork/xml";

use Win32::ODBC;

($path, $name) = split(/\//, $0);
push (@INC, $path);
require "sub.pl";

$inw = 0;
local $head="";
local $label="";
local $debug=0;
local $juanOpen=0;
@notfound=();
$tab=0;

#open (BAT, ">go.bat");

# -------------------
# read configuration;
# -------------------
$vol=shift;
if ($vol eq ""){
	print "\t$0: Converts simple Markup to Basic Markup (XML)\n";
	print "Usage: $0 Volumn\n";
	exit;
}
$vol=uc($vol);

$cfg{"EditionDate"} = today();
$cfg{"laiyuan"} = "/cbwork/simple/$vol/source.txt";
$cfg{"jingwen"} = "/cbwork/simple/$vol/new.txt";

#regex for big5
$big5 = '(?:[\xA1-\xFE][\x40-\x7E\xA1-\xFE]|[\x00-\x7F])';

# 含 entity 的 big5
$big5a = '(?:&[^;]+?;|[\xA1-\xFE][\x40-\x7E\xA1-\xFE]|[\x00-\x7F])';

#regex for gaiji expression
$pattern = << 'EOP';
		(									#capture open
		(?:髣|搪|礔)?
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char 匕 or parens expr (匕*矢)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?卍]
		\]
		(?:跪|竮)?
		)									#capture close
EOP

#regex for corr expression
$corrpat = << 'EOP';
#first part: gaiji or char or nothing or * of any of these
		\[
		(									#capture open
		(?:
		(?:									#atom open
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char 匕 or parens expr (匕*矢)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?卍]
		\]
		)									#atom close
		|
		[\xa1-\xfe][\x40-\xfe]
		|
		)*
		)									#capture close
		>									#this is it!
#second part: gaiji or char or nothing or * of any of these
		(									#capture open
		(?:
		\[
		(?:									#atom open
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char 匕 or parens expr (匕*矢)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?卍]
		\]
		)									#atom close
		|
		[\xa1-\xfe][\x40-\xfe]
		|
		)*
		)									#capture close
		\]
		
EOP

readGaiji();
readSource(); #讀 來源檔

$cjn = 0;
%open=();
readSutra(); #讀經文檔


$buf .= &checkopen("p", "title", "item", "list", "jhead", "juanBegin", "juanEnd", "div");
$buf .= "\n</body></text></TEI.2>\n";
closeSutra();

#writeEnt($oldvol, $oldnum);

final();

sub checkopen{
	local (@op) = @_;
	for (@op){
		if ($open{$_} > 0){
			if ($_ eq "head") { 
				$_ = closeHead(); 
			} elsif ($_ eq "div") {
				$_ = closeAllDiv();
			} elsif ($_ eq "jhead") {
				$_ = $juan_tmp . '</jhead>';
				$juan_tmp = '';
			} elsif ($_ =~ /^juan/) {
				$open{$_} = 0;
				$_ = "</juan>"; 
			} else { 
				if ($_ eq "cell") { # 表格裏也許還會有表格, 不知道有沒有
					$open{$_} --;
				} else {
					$open{$_} = 0;
				}
				$_ = "</$_>"; 
			}
		} else {
			$_ = "";
		}
	}
	return join("", @op);
}

sub header {
	local($file, $bd, $no) = @_;
	if ($debug) {
		print STDERR "171 header() no=$no\n";
	}
	my $title=$tit{$no};
	my $extent=$extent{$no};
	my $author=$author{$no};
	
	if ($author ne '') {
		$author = "\n\t\t\t<author>$author</author>";
	}

	local($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time());
	$today = sprintf("%4.4d/%2.2d/%2.2d %2.2d:%2.2d:%2.2d", $year+1900, $mon+1, $day, $hour, $min, $sec);
	$no=~s/_|n//g;
	$lye = $lye{$no};
	$lyc = $lyc{$no};
	if ($debug) {
		print STDERR "187 lye=$lye lyc=$lyc\n";
	}
	$no=~s/^0//;
	$date=$cfg{"EditionDate"};

# T 大正新脩大藏經 (Taisho Tripitaka) （大正藏） 【大】
# X 卍新纂大日本續藏經 (Manji Shinsan Dainihon Zokuzokyo) （新纂卍續藏） 【卍續】
# J 嘉興大藏經(新文豐版) (Jiaxing Canon(Xinwenfeng Edition)) （嘉興藏） 【嘉興】
# H 正史佛教資料類編 (Passages concerning Buddhism from the Official Histories) （正史） 【正史】
# W 藏外佛教文獻 (Buddhist Texts not contained in the Tripitaka) （藏外） 【藏外】 
# I 北朝佛教石刻拓片百品 (Selections of Buddhist Stone Rubbings from the Northern Dynasties) 【佛拓】

# A 金藏 (Jin Edition of the Canon) （趙城藏） 【金藏】
# B 大藏經補編 (Supplement to the Dazangjing) 　 【補編】
# C 中華大藏經 (Zhonghua Canon) （中華藏） 【中華】
# D 國家圖書館善本佛典 (Selections from the Taipei National Central Library Buddhist Rare Book Collection) 【國圖】
# F 房山石經 (Fangshan shijing) 　 【房山】
# G 佛教大藏經 (Fojiao Canon) 　 【教藏】
# K 高麗大藏經 (Tripitaka Koreana) （高麗藏） 【麗】
# L 乾隆大藏經(新文豐版) (Qianlong Edition of the Canon(Xinwenfeng Edition)) （清藏、龍藏、乾隆藏） 【龍】
# M 卍正藏經(新文豐版) (Manji Daizokyo(Xinwenfeng Edition)) （卍正藏） 【卍正】
# N 永樂南藏 (Southern Yongle Edition of the Canon) （再刻南藏） 【南藏】
# P 永樂北藏 (Northern Yongle Edition of the Canon) （北藏） 【北藏】
# Q 磧砂大藏經(新文豐版) (Qisha Edition of the Canon(Xinwenfeng Edition)) （磧砂藏） 【磧砂】
# S 宋藏遺珍(新文豐版) (Songzang yizhen(Xinwenfeng Edition)) 　 【宋遺】
# U 洪武南藏 (Southern Hongwu Edition of the Canon) （初刻南藏） 【洪武】

# R 卍續藏經(新文豐版) (Manji Zokuzokyo(Xinwenfeng Edition)) （卍續藏）
# Z 卍大日本續藏經 (Manji Dainihon Zokuzokyo)

	# 各種版本 TXJHWIABCDFGKLMNPQSU
	if ($bd =~ /^T/) {
		$collection = "Taisho Tripitaka";
	} elsif ($bd =~ /^X/) {
		$collection = "卍 Xuzangjing";
	} elsif ($bd =~ /^J/) {
		$collection = "Jiaxing Canon";
	} elsif ($bd =~ /^H/) {
		$collection = "Passages concerning Buddhism from the official histories";
	} elsif ($bd =~ /^W/) {
		$collection = "Buddhist Texts not contained in the Tripitaka";
	} elsif ($bd =~ /^I/) {
		$collection = "Selections of Buddhist Stone Rubbings from the Northern Dynasties";
	} elsif ($bd =~ /^A/) {
		$collection = "Jin Edition of the Canon";
	} elsif ($bd =~ /^B/) {
		$collection = "Supplement to the Dazangjing";
	} elsif ($bd =~ /^C/) {
		$collection = "Zhonghua Canon";
	} elsif ($bd =~ /^D/) {
		$collection = "Selections from the Taipei National Central Library Buddhist Rare Book Collection";
	} elsif ($bd =~ /^F/) {
		$collection = "Fangshan shijing";
	} elsif ($bd =~ /^G/) {
		$collection = "Fojiao Canon";
	} elsif ($bd =~ /^K/) {
		$collection = "Tripitaka Koreana";
	} elsif ($bd =~ /^L/) {
		$collection = "Qianlong Edition of the Canon";
	} elsif ($bd =~ /^M/) {
		$collection = "Manji Daizokyo";
	} elsif ($bd =~ /^N/) {
		$collection = "Southern Yongle Edition of the Canon";
	} elsif ($bd =~ /^P/) {
		$collection = "Northern Yongle Edition of the Canon";
	} elsif ($bd =~ /^Q/) {
		$collection = "Qisha Edition of the Canon";
	} elsif ($bd =~ /^S/) {
		$collection = "Songzang yizhen";
	} elsif ($bd =~ /^U/) {
		$collection = "Southern Hongwu Edition of the Canon";
	} else {
		die "bd=[$bd] vol=[$vol]\n";
	}

#	$title =~ s/\\/\\\\xx/g;
#	print STDERR 
	$bd =~ s/^[TXJHWIABCDFGKLMNPQSU]//;
#	print STDERR $title, "\n";
	my $head =<< "EOF";
<?xml version="1.0" encoding="cp950" ?>
<?xml-stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE TEI.2 SYSTEM "../dtd/cbetaxml.dtd"
[<!ENTITY % ENTY  SYSTEM "${file}.ent" >
<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
%ENTY;
%CBENT;
]>
<TEI.2>
<teiHeader>
<fileDesc>
		<titleStmt>
			<title>$collection, Electronic version, No. $no $title</title>$author
			<respStmt>
				<resp>Electronic Version by</resp>
				<name>CBETA</name>
			</respStmt>
		</titleStmt>
	<editionStmt>
		<edition>\$Revision\$ (Big5)<date>\$Date\$</date></edition>
	</editionStmt>
	<extent>${extent}卷</extent>
	<publicationStmt>
		<distributor>
			<name>中華電子佛典協會 (CBETA)</name>
			<address>
				<addrLine>service\@cbeta.org</addrLine>
			</address>
		</distributor>
		<availability>
			<p>Available for non-commercial use when distributed with this header intact.</p>
		</availability>
		<date>\$Date\$</date>
	</publicationStmt>
	<sourceDesc>
		<bibl>$collection Vol. $bd, No. $no &desc;</bibl>
	</sourceDesc>
</fileDesc>
<encodingDesc>
	<projectDesc>
		<p lang="eng" type="ly">$lye</p>
		<p lang="chi" type="ly">$lyc</p>
	</projectDesc>
</encodingDesc>
<revisionDesc>
	<change>
		<date>$today</date>
		<respStmt><name>Zhou Bang-Xin</name><resp>ed.</resp></respStmt>
		<item>Created initial TEI XML version with BASICX.BAT</item>
	</change>
<!--
\$Log\$
-->
</revisionDesc>
</teiHeader>
EOF
	$buf .= $head;
}

#replaces gaiji with entities
sub rep {
	local($quezi) = $_[0];
	if ($edith eq 1) {print STDERR "\n312|$quezi\n";}
	if ($quezi!~/\+|\-|\*|\/|\@|\?/) {
		return $quezi;
	}
	my $cb = $cb{$quezi};
	my $ret;
	if ($edith eq 1) {print STDERR "\n318|$cb\n";}
	if ($cb eq ""){
		#die "263 lb=$lb {$quezi} not found, program died!!\n";
		push @notfound, $quezi;
		$ret = "<xx/>$quezi";
		if ($debug2) {
			print STDERR "$quezi 找不到 CB 碼\n";
		}
	} else {
		#$lq{$quezi}=$qz{$quezi};
		if ($ent{$cb} =~ /^CI/) {
			$ret = "&" . $ent{$cb} . ';';
			#print STDERR "\n329|$ret\n";
		} else {
			$ret = '&CB' . $cb . ';';
		}
		$lq{$quezi} = $ret;
	}
	return $ret;
}

sub revrep {
	local($quezi) = $_[0];
#	print STDERR "$quezi\n";
	if ($revqz{$quezi} eq ""){
		die "$quezi not found!!\n";
	}
	return "$revqz{$quezi}";
}

%xnum=(
	"一", "1",
	"二", "2",
	"三", "3",
	"四", "4",
	"五", "5",
	"六", "6",
	"七", "7",
	"八", "8",
	"九", "9",
	"○", "0",
	"十", "",
	"百", "",
);

sub exnum{
	local($_) = $_[0];
	return "1000" if ($_ eq "千");
	return "100" if ($_ eq "百");
	return "10" if ($_ eq "十");
	s/^千([^因[^佉)/10$xnum{$1}/;
	s/千([^因[^佉)/0$xnum{$1}/;
	s/^千/1/;
	s/^百十$/110/;
	s/十$/0/;
	s/^百([^也[^Q])/10$xnum{$1}/;
	s/百([^也[^Q])/0$xnum{$1}/;
	s/^百/1/;
	s/^([0-9])?十/${1}1/;
	s/百十/1/;
	s/([\xa1-\xfe][\x40-\xfe])/$xnum{$1}/g;
	return $_;
}

sub fig{
	local($loc) = $_[0];
		$loc =~ s/一/1/g;
		$loc =~ s/二/2/g;
		$loc =~ s/三/3/g;
		$loc =~ s/功|/4/g;
		$loc =~ s/五/5/g;
		$loc =~ s/六/6/g;
		$loc =~ s/七/7/g;
		$loc =~ s/八/8/g;
		$loc =~ s/九/9/g;
		$loc =~ s/^十$/10/g;
		$loc =~ s/之十$/\.10/;
		$loc =~ s/^十(.)/1$1/g;
		$loc =~ s/(.)十$/${1}0/g;
		$loc =~ s/之十/\.1/;
		$loc =~ s/十//g;
		$loc =~ s/百/100/g;
		$loc =~ s/○/0/g;
		$loc =~ s/\s+//g;
		$loc =~ s/之/\./;
		if (length($loc) == 4){
			substr($loc, 1, 1) = "";
		}
		if (length($loc) == 5){
			substr($loc, 1, 2) = "";
		}
		if (length($loc) == 6){
			substr($loc, 1, 3) = "";
		}
		return $loc;
}


sub addp {
	local $itag = shift;
	local $before = shift;
	local $len=myLength($before)+1;
	my $id = "p${vol}p$p$sec${line}" . sprintf("%2.2d",$len);
	
	my $s='';
	if ($itag eq "Ｐ" or $itag=~/^<p/){
		if ($itag=~/<p,(\-?\d+?),(\-?\d+)>/) {
			$pMarginLeft=" rend=\"margin-left:$1em;text-indent:$2em\"";
		} elsif ($itag=~/<p,(\-?\d+?)>/) {
			$pMarginLeft=" rend=\"margin-left:$1em\"";
		} elsif ($open{"p"}<=0) {
			$pMarginLeft='';
		}
		if ($debug) {
			print STDERR " " x $tab, "395 addp() open{item}=", $open{"item"}, " open{p}=", $open{"p"}, "\n";
		}
		if ($open{"lg"} > 0){
			#return "</l><l type=\"inline\">";
			$open{"lg"}=0;
			$open{"p"}++;
			#return "</l></lg><p id=\"$id\" type=\"inline\">";
			return "</l></lg><p id=\"$id\" place=\"inline\">";
		} elsif ($open{"item"} > 0) {
			if ($open{"p"}>0) {
				$s="</p>";
			} else {
				if ($open{"title"}>0) {
					$open{"title"}=0;
					$s="</title>";
				}
				$open{"p"}++;
			}
			#return "$s<p id=\"$id\" type=\"inline\"$pMarginLeft>";
			return "$s<p id=\"$id\" place=\"inline\"$pMarginLeft>";
		} elsif ($open{"byline"} > 0) {
			$open{"byline"}=0;
			print STDERR '390 addp() open{"byline"}=' . $open{"byline"} . "\n";
			#return "</byline><p id=\"$id\" type=\"inline\"$pMarginLeft>";
			return "</byline><p id=\"$id\" place=\"inline\"$pMarginLeft>";
		} else {
			#return "</p><p id=\"$id\" type=\"inline\"$pMarginLeft>";
			return "</p><p id=\"$id\" place=\"inline\"$pMarginLeft>";
		}
	} elsif ($itag eq "Ｒ"){
		if ($open{"title"} > 0) {
			$open{"title"}=0;
			return "</title>";
		}
	} elsif ($itag eq "Ｚ"){
		if ($open{"lg"} > 0){
			#return "</l><l type=\"idharani\">";
			return '</l><l place="inline" type="dharani">';
		} else {
			#return "</p><p type=\"idharani\">";
			return '</p><p place="inline" type="dharani">';
		}
	} else {
		return $itag;
	}
}

sub beforePrintText {
	# T53n2121_p0125b28P##║婦言Ｓ　兒孫無量數　　因緣和合生
	if ($text =~ /Ｓ/) {
		$text =~ /^(.*)Ｓ(.*)$/;
		my $s1 = $1;
		my $s2 = $2;

		my $len=myLength($s1)+1;
		my $id= "lg${vol}p$p$sec${line}" . sprintf("%2.2d",$len);	
		
		if ($open{"p"}>0) {
			$s1 .= "</p>";
			$open{"p"}--;
		}
		$s2 =~ s#((　)+)#</l><l>$1#g;
		$s2 = "<l>" . $s2 . "</l>";
		$s2 =~ s#<l></l>##;
		#$text = $s1 . "<lg id=\"$id\" type=\"inline\">" . $s2;
		$text = $s1 . "<lg id=\"$id\" place=\"inline\">" . $s2;
		$open{"lg"}++;
		$lgType = "inline";
	}
}

sub cjuan {
	local($c1, $c2) = @_;
	local($x2) = $c2;
	if ($debug) {
		print STDERR "506 cjuan\n($c1,$c2)\n\n";
	}
	$c2 =~ s/\[[0-9（[0-9珠\]//g;
	$c2 =~ s/<note [^>]*>.*?<\/note>//g;
	$c2 =~ s/<lb[^>]*>//;
	$c2 =~ s/\n//;
	
	# X78n1553_p0464b22J##天聖廣燈錄卷第十　　　〔宋實〕
	if ($c2 =~ /^(.*?)　/) {
		$c2=$1;
	}
	
	if ($debug) {
		print STDERR "520 $c2\n";
	}

#	print STDERR "$c2\n";
	if ($c2 eq "上"){
		$cjn = 1;
		$jcnt = 1;
	} elsif($c2 eq "下" || $c2 eq "中"){
		$jcnt++;
		$cjn = $jcnt;
	} else {
		#$cjn = &fig($c2);
		$cjn=cn2an($c2);
	}
	#$cjn = sprintf("%3.3d", $cjn);
	if ($debug) {
		print STDERR "535 $cjn\n";
	}
#	print STDERR "$c1\t$c2\n";         
	return "open\" n=\"$cjn\">$c1$x2";
}

sub rep2 {
	local($x2, $x1) = @_;
	#edith modify 2005/1/10
	#X78n1549_p0282b08Q#2恒一
	#應該轉出<lb ed="X" n="0282b08"/><div2 type="other"><mulu type="其他" level="2" label="恒一"/><head>恒一</head>
	#所以全都 hide
	#return "$x1&M024261;" if ($x2 eq "碁");
	#return "$x1&M040426;" if ($x2 eq "銹");
	#return "$x1&M034294;" if ($x2 eq "裏");
	#return "$x1&M005505;" if ($x2 eq "墻");
	#return "$x1&M010527;" if ($x2 eq "恒");
	#return "$x1&M026945;" if ($x2 eq "粧");
	#return "$x1&M006710;" if ($x2 eq "嫺");
	return "$x1$x2";
}

sub myLabel {
	my $s = shift;
	if ($debug2) {
		print STDERR "487 myLebel($s)\n";
	}
	$s =~ s/\[\d\d\]//g;
	$s =~ s/\[＊]//g;  # added by Ray 2000/11/27 09:54上午
	# \xa6\x61 = 地
	my @type = ("品","分","會","經","\xa6\x61","章","緣起");

	$s =~ s/<corr.*?>//g;
	$s =~ s#</corr>##g;
	
	# add by Ray 2003/8/11 11:03上午
	if ($s =~ m#^<app><lem wit="【CBETA】" resp=".*?">(.*?)</lem><rdg wit="$wit">(.*?)</rdg></app>$#) {
		my $s1=$1;
		my $s2=$2;
		if ($s2 eq '') {
			#$s = "（$s1）";
			$s = $s1;
		} else {
			$s = $s1;
		}
	} else {
		$s =~ s#<app><lem wit="【CBETA】" resp=".*?">(.*?)</lem><rdg wit="$wit">.*?</rdg></app>#$1#g;
	}
  
	#$s =~ s#<note.*?</note>##g;
	$s =~ s#<note[^>]*?>(.*?)</note>#\($1\)#g;

	$s =~ s/^佛說//;
	$s =~ s/^（.+）第.+分(.+經第.+)$/$1/;
	# "（" = \xa1\x5d, "）" = \xa1\x5e
	$s =~ s/^\xa1\x5d.+\xa1\x5e第.+分(.+經第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e第.+分.+經(.+品第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(.+品第.+)$/$1/;
	$s =~ s/^第.+分.+經(.+品第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e第.+分(.+經)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(.+經第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(第.+分)初$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(第.+分)$/$1/;
	$s =~ s/^初分(.+品第.+)$/$1/;
	$s =~ s/^第.+分(.+品第.+)$/$1/;
	$s =~ s/^第.+分(.+品第.+)$/$1/;
	$s =~ s/^.+\xb7\x7c第.+之(一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+(.+品第.+)$/$2/;  # \xb7\x7c 會
	$s =~ s/^.+\xb7\x7c第(一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+(.+品第.+)$/$2/;  # \xb7\x7c 會
	$s =~ s/^.+\xb7\x7c(.+品第.+)$/$1/;  # \xb7\x7c 會
	$s =~ s/^.+分第(一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+(.+品第.+)$/$2/;  # \xb7\x7c 會
	if ($s !~ /分別/) { $s =~ s/^.+分(.+品第.+)$/$1/; }
	$s =~ s/^.+經(.+品第.+)$/$1/;
	$s =~ s/^(.+第.+)之.+$/$1/;
  
	if ($debug) {
		print STDERR "481 $s\n";
	}
  	
	# "第一品" => "1 第一品"
	foreach $type (@type) {
		$type = quotemeta($type);
		if ($s =~ /^第(.+)$type$/) {
			my $a = cn2an($1);
			if ($a ne "") { $s = "$a $s"; }
		}
	}

	if ($debug) { print STDERR "494 $s\n"; }

	# "＊＊品第一之一" => "1 ＊＊品"
	if ($s !~ /^\d+ /) {
		# X79n1557_p0012a09Q#2過去莊嚴劫。第九百九十八尊。毗婆尸佛
		#if ($s =~ /^(.+)第((一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+)(之)*.*$/) {
		if ($s =~ /^(.+)第((一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+)(之)+.*$/) {
			$s = $1;
			$a = cn2an($2);
			if ($a ne "") { $s = "$a $s"; }
		}
	}

	if ($debug) { print STDERR "507 $s\n"; }

	# "（一）＊＊＊" => "1 ＊＊＊"
	if ($s =~ /^\xa1\x5d((?:一|二|三|四|五|六|七|八|九|十|百)+)\xa1\x5e(.*)$/) {
	  $s = $2;
	  my $a = cn2an($1);
	  if ($a ne "" and $s ne "") { $s = " $s"; }
	  $s = $a . $s;
	}
	
	# 去掉句點
	while ($s =~ /^($big5*?)。(.*)$/) {
		$s = $1 . $2;
	}
	
	$s =~ s/&lac;//g;
	$s =~ s/&([^;]+);/＆$1；/g;
	$s =~ s/&(CB\d{5});/$1/g;
	$s =~ s/<anchor id=\".*?\"\/>//g;
	$s =~ s/<figure.*?\/>//g;
	#$label =~ s/<anchor[^>]*?>//g;
	if ($debug) {
		print STDERR "580 end myLabel $s\n";
	}
	$s =~ s/^\((.*)\)$/$1/; # 如果前後都是半形括號, 就去掉
	return $s;
}

sub closeHead {
	if ($debug2) {
		print STDERR "664 closeHead() label=[$label]\n";
		getc;
	}
	if (not $open{"head"}) { return ''; }

	my $s="";
	my $return1 = '';
    
	if ($divtype eq "xu") { $s = "序"; }
	elsif ($divtype eq "pin") { $s = "品"; }
	elsif ($divtype eq "hui") { $s = "會"; }
	elsif ($divtype eq "fen") { $s = "分"; }
	elsif ($divtype eq "other") { $s = "其他"; }
	elsif ($divtype eq "w") { $s = "附文"; } # 2004/6/18 03:06下午
	#else { $s = "其他"; }
	
	if ($s ne '') {
		$s = " type=\"$s\"";
	}

	$label = myLabel($label);
	my $level=$open{"div"};
	$head =~ s#<mulu>#<mulu$s level=\"$level\" label=\"$label\"/>#;
	if ($debug) { print STDERR "1093 head=[$head]\n"; }
	$return1 = "$head</head>";

	$open{"head"} = 0;
	$head = "";
	$label = "";
	return $return1;
}

sub readGaiji {
	my $cb,$zu,$ent,$mojikyo,$ty;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code
		$mojikyo = $row{"mojikyo"};  # mojikyo code
		$zu      = $row{"des"};      # 組字式
		$ent     = $row{"entity"};
		$uni     = $row{"uni"};
		$ty      = $row{"nor"};
		
		if ($cb =~ /0002b21/)
		{
			print STDERR "\n715|cb{$cb}\n";
			#print STDERR "\n716|nor{$ty}\n";
			#print STDERR "\n717|des{$zu}\n";
			#print STDERR "\n718|ent{$ent}\n";
		}
		
		if ($cb =~ /0005$/)
		{
			#print STDERR "\n724|cb{$cb}\n";
			#print STDERR "\n723|nor{$ty}\n";
			#print STDERR "\n724|des{$zu}\n";
			#print STDERR "\n718|ent{$ent}\n";
			#getc;
		}
		#getc;
		next if ($cb =~ /^#/);

		$ty = "" if ($ty =~ /none/i);
		$ty = "" if ($ty =~ /\x3f/);
		#if ($ent =~ /^[\?\x80-\xfe]/){
  		#	$ent ="&$d1;";
		#}
		die "ty=[$ty]" if ($ty =~ /\?/);

		#$qz{$zu} = $ent;
		$nr{$ent} = $ty;
		$cb{$zu} = $cb;
		$ent{$cb} = $ent;
	}
	$db->Close();
	print STDERR "ok\n";
}

sub rend {
	my $s='';
	if ($text =~ /(<p,(\-?\d+),(\-?\d+)>)/) {
		my $t=$1;
		$s = " rend=\"margin-left:$2em;text-indent:$3em\"";
		$text =~ s/$t//;
	} elsif ($text =~ /(<p,(\d+)>)/) {
		my $t=$1;
		$s = " rend=\"margin-left:$2em\"";
		$text =~ s/$t//;
	} elsif ($rend ne "0") {
		$s = ' rend="' . "margin-left:$rend" . 'em"';
		$oldRend = $rend;
		$rend = "0";
	}
	return $s;
}

sub writeEnt {
	my $vol=shift;
	my $num=shift;
	open (E, ">$vol$num.ent") if ($vol ne "");
	print E "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
	print E "<!ENTITY desc \"\" >\n";
	for $k (sort(keys(%lq))){
#&MX000144;	[(匕/禾)*(企-止+米)]
		$e = $lq{$k};
		$n = $nr{$e};
		$e =~ s/\&|;//g;
#ent: Nicht normalisiert
		#print F "<!ENTITY $e \"$k\" >\n";
#			print E "<!ENTITY $e \"<gaiji cb='CB$cb{$k}' des='$k' " ;
##changed entity to always CB (00-01-05)
		print E "<!ENTITY CB$cb{$k}  \"<gaiji cb='CB$cb{$k}' des='$k' " ;
#ent: normalisiert
		if ($n ne ""){
			#print N "<!ENTITY $e \"$n\" >\n" ;
			print E "nor='$n' ";
		} else {
			#print N "<!ENTITY $e \"$k\" >\n";
		}
		if ($e =~ /^M/){
			print E "mojikyo='$e'/>\" >\n";
		} else {
			print E "/>\" >\n"
		}
	}
}

sub changeSutra {
		#$buf .= &checkopen("p", "title", "item", "list", "jhead", "byline", "juanBegin", "juanEnd", "div");
		$buf .= &checkopen("p", "title", "item", "list", "jhead", "byline", "juanBegin", "juanEnd", "l", "lg", "div");
		if ($juanOpen) {
		  #print F "<juan fun=\"close\" n=\"$currentJuan\"></juan>";
		}
		$buf .= "\n</body></text></TEI.2>\n";
		closeSutra();
		#writeEnt($oldvol, $oldnum);
		$oldnum = $num;
		$oldvol = $vol;
		%lq = ();
		close(F);
		%open = ();
		$open{"div"}=0;
		$injuan = 0;
		$in_div_note = 0;
		$juanOpen=0;
		$figureEnt='';
		$jx='';
		if ($vol ne '' and $num ne '') {
			#my $xml_file = "$xml_root/$vol/$vol$num.xml";
			my $xml_file = "$vol$num.xml";
			open (F, ">$xml_file");
			print STDERR "820 $xml_file\n";
		}
		$firstLine=1;
		#print BAT "call cparsxml.bat $vol$num $vol$num\n";
		select (F);
		&header ("$vol$num", $vol, $num);
		$buf .= "<text><body>";
		if ($line ne "01") {
			$oldp = "$p$sec";
			$oldPage = $p;
			$count = 0;
		}
		$currentJuan = 0;
}

sub printOutJuan {
	
	if ($debug) {
		print STDERR "839 begin printOutJuan()\n";
		print STDERR "841 juan=$juan\n";
	}
	#edith modify 2005/5/27  編"第一、第二…"，而不是 "卷第一、 卷第二"，
	#X56n0949_p0870a17J##閑居編第一
	#if ($juan =~ /^(.*)open">(.*卷(?:\[[0-9（[0-9珠\])*第)(.*)$/s) {
	if ($juan =~ /^(.*)open">(.*[卷|編](?:\[[0-9（[0-9珠\])*第)(.*)$/s) {
		if ($debug) {print STDERR "845 ($1)($2)($3)\n";}
		$juan = $1 . &cjuan($2, $3);
	} elsif ($juan =~ /^(.*)open">(.*卷.*?第)(.*)$/s) {
		if ($debug) {print STDERR "848 ($1)($2)($3)\n"; getc;}
		$juan = $1 . &cjuan($2, $3);
	#} elsif ($juan =~ /^(.*)open">(.*卷.*?)((上|中|下))/s) {
	} elsif ($juan =~ /^(.*)open">(.*卷.*?)((上|中|下))$/s) {
		if ($debug2) {print STDERR "852 ($1)($2)($3)\n"; getc;}
		$juan = $1 . &cjuan($2, $3);
	} elsif ($juan =~ /^(.*)open">(.*?)(上|中|下)(卷.*)$/s) {
		if ($debug2) {print STDERR "855 ($1)($2)($3)($4)\n"; getc;}
		$juan = $1 . &cjuan($2, $3) . $4;
	} elsif ($juan =~ /^(.*)open">(.*?)(上|中|下)(帙.*)$/s) {
		$juan = $1 . &cjuan($2, $3) . $4;
	} elsif ($juan =~ /^(.*)open">(.*一卷.*)$/s) {
		#$juan = $1 . 'open" n="001">' . $2;
		#edith modify 2005/4/22 <juan fun="open" n="1"> n 的數值 1~9 卷1位, 10~99卷2位, 100~999 卷3位....，程式統一不補 0 了。
		$juan = $1 . 'open" n="1">' . $2;
	# X83n1578_p0412c01J##指月錄卷之二
	} elsif ($juan =~ /^(.*)open">(.*卷之)((?:一|二|三|\Q四\E|五|六|七|八|九|十|百)+)(.*)$/s) {
		$juan = $1 . cjuan($2, $3) . $4;
	} elsif ($juan =~ /^(.*)open">(.*卷)((?:一|二|三|\Q四\E|五|六|七|八|九|十|百)+)(.*)$/s) {
		if ($debug2) {print STDERR "867 ($1)($2)($3)($4)\n"; getc;}
		$juan = $1 . cjuan($2, $3) . $4;
	#edith add 2005/5/20 卷第一在第二行才看到
	#X74n1470_p0146c13j##大方廣佛華嚴經海印道場十重行願常[彳*扁]禮懺儀
         #x74n1470_p0146c14j=#卷第一
	} elsif ($tag =~ /J=/ and $juan =~ /^(.*)">(.*卷(?:\[[0-9（[0-9珠\])*第)(.*)$/s) {
		if ($debug2) {print STDERR "871 ($1)($2)($3)\n"; getc;}
		$juan_reCount=1;
		$juan = $1 . &cjuan($2, $3);
		#回傳的$juan 含 <juan fun="open" n="1open" n="2">, 必須把 n="1open" 刪掉
		#而且 <mulu type="卷" n="1"/> 更正為 <mulu type="卷" n="2"/>
		if ($juan =~ /( n=\"(\d+)open\")/) 
		{
		    $juan =~ s/$1//;
		    $juan =~ s#n="$currentJuan"#n="$cjn"#g;
		    #$currentJuan=$cjn;
		 }  
		if ($debug2) {print STDERR "873 ($currentJuan)($cjn)\n($juan)\n"; getc;}
	}
	
	if ($juan =~ /open">/){
		$juan =~ s/open">/open" n="1">/;
		if ($debug) {print STDERR "880 printOutJuan=[$juan]\n$currentJuan\n";getc;}		
		$jcnt = 1; # juan count 記錄目前到第幾卷
	}
	if ($juan =~ /open/){
		$injuan = 1;
	} else {
		$injuan = 0;
	}
        
         if ($juan =~ /open/){
		$juan =~ /n=\"(\d+)\"/;
		my $s = $1;
		$juanNum = $s;
		$s =~ s/^0//;
		$s =~ s/^0//;
		
		if ($debug) {print STDERR "905\n$juan\n$juanNum=$currentJuan\n";}
		if ($debug) {print STDERR "\n\n<milestone unit=\"juan\" n=\"$s\"\/>\n\n";}
		$juan =~ s#<mulu>#<mulu type=\"卷\" n=\"$s\"/>#;
		if ($currentJuan != $juanNum) {
			#edith modify 2005/5/20 內文裡沒有相同的 milestion 卷數, 才要加
			#s 將字串視為一行
			if ($buf !~ /<milestone unit="juan" n="$s"\/>/)
			{
			    $juan =~ s/(<juan[^>]*?>)/<milestone unit="juan" n="$s"\/>$1/s;
			 }
			$currentJuan = $juanNum;
		}
		$juanOpen=1;
		if ($debug) {print STDERR "\n912\n$juan\n\n";getc;}
		#$open{"juanBegin"} = 0; #edith modify 2005/3/9
	} else {
		#$open{"juanEnd"}=0;	#edith modify 2005/3/9
	}
		
	#2005/3/15 以空字串取代原字串, 以免 sub Tag_J 裡會跑inline_tag();時字串重覆放入$buf
	$space="";
	#edith modify 2005/5/9 改寫在這段裡:   }elsif ($tag eq "j=" or $tag =~ /J/) {  
	#if ($juan =~ /$text_J/) {$juan =~ s/\Q$text_J\E//g;}
	
	if ($juan =~ /|/) 
	{
		$juan =~ s/|//g;
		if ($debug) {print STDERR "896|juan=[$juan]\n"; getc;}	
	}
	
	$text_J="";	
	$buf .= $juan;   #edith hide 2005/5/20	
	#$juan_tmp = $juan; #edith modify 2005/5/20
	#edith modify 2005/5/20 重新計算卷數
         if ($juan_reCount)
         {
            $currentJuan=$cjn;
            $juan_reCount=0;
         }
	if ($debug) {
		print STDERR "914 $juan_tmp=\n$juan_tmp\n";
		getc;
	}
	#edith modify 2005/3/9 先hide掉, </jhead></juan>在 checkClose() 做
	if ($open{"jhead"}>0) {
		$buf .= "</jhead>";
		$open{"jhead"} = 0;
	}
	$buf .= "</juan>";
	$text_J = "";
	$juan = "";
}

sub tag_Q {
	my $tag = shift;
	my $level;
	$n_rend=0; # 結束 n 縮排的繼承
	if ($tag=~/(\d+)/) {
		$level=$1;
	} else {
		$level=1;
	}
	
	if ($open{"head"} == 0){
		#edith modify 2005/5/19 遇到Q, 省略相對的結束符號( </e> </n> </o> </w>)然後結束上一個相關tag
		#<e> <d>、<n> <d> → form def entry
		#<o> <u> →  div p 
		#<w> <a>→ sp dialog
		#$buf .= &checkopen("l","lg", "p", "title", "item", "list", "sp", "dialog");
		$buf .= &checkopen("l","lg", "p", "title", "item", "list", "sp", "dialog", "form", "def", "entry",);
		$in_div_note=0; #程式原遇到 </n>會將某參數歸零$in_div_note=0, 判斷是不是在 <div? type="note"> 裡
	}
	#if ($debug2) { print STDERR "890 in tag_Q() tag=[$tag]\n"; }
	#if ($debug2) { print STDERR "892 head個數=[" . $open{"head"} ."]\n"; }
	if ($debug2) { print STDERR "922 tag=[" . $tag ."]\n"; }
	
	if ($tag =~ /=/) {
		$head .= $lb;
	} else {
		$wq=0;
		$buf .= &checkopen("head"); # added 2004/6/25 11:32上午
		
		while ($level <= $open{"div"}) {
			$buf .= "</div" . $open{"div"} . ">";
			$open{"div"}--;
			$open{"commentary"}=0;
			$div_orig = 0;
		}
		# markedy by Ray 2006/9/18 11:19上午
		#if ($tag =~ /X/ and $jx=~/[Jx]/) {
		#	$currentJuan++;
		#	$buf .= "<milestone unit=\"juan\" n=\"$currentJuan\"/>";
		#	if ($debug) {
		#		print STDERR "888 add milestone $currentJuan\n";
		#	}
		#	$jx='X';
		#}
		while ($level > $open{"div"}+1) {
			$open{"div"}++;
			$head .= "<div" . $open{"div"} . ">";
		}
		if ($tag =~ /D/) { 
			$divtype = "pin"; 
			$head .= $lb;
		} elsif ($tag =~ /K/) { 
			$divtype = "hui"; 
			$head .= $lb;
		} elsif ($tag =~ /V/) { 
			$divtype = "fen"; 
			$head .= $lb;
		} elsif ($tag =~ /W/) { 
			$divtype = "w";
			if ($tag =~ /x/) {
				if (not $inw) {
					$open{"div"}++;
					$buf .= $lb;
					$buf .= "<div" . $level . " type=\"$divtype\"><mulu level=\"$level\" label=\"附文\"/>";
					$level++;
				} else {
					$head .= $lb;
				}
				$divtype="xu";
			} else {
				if ($tag=~/Q/) {
					$wq=1;
				}
				$head .= $lb;
			}
			$inw=1;
		} elsif ($tag =~ /Q/) { 
			$divtype = "other"; 
			#edith modify 2005/3/15 $tag_J_Q 代表已跑過 tag_J, 不用再加 $lb
			if (not $tag_J_Q) {
				$head .= $lb;
				$tag_J_Q=0;
			}
		} elsif ($tag =~ /[xX]/) { 
			$divtype = "xu"; 
			$head .= $lb;
		}
		$open{"div"}++;
		$open{"head"}++;
		$head .= "<div" . $level . " type=\"$divtype\"><mulu><head>";
	}
	
	$pMarginLeft=''; # 新的 div 開始, 不再繼承上一個 P 的 margin-left
	if ($debug2) { 
		print STDERR "\n1004 tag_Q() label=[$label] head=[$head]\n"; 
	}
	
	inline_tag();
	
	if ($debug2) { 
		print STDERR "960 end tag_Q() label=[$label] head=[$head]\n"; 
		print STDERR "962 head個數=[" . $open{"head"} ."]\n\n";
		getc;		
	}
}

sub gaijiReplace {
	my $s = shift;
	#if ($s =~ /搪/ || $s =~ /髣/) {$edith=1;}
	
	# 不含 ">"(\x3e), "["(\x5b), "]"(\x5d) 的 big5
	my $p="(?:[\x80-\xff][\x00-\xff]|[\x00-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])";
	#if ($edith eq 1) {print STDERR "\n995|$s\n";}
	$s =~ s#(\[辟/石\]\[石\*歷\])#&rep($1)#egx;
	$s =~ s#(礔\[石\*歷\])#&rep($1)#egx;
	$s =~ s#(\[跍\*月\]跪)#&rep($1)#egx;
	#$s =~ s#(琅\[王\*耶\])#&rep($1)#egx;
	$s =~ s#(\[立\*令\]竮)#&rep($1)#egx;
	#if ($edith eq 1) {print STDERR "\n1001|$s\n";}
	$s =~ s#(髣髣\[髟/弗\]\[髟/弗\])#&rep($1)#egx;	
	$s =~ s#(髣\[髟/弗\])#&rep($1)#egx;
	#if ($edith eq 1) {print STDERR "\n1004|$s\n";}
	#edith modify: 2005/1/17→搪[打-丁+突] 換成→ &CI0005;
	$s =~ s#(搪\[打-丁\+突\])#&rep($1)#egx;	
	$s =~ s#(\[仁\-二\+唐\]\[仁\-二\+突\])#&rep($1)#egx;
	$s =~ s#(\[商\*鳥\]\[羊\*鳥\])#&rep($1)#egx;
	
	# X85n1592_p0281b14_##[(廉-(前-刖))-〦+立)]纖如此)
	#$s =~ s/$pattern/&rep($1)/egx;		
	$s =~ s/(\[$p+?\])/&rep($1)/egx;		
	#if ($edith eq 1) {print STDERR "\n1008|$s\n";$edith=0;getc}
	return $s;
}

sub final {
	print STDERR "最後階段處理....\n";
	opendir DIR, ".";
	my @all = grep /\.xml$/, readdir DIR;
	close DIR;
	foreach $file (@all) {
		print STDERR "$file\n";
		my $xml='';
		open I, $file or die;
		while (<I>) {
			$xml .= $_;
		}
		close I;
		#2004/9/23 01:42下午
		#$xml =~ s/(<lb[^>]*?>)((?:\n<lb[^>]*?>)+)(<milestone[^>]*?>)/$1$3$2/sg;
		$xml =~ s/(<lb[^>]*?>)((?:\n<lb[^>]*?>)+)(<milestone[^>]*?>(<mulu[^>]*?>)?)/$1$3$2/sg;
		
		# 如果 </head>, </p> 前沒文字移到上一行最後
		# </cell>不用移
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(p|div\d+|list)>)+)#$2$1#sg;
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(head|p|div\d+|list)>)+)#$2$1#sg;
		$xml =~ s#((?:\n<[lp]b[^>]*?>(?:<mulu[^>]*?>)*)+)((</(head|p|div\d+|list)>)+)#$2$1#sg;
		###edith modify: 2005/1/25 </item></list>前沒文字移到上一行最後
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(head|item|p|div\d+|list)>)+)#$2$1#sg;
		###edith modify: 2005/1/31 </form>前沒文字移到上一行最後
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(form|head|item|p|div\d+|list)>)+)#$2$1#sg;
		###edith modify: 2005/5/6 </l>, 2005/5/10 </sp></lg>, 2005/5/11</def></entry>, 2005/5/24 dialog 前沒文字移到上一行最後
		$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(annals|date|def|dialog|entry|event|form|head|item|p|div\d+|list|l|lg|sp)>)+)#$2$1#sg;

		open O, ">$file" or die;
		print O $xml;
		close O;
	}
	
	if ((scalar @notfound)>0) {
		print STDERR "找不到CB碼的組字式：\n";
		foreach $s (@notfound) {
			print STDERR "$s\n";
		}
	}
}

sub readSource {
	print STDERR "讀 來源檔...\n";
	open(T, $cfg{"laiyuan"}) || print STDERR "can't open laiyuan\n";
	while(<T>){
	#S:蕭鎮國
		chomp;
		if ($_ eq '') {
			next;
		}
		if (/^.:/){
			($key, $value) = split(/:/, $_);
			($c, $e) = split(/, /, $value, 2);
			$namc{$key} = $c; 
			$name{$key} = $e; 
		} else {
	#4SJ    T1421-22-p0001 K0895-22 30 彌沙塞部和醯五分律(30卷)【劉宋 佛陀什共竺道生等譯】
	#SC4F   T0001-01-p0001  V1.12  2001/04/01   22  長阿含經           【後秦 佛陀耶舍共竺佛念譯】    K0647-17
	#CR     P1684-174-p0785 V1.0   2010/07/02    1  佛遺教經論疏節要   【宋 淨源述】
			($ls, $sid, $v, $k, $juan, $title, $rest) = split(/\s+/, $_, 7);
			#($tnum, $tvol, $d1, $tpage) = unpack("A6 A2 A1 A5", $sid);		# 冊數可能大於 2, 此行不用了
			$sid =~ /(.*?[\-_])(.*?)[\-_](.{5})/;
			$tnum = $1;
			$tvol = $2;
			$tpage = $3;
			
			if ($tnum !~ /^[TXJHWIABCDFGKLMNPQSU]/) {
				next;
			}
			$rest =~ s/\([ 0-9].*//;
			$rest = gaijiReplace($rest);
			$title = gaijiReplace($title); # added 2004/6/25 11:02上午
			$tnum =~ s/-//;
			$tnum =~ s/_//;
			$tnum =~ s/[TXJHWIABCDFGKLMNPQSU]/n/;
			$tit{$tnum} = $title;
			$extent{$tnum}=$juan;
			#die "no title $_\n" if ($tnum eq "" && $tnum ne "");
			die "$tnum no title $_\n" if ($tnum ne "" and $title eq '');
			print STDERR "1163 $tnum \t$title\n";
			$rest=~/【(.*?)】/;
			$author{$tnum}=$1;
			$sid = $tnum;
			$sid =~ s/n//;
	#		print STDERR "$tnum\t$sid\n";
			@ly = split(//, $ls);
			$outc = "";
			$oute = "";
			for $l (@ly){
				next if ($namc{$l} eq "");
				$outc .= "$namc{$l}，";
				$oute .= "$name{$l}, ";
			}
			$outc =~ s/，$//;
			$oute =~ s/, $//;
			$lyc{$sid} = $outc;
			$lye{$sid} = $oute;
		}
	}
}

sub readSutra {
	#
	# 讀經文檔
	#
	$firstLine=1;
	$oldnum = 0;
	$oldp = 0;
	$oldPage = 0;
	$x = "";
	open(T, $cfg{"jingwen"}) || die "can't open jingwen\n";
	while(<T>){
		$rendOfLastLine = $rendOfThisLine;
		$rendOfThisLine = '0';
		$rend = "0";
		$current_pos=1;
		chomp;
		if (/^#/ or $_ eq '') {
			next;
		}
		#if (/146c15/) { $debug=1; }
		if ($debug) {
			print STDERR "讀進 $_\n";
			watch_buf(1205);
			getc;
		}
		# 為避免有類似 [<□>>XX] 混淆了 >> 符號, 所以先處理 <□>
		s/<□>/&unrec;/g;	
		#($aline, $text) = unpack("A20 A*", $_);	# 冊數會大於 3 碼, 所以不用這行
		/^(\D*\d*n.{16})(.*)/;
		$aline = $1;
		$text = $2;
		if ($debug) { 
			print STDERR "932 align=[$aline] text=[$text]\n"; 
		}
		#T12n0374_p0365a01N##No. 374
		#($vol, $num, $p, $sec, $line, $tag) = unpack("A3 A6 A5 A1 A2 A3", $aline);	# 冊數會大於 3 碼, 所以不用這行
		
		$aline =~ /(\D*\d*)(n.{5})(p.{4})(.)(..)(...)/;
		$vol = $1;
		$num = $2;
		$p = $3;
		$sec = $4;
		$line = $5;
		$tag = $6;
		
		$WQ_n=0;    #例如:X74n1496_p0784a11WQ3 計算一行中的 <n> 有幾個
		
		##edith modify:2004/12/9 行首有 F, 要計算每行<c>個數, 其初始值為1
		if ($tag =~ /F/)
		{ 
			$c_Num = 0;	##edith modify:2004/12/29 初始值改成0
			$a_s = $text;
			##edith modify 2005/3/7 例如 X76n1516_p0018b13f##<c>辛丑(二)<c>(章武元)(據西蜀)<c2>(元)(全有吳楚)
			#edith modify 2005/3/21 例如 X76n1517_p0203c14Q#2韓文公別傳Ｃ刑部尚書　孟簡　集
			#C 要加在空格前面
			#edith modify 2005/4/21 新增</o>			
			while ($a_s =~ m#^((?:$big5)*?)(　　|　|Ａ|<a>|Ｂ|Ｃ|<c(?: r)?\d*?>|<d>|Ｅ|<e>|</e>|</F>|Ｉ|<I\d*?>|<J>|<j>|</L\d*?>|<n[,\d]*>|</n>|<o>|</o>|Ｐ|Ｓ|<p[,\-\d]*>|</P>|</?Q\d*>|<S>|<u>|</u>|<w>|</w>|Ｙ|Ｚ)(.*)$#) 
			{
				$a_text .= $1;
				$a_i_tag = $2;
				$a_s = $3;		
				#if ($a_i_tag eq "<c>")	{$c_Num++;}	#計算<table cols="?"> cols 個數 (行首有F)		
				if ($a_i_tag =~ /^<c/)	{$c_Num++;}	#計算<table cols="?"> cols 個數 (行首有F)		
			}
		}

		#edith modify 2005/3/8 start: <cell> 有跨行的情況, 所以<table cols="?">
		#cols 個數 $c_Num要繼續累加
		if ($tag !~ /F|f/ && $startRow) #代表不是表格的第一行, 而且<cell>仍在第一列裡
		{ 
			$a_s = $text;
			#edith modify 2005/3/21 例如 X76n1517_p0203c14Q#2韓文公別傳Ｃ刑部尚書　孟簡　集
			#while ($a_s =~ m#^((?:$big5)*?)(　　|　|Ａ|<a>|Ｂ|Ｃ|<c\d*?>|<d>|Ｅ|<e>|</e>|</F>|Ｉ|<I\d*?>|<J>|<j>|</L\d*?>|<n[,\d]*>|</n>|<o>|Ｐ|Ｓ|<p[,\-\d]*>|</P>|</?Q\d*>|<S>|<u>|</u>|<w>|</w>|Ｙ|Ｚ)(.*)$#) 
			#edith modify 2005/4/21 新增</o>
			while ($a_s =~ m#^((?:$big5)*?)(　　|　|Ａ|<a>|Ｂ|Ｃ|<c\d*?>|<d>|Ｅ|<e>|</e>|</F>|Ｉ|<I\d*?>|<J>|<j>|</L\d*?>|<n[,\d]*>|</n>|<o>|</o>|Ｐ|Ｓ|<p[,\-\d]*>|</P>|</?Q\d*>|<S>|<u>|</u>|<w>|</w>|Ｙ|Ｚ)(.*)$#) 
			{
				$a_text .= $1;
				$a_i_tag = $2;
				$a_s = $3;		
				if ($a_i_tag eq "<c>")	{$c_Num++;}
			}
			#edith modify 2005/5/18 <table cols="2"> 要在 <pb> 下一行
			#$buf_table_new= "\n". '<table cols="' . $c_Num .'">' . $lb;
			$buf_table_new= "\n". '<table cols="' . $c_Num .'">' . $lb_temp;
			$pb_flag=0;
	                   $lb_temp="";
			if ($debug2) {print STDERR "\n1184|$buf_table_new\n";getc;}
			$buf =~ s/$buf_table/$buf_table_new/;	#第一次取代		
			$buf_table	= $buf_table_new;	#第二次以上取代時用的
		}#edith modify 2005/3/8 end

# T 大正新脩大藏經 (Taisho Tripitaka) （大正藏） 【大】
# X 卍新纂大日本續藏經 (Manji Shinsan Dainihon Zokuzokyo) （新纂卍續藏） 【卍續】
# J 嘉興大藏經(新文豐版) (Jiaxing Canon(Xinwenfeng Edition)) （嘉興藏） 【嘉興】
# H 正史佛教資料類編 (Passages concerning Buddhism from the Official Histories) （正史） 【正史】
# W 藏外佛教文獻 (Buddhist Texts not contained in the Tripitaka) （藏外） 【藏外】 
# I 北朝佛教石刻拓片百品 (Selections of Buddhist Stone Rubbings from the Northern Dynasties) 【佛拓】

# A 金藏 (Jin Edition of the Canon) （趙城藏） 【金藏】
# B 大藏經補編 (Supplement to the Dazangjing) 　 【補編】
# C 中華大藏經 (Zhonghua Canon) （中華藏） 【中華】
# D 國家圖書館善本佛典 (Selections from the Taipei National Central Library Buddhist Rare Book Collection) 【國圖】
# F 房山石經 (Fangshan shijing) 　 【房山】
# G 佛教大藏經 (Fojiao Canon) 　 【教藏】
# K 高麗大藏經 (Tripitaka Koreana) （高麗藏） 【麗】
# L 乾隆大藏經(新文豐版) (Qianlong Edition of the Canon(Xinwenfeng Edition)) （清藏、龍藏、乾隆藏） 【龍】
# M 卍正藏經(新文豐版) (Manji Daizokyo(Xinwenfeng Edition)) （卍正藏） 【卍正】
# N 永樂南藏 (Southern Yongle Edition of the Canon) （再刻南藏） 【南藏】
# P 永樂北藏 (Northern Yongle Edition of the Canon) （北藏） 【北藏】
# Q 磧砂大藏經(新文豐版) (Qisha Edition of the Canon(Xinwenfeng Edition)) （磧砂藏） 【磧砂】
# S 宋藏遺珍(新文豐版) (Songzang yizhen(Xinwenfeng Edition)) 　 【宋遺】
# U 洪武南藏 (Southern Hongwu Edition of the Canon) （初刻南藏） 【洪武】

# R 卍續藏經(新文豐版) (Manji Zokuzokyo(Xinwenfeng Edition)) （卍續藏）
# Z 卍大日本續藏經 (Manji Dainihon Zokuzokyo)

		# TXJHWIABCDFGKLMNPQSU
		if ($vol =~ /^T/) {
			$wit="【大】";
		} elsif ($vol =~ /^X/) {
			$wit="【卍續】";
		} elsif ($vol =~ /^J/) {
			$wit="【嘉興】";
		} elsif ($vol =~ /^H/) {
			$wit="【正史】";
		} elsif ($vol =~ /^W/) {
			$wit="【藏外】";
		} elsif ($vol =~ /^I/) {
			$wit="【原】";		# 佛拓百品
		} elsif ($vol =~ /^A/) {
			$wit="【金藏】";
		} elsif ($vol =~ /^B/) {
			$wit="【補編】";
		} elsif ($vol =~ /^C/) {
			$wit="【中華】";
		} elsif ($vol =~ /^D/) {
			$wit="【國圖】";
		} elsif ($vol =~ /^F/) {
			$wit="【房山】";
		} elsif ($vol =~ /^G/) {
			$wit="【佛教】";
		} elsif ($vol =~ /^K/) {
			$wit="【麗】";
		} elsif ($vol =~ /^L/) {
			$wit="【龍】";
		} elsif ($vol =~ /^M/) {
			$wit="【卍正】";
		} elsif ($vol =~ /^N/) {
			$wit="【南藏】";
		} elsif ($vol =~ /^P/) {
			$wit="【北藏】";
		} elsif ($vol =~ /^Q/) {
			$wit="【磧砂】";
		} elsif ($vol =~ /^S/) {
			$wit="【宋遺】";
		} elsif ($vol =~ /^U/) {
			$wit="【洪武】";
		}
		$tag =~ s/#//g;

		#these tags are not used yet!	
		#this line has characters in siddham script	
		$tag =~ s/H//;
		
		#there are some images on this location	
		$tag =~ s/G//;
		
		#if ($tag =~ /\?/){
		#if ($tag =~ /[\?F]/){	###edith hide 2004/12/9 行首F另作處理了
		#	$qu = "<xx/>";
		#	if ($debug) {
		#		print STDERR "924 test=$text qu=$qu\n";
		#	}
		#} else {
		#	$qu = "";
		#}
		$tag =~ s/\?//;
		#$tag =~ s/F//; edith hide 2004/12/9 行首F另作處理了
		
		if ($text=~/^($big5a*?)(Ｑ.*)$/) {
			$text = "$1<xx/>$2";
		}
		#	die if ((length($tag) > 1 )&& ($tag  !~ /W[ZP]/));
		$num =~ s/_//;
		$p =~ s/p//;
		if ($num ne $oldnum){ changeSutra(); }
		
		if ($p ne $oldPage){
			$count = 0;
			$figureCount=0;
			$oldPage = $p;
		}
			
		if ("$p$sec" ne $oldp){
		#		print STDERR "$oldp:$line-P${p}S${sec}..$num:$oldnum\n";
			$oldp = "$p$sec";
		#<PB ed="T" id="T10.0302.0912c" n="0912c">
			$num =~ s/n//;
			$ed=substr($vol,0,1);
			$pb = "\n<pb ed=\"$ed\" id=\"$vol.$num.$p$sec\" n=\"$p$sec\"/>";
			#if ($debug2) {print STDERR "\n1235|$pb\n";getc;}
		} else {
			$pb = ""
		}
		
		# added by Ray 2000/11/28 10:38上午
		# 校勘符號 [99] => <anchor>
		$text =~ s/\[(\d{2,3}[A-Z]?)\]/<anchor id=\"fn${vol}p$p$sec$1\"\/>/g;
		#$text =~ s/\[(\d{2,3})\]/<anchor type="footnote" n=\"$1\"\/>/g;
		while ($text =~ /\[＊\]/) {
			$count ++;
			my $id = sprintf("fx${vol}p$p$sec%2.2d",$count);
			$text =~ s/\[＊\]/<anchor id=\"$id\"\/>/;
			#$text =~ s/\[＊\]/<anchor type="＊" n=\"$count\"\/>/;
		}

		while ($text =~ /【圖】/) {
			$figureCount ++;
			my $id = sprintf("${vol}p${p}_%2.2d",$figureCount);
			$text =~ s/【圖】/<figure entity=\"Fig$id\"\/>/;
			$figureEnt .= "<!ENTITY Fig$id SYSTEM \"figures/$id.gif\" NDATA GIF>\n";
		}

		if ($debug) { print STDERR "998| $text\n"; }
		# don't do this in the line that contains the number
		if ($tag ne "N"){
			$text =~ s/<([0-9][0-9])>/#$1#/g;
			if ($debug) {print STDERR "1200| $text\n";}
			$text = gaijiReplace($text);
			if ($debug) {print STDERR "1202| $text\n";}
			corr2app();
		# wegen gaiji-tag
			$text =~ s/sic="&([^;]*);"/sic="$1"/g;
		#		
			if ($debug) {print STDERR "1207| $text\n";}
			#$text =~ s/\(/<note type="inline">/g;
			if ($debug2) {print STDERR "1311|$text\n";	getc;}
                            #edith modfiy 2005/5/9 starting
                            #X74n1467_p0113b18S##　(十方三世佛　　阿彌陀第一　　九品度眾生　　威德無窮極　　我今大歸依　　懺悔三業罪
                            #變成 X74n1467_p0113b18S##(　十方三世佛　　阿彌陀第一　　九品度眾生　　威德無窮極　　我今大歸依　　懺悔三業罪
                            #XML才會轉出 <note place="inline">在<l>的前面
                            #<lg id="lgX74p0113b1801"><note place="inline"><l>十方三世佛</l><l>阿彌陀第一</l><l>九品度眾生</l><l>威德無窮極</l><l>我今大歸依</l><l>懺悔三業罪</l>
			#$text =~ s/\　\(/\(　/g;
			 #edith modfiy 2005/5/9 ending
								
			# 小括號 (...) 取代為 <note place="inline">....</note>
			$text = rep_note($text);
			
			# marked 2004/6/23 03:22下午
			#if ($text =~ /(Ｐ|Ｚ|<p.*?>)/ and $tag !~ /[CIMPpQs]/) {
			#		$text = inlinep($text);
			#}
			if ($text =~/\xf9[\xd6-\xdc]/){
				@ch = ();
				push(@ch, $text =~ /([\xa1-\xfe][\x40-\xfe]|[\x00-\xfe])/g);
				if ($debug) {print STDERR "1219|$text\n";	}
				for $c (@ch){
					#if ($debug) {print STDERR "1219|$c\n";	getc;}
					$c = &rep2($c) if ($c=~/\xf9[\xd6-\xdc]/);
		 		}
				$text = join("", @ch);
				if ($debug) {print STDERR "1224|$text\n";	}
			}
		
		#		$text =~ s/(\&[^;]*;)/&revrep($1)/eg;
		}
		#if ($debug2) { print STDERR "1271 before call tag_Q() text=[$text]\n"; }
		$rend = '0';
		if ($tag !~ /[LQIxX]/) { # LQIxX 後面的數字表示層次，不是空格
			if ($tag =~ /(\d)/) { 
				$rend = $1; 
				$tag =~ s/$rend//;
			}
			#if ($tag =~ /([a-i])/) { 
			if ($tag =~ /([a-d])/) { 
				$rend = $1; 
				$tag =~ s/$rend//;
				$rend = ord($rend) - ord('a') + 10;
			}
		}
		
		# k 強迫換行
		$lb_ed = substr($vol, 0,1);
		if ($tag =~ /k/) {
			$lb_ed = "C " . $lb_ed;
		}
		
		$lb = "$pb\n<lb ed=\"$lb_ed\" n=\"$p$sec$line\"/>$qu";
		if ($firstLine) {
			#$lb .= "\n" . '<milestone unit="juan" n="1"/>';
			$firstLine=0;
			#$currentJuan=1;
		}
		#$lb .= $qu;
		watch_buf(1259);
		checkClose(); # 檢查上一行應該 close 的 tag
		
		#W
		#if ($tag =~ /^W/) {  #changed meaning of W 10.10.1999
		if ($tag =~ /^W/) {
			watch_buf(1263);
			# X72n1442_p0723b05Wx#No. 1442-附
			# if ($tag !~ /[Qx]/) {
			if ($tag !~ /[Qx]/ and $text !~ /^<Q/) { # 2005/9/29 15:20 by Ray
				$tag =~ s/^W//;
				$tag = "_" if ($tag eq "");
				if ($inw == 0){
					$buf .= &checkopen ("p");
					$open{"div"}++;
					$buf .= "$lb<div" . $open{"div"} . " type=\"w\"";
					#$buf .= rend();
					$buf .= ">";
					$lb = '';
					$inw = 1;
				}
			}
			watch_buf(1277);
		} else { 
			if ($debug) {
				print STDERR " " x $tab, "1430 inw=$inw\n";
			}
			if ($inw) {
				if ($text !~ /<\/Q/) {
					$buf .= &checkopen ("p", "l", "lg");   #edith modify 2005/5/11: </div?> 結束之前要先結束 </l></lg>
					if ($open{"div"}>0) {
						$buf .= "</div" . $open{"div"} . ">";
						$open{"div"}--;
					}
				}
			}
			$inw = 0; 
		}
		
		if ($tag eq "N"){
		#This needs some attention: "N"lines > 1 not yet handled!
			$buf .= "$lb";
			if ($open{"head_no"} == 0){
				$buf .= "<head type=\"no\">";
				$open{"head_no"}++;
			}
			$buf .= "$text";
			#print "</head>";
		} elsif ($tag =~ /L/) { 
			tag_L();
		} elsif ($tag =~ /[DKVQxX]/) {
			#$head .= "$lb";
			if ($debug2) { print STDERR "1323 before call tag_Q() text=[$text]\n"; }
			tag_Q($tag);
		#} elsif ($tag =~ /A/) {	
			#tag_a();	#edith note: 2005/2/23 這行被hide, 也許在別處處理了
		} elsif ($tag =~ /[ABEY]/) {
			$pMarginLeft='';
			tag_b();
		} elsif ($tag =~ /C/) {	
			tag_c();
		} elsif ($tag =~ /e/) {	
			tag_e();
		} elsif ($tag eq "Ff") {	###edith modify 2004/12/9 例如:X78n1546_p0165a06WFf	內含 Ff
			tag_Ff();	
		} elsif ($tag eq "F") {	###edith modify 2004/12/9
			tag_F();	
		} elsif ($tag =~ /f/) {		###edith modify 2004/12/9 例如:X78n1546_p0165a07Wf#	內含 f
			tag_f();
		} elsif ($tag =~ /I/) {		
			tag_I();			
		} elsif ($tag =~  /J/) { 
			tag_J();
		#} elsif ($tag eq "j") {  edith modify 2005/5/9
		} elsif ($tag =~  /j/) {
			if ($debug2) {print STDERR "1471|edith($oldtag)\n"; getc;}
			tag_j();
		# x60n1135_p0745a23k#_慈雲灌頂行者續法合十題
		#} elsif ($tag eq "k") { 
		} elsif ($tag eq "k" or $tag eq "k_") { 
			$buf.=$lb;
			inline_tag();
		} elsif ($tag =~ /M/) { 
			tag_m();  #M 目錄部的經名
		} elsif ($tag =~ /n/) { 
			tag_n();  #n 段落後註解 2004/7/1 03:47下午
		} elsif ($tag =~ /[pPZ]/) { 
			tag_P();
		#} elsif ($tag eq "R") {           #R 目錄部中的譯者或作者
		} elsif ($tag =~ /R/) {           #edith modify:2005/3/15 有 R or R=
			$buf .= checkopen("title");
			$buf .= "$lb$text";
		#} elsif ($tag eq "R=") {           #edith note:2005/3/15 等同與上一行的 "R"
		#	
		} elsif ($tag eq "r") { 
			tag_r();
		} elsif ($tag =~ /[ST]/) {	
			tag_S();
		} elsif ($tag =~ /[st]/) { 
			tag_s();
		} elsif ($tag =~ /^_?k?$/) {
			watch_buf(1353);
			#if ($debug2) {print STDERR "\n1412|tag=$tag\n";}
			if ($text =~ /^<w>/) {
				$buf .= &checkopen("head");
			}
			# 處理 inline tag 前, 要先把 lb 印出去
			if ($open{"head"}>0) {
				$head .= $lb;
			} else {
				# x58n1013_p0519a02_##之。假有學無離識非有。<I2>二頂位。依明增定。發生上
				$buf .= $lb;
			}
			inline_tag();
			watch_buf(1363);
		} elsif ($tag eq 'W') {
			$buf .= $lb;
			inline_tag();
		} else {
			die "$tag\nunrecognized tag:[$tag] $_\n";
		}
		$oldtag = $tag;
		watch_buf(1235);
		if ($debug) {
			print STDERR "1260 一行處理完畢 wq=$wq inw=$inw open{div}=" . $open{"div"} . "\n";
			getc;
		}
	}
}

sub tag_r {
	if ($open{"div"} < 1){
		$lb .= "<div1>";
		$open{"div"}++;
	}
	my $id="p${vol}p$p$sec${line}01";
	$buf .= &checkopen("head", "byline", "l", "lg", "p", "title");
	$buf .= "$lb<p id=\"$id\" type=\"pre\">";
	$open{"r"}++;
	inline_tag();
	#$buf .= $text;
}

sub tag_x {
	if ($debug) {
		print STDERR "1190 buf=[$buf]\n";
	}
	my $tag = shift;
	my $level;
	if ($tag=~/(\d+)/) {
		$level=$1;
	} else {
		$level=1;
	}
	
	$divtype = "xu";
	#$head .= "$lb";
	if ($open{"head"} == 0){
		$buf .= &checkopen("l", "lg", "p", "title", "item", "list");
	}
	if ($tag !~ /=/) {
		while ($level <= $open{"div"}) {
			$buf .= "</div" . $open{"div"} . ">";
			$open{"div"}--;
		}
		while ($level > $open{"div"}+1) {
			$open{"div"}++;
			$head .= "<div" . $open{"div"} . ">";
		}
		$open{"div"}=1;
	} else {
		$head .= $lb;
	}
	inline_tag();
	# modified by Ray 2000/3/27 10:04AM
	#print "$text";
	if ($open{"head"}>0) {
		$label .= $text;
		$head .= $text;
	} else {
		$buf .= $text;
	}
	if ($debug) {
		print STDERR "1215 head=[$head] text=[$text]\n";
	}
}

sub tag_a {
	if ($debug2) {	print STDERR "1495 a=[$text]\n";getc;}
	
	if ($open{"byline"}>0 and $tag!~/=/){
		$buf .= "</byline>";
		$open{"byline"}--;
	}
	$buf .= "$lb";
	if ($open{"byline"} == 0){
		$buf .= "<byline type=\"author\">";
		$open{"byline"}++;
	} 
	if ($text =~ /^($big5*?)Ｂ(.*)$/) {
		$text = $1 . "</byline><byline type=\"other\">" . $2;
	}
	$buf .= "$text";
}

sub tag_c {
	if ($debug2) {
		print STDERR "1516 begin tag=$tag\n";
		getc;
	}
	#if ($oldtag =~ /YAE/){
	if ($oldtag =~ /[YAEB]/){
		$buf .= "</byline>";
		$open{"byline"}=0;
	}
	$buf .= "$lb";
	if ($debug) {
		print STDERR "1264 open byline: " . $open{"byline"} . "\n";
	}
	if ($open{"byline"} == 0){
		$buf .= "<byline type=\"collector\">";
		$open{"byline"}++;
	}
	if ($text =~ /($big5a)*(Ｐ|<p[,\-\d]*>)/) {
		$text = inlinep($text);
	}
	#$buf .= "$text";
	inline_tag();
	if ($debug2) {
		print STDERR '1272 end of tag_c(), open{"byline"}=' . $open{"byline"} . "\n";
	}
}

sub tag_b {
	if ($open{"byline"}>0 and $tag!~/=/){
		$buf .= "</byline>";
		$open{"byline"}--;
	}
	$buf .= "$lb";
	if ($open{"byline"} == 0){
		my $type;
		if ($tag=~/A/) {
			$type="author";
		} elsif ($tag=~/B/) {
			$type="other";
		} elsif ($tag=~/E/) {
			$type="editor";
		} elsif ($tag=~/Y/) {
			$type="translator";
		}
		$buf .= "<byline type=\"$type\">";
		$open{"byline"}++;
	} 
	inline_tag();
}

sub tag_e {
	#$buf .= &checkopen("p", "l", "lg", "def", "entry");
	#edith modify 2005/5/5
	#X74n1499_p1056a01e##一心奉請南嶽思大禪師立誓願文(拜觀同上)
         #x74n1499_p1056a02e##一心奉請天台智者大師別傳(拜觀同上)
	$buf .= &checkopen("p", "l", "lg", "def", "form" ,"entry");
	$buf .= $lb;

	#X74n1499_p1055c14e##一心奉請蓮宗寶鑑(拜觀同上)
	#x62n1202_p0650c11e##一心(阿彌陀經)<d><p,1>若有善男子善女人。聞說阿彌陀佛。執
	#if ($text !~ /<d>/ and $open{"div"} < 1)
	if ($open{"div"} < 1)
	{
	    $buf .= "<div1>";
	    $open{"div"}++;
        }        

	$buf .= "<entry><form>";
	$open{"entry"}++;
	$open{"form"}++;
	
	inline_tag();
}

sub tag_f {
	$buf .= &checkopen("p", "l", "lg", "def", "entry");	
	$lb =~ s/\n//g;	#edith modify 2004/12/9 $lb內含\n換行字元, 去掉只為了 .xml 內文的排版
	#$buf .= "\n<row>";
	#$buf .= "<cell>";	
	#$buf .= $lb;
	#$_temp="\n<row>"."<cell>" .$lb;
	#edith  modify 2004/12/29 <lb><row><cell>
	#$buf .= "\n<row>"."<cell>" .$lb;
	$buf .= "\n$lb<row>";		#$buf .= "\n$lb<row><cell>";	
	$open{"row"}++;
	#$open{"cell"}++;
	inline_tag();
}

sub tag_Ff {
	$buf .= &checkopen("p", "l", "lg", "def", "entry");
	$startRow=1;
	$buf_table="";
	$buf_table_new="";
	$pb_flag=0;
	$lb_temp="";
	if ($debug2) {print STDERR "1701|$lb\ntable cols=$c_Num\n";getc;}
	#$buf .= $lb;
	##edith modify:2004/12/9 行首有 F, 計算每行<c>個數填入 cols	
	#edith modify: 2004/12/29 <table>放在<lb><row><cell> 前面, 例如:X78n1546_p0165a05WQ1
	#<table cols="3">
	#<lb ed="X" n="0165a06"/><row><cell>戒珠淨土往生傳</cell><cell>王古寶珠集</cell><cell>新修往生傳</cell></row>
	#edith hide 2005/3/8 
	
	#edith modify 2005/5/18 <table cols="2"> 要在 <pb>
         #x74n1465_p0068b01Ff#<c><c>願我永離三惡道(一拜)
         #x74n1465_p0068b02_f#<c><c>願我常聞佛法僧(一拜)
         #<table cols="2">
         #<pb ed="X" id="X74.1465.0068b" n="0068b"/>
         #<lb ed="X" n="0068b01"/><row><cell></cell><cell>願我永離三惡道<note place="inline">一拜</note></cell></row>
	if ($pb=~ /<pb/)
	{
                $pb_flag = 1;	 
                $buf .= $pb;
                $lb_temp = $lb;
                $lb_temp=~ s#$pb##;  #去掉$pb
                if ($debug2) {print STDERR "1722|$pb\n";getc;}
                if ($debug2) {print STDERR "1723|$lb_temp\n";getc;}
	 }
	 else
	 {
                $lb_temp = $lb; 
	  }
	
	if ($c_Num >= 1)	#if ($c_Num >= 2)
	{
		$buf .= "\n". '<table cols="' . $c_Num .'">';
		#edith modify 2005/3/8, 2005/5/18<table cols="2"> 要在 <pb> 
		#$buf_table= "\n". '<table cols="' . $c_Num .'">' . $lb;		
		$buf_table= "\n". '<table cols="' . $c_Num .'">' . $lb_temp;
	}
	else
	{
		#$buf .= "<table>\n<row><cell>";
		$buf .= "\n<table>";
	}	
	
	#$buf .= $lb;
	#edith modify 2005/5/18<table cols="2"> 要在 <pb>
	$buf .= $lb_temp;
	
	$buf .= "<row>";	#$buf .= "<row><cell>";	
	$open{"table"}++;
	$open{"row"}++;
	#$open{"cell"}++;
	#edith modify: 2004/12/29 end
	inline_tag();
}

sub tag_F {
	$buf .= &checkopen("p", "l", "lg", "def", "entry");
	$buf .= $lb;
	$buf .= "<table>";
	$open{"table"}++;
	inline_tag();
}

sub tag_m {
	if ($open{"div"} < 1){
		$lb .= '<div1 type="jing"' . rend() . ">";
		$open{"div"}=1;
	}
	if ($debug) { print STDERR "436 text=[$text]\n"; }
	$buf .= checkopen("title", "p", "item");
	$buf .= $lb;
	if ($open{"list"}==0) {
		$buf .= "<list>";
		$open{"list"}++;
	}
	my $id="item${vol}p$p$sec${line}01";
	$buf .= "<item id=\"$id\"><title>";
	$open{"title"}++;
	$open{"item"}++;
	
	#if ($text =~ /^(.*)(<note type=\"inline\">.*)$/) {
	if ($text =~ /^(.*)(<note place=\"inline\">.*)$/) {
		$buf .= "$1</title>";
		$open{"title"}=0;
		$text = $2;
	}
	
	if ($text =~ /($big5)*Ｒ/ or $text =~ /($big5)*Ｐ/) {
		$text = inlinep($text);
		if ($debug) { print STDERR "500 ",$open{"title"},$open{"p"},"\n";  }
	}
	if ($debug) { print STDERR "459 text=[$text]\n"; }
	$buf .= "$text";
}

sub tag_n {
	$buf .= &checkopen("p", "def", "entry");
	$buf .= $lb;
		
	if (not $in_div_note) {
		$open{"div"}++;
		$buf .= "<div" . $open{"div"} . " type=\"note\">";
		$in_div_note=1;  
	}
	$buf .= "<entry";
	if ($rend != 0) {
		$buf .= ' rend="margin-left:' . $rend . 'em"';
		$n_rend=$rend;
	} else {
		$n_rend=0;
	}
	$buf .= "><form>";
	$open{"entry"}++;
	$open{"form"}++;
	inline_tag();
}

sub tag_S {
	$pMarginLeft=""; # 停止繼承 p 縮排
	if ($open{"div"} < 1){
		$lb .= "<div1 type=\"jing\">";
		$open{"div"}=1;
	}
	
	$buf .= &checkopen("head", "byline", "p", "item", "list");
	
	if ($open{"lg"} > 0){
		$lg = "";
	} else {
		$lgType='';
		my $id="lg${vol}p$p$sec${line}01";
		if ($tag =~ /T/) {
			#$lg = "<lg id=\"$id\" place=\"inline\">"; 
			$lg = "<lg id=\"$id\" type=\"abnormal\">"; 
			$lgType = "abnormal";			
		} else { 
			$lg = "<lg id=\"$id\">"; 
		}
	}
	#if ($lgType eq "inline") {
	#	if ($lg ne '') { $text = "<l>" . $text; } # 如果是偈頌的第一行
	#	$text =~ s#((　)+)#</l><l>$1#g;
	#} else {
	#	$text = "<l>" . $text;
	#	$text =~ s/(　)+/<\/l><l>/g;
	#	$text .= "</l>";
	#}
	#$text =~ s#^<l></l>##;
	#$buf .= "$lb$lg$text";
	$buf .= $lb;
	$buf .= $lg;
	$open{"lg"}++;
	inline_tag();
}

sub tag_I {
	#2005/5/10 edith modify : 前一行的 </l></lg> 要先結束, 例如:X74n1470_p0148c10S##
	#X74n1470_p0148c10S##　願共諸眾生　　往生華藏海　　極樂淨土中
         #X74n1470_p0148c11I##南無華藏世界海法界覺場法門之主入不思議解
	$buf .= &checkopen("l", "lg");
	
	$run_tagI = 1;	
	$tab++;
	#if ($open{"listhead"}>0) {
	#	$buf .= "</head>";
	#	$open{"listhead"}=0;
	#}
	#$buf .= $lb;
	if ($debug2) {	print STDERR " " x $tab, "1676 begin tag_I() tag=$tag\n";	}
	my $id="item${vol}p$p$sec${line}01";
	if ($tag !~ /=/) {
		my $level;
		if ($tag=~/(\d+)/) {
			$level=$1;
		} else {
			$level=1;
		}
		#$level++;
		item($level);
	} else {
		$buf .= $lb;
	}
	if ($debug2) {	print STDERR " " x $tab, "1690 inline_tag前 text=$text\n";	}
	inline_tag();
	if ($debug2) {	print STDERR " " x $tab, "1692 inline_tag後 text=$text\n";	getc;}
	$tab--;
}

sub tag_P {
	my $type='';
	if ($open{"div"} < 1){
		if ($tag =~ /Z/) {
			$type=" type=\"dharani\"";
		} else {
			#$type="jing";
		}
		#$lb .= "<div1$type" . rend() . ">";
		$lb .= "<div1$type>";
		$open{"div"}=1;
	}
	$buf .= &checkopen("head", "byline", "l", "lg", "p", "title");
	$type='';
	# mark by Ray 2003/8/13 10:30上午
	#if ($injuan == 0){
	#	$type="W";
	#}
	if ($tag =~ /Z/) {
		$type .= "dharani";
	} elsif ($tag =~ /W/) {
		$type .= "W";
	}
	
	if ($type ne '') {
		$type = " type=\"$type\"";
	}
	
	my $id = "p${vol}p$p$sec${line}01";
	#$pMarginLeft=rend();
	if ($rend ne '0') {
		$pMarginLeft = " rend=\"margin-left:${rend}em\"";
	} else {
		$pMarginLeft = '';
	}
	$buf .= $lb;
	if ($text !~ /^<p/) {
		$buf .= "<p id=\"$id\"$type$pMarginLeft>";
	}
	$open{"p"}++;
	#beforePrintText();
	inline_tag();
	#if ($text =~ /($big5)*(Ｐ|<p[,\-\d]*>)/) {
	#	$text = inlinep($text);
	#}
	checkCloseDiv();
}

sub tag_s {
	$buf .= $lb;
	inline_tag();
	$buf .= &checkopen("l", "lg");
}

# 卷首資訊
sub tag_J {
	if ($debug) { 
		print STDERR "1948 begin tag_J()\n"; 
		print STDERR "1949 juan=[$juan]\n";
		print STDERR "1950 juan_tmp=[$juan_tmp]\n";
	}
	#edith modify 2005/5/9 start
	#X74n1470_p0139a06J##大方廣佛華嚴經海印道場十重行
	#X74n1470_p0139a07J=#願常[彳*扁]禮懺儀卷第一
	#edith modify 2005/5/20 第一行結束時無法判斷卷數, 第二行才有"卷第二"字串
	#所以到 </juan> 時才寫入 $buf
	#X74n1470_p0147a06J##大方廣佛華嚴經海印道場十重行願常[彳*扁]禮懺儀卷第二
	#X74n1470_p0147a07J=#卷第二
	 if ($open{"jhead"}>0 and $tag!~/=/){
		$buf .= "</jhead>";
		$juan_tmp .= "</jhead>";  #edith modify 2005/5/20
		$open{"jhead"}--;
	}
	
	if ($open{"juanBegin"}>0 and $tag!~/=/){
		if ($debug2) {print STDERR "1972卷首資訊|i_tag=$i_tag\n$juan_tmp\n";getc;}		
		$buf .=$juan_tmp;   #edith modify 2005/5/20
		$juan_tmp="";           #edith modify 2005/5/20
		$buf .= "</juan>";
		$open{"juanBegin"}--;
	}
	#edith modify 2005/5/9 end
	
	local $text_J="";
	local $tag_J_Q=0;
	$buf .= &checkopen("l", "lg", "p", "title", "item", "list");
	#if ($debug2) {print STDERR "1793卷首資訊|i_tag=$i_tag\n";}
	$text1 = '';
	# Ex: T55n2149_p0219b15J##║大唐內典[10]錄Ｑ歷代眾經傳譯所從錄第一之
	if ($text =~ /^(($big5)*)Ｑ(($big5)*)$/) {
		$text = $1;
		$text1 = $3;
	}	
	
	if ($open{"juanBegin"} > 0){
		$juan .= "$lb$text";
		#$buf .= "$lb$text"; #edith modify 2005/5/9, 2005/5/20		
	} else {
		if ($tag !~ /=/) {
			$buf .= $lb;
			$lb = "";
		}
		if ($tag =~ /D/){
			#edith modify 2005/2/24
			$juan = "$lb<juan fun=\"open\"><mulu><jhead type=\"D\">$text";
			#$buf .= "$lb<juan fun=\"open\"><mulu><jhead type=\"D\">$text";
		} elsif ($tag =~ /X/){
			#edith modify 2005/2/24
			$juan = "$lb<juan fun=\"open\"><mulu><jhead type=\"X\">$text";
			#$buf .= "$lb<juan fun=\"open\"><mulu><jhead type=\"X\">$text"; 
		} else {
			#edith modify 2005/2/24 J(卷首資訊)行中有A(作者)
			#X75n1508_p0001a02J##[01]釋迦如來成道記一卷Ａ唐　王勃撰
			#$juan = "$lb<juan fun=\"open\"><mulu><jhead>$text";
			$juan = "$lb<juan fun=\"open\"><mulu><jhead>";
		}		
		$open{"jhead"}++;
		$open{"juanBegin"}++;		
		$text_J = $text;	#edith modify 2005/3/15
		#edith modify 2005/3/9
		#printOutJuan(); 
		#edith add 2005/2/23 卷首資訊也會有作者資料, 
		#例如 X75n1508_p0001a02J##[01]釋迦如來成道記一卷Ａ唐　王勃撰
		inline_tag(); 
		$text_J="";
	}
	if ($debug) {print STDERR "1818|$text\n";}
	if ($text1 ne '') {
		#printOutJuan();	#edith hide 2005/3/15
		$tag_J_Q=1;			#edith modify 2005/3/15
		$text = $text1;		
		tag_Q("Q");
	}	
	if ($debug) {
		print STDERR "2032 juan=[$juan]\n";
		print STDERR "juan_tmp=[$juan_tmp]\n";
		print STDERR "end tag_J()\n";
	}
}

sub tag_j {	
	if ($debug) { print STDERR "2036 $tag\n"; getc; }
	#edith modify 2005/5/9 start
	#X74n1470_p0146c13j##大方廣佛華嚴經海印道場十重行願常[彳*扁]禮懺儀
	#X74n1470_p0146c14j=#卷第一	
	if ($open{"jhead"}>0 and $tag!~/=/){
		#$buf .= "</jhead>"; 
		$juan_tmp .= "</jhead>"; #edith modify 2005/5/20
		$open{"jhead"}--;
	}
	
	if ($open{"juanEnd"}>0 and $tag!~/=/){
		#$buf .= "</juan>";
		$juan_tmp .= "</juan>"; #edith modify 2005/5/20
		$buf .= $juan_tmp;
		$juan_tmp = "";
		$open{"juanEnd"}--;
	}
	#edith modify 2005/5/9 end
	
	$buf .= &checkopen("l", "lg", "p", "title", "item", "list", "sp", "dialog");
	if ($open{"juanEnd"} > 0) { 
		$juan_tmp .= $lb; # 如果 卷尾資訊 已經開始, 就不印到 $buf, 先存進 $juan_temp
	} else {
		$buf .= "$lb<juan fun=\"close\" n=\"$currentJuan\"><jhead>";
		$open{"jhead"}++;
		$open{"juanEnd"}++;
		$juanOpen=0;
		if ($debug2) {print STDERR "1844|edith1($oldtag)\n"; getc;}
	}
	if ($debug) { watch_buf('2079'); }
	inline_tag();
	if ($debug) {
		print STDERR "2064 juan=[$juan]\n";
		print STDERR "juan_tmp=[$juan_tmp]\n";
		print STDERR "end tag_j()\n";
	}
}

sub tag_L {
	
	if ($tag!~/=/) {
		my $level;
		$tag=~/(\d)/;
		$level=$1;
		if ($level<=0) {
			$level=1;
		}		
		###edith modify:2004/12/10 start	新行首有 L, 要結束 </list>
		while ($level <= $open{"list"}) 
		{			
			if ($open{"item"} > 0)
			{
				$new_buf .= "</item>";
				$open{"item"}--;
			}
			$new_buf .= "</list>";
			$open{"list"}--;
		}			
		###edith modify:2004/12/10 end
		$buf .= $new_buf;
		$new_buf='';
		
		#X78n1554_p0575a13L#1卷第二
		#<lb ed="X" n="0575a13"/><list><head>卷第二</head>
		item($level); 
		
	} else {
		$buf .= $lb;
	}
	$itemsInList=0;
	$buf .= $text;		
}

sub item {
	my $level=shift;
	my $new_buf='';
	
	
	###edith modify 2004/12/10
	###X78n1554_p0575a14L#2臨濟宗
	###<list><item id="itemX78p0575a1401">臨濟宗
	#while ($level <= $open{"list"}) {
	if ($level == $open{"list"} && $open{"item"} >0) {
		#$new_buf .= "</item>";
		#$open{"item"}--;
	}
	
	while ($level < $open{"list"}) {
		$new_buf .= "</item>";
		$open{"item"}--;
		$new_buf .= "</list>";
		$open{"list"}--;
	}
	if ($open{"item"} eq $level) {
		$new_buf .= "</item>";
		$open{"item"}--;
	}
	
	
	
	if ($debug) {
		print STDERR "1675 item() new_buf=[$new_buf]\n";
	}
	$buf .= $new_buf;
	$new_buf='';
		
	if ($tag=~/Q/) {
		closeDiv($level);
	}
	#edith modify 2005/6/13 行號重覆列印
	#X59n1107_p0686b24e##汙家戒六比丘<d><I1>走入王宮迴避<I2>一聞達<I2>二摩醯沙
	#$buf .= $lb;	
	if ($buf =~ /$lb/)
	{
	    	   
	}
	else
	 {
	    $buf .= $lb;
	 }
	
	$lb='';
	if ($tag=~/Q/) {
		my $label=myLabel($text);
		$new_buf .= "<div1><mulu type=\"other\" level=\"1\" label=\"$label\"/>";
		$open{"div"}=1;
	} elsif ($open{"div"}<=0) {
		$new_buf .= "<div1>";
		$open{"div"}=1;
	}
	while ($open{"list"} < $level) {
		$new_buf .= "<list>";
		$open{"list"}++;
		$pMarginLeft = ''; # 新的 list 開始, 不再繼承上一個 p 的縮排 2004/11/17 02:59下午
	}
	if ($open{"list"}>0) {
		my $id="item${vol}p$p$sec${line}" . sprintf("%2.2d",$current_pos);
		$new_buf .= "<item id=\"$id\">";
		$open{"item"}++;		
	}
	if ($debug) {
		print STDERR "1654 item() text=[$text] new_buf=[$new_buf]\n";
	}
	$buf .= $new_buf;
	$new_buf='';
	
	if ($tag =~ /P/) {
		my $id = "p${vol}p$p$sec${line}01";
		$buf .= "<p id=\"$id\">";
		$open{"p"}++;
	}
	
	inline_tag();
	
	if ($debug) {
		print STDERR "1664 item() text=[$text]\n";
	}
	$buf .= $text;
	$text='';
	checkCloseDiv();
}

sub checkClose {
	$tab++;
        if ($debug) {
		print STDERR "2198 checkClose() open{div}=" . $open{"div"};
		print STDERR " open{l}=" . $open{"l"};
		print STDERR " open{lg}=" . $open{"lg"};
		print STDERR " wq=$wq inw=$inw\n";
	}
        
	# byline 可能在 卷資訊 之中, 所以先結束
	#if ($open{"byline"} > 0 && $tag !~ /[AYECB_]/){
	#edith add 2005/3/9
	#if ($open{"byline"} > 0 && $tag !~ /[AYECB]/){
	if ($open{"byline"} > 0 && $tag !~ /[YECB]/){
		$buf .= "</byline>";
		$open{"byline"} = 0;		
	}
	
	if ($open{"cell"} > 0){	###edith add 2004/12/9
		#edith modify 2005/3/8 row 有跨行的需求, 加入判斷條件(遇到行首有f表示前一個cell要結束)
		#X76n1516_p0028c20Ff#<c>丙申(太元二十一)(九月安帝即位)<c>(三)<c>(西秦)(太初九)<c>(後涼)(龍飛元)<c>(後燕寶)
		#X76n1516_p0028c21_##(永康元)<c>(魏)(皇始元)</F>
		if ($tag =~ /f/)
		{
			if ($debug2) {print STDERR "\n2006|i_tag=$i_tag\n";}
			$buf .= "</cell>";
			$open{"cell"} = 0;
		}
	}
	
	if ($open{"row"} > 0){	###edith add 2004/12/9
		#edith modify 2005/3/8 row 有跨行的需求, 加入判斷條件(遇到行首有f表示前一個row要結束)
		#X76n1516_p0028c20Ff#<c>丙申(太元二十一)(九月安帝即位)<c>(三)<c>(西秦)(太初九)<c>(後涼)(龍飛元)<c>(後燕寶)
		#X76n1516_p0028c21_##(永康元)<c>(魏)(皇始元)</F>
		if ($tag =~ /f/)	
		{
			$buf .= "</row>";
			$open{"row"} = 0;
			$c_Num=0;
			#edith modify 2005/3/8
			$startRow=0;
		}
	}
	
	#edith modify 2005/3/9, edith modify 2005/5/9 and $tag!~/=/
	#X74n1470_p0139a06J##大方廣佛華嚴經海印道場十重行
         #X74n1470_p0139a07J=#願常[彳*扁]禮懺儀卷第一
	#if ($open{"juanBegin"} > 0 && $tag !~ /[J]/){
	if ($open{"juanBegin"} > 0 and $tag!~/=/ ){		
		printOutJuan();
		#$open{"juanBegin"} = 0;	#edith modify 2005/3/1
		#$buf .=$juan_tmp;   #edith modify 2005/5/20
		$juan_tmp="";           #edith modify 2005/5/20
		#$buf .= "</juan>";
		$open{"juanBegin"}=0;
	}

	#
	#edith add 2005/3/9, edith modify 2005/5/9 and $tag!~/=/
	#X74n1470_p0146c13j##大方廣佛華嚴經海印道場十重行願常[彳*扁]禮懺儀
         #x74n1470_p0146c14j=#卷第一
	if ($open{"jhead"} > 0 and $tag!~/=/ ){
		#$buf .= "</jhead>";
		$juan_tmp .= "</jhead>";  #edith modify 2005/5/20
		$open{"jhead"}=0;
	}
		
	
	#edith modify 2005/3/9, edith modify 2005/5/9 and $tag!~/=/
	#X74n1470_p0146c13j##大方廣佛華嚴經海印道場十重行願常[彳*扁]禮懺儀
         #x74n1470_p0146c14j=#卷第一
	#if ($open{"juanEnd"} > 0 && $tag !~ /[j]/){		
	if ($open{"juanEnd"} > 0 and $tag!~/=/){
		#printOutJuan();
		$buf .=$juan_tmp;   #edith modify 2005/5/20
		$juan_tmp="";           #edith modify 2005/5/20
		$buf .= "</juan>";	#edith modify 2005/3/9		
		$open{"juanEnd"} = 0;	#edith modify 2005/3/1				
	}

	if ($open{"head"} > 0) {
		# 標題跨空白行
		# X01n0026_p0417c07Q#1大梵天王問佛決疑經
		# X01n0026_p0417c08Q=1
		# X01n0026_p0417c09Q=1凡例
		#if ($tag !~ /[DXxQKV_]/ or ($tag=~/Q/ and $tag!~/=/) or ($text eq ''){
		if ($tag !~ /[DXxQKV_]/ or ($tag=~/Q/ and $tag!~/=/) or ($text eq '' and $tag!~/=/) ) {
			$buf .= closeHead();
		}
	}
	
	#if ($open{"listhead"} > 0) {
	#	$buf .= "</head>";
	#	$open{"listhead"}--;
	#}

	# added by Ray 2000/5/26 01:53PM
	if ($open{"head_no"} > 0 && $tag !~ /N/){
		$buf .= "</head>";
		$open{"head_no"}=0;
	}
	
	
	# added by edith 2004/12/10
	# 例如:X78n1552_p0395c09S##　一杯甘露　　十年終南　　高旻高旻　　是誰同參
	# 最後少一個</l>
	#if ($open{"l"} > 0 )
	# edith modify 2005/5/6 X74n1475_p0394a22_##<T,1> 到 0394a23 "的小流)" 才結束
	#X74n1475_p0394a22_##<T,1>二藏(一聲聞藏二菩薩藏)之中菩薩攝(若此經攝彼二者。即但攝二[02]〔文。藏〕云。
         #x74n1475_p0394a23_##亦攝漸修一切群品譬如大海不謙小流)<T,1>若論三藏(一修多羅藏經也。二毗奈
	if ($open{"l"} > 0 and $intag_I eq 1)
	{
		#$notCloseI=1;      #遇到下一個 <T,1>會結束
	}
	
	# edith modify 2005/5/5 $tag!~/=/ 不是 "T=#" 才結束<I>
	if ($open{"l"} > 0 and $tag!~/=/ and $notCloseI eq 1)
	{
		#$notCloseI=0;  #遇到下一個 <T,1>會結束
		#$buf .= "</l>";
	         #$open{"l"}=0;
	}
	
	# added by Ray 2001/1/31 11:18上午
	if ($open{"lg"} > 0 and $lgType eq "inline" and $tag eq "_") {
			
			$text =~ s#((　)+)#</l><l>$1#g;
	}
	
	#if ($open{"p"} > 0 && $tag ne "_") {
	if ($open{"p"} > 0) {
		if ($debug) {
			print STDERR " " x $tab, "1747 checkClose() open{p}=", $open{"p"}, "\n";
		}
		my $t = $tag;
		$t =~ s/[k_#]//g;
		if (($t ne "") or ($text eq '')) {
			if ($inw and $t eq "W") {}
			elsif ($t =~ /I=/) {}
			else {
				$buf .= "</p>";
				$open{"p"} = 0;
			}
		}
	}
	
	if ($open{"item"}>0) {
		# modified by Ray 2003/9/16 04:16下午
		# X80n1566_p0443c09L##凡例
		# X80n1566_p0443c10I##[一>]會元合五為一連珠編貝良工心苦今猶見之是
		# X80n1566_p0443c11_##書旁蒐博[釆>采]去似存真未敢以千金募諸咸陽亦
		# X80n1566_p0443c12_##將舉苦心商之天下
		# X80n1566_p0443c13I##[一>]是書羅輯多年而載筆從事則始崇禎壬午至甲
		# X80n1566_p0443c14_##申冬季爛然成編會四方多故藏之石室未敢通
		#if ($tag!~/I=/) {
		#if ($tag!~/(I=|_)/) {
		#X81n1570_p0329c23IP#[一>]燈史自傳聯普續廣五籍。為禪門記載之書。其
		#X81n1570_p0330a13P##按列聖徽猷。[帚-巾+果]諸家法要。考古徵今。網羅上下。

		# 遇到 k, P, W 不結束 <item>

		# X78n1546_p0162b08WI#阿彌陀三耶三佛薩樓佛檀過度人道經二卷(吳
		# X78n1546_p0162b09W##支謙譯)</L>
		#if ($tag!~/(I|k|_|P)/ and $text!~/<I/) {
		if ($tag!~/(I|k|_|P|W)/ and $text!~/<I/) {
			$buf .= "</item>";
			$open{"item"}--;
		}
	}
	
	if ($open{"list"}>0) {
		my $t=$tag;
		$t=~s/_//;
		#if ($t eq '' and $itemsInList>0) { # 如果遇到空白行, 要結束所有的 List
		if ($t eq '' and $itemsInList>0 and $text eq '') { # 如果遇到空白行, 要結束所有的 List
			$buf .= &closeAllList(1);
		}
	}
	
	if ($open{"r"}>0) {
		if ($debug) {
			print STDERR "1790 checkClose() open{r}=", $open{"r"}, "\n";
		}
		if ($tag=~/r/) {
			$tag =~ s/r//;
		} else {
			$buf .= "</p>";
			$open{"r"}--;
		}
	}

	if ($open{"div"}>0) {
		if ($debug) {
			print STDERR " " x $tab, "2384 wq=$wq inw=$inw\n";
			print STDERR " " x $tab, "2385 tag=$tag\n";
		}
		if ($wq) {
			if ($tag !~ /W/) {
				if ($open{"div"} >= $wq) {
					$buf .= "</div" . $open{"div"} . ">";
					$open{"div"}--;
				}
				$wq=0;
				$inw=0; # 2004/8/5 10:25上午
			}
		}
	}
	if ($wq) {
		if ($tag !~ /W/) {
			$wq=0;
		}
	}
	$tab--;
	if ($debug) {
		print STDERR "2405 end checkClose() open{div}=" . $open{"div"} . "\n";
	}
}

sub closeAllList {
	my $n=shift;
	my $s='';
	
	$s .= &checkopen("p"); # 2004/6/21 09:20上午
	
	while($open{"list"}>=$n) {
		if ($open{"item"} >= $open{"list"}) {
			$s .= "</item>";
			$open{"item"}--;
		}
		$s .= "</list>";
		$open{"list"}--;
		if ($open{"list"}>0) {
			$s .= "</item>";
			$open{"item"}--;
		}
	}
	return $s;
}

sub closeAllDiv {
	my $s='';
	while($open{"div"}>0) {
		$s .= "</div" . $open{"div"} . ">";
		$open{"div"}--;
	}
	return $s;
}

sub closeSutra {
	if ($figureEnt ne '') {
		$buf =~ s/(%ENTY;)/$figureEnt$1/;
	}

	# <lb n="0293b16"/><juan fun="close" n="001"><jhead>嘉泰普燈錄卷第一</jhead></juan>
	# <lb n="0293b17"/></div3>
	# => 
	# <lb n="0293b16"/><juan fun="close" n="001"><jhead>嘉泰普燈錄卷第一</jhead></juan></div3>
	# <lb n="0293b17"/>
	$buf =~ s#((?:\n<(?:lb|pb)[^>]*?/>)+)((?:</div\d+?>)+)#$2$1#sg;
	$buf =~ s#<head></head>##sg; # 2005/9/29 16:16 by Ray
	
	# 把 <tt>&SD-CF5F;擔(引)</tt> 換成
	# <tt place="inline"><t lang="san-sd">&SD-CF5F;</t><t lang="chi">擔<note place="inline">引</note></t></tt>
	# 2010/11/25 by heaven
	
	$buf =~ s#<tt>((?:(?:\n<lb [^>]*?/>)?(?:&SD[^;]*?;))*)(.*?)</tt>#<tt place="inline"><t lang="san-sd">$1</t><t lang="chi">$2</t></tt>#sg;
	
	print F $buf;
	close (F);
	$buf = '';
}

# 算字數
sub myLength {
	my $str=shift;
	if ($debug) { print STDERR "myLength $str "; }
	my $n=0;
	if ($str=~/<figure/) {
		$n=1;
	}
	$str =~ s/<rdg[^>]*?>.*?<\/rdg>//g; # 去掉 <rdg> 不算
	$str =~ s/<[^>]*?>//g; # 去掉標記不算
	my $pattern = '(?:&.*?;|[\x80-\xff][\x00-\xff]|[\x00-\x7F])';
	my @a=();
	push(@a, $str =~ /$pattern/g);
	foreach $s (@a) {
		# 不算字數的符號
		#if ($s =~ /^(。)|(．)| |(　)|(〔)|(〕)|(【)|(】)|\(|\)$/) {
		if ($s =~ /^(◎|。|，|、|；|：|「|」|『|』|（|）|？|！|—|…|《|》|〈|〉|．|“|”|　|〔|〕|【|】|\(|\))$/) {
			next;
		}
		$n++;
		if ($s =~ /^&CI/) {
			$n++;
		}
	}
	if ($debug) { print STDERR $n,"\n"; }
	return $n;
}

sub inlinep {
	my $s=shift;
	$tab++;
	if ($debug) {
		print STDERR " " x $tab, "1834 begin inlinep() $s\n";
	}
	while ($s =~ /^($big5*?)(Ｚ|Ｐ|<p[,\-\d]*>)(.*)$/) {
		my $s1=$1;
		my $s2=$2;
		my $s3=$3;
		$s = $s1 . addp($s2, $s1) . $s3;
	}
	if ($s =~ /<\/P>/) {
		$s =~ s/<\/P>/<\/p>/;
		$open{"p"}--;
	}
	if ($debug) {
		print STDERR " " x $tab, "1899 end inlinep() $s\n";
	}
	$tab--;
	return $s;
}

sub checkCloseDiv {
	$closeDiv=0;
	if ($text =~ /^(.*?)<\/Q(\d+)>(.*)$/s) {
		$closeDiv=$2;
		$text = $1 . $3;
	}
	$buf .= $text;
	closeDiv($closeDiv);
}

sub closeDiv {
	my $n=shift;
	if ($n==0) {
		return;
	}
	# 檢查 div 結束前就應該結束的標記
	$buf .= &checkopen("l", "lg", "p", "title", "item", "list");
	
	while ($n <= $open{"div"}) {
		$buf .= "</div" . $open{"div"} . ">";
		$open{"div"}--;
	}
	$inw=0;
	$wq=0;
}

sub corr2app {
	# 含 entity, 不含 "<"(\x3c), ">"(\x3e) 的 big5
	my $big5a = '(?:&[^;]+?;|[\xA1-\xFE][\x40-\x7E\xA1-\xFE]|[\x00-\x3b]|\x3d|[\x3f-\x7f])';
	
	# X85n1591_p0229b11r## [[巳>已]>>]
	while ($text =~ /^((?:$big5)*)\[\[($big5a*?)>($big5a*?)\]>>\](.*)$/) {
		$text = $1 . "<app><lem wit=\"【CBETA】\" resp=\"CBETA.maha\"></lem><rdg wit=\"$wit\">$2</rdg></app>" . $4;
		if ($debug) {
			print STDERR "1838| $text\n";
		}
	}

	# X85n1591_p0229b12r##　[>>[巳>已]]
	while ($text =~ /^((?:$big5)*)\[>>\[($big5a*?)>($big5a*?)\]](.*)$/) {
		$text = $1 . "<app><lem wit=\"【CBETA】\" resp=\"CBETA.maha\">$3</lem><rdg wit=\"$wit\"></rdg></app>" . $4;
		if ($debug) {
			print STDERR "1848| $text\n";
		}
	}

	#$text =~ s/$corrpat/<corr sic="$1">$2<\/corr>/xg;
	#$text =~ s/$corrpat/<app><lem wit="【CBETA】" resp="CBETA.maha">$2<\/lem><rdg wit="$wit">$1<\/rdg><\/app>/xg;
	if ($debug) {
		print STDERR "2200| $text\n";
	}
	# 移位 [a>>b]
	while ($text =~ /^((?:$big5)*)\[($big5a*?)>>($big5a*?)\](.*)$/) {
		$text = $1 . "<app type=\"shift\"><lem wit=\"【CBETA】\" resp=\"CBETA.maha\">$3</lem><rdg wit=\"$wit\">$2</rdg></app>" . $4;
	}
	# 修訂 [a>b]
	while ($text =~ /^((?:$big5)*)\[($big5a*?)>($big5a*?)\](.*)$/) {
		if ($debug3) {
			print STDERR "2603| $text\n";
		}
		my $lem = $3;
		my $rdg = $2;
		
		if($lem eq "") {$lem = "&lac;"};	# 2011/12/04 沒有文字時要用 &lac;
		if($rdg eq "") {$rdg = "&lac;"};
		
		$text = $1 . "<app><lem wit=\"【CBETA】\" resp=\"CBETA.maha\">$lem</lem><rdg wit=\"$wit\">$rdg</rdg></app>" . $4;
		if ($debug3) {
			print STDERR "2607| $text\n";
			getc;
		}
	}
}

# 處理行中簡單標記
sub inline_tag {
	local $i_tag;
	my $s=$text;
	
	if ($debug) {
		print STDERR "2028 begin inline_tag() text=$text open{div}=" . $open{"div"} . "\n";
		watch_buf(2640);
	}
	$text='';
	my $len=1;
	
	if ($debug2) {print STDERR "2435 $s($i_tag)\n"; getc;}
	while ($s =~ m#^((?:$big5)*?)(　　|　|Ａ|<a>|<annals>|</annals>|Ｂ|Ｃ|<c\d*?(?: r\d+)?>|<d>|<date>|Ｅ|<event>|<e(?:,\d+)?>|</e>|</F>|Ｉ|<I\d*?>|<J>|<j>|<K[^>]*>|</L\d*?>|<mj>|<n[,\d]*>|</n>|<no_chg>|</no_chg>|<o>|</o>|Ｐ|Ｓ|<T[,\-\d]*>|</T>|<p=h\d+>|<p[,\-\d]*>|</P>|</?Q\d*[^>]*>|<S>|<u>|</u>|<w>|</w>|Ｙ|Ｚ|<z[,\-\d]*>)(.*)$#)
	{
		$text .= $1;
		$i_tag = $2;
		$s = $3;
		
		if ($debug2)
		{
			print STDERR "$lb\n";
			print STDERR "2546處理行中簡單標記{$1}\n";
			print STDERR "2547處理行中簡單標記{$2}\n";	
			print STDERR "2548處理行中簡單標記{$3}\n";	
			#print STDERR "2468|" . $open{"l"} . "</I>\n";		
			getc;
		}
		$len += myLength($text);
		$current_pos += myLength($text);

		if ($open{"head"}>0) {
			if ($text =~ /^(.*)(<note[^>]*?>)$/) {
				$head .= $1;
				$label .= $1;
				$text = $2;
			} else {
				$head .= $text;
				$label .= $text;
				$text = '';
			}
			if ($i_tag!~/　/) {
			 	if ($debug2) {
			 		print STDERR "2085 head=[$head] text=$text\n";
			 	}
				$buf .= closeHead();
			}
		}
		
		if ($debug2)
		{
			print STDERR "2576|$text\n";
			getc;
		}
		
		if ($open{"juanBegin"} > 0) {
			$juan .= $text;
		} else {
			$buf .= $text;
		}
		$text = '';	
		
		my $id="${vol}p$p$sec${line}" . sprintf("%2.2d",$len);
		if ($i_tag eq "　　") {
			if ($debug2)
			{
				print STDERR "2248 id{$id}\n";	
				print STDERR "2256 l{" . $open{"l"} ."}\n";
				print STDERR "2256 lg{" . $open{"lg"} ."}\n";	
				getc;
			}		
			if ($open{"lg"}) {
				if ($open{"l"}) {
					$buf .= "</l>";
					$open{"l"}--;
				}
				$buf .= "<l";
				$open{"l"}++;
				if ($lgType eq "abnormal") {
					$buf .= ' rend="text-indent:2em"';
				}
				$buf .= ">";
			} elsif ($open{"head"}) {
				$head .= $i_tag;
				$label .= $i_tag;
			} else {
				$buf .= $i_tag;
			}
		} elsif ($i_tag eq "　") {
			if ($debug) { print STDERR "2667 i_tag=[　] juanBegin=" . $open{"juanBegin"} . "\n";}
			if ($open{"lg"}) {
				if ($open{"l"}) {
					$buf .= "</l>";
					$open{"l"}--;
				}
				$buf .= "<l>";
				if ($debug2) {print STDERR "2555|\n$text\n";get;}
				$open{"l"}++;
			} elsif ($open{"head"}) {
				$head .= $i_tag;
				$label .= $i_tag;
			} else {
				if ($open{"juanBegin"} > 0) {
					$juan .= $i_tag;
				} else {
					$buf .= $i_tag;
				}
			}
		#edith modify 2005/3/21 例如 X76n1517_p0203c14Q#2韓文公別傳Ｃ刑部尚書　孟簡　集
		#} elsif ($i_tag =~ /^(Ａ|Ｂ|Ｅ|Ｙ)$/) {
		#edith modify 2005/3/21 例如 X76n1517_p0203c14Q#2韓文公別傳Ｃ刑部尚書　孟簡　集
		} elsif ($i_tag =~ /^(Ａ|Ｂ|Ｃ|Ｅ|Ｙ)$/) {
			#edith modify 2005/2/24
			$buf .= &checkopen("p", "byline", "jhead");
			#$buf .= &checkopen("p", "byline", "jhead", "juanBegin");
			$buf .= '<byline type="';
			#if ($debug2) {print STDERR "2382|i_tag=$i_tag\n";}
			if ($i_tag eq "Ａ") {
				$buf .= "author";
			} elsif ($i_tag eq "Ｂ") {
				$buf .= "other";
			} elsif ($i_tag eq "Ｃ") {
				$buf .= "Collector";
			} elsif ($i_tag eq "Ｅ") {
				$buf .= "editor";
			} elsif ($i_tag eq "Ｙ") {
				$buf .= "translator";
			}
			$buf .= '">';
			$open{"byline"}++;
		} elsif ($i_tag eq "<a>") {
		        #edith modify 2005/5/10 </lg></sp>先結束, 例如:#X74n1467_p0083a12_##<w><p>問曰Ｓ　十方皆淨土　　云何獨指西
			$buf .= &checkopen("p", "lg", "sp"); 
			$buf .= '<sp type="answer">';
			$open{"sp"}++;
		} elsif ($i_tag eq "<annals>") {
			$buf .= &checkopen("p", "event", "date", "annals"); 
			$buf .= '<annals>';
			$open{"annals"}++;
		} elsif ($i_tag eq "</annals>") {
			$buf .= &checkopen("p", "event", "date", "annals"); 
		#edith modify 2005/3/8
		} elsif ($i_tag =~ /<c(\d*?)(?: r(\d+))?>/) {
			$cell_cols=$1;
			$rows = $2;
			$buf .= &checkopen("cell");
			$buf .= "<cell";	
			if ($cell_cols ne "") {
				$buf .= " cols=\"$cell_cols\"";
			}
			if ($rows ne '') {
				$buf .= " rows=\"$rows\"";
			}
			$buf .= ">";
			$open{"cell"}++;
			
		#edith hide:2005/3/8 此段修改成上面的程式, 從 } elsif ($i_tag =~ /<c(\d*?)>/) { 開始
		#} elsif ($i_tag eq "<c>") {
		#	$buf .= &checkopen("cell");
		#	$buf .= "<cell>";
		#	$open{"cell"}++;		
		} elsif ($i_tag eq "<d>") 
		{
		    #edith modify 2005/5/10 :"p","def" 例如:X74n1496_p0751b11WQ3 ... ... ...<d>。<p>(匹亦切。與辟同。偏僻
			#$buf .= &checkopen("form","p","def");
			$buf .= &checkopen("p", "form","p","def");
			$buf .= "<def>";
			$open{"def"}++; 
		} elsif ($i_tag eq "<date>") {
			$buf .= "<date>";
			$open{"date"}++;
		} elsif ($i_tag eq "<event>") {
			$buf .= &checkopen("p", "date");
			$buf .= "<event>";
			$open{"event"}++;
		} elsif ($i_tag =~ /<e(,\d+)?>/) {
			$buf .= &checkopen("p","def", "form", "entry");
			$buf .= "<entry";
			if ($current_pos > 1) {
				$buf .= ' place="inline"';
			}
			if ($i_tag =~ /<e,(\d+)/) {
				$buf .= " rend=\"margin-left:$1em\"";
			}
			$buf .= "><form>";
			
			$open{"entry"}++;
			$open{"form"}++;
		} elsif ($i_tag eq "</e>") {
			#x60n1136_p0807a24_##<d><S>　十九逾城六苦行　　五歲遊歷三十成
			#x60n1136_p0807b01_##　說法度生五十年　　是則共當八十壽</e>
			#$buf .= &checkopen("p","def","form","entry");   #edith modify 2005/5/10 : "form"
			$buf .= &checkopen("p","l", "lg", "def","form","entry");
		} elsif ($i_tag eq "</F>") {
			$buf .= &checkopen("cell","row","table");
			$startRow=0;
		} elsif ($i_tag eq "Ｉ" or $i_tag eq "<I>") {
			$buf .= &checkopen("p");
			if ($open{"list"}==0) {
				$buf .= "<list>";
				$open{"list"}++;
			} else {
				$buf .= "</item>";
				$open{"item"}--;
			}
			$buf .= "<item id=\"item$id\">";
			$open{"item"}++;
		} elsif ($i_tag =~ /<I(\d+)>/) {
			my $level=$1;	
			$buf .=&checkopen("p"); #edith add 2005/6/13	
			item($level);
		} elsif ($i_tag eq "<J>") {
			$buf .= &checkopen("p"); # added by Ray 2006/7/31 14:04, X26n0514_p0189b14
			#$currentJuan++;
			#$buf .= "<milestone unit=\"juan\" n=\"$currentJuan\"/>";
			# 2004/9/23 11:44上午
			$buf .= "<mulu type=\"卷\" n=\"$currentJuan\"/>";
			$buf .= "<juan fun=\"open\" n=\"$currentJuan\"><jhead>$text";
			$open{"jhead"}++;
			$open{"juanBegin"}++;
		} elsif ($i_tag eq "<j>") {
			$buf .= &checkopen("l", "lg", "p", "title", "item", "list", "sp", "dialog");
			$buf .= "<juan fun=\"close\" n=\"$currentJuan\" place=\"inline\"><jhead>$text";
			$open{"jhead"}++;
			$open{"juanEnd"}++;
			$juanOpen=0;
		} elsif ($i_tag =~ /<K(\d+) (.*?)>/) {
			my $temp1 = $1;
			my $temp2 = $2;
			$temp2 =~ s/&([^;]+);/＆$1；/g;
			$buf .= "<mulu type=\"科判\" level=\"$temp1\" label=\"$temp2\"/>";
		} elsif ($i_tag =~ /<\/L(\d*?)>/) {
			my $n = $1;
			if ($n eq '') {
				$n=1;
			}
			$buf .= &closeAllList($n);
		} elsif ($i_tag =~ "<mj>") {
			$buf .= &checkopen("p");
			$currentJuan++;
			$buf .= "<milestone unit=\"juan\" n=\"$currentJuan\"/>";
		#讓 行中的 <n,1> 在 xml 轉成 <entry place="inline" rend="margin-left:1">
		#用<n[,\d]*> 作條件判斷則進不來
		} elsif ($i_tag =~ "<n[,\-\d]*>") { # 段落後註解
			$buf .= &checkopen("p", "def", "form", "entry");
			if (not $in_div_note) {
				$open{"div"}++;
				$buf .= "<div" . $open{"div"} . " type=\"note\">";
				$in_div_note=1;  
			}

			$buf .= "<entry";
			if ($current_pos > 1) {
				$buf .= ' place="inline"';		#<n>在行中
			}
			
			###edith modify:2004/12/13 start
			#讓 行中的 <n,1> 在 xml 轉成 <entry place="inline" rend="margin-left:1">
			if ($i_tag=~/<n,(\-?\d+?)>/) 
			{
				$n2_rend = $1;
				if ($n2_rend) 
				{
					$buf .= ' rend="margin-left:' . $n2_rend . 'em"';					
				}
			}
			###hide reason: 避免重覆加 rend="margin-left:1em
			if ($n_rend) {
			#	$buf .= ' rend="margin-left:' . $n_rend . 'em"';
			}
			$n2_rend =0;
			###edith modify:2004/12/13 end
			
			$buf .= "><form>";
			$open{"entry"}++;
			$open{"form"}++;
		} elsif ($i_tag eq "</n>") {
			$buf .= &checkopen("p","def","form","entry");
			$buf .= "</div" . $open{"div"} . ">";
			$open{"div"}--;
			$in_div_note=0;
		} elsif ($i_tag eq "<no_chg>") {
			$buf .= "<term rend=\"no_nor\">";
			$open{"no_chg"}++;
		} elsif ($i_tag eq "</no_chg>") {
			$buf .= "</term>";
			$open{"no_chg"}--;
		} elsif ($i_tag =~ /<o>/) {
			$buf .= &checkopen("l", "lg", "p","byline"); #edith modify 2005/6/6 l, lg 要結束
			if ($open{"commentary"}) {
				$buf .= "</div" . $open{"div"} . ">";
				$open{"div"}--;
				$open{"commentary"}=0;
			}
			if ($div_orig) {
				$buf .= "</div" . $open{"div"} . ">";
				$open{"div"}--;
				$div_orig=0;
			}
			$open{"div"}++;
			$buf .= "<div" . $open{"div"} . ' type="orig">';
			$div_orig=1;
			if ($debug) {
				print STDERR "2143 open{div}=" . $open{"div"} . "\n";
			}
		} elsif ($i_tag =~ /<p=h(\d+)>/) {
			$type="head$1";
			if ($open{"juanBegin"} > 0){
				printOutJuan();
				$juan_tmp="";           #edith modify 2005/5/20
				$open{"juanBegin"}=0;
			}
			$buf .= &checkopen("byline","l","lg", "p", "jhead", "juan");
			$buf .= "<p type=\"$type\" id=\"p$id\">";
			$open{"p"}++;
		#edith modify 2005/5/10 新增咒語標記 <z,1,-1><z,1>
		} elsif ($i_tag =~ /<p[,\-\d]*>/ or $i_tag =~ /<z[,\-\d]*>/) {
			$buf .= &checkopen("byline","l","lg");
			#if ($tag!~/[pP]/ and $open{"p"}>0) {
			if ($open{"p"}>0) {
				# 如果行首資訊裏已有P標記, 那麼 行首的 <p> 就不另開新段落
				if ($tag!~/[pP]/ or $len>1) {
					$buf .= "</p>";
					$open{"p"}--;
				}
			}
			if ($open{"div"}<1) {
				$open{"div"}=1;
				$buf .= "<div1>";
				if ($debug2) {print STDERR "2716|<div1>\n";}
			}
			if ($i_tag=~/<p,(\-?\d+),(\-?\d+)>/ or $i_tag=~/<z,(\-?\d+),(\-?\d+)>/) {
				$pMarginLeft=" rend=\"margin-left:$1em;text-indent:$2em\"";
			} elsif ($i_tag=~/<p,(\-?\d+?)>/ or $i_tag=~/<z,(\-?\d+?)>/) {
				$pMarginLeft=" rend=\"margin-left:$1em\"";
			} elsif ($open{"p"}<=0) {
				$pMarginLeft='';
			}
			
			$buf .= "<p id=\"p$id\"";
			
			if ($i_tag =~ /<z[,\-\d]*>/) {  #咒語標記 type
				$buf .= ' type="dharani"';
			}
			
			#if ($debug2) {print STDERR "2836|$current_pos";getc;}
			
			if ($current_pos>1) {
				$buf .= " place=\"inline\"";
			}
			$buf .= "$pMarginLeft>";
			$open{"p"}++;
		} elsif ($i_tag eq "Ｐ" or $i_tag eq "Ｚ") {
			$buf .= &checkopen("byline","p","l","lg");
			if ($open{"div"} < 1){
				my $type='';
				if ($i_tag  eq "Ｚ") {
					$buf .= '<div1 type="dharani">';
				} else {
					$buf .= "<div1>";
				}
				$open{"div"}=1;
			}
			$buf .= "<p id=\"p$id\" ";
			if ($i_tag eq "Ｚ") {
				$buf .= 'type="dharani" ';
			}
			$buf .= "place=\"inline\"$pMarginLeft>"; # 繼承上一個 P 的 margin-left
			$open{"p"}++;
		#edith modify 2005/4/21 有<o>, 沒有<u></u>...新增</o>, XML裡才會有結束的</div>
                    #SM:
                    #x54n0870_p0179b01_##║<o><p>斯不可得而生。不可得而滅也。</o>
                    #xML:
                    #<lb ed="X" n="0179b01"/><div1 type="orig"><p id="pX54p0179b0101">斯不可得而生。不可得而滅也。</p></div1>
		} elsif ($i_tag eq "</o>") {
                      $buf .= &checkopen("p", "l", "lg"); 
                      $buf .= "</div" . $open{"div"} . ">";
        	             $open{"div"}--;
                      $div_orig=0;
		} elsif ($i_tag eq "</P>") {
			$buf .= "</p>";
			$open{"p"}--;
		} elsif ($i_tag =~ /Ｓ/) {
			if ($open{"p"}>0) {
				$buf .= "</p>";
				$open{"p"}--;
			}
			if ($debug2)
			{
				print STDERR "2852 s{$s}\n";getc;
			}
			$s =~ s#((　)+)#</l><l>#g;
			if ($debug2)
			{
				print STDERR "2857 s{$s}\n";getc;
			}
			$s = "<l>" . $s . "</l>";
			if ($debug2)
			{
				print STDERR "2862 s{$s}\n";getc;
			}
			#$s =~ s#<l></l>##;
			#edith modify 2005/5/18 <a><p> 裡的偈頌多了一組 <l></l>。多加一個參數:g
			#X74n1467_p0083a13_##<a><p>答曰Ｓ　願強教主勝　　諸經共讚推</w>
			$s =~ s#<l></l>##g;
						
			#edith modify 2005/5/10 X74n1467_p0083a13_##<a><p>答曰Ｓ　願強教主勝　　諸經共讚推</w>
			if ($s =~ /.*(<\/.*>)<\/l>$/)   
			{
			    $tmp_tag=$1;
			    $s =~ s#$tmp_tag<\/l>#<\/l>$tmp_tag#g;    #例如:</w></l>變成 </l></w>
			 }
			 
			
			#$text .= "<lg id=\"lg$id\" type=\"inline\">";
			#edith modify 2005/5/10 	
			#$buf .= "<lg id=\"lg$id\" place=\"inline\">" . $s;				 	
			#$s='';
			$buf .= "<lg id=\"lg$id\" place=\"inline\">";
			
			$open{"lg"}++;
			$lgType = "inline";
		} elsif ($i_tag =~ /<Q(\d*)[^>]*>/) {
			start_inline_Q($1);
		} elsif ($i_tag =~ /<\/Q(\d*?)>/) {
			end_inline_q($i_tag);
		} elsif ($i_tag eq "<S>") {
			$buf .= &checkopen("p");
			$buf .= "<lg id=\"lg$id\">";
			$open{"lg"}++;
		#edith modify 2005/5/6 處理行中 <T,\d>: starting
		#X74n1475_p0394a21_##<T,1>教起因緣說[巳>已]竟<T,1>藏乘部分配如何
                   #<div1 type="jing"><lg id="lgX74p0394a2101" type="abnormal"><l rend="text-indent:1em">教起因緣說<app><lem wit="【CBETA】" resp="CBETA.maha">已</lem><rdg wit="【卍續】">巳</rdg></app>竟</l><l rend="text-indent:1em">藏乘部分配如何</l>
                   #X74n1475_p0394b07_##自說本生等三也)</T>
		} elsif ($i_tag =~ /<T,(\-?\d+?)>/) {
                        $pMarginLeft=""; # 停止繼承 p 縮排
                        # $buf .= &checkopen("head", "byline", "p", "item", "list", "l"); # #遇到下一個 <T,1>會結束 </l>
                        $buf .= &checkopen("head", "byline", "p", "l"); # 2011/12/05 B06n0005_p0162b18I## , <T> 遇到 list 及 item 不要中止
	               $intag_I = 1;
	                if ($open{"div"} < 1)
	                {
                                $buf .= "<div1 type=\"jing\">";
                                $open{"div"}=1;
                         }
                        
                         if ($open{"lg"} <= 0){
                                  $buf .= "<lg id=\"lg$id\" type=\"abnormal\">";
                                   $open{"lg"}++;
                          }
                           
                         if ($open{"l"} > 0){
                            $buf .= "</l>";
                            $open{"l"}--;
                            $intag_I = 0;
                        }
                         $buf .= "<l rend=\"text-indent:$1em\">";		  
    		      $open{"l"}++;		   
		 #edith modify 2005/5/6 處理行中 <T,\d>: ending  
		 #edith modify 2005/5/6 處理行中 </T>: starting
		 } elsif ($i_tag eq "</T>") {
		    $buf .= &checkopen("l", "lg");
		 #edith modify 2005/5/6 處理行中 </T>: ending   
		} elsif ($i_tag eq "<u>") {
			#$buf .= &checkopen("p", "l", "lg", "byline");
			$buf .= &checkopen("l", "lg", "p","byline"); #edith modify 2005/6/13 修正順序
			#edith modify 2005/5/24 因為 $open{"div"} 出現零的情況
			#X56n0932_p0490b23_##<u><p,1>○就文為二初題目次入文解釋。<p,1>△初又二初題
			#<lb ed="X" n="0490b23"/><div0 type="commentary"><div1><p id="pX56p0490b2301" rend="margin-left:1em">○就文為二初題目次入文解釋。</p><p id="pX56p0490b2314" place="inline" rend="margin-left:1em">△初又二初題
			#if ($div_orig) {
			if ($div_orig and $open{"div"} > 0) {
				$buf .= "</div" . $open{"div"} . ">";
				$div_orig=0;
				$open{"div"}--;
			}
			$open{"div"}++;
			
			$buf .= "<div" . $open{"div"} . ' type="commentary">';
			$open{"commentary"}=1;
		} elsif ($i_tag eq "</u>") {
			$buf .= &checkopen("p", "l", "lg");
			if ($open{"div"} > 0) { #edith modify 2005/6/13 加個判斷
			    $buf .= "</div" . $open{"div"} . ">";
			}
			$open{"commentary"}=0;
			$open{"div"}--;
		} elsif ($i_tag eq "<w>") {
			$buf .= &checkopen("byline", "p", "sp", "dialog");
			if ($open{"div"} < 1){
				$buf .= "<div1>";
				$open{"div"}++;
			}
			$buf .= '<dialog type="qa">';
			$open{"dialog"}++;
			$buf .= '<sp type="question">';
			$open{"sp"}++;
		} elsif ($i_tag eq "</w>") { 
			#edith note 2005/5/10 似乎跑不進來, 例如:
			#X74n1467_p0083a13_##<a><p>答曰Ｓ　願強教主勝　　諸經共讚推</w>
			$buf .= &checkopen("p", "l", "lg", "sp", "dialog");
		} else {
			if ($i_tag =~ /^<K/) { print STDERR "3137 $s\n"; }
		}
	}
	if ($debug) { print STDERR "3053 open_head:" . $open{"head"} . " juanBegin:" . $open{"juanBegin"} . "\n"; }
	if ($open{"head"}>0) {
		$head .= $s;
		$label .= $s;        
	} elsif ($open{"juanBegin"} > 0) {
		$juan .= $s;
	} elsif ($tag =~ /j/ or ($tag =~ /J/ and $open{"juanBegin"}>0)) { 
		#edith modify 2005/5/9
		#X74n1470_p0146c14j=#卷第一
		#避免變成<lb ed="X" n="0146c14"/>卷第一卷第一</jhead></juan>
		#X74n1470_p0139a06J##大方廣佛華嚴經海印道場十重行
		#避免變成<lb ed="X" n="0139a06"/><juan fun="open" n="1"><mulu type="卷" n="1"/><jhead>大方廣佛華嚴經海印道場十重行大方廣佛華嚴經海印道場十重行	 
		#$buf .= $s;
		$juan_tmp .= $s;
	} else {
	    $buf .= $s;
	}
	if ($debug) {
		print STDERR "2257 end of inline_tag() open{div}=" . $open{"div"} . "\n";
		print STDERR "2257 end of inline_tag() open{lg}=" . $open{"lg"} . "\n";
		print STDERR "2257 end of inline_tag() open{l}=" . $open{"l"} . "\n";
		print STDERR "2986\n"; getc; print STDERR $s; getc;"\n";
	}
	watch_buf(2156);
}

sub watch_buf {
	my $line=shift;
	if ($debug) {
		my $s='';
		my $s1=$buf;
		my $j=3;
		my $i;
		while ($j>0) {
			$i=rindex($s1,"<lb");
			if ($i > -1) {
				$s=substr($s1,$i) . $s;
				$s1=substr($s1, 0, $i);
			} else {
				$s = $s1 . $s;
				last;
			}
			$j--;
		}
		print STDERR "$line buf最後一行：【$s】\n";
	}
}

sub rep3 {
	my $s = shift;
	if ($s eq '<i>(') {
		return '<note place="interlinear">';
	} elsif ($s eq '(') {
		return '<note place="inline">';
	} elsif ($s eq ')' or $s eq ")</i>") {
		return '</note>';
	} else {
		return $s;
	}
}

# 傳回今天的日期 yyyy/mm/dd
sub today {
	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year += 1900;
	return "$year/$mon/$mday";
}

sub rep_note {
	my $s=shift;
	#<K> <Q> 標記裏的小括號不取代
	$s =~ s#(<[KQ][^>]*?>|<i>\(|\)</i>|\(|\))#&rep3($1)#egx;
	return $s;
}

sub start_inline_Q {
	my $level = shift;
	my $att = 0;
	my $label = '';
	if ($i_tag =~ /<Q\d* m=([^>]*)>/) {
		$att = 1;
		$label = $1;
		if ($debug) { print STDERR "2979 $label\n"; }
		$label =~ s#<note[^>]*?>(.*?)</note>#\($1\)#g;
		$label =~ s/&([^;]+);/＆$1；/g; # 缺字 entity 的 &...; 改成全型 ＆ ....；
		if ($debug) { print STDERR "2982 $label\n"; }
	}
	if ($level eq '') {
		$level=1;
	}
	# 20080414 by heaven 增加 "entry", "event", "date", "annals"
	$buf .= &checkopen("l", "lg", "p", "title", "item", "list", "def", "entry", "event", "date", "annals");
	if ($debug) {
		print STDERR "2113 text=[$text]\n";
	}
	while ($level <= $open{"div"}) {
		$buf .= "</div" . $open{"div"} . ">";
		$open{"div"}--;
		$div_orig=0;
		$open{"commentary"}=0;
	}
	while ($level > $open{"div"}+1) {
		$open{"div"}++;
		$head .= "<div" . $open{"div"} . ">";
	}
	if ($tag=~/W/) {
		$divtype ='w';
		$mulu_type = '附文';
		$inw=1;
		$wq = $open{"div"}+1;
	} else {
		$divtype = 'other';
		$mulu_type = '其他';
	}
	$head .= "<div" . $level . " type=\"$divtype\">";
	$open{"div"}++;
	if ($att) {
		if ($label ne '') {
			# label 前後不加全形括號 2005/12/1 14:41
			#$head .= "<mulu type=\"$mulu_type\" level=\"$level\" label=\"（$label）\"/>";
			$head .= "<mulu type=\"$mulu_type\" level=\"$level\" label=\"$label\"/>";
		}
		if ($s =~ /^<p/) {
			$buf .= $head;
			$head = '';
		} else {
			$head .= "<head>";
			$open{"head"}++;
		}
	} else {
		$head .= "<mulu><head>";
		$open{"head"}++;
	}
	if ($debug) {
		print STDERR "2127 head=[$head]\n";
	}
}

sub end_inline_q {
	my $i_tag = shift;
	$i_tag =~ /<\/Q(\d*?)>/;
	my $level = $1;
	if ($level eq '') {
		$level=1;
	}
	$buf .= closeAllList(1);
	$buf .= &checkopen("l", "lg", "p", "def", "entry", "title", "jhead", "juanEnd", "byline");

	# added 2004/6/25 11:15上午
	if ($open{"r"}>0) {
		$buf .= "</p>";
		$open{"r"}--;
	}
	if ($debug) { print STDERR "3180 wq=$wq inw=$inw"; }
	while ($level <= $open{"div"}) {
		$buf .= "</div" . $open{"div"} . ">";
		if ($open{"div"}==$wq) {
			$wq=0;
			$inw=0;
		}
		$open{"div"}--;
	}
	$open{"commentary"}=0;
}

__END__
:endofperl
