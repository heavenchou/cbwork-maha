#####################################################
# make_Xnnhtm.pl		2004/07/31
#
# 使用方法 perl make_Xnnhtm.pl [78 [87]]
#
#  perl make_Xnnhtm.pl		處理 1-88 冊
#  perl make_Xnnhtm.pl 2 5	處理 2-5 冊
#  perl make_Xnnhtm.pl 3	處理第 3 冊
#
# Copyright (C) CBETA, 1998-2007
# Copyright (C) Heaven Chou, 2000-2007
#
# 2006/02/16 把卍續中大正藏重覆的經文, 也一併加到目錄中
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
# 可改的參數
#######################################

# 請注意這個檔有沒有更新 "d:/cbeta.src/budalist/xuzang.txt";

my $output_path = "d:/cbeta.www/result/";	# 輸出的目錄
my $sourcefile = "xuzang.txt";	# 經文來源記錄檔
my $updatedate = '2007/02/25';				# 完成日期
#my $losefile = "normal.txt";				# 通用字檔
#my $ver_date = "ver_date.txt";				# 經文版本記錄 

# 注意, 底下還有部類列表要加

#######################################
#不要改的參數
#######################################

my %table;		#通用字表
my %table2;		#通用詞表

my $vol;		#格式是 X78
my $vol_num;	#格式是 78
my $key;
my @part;		#經文部別, 傳入的是冊數

my %cbpart;
my %part;
my $part;
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;
my %author;
my %taisho_vol;		# 大正藏的冊
my %taisho_sutra;	# 大正藏的經號

local *OUT;

# my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

#############################################################################
#  主程式
#############################################################################

#make_lose_table ($losefile, \%table, \%table2);		#產生通用字表
readGaiji ();		#產生通用字表

get_source();   # 取得經文來源檔
#get_ver_date();	# 取得經文版本與日期
get_part();	# 取得部別

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 7 if $i == 6;
	$i = 53 if $i == 52;
	
	$vol_num = sprintf("%02d",$i);	#冊別, 二位數字
	$vol = "X" . $vol_num;
	$part = $part[$vol_num-1];
	
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
	$part[0] = '印度撰述一';
	$part[1] = '印度撰述二';
	$part[2] = '大小乘釋經部一';
	$part[3] = '大小乘釋經部二';
	$part[4] = '大小乘釋經部三';
	$part[5] = '大小乘釋經部四';
	$part[6] = '大小乘釋經部五';
	$part[7] = '大小乘釋經部六';
	$part[8] = '大小乘釋經部七';
	$part[9] = '大小乘釋經部八';
	$part[10] = '大小乘釋經部九';
	$part[11] = '大小乘釋經部十';
	$part[12] = '大小乘釋經部十一';
	$part[13] = '大小乘釋經部十二';
	$part[14] = '大小乘釋經部十三';
	$part[15] = '大小乘釋經部十四';
	$part[16] = '大小乘釋經部十五';
	$part[17] = '大小乘釋經部十六';
	$part[18] = '大小乘釋經部十七';
	$part[19] = '大小乘釋經部十八';
	$part[20] = '大小乘釋經部十九';
	$part[21] = '大小乘釋經部二十';
	$part[22] = '大小乘釋經部二十一';
	$part[23] = '大小乘釋經部二十二';
	$part[24] = '大小乘釋經部二十三';
	$part[25] = '大小乘釋經部二十四';
	$part[26] = '大小乘釋經部二十五';
	$part[27] = '大小乘釋經部二十六';
	$part[28] = '大小乘釋經部二十七';
	$part[29] = '大小乘釋經部二十八';
	$part[30] = '大小乘釋經部二十九';
	$part[31] = '大小乘釋經部三十';
	$part[32] = '大小乘釋經部三十一';
	$part[33] = '大小乘釋經部三十二';
	$part[34] = '大小乘釋經部三十三';
	$part[35] = '大小乘釋經部三十四';
	$part[36] = '大小乘釋經部三十五';
	$part[37] = '大小乘釋律部一';
	$part[38] = '大小乘釋律部二';
	$part[39] = '大小乘釋律部三';
	$part[40] = '大小乘釋律部四';
	$part[41] = '大小乘釋律部五';
	$part[42] = '大小乘釋律部六';
	$part[43] = '大小乘釋律部七';
	$part[44] = '大小乘釋論部一';
	$part[45] = '大小乘釋論部二';
	$part[46] = '大小乘釋論部三';
	$part[47] = '大小乘釋論部四';
	$part[48] = '大小乘釋論部五';
	$part[49] = '大小乘釋論部六';
	$part[50] = '大小乘釋論部七';
	$part[51] = '大小乘釋論部八';
	$part[52] = '大小乘釋論部九';
	$part[53] = '諸宗著述部一';
	$part[54] = '諸宗著述部二';
	$part[55] = '諸宗著述部三';
	$part[56] = '諸宗著述部四';
	$part[57] = '諸宗著述部五';
	$part[58] = '諸宗著述部六';
	$part[59] = '諸宗著述部七';
	$part[60] = '諸宗著述部八';
	$part[61] = '諸宗著述部九';
	$part[62] = '諸宗著述部十';
	$part[63] = '諸宗著述部十一';
	$part[64] = '諸宗著述部十二';
	$part[65] = '諸宗著述部十三';
	$part[66] = '諸宗著述部十四';
	$part[67] = '諸宗著述部十五';
	$part[68] = '諸宗著述部十六';
	$part[69] = '諸宗著述部十七';
	$part[70] = '諸宗著述部十八';
	$part[71] = '諸宗著述部十九';
	$part[72] = '諸宗著述部二十';
	$part[73] = '禮懺部';
	$part[74] = '史傳部一';
	$part[75] = '史傳部二';
	$part[76] = '史傳部三';
	$part[77] = '史傳部四';
	$part[78] = '史傳部五';
	$part[79] = '史傳部六';
	$part[80] = '史傳部七';
	$part[81] = '史傳部八';
	$part[82] = '史傳部九';
	$part[83] = '史傳部十';
	$part[84] = '史傳部十一';
	$part[85] = '史傳部十二';
	$part[86] = '史傳部十三';
	$part[87] = '史傳部十四';
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
<title>CBETA 數位藏經閣 $part $vol</title>
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA 數位藏經閣 卍續藏漢文電子佛典 $part $vol">
<meta name="keywords" content="$vol, $part, CBETA, 中華電子佛典協會, 數位藏經閣, 大正藏, 卍續藏, 大藏經, 漢文電子佛典, 漢文佛典, 佛典電子化, 電子佛典, 佛典, 佛經, 佛教, 佛法, 佛教經典, 三藏, 經藏, 素怛纜, 律藏, 毗奈耶, 毘奈耶, 毘尼, 毗尼, 論藏, 阿毗達磨, 阿毘達磨, 法寶, 達磨, Tripitaka, Pitaka, Taisho, Xuzangjing, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
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
        <td bgcolor="#F9F1DF"><font size="4">第$cvol冊 $part</font></td>
      </tr>
      </table>
      </td></tr></table>
      
      <p>
      <table align="center" border="1" cellpadding="6" cellspacing="0" width="90%"  bordercolor="#E1E9CB">
      <tr> 
        <td align="center" bgcolor="#FAE7A3" nowrap>CBETA經錄<br>卍續藏部別</td>
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

	my $my_vol = $vol;
	my $taisho_data = "";
	
	if($taisho_vol{$key})		# 此經在大正藏之中
	{
		$filename = $taisho_vol{$key} . "n" . lc($taisho_sutra{$key});
		$my_vol =  $taisho_vol{$key};
		$taisho_data = "<br>(${my_vol}n" . $taisho_sutra{$key} . ")";
	}

