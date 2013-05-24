sub cNum {
	my $num = shift;
	my $i, $str;
	my @char=("","一","二","三","四","五","六","七","八","九");

	$i = int($num/100);
	$str = $char[$i];
	if ($i != 0) { $str .= "百"; }
	
	$num = $num % 100;
	$i = int($num/10);
	if ($i==0) {
		if ($str ne "" and $num != 0) { $str .= "零"; }
	} else {
		if ($i ==1) {
			if ($str eq "") {
				$str = "十";
			} else {
				$str .= "一十";
 			}
		} else {
 		  $str .= $char[$i] . "十";
 		}
 	}
	
 	$i = $num % 10;
 	$str .= $char[$i];
 	return $str;
}

# 中文數字 -> 阿拉伯數字
# created by Ray 2000/2/21 04:39PM
sub cn2an {
	my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my %map = (
    "○",0,
    "一",1,
 	  "二",2,
 	  "三",3,
 	  "四",4,
 	  "五",5,
 	  "六",6,
 	  "七",7,
 	  "八",8,
 	  "九",9
  );
	my @chars = ();
	push(@chars, $s =~ /$big5/g);
	
	my $result=0;
	my $n=0;
	my $old="";
	foreach $c (@chars) {
		if ($c eq "百") { 
			$result += $n*100; $n=0;
		} elsif ($c eq "十") { 
		  if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
		} elsif (exists $map{$c}) { 
		  if (($n%10) != 0 or $old eq "○") { $n *= 10; }
		  $n += $map{$c}; 
		}
		$old = $c;
	}
	$result += $n;
	if ($result == 0) { $result=""; }
	else { $result="$result"; }
	return $result;
}

sub b52utf8 {
	my $in = shift;
	my $big5 = "[\x00-\x7f]|[\x80-\xff][\x00-\xff]";
	my @a;
	my $temp='';
	push(@a, $in =~ /$big5/gs);
	my $s='', $c;
	foreach $c (@a) { 
		if ($b52utf8{$c} ne "") { 
			$temp .= $c;
			$c =  $b52utf8{$c}; 
		} else { 
			print STDERR "83 $in\n";
			print STDERR "84 $temp\n";
			die "subutf8.pl 85 Error: not in big52utf8 table. char:[$c] hex:" . unpack("H4",$c) ; 
		}
		$s.=$c; 
	}
	return $s;
}

sub getopts ($;$) {
    local($argumentative, $hash) = @_;
    local(@args,$_,$first,$rest);
    local($errs) = 0;
    local @EXPORT;

    @args = split( / */, $argumentative );
    while(@ARGV && ($_ = $ARGV[0]) =~ /^-(.)(.*)/) {
	($first,$rest) = ($1,$2);
	if (/^--$/) {	# early exit if --
	    shift @ARGV;
	    last;
	}
	$pos = index($argumentative,$first);
	if ($pos >= 0) {
	    if (defined($args[$pos+1]) and ($args[$pos+1] eq ':')) {
		shift(@ARGV);
		if ($rest eq '') {
		    ++$errs unless @ARGV;
		    $rest = shift(@ARGV);
		}
		if (ref $hash) {
		    $$hash{$first} = $rest;
		}
		else {
		    ${"opt_$first"} = $rest;
		    push( @EXPORT, "\$opt_$first" );
		}
	    }
	    else {
		if (ref $hash) {
		    $$hash{$first} = 1;
		}
		else {
		    ${"opt_$first"} = 1;
		    push( @EXPORT, "\$opt_$first" );
		}
		if ($rest eq '') {
		    shift(@ARGV);
		}
		else {
		    $ARGV[0] = "-$rest";
		}
	    }
	}
	else {
	    warn "Unknown option: $first\n";
	    ++$errs;
	    if ($rest ne '') {
		$ARGV[0] = "-$rest";
	    }
	    else {
		shift(@ARGV);
	    }
	}
    }
    unless (ref $hash) { 
	local $Exporter::ExportLevel = 1;
	import Getopt::Std;
    }
    $errs == 0;
}



1;
