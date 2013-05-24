#called from CBETA output programs. 
#provided the HEADER information

sub head {
	local ($fn) = $fh;
	$fn =~ s/.*\\//;
	$ebib =~ s/^\t+//;
	$ebib =~ s/\&desc;//i;
	if ($ebib =~ /Vol\.\s+([0-9]+),\s+No\.\s+([0-9]+)([A-Za-z])?/){
		$cbd = $1;
		$cvol= $2;
		$xa = $3;
	}
	$ebd = $cbd;
# 	$cbd =~ s/10/十/;
 	$cbd =~ s/0//;
 	$cbd =~ s/^1/十/g;
	$cbd =~ s/^2/二十/;
	$cbd =~ s/^3/三十/;
	$cbd =~ s/^4/四十/;
	$cbd =~ s/^5/五十/;
	$cbd =~ s/^6/六十/;
	$cbd =~ s/^7/七十/;
	$cbd =~ s/^8/八十/;
	$cbd =~ s/^9/九十/;
#	$cbd =~ s/0/○/g;
 	$cbd =~ s/1/一/g;
	$cbd =~ s/2/二/g;
	$cbd =~ s/3/三/g;
	$cbd =~ s/4/四/g;
	$cbd =~ s/5/五/g;
	$cbd =~ s/6/六/g;
	$cbd =~ s/7/七/g;
	$cbd =~ s/8/八/g;
	$cbd =~ s/9/九/g;
	$title =~ s/T.* //;
	$title =~ s/\t+//g;
#	$title =~ s/^\n//g;
	$title =~ s/^\x0d//g;
	$title =~ s/^\x0a//g;
	
#$title =~ s/\&(.*?);/$Entities{$1}/g;
#	print STDERR "\nXX  ", ord(substr($title, 0, 1)) , "\nXX${title}XX\n";
	print <<"EOD";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<script FOR="window" EVENT="onload">
	if (parent.head) {
		parent.head.location="$fn";
	}
</script>

<script LANGUAGE="JAVASCRIPT">
<!--
function showpic(name)
{window.open(name,"pic","width=30,height=25,scrollbars,resizable");}
//-->
</script>

<style>
  P {line-height: 1.5}
	.juan {color:green; font-weight:bold}
	.byline {color:#000080}
	.corr {color:red}
	.FuWen {font-style:normal}
</style>
<title>大正新脩大藏經 第${cbd}冊 No. $cvol$xa《${title}》</title>
</head>
<body>
<pre>
【經文資訊】大正新脩大藏經 第${cbd}冊 No. $cvol$xa《${title}》
【版本記錄】CBETA 電子佛典 $cfg{"CVER"} (Big5) 普及版，完成日期：$date
【編輯說明】本資料庫由中華電子佛典協會（CBETA）依大正新脩大藏經所編輯
【原始資料】$ly{"zh"}
【其它事項】本資料庫可自由免費流通，詳細內容請參閱\【<a href="http://www.cbeta.org/copyright.htm">中華電子佛典協會版權宣告</a>】

=========================================================================
# $ebib $title
# CBETA Chinese Electronic Tripitaka $cfg{"EVER"} (Big5) Normalized Version, Release Date: $date
# Distributor: Chinese Buddhist Electronic Text Association (CBETA)
# Source material obtained from: $ly{"en"}
# Distributed free of charge. For details please refer to <a href="http://www.cbeta.org/copyright_e.htm">The Copyright of CBETA DATABASE</a>
</pre><hr>
<a name="start">
EOD

#print "=========================================================================";


$short =<< "EOD";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<script FOR="window" EVENT="onload">
	if (parent.head) {
		parent.head.location="$fn";
	}
</script>

<script LANGUAGE="JAVASCRIPT">
<!--
function showpic(name)
{window.open(name,"pic","width=30,height=25,scrollbars,resizable");}
//-->
</script>

<style>
	.juan {color:green; font-weigth:bold}
	.byline {color:blue}
	.corr {color:red}
</style>
<title>大正新脩大藏經 第${cbd}冊 No. $cvol$xa《${title}》</title>
</head>
<body>
<pre>
【經文資訊】大正新脩大藏經 第${cbd}冊 No. $cvol$xa《${title}》CBETA 電子佛典 $cfg{"CVER"}普及版
# $ebib $title, CBETA Chinese Electronic Tripitaka $cfg{"EVER"}, Normal-Format
</pre><hr>
<a name="start">
EOD
#$short .=  "=========================================================================";


$fhed =<< "EOD";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<style>
  P {line-height: 1.5}
	.juan {color:green; font-weight:bold}
	.byline {color:#000080}
	.corr {color:red}
	.FuWen {font-style:normal}
</style>
<title>大正新脩大藏經 第${cbd}冊 No. $cvol$xa《${title}》</title>
</head>
<body>

T$ebd  No. $cvol$xa《${title}》CBETA 電子佛典 $cfg{"CVER"}普及版
CBETA Chinese Electronic Tripitaka Normal-Format
<hr>
</body></html>
EOD


}

1;
