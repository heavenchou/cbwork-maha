#####################################################
# make_Txxhtm.pl		2001/08/05
#
# �ϥΤ�k perl make_Txxhtm.pl [1 [56]]
#
#  perl make_Txxhtm.pl		�B�z 1-55, �� 85 �U
#  perl make_Txxhtm.pl 2 5	�B�z 2-5 �U
#  perl make_Txxhtm.pl 3	�B�z�� 3 �U
#
# Copyright (C) CBETA, 1998-2007
# Copyright (C) Heaven Chou, 2000-2007
#####################################################

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
# �i�諸�Ѽ�
#######################################

my $output_path = "d:/cbeta.www/result/";	#��X���ؿ�
my $losefile = "normal.txt";	#�q�Φr��
my $sourcefile = "taisho.txt";	#�g��ӷ��O����
my $updatedate = '2007/02/25';				# �������
#my $ver_date = "ver_date.txt";		# �g�媩���O�� 

#######################################
#���n�諸�Ѽ�
#######################################

my %table;		#�q�Φr��
my %table2;		#�q�ε���

my $vol;		#�榡�O T01
my $vol_num;	#�榡�O 01
my $key;
my @part;		#�g�峡�O, �ǤJ���O�U��

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
#  �D�{��
#############################################################################

#make_lose_table ($losefile, \%table, \%table2);		#���ͳq�Φr��
readGaiji();

get_source();   # ���o�g��ӷ���
#get_ver_date();	# ���o�g�媩���P���
get_part();	# ���o���O

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 85 if $i == 56;
	
	$vol_num = sprintf("%02d",$i);	#�U�O, �G��Ʀr
	$vol = "T" . $vol_num;
	
	open OUT , ">${output_path}${vol}.htm" || die "open $vol.htm error $!";

	print_head();	# �g�J���Y���Ĥ@�ӳ���
	foreach $key (sort(keys(%vol)))	# �B�z��g
	{
		next if $vol{$key} ne $vol;	# �ư��D���U��
		print_sutra($key);			# �L�X�U�U�S��O��		
	}
	print_tail();	# �L�X�ɧ�
	
	close OUT;
}

##########################################################
# ���o���O
##########################################################

sub get_part()
{
	@part=qw(
		���t���W
		���t���U
		���t���W
		���t���U
		��Y���@
		��Y���G
		��Y���T
		��Y���|
		�k�س����B���Y���W
		���Y���U
		�_�n���W
		�_�n���U�B�I�n����
		�j������
		�g�����@
		�g�����G
		�g�����T
		�g�����|
		�K�г��@
		�K�г��G
		�K�г��T 
		�K�г��|
		�߳��@
		�߳��G
		�߳��T
		���g�׳��W
		���g�׳��U�B�i�賡�@
		�i�賡�G
		�i�賡�T
		�i�賡�|
		���[�����B������W
		������U
		�׶�����
		�g�����@
		�g�����G
		�g�����T
		�g�����|
		�g������
		�g������
		�g�����C
		�߲������B�ײ����@
		�ײ����G
		�ײ����T
		�ײ����|
		�ײ������B�ѩv���@
		�ѩv���G
		�ѩv���T
		�ѩv���|
		�ѩv����
		�v�ǳ��@
		�v�ǳ��G
		�v�ǳ��T
		�v�ǳ��|
		�ƷJ���W
		�ƷJ���U�B�~�г���
		�ؿ�����
	);
	$part[84] = '�j�h�����B�æ�����';
	
	#$part = $part[$vol_num-1];
}

##########################################################
# �L�X���Y
##########################################################

sub print_head()
{
	my $cvol = get_cnum($vol_num);

print OUT << "HEAD1";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>CBETA �Ʀ��øg�� $part[$vol_num-1] $vol</title>
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA �Ʀ��øg�� �j���ú~��q�l��� $part[$vol_num-1] $vol">
<meta name="keywords" content="$vol, $part[$vol_num-1], CBETA, ���عq�l����|, �Ʀ��øg��, �j����, ������, �j�øg, �~��q�l���, �~����, ���q�l��, �q�l���, ���, ��g, ���, ��k, ��иg��, �T��, �g��, �����l, ����, �s�`�C, �i�`�C, �i��, �s��, ����, ���s�F�i, ���i�F�i, �k�_, �F�i, Tripitaka, Pitaka, Taisho, Xuzangjing, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
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
        <td bgcolor="#F9F1DF"><font size="4">��$cvol�U $part[$vol_num-1]</font></td>
      </tr>
      </table>
      </td></tr></table>
      
      <p>
      <table align="center" border="1" cellpadding="6" cellspacing="0" width="90%"  bordercolor="#E1E9CB">
      <tr> 
        <td align="center" bgcolor="#FAE7A3" nowrap>CBETA�g��<br>�j���ó��O</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>�g��</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>�g�W<font color="red">(�\\Ū���I�J)</font></td>
        <!-- <td align="center" bgcolor="#FAE7A3" nowrap>�U��<br>APP��</td> -->
        <!-- <td align="center" bgcolor="#FAE7A3" nowrap>�U��<br>PDF��</td> -->
        <td align="center" bgcolor="#FAE7A3" nowrap>��s���</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>����</td>
        <td align="center" bgcolor="#FAE7A3" nowrap>�¥N Ķ/�@��</td>
      </tr>
HEAD1
}

##########################################################
# �L�X���U�U�g���
##########################################################

sub print_sutra()
{
	my $key = shift;
	my $sutra_num = substr($key,3);
	$sutra_num =~ s/0*([^_]*)_*/$1/;	#�u�d�U�g��

	my $filename_cs = substr($key,3);	# ���j�p�g����
	
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
# �L�X�ɧ�
##########################################################

sub print_tail()
{
print OUT << "TAIL";   
       </table>
<!------------  ���e����   ----------->
    </td>
  </tr>
</table>
<!-----------    ����  ------------>
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
# ���o�g��ӷ��ɸ��
##########################################################

sub get_source()
{
	local *SOURCE;
	local $_;
	
        open SOURCE , "$sourcefile" || die "open $sourcefile error : $!";
        while(<SOURCE>)
        {
        	next if/^#/;

		# ���t����  ���t���W  T0002-01-p0150 K1182-34  1  �C��g(1��)   �i�� �k��Ķ�j
		
		/^\s*(\S*)\s*(\S*)\s*T(.{5})(\d\d).*?\s+.*?\s+(\d*)\s+(.*?)\s+(�i.*�j)/;

		my $cbpart = $1;
		my $part = $2;
        my $sutra_num = $3;
        my $sutra_vol = $4;
        my $juan = $5;
        my $sutra_name = $6;
        my $author = $7;

		if ($sutra_name =~ /\)$/)
		{
			$sutra_name = cut_note($sutra_name);	#�h���������A��
		}
		
		$sutra_num =~ s/\-/_/;
		my $key = "T$sutra_vol" . $sutra_num;	# �]�� 567 �T�U�|�ۦP, �ҥH�n�[�W vol

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
# ���o����Ʀr
#############################################################

sub get_cnum()		
{
	local $_ = $_[0];
	s/^0*//;

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
	local $_ = shift;	    # �ǤJ�n������
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