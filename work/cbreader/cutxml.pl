# $Id: cutxml.pl,v 1.25 2011/03/15 04:44:44 heaven Exp $
# 使用方法
#
# perl cutxml.pl T01 [T01n0001.xml]
#
# ★★★ 請注意, 若有不連續卷, 要先處理不連續卷資料
#
# 將 XML 切成一卷一檔, 這是由 getjuanpos.pl 修改而來的, 
# 也就是將 getjuanpls 的資料去組合成一卷一檔
#
# 實際的作法 : 
# 1. 先找出各 <milestone> 的位置, 把詳細的位置記錄起來, 並記下相關 lb 的行首資訊
# 2. 再 parse XML , 把各卷切卷處的 標記頭尾都記錄起來, 切卷之後才能補上相關的頭尾.
# 3. 把 <mulu> 的層次也要記錄起來, 因為有些範圍跨卷的 <mulu> 也要補上去, 主要是為了引用複製要取得品資訊
#
# 底下是以前 getjuanpos 的說明
#
# ===============================================================
#
# 由 xml 取得各經各卷的位置, 並單獨存成一檔, 以利日後快速取出單卷
#
# 檔名:T01n0013.2
# 內容:
# ==================
# 1506
# 19372
# 43944
# <div1 type="jing">
# </body></text></tei.2>
# ================
#
# 也就是當我想讀 T01n0013 的第2卷時,
# 會將臨時產生一個檔
# 
# 該臨時檔的內容是
# 
# T01n0013.xml 前 1506 個位元 (也就是到 <text><body> 為止)
# 再加上
# <div1 type="jing">
# 再加上
# T01n0013.xml  檔案絕對位置 19372 ~ 43944 (也就是第二卷的內容)
# 再加上
# </body></text></tei.2>
# 
# 就是一個第二卷的 xml 了

# command line parameters

require "c:/cbwork/work/bin/utf8b5o.plx";
use File::Copy;

my $pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
$vol = shift;
$inputFile = shift;

if($inputFile eq "" and $vol =~ /^(([TXJHWIABCFGKLMNPQSU]|(ZS)|(ZW))\d*)n.*?\.xml$/)
{
	$inputFile = $vol;
	$vol = $1;
}

$vol = uc($vol);

unless($vol)
{
	print "perl cutxml.pl T01 [T01n0001.xml]\n";
	exit;
}

my $errlog = "cutxml_${vol}_err.txt";

# 取參數

require "cutxml_cfg.pl";

local @lines = ();

# 取得所有 xml 的檔案名稱

opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

mkdir($outPath, MODE);

use XML::DOM;
my $parser = new XML::DOM::Parser;

if ($inputFile eq "") 
{
	my $killfile = "$outPath/*.*";
	$killfile =~ s/\//\\/g;
	$rmfile = unlink <${killfile}>;
	print "remove $killfile ($rmfile files removed)\n";

	open ERRLOG, ">$errlog" || die "open error log $errlog error!";
	close ERRLOG;
	for $file (sort(@allfiles)) 
	{
		print "$file\n";
		$file =~ /(?:[TXJHWIABCFGKLMNPQSU]|(?:ZS)|(?:ZW))(\d*)n(.{4,5})/;
		print STDERR "$1$2 ";
		do1file($file);
	}
	unlink $errlog;
} 
else
{
	my $killfile = "$outPath/$inputFile";
	$killfile =~ s/\//\\/g;
	$killfile =~ s/\.xml$/*.*/;
	$rmfile = unlink <${killfile}>;
	print "remove $killfile ($rmfile files removed)\n";

	$file = $inputFile;
	print "$file\n";
	$file =~ /(?:[TXJHWIABCFGKLMNPQSU]|(?:ZS)|(?:ZW))(\d*)n(.{4,5})/;
	print STDERR "$1$2 ";
	
	$errlog = "cutxml_${file}_err.txt";
	open ERRLOG, ">$errlog" || die "open error log $errlog error!";
	close ERRLOG;
	do1file($file);
	unlink $errlog;
}

#################################################

