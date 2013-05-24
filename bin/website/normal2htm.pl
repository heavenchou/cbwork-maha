#!/usr/local/bin/perl
#########################################
# 將 normal/app 的版本轉成 html 版
#########################################

#######################################
#可修改參數
#######################################

$TX = "X";	# 大正藏用 "T" , 卍續藏用 "X"

$from_vol = 1;		# 起始冊數
$to_vol = 88;		# 終止冊數

$run_x2r = 1;		# 1: 要, 0: 不是, 是否要處理卍續藏X版轉換R版的動作
$run_x2r = 0 if($TX eq "T");

$out_path = "d:/cbeta.www/result/normal/";	# 輸出目錄
$source_path = "c:/release/app/";			# 原始經文來源
$sutra_url = "/result/normal/";
$XtoRPath = "c:/cbwork/common/X2R/";		# 卍續藏 X to R 版的 js 目錄

#請注意這個檔有沒有更新 "taisho.txt";
#請注意這個檔有沒有更新 "xuzang.txt";

#######################################
# 主程式
#######################################
mkdir("$out_path") if(not -d "$out_path");

if($TX eq "T")
{
	$budalist = "taisho.txt";
}
elsif($TX eq "X")
{
	$budalist = "xuzang.txt";
}

# 讀取部類資料

open IN, $budalist || die "open $budalist fail!";
while(<IN>)
{
	next if /^#/;
	#史傳部類     史傳部四      X1553_78_p0420          31  天聖廣燈錄   【宋 李遵勗[束*力]編】
	#華嚴部類     華嚴部        X0001_01_p0001 xx_xxxxx  1  圓覺經佚文                               【】
	#阿含部類     阿含部上      T0002-01-p0150 K1182-34  1  七佛經(1卷)  【宋 法天譯】
	
	/^\s*(\S*)\s*(\S*)\s*${TX}(.{5})/;
	my $id = $3;
	my $part=$2;
	my $cbpart=$1;

	$id =~ s/[\-\_]//;
	$id = lc($id);
	$part{$id}=$part;
	$cbpart{$id}=$cbpart;
	
	#拿掉什麼部一, 部二, 部全....
	
	$part{$id} =~ s/部.*$/部/;
}
close IN;


