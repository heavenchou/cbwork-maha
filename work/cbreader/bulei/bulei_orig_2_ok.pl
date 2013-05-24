
dofile1("bulei1_orig.txt", ">..\\bulei1.txt");
dofile("bulei2_orig.txt", ">..\\bulei2.txt");	# 沒有階層的格式
dofile1("bulei3_orig.txt", ">..\\bulei3.txt");
dofile1("bulei4_orig.txt", ">..\\bulei4.txt");
dofile("bulei5_orig.txt", ">..\\bulei5.txt");	# 沒有階層的格式
dofile("bulei6_orig.txt", ">..\\bulei6.txt");	# 沒有階層的格式
dofile1("bulei7_orig.txt", ">..\\bulei7.txt");
dofile1("buleinewsign_orig.txt", ">..\\buleinewsign.txt");	# 新式標點目錄
dofile1("buleifuyan_orig.txt", ">..\\buleifuyan.txt");		# 福嚴三年讀經目錄
dofile1("buleilichan_orig.txt", ">..\\buleilichan.txt");	# 杜老師做的禮懺部

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
		# 001##0001   22,長阿含經    ,【後秦 佛陀耶舍共竺佛念譯】
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

#01 阿含部類 T01-02,25,33
#	T0001-25 長阿含經類 T01
#		T0001 長阿含經22卷
#		T0002-25 長阿含經單本
#			T0002 七佛經1卷
#			T0003 毘婆尸佛經2卷
#			T0004 七佛父母姓字經1卷
#
# 要變成
#
#001##01 阿含部類 T01-02,25,33
#001001##T0001-25 長阿含經類 T01
#001001001##T0001 長阿含經22卷
#001001002##T0002-25 長阿含經單本
#001001002001##T0002 七佛經1卷
#001001002002##T0003 毘婆尸佛經2卷
#001001002003##T0004 七佛父母姓字經1卷

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
		elsif($tabnum == $lasttab + 1)		# 多了一層
		{
			for($i = 0 ; $i<$tabnum ; $i++)
			{
				$num = sprintf("%03d",$tab[$i]);
				print OUT "$num";
			}
			$tab[$tabnum] = 1;				# 新的一層
			print OUT "001";
		}
		else
		{
			print "err : 怎麼可能? $head$data\n";
			exit;
		}
		
		print OUT "##$data\n";
		
		$lasttab = $tabnum;
	}

	close IN;
	close OUT;
}