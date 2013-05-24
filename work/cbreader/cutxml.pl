# $Id: cutxml.pl,v 1.25 2011/03/15 04:44:44 heaven Exp $
# �ϥΤ�k
#
# perl cutxml.pl T01 [T01n0001.xml]
#
# ������ �Ъ`�N, �Y�����s���, �n���B�z���s������
#
# �N XML �����@���@��, �o�O�� getjuanpos.pl �ק�ӨӪ�, 
# �]�N�O�N getjuanpls ����ƥh�զX���@���@��
#
# ��ڪ��@�k : 
# 1. ����X�U <milestone> ����m, ��ԲӪ���m�O���_��, �ðO�U���� lb ���歺��T
# 2. �A parse XML , ��U�������B�� �аO�Y�����O���_��, ��������~��ɤW�������Y��.
# 3. �� <mulu> ���h���]�n�O���_��, �]�����ǽd������ <mulu> �]�n�ɤW�h, �D�n�O���F�ޥνƻs�n���o�~��T
#
# ���U�O�H�e getjuanpos ������
#
# ===============================================================
#
# �� xml ���o�U�g�U������m, �ó�W�s���@��, �H�Q���ֳt���X���
#
# �ɦW:T01n0013.2
# ���e:
# ==================
# 1506
# 19372
# 43944
# <div1 type="jing">
# </body></text></tei.2>
# ================
#
# �]�N�O��ڷQŪ T01n0013 ����2����,
# �|�N�{�ɲ��ͤ@����
# 
# ���{���ɪ����e�O
# 
# T01n0013.xml �e 1506 �Ӧ줸 (�]�N�O�� <text><body> ����)
# �A�[�W
# <div1 type="jing">
# �A�[�W
# T01n0013.xml  �ɮ׵����m 19372 ~ 43944 (�]�N�O�ĤG�������e)
# �A�[�W
# </body></text></tei.2>
# 
# �N�O�@�ӲĤG���� xml �F

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

# ���Ѽ�

require "cutxml_cfg.pl";

local @lines = ();