# 各冊準備工作
for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	#$vol = "$i";
	if($i == 56 and $TX eq "T") {$i = 85;}
	if($i == 6 and $TX eq "X") {$i = 7;}
	if($i == 52 and $TX eq "X") {$i = 53;}
	$vol = $TX . sprintf("%02d", $i);
	@files = <${source_path}${vol}/*.txt>;
	if($run_x2r)
	{
		$XtoRfile = "${XtoRPath}${vol}R.txt";
		getx2r();
	}
	doit();
	print "$vol ok\n";
}

exit;

sub getx2r()
{
	# xr['0420a04']='1350595a01';
	undef %X2R;
	#for($i=0; $i<=$#XtoRfiles; $i++)
    {
    	open IN, "$XtoRfile" || die "$_";
    	while(<IN>)
    	{
	    	# xr['0420a04']='1350595a01';
    		# if(/xr\['(.{7})'\]='(.{10})'/)
	    	# X63n1217_p0001a02║R110_pxxxxxxx
            # X63n1217_p0001a03║R110_p0807a01
            if(/X..n.{6}(.{7}).*?(R.{5}\d{4}.{3})/)
    		{
    			$X2R{$1} = $2;
    		}
    	}
    	close IN;
    }
}

sub doit()
{
    my $i;

    @files = sort(@files);
    for($i=0; $i<=$#files; $i++)
    {
    	my $prefile = ($i==0)?"":$files[$i-1];
    	my $file = $files[$i];
    	my $nextfile = ($i==$#files)?"":$files[$i+1];
    	
	open IN, $file;
	@txt = <IN>;
	close IN;
	
	#unlink($file);

	$file =~ /(.{8})\.txt$/;
	$outfile = lc($1);
	$outfile = "${out_path}${vol}/${outfile}.htm";
	mkdir("${out_path}${vol}","0777") if(not -d "${out_path}${vol}");

	$txt[0] =~ /(N\o\..*》)/;
	$title = $1;
	
	$outfile =~ /(.{5})0*(\d*)\.htm/;
	$jingnum = $1;
	$juannum = $2;
	
	open OUT, ">$outfile";

print OUT << "HEAD";
<html>
<head>
<title>CBETA ${vol} ${title}卷${juannum}</title>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA 數位藏經閣漢文電子佛典 ${title} 卷${juannum}">
<meta name="keywords" content="${title}, CBETA, 中華電子佛典協會, 數位藏經閣, 大正藏, 卍續藏, 大藏經, 漢文電子佛典, 漢文佛典, 佛典電子化, 電子佛典, 佛典, 佛經, 佛教, 佛法, 佛教經典, 三藏, 經藏, 素怛纜, 律藏, 毗奈耶, 毘奈耶, 毘尼, 毗尼, 論藏, 阿毗達磨, 阿毘達磨, 法寶, 達磨, Tripitaka, Pitaka, Taisho, Xuzangjing, Zokuzokyo, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
<link href="/css/cbeta.css" rel="stylesheet" type="text/css">
<script src="/js/menu.js"></script>
</head>
<body class="sutra">
<script language="javascript">
<!--
  showHeader();
-->
</script>
HEAD

	$button = "<input type=submit onClick=\"ShowXLineHead('X');\" value=\"新纂版行首(X版)\">\n<input type=submit onClick=\"ShowXLineHead('R');\" value=\"新文豐影印版行首(R版)\">\n<input type=submit onClick=\"ShowXLineHead('RX');\" value=\"R版行首，但保留X版特有的資料\">";

	if($txt[5] =~ /^===/)		#if($juannum == 1) 用卷判斷有時不準
	{
		if($run_x2r)
		{
			$txt[11] = "<hr>\n$button\n<br><p>\n";
		}
		else
		{
			$txt[11] = "<hr>\n";
		}
	
		$txt[5] = "<hr>\n";
		$txt[4] = "【其他事項】本資料庫可自由免費流通，詳細內容請參閱\【<a href=\"http://www.cbeta.org/copyright.htm\" target=\"_blank\">中華電子佛典協會版權宣告</a>】\n";
		$txt[10] = "# Distributed free of charge. For details please read at <a href=\"http://www.cbeta.org/copyright_e.htm\" target=\"_blank\">The Copyright of CBETA</a>\n";
	}
	else
	{
		if($run_x2r)
		{
			$txt[2] = "<hr>\n$button\n<br><p>\n";	
		}
		else
		{
			$txt[2] = "<hr>\n";
		}
	}
	
	#上一卷下一卷的選單
	
	print OUT "<p>";	
	writemenu($prefile, $file, $nextfile);
	
	# 加入 CBETA 經錄
	
	$jingnum =~ s/_//;
	
	$part = "〔$part{$jingnum}〕";
	$cbpart = "〔$cbpart{$jingnum}〕";
	$cbpart =~ s/,/〕〔/g;

	print OUT "<hr>【經錄部類】${cbpart}${part}<br>\n";

	# 印出經文內容

	foreach $_ (@txt)
	{
		s/\x0d//g;
		chomp;
		
		if($run_x2r)
		{
			if(/^X..n.....p(.{7}).*?║(.*)/)
			{
				# X78n1553_p0420a11
				# R135_p0595a01
				# xr['0420a04']='1350595a01';
				
				$rtmp = $X2R{$1};
				$data = $2;
				if($data ne "" and $rtmp eq "")
				{
					#$rtmp = "__________";
				}

				#$rtmp =~ s/(.{3})(.{7})/R$1_p$2/;
				
				#X78n1553_p0420a01
				#<span id=head X="X78n1553_p0420a06" R="R135_p0595a06"></span>

				if($rtmp eq "")
				{
					if($data eq "")
					{
						s/^(X..n.....p.{7}.*?║.*)/<span id=head X="$1<br>" R=""><\/span>\n/;
					}
					else
					{
						s/^X(..)n(.....)(p.{7})(.*)/<span id=head X="X$1n$2$3$4<br>" R="" RX="X0$1_$3$4<br>"><\/span>\n/;
					}
				}
				else
				{
					s/^(X..n.....p.{7})/<span id=head X="$1" R="$rtmp"><\/span>/;
				}
			}
		}	
		
		if(not /<hr>/)
		{
			$_ = "$_<br>\n" unless ($run_x2r and /<br>/);
			print OUT;
		}
		else
		{
			print OUT "$_\n";
		}
	}
	print OUT "<hr>";

	#上一卷下一卷的選單

	writemenu($prefile, $file, $nextfile);

	print OUT "<script language=\"javascript\">\n";
	print OUT "  ShowTail();\n";
	if($run_x2r)
	{
		print OUT "  ShowXLineHead(\"X\");\n";
	}
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
	close OUT;
    }
}

sub writemenu
{
	my $prefile = shift;
	my $thisfile = shift;
	my $nextfile = shift;

	$prefile =~ /(.....)(...)\.txt/;
	my $pre1 = $1;
	my $pre2 = $2;

	$thisfile =~ /(.....)(...)\.txt/;
	my $this1 = $1;
	my $this2 = $2;
	my $this3 = lc($this1);
	$this3 =~ s/_//;

	$nextfile =~ /(.....)(...)\.txt/;
	my $next1 = $1;
	my $next2 = $2;

	# 判斷上一卷有沒有連結

	if ($pre1 eq $this1)		#同一經
	{
		$prejuan1 = "<a href=\"${sutra_url}${vol}/${pre1}${pre2}.htm\">";
		$prejuan2 = "</a>";
	}
	else
	{
		$prejuan1 = "";
		$prejuan2 = "";
	}

	# 判斷下一卷有沒有連結
	
	if ($next1 eq $this1)		#同一經
	{
		$nextjuan1 = "<a href=\"${sutra_url}${vol}/${next1}${next2}.htm\">";
		$nextjuan2 = "</a>";
	}
	else
	{
		$nextjuan1 = "";
		$nextjuan2 = "";
	}
	
print OUT << "MENU";
<table border="1" cellspacing="0" cellpadding="5" bgcolor="#FAE7A3" align="center" bordercolor="#9BB4C6" width="50%">
  <tr> 
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10"><a href="/index.htm">大藏經目錄</a></td>
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10"><a href="/result/${vol}/${vol}n${this3}.htm">本經目錄</a></td>
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10">${prejuan1}上一卷${prejuan2}</td>
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10">${nextjuan1}下一卷${nextjuan2}</td>
  </tr>
</table>
MENU

}