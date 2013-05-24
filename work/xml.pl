mkdir("c:/work/xml",MODE);
for ($i=1; $i<=85; $i++) {
	$vol = sprintf("T%2.2d",$i);
	$dir = "c:/cbwork/xml/$vol";
	if (not -e $dir) { next; }
	chdir($dir);

	mkdir("c:/work/xml/$vol",MODE);
	open O,">c:/work/xml/$vol/CVS/Root";
	print O ":pserver:guest\@cvs.cbeta.org:/usr/local/rep\n";
	close O;
	system "\"c:/program files/winzip/wzzip\" -rp y:/cbeta/xml/$vol.zip c:/work/xml/$vol";
}