# ���o�Ҧ� xml ���ɮצW��

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
	my $infile = "$sourcePath/$file";	# �ӷ���
	my $outfile;
	my $filelen;	# xml �ɪ�����
	my $alldata;	# ���ɩҦ������e
	
	my @juan_start = ();
	my @juan_end = ();
	local @lbn = ();
	local @start_tag = ();		# �O���U���}�Y���ӭn�ɤW���аO
	local @end_tag = ();		# �O���U���������ӭn�ɤW���аO
	
	# �U���ؿ��}�Y���B�z�k:
	# �C�@���@�J�� <mulu level="n"> �N�O���b $this_juan_mulu[n] , �ç� n �O��k�b $mulu_n �ܼƤ�
	# �Ө�������, �N�� 1~n ���аO���O���b $mulu_tag[n] ����
	# �Ҧp�Y�@��������, @this_juan_mulu ���e�O ("<mulu level=1 label=�Ĥ@��/>", "<mulu level=2 label=�ĤG��/>")
	# �h $mulu_tag[x] = "<mulu level=1 label=�Ĥ@��/><mulu level=2 label=�ĤG��/>"
	
	local @mulu_tag = ();		# �O���U���}�Y�n�ɤW���O�� , �}�C�O�� 1 �}�l�B�z, 0 ���ޥ�.
	local @this_juan_mulu = ();		# �O���Y�@�����Ҧ� mulu �аO , �}�C�O�� 1 �}�l�B�z, 0 ���ޥ�.
	local $mulu_n = 0;
	
	open (IN, $infile) or die "open $infile error!$!";
	binmode IN;	# �G�i����
	
	seek IN, 0, 2;
	$filelen = tell IN;	# ���o�ɮת���
	seek IN, 0, 0;
	
	read IN, $alldata, $filelen;	#Ū�J�ܼƤ�
	
	##########################################
	# �� xml �e�����j�p (�� <text><body> ����)
	##########################################
	
	my $pos1 = index($alldata, "<body>", 0);
	
	if ($pos1 < 0)			# �䤣��
	{
		print "$infile pos1 = $pos1\n";
		print STDERR "$infile pos1 = $pos1\n";
	}
	
	if(substr ($alldata, $pos1, 8) eq "<body>\x0d\x0a"){
		$pos1 += 8;	# �]�t�G�Ӵ��� 0d 0a
	}
	else{
		$pos1 += 6;
	}
	
	##############################################
	# �n�v���� <milestone �F
	#########################
	
	my $juannum = 0;
	my $milestonepos = -1;
	
	# <lb n="0875b02"/>
	# <milestone unit="juan" n="1"/>
	
	$alldata =~ s/(<milestone)(.*?)( unit=".*?")(.*?>)/$1$3$2$4/g;
	while(($milestonepos = index($alldata, "<milestone unit", 0)) > 0)
	#while(($milestonepos = index($alldata, "<milestone ", 0)) > 0)
	{
		# �b <body ���e�����n, �]���i��O�b���Ѥ�
		
		if($milestonepos < $pos1)
		{
			substr($alldata, $milestonepos, 3) = "<--";	
			next;
		}
		
		# ��� milestone
		
		$juannum++;
		
		# �N <milestone ���� <--lestone, �H�K���Ч��
		substr($alldata, $milestonepos, 3) = "<--";	
		
		if(substr ($alldata, $milestonepos - 19, 3) eq "<lb"){
			$milestonepos -= 19;	# <lb n="0107a16"/>\n<milestone unit="juan" n="17"/>
		} elsif (substr ($alldata, $milestonepos - 17, 3) eq "<lb"){
			$milestonepos -= 17;	# milestone �M lb �����S������
		} elsif (substr ($alldata, $milestonepos - 26, 3) eq "<lb"){
			$milestonepos -= 26;	# <lb ed="X" n="0691a08"/><milestone unit="juan" n="7"/>
		} elsif (substr ($alldata, $milestonepos - 24, 3) eq "<lb"){
			$milestonepos -= 24;	# milestone �M lb �����S������
		} else {
			
			# ��, �٬O�Ĩħ�a!
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

			if($lbpos == 0)		# ��, �u���䤣��F
			{
				print "$juannum Error!";
				print STDERR "$juannum Error!";
				exit 1;
			}
		}

		# �s����, ���X lb �����

		my $lbn = substr ($alldata, $milestonepos, 50);
		$lbn =~ /^.*?n="(\d\d\d\d.\d\d)"/;
		$lbn[$juannum] = $1;

		# <lb ���e�Y�� <pb , �]�@�֦Y�U��
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
	# �n paser xml �F
	#
	##################

	ParserXML($file);

	##############################################
	# copy ent ��
	#########################
	
	$entfile = $file;
	$entfile =~ s/\.xml/\.ent/;
	
	copy("$sourcePath/$entfile", "$outPath/$entfile");
	
	################################################
	#
	# ��X���G
	#
	##################

	print STDERR "juannum=$juannum\n";
	for($i=1; $i<= $juannum; $i++)
	{
		my $ii = sprintf("%03d",$i);
		
		#�B�z�S���ɦW ###########################################
		
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
		#T19n0946.xml �S���ĤT��, �u�� 1, 2, 4, 5 ��
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
		#�B�z�S����
		
		# X03n0208.xml �u����10
		if($file eq "X03n0208.xml")
		{
			$ii = "010" if($i==1);
		}
		# X03n0211.xml �u����6
		if($file eq "X03n0211.xml")
		{
			$ii = "006" if($i==1);
		}
		# X03n0221.xml �Ѩ� 1~5,8~15, ���O 6~13 (�S�� 6,7)
		if($file eq "X03n0221.xml")
		{
			$ii = sprintf("%03d",$i+2) if($i>5);
		}
		#X07n0234.xml ���Y�g���`,(�ʤG�Q�������21~70�B91~100��111~112)
		#01~20,71~90,101~110,113~120 (��ڨ���)
		#01~20,21~40, 41~ 50, 51~ 58 (�y������)
		if($file eq "X07n0234.xml")
		{
			$ii = sprintf("%03d",$i+50) if($i>20);
			$ii = sprintf("%03d",$i+60) if($i>40);
			$ii = sprintf("%03d",$i+62) if($i>50);
		}
		# X08n0235.xml ���Y�g�ͥȧ��,(�������������),
		if($file eq "X08n0235.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X09n0240 �Ѩ� 45 �}�l
		if($file eq "X09n0240.xml")
		{
			$ii = sprintf("%03d",$i+44);
		}
		# X09n0244 �ѬO 2,3 , �S����1
		if($file eq "X09n0244.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X17n0321.xml �Ѩ� 1,2,5 ���O 1~3 (�S�� 3,4)
		if($file eq "X17n0321.xml")
		{
			$ii = "005" if($i == 3);
		}
		# X19n0345.xml �Ѩ� 4,5 ���O 1~2 (�S�� 1~3)
		if($file eq "X19n0345.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X21n0367.xml �Ѩ� 4~8 ���O 1~5 (�S�� 1~3)
		if($file eq "X21n0367.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X21n0368.xml �Ѩ� 2~4 ���O 1~3 (�S�� 1)
		if($file eq "X21n0368.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X24n0451.xml �Ѩ� 1,3~10, ���O 1~9 (�S�� 2)
		if($file eq "X24n0451.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 1);
		}
		# X26n0560.xml �u���� 2 ���O 1 (�S�� 1)
		if($file eq "X26n0560.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X34n0638.xml �Ѩ� 1~21,24~29,31,33~35 , ���O 1~31 (�S�� 22,23,30.32)
		if($file eq "X34n0638.xml")
		{
			$ii = sprintf("%03d",$i+2) if($i > 21);
			$ii = sprintf("%03d",$i+3) if($i > 27);
			$ii = sprintf("%03d",$i+4) if($i > 28);
		}
		# X37n0662.xml �Ѩ� 1~14,16~20, ���O 1~19 (�S�� 15)
		if($file eq "X37n0662.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 14);
		}
		# X38n0687.xml �Ѩ� 2,4 , ���O 1,2 (�S�� 1,3)
		if($file eq "X38n0687.xml")
		{
			$ii = "002" if($i == 1);
			$ii = "004" if($i == 2);
		}
		# X39n0704.xml �Ѩ� 3~5, ���O 1~3 (�S�� 1,2)
		if($file eq "X39n0704.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X39n0705.xml �Ѩ� 2 ���O 1 (�S�� 1)
		if($file eq "X39n0705.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X39n0712.xml �Ѩ� 3 ���O 1 (�S�� 1,2)
		if($file eq "X39n0712.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X40n0714.xml �Ѩ� 3,4 ���O 1,2 (�S�� 1,2)
		if($file eq "X40n0714.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X42n0733.xml �Ѩ� 2~8,10 ���O 1~8 (�S�� 1,9)
		if($file eq "X42n0733.xml")
		{
			$ii = sprintf("%03d",$i+1);
			$ii = "010" if($i == 8);
		}
		# X42n0734.xml �Ѩ� 9 ���O 1 (�S�� 1~8)
		if($file eq "X42n0734.xml")
		{
			$ii = "009";
		}
		# X46n0784.xml �Ѩ� 2,5~10 ���O 1~7 (�S�� 1,3,4)
		if($file eq "X46n0784.xml")
		{
			$ii = "002" if($i == 1);
			$ii = sprintf("%03d",$i+3) if($i > 1);
		}
		# X46n0791.xml �Ѩ� 1,6,14,15,17,21,24 ���O 1~7 (�S�� ...)
		if($file eq "X46n0791.xml")
		{
			$ii = "006" if($i == 2);
			$ii = "014" if($i == 3);
			$ii = "015" if($i == 4);
			$ii = "017" if($i == 5);
			$ii = "021" if($i == 6);
			$ii = "024" if($i == 7);
		}
		# X48n0797.xml �Ѩ� 3 ���O 1 (�S�� 1,2)
		if($file eq "X48n0797.xml")
		{
			$ii = "003";
		}
		# X48n0799.xml �Ѩ� 1,2,7 ���O 1~3 (�S�� 3~6)
		if($file eq "X48n0799.xml")
		{
			$ii = "007" if($i == 3);
		}
		# X48n0808.xml �Ѩ� 1,5,9,10 ���O 1~4 (�S�� 2,3,4,6,7,8)
		if($file eq "X48n0808.xml")
		{
			$ii = "005" if($i == 2);
			$ii = "009" if($i == 3);
			$ii = "010" if($i == 4);
		}
		# X49n0812.xml �Ѩ� 2 ���O 1 (�S�� 1)
		if($file eq "X49n0812.xml")
		{
			$ii = "002";
		}
		# X49n0815.xml �Ѩ� 1~8,10~13 ���O 1~12 (�S�� 9)
		if($file eq "X49n0815.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 8);
		}
		# X50n0817.xml �Ѩ� 17 ���O 1 (�S�� 1~16)
		if($file eq "X50n0817.xml")
		{
			$ii = "017";
		}
		# X50n0819.xml �Ѩ� 1~14,16,18 ���O 1~16 (�S�� 15,17)
		if($file eq "X50n0819.xml")
		{
			$ii = "016" if($i == 15);
			$ii = "018" if($i == 16);
		}
		# X51n0822.xml �Ѩ� 4~10 ���O 1~7 (�S�� 1~3)
		if($file eq "X51n0822.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X53n0836.xml �Ѩ� 1,2,4~7,17 ���O 1~7 (�S�� 3,8~16)
		if($file eq "X53n0836.xml")
		{
			$ii = sprintf("%03d",$i+1) if($i > 2);
			$ii = "017" if($i == 7);
		}
		# X53n0842.xml �Ѩ� 29,30 ���O 1,2 (�S�� 1~28)
		if($file eq "X53n0842.xml")
		{
			$ii = "029" if($i == 1);
			$ii = "030" if($i == 2);
		}
		# X53n0843.xml �Ѩ� 9,18 ���O 1,2 (�S�� 1~8,10~17)
		if($file eq "X53n0843.xml")
		{
			$ii = "009" if($i == 1);
			$ii = "018" if($i == 2);
		} 
		# X55n0882.xml ���T��, ���O�� 4,7,8
		if($file eq "X55n0882.xml")
		{
			$ii = "004" if($i == 1);
			$ii = "007" if($i == 2);
			$ii = "008" if($i == 3);
		} 
		# X57n0952.xml �u���� 10
		if($file eq "X57n0952.xml")
		{
			$ii = "010" if($i == 1);
		} 
		# X57n0966.xml �Ѩ� 2 �}�l (2,3,4,5)
		if($file eq "X57n0966.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# X57n0967.xml �Ѩ� 3 �}�l (3,4)
		if($file eq "X57n0967.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X58n1015.xml �u���G��, ���O�� 14,22
		if($file eq "X58n1015.xml")
		{
			$ii = "014" if($i == 1);
			$ii = "022" if($i == 2);
		}
		# X72n1435.xml �Ѩ�13 ���ۨ� 16
		if($file eq "X72n1435.xml" and $i > 13)
		{
			$ii = sprintf("%03d",$i+2);
		}
		# X73n1456.xml �Ѩ�44~55, ���O 41~52 (�S�� 41,42,43)
		if($file eq "X73n1456.xml" and $i > 40)
		{
			$ii = sprintf("%03d",$i+3);
		}
		# X81n1568.xml �Ѩ�10~��25, ���O1~16
		if($file eq "X81n1568.xml")
		{
			$ii = sprintf("%03d",$i+9);
		}
		# X82n1571.xml �Ѩ� 34~120 ���O 1~ 87
		if($file eq "X82n1571.xml")
		{
			$ii = sprintf("%03d",$i+33);
		}
		# X85n1587.xml �Ѩ� 2~16 ���O 1~ 15
		if($file eq "X85n1587.xml")
		{
			$ii = sprintf("%03d",$i+1);
		}
		# J25nB165.xml �@ 1 ��, �u���� 6
		if($file eq "J25nB165.xml")
		{
			$ii = "006" if($i==1);
		}
		# J25nB166.xml �@ 1 ��, �u���� 7
		if($file eq "J25nB166.xml")
		{
			$ii = "007" if($i==1);
		}
		# J25nB167.xml �@ 1 ��, �u���� 8
		if($file eq "J25nB167.xml")
		{
			$ii = "008" if($i==1);
		}
		# J32nB271.xml �Ѩ� 6~44 ���O 1~39
		if($file eq "J32nB271.xml")
		{
			$ii = sprintf("%03d",$i+5);
		}
		# J33nB277.xml �Ѩ� 12~25 ���O 1~14
		if($file eq "J33nB277.xml")
		{
			$ii = sprintf("%03d",$i+11);
		}
		# W01n0007.xml �@ 1 ��, �u���� 3
		if($file eq "W01n0007.xml")
		{
			$ii = "003" if($i==1);
		}
		# W03n0025.xml �@ 1 ��, �u���� 2
		if($file eq "W03n0025.xml")
		{
			$ii = "002" if($i==1);
		}
		# W03n0030.xml �@ 1 ��, �u���� 14
		if($file eq "W03n0030.xml")
		{
			$ii = "014" if($i==1);
		}
		# A097n1276      �j��}�����мs�~����(��3��-��4��)
		if($file eq "A097n1276.xml")
		{
			$ii = sprintf("%03d",$i+2);
		}
		# A098n1276      �j��}�����мs�~����(��5-10,12-20��)
		if($file eq "A098n1276.xml")
		{
			if($i<=6) {	$ii = sprintf("%03d",$i+4); }
			else { $ii = sprintf("%03d",$i+5); }
		}
		# A111n1501      �j�����Ūk�_�� (3-8,10-12)
		if($file eq "A111n1501.xml")
		{
			if($i<=6) {	$ii = sprintf("%03d",$i+2); }
			else { $ii = sprintf("%03d",$i+3); }
		}
		# A112n1501      �j�����Ūk�_�� (13-18,20)
		if($file eq "A112n1501.xml")
		{
			if($i<=6) {	$ii = sprintf("%03d",$i+12); }
			else { $ii = sprintf("%03d",$i+13); }
		}
		# A114n1510      �򻡤j�������\�k�q�g (2,6,7��)
		if($file eq "A114n1510.xml")
		{
			$ii = "002" if($i==1);
			$ii = "006" if($i==2);
			$ii = "007" if($i==3);
		}
		# A120n1565      ����v�a�׸q�t(��1,4,6-8,11-12,15,17,19-20,22,26,28-32��)
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
		# A121n1565      ����v�a�׸q�t(��33-35,38,40��)
		if($file eq "A121n1565.xml")
		{
			$ii = "033" if($i==1);
			$ii = "034" if($i==2);
			$ii = "035" if($i==3);
			$ii = "038" if($i==4);
			$ii = "040" if($i==5);
		}
		# C056n1163      �@���g���q(��1��-��15��)
		# C057n1163      �@���g���q(��16��-��25��)
		if($file eq "C057n1163.xml")
		{
			$ii = sprintf("%03d",$i+15);
		}
		# K34n1257       �s���øg���q�H���(��1��-��12)
		# K35n1257       �s���øg���q�H���(��13��-��30)
		if($file eq "K35n1257.xml")
		{
			$ii = sprintf("%03d",$i+12);
		}
		# K41n1482       �j�����[����(��10��-��18��)
		if($file eq "K41n1482.xml")
		{
			$ii = sprintf("%03d",$i+9);
		}
		# L115n1490      ���k���ظg�ȸq����(��1��-��3��)
		# L116n1490      ���k���ظg�ȸq����(��4��-��40��)
		if($file eq "L116n1490.xml")
		{
			$ii = sprintf("%03d",$i+3);
		}
		# L130n1557      �j��s����Y�g���r�|��(��1��-��17��)
		# L131n1557      �j��s����Y�g���r�|��(��17��-��34��)
		if($file eq "L131n1557.xml")
		{
			$ii = sprintf("%03d",$i+16);
		}
		# L132n1557      �j��s����Y�g���r�|��(��34��-��51��)
		if($file eq "L132n1557.xml")
		{
			$ii = sprintf("%03d",$i+33);
		}
		# L133n1557      �j��s����Y�g���r�|��(��51��-��80��)
		if($file eq "L133n1557.xml")
		{
			$ii = sprintf("%03d",$i+50);
		}
		# L153n1638      ���i�H�I�v�y��(��1��-��6��)
		# L154n1638      ���i�H�I�v�y��(��7��-��10��)
		if($file eq "L154n1638.xml")
		{
			$ii = sprintf("%03d",$i+6);
		}
		# P154n1519      �v���έn����(��1��-��12��)
		# P155n1519      �v���έn����(��13��-��20��)
		if($file eq "P155n1519.xml")
		{
			$ii = sprintf("%03d",$i+12);
		}
		# P178n1611      �Ѧ�@�L�p�ӵ��ĴL�̯����W�g(��1��-��29��)
		# P179n1611      �Ѧ�@�L�p�ӵ��ĴL�̯����W�g(��30��-��40��)
		if($file eq "P179n1611.xml")
		{
			$ii = sprintf("%03d",$i+29);
		}
		# P179n1612      �Ѧ�@�L�p�ӵ��ĴL�̦W�ٺq��(��1��-��18��)
		# P180n1612      �Ѧ�@�L�p�ӵ��ĴL�̦W�ٺq��(��19��-��50��)
		if($file eq "P180n1612.xml")
		{
			$ii = sprintf("%03d",$i+18);
		}
		# P181n1612      �Ѧ�@�L�p�ӵ��ĴL�̦W�ٺq��(��51��)
		if($file eq "P181n1612.xml")
		{
			$ii = "051" if($i==1);
		}
		# P181n1615      �j���T�êk��(��1��-��13��)
		# P182n1615      �j���T�êk��(��14��-��35��)
		if($file eq "P182n1615.xml")
		{
			$ii = sprintf("%03d",$i+13);
		}
		# P183n1615      �j���T�êk��(��36��-��38��)
		if($file eq "P183n1615.xml")
		{
			$ii = sprintf("%03d",$i+35);
		}
		# P184n1617      ���k���ظg�n��(��1��-��12��)
		# P185n1617      ���k���ظg�n��(��13��-��19��)
		if($file eq "P185n1617.xml")
		{
			$ii = sprintf("%03d",$i+12);
		}
		# S06n0046       �W�͸g�|�j�q���s��(��2,4��)
		if($file eq "S06n0046.xml")
		{
			$ii = "002" if($i==1);
			$ii = "004" if($i==2);
		}
		# U222n1418      ���Y�g����(��1��-��3��)
		# U223n1418      ���Y�g����(��4-5,7-20��)
		if($file eq "U223n1418.xml")
		{
			$ii = "004" if($i==1);
			$ii = "005" if($i==2);
			$ii = sprintf("%03d",$i+4) if($i > 2);
		}
		
		#�B�z�S���ɦW ###########################################
		
		$outfile = "$outPath/$file";	# ��X��
		$outfile =~ s/\.xml$/_$ii.xml/;	# �ɦW�ܦ� T01n0001_001.xml
		
		$outfile =~ s/(T0[5-7]n0220)[a-z]/$1/;		# �M�����j��Y�g�g��

		print STDERR ">$outfile\n";
		open OUT, ">$outfile" or die "Open $outfile error!$!";
		binmode OUT;	# �G�i����		
		
		#print OUT "$pos1\n";
		#print OUT "$juan_start[$i]\n";
		#print OUT "$juan_end[$i]\n";
		#print OUT "$start_tag[$i]\n";
		#print OUT "${end_tag[$i]}</body></text></tei.2>";
		
		my $out = substr ($alldata, 0, $pos1);
		$out =~ s/<--lestone/<milestone/;
		$out =~ s/"cp950"/"big5"/;		# CBReader �٬O�ݭn�� big5 ���r���ŧi
		
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
	
	parseNode($root);	# �i����R
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
	# elsif ($nodeTypeName eq "TEXT_NODE") {text_handler($node);}	# �ڤ����o��
}

sub start_handler 
{       
	my $node = shift;
	my $parentnode;
	
	local $el = $node->getTagName;
	
	# �B�z <lb> �аO
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
				# �ܦ�, ��ܳo�@�� <lb> �O�Y�@�����}�l.
				$bingo = 1;
				last;
			}
		}
		
		return if($bingo == 0);

		# �ܦ�, ��ܧ��t�@�����}�Y�B, �ҥH�n�O���W�����������U�ؼаO, �~�ŦX XML ����h.

		$milestoneNum++;	# �� N ��
		
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
		
		# �O�������� mulu �аO
		$mulu_tag[$milestoneNum] = "";
		for($i = 1; $i<=$mulu_n; $i++)
		{
			$mulu_tag[$milestoneNum] = $mulu_tag[$milestoneNum] . $this_juan_mulu[$i];
		}
		#$mulu_n = 0;			# ���i�H�k�s, �]���Y�@���i�৹���S�� mulu , �����n�@���~�ӤW�h
		#$this_juan_mulu = ();	# ���i�H�k�s, �]���Y�@���i�৹���S�� mulu , �����n�@���~�ӤW�h
	}
	
	# �B�z <mulu> �аO <mulu level="1" label="��" type="��"/>
	
	# �U���ؿ��}�Y���B�z�k:
	# �C�@���@�J�� <mulu level="n"> �N�O���b $this_juan_mulu[n] , �ç� n �O��k�b $mulu_n �ܼƤ�
	# �Ө�������, �N�� 1~n ���аO���O���b $mulu_tag[n] ����
	# �Ҧp�Y�@��������, @this_juan_mulu ���e�O ("<mulu level=1 label=�Ĥ@��/>", "<mulu level=2 label=�ĤG��/>")
	# �h $mulu_tag[x] = "<mulu level=1 label=�Ĥ@��/><mulu level=2 label=�ĤG��/>"
	
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
		if($attrs =~ / level=/)		# �S�� level �����B�z <mulu n="002" type="��"/>
		{
			$mulu_n = $mulu_n_tmp;
			$this_juan_mulu[$mulu_n] = "${attrs}/>";
		}
	}
}