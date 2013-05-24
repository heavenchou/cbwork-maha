$indir = "/cbwork/xml";
for ($i=52; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$dir = "$indir/$vol";
	if (not -e $dir) { next; }
	
	opendir THISDIR, $dir or die "opendir error: $dir";
	my @allfiles = grep !/^\.\.?$/, readdir THISDIR;
	closedir THISDIR;
	
	foreach $file (@allfiles) {
		if ($file =~ /xml$/) {
			print STDERR "$file\n";
			open I, "$dir/$file" or die;
			$s='';
			while (<I>) {
				while (/CB\d\d\d\d\D/) {
					s/CB(\d\d\d\d)(\D)/CB0$1$2/g;
				}
				$s .= $_;
			}
			close I;
			open O, ">$dir/$file";
			print O $s;
			close O;
		}
	}
}