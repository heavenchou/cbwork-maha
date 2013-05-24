#######################################################################
# makeXtoc.pl				2004/07/31
#
# 使用方法 perl maketoc.pl [78 [87]]
#
#  perl makeXtoc.pl	處理 63-73 冊
#  perl makeXtoc.pl 78 81 處理 78-81 冊
#  perl makeXtoc.pl 78 處理第 78 冊
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
	$to_vol = 88;
}
elsif ($from_vol ne "" and $to_vol eq "")	# 只有第一個參數
{
	$from_vol =~ s/^X//i;
	$to_vol = $from_vol;
}
else
{
	$from_vol =~ s/^X//i;
	$to_vol =~ s/^X//i;
}

#######################################
#可修改參數
#######################################

#my $ver_date = "ver_date.txt";		# 版本與日期的記錄檔
my $outpath = "d:/cbeta.www/result/";	# 輸出的目錄
my $updatedate = '2007/02/25';			# 完成日期
my $sourcepath = "c:/cbwork/simple";	# source.txt 的目錄

##### 注意 : 若有特殊卷或不連續卷，要在底下處理。

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
my %source;			#放各經名及來源, 例 $source{"0310_"} = "SKB";
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;

local *OUT;

########################################################################
#  主程式
########################################################################

readGaiji();		#產生通用字表
#make_lose_table ($losefile, \%table, \%table2);		#產生通用字表
#get_ver_date();	# 取得經文版本與日期

mkdir ("$outpath") if (not -d "$outpath");

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 7 if $i == 6;
	$i = 53 if $i == 52;
	
	$vol_num = sprintf("%02d",$i);	#冊別, 二位數字
	$vol = "X" . $vol_num;
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
<meta name="description" content="CBETA 卍續藏漢文電子佛典 $vol No. $sutra_num 《$sutra_name》">
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
<li>【經文資訊】卍新纂續藏經 第$vol_c冊 No. $sutra_num《$sutra_name》
<li>【版本記錄】CBETA 電子佛典 Big5 App 版，最近更新日期：$updatedate
<li>【編輯說明】本資料庫由中華電子佛典協會（CBETA）依卍新纂續藏經所編輯
<li>【原始資料】$from_c
<li>【其他事項】本資料庫可自由免費流通，詳細內容請參閱\【<a href="/copyright.htm" target="_blank">中華電子佛典協會版權宣告</a>】
</ul>
<ul>
<li> 卍 Xuzangjing Vol. $vol, No. $sutra_num $sutra_name
<li> CBETA Chinese Electronic Tripitaka Big5 App Version, Release Date:$updatedate
<li> Distributor: Chinese Buddhist Electronic Text Association (CBETA)
<li> Source material obtained from: $from_e
<li> Distributed free of charge. For details please read at <a href="/copyright_e.htm" target="_blank">The Copyright of CBETA</a>
</ul>

<hr>
<center><h3>目錄  Contents</h3>
<table border="1" cellpadding="4" cellspacing="0" bordercolor="#9BB4C6">
<tr bgcolor="#FAE7A3">
        <td align="center" valign="top"><font color="#990000"><strong>App 版 (分卷)<br>
        </strong><font face="Times New Roman"><strong>App Format Ver.</strong></font></font></td>
</tr>
HTML

#分卷印了

