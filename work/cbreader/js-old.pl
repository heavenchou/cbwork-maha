# js.pl
# 2004/12/23 02:40�U�� modified by Ray

# �R�O�C�Ѽ�
$vol = shift; # �Y�����w�U�ƴN�]����

# �Ѽ�
$juanline="H:/cbeta200604/CBReader/Juanline"; # ����T���|
$js_dir="H:/cbeta200604/CBReader/js"; # ��X���|
$in_dir="c:/cbwork/common/x2r"; # ��J��Ӫ���|

if ($vol eq '') {
	opendir DIR, $juanline or die "cannot opendir $in_dir";
	@allfiles = grep /^X.*\.txt$/, readdir DIR;
	closedir DIR;
	foreach $s (@allfiles) {
		$vol = substr($s, 0, 3);
		do_vol($vol);
	}
} else {
	do_vol($vol);
}

sub do_vol {
	$vol = shift;
	mkdir("$js_dir/$vol", MODE);
	$ed=substr($vol,0,1);
	
	$f = "$in_dir/${vol}R.txt";
	open I, $f or die "cannot open $f";
	$f = "$juanline/$vol.txt";
	open J, $f or die "cannot open $f";
	$buf='';
	while(<J>) {
		chomp;
		($line,$sutra,$juan) = split /[ ,]+/; # ���o�Y�g�Y�����_�l�渹
		readxr(); # �p��Ӧ渹����Ӹ�T��Ū�i��
	
		$file = "$js_dir/$vol/" . $sutra . $juan . ".js";
		print STDERR ">$file\n";
		close O;
		open O, ">$file" or die;
		select O;
		print "var xr = new Object();\n";
		print $buf;
	}
	$line="9999z99";
	readxr();
	close I;
	close J;
	close O;
}

sub readxr {
	my $s;
	while (<I>) {
		chomp;
		$s=$_;
		#if (/[X%]......._p(.......)...��R(...)_p(\d{4}.\d\d)��/) {
		if ($s=~/[X%].......[_a-z]p(.......)��R(...)_p(\d{4}.\d\d)/) {
			$x=$1;
			$buf="xr['$1']='$2$3';\n";
			if ($x ge $line) {
				return;
			}
			print $buf;
			$buf='';
		} elsif ($s=~/[X%].......[_a-z]p(.......)��/) {
			$x=$1;
			if ($x ge $line) {
				return;
			}
		}
	}
}