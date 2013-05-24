#called from CBETA output programs. 
#provided the HEADER information
# v 0.1, zh=>chi, en=>eng, 2002/10/21 10:13AM by Ray
# v 0.2, 檔頭顯示正確 encoding, 2002/10/24 01:33PM by Ray

require "subutf8.pl";
sub head {
	my $cFormat = shift;
	my $eFormat = shift;
	my $version = shift;
	#watch("\n12|ebib=$ebib\n");
	#watch("\n12|ebib=[$cFormat][$eFormat][$version]\n");
	$ebib =~ s/^\t+//;
	$ebib =~ s/\&desc;//i;
	if ($ebib =~ /Vol\.\s+([0-9]+),\s+No\.\s+([AB])?([0-9]+)([A-Za-z])?/){
		$cbd = $1;
		$pre_cvol= $2;	# 嘉興藏的經號前會有 AB 等數字
		$cvol= $3;
		$xa = $4;
	}
	$ebib =~ s/(.*) $/$1/;  # added by Ray 1999/11/28 05:03PM 去掉最後的空白
	# 跨冊的經, 經號最後的 abc 去掉, 別本的 abc 還是要保留 2006/6/27 15:55 by Ray
	print STDERR "ebib=[$ebib]\n";
	if ($xa ne '') {
		if ($vol =~ /^T/) {
			if ($cvol eq "220") {
				$xa = '';
				$ebib = strip_abc($ebib);
			}
		} elsif ($vol =~ /^X/) {
			if ($cvol =~/^(240|367|714|1568|1571)$/) {
				$xa = '';
				$ebib = strip_abc($ebib);
			}
		}
	}
	#watch("cbd=[$cbd] $cvol=[$cvol]\n");
 	$cbd = cNum($cbd);  # 轉為中文數字
	
	if($pre_cvol eq "")	# 非嘉興藏才需要去除經號前面的 0
	{
		$cvol =~ s/^0(\d*)/$1/;
		$cvol =~ s/^0(\d*)/$1/;
	}
	
	$ebib =~ s/(.*)No. 0(.*)/$1No. $2/;
	$ebib =~ s/(.*)No. 0(.*)/$1No. $2/;
	$ebib =~ s/(.*)Vol. 0(.*)/$1Vol. $2/;

	$ly{"zh"} =~ s/卅/／/g;
	#watch("第${cbd}冊 No. $pre_cvol$cvol$xa《${title}》V${version} $cFormat，完成日期：${date}");

	my $encoding="";
	if ($outEncoding eq "big5") {
		$encoding="Big5";
	} elsif ( $outEncoding eq "gbk"){
		$encoding="GBK";
	} elsif ( $outEncoding eq "sjis"){
		$encoding="Shift-JIS";
	} elsif ($outEncoding eq "utf8") {
		$encoding="UTF-8";
	}

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

	# TXJHWIABCFGKLMNPQSU
	my $edition_c ='';
	if ($ed eq "T") {
		$edition_c = "大正新脩大藏經";
	} elsif ($ed eq "X") {
		$edition_c = "卍新纂續藏經";
	}  elsif ($ed eq "J") {
		$edition_c = "嘉興大藏經";
	}  elsif (($ed eq "H") || ($ed eq "ZS")) {
		$edition_c = "正史佛教資料類編";
	}  elsif (($ed eq "W") || ($ed eq "ZW")) {
		$edition_c = "藏外佛教文獻";
	}  elsif ($ed eq "I") {
		$edition_c = "北朝佛教石刻拓片百品";
	}  elsif ($ed eq "A") {
		$edition_c = "金藏";
	}  elsif ($ed eq "B") {
		$edition_c = "大藏經補編";
	}  elsif ($ed eq "C") {
		$edition_c = "中華大藏經";
	}  elsif ($ed eq "D") {
		$edition_c = "國家圖書館善本佛典";
	}  elsif ($ed eq "F") {
		$edition_c = "房山石經";
	}  elsif ($ed eq "G") {
		$edition_c = "佛教大藏經";
	}  elsif ($ed eq "K") {
		$edition_c = "高麗大藏經";
	}  elsif ($ed eq "L") {
		$edition_c = "乾隆大藏經";
	}  elsif ($ed eq "M") {
		$edition_c = "卍正藏經";
	}  elsif ($ed eq "N") {
		$edition_c = "永樂南藏";
	}  elsif ($ed eq "P") {
		$edition_c = "永樂北藏";
	}  elsif ($ed eq "Q") {
		$edition_c = "磧砂大藏經";
	}  elsif ($ed eq "S") {
		$edition_c = "宋藏遺珍";
	}  elsif ($ed eq "U") {
		$edition_c = "洪武南藏";
	} else {
		die;
	}

#$title =~ s/\&(.*?);/$Entities{$1}/g;
	#print STDERR "\nhead.pl 58 cvol=$cvol xa=[$xa] ebib=[$ebib] title=$title\n";
	$sutraHeader =<<"EOD";
【經文資訊】$edition_c 第${cbd}冊 No. $pre_cvol$cvol$xa《${title}》
【版本記錄】CBETA 電子佛典 V${version} ($encoding) $cFormat，完成日期：${date}
【編輯說明】本資料庫由中華電子佛典協會（CBETA）依${edition_c}所編輯
【原始資料】$ly{"chi"}
【其它事項】本資料庫可自由免費流通，詳細內容請參閱\【中華電子佛典協會版權宣告】(http://www.cbeta.org/copyright.htm)
=========================================================================
# $ebib $title
# CBETA Chinese Electronic Tripitaka V${version} ($encoding) $eFormat, Release Date: ${date}
# Distributor: Chinese Buddhist Electronic Text Association (CBETA)
# Source material obtained from: $ly{"eng"}
# Distributed free of charge. For details please read at http://www.cbeta.org/copyright_e.htm
EOD
	$sutraHeader .= "=" x 73;

	if ($opt_p) {	#edith note: 2005/1/19 PDA 版的抬頭資訊
		$short =<< "EOD";
$edition_c
第${cbd}冊 No. $pre_cvol$cvol$xa
《${title}》
CBETA 電子佛典 V${version} $cFormat
EOD
		$short .=  ("=" x 26) . "\n";
	} else {
		$short =<< "EOD";
【經文資訊】$edition_c 第${cbd}冊 No. $pre_cvol$cvol$xa《${title}》CBETA 電子佛典 V${version} $cFormat
# $ebib $title, CBETA Chinese Electronic Tripitaka V${version}, $eFormat
EOD
		$short .= "=" x 73;
	}
	#watch("90|short=[$short]\n");
	return $sutraHeader;
}

sub strip_abc {
	$s = shift;
	if ($s =~ /^(.*)[a-z]$/) {
		$s = $1;
	}
	return $s;
}