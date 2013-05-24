#######################################################################
# maketoc.pl				2001/08/05
#
# 使用方法 perl maketoc.pl [1 [56]]
#
#  perl maketoc.pl	處理 1-55, 及 85 冊
#  perl maketoc.pl 2 5	處理 2-5 冊
#  perl maketoc.pl 3	處理第 3 冊
#
# Copyright (C) CBETA, 1998-2007
# Copyright (C) Heaven Chou, 1999-2007
#######################################################################

use strict;
use Win32::ODBC;

#######################################
# 傳入的參數
#######################################

my $from_vol = shift;
my $to_vol = shift;

if($from_vol eq "" and $to_vol eq "")
{
	$from_vol = 1;
	$to_vol = 85;
}
elsif ($from_vol ne "" and $to_vol eq "")	# 只有第一個參數
{
	$from_vol =~ s/^T//i;
	$to_vol = $from_vol;
}
else
{
	$from_vol =~ s/^T//i;
	$to_vol =~ s/^T//i;
}

#######################################
#可修改參數
#######################################

#my $ver_date = "ver_date.txt";		# 版本與日期的記錄檔
my $outpath = "d:/cbeta.www/result/";	# 輸出的目錄
my $updatedate = '2007/02/25';				# 完成日期
my $sourcepath = "c:/cbwork/simple";	# source.txt 的目錄

#######################################
#不要改的參數
#######################################

my %table;		#通用字表
my %table2;		#通用詞表

my $vol;		#格式是 T01
my $vol_num;	#格式是 01
my $key;

my %source_sign_e;	#放英文名詞, 例 $source_sing_e{"S"} = "Text as provided by Mister Hsiao Chen-kuo"
my %source_sign_c;	#放中文名詞, 例 $source_sing_c{"S"} = "蕭鎮國大德"
my %source;		    #放各經名及來源, 例 $source{"0310_"} = "SKB";
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;

local *OUT;

########################################################################
#  主程式
########################################################################

#make_lose_table ($losefile, \%table, \%table2);		#產生通用字表
readGaiji();
#get_ver_date();	# 取得經文版本與日期

mkdir ("$outpath") if (not -d "$outpath");

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 85 if $i == 56;
	
	$vol_num = sprintf("%02d",$i);	#冊別, 二位數字
	$vol = "T" . $vol_num;
	print "$vol...";
	
	my $sourcefile = "$sourcepath/$vol/source.txt";     #經文來源記錄檔
	%vol = ();				# 先歸零
	get_source($sourcefile);   		# 取得本冊經文來源檔

	foreach $key (sort keys(%vol))		# 之前有歸零了
	{
		my $sutra_num = $key;
		$sutra_num =~ s/0*([^_]*)_*/$1/;	# 純數字部份
	
		mkdir ("${outpath}$vol","0777") if (not -d "${outpath}$vol");
	
		# 取得檔名
		
		my $filename = lc($key);
	
		$filename =~ s/_//;
		$filename = $vol . "n" . $filename . ".htm";
	
		open OUT, ">${outpath}${vol}/$filename" || die "open $filename error. $!";
		print_head($key);
		close OUT;
	}
	print "ok\n";
}
exit;

##########################################################
# 本經第一檔, 印資料多的卷首資訊
# 傳入參數 1 表示印長的卷首資訊, 2 表示印短的卷首資訊
##########################################################

