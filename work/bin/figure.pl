print STDERR << "XXX";
+--------------------------------------
| figure.pl 
| 將 xml 檔的 【圖】換成 <figure> 標記
| Version 0.1
| Written by Ray Chou
| 2002/6/21 06:12PM
+--------------------------------------
XXX

# 改這兩個目錄參數
$in_dir = "c:/cbwork/xml/T39";
$out_dir = "D:/temp";

mkdir $out_dir, MODE;

opendir (INDIR, $in_dir);
@allfiles = grep /\.xml$/, readdir INDIR;
closedir INDIR;
for $file (sort(@allfiles)){
	do1file($file);
}
unlink "$out_dir/temp.txt";

sub do1file {
	my $in=shift;
	print STDERR "$in\n";
	$vol=substr($in,1,2);
	
	open I, "$in_dir/$in" or die;
	open O, ">$out_dir/temp.txt" or die;
	select O;
	@figures=();
	while(<I>) {
		if (/<pb.*?n=\"(....).\"/) {
			$pb = $1;
			$count=0;
		}
		s/【圖】/&rep()/eg;
		print;
	}
	close I;
	close O;
	
	open I, "$out_dir/temp.txt" or die;
	open O, ">$out_dir/$in" or die;
	select O;
	while(<I>) {
		if (/^\%ENTY/) {
			foreach $s (@figures) {
				print "<!ENTITY FigT$s SYSTEM \"figures/$s.gif\" NDATA GIF>\n";
			}
		}
		print;
	}
	close I;
	close O;
}

sub rep {
	$count++;
	$s = $vol . $pb . sprintf("%2.2d",$count);
	push @figures, $s;
	return "<figure entity=\"FigT$s\"/>";
}