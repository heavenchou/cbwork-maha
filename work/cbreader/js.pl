# js.pl
# 2006/1/13 14:43 by Ray
# 2004/12/23 02:40�U�� modified by Ray

# �R�O�C�Ѽ�
$vol = shift; # �Y�����w�U�ƴN�]����

# �Ѽ�
$juanline="d:/cbeta/cd2006-04/juanline"; # ����T���|
$js_dir="d:/cbeta/cd2006-04/js"; # ��X���|
$in_dir="d:/cbwork/common/x2r"; # ��J��Ӫ���|

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
	$last_r = '';
	@no_r=();
	while(<J>) {
		chomp;
		($line,$sutra,$juan) = split /[ ,]+/; # ���o�Y�g�Y�����_�l�渹
		if ($sutra eq "1546") { # ��3 �b ��2 �e��
			if ($juan eq "002") {
				$juan = "003";
				$line = "0154a01";
			} elsif ($juan eq "003") {
				$juan = "002";
				$line = "0163b01";
			}
		}
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
			$last_r = "$2$3";
			$buf="xr['$x']='$last_r';\n";
			
			foreach  $x (@no_r) {
				print "xr['${x}t']='$last_r';\n";
			}
			@no_r = ();
			
			if ($x ge $line) {
				return;
			}
			print $buf;
			$buf='';
		} elsif ($s=~/[X%].......[_a-z]p(.......)��/) {
			$x=$1;
			push @no_r, $x;
			if ($x ge $line) {
				$last_r = '';
				return;
			}
			if ($last_r ne '') {
				print "xr['${x}h']='$last_r';\n";
			}
		}
	}
}