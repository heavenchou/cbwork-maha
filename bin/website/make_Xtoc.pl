#######################################################################
# makeXtoc.pl				2004/07/31
#
# �ϥΤ�k perl maketoc.pl [78 [87]]
#
#  perl makeXtoc.pl	�B�z 63-73 �U
#  perl makeXtoc.pl 78 81 �B�z 78-81 �U
#  perl makeXtoc.pl 78 �B�z�� 78 �U
#
# Copyright (C) CBETA, 1998-2007
# Copyright (C) Heaven Chou, 1999-2007
#######################################################################

use strict;
use Win32::ODBC;

#######################################
# �ǤJ���Ѽ�
#######################################

my $from_vol = shift;
my $to_vol = shift;

if($from_vol eq "" and $to_vol eq "")
{
	$from_vol = 1;
	$to_vol = 88;
}
elsif ($from_vol ne "" and $to_vol eq "")	# �u���Ĥ@�ӰѼ�
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
#�i�ק�Ѽ�
#######################################

#my $ver_date = "ver_date.txt";		# �����P������O����
my $outpath = "d:/cbeta.www/result/";	# ��X���ؿ�
my $updatedate = '2007/02/25';			# �������
my $sourcepath = "c:/cbwork/simple";	# source.txt ���ؿ�

##### �`�N : �Y���S����Τ��s����A�n�b���U�B�z�C

#######################################
#���n�諸�Ѽ�
#######################################

my %table;		#�q�Φr��
my %table2;		#�q�ε���

my $vol;		#�榡�O T01
my $vol_num;	#�榡�O 01
my $key;

my %source_sign_e;	#��^��W��, �� $source_sing_e{"S"} = "Text as provided by Mister Hsiao Chen-kuo"
my %source_sign_c;	#�񤤤�W��, �� $source_sing_c{"S"} = "�����j�w"
my %source;			#��U�g�W�Ψӷ�, �� $source{"0310_"} = "SKB";
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;

local *OUT;

########################################################################
#  �D�{��
########################################################################

readGaiji();		#���ͳq�Φr��
#make_lose_table ($losefile, \%table, \%table2);		#���ͳq�Φr��
#get_ver_date();	# ���o�g�媩���P���

mkdir ("$outpath") if (not -d "$outpath");

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 7 if $i == 6;
	$i = 53 if $i == 52;
	
	$vol_num = sprintf("%02d",$i);	#�U�O, �G��Ʀr
	$vol = "X" . $vol_num;
	print "$vol...";
	
	my $sourcefile = "$sourcepath/$vol/source.txt";     #�g��ӷ��O����
	%vol = ();				# ���k�s
	get_source($sourcefile);   		# ���o���U�g��ӷ���

	foreach $key (sort keys(%vol))		# ���e���k�s�F
	{
		my $sutra_num = $key;
		$sutra_num =~ s/0*([^_]*)_*/$1/;	# �¼Ʀr����
	
		mkdir ("${outpath}$vol","0777") if (not -d "${outpath}$vol");
	
		# ���o�ɦW
		
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
# ���g�Ĥ@��, �L��Ʀh��������T
# �ǤJ�Ѽ� 1 ��ܦL����������T, 2 ��ܦL�u��������T
##########################################################

sub print_head()
{

my $key = shift;
my $vol_c = get_cnum($vol_num);	#���o�U�Ƥ���Ʀr
my $sutra_num;

$key =~ /0*([^_]*)/;	#���g��
$sutra_num = $1;

my $from = $source{$key};
my $sutra_name = $sutra_name{$key};
my $fromkey="";
my $from_c="";
my $from_e="";

while(length ($from) >0)		# ���o���^�媺�g��ӷ����
{
	$fromkey = substr $from, 0, 1;
	$from = substr $from, 1;
	$from_c .= "$source_sign_c{$fromkey}�A";
	$from_e .= "$source_sign_e{$fromkey}, ";
}

substr ($from_c, -2 , 2) = "";
substr ($from_e, -2 , 2) = "";

#���ժ�, �ҥH���U�������X��
#<li>�i�����O���jCBETA �q�l��� $ver (Big5) �u�W���A��������G$date
#<li> CBETA Chinese Electronic Tripitaka $ver (Big5) Online Version, Release Date: $date

print OUT << "HTML";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>CBETA $vol No. $sutra_num �m$sutra_name�n</title>
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA �����ú~��q�l��� $vol No. $sutra_num �m$sutra_name�n">
<meta name="keywords" content="$vol, �m$sutra_name�n, CBETA, ���عq�l����|, �Ʀ��øg��, �j����, ������, �j�øg, �~��q�l���, �~����, ���q�l��, �q�l���, ���, ��g, ���, ��k, ��иg��, �T��, �g��, �����l, ����, �s�`�C, �i�`�C, �i��, �s��, ����, ���s�F�i, ���i�F�i, �k�_, �F�i, Tripitaka, Pitaka, Taisho, Xuzangjing, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
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
<li>�i�g���T�j�÷sġ���øg ��$vol_c�U No. $sutra_num�m$sutra_name�n
<li>�i�����O���jCBETA �q�l��� Big5 App ���A�̪��s����G$updatedate
<li>�i�s�軡���j����Ʈw�Ѥ��عq�l����|�]CBETA�^���÷sġ���øg�ҽs��
<li>�i��l��ơj$from_c
<li>�i��L�ƶ��j����Ʈw�i�ۥѧK�O�y�q�A�ԲӤ��e�аѾ\\�i<a href="/copyright.htm" target="_blank">���عq�l����|���v�ŧi</a>�j
</ul>
<ul>
<li> �� Xuzangjing Vol. $vol, No. $sutra_num $sutra_name
<li> CBETA Chinese Electronic Tripitaka Big5 App Version, Release Date:$updatedate
<li> Distributor: Chinese Buddhist Electronic Text Association (CBETA)
<li> Source material obtained from: $from_e
<li> Distributed free of charge. For details please read at <a href="/copyright_e.htm" target="_blank">The Copyright of CBETA</a>
</ul>

<hr>
<center><h3>�ؿ�  Contents</h3>
<table border="1" cellpadding="4" cellspacing="0" bordercolor="#9BB4C6">
<tr bgcolor="#FAE7A3">
        <td align="center" valign="top"><font color="#990000"><strong>App �� (����)<br>
        </strong><font face="Times New Roman"><strong>App Format Ver.</strong></font></font></td>
</tr>
HTML

#�����L�F

for(my $i=1; $i<=$juan{$key}; $i++)
{
	my $j = $i;
	
	#�B�z�S����
	if(($vol eq "X03") and ($key eq "0208_") and ($i==1)) 
	{
		# �u����10
		$j = 10;
	}
	if(($vol eq "X03") and ($key eq "0211_") and ($i==1)) 
	{
		# �u����6
		$j = 6;
	}
	if(($vol eq "X03") and ($key eq "0221_") and ($i>5)) 
	{
		# X03n0221.xml �Ѩ� 8~15, ���O 6~13 (�S�� 6,7)
		$j = $i+2;
	}
	if(($vol eq "X07") and ($key eq "0234_")) 
	{
		#X07n0234 ���Y�g���`,(�ʤG�Q�������21~70�B91~100��111~112)
		#01~20,71~90,101~110,113~120 (��ڨ���)
		#01~20,21~40, 41~ 50, 51~ 58 (�y������)
		$j = $i+50 if($i>20);
		$j = $i+60 if($i>40);
		$j = $i+62 if($i>50);
	}
	if(($vol eq "X08") and ($key eq "0235_")) 
	{
		#X08n0235 ���Y�g�ͥȧ��,(�������������),
		$j = $i+1;
	}
	if(($vol eq "X09") and ($key eq "0240_"))
	{
		#X09n0240 �Ѩ� 45 �}�l
		$j = $i+44;
	}
	if(($vol eq "X09") and ($key eq "0244_"))
	{
		#X09n0244 �Ѩ� 2,3 , ���O 1,2 (�S�� 1)
		$j = $i+1;
	}
	if(($vol eq "X17") and ($key eq "0321_"))
	{
		# X17n0321.xml �Ѩ� 1,2,5 ���O 1~3 (�S�� 3,4)
		$j = 5 if($i == 3);
	}
	if(($vol eq "X19") and ($key eq "0345_"))
	{
		# X19n0345.xml �Ѩ� 4,5 ���O 1~2 (�S�� 1~3)
		$j = $i+3;
	}
	if(($vol eq "X21") and ($key eq "0367_"))
	{
		# X21n0367.xml �Ѩ� 4~8 ���O 1~5 (�S�� 1~3)
		$j = $i+3;
	}
	if(($vol eq "X21") and ($key eq "0368_"))
	{
		# X21n0368.xml �Ѩ� 2~4 ���O 1~3 (�S�� 1)
		$j = $i+1;
	}
	if(($vol eq "X24") and ($key eq "0451_"))
	{
		# X24n0451.xml �Ѩ� 1,3~10, ���O 1~9 (�S�� 2)
		$j = $i + 1 if($i > 1);
	}
	if(($vol eq "X26") and ($key eq "0560_"))
	{
		# X26n0560.xml �Ѩ� 2 ���O 1 (�S�� 1)
		$j = $i+1;
	}
	if(($vol eq "X34") and ($key eq "0638_"))
	{
		# X34n0638.xml �Ѩ� 1~21,24~29,31,33~35 , ���O 1~31 (�S�� 22,23,30.32)
		$j = $i + 2 if($i > 21);
		$j = $i + 3 if($i > 27);
		$j = $i + 4 if($i > 29);
	}
	if(($vol eq "X37") and ($key eq "0662_"))
	{
		# X37n0662.xml �Ѩ� 1~14,16~20, ���O 1~19 (�S�� 15)
		$j = $i+1 if($i > 14);
	}
	if(($vol eq "X38") and ($key eq "0687_"))
	{
		# X38n0687.xml �Ѩ� 2,4 , ���O 1,2 (�S�� 1,3)
		$j = 2 if($i == 1);
		$j = 4 if($i == 2);
	}
	if(($vol eq "X39") and ($key eq "0704_"))
	{
		# X39n0704.xml �Ѩ� 3~5, ���O 1~3 (�S�� 1,2)
		$j = $i+2;
	}
	if(($vol eq "X39") and ($key eq "0705_"))
	{
		# X39n0705.xml �Ѩ� 2 ���O 1 (�S�� 1)
		$j = $i+1;
	}
	if(($vol eq "X39") and ($key eq "0712_"))
	{
		# X39n0712.xml �Ѩ� 3 ���O 1 (�S�� 1,2)
		$j = $i+2;
	}
	if(($vol eq "X40") and ($key eq "0714_"))
	{
		# X40n0714.xml �Ѩ� 3,4 ���O 1,2 (�S�� 1,2)
		$j = $i+2;
	}
	if(($vol eq "X42") and ($key eq "0733_"))
	{
		# X42n0733.xml �Ѩ� 2~8,10 ���O 1~8 (�S�� 1,9)
		$j = $i+1;
		$j = 10 if($i == 8);
	}
	if(($vol eq "X42") and ($key eq "0734_"))
	{
		# X42n0734.xml �Ѩ� 9 ���O 1 (�S�� 1~8)
		$j = 9;
	}
	if(($vol eq "X46") and ($key eq "0784_"))
	{
		# X46n0784.xml �Ѩ� 2,5~10 ���O 1~7 (�S�� 1,3,4)
		$j = 2 if($i == 1);
		$j = $i + 3 if($i > 1);
	}
	if(($vol eq "X46") and ($key eq "0791_"))
	{
		# X46n0791.xml �Ѩ� 1,6,14,15,17,21,24 ���O 1~7 (�S�� ...)
		$j = 6 if($i == 2);
		$j = 14 if($i == 3);
		$j = 15 if($i == 4);
		$j = 17 if($i == 5);
		$j = 21 if($i == 6);
		$j = 24 if($i == 7);
	}
	if(($vol eq "X48") and ($key eq "0797_"))
	{
		# X48n0797.xml �Ѩ� 3 ���O 1 (�S�� 1,2)
		$j = 3;
	}
	if(($vol eq "X48") and ($key eq "0799_"))
	{
		# X48n0799.xml �Ѩ� 1,2,7 ���O 1~3 (�S�� 3~6)
		$j = 7 if($i == 3);
	}
	if(($vol eq "X48") and ($key eq "0808_"))
	{
		# X48n0808.xml �Ѩ� 1,5,9,10 ���O 1~4 (�S�� 2,3,4,6,7,8)
		$j = 5 if($i == 2);
		$j = 9 if($i == 3);
		$j = 10 if($i == 4);
	}
	if(($vol eq "X49") and ($key eq "0812_"))
	{
		# X49n0812.xml �Ѩ� 2 ���O 1 (�S�� 1)
		$j = 2;
	}
	if(($vol eq "X49") and ($key eq "0815_"))
	{
		# X49n0815.xml �Ѩ� 1~8,10~13 ���O 1~12 (�S�� 9)
		$j = $i + 1 if($i > 8);
	}
	if(($vol eq "X50") and ($key eq "0817_"))
	{
		# X50n0817.xml �Ѩ� 17 ���O 1 (�S�� 1~16)
		$j = 17;
	}
	if(($vol eq "X50") and ($key eq "0819_"))
	{
		# X50n0819.xml �Ѩ� 1~14,16,18 ���O 1~16 (�S�� 15,17)
		$j = 16 if($i == 15);
		$j = 18 if($i == 16);
	}
	if(($vol eq "X51") and ($key eq "0822_"))
	{
		# X51n0822.xml �Ѩ� 4~10 ���O 1~7 (�S�� 1~3)
		$j = $i+3;
	}
	if(($vol eq "X53") and ($key eq "0836_"))
	{
		# X53n0836.xml �Ѩ� 1,2,4~7,17 ���O 1~7 (�S�� 3,8~16)
		$j = $i+1 if($i > 3);
		$j = 17 if($i == 7);
	}
	if(($vol eq "X53") and ($key eq "0842_"))
	{
		# X53n0842.xml �Ѩ� 29,30 ���O 1,2 (�S�� 1~28)
		$j = 29 if($i == 1);
		$j = 30 if($i == 2);
	}
	if(($vol eq "X53") and ($key eq "0843_"))
	{
		# X53n0843.xml �Ѩ� 9,18 ���O 1,2 (�S�� 1~8,10~17)
		$j = 9 if($i == 1);
		$j = 18 if($i == 2);
	}
	if($vol eq "X55" and $key eq "0882_")
	{
		# �u���� 4,7,10
		$j = 4 if ($i == 1);
		$j = 7 if ($i == 2);
		$j = 8 if ($i == 3);
	}
	if($vol eq "X57" and $key eq "0952_")
	{
		# �u���� 10
		$j = 10 if ($i == 1);
	}
	if($vol eq "X57" and $key eq "0966_")
	{
		# �u���� 2,3,4,5
		$j = $i+1;
	}
	if($vol eq "X57" and $key eq "0967_")
	{
		# �u���� 3,4
		$j = $i+2;
	}
	if($vol eq "X58" and $key eq "1015_")
	{
		# �u���� 14,22
		$j = 14 if ($i == 1);
		$j = 22 if ($i == 2);
	}
	if($vol eq "X72" and $key eq "1435_" and $i>13)
	{
		# X72n1435.xml �Ѩ�1~13,16~35 , ���O 1~13,14~33 (13,14,15 �X�� 13�@��)
		$j = $i+2;
	}
	if($vol eq "X73" and $key eq "1456_" and $i>40)
	{
		# X73n1456.xml �Ѩ�44~55, ���O 41~52 (�S�� 41,42,43)
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
# ���o�g��ӷ��ɸ��
##########################################################

sub get_source()
{
	local *SOURCE;
	my $sourcefile = shift;
	
        # %source_sign_e	��^��W��, �� $source_sing_e{"S"} = "Text as provided by Mister Hsiao Chen-kuo"
        # %source_sign_c	�񤤤�W��, �� $source_sing_c{"S"} = "�����j�w"
        # %source		��U�g�W�Ψӷ�, �� $source{"0310_"} = "SKB";
        # %sutra_name		��g�W, �� $sutra_name{"0310_"} = "�j�_�n�g";
        # %vol			��U�g���U�O, �� $vol{"0310_"} = 11 (�� 11 �U)
        # %sutra_juan		��U�g������, �� $sutra_juan{"0310_"} = 120 (120 ��)

        open SOURCE , "$sourcefile" || die "open $sourcefile error : $!";
        while(<SOURCE>)
        {
                #���ӷ��O��, �榡�p�U
                #S:�����j�w, Text as provided by Mister Hsiao Chen-kuo

                if (/(.)\s*:\s*(.*?)\s*,\s*(.*?)\s*$/)
                {
                        $source_sign_c{"$1"} = "$2";
                        $source_sign_e{"$1"} = "$3";
                }
                #���g�W�Ψӷ�, �榡�p�U
                #SK4    T0310-11-p0001 K0022-06 120 �j�_�n�g(120��)�i�� �д��y��Ķ�}�X�j
                #elsif (/^(.*?)\s+T(.{5})(\d\d).*?\s+.*?\s+(\d*)\s+(.*?)(?:(?:\()|(?:�i))/)
                #APJ    T0220-05-p0001  V1.0   1999/12/10  200  �j��Y�iù�e�h�g    �i�� �ȮNĶ�j                  K0001-01
		elsif (/^(.*?)\sX(.{5})(\d\d).*?\s+.*?\s+.*?\s+(.*?)\s+(.*?)\s+()/)
		{
                        my $from = $1;
                        my $sutra_num = $2;
                        my $sutra_vol = $3;
                        #my $sut_ver = $4;	# �o�̪�����P�������ǤF
                        #my $sut_date = $5;
                        my $juan = $4;
                        my $sutra_name = $5;
                        
			$from =~ s/ //g;
			if ($sutra_name =~ /\)$/)
			{
				$sutra_name = cut_note($sutra_name);	#�h���������A��
			}
			
			$sutra_num =~ s/\-/_/;		# �����зǤ���ƪ��榡

                        $source{$sutra_num} = $from;
                        $vol{$sutra_num} = "T$sutra_vol";
                        $juan{$sutra_num} = $juan;
			$sutra_name{$sutra_num} = lose2normal ($sutra_name, \%table, \%table2);           
                }
        }
        close SOURCE;
}

#############################################################
# ���o����Ʀr
#############################################################

sub get_cnum()		
{
	local $_ = $_[0];

	s/^0*(\d*)/$1/;
	s/10/�Q/;		# 10 ���� �Q
	s/^1(.)/�Q$1/g;		# 1x ���� �Qx
	s/^(\d)(\d)/$1�Q$2/;	# xx ���� x�Qx	
	s/1/�@/g;
	s/2/�G/g;
	s/3/�T/g;
	s/4/�|/g;
	s/5/��/g;
	s/6/��/g;
	s/7/�C/g;
	s/8/�K/g;
	s/9/�E/g;
	s/0//g;
	return ($_);
}

#############################################################
# �h���r��������A��
# �� xxxx(yy) -> xxxx
# �p�� xxxx(yy[(zz)]) -> xxxx
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
# ���o�g�媩���P���
##########################################################

##############################################################################
# ���ͳq�Φr��
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
		$des     = $row{"des"};		# �զr��
		$nor     = $row{"nor"};		# �q�Φr

		if($cb =~ /^x/)		# �q�ε�
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
# �N�Y���ܦ��q�Φr
# �ϥΪk:
#     lose2normal (���, hash �q�Φr������, hash �q�ε�������)
# ��: lose2normal ($line, \%table, \%table2)
##############################################################################

sub lose2normal
{
	local $_ = shift;	# �ǤJ�n������
	my $losetable = shift;	# �ǤJ�q�Φr��
	my $losetable2 = shift;	# �ǤJ�q�ε���
	
	my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x00-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])';

	# ���P�_���S���զr��
	return $_ if ($_ !~ /\[/);

	# ���q�ε�
	s=\Q����[�I/��][�I/��]\E=�ϧϩ���=g;		# ����[�I/��][�I/��]�n����
	foreach my $loseword2 (keys(%$losetable2))
	{
		s/\Q$loseword2\E/$losetable2->{$loseword2}/g;
	}
	
	# ���q�Φr
	
	s/(\[$losebig5*?\])/($losetable->{$1}||$1)/ge;
	
	return $_;
}

###  END  ####################################################