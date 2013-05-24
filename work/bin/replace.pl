$indir = "/cbwork/xml";
$out_dir = "c:/release/new-xml";
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	print STDERR "$vol\n";
	$dir = "$indir/$vol";
	if (not -e $dir) { next; }
	mkdir("$out_dir/$vol",MODE);
	
	opendir THISDIR, $dir or die "opendir error: $dir";
	my @allfiles = grep /\.xml$/, readdir THISDIR;
	closedir THISDIR;
	
	foreach $file (@allfiles) {
		open I, "$dir/$file" or die;
		open O, ">$out_dir/$vol/$file" or die;
		select O;
		while (<I>) {
			s/tei.2/TEI.2/g;
			print;
		}
		close I;
	}
}