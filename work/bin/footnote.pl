#
# footnote.pl
# ®Õ°É²Å¸¹ [99] => <anchor>
# by Ray
#
$vol = shift;
$vol = uc($vol);
$sourcePath="c:/CBWork/$vol";
$outPath = "c:/release/NewXML/$vol";
mkdir("c:/Release", MODE);
mkdir("c:/Release/NewXML", MODE);
mkdir($outPath, MODE);
opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
for $file (sort(@allfiles)) { do1file("$file"); }

sub do1file {
	$file = shift;
	print STDERR "$file\n";
	open I, "$sourcePath/$file" or die "open $file error\n";
	open O, ">$outPath/$file";
	$count=0;
	$page="#";
	while (<I>) {
		if (/<lb n=\"(\d{4}\w)/) {
			if ($1 ne $page) { $count=0; }
			$page = $1;
		}
		
		while (/\[(\d{2,3})\]/) {
			$n = $1;
			$id = "fn${vol}p$page$n";
			s/\[(\d{2,3})\]/<anchor id=\"$id\"\/>/;
		}
		
		while (/\[¡¯\]/) {
			$count++;
			$id = "fx${vol}p$page$count";
			s/\[¡¯\]/<anchor id=\"$id\"\/>/;
		}
		print O;
	}
}