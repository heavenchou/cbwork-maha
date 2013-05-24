#
# 檢查是否有不應存在的 M 碼
# Written by Ray 2000/12/15 09:24上午
#
$vol = shift;
$vol = uc($vol);
$sourcePath="c:/CBWork/$vol";
$outPath = "c:/release/NewXML/$vol";

$except = "M024261 M040426 M034294 M005505 M010528 M010527 M026945 M006710";
$except .= "M062404 M062477 M062447 M062443 M062459 M062456 M062440 M062433 M062482 M062438 M062406 M062440 M062443 M062447 M062453 M062459 M062466 M062473 M062474 M062417";

opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
for $file (sort(@allfiles)) { do1file("$file"); }

sub do1file {
	my $file = shift;
	$path = "$sourcePath/$file";
	print STDERR "$file...\n";
	open I,$path or die "open $path error\n";
	while (<I>) {
		$line = $_;
		while (/(M\d{6})/) {
			$m = $1;
			if ( $except !~ /$m/) {
				print STDERR "$line\n";
				last;
			}
			s/M\d{6}//;
		}
	}
	close I;
}