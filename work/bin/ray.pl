# created by Ray 2000/3/8 08:44AM
$vol = shift;
$work = "j:/bsin/cbeta/" . $vol . "/";
%ent = ();

opendir (INDIR, $work);
@dir = readdir(INDIR);
@allfiles = grep(/\.ent$/i, @dir);
foreach $file (@allfiles) {
  open(I, $work . $file) || die "can't open $file\n";
  while (<I>) {
    s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
		  /^(.+)\s+\"(.*)\".*/;
		  $ent = $1;
		  $val = $2;
		  $ent =~ s/ //g;
		  if ($val=~/nor=\'(.+?)\'/) { $val=$1; }  # 優先用通用字
		  elsif ($val=~/des=\'(.+?)\'/) { $val=$1; } # 否則用組字式
		} else {
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		}
		$ent{$ent} = $val;
  }
  close I;
}

@allfiles = grep(/\.xml$/i, @dir);
foreach $file (@allfiles) {
  print "$file\n";
  open(I, $work . $file) || die "can't open $file\n";
  while (<I>) {
    if ((/head/ or /title/) and (/M\d+/ or /CB\d+/)) { 
      if (/(M\d+)/) { $c = $1; } 
      elsif (/(CB\d+)/) { $c = $1; }
      $val = $ent{$c};
      s/&$c;/$val/g;
      s/\[\d\d\]//g;
      s/<div\d .*?>//g;
      s/<\/div\d>//g;
      s/<head>//g;
      s/<\/head>//g;
      s/<title>//g;
      s#</title>##g;
      print ; 
    }
  }
  close I;
}