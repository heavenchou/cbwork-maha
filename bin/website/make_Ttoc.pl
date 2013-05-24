#######################################################################
# maketoc.pl				2001/08/05
#
# �ϥΤ�k perl maketoc.pl [1 [56]]
#
#  perl maketoc.pl	�B�z 1-55, �� 85 �U
#  perl maketoc.pl 2 5	�B�z 2-5 �U
#  perl maketoc.pl 3	�B�z�� 3 �U
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
	$to_vol = 85;
}
elsif ($from_vol ne "" and $to_vol eq "")	# �u���Ĥ@�ӰѼ�
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
#�i�ק�Ѽ�
#######################################

#my $ver_date = "ver_date.txt";		# �����P������O����
my $outpath = "d:/cbeta.www/result/";	# ��X���ؿ�
my $updatedate = '2007/02/25';				# �������
my $sourcepath = "c:/cbwork/simple";	# source.txt ���ؿ�

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
my %source;		    #��U�g�W�Ψӷ�, �� $source{"0310_"} = "SKB";
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;

local *OUT;

########################################################################
#  �D�{��
########################################################################

#make_lose_table ($losefile, \%table, \%table2);		#���ͳq�Φr��
readGaiji();
#get_ver_date();	# ���o�g�媩���P���

mkdir ("$outpath") if (not -d "$outpath");

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 85 if $i == 56;
	
	$vol_num = sprintf("%02d",$i);	#�U�O, �G��Ʀr
	$vol = "T" . $vol_num;
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
<meta name="description" content="CBETA �j���ú~��q�l��� $vol No. $sutra_num �m$sutra_name�n">
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
<li>�i�g���T�j�j���s��j�øg��$vol_c�U No. $sutra_num�m$sutra_name�n
<li>�i�����O���jCBETA �q�l��� Big5 App ���A�̪��s����G$updatedate
<li>�i�s�軡���j����Ʈw�Ѥ��عq�l����|�]CBETA�^�̤j���s��j�øg�ҽs��
<li>�i��l��ơj$from_c
<li>�i��L�ƶ��j����Ʈw�i�ۥѧK�O�y�q�A�ԲӤ��e�аѾ\\�i<a href="/copyright.htm" target="_blank">���عq�l����|��Ʈw���v�ŧi</a>�j
</ul>
<ul>
<li> Taisho Tripitaka Vol. $vol, No. $sutra_num $sutra_name
<li> CBETA Chinese Electronic Tripitaka Big5 App Version, Release Date:$updatedate
<li> Distributor: Chinese Buddhist Electronic Text Association (CBETA)
<li> Source material obtained from: $from_e
<li> Distributed free of charge. For details please read at <a href="/copyright_e.htm" target="_blank">The Copyright of CBETA DATABASE</a>
</ul>

<hr>
<center><h3>�ؿ�  Contents</h3>
<table border="1" cellpadding="4" cellspacing="0" bordercolor="#9BB4C6">
<tr bgcolor="#FAE7A3">
        <td align="center" valign="top"><font color="#990000"><strong>���Ϊ� (����)<br>
        </strong><font face="Times New Roman"><strong>Normalized Format Ver.</strong></font></font></td>
</tr>
HTML

#�����L�F

for(my $i=1; $i<=$juan{$key}; $i++)
{
	my $j = $i;
	
	#�B�z�S����
	
	if($vol eq "T06") { $j = $i + 200;}
	if($vol eq "T07") { $j = $i + 400;}
    #if(($vol eq "T19") and ($key eq "0946_") and ($i > 2))
	#{
	#	$j = $i+1;
    #}
	
	my $fulljuan = sprintf("$key%03d", $j);
	
	if($vol eq "T19"){
		# T19, 0946 �ʲ� 3 ��
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
		elsif (/^(.*?)\sT(.{5})(\d\d).*?\s+.*?\s+.*?\s+(.*?)\s+(.*?)\s+()/)
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