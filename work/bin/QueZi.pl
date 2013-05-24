$sourcePath = "c:/cbwork/xml";
use Win32::ODBC;
$max = 50;
%count=();
@text=();
%ZuZiShi=();
%mojikyo=();
%CbetaEnt=();
%m2cb=();

readCbetaEnt("c:/cbwork/xml/dtd/cbeta.ent");
readCbetaEnt("c:/cbwork/xml/dtd/jap.ent");
readGaiji();

for ($i=01; $i<=85; $i++) {
	$path = "$sourcePath/T" . sprintf("%2.2d",$i);
	opendir (INDIR, $path);
	@allfiles = grep(/\.xml$/i, readdir(INDIR));
	foreach $file (@allfiles) {
		print STDERR "$file\n";
		processOneFile();
	}
}

$old ='';
foreach $s (sort @text) {
  $s =~ /^(.*?) /;
  if ($1 eq $old) {
    @temp = split ' ', $s;
    $temp[0] =~ s/\S/ /g;
    $temp[1] =~ s/\S/ /g;
    if (length($temp[2])==8) { $temp[2].=' '; }
    $s = join ' ',@temp;
  } else {
    $old = $1;
  }
  print "$s\n";
}

sub processOneFile {
  $file =~ /(.*)\.xml/;
  $sutra = $1;
  if (length($sutra)==8) { $sutra .= ' '; }
  open I1, $path . "/" . $file or die "open error $file";
  while (<I1>) {
    chomp;
    $s = $_;
    if ($s =~ /lb n=\"(.+?)\"/) { $lb = $1; }
    $s =~ s#<corr sic="(M\d{6})">.*?</corr>#&$1;#g;
    $s =~ s#<corr sic="(CB\d{4})">.*?</corr>#&$1;#g;
    my $line = $s;
    while ($line =~ /&(.*?);/ or $line =~ /="(M\d{6})"/ or $line =~ /="(CB\d{4})"/) {
      $code = $1;
      $line =~ s/&$code;//g;
      $line =~ s/$code//g;
      if (exists $CbetaEnt{$code}) { next; }
		if ($code=~/M\d*/) {
			$code = $m2cb{$code};
		}
      if (not exists $count{$code}) { $count{$code} = 0; }
      if ($count{$code} >= $max) { next; }
      $count{$code} ++;
      $s =~ s/<.+?>//g;
      $zuzi = $ZuZiShi{$code};
      $ent = $code;
		if ($code =~ /^CB/ and $mojikyo{$code} ne '') {
			$ent = $mojikyo{$code};
			$s =~ s/$code/$ent/g;
		}
      push @text, "$code $zuzi &$ent; $sutra $lb $s";
    }
  }
  close I1;
}

sub readCbetaEnt {
	my $file = shift;
	print STDERR "Read $file...\n";
	open I1, $file;
	while (<I1>) {
		if (/<!ENTITY +(.*?) +"(.*?)" *>/) {
			$CbetaEnt{$1} = $2;
		}
	}
	close I1;
}

sub readGaiji {
  my $cb,$zu,$ent,$mojikyo;
  print STDERR "Reading Gaiji-m.mdb ....";
  my $db = new Win32::ODBC("gaiji-m");
  if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
  while($db->FetchRow()){
    undef %row;
    %row = $db->DataHash();
    $cb      = $row{"cb"};       # cbeta code
    $mojikyo = $row{"mojikyo"};  # mojikyo code
    $zu      = $row{"des"};      # ²զr¦¡
    $ent     = $row{"entity"};
    $uni     = $row{"uni"};

  	next if ($cb =~ /^#/);

	$cb = 'CB' . $cb;
	$ZuZiShi{$cb} = $zu;
	$ZuZiShi{$mojikyo} = $zu;
	$mojikyo{$cb} = $mojikyo;
	$m2cb{$mojikyo} = $cb;
  }
  $db->Close();
  print STDERR "ok\n";
}