readGaiji("gaiji-m.xml");

$infile = "../t02/T02 ®Õ°É.txt";
$outfile = ">../t02/T02 ®Õ°É-1.txt";

my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';

open(I, $infile) || die "can't open $infile\n";
open (O, $outfile);
select O;
while (<I>) {
  #s/(\[.+?\])/&rep($1)/egx;
  chomp;
  $s = $_;
  my @a=();
  push(@a, $s =~ /$big5/gs);
	$s = '';
	$zu = '';
	foreach $c (@a) {	
	  if ($c eq '[') { 
	    $zu = $c; 
	  } elsif ($c eq ']') {
	    $zu .= ']';
	    $s .= rep($zu);
	    $zu = '';
	  } else {
	    if ($zu eq '') { $s .= $c; }
	    else { $zu .= $c; }
	  }
	}

  print "$s\n";
}

sub readGaiji {
  $file = shift;
  open(T, $file) || die "can't open $files{\"gaiji\"}\n";
  while(<T>){
  	chop;
  	#($cb, $d1, $ent, $uni, $uent, $zu, $ty, $ref, $exm) = split(/\t/, $_);
  	if ($_ !~ /<gaiji>/) { next; }
  	$_=<T>; chomp;	m#<cb>(.*)</cb>#;           $cb=$1;
  	$_=<T>; chomp;	m#<mojikyo>(.*)</mojikyo>#; $d1=$1;
  	$_=<T>; chomp;	m#<entity>(.*)</entity>#;   $ent="&$1;";
  	$_=<T>; chomp;	m#<uni>(.*)</uni>#;         $uni="u$1";
  	                                            $uent = "&U-$1;";
  	$_=<T>; chomp;	m#<des>(.*)</des>#;         $zu=$1;
  	$_=<T>; chomp;	m#<nor>(.*)</nor>#;         $ty=$1;
  	$_=<T>; chomp;	m#<ref>(.*)</ref>#;         $ref=$1;
  	$_=<T>; chomp;	m#<exm>(.*)</exm>#;         $exm=$1;

  	next if ($cb =~ /^#/);
  	
  	$ty = "" if ($ty =~ /none/i);
  	$ty = "" if ($ty =~ /\x3f/);
  	if ($ent =~ /^[\?\x80-\xfe]/){
  		$ent ="&$d1;";
  	}
  	die "$_\n" if ($ent !~ /\&/);
  	die if ($ty =~ /\?/);
  	$mojikyo{$zu} = $d1;
  }
}

#replaces gaiji with entities
sub rep {
	local($quezi) = $_[0];
	if ($quezi eq "[¤O]" or $quezi =~ /No. \d+/) { return $quezi; }
	if ($quezi !~ /\W+[\+\-*\/]\W+/) { return $quezi; }
#	print STDERR "$quezi\t$qz{$quezi}\n";
	if ($mojikyo{$quezi} eq ""){
###new
		#print STDERR "767 $quezi not found!!\n";
		return $quezi;
	}
	return "&$mojikyo{$quezi};";
}
