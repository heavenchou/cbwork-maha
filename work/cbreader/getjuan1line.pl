# 使用方法
#
# perl getjuan1line.pl T01
#
# 取得某一冊所有經所有卷的第一行的行首標記
#


# command line parameters
$vol = shift;
$vol = uc($vol);
#$vol = substr($vol,0,3);

# configuration
$sourcePath = "c:/release/normal/$vol";
$outPath = "c:/release/Juanline";
mkdir($outPath);

$outfile = "$outPath/${vol}.txt";

opendir (INDIR, $sourcePath);
@allfiles = grep(/\.txt$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;


open OUT, ">$outfile" || die "open outfile $outfile error!$!";

for $file (sort(@allfiles)) 
{
	do1file("$sourcePath/$file");
}

close OUT;

#################################################

sub do1file 
{

	my $file = shift;
	
	open (IN, $file);
	
	$file =~ /\/.(.....)(...)\.txt$/;
	$sutra = $1;
	$juan = $2;
	
	while(<IN>)
	{
		if (/[TXJHWIABCFGKLMNPQSU]\d*n(.{5})p(.{7})║/)
		{
			$sutra = $1;
			$line = $2;
			if($sutra=~/(....)_/)
			{
				$sutra = $1 . " ";
			}
			print OUT "$line, $sutra, $juan\n";
			last;
		}
	}
	close IN;
}