sub print_head()
{

my $key = shift;
my $vol_c = get_cnum($vol_num);	#取得冊數中文數字
my $sutra_num;

$key =~ /0*([^_]*)/;	#取經號
$sutra_num = $1;

my $from = $source{$key};
my $sutra_name = $sutra_name{$key};
my $fromkey="";
my $from_c="";
my $from_e="";

while(length ($from) >0)		# 取得中英文的經文來源資料
{
	$fromkey = substr $from, 0, 1;
	$from = substr $from, 1;
	$from_c .= "$source_sign_c{$fromkey}，";
	$from_e .= "$source_sign_e{$fromkey}, ";
}

substr ($from_c, -2 , 2) = "";
substr ($from_e, -2 , 2) = "";

#測試版, 所以底下的先移出來
#<li>【版本記錄】CBETA 電子佛典 $ver (Big5) 線上版，完成日期：$date
#<li> CBETA Chinese Electronic Tripitaka $ver (Big5) Online Version, Release Date: $date

print OUT << "HTML";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>CBETA $vol No. $sutra_num 《$sutra_name》</title>
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA 大正藏漢文電子佛典 $vol No. $sutra_num 《$sutra_name》">
<meta name="keywords" content="$vol, 《$sutra_name》, CBETA, 中華電子佛典協會, 數位藏經閣, 大正藏, 卍續藏, 大藏經, 漢文電子佛典, 漢文佛典, 佛典電子化, 電子佛典, 佛典, 佛經, 佛教, 佛法, 佛教經典, 三藏, 經藏, 素怛纜, 律藏, 毗奈耶, 毘奈耶, 毘尼, 毗尼, 論藏, 阿毗達磨, 阿毘達磨, 法寶, 達磨, Tripitaka, Pitaka, Taisho, Xuzangjing, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
<link href="/css/cbeta.css" rel="stylesheet" type="text/css">
<script src="/js/menu.js"></script>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<script language="javascript">
  showHeader();
</script>
<table width="760" align="center"><tr><td>
<img src="/img/pubview.gif" align="center">
<p>
<ul>
<li>【經文資訊】大正新脩大藏經第$vol_c冊 No. $sutra_num《$sutra_name》
<li>【版本記錄】CBETA 電子佛典 Big5 App 版，最近更新日期：$updatedate
<li>【編輯說明】本資料庫由中華電子佛典協會（CBETA）依大正新脩大藏經所編輯
<li>【原始資料】$from_c
<li>【其他事項】本資料庫可自由免費流通，詳細內容請參閱\【<a href="/copyright.htm" target="_blank">中華電子佛典協會資料庫版權宣告</a>】
</ul>
<ul>
<li> Taisho Tripitaka Vol. $vol, No. $sutra_num $sutra_name
<li> CBETA Chinese Electronic Tripitaka Big5 App Version, Release Date:$updatedate
<li> Distributor: Chinese Buddhist Electronic Text Association (CBETA)
<li> Source material obtained from: $from_e
<li> Distributed free of charge. For details please read at <a href="/copyright_e.htm" target="_blank">The Copyright of CBETA DATABASE</a>
</ul>

<hr>
<center><h3>目錄  Contents</h3>
<table border="1" cellpadding="4" cellspacing="0" bordercolor="#9BB4C6">
<tr bgcolor="#FAE7A3">
        <td align="center" valign="top"><font color="#990000"><strong>普及版 (分卷)<br>
        </strong><font face="Times New Roman"><strong>Normalized Format Ver.</strong></font></font></td>
</tr>
HTML

#分卷印了

for(my $i=1; $i<=$juan{$key}; $i++)
{
	my $j = $i;
	
	#處理特殊的卷
	
	if($vol eq "T06") { $j = $i + 200;}
	if($vol eq "T07") { $j = $i + 400;}
    #if(($vol eq "T19") and ($key eq "0946_") and ($i > 2))
	#{
	#	$j = $i+1;
    #}
	
	my $fulljuan = sprintf("$key%03d", $j);
	
	if($vol eq "T19"){
		# T19, 0946 缺第 3 卷
		if ($fulljuan eq "0946_004"){$fulljuan = "0946_005"; $j=5;}	
		if ($fulljuan eq "0946_003"){$fulljuan = "0946_004"; $j=4;}
	}	
	if($vol eq "T54"){
		if ($fulljuan eq "2139_002"){$fulljuan = "2139_010"; $j=10;}	
	}
	if($vol eq "T85"){
		if ($fulljuan eq "2742_001"){$fulljuan = "2742_002";}
		if ($fulljuan eq "2744_001"){$fulljuan = "2744_002";}
		if ($fulljuan eq "2748_001"){$fulljuan = "2748_003";}
		if ($fulljuan eq "2754_001"){$fulljuan = "2754_003";}
		if ($fulljuan eq "2757_001"){$fulljuan = "2757_003";}
		if ($fulljuan eq "2764B001"){$fulljuan = "2764B004";}
		if ($fulljuan eq "2769_001"){$fulljuan = "2769_004";}
		if ($fulljuan eq "2772_001"){$fulljuan = "2772_003";}
		if ($fulljuan eq "2772_002"){$fulljuan = "2772_006";}
		if ($fulljuan eq "2799_002"){$fulljuan = "2799_003";}
		if ($fulljuan eq "2803_001"){$fulljuan = "2803_004";}
		if ($fulljuan eq "2805_001"){$fulljuan = "2805_005";}
		if ($fulljuan eq "2805_002"){$fulljuan = "2805_007";}
		if ($fulljuan eq "2809_001"){$fulljuan = "2809_004";}
		if ($fulljuan eq "2814_003"){$fulljuan = "2814_005";}
		if ($fulljuan eq "2814_002"){$fulljuan = "2814_004";}
		if ($fulljuan eq "2814_001"){$fulljuan = "2814_003";}
		if ($fulljuan eq "2820_001"){$fulljuan = "2820_012";}
		if ($fulljuan eq "2825_002"){$fulljuan = "2825_003";}
		if ($fulljuan eq "2827_002"){$fulljuan = "2827_003";}
		if ($fulljuan eq "2827_001"){$fulljuan = "2827_002";}
		if ($fulljuan eq "2880_003"){$fulljuan = "2880_004";}
		if ($fulljuan eq "2880_002"){$fulljuan = "2880_003";}
		if ($fulljuan eq "2880_001"){$fulljuan = "2880_002";}
		$fulljuan =~ /.{5}0*(\d*)/;
		$j = $1;
	}

	$fulljuan = lc($fulljuan);

print OUT << "HTML1"
<tr><td><a href="../normal/$vol/$fulljuan.htm">$j $sutra_name{$key}</a></td></tr>
HTML1

}
print OUT "</table></center></td></tr></table>\n";
print OUT "<script language=\"javascript\">\n";
print OUT "  ShowTail();\n";
print OUT "</script>\n";
print OUT '<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">' . "\n";
print OUT '</script>' . "\n";
print OUT '<script type="text/javascript">' . "\n";
print OUT 'myURL = window.location.href;' . "\n";
print OUT 'if(myURL.match(/www.cbeta.org/i))' . "\n";
print OUT '_uacct = "UA-541905-1";' . "\n";
print OUT 'else if(myURL.match(/w3.cbeta.org/i))' . "\n";
print OUT '_uacct = "UA-541905-3";' . "\n";
print OUT 'else if(myURL.match(/cbeta.buddhist\-canon.com/i))' . "\n";
print OUT '_uacct = "UA-541905-4";' . "\n";
print OUT 'else if(myURL.match(/cbeta.kswer.com/i))' . "\n";
print OUT '_uacct = "UA-541905-5";' . "\n";
print OUT 'urchinTracker();' . "\n";
print OUT '</script>' . "\n";
print OUT "</body>\n";
print OUT "</html>\n";
}