for(my $i=1; $i<=$juan{$key}; $i++)
{
	my $j = $i;
	
	#處理特殊的卷
	if(($vol eq "X03") and ($key eq "0208_") and ($i==1)) 
	{
		# 只有卷10
		$j = 10;
	}
	if(($vol eq "X03") and ($key eq "0211_") and ($i==1)) 
	{
		# 只有卷6
		$j = 6;
	}
	if(($vol eq "X03") and ($key eq "0221_") and ($i>5)) 
	{
		# X03n0221.xml 由卷 8~15, 不是 6~13 (沒有 6,7)
		$j = $i+2;
	}
	if(($vol eq "X07") and ($key eq "0234_")) 
	{
		#X07n0234 華嚴經疏注,(百二十卷但欠卷21~70、91~100及111~112)
		#01~20,71~90,101~110,113~120 (實際卷數)
		#01~20,21~40, 41~ 50, 51~ 58 (流水卷數)
		$j = $i+50 if($i>20);
		$j = $i+60 if($i>40);
		$j = $i+62 if($i>50);
	}
	if(($vol eq "X08") and ($key eq "0235_")) 
	{
		#X08n0235 華嚴經談玄抉擇,(六卷但初卷不傳),
		$j = $i+1;
	}
	if(($vol eq "X09") and ($key eq "0240_"))
	{
		#X09n0240 由卷 45 開始
		$j = $i+44;
	}
	if(($vol eq "X09") and ($key eq "0244_"))
	{
		#X09n0244 由卷 2,3 , 不是 1,2 (沒有 1)
		$j = $i+1;
	}
	if(($vol eq "X17") and ($key eq "0321_"))
	{
		# X17n0321.xml 由卷 1,2,5 不是 1~3 (沒有 3,4)
		$j = 5 if($i == 3);
	}
	if(($vol eq "X19") and ($key eq "0345_"))
	{
		# X19n0345.xml 由卷 4,5 不是 1~2 (沒有 1~3)
		$j = $i+3;
	}
	if(($vol eq "X21") and ($key eq "0367_"))
	{
		# X21n0367.xml 由卷 4~8 不是 1~5 (沒有 1~3)
		$j = $i+3;
	}
	if(($vol eq "X21") and ($key eq "0368_"))
	{
		# X21n0368.xml 由卷 2~4 不是 1~3 (沒有 1)
		$j = $i+1;
	}
	if(($vol eq "X24") and ($key eq "0451_"))
	{
		# X24n0451.xml 由卷 1,3~10, 不是 1~9 (沒有 2)
		$j = $i + 1 if($i > 1);
	}
	if(($vol eq "X26") and ($key eq "0560_"))
	{
		# X26n0560.xml 由卷 2 不是 1 (沒有 1)
		$j = $i+1;
	}
	if(($vol eq "X34") and ($key eq "0638_"))
	{
		# X34n0638.xml 由卷 1~21,24~29,31,33~35 , 不是 1~31 (沒有 22,23,30.32)
		$j = $i + 2 if($i > 21);
		$j = $i + 3 if($i > 27);
		$j = $i + 4 if($i > 29);
	}
	if(($vol eq "X37") and ($key eq "0662_"))
	{
		# X37n0662.xml 由卷 1~14,16~20, 不是 1~19 (沒有 15)
		$j = $i+1 if($i > 14);
	}
	if(($vol eq "X38") and ($key eq "0687_"))
	{
		# X38n0687.xml 由卷 2,4 , 不是 1,2 (沒有 1,3)
		$j = 2 if($i == 1);
		$j = 4 if($i == 2);
	}
	if(($vol eq "X39") and ($key eq "0704_"))
	{
		# X39n0704.xml 由卷 3~5, 不是 1~3 (沒有 1,2)
		$j = $i+2;
	}
	if(($vol eq "X39") and ($key eq "0705_"))
	{
		# X39n0705.xml 由卷 2 不是 1 (沒有 1)
		$j = $i+1;
	}
	if(($vol eq "X39") and ($key eq "0712_"))
	{
		# X39n0712.xml 由卷 3 不是 1 (沒有 1,2)
		$j = $i+2;
	}
	if(($vol eq "X40") and ($key eq "0714_"))
	{
		# X40n0714.xml 由卷 3,4 不是 1,2 (沒有 1,2)
		$j = $i+2;
	}
	if(($vol eq "X42") and ($key eq "0733_"))
	{
		# X42n0733.xml 由卷 2~8,10 不是 1~8 (沒有 1,9)
		$j = $i+1;
		$j = 10 if($i == 8);
	}
	if(($vol eq "X42") and ($key eq "0734_"))
	{
		# X42n0734.xml 由卷 9 不是 1 (沒有 1~8)
		$j = 9;
	}
	if(($vol eq "X46") and ($key eq "0784_"))
	{
		# X46n0784.xml 由卷 2,5~10 不是 1~7 (沒有 1,3,4)
		$j = 2 if($i == 1);
		$j = $i + 3 if($i > 1);
	}
	if(($vol eq "X46") and ($key eq "0791_"))
	{
		# X46n0791.xml 由卷 1,6,14,15,17,21,24 不是 1~7 (沒有 ...)
		$j = 6 if($i == 2);
		$j = 14 if($i == 3);
		$j = 15 if($i == 4);
		$j = 17 if($i == 5);
		$j = 21 if($i == 6);
		$j = 24 if($i == 7);
	}
	if(($vol eq "X48") and ($key eq "0797_"))
	{
		# X48n0797.xml 由卷 3 不是 1 (沒有 1,2)
		$j = 3;
	}
	if(($vol eq "X48") and ($key eq "0799_"))
	{
		# X48n0799.xml 由卷 1,2,7 不是 1~3 (沒有 3~6)
		$j = 7 if($i == 3);
	}
	if(($vol eq "X48") and ($key eq "0808_"))
	{
		# X48n0808.xml 由卷 1,5,9,10 不是 1~4 (沒有 2,3,4,6,7,8)
		$j = 5 if($i == 2);
		$j = 9 if($i == 3);
		$j = 10 if($i == 4);
	}
	if(($vol eq "X49") and ($key eq "0812_"))
	{
		# X49n0812.xml 由卷 2 不是 1 (沒有 1)
		$j = 2;
	}
	if(($vol eq "X49") and ($key eq "0815_"))
	{
		# X49n0815.xml 由卷 1~8,10~13 不是 1~12 (沒有 9)
		$j = $i + 1 if($i > 8);
	}
	if(($vol eq "X50") and ($key eq "0817_"))
	{
		# X50n0817.xml 由卷 17 不是 1 (沒有 1~16)
		$j = 17;
	}
	if(($vol eq "X50") and ($key eq "0819_"))
	{
		# X50n0819.xml 由卷 1~14,16,18 不是 1~16 (沒有 15,17)
		$j = 16 if($i == 15);
		$j = 18 if($i == 16);
	}
	if(($vol eq "X51") and ($key eq "0822_"))
	{
		# X51n0822.xml 由卷 4~10 不是 1~7 (沒有 1~3)
		$j = $i+3;
	}
	if(($vol eq "X53") and ($key eq "0836_"))
	{
		# X53n0836.xml 由卷 1,2,4~7,17 不是 1~7 (沒有 3,8~16)
		$j = $i+1 if($i > 3);
		$j = 17 if($i == 7);
	}
	if(($vol eq "X53") and ($key eq "0842_"))
	{
		# X53n0842.xml 由卷 29,30 不是 1,2 (沒有 1~28)
		$j = 29 if($i == 1);
		$j = 30 if($i == 2);
	}
	if(($vol eq "X53") and ($key eq "0843_"))
	{
		# X53n0843.xml 由卷 9,18 不是 1,2 (沒有 1~8,10~17)
		$j = 9 if($i == 1);
		$j = 18 if($i == 2);
	}
	if($vol eq "X55" and $key eq "0882_")
	{
		# 只有卷 4,7,10
		$j = 4 if ($i == 1);
		$j = 7 if ($i == 2);
		$j = 8 if ($i == 3);
	}
	if($vol eq "X57" and $key eq "0952_")
	{
		# 只有卷 10
		$j = 10 if ($i == 1);
	}
	if($vol eq "X57" and $key eq "0966_")
	{
		# 只有卷 2,3,4,5
		$j = $i+1;
	}
	if($vol eq "X57" and $key eq "0967_")
	{
		# 只有卷 3,4
		$j = $i+2;
	}
	if($vol eq "X58" and $key eq "1015_")
	{
		# 只有卷 14,22
		$j = 14 if ($i == 1);
		$j = 22 if ($i == 2);
	}
	if($vol eq "X72" and $key eq "1435_" and $i>13)
	{
		# X72n1435.xml 由卷1~13,16~35 , 不是 1~13,14~33 (13,14,15 合成 13一卷)
		$j = $i+2;
	}
	if($vol eq "X73" and $key eq "1456_" and $i>40)
	{
		# X73n1456.xml 由卷44~55, 不是 41~52 (沒有 41,42,43)
		$j = $i+3;
	}
	if(($vol eq "X81") and ($key eq "1568_"))
	{
		$j = $i+9;
	}
	if(($vol eq "X82") and ($key eq "1571_"))
	{
		$j = $i+33;
	}
	if(($vol eq "X85") and ($key eq "1587_"))
	{
		$j = $i+1;
	}

	my $fulljuan = sprintf("$key%03d", $j);

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
		elsif (/^(.*?)\sX(.{5})(\d\d).*?\s+.*?\s+.*?\s+(.*?)\s+(.*?)\s+()/)
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