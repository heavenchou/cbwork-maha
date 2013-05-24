my $ver = "normal";
# my $ver = "pda";
# my $ver = "app";
# my $ver = "app1";

my $source_root;
my $target_root;

$source_root = "C:/release/$ver/";		# �ӷ��ؿ�
$target_root = "c:/work/$ver/";		# �ت��ؿ�

my $TFrom = 1; 	# �j���óB�z�U�ƶ}�l
my $Tto = 85;		# �j���óB�z�U�Ƶ���
my $XFrom = 11; 	# �����óB�z�U�ƶ}�l
my $Xto = 16;		# �����óB�z�U�Ƶ���

my $runT = 0;		# ����j����
my $runX = 1;		# ����������

##############################################
# �D�{��
##############################################

mkdir ($target_root) unless(-d $target_root);

$TFrom = 999 if($runT == 0);
$XFrom = 999 if($runX == 0);

for(my $i = $TFrom; $i<= $Tto; $i++)
{
	$i = 85 if ($i == 56);
	$vol = sprintf("T%02d", $i);
	dothisdir($vol);
}
for(my $i = $XFrom; $i<= $Xto; $i++)
{
	$i = 7 if ($i == 6);
	$vol = sprintf("X%02d", $i);
	dothisdir($vol);
}

print "ok!\n";
<>;
exit;


# �B�z��@�ؿ�

sub dothisdir
{
	my $vol = shift;
	my $source_dir = $source_root . $vol . "/*.*";
	open OUT, ">${target_root}${vol}.txt" or die "open ${target_root}${vol}.txt error!";
	my @files = <{$source_dir}>;
	foreach my $file (sort(@files))
	{
		dothisfile($file);
	}
	close OUT;
}

# �B�z��@�ɮ�

sub dothisfile
{
	my $file_from = shift;
	print $file_from . "\n";
	
	open IN, "$file_from" or die "open $file_from error";
	my $linenum = 0;
	while(<IN>)
	{
		$linenum++;
		if($ver eq "pda")
		{
			next if($linenum <=5);
			s/\[\d{4}[a-z]\d\d\]//;
		}
		if($ver eq "normal" or $ver eq "app" or $ver eq "app1")
		{
			next if($_ !~ /^[TX]/);
			s/[TX]\d\dn.{5}p\d{4}.\d\d.*?��//;
		}
		chomp;
		s/ //g;
		s/�@//g;
		print OUT "$_";
	}
	close IN;	
}
