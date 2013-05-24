
dofile1("bulei1_orig.txt", ">..\\bulei1.txt");
dofile("bulei2_orig.txt", ">..\\bulei2.txt");	# �S�����h���榡
dofile1("bulei3_orig.txt", ">..\\bulei3.txt");
dofile1("bulei4_orig.txt", ">..\\bulei4.txt");
dofile("bulei5_orig.txt", ">..\\bulei5.txt");	# �S�����h���榡
dofile("bulei6_orig.txt", ">..\\bulei6.txt");	# �S�����h���榡
dofile1("bulei7_orig.txt", ">..\\bulei7.txt");
dofile1("buleinewsign_orig.txt", ">..\\buleinewsign.txt");	# �s�����I�ؿ�
dofile1("buleifuyan_orig.txt", ">..\\buleifuyan.txt");		# ���Y�T�~Ū�g�ؿ�
dofile1("buleilichan_orig.txt", ">..\\buleilichan.txt");	# ���Ѯv����§�b��

sub dofile
{
	$infile = shift;
	$outfile = shift;

	open IN, "$infile";
	open OUT, "$outfile";

	$lasthead = "";
	$num = 0;

	while(<IN>)
	{
		# 001##0001   22,�����t�g    ,�i�᯳ ����C�٦@�Ǧ��Ķ�j
		/(...)(##.*?)\s*$/;
		$head = $1;
		$data = $2;
		if($head == $lasthead)
		{
			$num++;
		}
		else
		{
			$num = 1;
		}
		$num = sprintf("%03d",$num);
		print OUT "$head$num$data\n";
		$lasthead = $head;
	}

	close IN;
	close OUT;
}

sub dofile1
{

#01 ���t���� T01-02,25,33
#	T0001-25 �����t�g�� T01
#		T0001 �����t�g22��
#		T0002-25 �����t�g�楻
#			T0002 �C��g1��
#			T0003 �i�C�r��g2��
#			T0004 �C������m�r�g1��
#
# �n�ܦ�
#
#001##01 ���t���� T01-02,25,33
#001001##T0001-25 �����t�g�� T01
#001001001##T0001 �����t�g22��
#001001002##T0002-25 �����t�g�楻
#001001002001##T0002 �C��g1��
#001001002002##T0003 �i�C�r��g2��
#001001002003##T0004 �C������m�r�g1��

	$infile = shift;
	$outfile = shift;

	open IN, "$infile";
	open OUT, "$outfile";

	$lasttab = 0;
	$tab[0] = 0;

	while(<IN>)
	{
		/^(\s*)(\S.*?)\s*$/;
		$head = $1;
		$data = $2;
		
		$tabnum = 0;
		while($head ne "")
		{
			if($head =~ /^(\t)(.*)/)
			{
				$tabnum++;
				$head = $2;
			}
			else
			{
				print "not tab err : $head$data\n";
				exit;
			}
		}
		
		if($tabnum <= $lasttab)
		{
			for($i = 0 ; $i<$tabnum ; $i++)
			{
				$num = sprintf("%03d",$tab[$i]);
				print OUT "$num";
			}
			$tab[$tabnum] = $tab[$tabnum] + 1;
			$num = sprintf("%03d",$tab[$tabnum]);
			print OUT "$num";
		}
		elsif($tabnum == $lasttab + 1)		# �h�F�@�h
		{
			for($i = 0 ; $i<$tabnum ; $i++)
			{
				$num = sprintf("%03d",$tab[$i]);
				print OUT "$num";
			}
			$tab[$tabnum] = 1;				# �s���@�h
			print OUT "001";
		}
		else
		{
			print "err : ���i��? $head$data\n";
			exit;
		}
		
		print OUT "##$data\n";
		
		$lasttab = $tabnum;
	}

	close IN;
	close OUT;
}