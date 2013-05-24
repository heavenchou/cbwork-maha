#-------------------------------
# anchor.pl
# Version 0.1
# Ray Chou
# 2002/6/20 02:04
#-------------------------------

# 改這兩個目錄參數
$in_dir = "c:/cbwork/xml/T52";
$out_dir = "D:/temp";

mkdir $out_dir, MODE;

opendir (INDIR, $in_dir);
@allfiles = grep /\.xml$/, readdir INDIR;
closedir INDIR;
for $file (sort(@allfiles)){
	do1file($file);
}

sub do1file {
	my $in=shift;
	print STDERR "$in\n";
	
	open I, "$in_dir/$in" or die;
	open O, ">$out_dir/$in" or die;
	select O;
	while(<I>) {
		if (/<pb.*?n=\"(.{5})\"/) {
			$pb = $1;
		}
		s/(fnT\d{8})/&rep($1)/eg;
		s/(fxT\d{8})/&rep1($1)/eg;
		print;
	}
	close I;
	close O;
}

sub rep {
	my $s=shift;
	$s =~ /(fnT\d\d)(\d{4})(\d\d)/;
	$s = $1 . "p" . $pb . $3;
	return $s;
}

sub rep1 {
	my $s=shift;
	$s =~ /(fxT\d\d)(\d{4})(\d\d)/;
	my $vol = $1;
	my $n=$3;
	$n =~ s/^0//;
	$s = $vol . "p" . $pb . $n;
	return $s;
}