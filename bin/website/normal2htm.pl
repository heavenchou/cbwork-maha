#!/usr/local/bin/perl
#########################################
# �N normal/app �������ন html ��
#########################################

#######################################
#�i�ק�Ѽ�
#######################################

$TX = "X";	# �j���å� "T" , �����å� "X"

$from_vol = 1;		# �_�l�U��
$to_vol = 88;		# �פ�U��

$run_x2r = 1;		# 1: �n, 0: ���O, �O�_�n�B�z������X���ഫR�����ʧ@
$run_x2r = 0 if($TX eq "T");

$out_path = "d:/cbeta.www/result/normal/";	# ��X�ؿ�
$source_path = "c:/release/app/";			# ��l�g��ӷ�
$sutra_url = "/result/normal/";
$XtoRPath = "c:/cbwork/common/X2R/";		# ������ X to R ���� js �ؿ�

#�Ъ`�N�o���ɦ��S����s "taisho.txt";
#�Ъ`�N�o���ɦ��S����s "xuzang.txt";

#######################################
# �D�{��
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

# Ū���������

open IN, $budalist || die "open $budalist fail!";
while(<IN>)
{
	next if /^#/;
	#�v�ǳ���     �v�ǳ��|      X1553_78_p0420          31  �Ѹt�s�O��   �i�� �����[��*�O]�s�j
	#���Y����     ���Y��        X0001_01_p0001 xx_xxxxx  1  ��ı�g�H��                               �i�j
	#���t����     ���t���W      T0002-01-p0150 K1182-34  1  �C��g(1��)  �i�� �k��Ķ�j
	
	/^\s*(\S*)\s*(\S*)\s*${TX}(.{5})/;
	my $id = $3;
	my $part=$2;
	my $cbpart=$1;

	$id =~ s/[\-\_]//;
	$id = lc($id);
	$part{$id}=$part;
	$cbpart{$id}=$cbpart;
	
	#�������򳡤@, ���G, ����....
	
	$part{$id} =~ s/��.*$/��/;
}
close IN;


# �U�U�ǳƤu�@
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
	    	# X63n1217_p0001a02��R110_pxxxxxxx
            # X63n1217_p0001a03��R110_p0807a01
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

	$txt[0] =~ /(N\o\..*�n)/;
	$title = $1;
	
	$outfile =~ /(.{5})0*(\d*)\.htm/;
	$jingnum = $1;
	$juannum = $2;
	
	open OUT, ">$outfile";

print OUT << "HEAD";
<html>
<head>
<title>CBETA ${vol} ${title}��${juannum}</title>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta name="GENERATOR" content="Perl by Heaven">
<meta name="description" content="CBETA �Ʀ��øg�պ~��q�l��� ${title} ��${juannum}">
<meta name="keywords" content="${title}, CBETA, ���عq�l����|, �Ʀ��øg��, �j����, ������, �j�øg, �~��q�l���, �~����, ���q�l��, �q�l���, ���, ��g, ���, ��k, ��иg��, �T��, �g��, �����l, ����, �s�`�C, �i�`�C, �i��, �s��, ����, ���s�F�i, ���i�F�i, �k�_, �F�i, Tripitaka, Pitaka, Taisho, Xuzangjing, Zokuzokyo, Canon, Sutra, Buddhist, Buddhism, Vinaya, Abhidharma, Abhidhamma, Abhidarma, Dhamma, Bible">
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

	$button = "<input type=submit onClick=\"ShowXLineHead('X');\" value=\"�sġ���歺(X��)\">\n<input type=submit onClick=\"ShowXLineHead('R');\" value=\"�s���׼v�L���歺(R��)\">\n<input type=submit onClick=\"ShowXLineHead('RX');\" value=\"R���歺�A���O�dX���S�������\">";

	if($txt[5] =~ /^===/)		#if($juannum == 1) �Ψ��P�_���ɤ���
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
		$txt[4] = "�i��L�ƶ��j����Ʈw�i�ۥѧK�O�y�q�A�ԲӤ��e�аѾ\\�i<a href=\"http://www.cbeta.org/copyright.htm\" target=\"_blank\">���عq�l����|���v�ŧi</a>�j\n";
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
	
	#�W�@���U�@�������
	
	print OUT "<p>";	
	writemenu($prefile, $file, $nextfile);
	
	# �[�J CBETA �g��
	
	$jingnum =~ s/_//;
	
	$part = "�e$part{$jingnum}�f";
	$cbpart = "�e$cbpart{$jingnum}�f";
	$cbpart =~ s/,/�f�e/g;

	print OUT "<hr>�i�g�������j${cbpart}${part}<br>\n";

	# �L�X�g�夺�e

	foreach $_ (@txt)
	{
		s/\x0d//g;
		chomp;
		
		if($run_x2r)
		{
			if(/^X..n.....p(.{7}).*?��(.*)/)
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
						s/^(X..n.....p.{7}.*?��.*)/<span id=head X="$1<br>" R=""><\/span>\n/;
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

	#�W�@���U�@�������

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

	# �P�_�W�@�����S���s��

	if ($pre1 eq $this1)		#�P�@�g
	{
		$prejuan1 = "<a href=\"${sutra_url}${vol}/${pre1}${pre2}.htm\">";
		$prejuan2 = "</a>";
	}
	else
	{
		$prejuan1 = "";
		$prejuan2 = "";
	}

	# �P�_�U�@�����S���s��
	
	if ($next1 eq $this1)		#�P�@�g
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
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10"><a href="/index.htm">�j�øg�ؿ�</a></td>
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10"><a href="/result/${vol}/${vol}n${this3}.htm">���g�ؿ�</a></td>
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10">${prejuan1}�W�@��${prejuan2}</td>
    <td width="25%" class="text" align="center"><img src="/img/grid.gif" width="10" height="10">${nextjuan1}�U�@��${nextjuan2}</td>
  </tr>
</table>
MENU

}