print OUT << "SUTRA";   
    <tr>
        <td>$cbpart{$key}<br>$part{$key}</td>
        <td>${sutra_num}</td>
        <td><a href="${my_vol}/${filename}.htm">$sutra_name{$key}</a>${taisho_data}</td>
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

			# 這是舊版 
			# 史傳部類  史傳部一  X1553_78_p0420          31  天聖廣燈錄    【宋 李遵勗[束*力]編】
			# /^\s*(\S*)\s*(\S*)\s*X(.{5})(\d\d).*?\s+(\d*)\s+(.*?)\s+(【.*】)/;
		
			# 新版有加入大正相關資料
			# 華嚴部類   華嚴部  X0001_01_p0001 xx_xxxxx 1  圓覺經佚文   【】
		
			#/^\s*(\S*)\s+(\S*)\s+X(.{5})(\d\d).*?\s+(\S*)\s+(\d*)\s+(.*?)\s+(【.*】)/;
			/^\s*(\S*)\s+(\S*)\s+X(.{5})(\d\d).*?\s+(\S*)\s+(\d*)\s+(.*?)\s+(【.*】)/;
			
			my $cbpart = $1;
			my $part1 = $2;
        	my $sutra_num = $3;
        	my $sutra_vol = $4;
        	my $taisho_data = $5;
        	my $juan = $6;
        	my $sutra_name = $7;
        	my $author = $8;

			if ($sutra_name =~ /\)$/)
			{
				$sutra_name = cut_note($sutra_name);	#去除尾部的括號
			}
		
			$sutra_num =~ s/\-/_/;
			my $key = "X$sutra_vol" . $sutra_num;	# 因為 567 三冊會相同, 所以要加上 vol

			$cbpart{$key} = $cbpart;
			$part{$key} = $part1;
			$vol{$key} = "X$sutra_vol";
			$sutra_name{$key} = lose2normal ($sutra_name, \%table, \%table2);
			$juan{$key} = $juan;
			$author{$key} = lose2normal ($author, \%table, \%table2);
			
			if($taisho_data =~ /(\d\d)_(\d\d\d\d.?)/)
			{
				$taisho_vol{$key} = "T$1";		# 大正藏的冊
				$taisho_sutra{$key} = $2;	# 大正藏的經號
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
# 產生通用字表, 使用 ODBC 資料庫
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
	local $_ = shift;		# 傳入要換的行
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