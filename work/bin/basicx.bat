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
# �� ²�满�� by heaven (���@�w���T)
# %open �ΨӦs�񦳶}�ҼаO���ƶq, �Ҧp : $open{"head"} = 2 , ��� head �٦��G�h������
# sub readSutra : Ū�JBM���g��, ������歺����¦�аO���b���B�z
# sub inline_tag : �B�z�椤²��аO
# sub checkopen : �ΨӧP�_�٦��S���� close ���аO, �Y��, �N close ��.

# closeSutra �� final ���O�����᪺�B�z, �γ\�i�H�X��, final �N���ΦA open �@���F.
# sub closeSutra();
# sub final();
# ================================================================================================
# A <byline type="Author">
# B <byline type="Other">
# C <byline type="Collector">
# E <byline type="Editor">
# Y <byline type="Translator">
#
#2004/12/9�B2004/12/10 modify by edith
# v 2.1.1, �����ö}�l, <list> �� L, <item> �� I, ��,  modified by Ray 2003/7/15 03:27�U��
# v 2.1.2, 2003/8/12 09:53�W�� by ray
# v 2.1.3, 2003/10/16 10:36�W�� by Ray
#          <lb ed="X" n="0404c05"/><byline type="Collector">��ù���]�ǤH�@£���^�n�Ͷ�</byline>
#          <lb ed="X" n="0404c06"/><byline type="Other">�d�p�Ѧ��s�H�@�Y�J�D���j��</byline>
#          <lb ed="X" n="0404c07"/><byline type="Other">��Ǳ������@�}�z�@���꭫��</byline>
#          <lb ed="X" n="0404c08"/><byline type="Other">��ǡ@�@���@�q��@���@�@�\</byline>
# v 2.1.4, 2003/10/20 10:18�W�� by Ray
#          X84n1579_p0012a11LQ1�������Z[��>��]�G�Q�h
#          X84n1584_p0652a21_##���U���C</L>�ަ�R�M�n�ԭz�C</Q1>
# v 2.1.5, 2003/10/27 01:19�U�� by Ray
#          X85n1591_p0229b11r## [[�x>�w]>>]
#          X85n1591_p0229b12r##�@[>>[�x>�w]]
#          X85n1592_p0281b14_##[(�G-(�e-�G))-��+��)]�֦p��)
#          X84n1581_p0358b12I##���۵a�I�v�׬r[�s/ʰ]���I�v�תŨ����I�v
# v 2.1.6, 2003/10/28 05:45�U�� by Ray
# v 2.1.7, 2003/11/7 05:06�U�� by Ray
# v 2.2.1, �׭q [A>B] �ন <app><lem wit="..." resp="CBETA.maha"> 2004/2/9 02:17�U�� by Ray
# v 2.3.1, 2004/4/21 10:53�W�� by Ray
#          cvs �۰ʧ�s�������s���B��� ��b <editionStmt>
#          ²��аO x,X �᭱���Ʀr ��� div �h��
#          type="inline" ��� place="inline"
# v 2.3.2, xml:stylesheet => xml-stylesheet
# v 2.3.3, 2004/4/30 03:45�U�� by Ray
# v 2.4.1, 2004/5/5 11:29�W�� by Ray
#          X71, No. 1420
#          <lb ed="X" n="0655c06"/><div1 type="other"><mulu type="��L" level="1" label="��CB01614�F��"/><head>&CB01614;��<note place="inline">���������y�Φ檬���</note></head> 
#          maha ı�o�o�̪��u�����p�r�v�۰���J mulu label �|����n�C
#          ��J��A�A�� xml �H���h�s��A�Y�����n�N�O�d�A�Y���o�۴N�屼�C
# v 2.4.2 2004/5/13 02:22�U�� by Ray
#         X71n1414_p0397b15Q#2�L����य���Ыn��
# v 2.4.3 2004/5/28 04:15�U�� by Ray
# v 2.5.1, 2004/7/7 09:21�W�� by Ray
#	X64 �B�z e, <e>, </e>
# v 2.5.2, 2004/7/22 11:13�W�� by Ray
#	X �������~ X64n1271_p0777a02X##No. 1271-A
# 2004/9/3 09:36�W�� by Ray
#	<n> �~�ӤW�@�� n ���Y��
# 2008/04/11 by heaven
#	�䴩 <annals><date><event> �аO
# 2008/06/16 by heaven : <��> -> &unrec;
# 2008/06/17 by heaven : �䴩���q�Ϊ��аO <no_chg>[��*�_]</no_chg> --> <term rend="no_nor">&CB07460;</term>
# 2008/06/19 by heaven : �B�z [<��>>��] �L�k�۰��ন XML �����D. ���k�O���e�B�z <��> -> &unrec;
# 2009/02/21 by heaven : �䴩�ĤT���g�媺�N�X C , C01n0001_p0001a01
# 2009/02/28 by heaven : �䴩H��W�}�Y�N�X�A�����䴩�ĤT���g�媺�N�X C , C01n0001_p0001a01
# 2009/03/14 by heaven : wit �ݩʤ䴩���v�P�å~
# 2010/07/19 by heaven : �ק�䴩���X�i��j�� 3
# 2010/11/25 by heaven : �䴩<tt>�аO
# 2010/12/06 by heaven : �䴩<tt>�аO, <tt> �аO�i��|���
# 2010/12/04 by heaven : <app> ���S����r�������n���� &lac;
# 2010/12/05 by heaven : <T> �аO���n���� list �� item .
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

# �t entity �� big5
$big5a = '(?:&[^;]+?;|[\xA1-\xFE][\x40-\x7E\xA1-\xFE]|[\x00-\x7F])';

#regex for gaiji expression
$pattern = << 'EOP';
		(									#capture open
		(?:��|�e|�Y)?
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char �P or parens expr (�P*��)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?��]
		\]
		(?:��|�M)?
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
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char �P or parens expr (�P*��)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?��]
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
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char �P or parens expr (�P*��)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?��]
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
readSource(); #Ū �ӷ���

$cjn = 0;
%open=();
readSutra(); #Ū�g����


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
				if ($_ eq "cell") { # ����ؤ]�\�ٷ|�����, �����D���S��
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

# T �j���s��j�øg (Taisho Tripitaka) �]�j���á^ �i�j�j
# X �÷sġ�j�饻���øg (Manji Shinsan Dainihon Zokuzokyo) �]�sġ�����á^ �i����j
# J �ſ��j�øg(�s���ת�) (Jiaxing Canon(Xinwenfeng Edition)) �]�ſ��á^ �i�ſ��j
# H ���v��и�����s (Passages concerning Buddhism from the Official Histories) �]���v�^ �i���v�j
# W �å~��Ф��m (Buddhist Texts not contained in the Tripitaka) �]�å~�^ �i�å~�j 
# I �_�¦�Хۨ�ݤ��ʫ~ (Selections of Buddhist Stone Rubbings from the Northern Dynasties) �i��ݡj

# A ���� (Jin Edition of the Canon) �]�����á^ �i���áj
# B �j�øg�ɽs (Supplement to the Dazangjing) �@ �i�ɽs�j
# C ���ؤj�øg (Zhonghua Canon) �]�����á^ �i���ءj
# D ��a�Ϯ��]������� (Selections from the Taipei National Central Library Buddhist Rare Book Collection) �i��ϡj
# F �Фs�۸g (Fangshan shijing) �@ �i�Фs�j
# G ��Фj�øg (Fojiao Canon) �@ �i���áj
# K ���R�j�øg (Tripitaka Koreana) �]���R�á^ �i�R�j
# L �����j�øg(�s���ת�) (Qianlong Edition of the Canon(Xinwenfeng Edition)) �]�M�áB�s�áB�����á^ �i�s�j
# M �å��øg(�s���ת�) (Manji Daizokyo(Xinwenfeng Edition)) �]�å��á^ �i�å��j
# N �ü֫n�� (Southern Yongle Edition of the Canon) �]�A��n�á^ �i�n�áj
# P �ü֥_�� (Northern Yongle Edition of the Canon) �]�_�á^ �i�_�áj
# Q �l��j�øg(�s���ת�) (Qisha Edition of the Canon(Xinwenfeng Edition)) �]�l���á^ �i�l��j
# S ���ÿ��(�s���ת�) (Songzang yizhen(Xinwenfeng Edition)) �@ �i����j
# U �x�Z�n�� (Southern Hongwu Edition of the Canon) �]���n�á^ �i�x�Z�j

# R �����øg(�s���ת�) (Manji Zokuzokyo(Xinwenfeng Edition)) �]�����á^
# Z �äj�饻���øg (Manji Dainihon Zokuzokyo)

	# �U�ت��� TXJHWIABCDFGKLMNPQSU
	if ($bd =~ /^T/) {
		$collection = "Taisho Tripitaka";
	} elsif ($bd =~ /^X/) {
		$collection = "�� Xuzangjing";
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
	<extent>${extent}��</extent>
	<publicationStmt>
		<distributor>
			<name>���عq�l����| (CBETA)</name>
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
			print STDERR "$quezi �䤣�� CB �X\n";
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
	"�@", "1",
	"�G", "2",
	"�T", "3",
	"�|", "4",
	"��", "5",
	"��", "6",
	"�C", "7",
	"�K", "8",
	"�E", "9",
	"��", "0",
	"�Q", "",
	"��", "",
);

sub exnum{
	local($_) = $_[0];
	return "1000" if ($_ eq "�d");
	return "100" if ($_ eq "��");
	return "10" if ($_ eq "�Q");
	s/^�d([^�][^�])/10$xnum{$1}/;
	s/�d([^�][^�])/0$xnum{$1}/;
	s/^�d/1/;
	s/^�ʤQ$/110/;
	s/�Q$/0/;
	s/^��([^�][^Q])/10$xnum{$1}/;
	s/��([^�][^Q])/0$xnum{$1}/;
	s/^��/1/;
	s/^([0-9])?�Q/${1}1/;
	s/�ʤQ/1/;
	s/([\xa1-\xfe][\x40-\xfe])/$xnum{$1}/g;
	return $_;
}

sub fig{
	local($loc) = $_[0];
		$loc =~ s/�@/1/g;
		$loc =~ s/�G/2/g;
		$loc =~ s/�T/3/g;
		$loc =~ s/�\|/4/g;
		$loc =~ s/��/5/g;
		$loc =~ s/��/6/g;
		$loc =~ s/�C/7/g;
		$loc =~ s/�K/8/g;
		$loc =~ s/�E/9/g;
		$loc =~ s/^�Q$/10/g;
		$loc =~ s/���Q$/\.10/;
		$loc =~ s/^�Q(.)/1$1/g;
		$loc =~ s/(.)�Q$/${1}0/g;
		$loc =~ s/���Q/\.1/;
		$loc =~ s/�Q//g;
		$loc =~ s/��/100/g;
		$loc =~ s/��/0/g;
		$loc =~ s/\s+//g;
		$loc =~ s/��/\./;
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
	if ($itag eq "��" or $itag=~/^<p/){
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
	} elsif ($itag eq "��"){
		if ($open{"title"} > 0) {
			$open{"title"}=0;
			return "</title>";
		}
	} elsif ($itag eq "��"){
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
	# T53n2121_p0125b28P##��������@��]�L�q�ơ@�@�]�t�M�X��
	if ($text =~ /��/) {
		$text =~ /^(.*)��(.*)$/;
		my $s1 = $1;
		my $s2 = $2;

		my $len=myLength($s1)+1;
		my $id= "lg${vol}p$p$sec${line}" . sprintf("%2.2d",$len);	
		
		if ($open{"p"}>0) {
			$s1 .= "</p>";
			$open{"p"}--;
		}
		$s2 =~ s#((�@)+)#</l><l>$1#g;
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
	$c2 =~ s/\[[0-9�][0-9�]\]//g;
	$c2 =~ s/<note [^>]*>.*?<\/note>//g;
	$c2 =~ s/<lb[^>]*>//;
	$c2 =~ s/\n//;
	
	# X78n1553_p0464b22J##�Ѹt�s�O�����ĤQ�@�@�@�e����f
	if ($c2 =~ /^(.*?)�@/) {
		$c2=$1;
	}
	
	if ($debug) {
		print STDERR "520 $c2\n";
	}

#	print STDERR "$c2\n";
	if ($c2 eq "�W"){
		$cjn = 1;
		$jcnt = 1;
	} elsif($c2 eq "�U" || $c2 eq "��"){
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
	#X78n1549_p0282b08Q#2�ڤ@
	#������X<lb ed="X" n="0282b08"/><div2 type="other"><mulu type="��L" level="2" label="�ڤ@"/><head>�ڤ@</head>
	#�ҥH���� hide
	#return "$x1&M024261;" if ($x2 eq "��");
	#return "$x1&M040426;" if ($x2 eq "��");
	#return "$x1&M034294;" if ($x2 eq "��");
	#return "$x1&M005505;" if ($x2 eq "��");
	#return "$x1&M010527;" if ($x2 eq "��");
	#return "$x1&M026945;" if ($x2 eq "��");
	#return "$x1&M006710;" if ($x2 eq "��");
	return "$x1$x2";
}

sub myLabel {
	my $s = shift;
	if ($debug2) {
		print STDERR "487 myLebel($s)\n";
	}
	$s =~ s/\[\d\d\]//g;
	$s =~ s/\[��]//g;  # added by Ray 2000/11/27 09:54�W��
	# \xa6\x61 = �a
	my @type = ("�~","��","�|","�g","\xa6\x61","��","�t�_");

	$s =~ s/<corr.*?>//g;
	$s =~ s#</corr>##g;
	
	# add by Ray 2003/8/11 11:03�W��
	if ($s =~ m#^<app><lem wit="�iCBETA�j" resp=".*?">(.*?)</lem><rdg wit="$wit">(.*?)</rdg></app>$#) {
		my $s1=$1;
		my $s2=$2;
		if ($s2 eq '') {
			#$s = "�]$s1�^";
			$s = $s1;
		} else {
			$s = $s1;
		}
	} else {
		$s =~ s#<app><lem wit="�iCBETA�j" resp=".*?">(.*?)</lem><rdg wit="$wit">.*?</rdg></app>#$1#g;
	}
  
	#$s =~ s#<note.*?</note>##g;
	$s =~ s#<note[^>]*?>(.*?)</note>#\($1\)#g;

	$s =~ s/^��//;
	$s =~ s/^�].+�^��.+��(.+�g��.+)$/$1/;
	# "�]" = \xa1\x5d, "�^" = \xa1\x5e
	$s =~ s/^\xa1\x5d.+\xa1\x5e��.+��(.+�g��.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e��.+��.+�g(.+�~��.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(.+�~��.+)$/$1/;
	$s =~ s/^��.+��.+�g(.+�~��.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e��.+��(.+�g)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(.+�g��.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(��.+��)��$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(��.+��)$/$1/;
	$s =~ s/^���(.+�~��.+)$/$1/;
	$s =~ s/^��.+��(.+�~��.+)$/$1/;
	$s =~ s/^��.+��(.+�~��.+)$/$1/;
	$s =~ s/^.+\xb7\x7c��.+��(�@|�G|�T|\xa5\x7c|��|��|�C|�K|�E|�Q|��)+(.+�~��.+)$/$2/;  # \xb7\x7c �|
	$s =~ s/^.+\xb7\x7c��(�@|�G|�T|\xa5\x7c|��|��|�C|�K|�E|�Q|��)+(.+�~��.+)$/$2/;  # \xb7\x7c �|
	$s =~ s/^.+\xb7\x7c(.+�~��.+)$/$1/;  # \xb7\x7c �|
	$s =~ s/^.+����(�@|�G|�T|\xa5\x7c|��|��|�C|�K|�E|�Q|��)+(.+�~��.+)$/$2/;  # \xb7\x7c �|
	if ($s !~ /���O/) { $s =~ s/^.+��(.+�~��.+)$/$1/; }
	$s =~ s/^.+�g(.+�~��.+)$/$1/;
	$s =~ s/^(.+��.+)��.+$/$1/;
  
	if ($debug) {
		print STDERR "481 $s\n";
	}
  	
	# "�Ĥ@�~" => "1 �Ĥ@�~"
	foreach $type (@type) {
		$type = quotemeta($type);
		if ($s =~ /^��(.+)$type$/) {
			my $a = cn2an($1);
			if ($a ne "") { $s = "$a $s"; }
		}
	}

	if ($debug) { print STDERR "494 $s\n"; }

	# "�����~�Ĥ@���@" => "1 �����~"
	if ($s !~ /^\d+ /) {
		# X79n1557_p0012a09Q#2�L�h���Y�T�C�ĤE�ʤE�Q�K�L�C�s�C�r��
		#if ($s =~ /^(.+)��((�@|�G|�T|\xa5\x7c|��|��|�C|�K|�E|�Q|��)+)(��)*.*$/) {
		if ($s =~ /^(.+)��((�@|�G|�T|\xa5\x7c|��|��|�C|�K|�E|�Q|��)+)(��)+.*$/) {
			$s = $1;
			$a = cn2an($2);
			if ($a ne "") { $s = "$a $s"; }
		}
	}

	if ($debug) { print STDERR "507 $s\n"; }

	# "�]�@�^������" => "1 ������"
	if ($s =~ /^\xa1\x5d((?:�@|�G|�T|�||��|��|�C|�K|�E|�Q|��)+)\xa1\x5e(.*)$/) {
	  $s = $2;
	  my $a = cn2an($1);
	  if ($a ne "" and $s ne "") { $s = " $s"; }
	  $s = $a . $s;
	}
	
	# �h���y�I
	while ($s =~ /^($big5*?)�C(.*)$/) {
		$s = $1 . $2;
	}
	
	$s =~ s/&lac;//g;
	$s =~ s/&([^;]+);/��$1�F/g;
	$s =~ s/&(CB\d{5});/$1/g;
	$s =~ s/<anchor id=\".*?\"\/>//g;
	$s =~ s/<figure.*?\/>//g;
	#$label =~ s/<anchor[^>]*?>//g;
	if ($debug) {
		print STDERR "580 end myLabel $s\n";
	}
	$s =~ s/^\((.*)\)$/$1/; # �p�G�e�᳣�O�b�άA��, �N�h��
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
    
	if ($divtype eq "xu") { $s = "��"; }
	elsif ($divtype eq "pin") { $s = "�~"; }
	elsif ($divtype eq "hui") { $s = "�|"; }
	elsif ($divtype eq "fen") { $s = "��"; }
	elsif ($divtype eq "other") { $s = "��L"; }
	elsif ($divtype eq "w") { $s = "����"; } # 2004/6/18 03:06�U��
	#else { $s = "��L"; }
	
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
		$zu      = $row{"des"};      # �զr��
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
#&MX000144;	[(�P/��)*(��-��+��)]
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
	#edith modify 2005/5/27  �s"�Ĥ@�B�ĤG�K"�A�Ӥ��O "���Ĥ@�B ���ĤG"�A
	#X56n0949_p0870a17J##�~�~�s�Ĥ@
	#if ($juan =~ /^(.*)open">(.*��(?:\[[0-9�][0-9�]\])*��)(.*)$/s) {
	if ($juan =~ /^(.*)open">(.*[��|�s](?:\[[0-9�][0-9�]\])*��)(.*)$/s) {
		if ($debug) {print STDERR "845 ($1)($2)($3)\n";}
		$juan = $1 . &cjuan($2, $3);
	} elsif ($juan =~ /^(.*)open">(.*��.*?��)(.*)$/s) {
		if ($debug) {print STDERR "848 ($1)($2)($3)\n"; getc;}
		$juan = $1 . &cjuan($2, $3);
	#} elsif ($juan =~ /^(.*)open">(.*��.*?)((�W|��|�U))/s) {
	} elsif ($juan =~ /^(.*)open">(.*��.*?)((�W|��|�U))$/s) {
		if ($debug2) {print STDERR "852 ($1)($2)($3)\n"; getc;}
		$juan = $1 . &cjuan($2, $3);
	} elsif ($juan =~ /^(.*)open">(.*?)(�W|��|�U)(��.*)$/s) {
		if ($debug2) {print STDERR "855 ($1)($2)($3)($4)\n"; getc;}
		$juan = $1 . &cjuan($2, $3) . $4;
	} elsif ($juan =~ /^(.*)open">(.*?)(�W|��|�U)(�o.*)$/s) {
		$juan = $1 . &cjuan($2, $3) . $4;
	} elsif ($juan =~ /^(.*)open">(.*�@��.*)$/s) {
		#$juan = $1 . 'open" n="001">' . $2;
		#edith modify 2005/4/22 <juan fun="open" n="1"> n ���ƭ� 1~9 ��1��, 10~99��2��, 100~999 ��3��....�A�{���Τ@���� 0 �F�C
		$juan = $1 . 'open" n="1">' . $2;
	# X83n1578_p0412c01J##����������G
	} elsif ($juan =~ /^(.*)open">(.*����)((?:�@|�G|�T|\Q�|\E|��|��|�C|�K|�E|�Q|��)+)(.*)$/s) {
		$juan = $1 . cjuan($2, $3) . $4;
	} elsif ($juan =~ /^(.*)open">(.*��)((?:�@|�G|�T|\Q�|\E|��|��|�C|�K|�E|�Q|��)+)(.*)$/s) {
		if ($debug2) {print STDERR "867 ($1)($2)($3)($4)\n"; getc;}
		$juan = $1 . cjuan($2, $3) . $4;
	#edith add 2005/5/20 ���Ĥ@�b�ĤG��~�ݨ�
	#X74n1470_p0146c13j##�j��s����Y�g���L�D���Q�����@�`[�L*��]§�b��
         #x74n1470_p0146c14j=#���Ĥ@
	} elsif ($tag =~ /J=/ and $juan =~ /^(.*)">(.*��(?:\[[0-9�][0-9�]\])*��)(.*)$/s) {
		if ($debug2) {print STDERR "871 ($1)($2)($3)\n"; getc;}
		$juan_reCount=1;
		$juan = $1 . &cjuan($2, $3);
		#�^�Ǫ�$juan �t <juan fun="open" n="1open" n="2">, ������ n="1open" �R��
		#�ӥB <mulu type="��" n="1"/> �󥿬� <mulu type="��" n="2"/>
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
		$jcnt = 1; # juan count �O���ثe��ĴX��
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
		$juan =~ s#<mulu>#<mulu type=\"��\" n=\"$s\"/>#;
		if ($currentJuan != $juanNum) {
			#edith modify 2005/5/20 ����̨S���ۦP�� milestion ����, �~�n�[
			#s �N�r������@��
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
		
	#2005/3/15 �H�Ŧr����N��r��, �H�K sub Tag_J �̷|�]inline_tag();�ɦr�꭫�Щ�J$buf
	$space="";
	#edith modify 2005/5/9 ��g�b�o�q��:   }elsif ($tag eq "j=" or $tag =~ /J/) {  
	#if ($juan =~ /$text_J/) {$juan =~ s/\Q$text_J\E//g;}
	
	if ($juan =~ /|/) 
	{
		$juan =~ s/|//g;
		if ($debug) {print STDERR "896|juan=[$juan]\n"; getc;}	
	}
	
	$text_J="";	
	$buf .= $juan;   #edith hide 2005/5/20	
	#$juan_tmp = $juan; #edith modify 2005/5/20
	#edith modify 2005/5/20 ���s�p�����
         if ($juan_reCount)
         {
            $currentJuan=$cjn;
            $juan_reCount=0;
         }
	if ($debug) {
		print STDERR "914 $juan_tmp=\n$juan_tmp\n";
		getc;
	}
	#edith modify 2005/3/9 ��hide��, </jhead></juan>�b checkClose() ��
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
	$n_rend=0; # ���� n �Y�ƪ��~��
	if ($tag=~/(\d+)/) {
		$level=$1;
	} else {
		$level=1;
	}
	
	if ($open{"head"} == 0){
		#edith modify 2005/5/19 �J��Q, �ٲ��۹諸�����Ÿ�( </e> </n> </o> </w>)�M�ᵲ���W�@�Ӭ���tag
		#<e> <d>�B<n> <d> �� form def entry
		#<o> <u> ��  div p 
		#<w> <a>�� sp dialog
		#$buf .= &checkopen("l","lg", "p", "title", "item", "list", "sp", "dialog");
		$buf .= &checkopen("l","lg", "p", "title", "item", "list", "sp", "dialog", "form", "def", "entry",);
		$in_div_note=0; #�{����J�� </n>�|�N�Y�Ѽ��k�s$in_div_note=0, �P�_�O���O�b <div? type="note"> ��
	}
	#if ($debug2) { print STDERR "890 in tag_Q() tag=[$tag]\n"; }
	#if ($debug2) { print STDERR "892 head�Ӽ�=[" . $open{"head"} ."]\n"; }
	if ($debug2) { print STDERR "922 tag=[" . $tag ."]\n"; }
	
	if ($tag =~ /=/) {
		$head .= $lb;
	} else {
		$wq=0;
		$buf .= &checkopen("head"); # added 2004/6/25 11:32�W��
		
		while ($level <= $open{"div"}) {
			$buf .= "</div" . $open{"div"} . ">";
			$open{"div"}--;
			$open{"commentary"}=0;
			$div_orig = 0;
		}
		# markedy by Ray 2006/9/18 11:19�W��
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
					$buf .= "<div" . $level . " type=\"$divtype\"><mulu level=\"$level\" label=\"����\"/>";
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
			#edith modify 2005/3/15 $tag_J_Q �N��w�]�L tag_J, ���ΦA�[ $lb
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
	
	$pMarginLeft=''; # �s�� div �}�l, ���A�~�ӤW�@�� P �� margin-left
	if ($debug2) { 
		print STDERR "\n1004 tag_Q() label=[$label] head=[$head]\n"; 
	}
	
	inline_tag();
	
	if ($debug2) { 
		print STDERR "960 end tag_Q() label=[$label] head=[$head]\n"; 
		print STDERR "962 head�Ӽ�=[" . $open{"head"} ."]\n\n";
		getc;		
	}
}

sub gaijiReplace {
	my $s = shift;
	#if ($s =~ /�e/ || $s =~ /��/) {$edith=1;}
	
	# ���t ">"(\x3e), "["(\x5b), "]"(\x5d) �� big5
	my $p="(?:[\x80-\xff][\x00-\xff]|[\x00-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])";
	#if ($edith eq 1) {print STDERR "\n995|$s\n";}
	$s =~ s#(\[�@/��\]\[��\*��\])#&rep($1)#egx;
	$s =~ s#(�Y\[��\*��\])#&rep($1)#egx;
	$s =~ s#(\[��\*��\]��)#&rep($1)#egx;
	#$s =~ s#(�w\[��\*�C\])#&rep($1)#egx;
	$s =~ s#(\[��\*�O\]�M)#&rep($1)#egx;
	#if ($edith eq 1) {print STDERR "\n1001|$s\n";}
	$s =~ s#(����\[�I/��\]\[�I/��\])#&rep($1)#egx;	
	$s =~ s#(��\[�I/��\])#&rep($1)#egx;
	#if ($edith eq 1) {print STDERR "\n1004|$s\n";}
	#edith modify: 2005/1/17���e[��-�B+��] ������ &CI0005;
	$s =~ s#(�e\[��-�B\+��\])#&rep($1)#egx;	
	$s =~ s#(\[��\-�G\+��\]\[��\-�G\+��\])#&rep($1)#egx;
	$s =~ s#(\[��\*��\]\[��\*��\])#&rep($1)#egx;
	
	# X85n1592_p0281b14_##[(�G-(�e-�G))-��+��)]�֦p��)
	#$s =~ s/$pattern/&rep($1)/egx;		
	$s =~ s/(\[$p+?\])/&rep($1)/egx;		
	#if ($edith eq 1) {print STDERR "\n1008|$s\n";$edith=0;getc}
	return $s;
}

sub final {
	print STDERR "�̫ᶥ�q�B�z....\n";
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
		#2004/9/23 01:42�U��
		#$xml =~ s/(<lb[^>]*?>)((?:\n<lb[^>]*?>)+)(<milestone[^>]*?>)/$1$3$2/sg;
		$xml =~ s/(<lb[^>]*?>)((?:\n<lb[^>]*?>)+)(<milestone[^>]*?>(<mulu[^>]*?>)?)/$1$3$2/sg;
		
		# �p�G </head>, </p> �e�S��r����W�@��̫�
		# </cell>���β�
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(p|div\d+|list)>)+)#$2$1#sg;
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(head|p|div\d+|list)>)+)#$2$1#sg;
		$xml =~ s#((?:\n<[lp]b[^>]*?>(?:<mulu[^>]*?>)*)+)((</(head|p|div\d+|list)>)+)#$2$1#sg;
		###edith modify: 2005/1/25 </item></list>�e�S��r����W�@��̫�
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(head|item|p|div\d+|list)>)+)#$2$1#sg;
		###edith modify: 2005/1/31 </form>�e�S��r����W�@��̫�
		#$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(form|head|item|p|div\d+|list)>)+)#$2$1#sg;
		###edith modify: 2005/5/6 </l>, 2005/5/10 </sp></lg>, 2005/5/11</def></entry>, 2005/5/24 dialog �e�S��r����W�@��̫�
		$xml =~ s#((?:\n<[lp]b[^>]*?>)+)((</(annals|date|def|dialog|entry|event|form|head|item|p|div\d+|list|l|lg|sp)>)+)#$2$1#sg;

		open O, ">$file" or die;
		print O $xml;
		close O;
	}
	
	if ((scalar @notfound)>0) {
		print STDERR "�䤣��CB�X���զr���G\n";
		foreach $s (@notfound) {
			print STDERR "$s\n";
		}
	}
}

sub readSource {
	print STDERR "Ū �ӷ���...\n";
	open(T, $cfg{"laiyuan"}) || print STDERR "can't open laiyuan\n";
	while(<T>){
	#S:�����
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
	#4SJ    T1421-22-p0001 K0895-22 30 ���F�볡�M�Q������(30��)�i�B�� ������@�ǹD�͵�Ķ�j
	#SC4F   T0001-01-p0001  V1.12  2001/04/01   22  �����t�g           �i�᯳ ����C�٦@�Ǧ��Ķ�j    K0647-17
	#CR     P1684-174-p0785 V1.0   2010/07/02    1  ���иg�ײ��`�n   �i�� �b���z�j
			($ls, $sid, $v, $k, $juan, $title, $rest) = split(/\s+/, $_, 7);
			#($tnum, $tvol, $d1, $tpage) = unpack("A6 A2 A1 A5", $sid);		# �U�ƥi��j�� 2, ���椣�ΤF
			$sid =~ /(.*?[\-_])(.*?)[\-_](.{5})/;
			$tnum = $1;
			$tvol = $2;
			$tpage = $3;
			
			if ($tnum !~ /^[TXJHWIABCDFGKLMNPQSU]/) {
				next;
			}
			$rest =~ s/\([ 0-9].*//;
			$rest = gaijiReplace($rest);
			$title = gaijiReplace($title); # added 2004/6/25 11:02�W��
			$tnum =~ s/-//;
			$tnum =~ s/_//;
			$tnum =~ s/[TXJHWIABCDFGKLMNPQSU]/n/;
			$tit{$tnum} = $title;
			$extent{$tnum}=$juan;
			#die "no title $_\n" if ($tnum eq "" && $tnum ne "");
			die "$tnum no title $_\n" if ($tnum ne "" and $title eq '');
			print STDERR "1163 $tnum \t$title\n";
			$rest=~/�i(.*?)�j/;
			$author{$tnum}=$1;
			$sid = $tnum;
			$sid =~ s/n//;
	#		print STDERR "$tnum\t$sid\n";
			@ly = split(//, $ls);
			$outc = "";
			$oute = "";
			for $l (@ly){
				next if ($namc{$l} eq "");
				$outc .= "$namc{$l}�A";
				$oute .= "$name{$l}, ";
			}
			$outc =~ s/�A$//;
			$oute =~ s/, $//;
			$lyc{$sid} = $outc;
			$lye{$sid} = $oute;
		}
	}
}

sub readSutra {
	#
	# Ū�g����
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
			print STDERR "Ū�i $_\n";
			watch_buf(1205);
			getc;
		}
		# ���קK������ [<��>>XX] �V�c�F >> �Ÿ�, �ҥH���B�z <��>
		s/<��>/&unrec;/g;	
		#($aline, $text) = unpack("A20 A*", $_);	# �U�Ʒ|�j�� 3 �X, �ҥH���γo��
		/^(\D*\d*n.{16})(.*)/;
		$aline = $1;
		$text = $2;
		if ($debug) { 
			print STDERR "932 align=[$aline] text=[$text]\n"; 
		}
		#T12n0374_p0365a01N##No. 374
		#($vol, $num, $p, $sec, $line, $tag) = unpack("A3 A6 A5 A1 A2 A3", $aline);	# �U�Ʒ|�j�� 3 �X, �ҥH���γo��
		
		$aline =~ /(\D*\d*)(n.{5})(p.{4})(.)(..)(...)/;
		$vol = $1;
		$num = $2;
		$p = $3;
		$sec = $4;
		$line = $5;
		$tag = $6;
		
		$WQ_n=0;    #�Ҧp:X74n1496_p0784a11WQ3 �p��@�椤�� <n> ���X��
		
		##edith modify:2004/12/9 �歺�� F, �n�p��C��<c>�Ӽ�, ���l�Ȭ�1
		if ($tag =~ /F/)
		{ 
			$c_Num = 0;	##edith modify:2004/12/29 ��l�ȧ令0
			$a_s = $text;
			##edith modify 2005/3/7 �Ҧp X76n1516_p0018b13f##<c>����(�G)<c>(���Z��)(�ڦ踾)<c2>(��)(�����d��)
			#edith modify 2005/3/21 �Ҧp X76n1517_p0203c14Q#2���夽�O�ǢѦD���|�ѡ@�s²�@��
			#C �n�[�b�Ů�e��
			#edith modify 2005/4/21 �s�W</o>			
			while ($a_s =~ m#^((?:$big5)*?)(�@�@|�@|��|<a>|��|��|<c(?: r)?\d*?>|<d>|��|<e>|</e>|</F>|��|<I\d*?>|<J>|<j>|</L\d*?>|<n[,\d]*>|</n>|<o>|</o>|��|��|<p[,\-\d]*>|</P>|</?Q\d*>|<S>|<u>|</u>|<w>|</w>|��|��)(.*)$#) 
			{
				$a_text .= $1;
				$a_i_tag = $2;
				$a_s = $3;		
				#if ($a_i_tag eq "<c>")	{$c_Num++;}	#�p��<table cols="?"> cols �Ӽ� (�歺��F)		
				if ($a_i_tag =~ /^<c/)	{$c_Num++;}	#�p��<table cols="?"> cols �Ӽ� (�歺��F)		
			}
		}

		#edith modify 2005/3/8 start: <cell> ����檺���p, �ҥH<table cols="?">
		#cols �Ӽ� $c_Num�n�~��֥[
		if ($tag !~ /F|f/ && $startRow) #�N���O��檺�Ĥ@��, �ӥB<cell>���b�Ĥ@�C��
		{ 
			$a_s = $text;
			#edith modify 2005/3/21 �Ҧp X76n1517_p0203c14Q#2���夽�O�ǢѦD���|�ѡ@�s²�@��
			#while ($a_s =~ m#^((?:$big5)*?)(�@�@|�@|��|<a>|��|��|<c\d*?>|<d>|��|<e>|</e>|</F>|��|<I\d*?>|<J>|<j>|</L\d*?>|<n[,\d]*>|</n>|<o>|��|��|<p[,\-\d]*>|</P>|</?Q\d*>|<S>|<u>|</u>|<w>|</w>|��|��)(.*)$#) 
			#edith modify 2005/4/21 �s�W</o>
			while ($a_s =~ m#^((?:$big5)*?)(�@�@|�@|��|<a>|��|��|<c\d*?>|<d>|��|<e>|</e>|</F>|��|<I\d*?>|<J>|<j>|</L\d*?>|<n[,\d]*>|</n>|<o>|</o>|��|��|<p[,\-\d]*>|</P>|</?Q\d*>|<S>|<u>|</u>|<w>|</w>|��|��)(.*)$#) 
			{
				$a_text .= $1;
				$a_i_tag = $2;
				$a_s = $3;		
				if ($a_i_tag eq "<c>")	{$c_Num++;}
			}
			#edith modify 2005/5/18 <table cols="2"> �n�b <pb> �U�@��
			#$buf_table_new= "\n". '<table cols="' . $c_Num .'">' . $lb;
			$buf_table_new= "\n". '<table cols="' . $c_Num .'">' . $lb_temp;
			$pb_flag=0;
	                   $lb_temp="";
			if ($debug2) {print STDERR "\n1184|$buf_table_new\n";getc;}
			$buf =~ s/$buf_table/$buf_table_new/;	#�Ĥ@�����N		
			$buf_table	= $buf_table_new;	#�ĤG���H�W���N�ɥΪ�
		}#edith modify 2005/3/8 end

# T �j���s��j�øg (Taisho Tripitaka) �]�j���á^ �i�j�j
# X �÷sġ�j�饻���øg (Manji Shinsan Dainihon Zokuzokyo) �]�sġ�����á^ �i����j
# J �ſ��j�øg(�s���ת�) (Jiaxing Canon(Xinwenfeng Edition)) �]�ſ��á^ �i�ſ��j
# H ���v��и�����s (Passages concerning Buddhism from the Official Histories) �]���v�^ �i���v�j
# W �å~��Ф��m (Buddhist Texts not contained in the Tripitaka) �]�å~�^ �i�å~�j 
# I �_�¦�Хۨ�ݤ��ʫ~ (Selections of Buddhist Stone Rubbings from the Northern Dynasties) �i��ݡj

# A ���� (Jin Edition of the Canon) �]�����á^ �i���áj
# B �j�øg�ɽs (Supplement to the Dazangjing) �@ �i�ɽs�j
# C ���ؤj�øg (Zhonghua Canon) �]�����á^ �i���ءj
# D ��a�Ϯ��]������� (Selections from the Taipei National Central Library Buddhist Rare Book Collection) �i��ϡj
# F �Фs�۸g (Fangshan shijing) �@ �i�Фs�j
# G ��Фj�øg (Fojiao Canon) �@ �i���áj
# K ���R�j�øg (Tripitaka Koreana) �]���R�á^ �i�R�j
# L �����j�øg(�s���ת�) (Qianlong Edition of the Canon(Xinwenfeng Edition)) �]�M�áB�s�áB�����á^ �i�s�j
# M �å��øg(�s���ת�) (Manji Daizokyo(Xinwenfeng Edition)) �]�å��á^ �i�å��j
# N �ü֫n�� (Southern Yongle Edition of the Canon) �]�A��n�á^ �i�n�áj
# P �ü֥_�� (Northern Yongle Edition of the Canon) �]�_�á^ �i�_�áj
# Q �l��j�øg(�s���ת�) (Qisha Edition of the Canon(Xinwenfeng Edition)) �]�l���á^ �i�l��j
# S ���ÿ��(�s���ת�) (Songzang yizhen(Xinwenfeng Edition)) �@ �i����j
# U �x�Z�n�� (Southern Hongwu Edition of the Canon) �]���n�á^ �i�x�Z�j

# R �����øg(�s���ת�) (Manji Zokuzokyo(Xinwenfeng Edition)) �]�����á^
# Z �äj�饻���øg (Manji Dainihon Zokuzokyo)

		# TXJHWIABCDFGKLMNPQSU
		if ($vol =~ /^T/) {
			$wit="�i�j�j";
		} elsif ($vol =~ /^X/) {
			$wit="�i����j";
		} elsif ($vol =~ /^J/) {
			$wit="�i�ſ��j";
		} elsif ($vol =~ /^H/) {
			$wit="�i���v�j";
		} elsif ($vol =~ /^W/) {
			$wit="�i�å~�j";
		} elsif ($vol =~ /^I/) {
			$wit="�i��j";		# ��ݦʫ~
		} elsif ($vol =~ /^A/) {
			$wit="�i���áj";
		} elsif ($vol =~ /^B/) {
			$wit="�i�ɽs�j";
		} elsif ($vol =~ /^C/) {
			$wit="�i���ءj";
		} elsif ($vol =~ /^D/) {
			$wit="�i��ϡj";
		} elsif ($vol =~ /^F/) {
			$wit="�i�Фs�j";
		} elsif ($vol =~ /^G/) {
			$wit="�i��Сj";
		} elsif ($vol =~ /^K/) {
			$wit="�i�R�j";
		} elsif ($vol =~ /^L/) {
			$wit="�i�s�j";
		} elsif ($vol =~ /^M/) {
			$wit="�i�å��j";
		} elsif ($vol =~ /^N/) {
			$wit="�i�n�áj";
		} elsif ($vol =~ /^P/) {
			$wit="�i�_�áj";
		} elsif ($vol =~ /^Q/) {
			$wit="�i�l��j";
		} elsif ($vol =~ /^S/) {
			$wit="�i����j";
		} elsif ($vol =~ /^U/) {
			$wit="�i�x�Z�j";
		}
		$tag =~ s/#//g;

		#these tags are not used yet!	
		#this line has characters in siddham script	
		$tag =~ s/H//;
		
		#there are some images on this location	
		$tag =~ s/G//;
		
		#if ($tag =~ /\?/){
		#if ($tag =~ /[\?F]/){	###edith hide 2004/12/9 �歺F�t�@�B�z�F
		#	$qu = "<xx/>";
		#	if ($debug) {
		#		print STDERR "924 test=$text qu=$qu\n";
		#	}
		#} else {
		#	$qu = "";
		#}
		$tag =~ s/\?//;
		#$tag =~ s/F//; edith hide 2004/12/9 �歺F�t�@�B�z�F
		
		if ($text=~/^($big5a*?)(��.*)$/) {
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
		
		# added by Ray 2000/11/28 10:38�W��
		# �հɲŸ� [99] => <anchor>
		$text =~ s/\[(\d{2,3}[A-Z]?)\]/<anchor id=\"fn${vol}p$p$sec$1\"\/>/g;
		#$text =~ s/\[(\d{2,3})\]/<anchor type="footnote" n=\"$1\"\/>/g;
		while ($text =~ /\[��\]/) {
			$count ++;
			my $id = sprintf("fx${vol}p$p$sec%2.2d",$count);
			$text =~ s/\[��\]/<anchor id=\"$id\"\/>/;
			#$text =~ s/\[��\]/<anchor type="��" n=\"$count\"\/>/;
		}

		while ($text =~ /�i�ϡj/) {
			$figureCount ++;
			my $id = sprintf("${vol}p${p}_%2.2d",$figureCount);
			$text =~ s/�i�ϡj/<figure entity=\"Fig$id\"\/>/;
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
                            #X74n1467_p0113b18S##�@(�Q��T�@��@�@�������Ĥ@�@�@�E�~�ײ��͡@�@�¼w�L�a���@�@�ڤ��j�k�̡@�@�b���T�~�o
                            #�ܦ� X74n1467_p0113b18S##(�@�Q��T�@��@�@�������Ĥ@�@�@�E�~�ײ��͡@�@�¼w�L�a���@�@�ڤ��j�k�̡@�@�b���T�~�o
                            #XML�~�|��X <note place="inline">�b<l>���e��
                            #<lg id="lgX74p0113b1801"><note place="inline"><l>�Q��T�@��</l><l>�������Ĥ@</l><l>�E�~�ײ���</l><l>�¼w�L�a��</l><l>�ڤ��j�k��</l><l>�b���T�~�o</l>
			#$text =~ s/\�@\(/\(�@/g;
			 #edith modfiy 2005/5/9 ending
								
			# �p�A�� (...) ���N�� <note place="inline">....</note>
			$text = rep_note($text);
			
			# marked 2004/6/23 03:22�U��
			#if ($text =~ /(��|��|<p.*?>)/ and $tag !~ /[CIMPpQs]/) {
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
		if ($tag !~ /[LQIxX]/) { # LQIxX �᭱���Ʀr��ܼh���A���O�Ů�
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
		
		# k �j������
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
		checkClose(); # �ˬd�W�@������ close �� tag
		
		#W
		#if ($tag =~ /^W/) {  #changed meaning of W 10.10.1999
		if ($tag =~ /^W/) {
			watch_buf(1263);
			# X72n1442_p0723b05Wx#No. 1442-��
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
					$buf .= &checkopen ("p", "l", "lg");   #edith modify 2005/5/11: </div?> �������e�n������ </l></lg>
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
			#tag_a();	#edith note: 2005/2/23 �o��Qhide, �]�\�b�O�B�B�z�F
		} elsif ($tag =~ /[ABEY]/) {
			$pMarginLeft='';
			tag_b();
		} elsif ($tag =~ /C/) {	
			tag_c();
		} elsif ($tag =~ /e/) {	
			tag_e();
		} elsif ($tag eq "Ff") {	###edith modify 2004/12/9 �Ҧp:X78n1546_p0165a06WFf	���t Ff
			tag_Ff();	
		} elsif ($tag eq "F") {	###edith modify 2004/12/9
			tag_F();	
		} elsif ($tag =~ /f/) {		###edith modify 2004/12/9 �Ҧp:X78n1546_p0165a07Wf#	���t f
			tag_f();
		} elsif ($tag =~ /I/) {		
			tag_I();			
		} elsif ($tag =~  /J/) { 
			tag_J();
		#} elsif ($tag eq "j") {  edith modify 2005/5/9
		} elsif ($tag =~  /j/) {
			if ($debug2) {print STDERR "1471|edith($oldtag)\n"; getc;}
			tag_j();
		# x60n1135_p0745a23k#_�O���鳻�����k�X�Q�D
		#} elsif ($tag eq "k") { 
		} elsif ($tag eq "k" or $tag eq "k_") { 
			$buf.=$lb;
			inline_tag();
		} elsif ($tag =~ /M/) { 
			tag_m();  #M �ؿ������g�W
		} elsif ($tag =~ /n/) { 
			tag_n();  #n �q������� 2004/7/1 03:47�U��
		} elsif ($tag =~ /[pPZ]/) { 
			tag_P();
		#} elsif ($tag eq "R") {           #R �ؿ�������Ķ�̩Χ@��
		} elsif ($tag =~ /R/) {           #edith modify:2005/3/15 �� R or R=
			$buf .= checkopen("title");
			$buf .= "$lb$text";
		#} elsif ($tag eq "R=") {           #edith note:2005/3/15 ���P�P�W�@�檺 "R"
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
			# �B�z inline tag �e, �n���� lb �L�X�h
			if ($open{"head"}>0) {
				$head .= $lb;
			} else {
				# x58n1013_p0519a02_##���C�����ǵL���ѫD���C<I2>�G����C�̩��W�w�C�o�ͤW
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
			print STDERR "1260 �@��B�z���� wq=$wq inw=$inw open{div}=" . $open{"div"} . "\n";
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
	if ($text =~ /^($big5*?)��(.*)$/) {
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
	if ($text =~ /($big5a)*(��|<p[,\-\d]*>)/) {
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
	#X74n1499_p1056a01e##�@�ߩ^�Ыn����j�I�v�߻}�@��(���[�P�W)
         #x74n1499_p1056a02e##�@�ߩ^�Фѥx���̤j�v�O��(���[�P�W)
	$buf .= &checkopen("p", "l", "lg", "def", "form" ,"entry");
	$buf .= $lb;

	#X74n1499_p1055c14e##�@�ߩ^�н��v�_Ų(���[�P�W)
	#x62n1202_p0650c11e##�@��(�������g)<d><p,1>�Y�����k�l���k�H�C�D����������C��
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
	$lb =~ s/\n//g;	#edith modify 2004/12/9 $lb���t\n����r��, �h���u���F .xml ���媺�ƪ�
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
	##edith modify:2004/12/9 �歺�� F, �p��C��<c>�Ӽƶ�J cols	
	#edith modify: 2004/12/29 <table>��b<lb><row><cell> �e��, �Ҧp:X78n1546_p0165a05WQ1
	#<table cols="3">
	#<lb ed="X" n="0165a06"/><row><cell>�ٯ]�b�g���Ͷ�</cell><cell>���j�_�]��</cell><cell>�s�ש��Ͷ�</cell></row>
	#edith hide 2005/3/8 
	
	#edith modify 2005/5/18 <table cols="2"> �n�b <pb>
         #x74n1465_p0068b01Ff#<c><c>�@�ڥ����T�c�D(�@��)
         #x74n1465_p0068b02_f#<c><c>�@�ڱ`�D��k��(�@��)
         #<table cols="2">
         #<pb ed="X" id="X74.1465.0068b" n="0068b"/>
         #<lb ed="X" n="0068b01"/><row><cell></cell><cell>�@�ڥ����T�c�D<note place="inline">�@��</note></cell></row>
	if ($pb=~ /<pb/)
	{
                $pb_flag = 1;	 
                $buf .= $pb;
                $lb_temp = $lb;
                $lb_temp=~ s#$pb##;  #�h��$pb
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
		#edith modify 2005/3/8, 2005/5/18<table cols="2"> �n�b <pb> 
		#$buf_table= "\n". '<table cols="' . $c_Num .'">' . $lb;		
		$buf_table= "\n". '<table cols="' . $c_Num .'">' . $lb_temp;
	}
	else
	{
		#$buf .= "<table>\n<row><cell>";
		$buf .= "\n<table>";
	}	
	
	#$buf .= $lb;
	#edith modify 2005/5/18<table cols="2"> �n�b <pb>
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
	
	if ($text =~ /($big5)*��/ or $text =~ /($big5)*��/) {
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
	$pMarginLeft=""; # �����~�� p �Y��
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
	#	if ($lg ne '') { $text = "<l>" . $text; } # �p�G�O�U�|���Ĥ@��
	#	$text =~ s#((�@)+)#</l><l>$1#g;
	#} else {
	#	$text = "<l>" . $text;
	#	$text =~ s/(�@)+/<\/l><l>/g;
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
	#2005/5/10 edith modify : �e�@�檺 </l></lg> �n������, �Ҧp:X74n1470_p0148c10S##
	#X74n1470_p0148c10S##�@�@�@�Ѳ��͡@�@���͵��î��@�@���ֲb�g��
         #X74n1470_p0148c11I##�n�L���å@�ɮ��k��ı���k�����D�J����ĳ��
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
	if ($debug2) {	print STDERR " " x $tab, "1690 inline_tag�e text=$text\n";	}
	inline_tag();
	if ($debug2) {	print STDERR " " x $tab, "1692 inline_tag�� text=$text\n";	getc;}
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
	# mark by Ray 2003/8/13 10:30�W��
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
	#if ($text =~ /($big5)*(��|<p[,\-\d]*>)/) {
	#	$text = inlinep($text);
	#}
	checkCloseDiv();
}

sub tag_s {
	$buf .= $lb;
	inline_tag();
	$buf .= &checkopen("l", "lg");
}

# ������T
sub tag_J {
	if ($debug) { 
		print STDERR "1948 begin tag_J()\n"; 
		print STDERR "1949 juan=[$juan]\n";
		print STDERR "1950 juan_tmp=[$juan_tmp]\n";
	}
	#edith modify 2005/5/9 start
	#X74n1470_p0139a06J##�j��s����Y�g���L�D���Q����
	#X74n1470_p0139a07J=#�@�`[�L*��]§�b�����Ĥ@
	#edith modify 2005/5/20 �Ĥ@�浲���ɵL�k�P�_����, �ĤG��~��"���ĤG"�r��
	#�ҥH�� </juan> �ɤ~�g�J $buf
	#X74n1470_p0147a06J##�j��s����Y�g���L�D���Q�����@�`[�L*��]§�b�����ĤG
	#X74n1470_p0147a07J=#���ĤG
	 if ($open{"jhead"}>0 and $tag!~/=/){
		$buf .= "</jhead>";
		$juan_tmp .= "</jhead>";  #edith modify 2005/5/20
		$open{"jhead"}--;
	}
	
	if ($open{"juanBegin"}>0 and $tag!~/=/){
		if ($debug2) {print STDERR "1972������T|i_tag=$i_tag\n$juan_tmp\n";getc;}		
		$buf .=$juan_tmp;   #edith modify 2005/5/20
		$juan_tmp="";           #edith modify 2005/5/20
		$buf .= "</juan>";
		$open{"juanBegin"}--;
	}
	#edith modify 2005/5/9 end
	
	local $text_J="";
	local $tag_J_Q=0;
	$buf .= &checkopen("l", "lg", "p", "title", "item", "list");
	#if ($debug2) {print STDERR "1793������T|i_tag=$i_tag\n";}
	$text1 = '';
	# Ex: T55n2149_p0219b15J##���j�𤺨�[10]���߾��N���g��Ķ�ұq���Ĥ@��
	if ($text =~ /^(($big5)*)��(($big5)*)$/) {
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
			#edith modify 2005/2/24 J(������T)�椤��A(�@��)
			#X75n1508_p0001a02J##[01]���{�p�Ӧ��D�O�@���ϭ�@���k��
			#$juan = "$lb<juan fun=\"open\"><mulu><jhead>$text";
			$juan = "$lb<juan fun=\"open\"><mulu><jhead>";
		}		
		$open{"jhead"}++;
		$open{"juanBegin"}++;		
		$text_J = $text;	#edith modify 2005/3/15
		#edith modify 2005/3/9
		#printOutJuan(); 
		#edith add 2005/2/23 ������T�]�|���@�̸��, 
		#�Ҧp X75n1508_p0001a02J##[01]���{�p�Ӧ��D�O�@���ϭ�@���k��
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
	#X74n1470_p0146c13j##�j��s����Y�g���L�D���Q�����@�`[�L*��]§�b��
	#X74n1470_p0146c14j=#���Ĥ@	
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
		$juan_tmp .= $lb; # �p�G ������T �w�g�}�l, �N���L�� $buf, ���s�i $juan_temp
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
		###edith modify:2004/12/10 start	�s�歺�� L, �n���� </list>
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
		
		#X78n1554_p0575a13L#1���ĤG
		#<lb ed="X" n="0575a13"/><list><head>���ĤG</head>
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
	###X78n1554_p0575a14L#2�{�٩v
	###<list><item id="itemX78p0575a1401">�{�٩v
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
	#edith modify 2005/6/13 �渹���ЦC�L
	#X59n1107_p0686b24e##���a�٤���C<d><I1>���J���c�j��<I2>�@�D�F<I2>�G���Q�F
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
		$pMarginLeft = ''; # �s�� list �}�l, ���A�~�ӤW�@�� p ���Y�� 2004/11/17 02:59�U��
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
        
	# byline �i��b ����T ����, �ҥH������
	#if ($open{"byline"} > 0 && $tag !~ /[AYECB_]/){
	#edith add 2005/3/9
	#if ($open{"byline"} > 0 && $tag !~ /[AYECB]/){
	if ($open{"byline"} > 0 && $tag !~ /[YECB]/){
		$buf .= "</byline>";
		$open{"byline"} = 0;		
	}
	
	if ($open{"cell"} > 0){	###edith add 2004/12/9
		#edith modify 2005/3/8 row ����檺�ݨD, �[�J�P�_����(�J��歺��f��ܫe�@��cell�n����)
		#X76n1516_p0028c20Ff#<c>����(�Ӥ��G�Q�@)(�E��w�ҧY��)<c>(�T)<c>(�诳)(�Ӫ�E)<c>(��D)(�s����)<c>(��P�_)
		#X76n1516_p0028c21_##(�ñd��)<c>(�Q)(�өl��)</F>
		if ($tag =~ /f/)
		{
			if ($debug2) {print STDERR "\n2006|i_tag=$i_tag\n";}
			$buf .= "</cell>";
			$open{"cell"} = 0;
		}
	}
	
	if ($open{"row"} > 0){	###edith add 2004/12/9
		#edith modify 2005/3/8 row ����檺�ݨD, �[�J�P�_����(�J��歺��f��ܫe�@��row�n����)
		#X76n1516_p0028c20Ff#<c>����(�Ӥ��G�Q�@)(�E��w�ҧY��)<c>(�T)<c>(�诳)(�Ӫ�E)<c>(��D)(�s����)<c>(��P�_)
		#X76n1516_p0028c21_##(�ñd��)<c>(�Q)(�өl��)</F>
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
	#X74n1470_p0139a06J##�j��s����Y�g���L�D���Q����
         #X74n1470_p0139a07J=#�@�`[�L*��]§�b�����Ĥ@
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
	#X74n1470_p0146c13j##�j��s����Y�g���L�D���Q�����@�`[�L*��]§�b��
         #x74n1470_p0146c14j=#���Ĥ@
	if ($open{"jhead"} > 0 and $tag!~/=/ ){
		#$buf .= "</jhead>";
		$juan_tmp .= "</jhead>";  #edith modify 2005/5/20
		$open{"jhead"}=0;
	}
		
	
	#edith modify 2005/3/9, edith modify 2005/5/9 and $tag!~/=/
	#X74n1470_p0146c13j##�j��s����Y�g���L�D���Q�����@�`[�L*��]§�b��
         #x74n1470_p0146c14j=#���Ĥ@
	#if ($open{"juanEnd"} > 0 && $tag !~ /[j]/){		
	if ($open{"juanEnd"} > 0 and $tag!~/=/){
		#printOutJuan();
		$buf .=$juan_tmp;   #edith modify 2005/5/20
		$juan_tmp="";           #edith modify 2005/5/20
		$buf .= "</juan>";	#edith modify 2005/3/9		
		$open{"juanEnd"} = 0;	#edith modify 2005/3/1				
	}

	if ($open{"head"} > 0) {
		# ���D��ťզ�
		# X01n0026_p0417c07Q#1�j��Ѥ��ݦ�M�øg
		# X01n0026_p0417c08Q=1
		# X01n0026_p0417c09Q=1�Z��
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
	# �Ҧp:X78n1552_p0395c09S##�@�@�M���S�@�@�Q�~�׫n�@�@���ɰ��ɡ@�@�O�֦P��
	# �̫�֤@��</l>
	#if ($open{"l"} > 0 )
	# edith modify 2005/5/6 X74n1475_p0394a22_##<T,1> �� 0394a23 "���p�y)" �~����
	#X74n1475_p0394a22_##<T,1>�G��(�@�n�D�äG������)����������(�Y���g�᩼�G�̡C�Y����G[02]�e��C�áf���C
         #x74n1475_p0394a23_##���ấ�פ@���s�~Ĵ�p�j�������p�y)<T,1>�Y�פT��(�@�צhù�øg�]�C�G�s�`
	if ($open{"l"} > 0 and $intag_I eq 1)
	{
		#$notCloseI=1;      #�J��U�@�� <T,1>�|����
	}
	
	# edith modify 2005/5/5 $tag!~/=/ ���O "T=#" �~����<I>
	if ($open{"l"} > 0 and $tag!~/=/ and $notCloseI eq 1)
	{
		#$notCloseI=0;  #�J��U�@�� <T,1>�|����
		#$buf .= "</l>";
	         #$open{"l"}=0;
	}
	
	# added by Ray 2001/1/31 11:18�W��
	if ($open{"lg"} > 0 and $lgType eq "inline" and $tag eq "_") {
			
			$text =~ s#((�@)+)#</l><l>$1#g;
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
		# modified by Ray 2003/9/16 04:16�U��
		# X80n1566_p0443c09L##�Z��
		# X80n1566_p0443c10I##[�@>]�|���X�����@�s�]�s���}�u�߭W���S�����O
		# X80n1566_p0443c11_##�Ѯǻ`��[��>��]�h���s�u�����H�d���ҽѫw����
		# X80n1566_p0443c12_##�N�|�W�߰Ӥ��ѤU
		# X80n1566_p0443c13I##[�@>]�O��ù��h�~�Ӹ����q�ƫh�l�R�դФȦܥ�
		# X80n1566_p0443c14_##�ӥV�u��M���s�|�|��h�G�ä��۫ǥ����q
		#if ($tag!~/I=/) {
		#if ($tag!~/(I=|_)/) {
		#X81n1570_p0329c23IP#[�@>]�O�v�۶��p����s���y�C���I���O�����ѡC��
		#X81n1570_p0330a13P##���C�t���ߡC[��-�y+�G]�Ѯa�k�n�C�ҥj�x���C��ù�W�U�C

		# �J�� k, P, W ������ <item>

		# X78n1546_p0162b08WI#�������T�C�T���ļӦ��ȹL�פH�D�g�G��(�d
		# X78n1546_p0162b09W##����Ķ)</L>
		#if ($tag!~/(I|k|_|P)/ and $text!~/<I/) {
		if ($tag!~/(I|k|_|P|W)/ and $text!~/<I/) {
			$buf .= "</item>";
			$open{"item"}--;
		}
	}
	
	if ($open{"list"}>0) {
		my $t=$tag;
		$t=~s/_//;
		#if ($t eq '' and $itemsInList>0) { # �p�G�J��ťզ�, �n�����Ҧ��� List
		if ($t eq '' and $itemsInList>0 and $text eq '') { # �p�G�J��ťզ�, �n�����Ҧ��� List
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
				$inw=0; # 2004/8/5 10:25�W��
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
	
	$s .= &checkopen("p"); # 2004/6/21 09:20�W��
	
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

	# <lb n="0293b16"/><juan fun="close" n="001"><jhead>�Ů����O�����Ĥ@</jhead></juan>
	# <lb n="0293b17"/></div3>
	# => 
	# <lb n="0293b16"/><juan fun="close" n="001"><jhead>�Ů����O�����Ĥ@</jhead></juan></div3>
	# <lb n="0293b17"/>
	$buf =~ s#((?:\n<(?:lb|pb)[^>]*?/>)+)((?:</div\d+?>)+)#$2$1#sg;
	$buf =~ s#<head></head>##sg; # 2005/9/29 16:16 by Ray
	
	# �� <tt>&SD-CF5F;��(��)</tt> ����
	# <tt place="inline"><t lang="san-sd">&SD-CF5F;</t><t lang="chi">��<note place="inline">��</note></t></tt>
	# 2010/11/25 by heaven
	
	$buf =~ s#<tt>((?:(?:\n<lb [^>]*?/>)?(?:&SD[^;]*?;))*)(.*?)</tt>#<tt place="inline"><t lang="san-sd">$1</t><t lang="chi">$2</t></tt>#sg;
	
	print F $buf;
	close (F);
	$buf = '';
}

# ��r��
sub myLength {
	my $str=shift;
	if ($debug) { print STDERR "myLength $str "; }
	my $n=0;
	if ($str=~/<figure/) {
		$n=1;
	}
	$str =~ s/<rdg[^>]*?>.*?<\/rdg>//g; # �h�� <rdg> ����
	$str =~ s/<[^>]*?>//g; # �h���аO����
	my $pattern = '(?:&.*?;|[\x80-\xff][\x00-\xff]|[\x00-\x7F])';
	my @a=();
	push(@a, $str =~ /$pattern/g);
	foreach $s (@a) {
		# ����r�ƪ��Ÿ�
		#if ($s =~ /^(�C)|(�D)| |(�@)|(�e)|(�f)|(�i)|(�j)|\(|\)$/) {
		if ($s =~ /^(��|�C|�A|�B|�F|�G|�u|�v|�y|�z|�]|�^|�H|�I|�X|�K|�m|�n|�q|�r|�D|��|��|�@|�e|�f|�i|�j|\(|\))$/) {
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
	while ($s =~ /^($big5*?)(��|��|<p[,\-\d]*>)(.*)$/) {
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
	# �ˬd div �����e�N���ӵ������аO
	$buf .= &checkopen("l", "lg", "p", "title", "item", "list");
	
	while ($n <= $open{"div"}) {
		$buf .= "</div" . $open{"div"} . ">";
		$open{"div"}--;
	}
	$inw=0;
	$wq=0;
}

sub corr2app {
	# �t entity, ���t "<"(\x3c), ">"(\x3e) �� big5
	my $big5a = '(?:&[^;]+?;|[\xA1-\xFE][\x40-\x7E\xA1-\xFE]|[\x00-\x3b]|\x3d|[\x3f-\x7f])';
	
	# X85n1591_p0229b11r## [[�x>�w]>>]
	while ($text =~ /^((?:$big5)*)\[\[($big5a*?)>($big5a*?)\]>>\](.*)$/) {
		$text = $1 . "<app><lem wit=\"�iCBETA�j\" resp=\"CBETA.maha\"></lem><rdg wit=\"$wit\">$2</rdg></app>" . $4;
		if ($debug) {
			print STDERR "1838| $text\n";
		}
	}

	# X85n1591_p0229b12r##�@[>>[�x>�w]]
	while ($text =~ /^((?:$big5)*)\[>>\[($big5a*?)>($big5a*?)\]](.*)$/) {
		$text = $1 . "<app><lem wit=\"�iCBETA�j\" resp=\"CBETA.maha\">$3</lem><rdg wit=\"$wit\"></rdg></app>" . $4;
		if ($debug) {
			print STDERR "1848| $text\n";
		}
	}

	#$text =~ s/$corrpat/<corr sic="$1">$2<\/corr>/xg;
	#$text =~ s/$corrpat/<app><lem wit="�iCBETA�j" resp="CBETA.maha">$2<\/lem><rdg wit="$wit">$1<\/rdg><\/app>/xg;
	if ($debug) {
		print STDERR "2200| $text\n";
	}
	# ���� [a>>b]
	while ($text =~ /^((?:$big5)*)\[($big5a*?)>>($big5a*?)\](.*)$/) {
		$text = $1 . "<app type=\"shift\"><lem wit=\"�iCBETA�j\" resp=\"CBETA.maha\">$3</lem><rdg wit=\"$wit\">$2</rdg></app>" . $4;
	}
	# �׭q [a>b]
	while ($text =~ /^((?:$big5)*)\[($big5a*?)>($big5a*?)\](.*)$/) {
		if ($debug3) {
			print STDERR "2603| $text\n";
		}
		my $lem = $3;
		my $rdg = $2;
		
		if($lem eq "") {$lem = "&lac;"};	# 2011/12/04 �S����r�ɭn�� &lac;
		if($rdg eq "") {$rdg = "&lac;"};
		
		$text = $1 . "<app><lem wit=\"�iCBETA�j\" resp=\"CBETA.maha\">$lem</lem><rdg wit=\"$wit\">$rdg</rdg></app>" . $4;
		if ($debug3) {
			print STDERR "2607| $text\n";
			getc;
		}
	}
}

# �B�z�椤²��аO
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
	while ($s =~ m#^((?:$big5)*?)(�@�@|�@|��|<a>|<annals>|</annals>|��|��|<c\d*?(?: r\d+)?>|<d>|<date>|��|<event>|<e(?:,\d+)?>|</e>|</F>|��|<I\d*?>|<J>|<j>|<K[^>]*>|</L\d*?>|<mj>|<n[,\d]*>|</n>|<no_chg>|</no_chg>|<o>|</o>|��|��|<T[,\-\d]*>|</T>|<p=h\d+>|<p[,\-\d]*>|</P>|</?Q\d*[^>]*>|<S>|<u>|</u>|<w>|</w>|��|��|<z[,\-\d]*>)(.*)$#)
	{
		$text .= $1;
		$i_tag = $2;
		$s = $3;
		
		if ($debug2)
		{
			print STDERR "$lb\n";
			print STDERR "2546�B�z�椤²��аO{$1}\n";
			print STDERR "2547�B�z�椤²��аO{$2}\n";	
			print STDERR "2548�B�z�椤²��аO{$3}\n";	
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
			if ($i_tag!~/�@/) {
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
		if ($i_tag eq "�@�@") {
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
		} elsif ($i_tag eq "�@") {
			if ($debug) { print STDERR "2667 i_tag=[�@] juanBegin=" . $open{"juanBegin"} . "\n";}
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
		#edith modify 2005/3/21 �Ҧp X76n1517_p0203c14Q#2���夽�O�ǢѦD���|�ѡ@�s²�@��
		#} elsif ($i_tag =~ /^(��|��|��|��)$/) {
		#edith modify 2005/3/21 �Ҧp X76n1517_p0203c14Q#2���夽�O�ǢѦD���|�ѡ@�s²�@��
		} elsif ($i_tag =~ /^(��|��|��|��|��)$/) {
			#edith modify 2005/2/24
			$buf .= &checkopen("p", "byline", "jhead");
			#$buf .= &checkopen("p", "byline", "jhead", "juanBegin");
			$buf .= '<byline type="';
			#if ($debug2) {print STDERR "2382|i_tag=$i_tag\n";}
			if ($i_tag eq "��") {
				$buf .= "author";
			} elsif ($i_tag eq "��") {
				$buf .= "other";
			} elsif ($i_tag eq "��") {
				$buf .= "Collector";
			} elsif ($i_tag eq "��") {
				$buf .= "editor";
			} elsif ($i_tag eq "��") {
				$buf .= "translator";
			}
			$buf .= '">';
			$open{"byline"}++;
		} elsif ($i_tag eq "<a>") {
		        #edith modify 2005/5/10 </lg></sp>������, �Ҧp:#X74n1467_p0083a12_##<w><p>�ݤ��@�Q��Ҳb�g�@�@����W����
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
			
		#edith hide:2005/3/8 ���q�ק令�W�����{��, �q } elsif ($i_tag =~ /<c(\d*?)>/) { �}�l
		#} elsif ($i_tag eq "<c>") {
		#	$buf .= &checkopen("cell");
		#	$buf .= "<cell>";
		#	$open{"cell"}++;		
		} elsif ($i_tag eq "<d>") 
		{
		    #edith modify 2005/5/10 :"p","def" �Ҧp:X74n1496_p0751b11WQ3 ... ... ...<d>�C<p>(�ǥ���C�P�@�P�C����
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
			#x60n1136_p0807a24_##<d><S>�@�Q�E�O�����W��@�@�����C���T�Q��
			#x60n1136_p0807b01_##�@���k�ץͤ��Q�~�@�@�O�h�@��K�Q��</e>
			#$buf .= &checkopen("p","def","form","entry");   #edith modify 2005/5/10 : "form"
			$buf .= &checkopen("p","l", "lg", "def","form","entry");
		} elsif ($i_tag eq "</F>") {
			$buf .= &checkopen("cell","row","table");
			$startRow=0;
		} elsif ($i_tag eq "��" or $i_tag eq "<I>") {
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
			# 2004/9/23 11:44�W��
			$buf .= "<mulu type=\"��\" n=\"$currentJuan\"/>";
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
			$temp2 =~ s/&([^;]+);/��$1�F/g;
			$buf .= "<mulu type=\"��P\" level=\"$temp1\" label=\"$temp2\"/>";
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
		#�� �椤�� <n,1> �b xml �ন <entry place="inline" rend="margin-left:1">
		#��<n[,\d]*> �@����P�_�h�i����
		} elsif ($i_tag =~ "<n[,\-\d]*>") { # �q�������
			$buf .= &checkopen("p", "def", "form", "entry");
			if (not $in_div_note) {
				$open{"div"}++;
				$buf .= "<div" . $open{"div"} . " type=\"note\">";
				$in_div_note=1;  
			}

			$buf .= "<entry";
			if ($current_pos > 1) {
				$buf .= ' place="inline"';		#<n>�b�椤
			}
			
			###edith modify:2004/12/13 start
			#�� �椤�� <n,1> �b xml �ন <entry place="inline" rend="margin-left:1">
			if ($i_tag=~/<n,(\-?\d+?)>/) 
			{
				$n2_rend = $1;
				if ($n2_rend) 
				{
					$buf .= ' rend="margin-left:' . $n2_rend . 'em"';					
				}
			}
			###hide reason: �קK���Х[ rend="margin-left:1em
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
			$buf .= &checkopen("l", "lg", "p","byline"); #edith modify 2005/6/6 l, lg �n����
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
		#edith modify 2005/5/10 �s�W�G�y�аO <z,1,-1><z,1>
		} elsif ($i_tag =~ /<p[,\-\d]*>/ or $i_tag =~ /<z[,\-\d]*>/) {
			$buf .= &checkopen("byline","l","lg");
			#if ($tag!~/[pP]/ and $open{"p"}>0) {
			if ($open{"p"}>0) {
				# �p�G�歺��T�ؤw��P�аO, ���� �歺�� <p> �N���t�}�s�q��
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
			
			if ($i_tag =~ /<z[,\-\d]*>/) {  #�G�y�аO type
				$buf .= ' type="dharani"';
			}
			
			#if ($debug2) {print STDERR "2836|$current_pos";getc;}
			
			if ($current_pos>1) {
				$buf .= " place=\"inline\"";
			}
			$buf .= "$pMarginLeft>";
			$open{"p"}++;
		} elsif ($i_tag eq "��" or $i_tag eq "��") {
			$buf .= &checkopen("byline","p","l","lg");
			if ($open{"div"} < 1){
				my $type='';
				if ($i_tag  eq "��") {
					$buf .= '<div1 type="dharani">';
				} else {
					$buf .= "<div1>";
				}
				$open{"div"}=1;
			}
			$buf .= "<p id=\"p$id\" ";
			if ($i_tag eq "��") {
				$buf .= 'type="dharani" ';
			}
			$buf .= "place=\"inline\"$pMarginLeft>"; # �~�ӤW�@�� P �� margin-left
			$open{"p"}++;
		#edith modify 2005/4/21 ��<o>, �S��<u></u>...�s�W</o>, XML�̤~�|��������</div>
                    #SM:
                    #x54n0870_p0179b01_##��<o><p>�����i�o�ӥ͡C���i�o�ӷ��]�C</o>
                    #xML:
                    #<lb ed="X" n="0179b01"/><div1 type="orig"><p id="pX54p0179b0101">�����i�o�ӥ͡C���i�o�ӷ��]�C</p></div1>
		} elsif ($i_tag eq "</o>") {
                      $buf .= &checkopen("p", "l", "lg"); 
                      $buf .= "</div" . $open{"div"} . ">";
        	             $open{"div"}--;
                      $div_orig=0;
		} elsif ($i_tag eq "</P>") {
			$buf .= "</p>";
			$open{"p"}--;
		} elsif ($i_tag =~ /��/) {
			if ($open{"p"}>0) {
				$buf .= "</p>";
				$open{"p"}--;
			}
			if ($debug2)
			{
				print STDERR "2852 s{$s}\n";getc;
			}
			$s =~ s#((�@)+)#</l><l>#g;
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
			#edith modify 2005/5/18 <a><p> �̪��U�|�h�F�@�� <l></l>�C�h�[�@�ӰѼ�:g
			#X74n1467_p0083a13_##<a><p>�����@�@�j�ХD�ӡ@�@�Ѹg�@�g��</w>
			$s =~ s#<l></l>##g;
						
			#edith modify 2005/5/10 X74n1467_p0083a13_##<a><p>�����@�@�j�ХD�ӡ@�@�Ѹg�@�g��</w>
			if ($s =~ /.*(<\/.*>)<\/l>$/)   
			{
			    $tmp_tag=$1;
			    $s =~ s#$tmp_tag<\/l>#<\/l>$tmp_tag#g;    #�Ҧp:</w></l>�ܦ� </l></w>
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
		#edith modify 2005/5/6 �B�z�椤 <T,\d>: starting
		#X74n1475_p0394a21_##<T,1>�а_�]�t��[�x>�w]��<T,1>�í������t�p��
                   #<div1 type="jing"><lg id="lgX74p0394a2101" type="abnormal"><l rend="text-indent:1em">�а_�]�t��<app><lem wit="�iCBETA�j" resp="CBETA.maha">�w</lem><rdg wit="�i����j">�x</rdg></app>��</l><l rend="text-indent:1em">�í������t�p��</l>
                   #X74n1475_p0394b07_##�ۻ����͵��T�])</T>
		} elsif ($i_tag =~ /<T,(\-?\d+?)>/) {
                        $pMarginLeft=""; # �����~�� p �Y��
                        # $buf .= &checkopen("head", "byline", "p", "item", "list", "l"); # #�J��U�@�� <T,1>�|���� </l>
                        $buf .= &checkopen("head", "byline", "p", "l"); # 2011/12/05 B06n0005_p0162b18I## , <T> �J�� list �� item ���n����
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
		 #edith modify 2005/5/6 �B�z�椤 <T,\d>: ending  
		 #edith modify 2005/5/6 �B�z�椤 </T>: starting
		 } elsif ($i_tag eq "</T>") {
		    $buf .= &checkopen("l", "lg");
		 #edith modify 2005/5/6 �B�z�椤 </T>: ending   
		} elsif ($i_tag eq "<u>") {
			#$buf .= &checkopen("p", "l", "lg", "byline");
			$buf .= &checkopen("l", "lg", "p","byline"); #edith modify 2005/6/13 �ץ�����
			#edith modify 2005/5/24 �]�� $open{"div"} �X�{�s�����p
			#X56n0932_p0490b23_##<u><p,1>���N�嬰�G���D�ئ��J������C<p,1>����S�G���D
			#<lb ed="X" n="0490b23"/><div0 type="commentary"><div1><p id="pX56p0490b2301" rend="margin-left:1em">���N�嬰�G���D�ئ��J������C</p><p id="pX56p0490b2314" place="inline" rend="margin-left:1em">����S�G���D
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
			if ($open{"div"} > 0) { #edith modify 2005/6/13 �[�ӧP�_
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
			#edith note 2005/5/10 ���G�]���i��, �Ҧp:
			#X74n1467_p0083a13_##<a><p>�����@�@�j�ХD�ӡ@�@�Ѹg�@�g��</w>
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
		#X74n1470_p0146c14j=#���Ĥ@
		#�קK�ܦ�<lb ed="X" n="0146c14"/>���Ĥ@���Ĥ@</jhead></juan>
		#X74n1470_p0139a06J##�j��s����Y�g���L�D���Q����
		#�קK�ܦ�<lb ed="X" n="0139a06"/><juan fun="open" n="1"><mulu type="��" n="1"/><jhead>�j��s����Y�g���L�D���Q����j��s����Y�g���L�D���Q����	 
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
		print STDERR "$line buf�̫�@��G�i$s�j\n";
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

# �Ǧ^���Ѫ���� yyyy/mm/dd
sub today {
	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	$year += 1900;
	return "$year/$mon/$mday";
}

sub rep_note {
	my $s=shift;
	#<K> <Q> �аO�ت��p�A�������N
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
		$label =~ s/&([^;]+);/��$1�F/g; # �ʦr entity �� &...; �令���� �� ....�F
		if ($debug) { print STDERR "2982 $label\n"; }
	}
	if ($level eq '') {
		$level=1;
	}
	# 20080414 by heaven �W�[ "entry", "event", "date", "annals"
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
		$mulu_type = '����';
		$inw=1;
		$wq = $open{"div"}+1;
	} else {
		$divtype = 'other';
		$mulu_type = '��L';
	}
	$head .= "<div" . $level . " type=\"$divtype\">";
	$open{"div"}++;
	if ($att) {
		if ($label ne '') {
			# label �e�ᤣ�[���άA�� 2005/12/1 14:41
			#$head .= "<mulu type=\"$mulu_type\" level=\"$level\" label=\"�]$label�^\"/>";
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

	# added 2004/6/25 11:15�W��
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