##########################################################
# 取得經文來源檔資料
##########################################################

sub get_source()
{
	local *SOURCE;
	my $sourcefile = shift;
	
        # %source_sign_e	放英文名詞, 例 $source_sing_e{"S"} = "Text as provided by Mister Hsiao Chen-kuo"
        # %source_sign_c	放中文名詞, 例 $source_sing_c{"S"} = "蕭鎮國大德"
        # %source		放各經名及來源, 例 $source{"0310_"} = "SKB";
        # %sutra_name		放經名, 例 $sutra_name{"0310_"} = "大寶積經";
        # %vol			放各經的冊別, 例 $vol{"0310_"} = 11 (第 11 冊)
        # %sutra_juan		放各經的卷數, 例 $sutra_juan{"0310_"} = 120 (120 卷)

        open SOURCE , "$sourcefile" || die "open $sourcefile error : $!";
        while(<SOURCE>)
        {
                #找到來源記錄, 格式如下
                #S:蕭鎮國大德, Text as provided by Mister Hsiao Chen-kuo

                if (/(.)\s*:\s*(.*?)\s*,\s*(.*?)\s*$/)
                {
                        $source_sign_c{"$1"} = "$2";
                        $source_sign_e{"$1"} = "$3";
                }
                #找到經名及來源, 格式如下
                #SK4    T0310-11-p0001 K0022-06 120 大寶積經(120卷)【唐 菩提流志譯并合】
                #elsif (/^(.*?)\s+T(.{5})(\d\d).*?\s+.*?\s+(\d*)\s+(.*?)(?:(?:\()|(?:【))/)
                #APJ    T0220-05-p0001  V1.0   1999/12/10  200  大般若波羅蜜多經    【唐 玄奘譯】                  K0001-01
		elsif (/^(.*?)\sT(.{5})(\d\d).*?\s+.*?\s+.*?\s+(.*?)\s+(.*?)\s+()/)
		{
                        my $from = $1;
                        my $sutra_num = $2;
                        my $sutra_vol = $3;
                        #my $sut_ver = $4;	# 這裡的日期與版本不準了
                        #my $sut_date = $5;
                        my $juan = $4;
                        my $sutra_name = $5;
                        
			$from =~ s/ //g;
			if ($sutra_name =~ /\)$/)
			{
				$sutra_name = cut_note($sutra_name);	#去除尾部的括號
			}
			
			$sutra_num =~ s/\-/_/;		# 做成標準五位數的格式

                        $source{$sutra_num} = $from;
                        $vol{$sutra_num} = "T$sutra_vol";
                        $juan{$sutra_num} = $juan;
			$sutra_name{$sutra_num} = lose2normal ($sutra_name, \%table, \%table2);           
                }
        }
        close SOURCE;
}

