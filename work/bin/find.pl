#$indir = "/cbwork/simple";
$indir = "/cbwork/xml";
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $except5d='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x5c])|(?:[\x5e-\xff]))';
%lang=();
for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$dir = "$indir/$vol";
	if (not -e $dir) { next; }
	print STDERR "$vol\n";
	
	opendir THISDIR, $dir or die "opendir error: $dir";
	#my @allfiles = grep !/^\.\.?$/, readdir THISDIR;
	#my @allfiles = grep /^new.txt$/, readdir THISDIR;
	my @allfiles = grep /\.xml$/, readdir THISDIR;
	closedir THISDIR;
	
	foreach $file (@allfiles) {
		if ($file =~ /xml$/) {
		#if ($file =~ /txt$/) {
			open I, "$dir/$file" or die;
			while (<I>) {
				if (/<lem.*?<corr.*?<\/lem>/) {
						print "$file $_";
				}
			}
		}
	}
}


foreach $k (keys %lang) {
	print $k, $lang{$k}, "\n";
}

sub rep {
	$s = shift;
	$lang{$s} ++;
}