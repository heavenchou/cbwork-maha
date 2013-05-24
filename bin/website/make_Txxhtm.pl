#####################################################
# make_Txxhtm.pl		2001/08/05
#
# 使用方法 perl make_Txxhtm.pl [1 [56]]
#
#  perl make_Txxhtm.pl		處理 1-55, 及 85 冊
#  perl make_Txxhtm.pl 2 5	處理 2-5 冊
#  perl make_Txxhtm.pl 3	處理第 3 冊
#
# Copyright (C) CBETA, 1998-2007
# Copyright (C) Heaven Chou, 2000-2007
#####################################################

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
# 可改的參數
#######################################

my $output_path = "d:/cbeta.www/result/";	#輸出的目錄
my $losefile = "normal.txt";	#通用字檔
my $sourcefile = "taisho.txt";	#經文來源記錄檔
my $updatedate = '2007/02/25';				# 完成日期
#my $ver_date = "ver_date.txt";		# 經文版本記錄 

#######################################
#不要改的參數
#######################################

my %table;		#通用字表
my %table2;		#通用詞表

my $vol;		#格式是 T01
my $vol_num;	#格式是 01
my $key;
my @part;		#經文部別, 傳入的是冊數

my %cbpart;
my %part;
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;
my %author;

local *OUT;

# my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

#############################################################################
#  主程式
#############################################################################

#make_lose_table ($losefile, \%table, \%table2);		#產生通用字表
readGaiji();

get_source();   # 取得經文來源檔
#get_ver_date();	# 取得經文版本與日期
get_part();	# 取得部別

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 85 if $i == 56;
	
	$vol_num = sprintf("%02d",$i);	#冊別, 二位數字
	$vol = "T" . $vol_num;
	
	open OUT , ">${output_path}${vol}.htm" || die "open $vol.htm error $!";

	print_head();	# 寫入檔頭的第一個部份
	foreach $key (sort(keys(%vol)))	# 處理單經
	{
		next if $vol{$key} ne $vol;	# 排除非本冊的
		print_sutra($key);			# 印出各冊特殊記錄		
	}
	print_tail();	# 印出檔尾
	
	close OUT;
}

##########################################################
# 取得部別
##########################################################

sub get_part()
{
	@part=qw(
		阿含部上
		阿含部下
		本緣部上
		本緣部下
		般若部一
		般若部二
		般若部三
		般若部四
		法華部全、華嚴部上
		華嚴部下
		寶積部上
		寶積部下、涅槃部全
		大集部全
		經集部一
		經集部二
		經集部三
		經集部四
		密教部一
		密教部二
		密教部三 
		密教部四
		律部一
		律部二
		律部三
		釋經論部上
		釋經論部下、毘曇部一
		毘曇部二
		毘曇部三
		毘曇部四
		中觀部全、瑜伽部上
		瑜伽部下
		論集部全
		經疏部一
		經疏部二
		經疏部三
		經疏部四
		經疏部五
		經疏部六
		經疏部七
		律疏部全、論疏部一
		論疏部二
		論疏部三
		論疏部四
		論疏部五、諸宗部一
		諸宗部二
		諸宗部三
		諸宗部四
		諸宗部五
		史傳部一
		史傳部二
		史傳部三
		史傳部四
		事彙部上
		事彙部下、外教部全
		目錄部全
	);
	$part[84] = '古逸部全、疑似部全';
	
	#$part = $part[$vol_num-1];
}

##########################################################
# 印出檔頭
##########################################################

sub print_head()
{
	my $cvol = get_cnum($vol_num);

print OUT << "HEAD1";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>CBETA 數位藏經閣 $part[$vol_num-1] $vol</title>
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA 數位藏經閣 大正藏漢文電子佛典 $part[$vol_num-1] $vol">
<meta name="keywords" content="$vol, $part[$vol_num-1], CBETA, 中華電子佛典協會, 數位藏經閣, 大正藏, 卍續藏, 大藏經, 漢文電子佛典, 漢文佛典, 佛典電子化, 電子佛典, 佛典, 佛經, 佛教, 佛法, 佛教經典, 三藏, 經藏, 素怛纜, 律藏, 毗奈耶, 毘奈耶, 毘尼, 毗尼, 論藏, 阿毗達磨, 阿毘達磨, 法寶, 達磨, Tripitaka, Pitaka, Taisho, Xuzangjing, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
<link href="/css/cbeta.css" rel="stylesheet" type="text/css">
<script src="/js/menu.js"></script>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" text="#000000">
<script language="javascript">
  showHeader();
</script>
<!-----------    start of main content  ------------> 

<table width="760" cellspacing="0" cellpadding="2" border="0" align="center">
  <tr>
    <td>
      <p><img src="../img/pubview.gif" width="203" height="25" align="left">
      <p>&nbsp; </p>
      
	  <table align="center" border="0" cellpadding="0" cellspacing="0" width="90%"  bordercolor="#E1E9CB">
	  <tr><td>
      <table align="left" border="1" cellpadding="3" cellspacing="0" bordercolor="#990000" >
      <tr> 
        <td bgcolor="#F9F1DF"><font size="4">第$cvol冊 $part[$vol_num-1]</font></td>
      </tr>
      </table>
      </td></tr></table>
      
      <p>
      <table align="center" border="1" cellpadding="6" cellspacing="0" width="90%"  bordercolor="#E1E9CB">
      <tr> 
        <td align="center" bgcolor="#FAE7A3" nowrap>CBETA經錄<br>大正藏部別</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>經號</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>經名<font color="red">(閱\讀請點入)</font></td>
        <!-- <td align="center" bgcolor="#FAE7A3" nowrap>下載<br>APP版</td> -->
        <!-- <td align="center" bgcolor="#FAE7A3" nowrap>下載<br>PDF版</td> -->
        <td align="center" bgcolor="#FAE7A3" nowrap>更新日期</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>卷數</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>朝代 譯/作者</td>
      </tr>
HEAD1
}

