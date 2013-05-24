#####################################################
# make_Xnnhtm.pl		2004/07/31
#
# �ϥΤ�k perl make_Xnnhtm.pl [78 [87]]
#
#  perl make_Xnnhtm.pl		�B�z 1-88 �U
#  perl make_Xnnhtm.pl 2 5	�B�z 2-5 �U
#  perl make_Xnnhtm.pl 3	�B�z�� 3 �U
#
# Copyright (C) CBETA, 1998-2007
# Copyright (C) Heaven Chou, 2000-2007
#
# 2006/02/16 �����򤤤j���í��Ъ��g��, �]�@�֥[��ؿ���
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
# �i�諸�Ѽ�
#######################################

# �Ъ`�N�o���ɦ��S����s "d:/cbeta.src/budalist/xuzang.txt";

my $output_path = "d:/cbeta.www/result/";	# ��X���ؿ�
my $sourcefile = "xuzang.txt";	# �g��ӷ��O����
my $updatedate = '2007/02/25';				# �������
#my $losefile = "normal.txt";				# �q�Φr��
#my $ver_date = "ver_date.txt";				# �g�媩���O�� 

# �`�N, ���U�٦������C��n�[

#######################################
#���n�諸�Ѽ�
#######################################

my %table;		#�q�Φr��
my %table2;		#�q�ε���

my $vol;		#�榡�O X78
my $vol_num;	#�榡�O 78
my $key;
my @part;		#�g�峡�O, �ǤJ���O�U��

my %cbpart;
my %part;
my $part;
my %vol;
my %sutra_name;
my %ver;
my %date;
my %juan;
my %author;
my %taisho_vol;		# �j���ê��U
my %taisho_sutra;	# �j���ê��g��

local *OUT;

# my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

#############################################################################
#  �D�{��
#############################################################################

#make_lose_table ($losefile, \%table, \%table2);		#���ͳq�Φr��
readGaiji ();		#���ͳq�Φr��

get_source();   # ���o�g��ӷ���
#get_ver_date();	# ���o�g�媩���P���
get_part();	# ���o���O

