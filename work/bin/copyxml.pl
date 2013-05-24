#
# ±N *.xml *.ent ±q c:/cbwork copy ¨ì y:/cbeta/xml
#
use File::Copy;
$source = "c:/cbwork/work/bin/Root";
$outPath = "y:/cbeta/xml";
copy("c:/cbwork/work/bin/Root", "$outPath/cvs/Root");
for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	mkdir("$outPath/$vol", MODE);
	$dir = "c:/cbwork/xml/$vol";
	if (not -e $dir) { next; }
	print STDERR "$dir\n";
	copy($source, "$outPath/$vol/cvs/Root");
}