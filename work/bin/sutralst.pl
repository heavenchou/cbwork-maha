#
#
use File::Copy;
use Win32::ODBC;

readGaiji();
readCbetaEnt();
open O, ">c:/cbwork/work/bin/sutralst.txt" or die "open error";

for ($i=1; $i<=85; $i++) {
	$i = 85 if($i == 56);
	$vol = "T" . sprintf("%2.2d",$i);
	dodir($vol);
}
for ($i=1; $i<=88; $i++) {
	$i = 7 if($i == 6);
	$i = 53 if($i == 52);
	$vol = "X" . sprintf("%2.2d",$i);
	dodir($vol);
}
for ($i=1; $i<=40; $i++) {
	$i = 7 if($i == 2);
	$i = 10 if($i == 8);
	$i = 15 if($i == 11);
	$i = 19 if($i == 16);
	$vol = "J" . sprintf("%2.2d",$i);
	dodir($vol);
}
for ($i=1; $i<=1; $i++) {
	$vol = "H" . sprintf("%2.2d",$i);
	dodir($vol);
}
for ($i=1; $i<=9; $i++) {
	$vol = "W" . sprintf("%2.2d",$i);
	dodir($vol);
}
for ($i=1; $i<=1; $i++) {
	$vol = "I" . sprintf("%2.2d",$i);
	dodir($vol);
}
close O;

##################################################################

sub dodir
{
	my $vol = shift;
	$dir = "c:/cbwork/xml/$vol";
	if (not -e $dir) { next; }
	print STDERR "$dir\n";
	opendir INDIR, $dir or die "opendir $dir error: $dir";
	my @allfiles = grep(/^[TXJHWI]\d\dn.{4,5}\.xml$/i, readdir(INDIR));
	closedir INDIR;
  
	foreach $file (sort @allfiles)
	{
		do1file($file);
	}
}

sub do1file {
	my $file = shift;
	print STDERR "$file\n";
	open I, "<$dir/$file" or die "open error";
	$juan = 0;
	while (<I>) {
		if (/title.*No. ([AB]?)(\d+)([A-Za-z])? (.*)<\/title/) {
			my $j = $1;
			my $number  = $2;
			my $other = $3;
			$name = $4;
			
			if($j)	#嘉興藏的經號
			{
				$num = $j . sprintf("%03d",$number) . $other;
			}
			else
			{
				$num = sprintf("%04d",$number) . $other;
			}
		}
		if (m#<extent>(\d+?)卷</extent>#) {
			$juan = $1;
		}
		if (/^<lb\s*(?:ed="[TXJHWI]")?\s*n="(\w{7})"/) {
			$lb = $1;
			last;
		}
	}
	
	if ($juan == 0) {
		$juan = 1;
		while (<I>) {
			if (/<juan fun=\"open\" n=\"(.*?)\">/) {
				$n = int($1);
				if ($n > $juan) { $juan = $n; }
			}
		}
	}
	close I;
	
	while ($name=~ /&(.*?);/) {
		if (exists($nor{$1})) {
			my $n = $nor{$1};
			$name =~ s/&.*?;/$n/;
		} else {
			die "$1";
		}
	}
	print O "$vol##$num##$name##$juan##$lb\n";
}

sub readGaiji {
	my $cb,$zu,$ent,$mojikyo,$ty;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = 'CB' . $row{"cb"};       # cbeta code
		$mojikyo = $row{"mojikyo"};  # mojikyo code
		$zu      = $row{"des"};      # 組字式
		$ty      = $row{"nor"};

		next if ($cb =~ /^#/);

		$ty = "" if ($ty =~ /none/i);
		$ty = "" if ($ty =~ /\x3f/);
		die "ty=[$ty]" if ($ty =~ /\?/);

		if ($ty ne '') {
			$nor{$cb} = $ty;
		} else {
			$nor{$cb} = $zu;
		}
	}
	$db->Close();
	print STDERR "ok\n";
}

sub readCbetaEnt {
	open I, "c:/cbwork/xml/dtd/cbeta.ent" or die "open error";
	while (<I>) {
		if (/<!ENTITY (\S*) +"(.*)"  >/) {
			$nor{$1} = $2;
			print STDERR "$1 => ",$nor{$1},"\n";
		}
	}
	close I;
}