#############################################################
# 取得中文數字
#############################################################

sub get_cnum()		
{
	local $_ = $_[0];

	s/^0*(\d*)/$1/;
	s/10/十/;		# 10 換成 十
	s/^1(.)/十$1/g;		# 1x 換成 十x
	s/^(\d)(\d)/$1十$2/;	# xx 換成 x十x	
	s/1/一/g;
	s/2/二/g;
	s/3/三/g;
	s/4/四/g;
	s/5/五/g;
	s/6/六/g;
	s/7/七/g;
	s/8/八/g;
	s/9/九/g;
	s/0//g;
	return ($_);
}

#############################################################
# 去除字串尾部的括號
# 例 xxxx(yy) -> xxxx
# 小心 xxxx(yy[(zz)]) -> xxxx
#############################################################

sub cut_note()
{
	local $_ = $_[0];
	
	while (/\)$/)
	{
		while(not /\([^\)]*?\)$/)
		{
			s/\(([^\(]*?)\)/#1#$1#2#/g;
		}
	
		if (/\([^\)]*\)$/)
		{
			s/\([^\(]*\)$//;
		
		}
	
		s/#1#/\(/g;
		s/#2#/\)/g;
	}
	return $_;
}

##########################################################
# 取得經文版本與日期
##########################################################


##############################################################################
# 產生通用字表
##############################################################################

sub readGaiji {
	my $cb;
	my $des;
	my $ent;
	my $mojikyo;
	my $nor;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM cb_des_nor")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		my %row;
		undef %row;
		%row = $db->DataHash();
		
		$cb      = $row{"cb"};		# cbeta code
		$des     = $row{"des"};		# 組字式
		$nor     = $row{"nor"};		# 通用字

		if($cb =~ /^x/)		# 通用詞
		{
			$table2{$des} = $nor;
			next;
		}

		next if ($cb !~ /^\d/);
		next if ($nor eq "");

		$table{$des} = $nor;
	}
	$db->Close();
	print STDERR "ok\n";
}
##############################################################################
# 將某行變成通用字
# 使用法:
#     lose2normal (資料, hash 通用字表的指標, hash 通用詞表的指標)
# 例: lose2normal ($line, \%table, \%table2)
##############################################################################

sub lose2normal
{
	local $_ = shift;	# 傳入要換的行
	my $losetable = shift;	# 傳入通用字表
	my $losetable2 = shift;	# 傳入通用詞表
	
	my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x00-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])';

	# 先判斷有沒有組字式
	return $_ if ($_ !~ /\[/);

	# 換通用詞
	s=\Q髣髣[髟/弗][髟/弗]\E=彷彷彿彿=g;		# 髣髣[髟/弗][髟/弗]要先換
	foreach my $loseword2 (keys(%$losetable2))
	{
		s/\Q$loseword2\E/$losetable2->{$loseword2}/g;
	}
	
	# 換通用字
	
	s/(\[$losebig5*?\])/($losetable->{$1}||$1)/ge;
	
	return $_;
}

###  END  ####################################################