for(my $i=$from_vol; $i<=$to_vol; $i++)
{
	$i = 7 if $i == 6;
	$i = 53 if $i == 52;
	
	$vol_num = sprintf("%02d",$i);	#�U�O, �G��Ʀr
	$vol = "X" . $vol_num;
	$part = $part[$vol_num-1];
	
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
	$part[0] = '�L�׼��z�@';
	$part[1] = '�L�׼��z�G';
	$part[2] = '�j�p�����g���@';
	$part[3] = '�j�p�����g���G';
	$part[4] = '�j�p�����g���T';
	$part[5] = '�j�p�����g���|';
	$part[6] = '�j�p�����g����';
	$part[7] = '�j�p�����g����';
	$part[8] = '�j�p�����g���C';
	$part[9] = '�j�p�����g���K';
	$part[10] = '�j�p�����g���E';
	$part[11] = '�j�p�����g���Q';
	$part[12] = '�j�p�����g���Q�@';
	$part[13] = '�j�p�����g���Q�G';
	$part[14] = '�j�p�����g���Q�T';
	$part[15] = '�j�p�����g���Q�|';
	$part[16] = '�j�p�����g���Q��';
	$part[17] = '�j�p�����g���Q��';
	$part[18] = '�j�p�����g���Q�C';
	$part[19] = '�j�p�����g���Q�K';
	$part[20] = '�j�p�����g���Q�E';
	$part[21] = '�j�p�����g���G�Q';
	$part[22] = '�j�p�����g���G�Q�@';
	$part[23] = '�j�p�����g���G�Q�G';
	$part[24] = '�j�p�����g���G�Q�T';
	$part[25] = '�j�p�����g���G�Q�|';
	$part[26] = '�j�p�����g���G�Q��';
	$part[27] = '�j�p�����g���G�Q��';
	$part[28] = '�j�p�����g���G�Q�C';
	$part[29] = '�j�p�����g���G�Q�K';
	$part[30] = '�j�p�����g���G�Q�E';
	$part[31] = '�j�p�����g���T�Q';
	$part[32] = '�j�p�����g���T�Q�@';
	$part[33] = '�j�p�����g���T�Q�G';
	$part[34] = '�j�p�����g���T�Q�T';
	$part[35] = '�j�p�����g���T�Q�|';
	$part[36] = '�j�p�����g���T�Q��';
	$part[37] = '�j�p�����߳��@';
	$part[38] = '�j�p�����߳��G';
	$part[39] = '�j�p�����߳��T';
	$part[40] = '�j�p�����߳��|';
	$part[41] = '�j�p�����߳���';
	$part[42] = '�j�p�����߳���';
	$part[43] = '�j�p�����߳��C';
	$part[44] = '�j�p�����׳��@';
	$part[45] = '�j�p�����׳��G';
	$part[46] = '�j�p�����׳��T';
	$part[47] = '�j�p�����׳��|';
	$part[48] = '�j�p�����׳���';
	$part[49] = '�j�p�����׳���';
	$part[50] = '�j�p�����׳��C';
	$part[51] = '�j�p�����׳��K';
	$part[52] = '�j�p�����׳��E';
	$part[53] = '�ѩv�ۭz���@';
	$part[54] = '�ѩv�ۭz���G';
	$part[55] = '�ѩv�ۭz���T';
	$part[56] = '�ѩv�ۭz���|';
	$part[57] = '�ѩv�ۭz����';
	$part[58] = '�ѩv�ۭz����';
	$part[59] = '�ѩv�ۭz���C';
	$part[60] = '�ѩv�ۭz���K';
	$part[61] = '�ѩv�ۭz���E';
	$part[62] = '�ѩv�ۭz���Q';
	$part[63] = '�ѩv�ۭz���Q�@';
	$part[64] = '�ѩv�ۭz���Q�G';
	$part[65] = '�ѩv�ۭz���Q�T';
	$part[66] = '�ѩv�ۭz���Q�|';
	$part[67] = '�ѩv�ۭz���Q��';
	$part[68] = '�ѩv�ۭz���Q��';
	$part[69] = '�ѩv�ۭz���Q�C';
	$part[70] = '�ѩv�ۭz���Q�K';
	$part[71] = '�ѩv�ۭz���Q�E';
	$part[72] = '�ѩv�ۭz���G�Q';
	$part[73] = '§�b��';
	$part[74] = '�v�ǳ��@';
	$part[75] = '�v�ǳ��G';
	$part[76] = '�v�ǳ��T';
	$part[77] = '�v�ǳ��|';
	$part[78] = '�v�ǳ���';
	$part[79] = '�v�ǳ���';
	$part[80] = '�v�ǳ��C';
	$part[81] = '�v�ǳ��K';
	$part[82] = '�v�ǳ��E';
	$part[83] = '�v�ǳ��Q';
	$part[84] = '�v�ǳ��Q�@';
	$part[85] = '�v�ǳ��Q�G';
	$part[86] = '�v�ǳ��Q�T';
	$part[87] = '�v�ǳ��Q�|';
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
<title>CBETA �Ʀ��øg�� $part $vol</title>
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA �Ʀ��øg�� �����ú~��q�l��� $part $vol">
<meta name="keywords" content="$vol, $part, CBETA, ���عq�l����|, �Ʀ��øg��, �j����, ������, �j�øg, �~��q�l���, �~����, ���q�l��, �q�l���, ���, ��g, ���, ��k, ��иg��, �T��, �g��, �����l, ����, �s�`�C, �i�`�C, �i��, �s��, ����, ���s�F�i, ���i�F�i, �k�_, �F�i, Tripitaka, Pitaka, Taisho, Xuzangjing, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
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
        <td bgcolor="#F9F1DF"><font size="4">��$cvol�U $part</font></td>
      </tr>
      </table>
      </td></tr></table>
      
      <p>
      <table align="center" border="1" cellpadding="6" cellspacing="0" width="90%"  bordercolor="#E1E9CB">
      <tr> 
        <td align="center" bgcolor="#FAE7A3" nowrap>CBETA�g��<br>�����ó��O</td>
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

	my $my_vol = $vol;
	my $taisho_data = "";
	
	if($taisho_vol{$key})		# ���g�b�j���ä���
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

			# �o�O�ª� 
			# �v�ǳ���  �v�ǳ��@  X1553_78_p0420          31  �Ѹt�s�O��    �i�� �����[��*�O]�s�j
			# /^\s*(\S*)\s*(\S*)\s*X(.{5})(\d\d).*?\s+(\d*)\s+(.*?)\s+(�i.*�j)/;
		
			# �s�����[�J�j���������
			# ���Y����   ���Y��  X0001_01_p0001 xx_xxxxx 1  ��ı�g�H��   �i�j
		
			#/^\s*(\S*)\s+(\S*)\s+X(.{5})(\d\d).*?\s+(\S*)\s+(\d*)\s+(.*?)\s+(�i.*�j)/;
			/^\s*(\S*)\s+(\S*)\s+X(.{5})(\d\d).*?\s+(\S*)\s+(\d*)\s+(.*?)\s+(�i.*�j)/;
			
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
				$sutra_name = cut_note($sutra_name);	#�h���������A��
			}
		
			$sutra_num =~ s/\-/_/;
			my $key = "X$sutra_vol" . $sutra_num;	# �]�� 567 �T�U�|�ۦP, �ҥH�n�[�W vol

			$cbpart{$key} = $cbpart;
			$part{$key} = $part1;
			$vol{$key} = "X$sutra_vol";
			$sutra_name{$key} = lose2normal ($sutra_name, \%table, \%table2);
			$juan{$key} = $juan;
			$author{$key} = lose2normal ($author, \%table, \%table2);
			
			if($taisho_data =~ /(\d\d)_(\d\d\d\d.?)/)
			{
				$taisho_vol{$key} = "T$1";		# �j���ê��U
				$taisho_sutra{$key} = $2;	# �j���ê��g��
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
# ���ͳq�Φr��, �ϥ� ODBC ��Ʈw
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
	local $_ = shift;		# �ǤJ�n������
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