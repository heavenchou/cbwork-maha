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
# 	$cbd =~ s/10/�Q/;
 	$cbd =~ s/0//;
 	$cbd =~ s/^1/�Q/g;
	$cbd =~ s/^2/�G�Q/;
	$cbd =~ s/^3/�T�Q/;
	$cbd =~ s/^4/�|�Q/;
	$cbd =~ s/^5/���Q/;
	$cbd =~ s/^6/���Q/;
	$cbd =~ s/^7/�C�Q/;
	$cbd =~ s/^8/�K�Q/;
	$cbd =~ s/^9/�E�Q/;
#	$cbd =~ s/0/��/g;
 	$cbd =~ s/1/�@/g;
	$cbd =~ s/2/�G/g;
	$cbd =~ s/3/�T/g;
	$cbd =~ s/4/�|/g;
	$cbd =~ s/5/��/g;
	$cbd =~ s/6/��/g;
	$cbd =~ s/7/�C/g;
	$cbd =~ s/8/�K/g;
	$cbd =~ s/9/�E/g;
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
<title>�j���s��j�øg ��${cbd}�U No. $cvol$xa�m${title}�n</title>
</head>
<body>
<pre>
�i�g���T�j�j���s��j�øg ��${cbd}�U No. $cvol$xa�m${title}�n
�i�����O���jCBETA �q�l��� $cfg{"CVER"} (Big5) ���Ϊ��A��������G$date
�i�s�軡���j����Ʈw�Ѥ��عq�l����|�]CBETA�^�̤j���s��j�øg�ҽs��
�i��l��ơj$ly{"zh"}
�i�䥦�ƶ��j����Ʈw�i�ۥѧK�O�y�q�A�ԲӤ��e�аѾ\\�i<a href="http://www.cbeta.org/copyright.htm">���عq�l����|���v�ŧi</a>�j

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
<title>�j���s��j�øg ��${cbd}�U No. $cvol$xa�m${title}�n</title>
</head>
<body>
<pre>
�i�g���T�j�j���s��j�øg ��${cbd}�U No. $cvol$xa�m${title}�nCBETA �q�l��� $cfg{"CVER"}���Ϊ�
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
<title>�j���s��j�øg ��${cbd}�U No. $cvol$xa�m${title}�n</title>
</head>
<body>

T$ebd  No. $cvol$xa�m${title}�nCBETA �q�l��� $cfg{"CVER"}���Ϊ�
CBETA Chinese Electronic Tripitaka Normal-Format
<hr>
</body></html>
EOD


}

1;
