#
# 將 xml 經文檔中的 M碼 改用 cb碼
#
use Win32::ODBC;

$vol = shift;
$vol = uc($vol);
$sourcePath="c:/CBWork/$vol";
$outPath = "c:/release/NewXML/$vol";

$except = "M024261 M040426 M034294 M005505 M010528 M010527 M026945 M006710";
$except .= "M062404 M062477 M062447 M062443 M062459 M062456 M062440 M062433 M062482 M062438 M062406 M062440 M062443 M062447 M062453 M062459 M062466 M062473 M062474 M062417";
readGaiji();

mkdir("c:/Release", MODE);
mkdir("c:/Release/NewXML", MODE);
mkdir($outPath, MODE);
opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
for $file (sort(@allfiles)) { do1file("$file"); }

sub do1file {
	my $file = shift;
	$path = "$sourcePath/$file";
	print STDERR "$path => $outPath/$file...\n";
	open I,$path or die "open $path error\n";
	open O,">$outPath/$file";
	while (<I>) {
		while (/(M\d{6})/) {
			$m = $1;
			if (exists $m2cb{$m}) {
				$cb = "CB" . $m2cb{$m};
				s/M\d{6}/$cb/;
			} elsif ( $except =~ /$m/) {
				s/M(\d{6})/#@#$1#@#/;
			} else {
				die "$m not found\n";
			}
		}
		s/#@#(\d{6})#@#/M$1/g;
		#print STDERR;
		print O;
	}
	close I;
}

sub readGaiji {
	my $cb,$zu,$ent,$mojikyo,$ty;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code
		$mojikyo = $row{"mojikyo"};  # mojikyo code
		next if ($cb =~ /^#/);
		next if ($mojikyo eq "");
	
		$m2cb{$mojikyo} = $cb;
	}
	$db->Close();
	print STDERR "ok\n";
}