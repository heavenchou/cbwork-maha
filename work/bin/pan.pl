$max = 1;
%count=();
@text=();
%ZuZiShi=();
%mojikyo=();

open I1,"gaiji-m.txt";
while (<I1>) {
	($cb, $d1, $ent, $uni, $uent, $zu, $ty, $ref, $exm) = split(/\t/, $_);
	$ZuZiShi{'CB' . $cb} = $zu;
	$ZuZiShi{$d1} = $zu;
	$mojikyo{'CB' . $cb} = $d1;
}
close I1;

for ($i=33; $i<=36; $i++) {
  $path = "j:/bsin/cbeta/T" . sprintf("%2.2d",$i);
  opendir (INDIR, $path);
  @allfiles = grep(/\.xml$/i, readdir(INDIR));
  foreach $file (@allfiles) {
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
    if ($s =~ /&(.*?);/) {
      $code = $1;
      if (not exists $count{$code}) { $count{$code} = 0; }
      if ($count{$code} >= $max) { next; }
      $count{$code} ++;
      $s =~ s/<.+?>//g;
      $zuzi = $ZuZiShi{$code};
      $ent = $code;
      if ($code =~ /^CB/) {
        $ent = $mojikyo{$code};
        $s =~ s/$code/$ent/g;
      }
      push @text, "$code $zuzi &$ent; $sutra $lb $s";
    }
  }
  close I1;
}