sub do1file 
{
	my $file = shift;
	my $infile = "$sourcePath/$file";	# 來源檔
	my $outfile;
	my $filelen;	# xml 檔的長度
	my $alldata;	# 本檔所有的內容
	
	my @juan_start = ();
	my @juan_end = ();
	local @lbn = ();
	local @start_tag = ();		# 記錄各卷開頭應該要補上的標記
	local @end_tag = ();		# 記錄各卷結尾應該要補上的標記
	
	# 各卷目錄開頭的處理法:
	# 每一卷一遇到 <mulu level="n"> 就記錄在 $this_juan_mulu[n] , 並把 n 記錄k在 $mulu_n 變數中
	# 該卷結束時, 就把 1~n 的標記都記錄在 $mulu_tag[n] 之中
	# 例如某一卷結束時, @this_juan_mulu 內容是 ("<mulu level=1 label=第一個/>", "<mulu level=2 label=第二個/>")
	# 則 $mulu_tag[x] = "<mulu level=1 label=第一個/><mulu level=2 label=第二個/>"
	
	local @mulu_tag = ();		# 記錄各卷開頭要補上的記錄 , 陣列是由 1 開始處理, 0 不管它.
	local @this_juan_mulu = ();		# 記錄某一卷的所有 mulu 標記 , 陣列是由 1 開始處理, 0 不管它.
	local $mulu_n = 0;
	
	open (IN, $infile) or die "open $infile error!$!";
	binmode IN;	# 二進位檔
	
	seek IN, 0, 2;
	$filelen = tell IN;	# 取得檔案長度
	seek IN, 0, 0;
	
	read IN, $alldata, $filelen;	#讀入變數中
	
	##########################################
	# 找 xml 前面的大小 (至 <text><body> 為止)
	##########################################
	
	my $pos1 = index($alldata, "<body>", 0);
	
	if ($pos1 < 0)			# 找不到
	{
		print "$infile pos1 = $pos1\n";
		print STDERR "$infile pos1 = $pos1\n";
	}
	
	if(substr ($alldata, $pos1, 8) eq "<body>\x0d\x0a"){
		$pos1 += 8;	# 包含二個換行 0d 0a
	}
	else{
		$pos1 += 6;
	}
	
	##############################################
	# 要逐卷找 <milestone 了
	#########################
	
	my $juannum = 0;
	my $milestonepos = -1;
	
	# <lb n="0875b02"/>
	# <milestone unit="juan" n="1"/>
	
	$alldata =~ s/(<milestone)(.*?)( unit=".*?")(.*?>)/$1$3$2$4/g;
	while(($milestonepos = index($alldata, "<milestone unit", 0)) > 0)
	#while(($milestonepos = index($alldata, "<milestone ", 0)) > 0)
	{
		# 在 <body 之前的不要, 因為可能是在註解中
		
		if($milestonepos < $pos1)
		{
			substr($alldata, $milestonepos, 3) = "<--";	
			next;
		}
		
		# 找到 milestone
		
		$juannum++;
		
		# 將 <milestone 換成 <--lestone, 以免重覆找到
		substr($alldata, $milestonepos, 3) = "<--";	
		
		if(substr ($alldata, $milestonepos - 19, 3) eq "<lb"){
			$milestonepos -= 19;	# <lb n="0107a16"/>\n<milestone unit="juan" n="17"/>
		} elsif (substr ($alldata, $milestonepos - 17, 3) eq "<lb"){
			$milestonepos -= 17;	# milestone 和 lb 之間沒有換行
		} elsif (substr ($alldata, $milestonepos - 26, 3) eq "<lb"){
			$milestonepos -= 26;	# <lb ed="X" n="0691a08"/><milestone unit="juan" n="7"/>
		} elsif (substr ($alldata, $milestonepos - 24, 3) eq "<lb"){
			$milestonepos -= 24;	# milestone 和 lb 之間沒有換行
		} else {
			
			# 唉, 還是乖乖找吧!
			# <lb n="0666c16"/><div1 type="other">\n<milestone unit="juan" n="38"/>
			
			my $lbpos = 0;
			
			for(my $i=0; $i<100; $i++)
			{
				if(substr ($alldata, $milestonepos - 20 - $i, 3) eq "<lb")
				{
					$lbpos = 20 + $i;
					$milestonepos -= $lbpos;
					last;
				}
			}

			if($lbpos == 0)		# 唉, 真的找不到了
			{
				print "$juannum Error!";
				print STDERR "$juannum Error!";
				exit 1;
			}
		}

		# 新版的, 取出 lb 的資料

		my $lbn = substr ($alldata, $milestonepos, 50);
		$lbn =~ /^.*?n="(\d\d\d\d.\d\d)"/;
		$lbn[$juannum] = $1;

		# <lb 之前若有 <pb , 也一併吃下來
		#<pb ed="X" id="X78.1553.0431b" n="0431b"/>\n<lb ed="X" n="0431b01"/><milestone unit="juan" n="3"/>
		if(substr ($alldata, $milestonepos - 44, 3) eq "<pb"){
			$milestonepos -= 44;
		}
		#<pb ed="ZS" id="ZS78.1553.0431b" n="0431b"/>\n<lb ed="X" n="0431b01"/><milestone unit="juan" n="3"/>
		if(substr ($alldata, $milestonepos - 46, 3) eq "<pb"){
			$milestonepos -= 46;
		}
			
		$juan_start[$juannum] = $milestonepos;
		if($juannum > 0){
			$juan_end[$juannum-1] = $juan_start[$juannum]-1;
		}
	}
	
	$endpos = index($alldata, "</body>", 0);
	$juan_end[$juannum] = $endpos - 1;
	
	################################################
	#
	# 要 paser xml 了
	#
	##################

	ParserXML($file);

	##############################################
	# copy ent 檔
	#########################
	
	$entfile = $file;
	$entfile =~ s/\.xml/\.ent/;
	
	copy("$sourcePath/$entfile", "$outPath/$entfile");
	
	################################################
	#
	# 輸出結果
	#
	##################

	print STDERR "juannum=$juannum\n";
	for($i=1; $i<= $juannum; $i++)
	{
		my $ii = sprintf("%03d",$i);
		
		#處理特殊檔名 ###########################################
		
		if($file eq "T06n0220b.xml")
		{
			$ii = sprintf("%03d",$i+200);
		}
		if($file eq "T07n0220c.xml")
		{
			$ii = sprintf("%03d",$i+400);
		}
		if($file eq "T07n0220d.xml")
		{
			$ii = sprintf("%03d",$i+537);
		}
		if($file eq "T07n0220e.xml")
		{
			$ii = sprintf("%03d",$i+565);
		}
		if($file eq "T07n0220f.xml")
		{
			$ii = sprintf("%03d",$i+573);
		}
		if($file eq "T07n0220g.xml")
		{
			$ii = sprintf("%03d",$i+575);
		}
		if($file eq "T07n0220h.xml")
		{
			$ii = sprintf("%03d",$i+576);
		}
		if($file eq "T07n0220i.xml")
		{
			$ii = sprintf("%03d",$i+577);
		}
		if($file eq "T07n0220j.xml")
		{
			$ii = sprintf("%03d",$i+578);
		}
		if($file eq "T07n0220k.xml")
		{
			$ii = sprintf("%03d",$i+583);
		}
		if($file eq "T07n0220l.xml")
		{
			$ii = sprintf("%03d",$i+588);
		}
		if($file eq "T07n0220m.xml")
		{
			$ii = sprintf("%03d",$i+589);
		}
		if($file eq "T07n0220n.xml")
		{
			$ii = sprintf("%03d",$i+590);
		}
		if($file eq "T07n0220o.xml")
		{
			$ii = sprintf("%03d",$i+592);
		}
		#T19n0946.xml 沒有第三卷, 只有 1, 2, 4, 5 卷
		if($file eq "T19n0946.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i>2);
		}
		# T54
		if($file eq "T54n2139.xml")
		{
			$ii = "010" if($i==2);
		}
		# T85
		if($file eq "T85n2742.xml")
		{
			$ii = "002" if($i==1);
		}
		if($file eq "T85n2744.xml")
		{
			$ii = "002" if($i==1);
		}
		if($file eq "T85n2748.xml")
		{
			$ii = "003" if($i==1);
		}
		if($file eq "T85n2754.xml")
		{
			$ii = "003" if($i==1);
		}
		if($file eq "T85n2757.xml")
		{
			$ii = "003" if($i==1);
		}
		if($file eq "T85n2764B.xml")
		{
			$ii = "004" if($i==1);
		}
		if($file eq "T85n2769.xml")
		{
			$ii = "004" if($i==1);
		}
		if($file eq "T85n2772.xml")
		{
			$ii = "003" if($i==1);
		}
		if($file eq "T85n2772.xml")
		{
			$ii = "006" if($i==2);
		}
		if($file eq "T85n2799.xml")
		{
			$ii = "003" if($i==2);
		}
		if($file eq "T85n2803.xml")
		{
			$ii = "004" if($i==1);
		}
		if($file eq "T85n2805.xml")
		{
			$ii = "005" if($i==1);
		}
		if($file eq "T85n2805.xml")
		{
			$ii = "007" if($i==2);
		}
		if($file eq "T85n2809.xml")
		{
			$ii = "004" if($i==1);
		}
		if($file eq "T85n2814.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		if($file eq "T85n2820.xml")
		{
			$ii = "012" if($i==1);
		}
		if($file eq "T85n2825.xml")
		{
			$ii = "003" if($i==2);
		}
		if($file eq "T85n2827.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		if($file eq "T85n2880.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		########################################
		#處理特殊的卷
		
		# X03n0208.xml 只有卷10
		if($file eq "X03n0208.xml")
		{
			$ii = "010" if($i==1);
		}
		# X03n0211.xml 只有卷6
		if($file eq "X03n0211.xml")
		{
			$ii = "006" if($i==1);
		}
		# X03n0221.xml 由卷 1~5,8~15, 不是 6~13 (沒有 6,7)
		if($file eq "X03n0221.xml")
		{
			$ii = sprintf("%03d",$i+2) if($i>5);
		}
		#X07n0234.xml 華嚴經疏注,(百二十卷但欠卷21~70、91~100及111~112)
		#01~20,71~90,101~110,113~120 (實際卷數)
		#01~20,21~40, 41~ 50, 51~ 58 (流水卷數)
		if($file eq "X07n0234.xml")
		{
			$ii = sprintf("%03d",$i+50) if($i>20);
			$ii = sprintf("%03d",$i+60) if($i>40);
			$ii = sprintf("%03d",$i+62) if($i>50);
		}
		# X08n0235.xml 華嚴經談玄抉擇,(六卷但初卷不傳),
		if($file eq "X08n0235.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X09n0240 由卷 45 開始
		if($file eq "X09n0240.xml")
		{
			$ii = sprintf("%03d",$i+44);
		}
		# X09n0244 由是 2,3 , 沒有卷1
		if($file eq "X09n0244.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X17n0321.xml 由卷 1,2,5 不是 1~3 (沒有 3,4)
		if($file eq "X17n0321.xml")
		{
			$ii = "005" if($i == 3);
		}
		# X19n0345.xml 由卷 4,5 不是 1~2 (沒有 1~3)
		if($file eq "X19n0345.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X21n0367.xml 由卷 4~8 不是 1~5 (沒有 1~3)
		if($file eq "X21n0367.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X21n0368.xml 由卷 2~4 不是 1~3 (沒有 1)
		if($file eq "X21n0368.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X24n0451.xml 由卷 1,3~10, 不是 1~9 (沒有 2)
		if($file eq "X24n0451.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 1);
		}
		# X26n0560.xml 只有卷 2 不是 1 (沒有 1)
		if($file eq "X26n0560.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X34n0638.xml 由卷 1~21,24~29,31,33~35 , 不是 1~31 (沒有 22,23,30.32)
		if($file eq "X34n0638.xml")
		{
			$ii = sprintf("%03d",$i+2) if($i > 21);
			$ii = sprintf("%03d",$i+3) if($i > 27);
			$ii = sprintf("%03d",$i+4) if($i > 28);
		}
		# X37n0662.xml 由卷 1~14,16~20, 不是 1~19 (沒有 15)
		if($file eq "X37n0662.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 14);
		}
		# X38n0687.xml 由卷 2,4 , 不是 1,2 (沒有 1,3)
		if($file eq "X38n0687.xml")
		{
			$ii = "002" if($i == 1);
			$ii = "004" if($i == 2);
		}
		# X39n0704.xml 由卷 3~5, 不是 1~3 (沒有 1,2)
		if($file eq "X39n0704.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X39n0705.xml 由卷 2 不是 1 (沒有 1)
		if($file eq "X39n0705.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X39n0712.xml 由卷 3 不是 1 (沒有 1,2)
		if($file eq "X39n0712.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X40n0714.xml 由卷 3,4 不是 1,2 (沒有 1,2)
		if($file eq "X40n0714.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X42n0733.xml 由卷 2~8,10 不是 1~8 (沒有 1,9)
		if($file eq "X42n0733.xml")
		{
			$ii = sprintf("%03d",$i+1);
			$ii = "010" if($i == 8);
		}
		# X42n0734.xml 由卷 9 不是 1 (沒有 1~8)
		if($file eq "X42n0734.xml")
		{
			$ii = "009";
		}
		# X46n0784.xml 由卷 2,5~10 不是 1~7 (沒有 1,3,4)
		if($file eq "X46n0784.xml")
		{
			$ii = "002" if($i == 1);
			$ii = sprintf("%03d",$i+3) if($i > 1);
		}
		# X46n0791.xml 由卷 1,6,14,15,17,21,24 不是 1~7 (沒有 ...)
		if($file eq "X46n0791.xml")
		{
			$ii = "006" if($i == 2);
			$ii = "014" if($i == 3);
			$ii = "015" if($i == 4);
			$ii = "017" if($i == 5);
			$ii = "021" if($i == 6);
			$ii = "024" if($i == 7);
		}
		# X48n0797.xml 由卷 3 不是 1 (沒有 1,2)
		if($file eq "X48n0797.xml")
		{
			$ii = "003";
		}
		# X48n0799.xml 由卷 1,2,7 不是 1~3 (沒有 3~6)
		if($file eq "X48n0799.xml")
		{
			$ii = "007" if($i == 3);
		}
		# X48n0808.xml 由卷 1,5,9,10 不是 1~4 (沒有 2,3,4,6,7,8)
		if($file eq "X48n0808.xml")
		{
			$ii = "005" if($i == 2);
			$ii = "009" if($i == 3);
			$ii = "010" if($i == 4);
		}
		# X49n0812.xml 由卷 2 不是 1 (沒有 1)
		if($file eq "X49n0812.xml")
		{
			$ii = "002";
		}
		# X49n0815.xml 由卷 1~8,10~13 不是 1~12 (沒有 9)
		if($file eq "X49n0815.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 8);
		}
		# X50n0817.xml 由卷 17 不是 1 (沒有 1~16)
		if($file eq "X50n0817.xml")
		{
			$ii = "017";
		}
		# X50n0819.xml 由卷 1~14,16,18 不是 1~16 (沒有 15,17)
		if($file eq "X50n0819.xml")
		{
			$ii = "016" if($i == 15);
			$ii = "018" if($i == 16);
		}
		# X51n0822.xml 由卷 4~10 不是 1~7 (沒有 1~3)
		if($file eq "X51n0822.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X53n0836.xml 由卷 1,2,4~7,17 不是 1~7 (沒有 3,8~16)
		if($file eq "X53n0836.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 2);
			$ii = "017" if($i == 7);
		}
		# X53n0842.xml 由卷 29,30 不是 1,2 (沒有 1~28)
		if($file eq "X53n0842.xml")
		{
			$ii = "029" if($i == 1);
			$ii = "030" if($i == 2);
		}
		# X53n0843.xml 由卷 9,18 不是 1,2 (沒有 1~8,10~17)
		if($file eq "X53n0843.xml")
		{
			$ii = "009" if($i == 1);
			$ii = "018" if($i == 2);
		} 
		# X55n0882.xml 有三卷, 分別為 4,7,8
		if($file eq "X55n0882.xml")
		{
			$ii = "004" if($i == 1);
			$ii = "007" if($i == 2);
			$ii = "008" if($i == 3);
		} 
		# X57n0952.xml 只有卷 10
		if($file eq "X57n0952.xml")
		{
			$ii = "010" if($i == 1);
		} 
		# X57n0966.xml 由卷 2 開始 (2,3,4,5)
		if($file eq "X57n0966.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X57n0967.xml 由卷 3 開始 (3,4)
		if($file eq "X57n0967.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X58n1015.xml 只有二卷, 分別為 14,22
		if($file eq "X58n1015.xml")
		{
			$ii = "014" if($i == 1);
			$ii = "022" if($i == 2);
		}
		# X72n1435.xml 由卷13 接著卷 16
		if($file eq "X72n1435.xml" and $i > 13)
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X73n1456.xml 由卷44~55, 不是 41~52 (沒有 41,42,43)
		if($file eq "X73n1456.xml" and $i > 40)
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X81n1568.xml 由卷10~卷25, 不是1~16
		if($file eq "X81n1568.xml")
		{
			$ii = sprintf("%03d",$i+9);
		}
		# X82n1571.xml 由卷 34~120 不是 1~ 87
		if($file eq "X82n1571.xml")
		{
			$ii = sprintf("%03d",$i+33);
		}
		# X85n1587.xml 由卷 2~16 不是 1~ 15
		if($file eq "X85n1587.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# J25nB165.xml 共 1 卷, 只有卷 6
		if($file eq "J25nB165.xml")
		{
			$ii = "006" if($i==1);
		}
		# J25nB166.xml 共 1 卷, 只有卷 7
		if($file eq "J25nB166.xml")
		{
			$ii = "007" if($i==1);
		}
		# J25nB167.xml 共 1 卷, 只有卷 8
		if($file eq "J25nB167.xml")
		{
			$ii = "008" if($i==1);
		}
		# J32nB271.xml 由卷 6~44 不是 1~39
		if($file eq "J32nB271.xml")
		{
			$ii = sprintf("%03d",$i+5);
		}
		# J33nB277.xml 由卷 12~25 不是 1~14
		if($file eq "J33nB277.xml")
		{
			$ii = sprintf("%03d",$i+11);
		}
		# W01n0007.xml 共 1 卷, 只有卷 3
		if($file eq "W01n0007.xml")
		{
			$ii = "003" if($i==1);
		}
		# W03n0025.xml 共 1 卷, 只有卷 2
		if($file eq "W03n0025.xml")
		{
			$ii = "002" if($i==1);
		}
		# W03n0030.xml 共 1 卷, 只有卷 14
		if($file eq "W03n0030.xml")
		{
			$ii = "014" if($i==1);
		}
		# A097n1276      大唐開元釋教廣品歷章(第3卷-第4卷)
		if($file eq "A097n1276.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# A098n1276      大唐開元釋教廣品歷章(第5-10,12-20卷)
		if($file eq "A098n1276.xml")
		{
			if($i<=6) {	$ii = sprintf("%03d",$i+4); }
			else { $ii = sprintf("%03d",$i+5); }
		}
		# A111n1501      大中祥符法寶錄 (3-8,10-12)
		if($file eq "A111n1501.xml")
		{
			if($i<=6) {	$ii = sprintf("%03d",$i+2); }
			else { $ii = sprintf("%03d",$i+3); }
		}
		# A112n1501      大中祥符法寶錄 (13-18,20)
		if($file eq "A112n1501.xml")
		{
			if($i<=6) {	$ii = sprintf("%03d",$i+12); }
			else { $ii = sprintf("%03d",$i+13); }
		}
		# A114n1510      佛說大乘僧伽吒法義經 (2,6,7卷)
		if($file eq "A114n1510.xml")
		{
			$ii = "002" if($i==1);
			$ii = "006" if($i==2);
			$ii = "007" if($i==3);
		}
		# A120n1565      瑜伽師地論義演(第1,4,6-8,11-12,15,17,19-20,22,26,28-32卷)
		if($file eq "A120n1565.xml")
		{
			$ii = "001" if($i==1);
			$ii = "004" if($i==2);
			$ii = "006" if($i==3);
			$ii = "007" if($i==4);
			$ii = "008" if($i==5);
			$ii = "011" if($i==6);
			$ii = "012" if($i==7);
			$ii = "015" if($i==8);
			$ii = "017" if($i==9);
			$ii = "019" if($i==10);
			$ii = "020" if($i==11);
			$ii = "022" if($i==12);
			$ii = "026" if($i==13);
			$ii = sprintf("%03d",$i+14) if($i > 13);
		}
		# A121n1565      瑜伽師地論義演(第33-35,38,40卷)
		if($file eq "A121n1565.xml")
		{
			$ii = "033" if($i==1);
			$ii = "034" if($i==2);
			$ii = "035" if($i==3);
			$ii = "038" if($i==4);
			$ii = "040" if($i==5);
		}
		# C056n1163      一切經音義(第1卷-第15卷)
		# C057n1163      一切經音義(第16卷-第25卷)
		if($file eq "C057n1163.xml")
		{
			$ii = sprintf("%03d",$i+15);
		}
		# K34n1257       新集藏經音義隨函錄(第1卷-第12)
		# K35n1257       新集藏經音義隨函錄(第13卷-第30)
		if($file eq "K35n1257.xml")
		{
			$ii = sprintf("%03d",$i+12);
		}
		# K41n1482       大乘中觀釋論(第10卷-第18卷)
		if($file eq "K41n1482.xml")
		{
			$ii = sprintf("%03d",$i+9);
		}
		# L115n1490      妙法蓮華經玄義釋籤(第1卷-第3卷)
		# L116n1490      妙法蓮華經玄義釋籤(第4卷-第40卷)
		if($file eq "L116n1490.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# L130n1557      大方廣佛華嚴經疏鈔會本(第1卷-第17卷)
		# L131n1557      大方廣佛華嚴經疏鈔會本(第17卷-第34卷)
		if($file eq "L131n1557.xml")
		{
			$ii = sprintf("%03d",$i+16);
		}
		# L132n1557      大方廣佛華嚴經疏鈔會本(第34卷-第51卷)
		if($file eq "L132n1557.xml")
		{
			$ii = sprintf("%03d",$i+33);
		}
		# L133n1557      大方廣佛華嚴經疏鈔會本(第51卷-第80卷)
		if($file eq "L133n1557.xml")
		{
			$ii = sprintf("%03d",$i+50);
		}
		# L153n1638      雪嶠信禪師語錄(第1卷-第6卷)
		# L154n1638      雪嶠信禪師語錄(第7卷-第10卷)
		if($file eq "L154n1638.xml")
		{
			$ii = sprintf("%03d",$i+6);
		}
		# P154n1519      宗門統要正續集(第1卷-第12卷)
		# P155n1519      宗門統要正續集(第13卷-第20卷)
		if($file eq "P155n1519.xml")
		{
			$ii = sprintf("%03d",$i+12);
		}
		# P178n1611      諸佛世尊如來菩薩尊者神僧名經(第1卷-第29卷)
		# P179n1611      諸佛世尊如來菩薩尊者神僧名經(第30卷-第40卷)
		if($file eq "P179n1611.xml")
		{
			$ii = sprintf("%03d",$i+29);
		}
		# P179n1612      諸佛世尊如來菩薩尊者名稱歌曲(第1卷-第18卷)
		# P180n1612      諸佛世尊如來菩薩尊者名稱歌曲(第19卷-第50卷)
		if($file eq "P180n1612.xml")
		{
			$ii = sprintf("%03d",$i+18);
		}
		# P181n1612      諸佛世尊如來菩薩尊者名稱歌曲(第51卷)
		if($file eq "P181n1612.xml")
		{
			$ii = "051" if($i==1);
		}
		# P181n1615      大明三藏法數(第1卷-第13卷)
		# P182n1615      大明三藏法數(第14卷-第35卷)
		if($file eq "P182n1615.xml")
		{
			$ii = sprintf("%03d",$i+13);
		}
		# P183n1615      大明三藏法數(第36卷-第38卷)
		if($file eq "P183n1615.xml")
		{
			$ii = sprintf("%03d",$i+35);
		}
		# P184n1617      妙法蓮華經要解(第1卷-第12卷)
		# P185n1617      妙法蓮華經要解(第13卷-第19卷)
		if($file eq "P185n1617.xml")
		{
			$ii = sprintf("%03d",$i+12);
		}
		# S06n0046       上生經會古通今新抄(第2,4卷)
		if($file eq "S06n0046.xml")
		{
			$ii = "002" if($i==1);
			$ii = "004" if($i==2);
		}
		# U222n1418      華嚴經疏科(第1卷-第3卷)
		# U223n1418      華嚴經疏科(第4-5,7-20卷)
		if($file eq "U223n1418.xml")
		{
			$ii = "004" if($i==1);
			$ii = "005" if($i==2);
			$ii = sprintf("%03d",$i+4) if($i > 2);
		}
		
		#處理特殊檔名 ###########################################
		
		$outfile = "$outPath/$file";	# 輸出檔
		$outfile =~ s/\.xml$/_$ii.xml/;	# 檔名變成 T01n0001_001.xml
		
		$outfile =~ s/(T0[5-7]n0220)[a-z]/$1/;		# 專門為大般若經寫的

		print STDERR ">$outfile\n";
		open OUT, ">$outfile" or die "Open $outfile error!$!";
		binmode OUT;	# 二進位檔		
		
		#print OUT "$pos1\n";
		#print OUT "$juan_start[$i]\n";
		#print OUT "$juan_end[$i]\n";
		#print OUT "$start_tag[$i]\n";
		#print OUT "${end_tag[$i]}</body></text></tei.2>";
		
		my $out = substr ($alldata, 0, $pos1);
		$out =~ s/<--lestone/<milestone/;
		$out =~ s/"cp950"/"big5"/;		# CBReader 還是需要用 big5 的字集宣告
		
		print OUT "$out";
		
		print OUT "$mulu_tag[$i]";
		print OUT "$start_tag[$i]\x0d\x0a" unless ($start_tag[$i] eq "");
		
		$out = substr ($alldata, $juan_start[$i], $juan_end[$i]-$juan_start[$i]+1);
		$out =~ s/<--lestone/<milestone/;
		print OUT "$out";
		
		print OUT "${end_tag[$i]}</body></text></TEI.2>";
		
		close OUT;
	}
	
	close IN;

}

sub ParserXML()
{	

	my $file = shift;
	$newdir = "$sourcePath/";
	chdir "$newdir";
	print STDERR "parse $file\n";
	my $doc = $parser->parsefile($file);
	chdir "$myPath";
	
	my $root = $doc->getDocumentElement();
	
	local $milestoneNum = 0;
	
	parseNode($root);	# 進行分析
	$root->dispose;
}

sub parseNode
{
	my $node = shift;
	my $nodeTypeName = $node->getNodeTypeName;
	if ($nodeTypeName eq "ELEMENT_NODE") {
		start_handler($node);
		for my $kid ($node->getChildNodes) {
			parseNode($kid);
		}
		#end_handler($node);
	}
	# elsif ($nodeTypeName eq "TEXT_NODE") {text_handler($node);}	# 我不做這個
}

sub start_handler 
{       
	my $node = shift;
	my $parentnode;
	
	local $el = $node->getTagName;
	
	# 處理 <lb> 標記
	if ($el eq "lb")
	{
		my $lb_attmap = $node->getAttributes;
		my $bingo = 0;
		
		for my $lb_attr ($lb_attmap->getValues) 
		{
			my $attrName = $lb_attr->getName;
			my $attrValue = $lb_attr->getValue;
			
			if ($attrName eq "n" and $attrValue eq $lbn[$milestoneNum+1])
			{
				# 至此, 表示這一個 <lb> 是某一卷的開始.
				$bingo = 1;
				last;
			}
		}
		
		return if($bingo == 0);

		# 至此, 表示找到另一卷的開頭處, 所以要記錄上卷未結束的各種標記, 才符合 XML 的原則.

		$milestoneNum++;	# 第 N 個
		
		$parentnode = $node->getParentNode();
		while(($pnName = $parentnode->getTagName()) ne "body")
		{
			my $map = $parentnode->getAttributes;
			my $attrs = "<$pnName";
			for my $attr ($map->getValues) 
			{
				my $attrName = $attr->getName;
				my $attrValue = $attr->getValue;
				$attrValue =~ s/($pattern)/$utf8out{$1}/g;
				$attrs .= " $attrName=\"$attrValue\"";
			}
	
			$start_tag[$milestoneNum] = "${attrs}>" . $start_tag[$milestoneNum];
			$end_tag[$milestoneNum-1] .= "</${pnName}>";
			$parentnode = $parentnode->getParentNode();
		}
		
		# 記錄此卷的 mulu 標記
		$mulu_tag[$milestoneNum] = "";
		for($i = 1; $i<=$mulu_n; $i++)
		{
			$mulu_tag[$milestoneNum] = $mulu_tag[$milestoneNum] . $this_juan_mulu[$i];
		}
		#$mulu_n = 0;			# 不可以歸零, 因為某一卷可能完全沒有 mulu , 但都要一直繼承上去
		#$this_juan_mulu = ();	# 不可以歸零, 因為某一卷可能完全沒有 mulu , 但都要一直繼承上去
	}
	
	# 處理 <mulu> 標記 <mulu level="1" label="序" type="序"/>
	
	# 各卷目錄開頭的處理法:
	# 每一卷一遇到 <mulu level="n"> 就記錄在 $this_juan_mulu[n] , 並把 n 記錄k在 $mulu_n 變數中
	# 該卷結束時, 就把 1~n 的標記都記錄在 $mulu_tag[n] 之中
	# 例如某一卷結束時, @this_juan_mulu 內容是 ("<mulu level=1 label=第一個/>", "<mulu level=2 label=第二個/>")
	# 則 $mulu_tag[x] = "<mulu level=1 label=第一個/><mulu level=2 label=第二個/>"
	
	if ($el eq "mulu")
	{
		my $map = $node->getAttributes;
		my $attrs = "<mulu";
		my $mulu_n_tmp = 0;
		for my $attr ($map->getValues) 
		{
			my $attrName = $attr->getName;
			my $attrValue = $attr->getValue;
			$attrValue =~ s/($pattern)/$utf8out{$1}/g;
			$attrs .= " $attrName=\"$attrValue\"";
			if($attrName eq "level")
			{
				$mulu_n_tmp = $attrValue;
			}
		}
		if($attrs =~ / level=/)		# 沒有 level 的不處理 <mulu n="002" type="卷"/>
		{
			$mulu_n = $mulu_n_tmp;
			$this_juan_mulu[$mulu_n] = "${attrs}/>";
		}
	}
}