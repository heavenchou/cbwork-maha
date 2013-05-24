#
# cbeta ent 檔所使用到的悉曇字, 與輸入法對照表
# written by Ray 2001/2/22 01:50下午
#
open I,"T:/siddham/siddam1.txt" or die "open error";
<I>; <I>;
while (<I>) {
	($k, $x) = split;
	$x{$x} = $k;
}
close I;

for ($i=1; $i<=53; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$dir = "c:/cbwork/$vol";
	print STDERR "$dir\n";

	opendir THISDIR, $dir or die "opendir error: $dir";
	my @allfiles = grep /\.ent$/, readdir THISDIR;
	closedir THISDIR;
	foreach $file (@allfiles) {
		open I,"$dir/$file" or die "open error";
		while (<I>) {
			if (/SD-(\w{4})/) {
				$s{$1}=0;
			}
		}
		close I;
	}
}

print <<EOF;
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
</head>
<body>
<table border="1" cellspacing="0" cellpadding="5">
EOF
for $key (sort keys %s) {
	print "<tr><td>$key";
	$s = pack "H4", $key;
	print "<td><font face='siddam'>$s</font><td>",$x{$s},"\n";
}
print "</table></body></html>";