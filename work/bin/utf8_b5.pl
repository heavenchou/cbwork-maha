#------------------------------------------------------------------
# utf8_b5.pl
#
# Requirements:
#	ODBC 資料來源要設定指到 gaiji-m.mdb
#
# v0.1, by Ray Chou
# v0.2, 忽略副檔名大小寫, 2002/11/7 02:05PM by Ray
#-------------------------------------------------------------------

# 改這兩個目錄參數
#$in_dir = "C:/cbwork/work/bin/utf8";
#$out_dir = "C:/cbwork/work/bin/utf8/big5";
$in_dir = "d:/temp/1";
$out_dir = "d:/temp/2";

mkdir $out_dir, MODE;

require "utf8b5o.plx";
require "utf8.pl";

$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
%uni=();
readGaiji();


opendir (INDIR, $in_dir) or die;
@allfiles = grep /\.txt$/i, readdir INDIR;
closedir INDIR;
for $file (sort(@allfiles)){
	do1file($file);
}

sub do1file {
	my $in=shift;
	print STDERR "33 $in\n";
	open O, ">$out_dir/$in" or die;
	select O;
	open I, "$in_dir/$in" or die;
	while(<I>) {
		@a=();
		push(@a, $_ =~ /$utf8/gs);
		my $c;
		$s = '';
		foreach $c (@a) {
			if ($c ne "\n" and length($c)!=1) {
				if (exists $utf8out{$c}) { $c =  $utf8out{$c}; }
				else {
					$c = UTF8toUCS2($c);
					if (exists $uni{$c}) {
						$c = $uni{$c};
					} else {
						$c = "&#x" . unpack("H*",$c) . ";";
						if ($c eq "&#xfeff;") {
							$c='';
						}
					}
				}
			}
			$s.=$c; 
		}
		print O $s;
	}
	close I;
	close O;
}

sub readGaiji {
	use Win32::ODBC;
	my $cb,$zu,$ent,$mojikyo;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$uni     = $row{"uni"};       # cbeta code

		next if ($uni eq "");

		$uni = pack("H4",$uni);
		$zu      = $row{"des"};      # ²զr¦¡

		$uni{$uni} = $zu;
	}
	$db->Close();
	print STDERR "ok\n";
}

sub UTF8toUCS2 () {
	my $bytes = shift;
	if ($bytes eq "") {
		return "";
	}
	my $save = $bytes;
	if ($bytes =~ /^([\x00-\x7f])$/) {
		pack("n*",unpack("C*",$1));
	} elsif ($bytes =~ /^([\xC0-\xDF])([\x80-\xBF])$/) {
		pack("n", ((ord($1) & 31) << 6) | (ord($2) & 63) );
	} elsif ($bytes =~ /^([\xE0-\xEF])([\x80-\xBF])([\x80-\xBF])/) {
		pack("n", ((ord($1) & 15) << 12) | ((ord($2) & 63) << 6) | (ord($3) & 63));
	} else {
		die "bad UTF-8 data: [$save][" . unpack("H*",$save) . "]";
	}
}