##########################################################
# 印出本冊各經資料
##########################################################

sub print_sutra()
{
	my $key = shift;
	my $sutra_num = substr($key,3);
	$sutra_num =~ s/0*([^_]*)_*/$1/;	#只留下經號

	my $filename_cs = substr($key,3);	# 有大小寫之分
	
	$filename_cs =~ s/_//;
	my $filename = $vol . "n" . lc($filename_cs);
	$filename_cs = $vol . "n" . $filename_cs;

print OUT << "SUTRA";   
    <tr>
        <td>$cbpart{$key}<br>$part{$key}</td>
        <td>$sutra_num</td>
        <td><a href="${vol}/${filename}.htm">$sutra_name{$key}</a></td>
        <!-- <td align="center" valign="middle"><font face="Wingdings" size="+2"><a href="../download/app1/${vol}/${filename}.zip">&#60;</a></font></td> -->
        <!-- <td align="center" valign="middle"><font face="Wingdings" size="+2"><a href="http://cbeta.twbbs.org/download/pdf/${vol}/${filename_cs}.pdf">&#60;</a></font></td> -->
        <td>$updatedate</td>
        <td align="right">$juan{$key}</td>
        <td>$author{$key}</td>
    </tr>
SUTRA
}

##########################################################
# 印出檔尾
##########################################################

sub print_tail()
{
print OUT << "TAIL";   
       </table>
<!------------  內容結束   ----------->
    </td>
  </tr>
</table>
<!-----------    頁尾  ------------>
<script language="javascript">
  ShowTail();
</script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
myURL = window.location.href;
if(myURL.match(/www.cbeta.org/i))
_uacct = "UA-541905-1";
else if(myURL.match(/w3.cbeta.org/i))
_uacct = "UA-541905-3";
else if(myURL.match(/cbeta.buddhist\-canon.com/i))
_uacct = "UA-541905-4";
else if(myURL.match(/cbeta.kswer.com/i))
_uacct = "UA-541905-5";
urchinTracker();
</script>
</body>
</html>
TAIL
}

##########################################################
# 取得經文來源檔資料
##########################################################

sub get_source()
{
	local *SOURCE;
	local $_;
	
        open SOURCE , "$sourcefile" || die "open $sourcefile error : $!";
        while(<SOURCE>)
        {
        	next if/^#/;

		# 阿含部類  阿含部上  T0002-01-p0150 K1182-34  1  七佛經(1卷)   【宋 法天譯】
		
		/^\s*(\S*)\s*(\S*)\s*T(.{5})(\d\d).*?\s+.*?\s+(\d*)\s+(.*?)\s+(【.*】)/;

		my $cbpart = $1;
		my $part = $2;
        my $sutra_num = $3;
        my $sutra_vol = $4;
        my $juan = $5;
        my $sutra_name = $6;
        my $author = $7;

		if ($sutra_name =~ /\)$/)
		{
			$sutra_name = cut_note($sutra_name);	#去除尾部的括號
		}
		
		$sutra_num =~ s/\-/_/;
		my $key = "T$sutra_vol" . $sutra_num;	# 因為 567 三冊會相同, 所以要加上 vol

		$cbpart{$key} = $cbpart;
		$part{$key} = $part;
		$vol{$key} = "T$sutra_vol";
		$sutra_name{$key} = lose2normal ($sutra_name, \%table, \%table2);
		$juan{$key} = $juan;
		$author{$key} = lose2normal ($author, \%table, \%table2);

        }
        close SOURCE;
}

#############################################################
# 取得中文數字
#############################################################

sub get_cnum()		
{
	local $_ = $_[0];
	s/^0*//;

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
	local $_ = shift;
	
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
	local $_ = shift;	    # 傳入要換的行
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