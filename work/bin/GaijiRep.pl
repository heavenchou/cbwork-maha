#
# GaijiRep.pl
# ¯Ê¦r½X¨ú¥N
# by Ray 2001/3/30 09:54¤W¤È
#
$indir = "c:/cbwork/xml";
%table = (
"CB07744" => "CB09852", 
);
for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$dir = "$indir/$vol";
	if (not -e $dir) { next; }
	print STDERR "$vol\n";
	opendir THISDIR, $dir or die "opendir error: $dir";
	my @allfiles = grep !/^\.\.?$/, readdir THISDIR;
	closedir THISDIR;

	foreach $file (@allfiles)
	{
		if ($file =~ /xml$/) {
			open I, "$dir/$file" or die;
			$s='';
			$dirty = 0;
			while (<I>) {
				$a = $_;
				$old = $a;
				while ( ($k1,$k2) = each %table ) {
					$a =~ s/$k1(\D)/$k2$1/g;
				}
				if ($a ne $old) { $dirty = 1; }
				$s .= $a;
			}
			close I;
			if ($dirty) {
				print STDERR "$file\n";
				open O, ">$dir/$file" or die;
				print O $s;
				close O;
			}
		}
	}
}