sub cNum {
	my $num = shift;
	my $i, $str;
	my @char=("","ˆê","“ñ","O","l","ŒÜ","˜Z","µ","”ª","‹ã");

	$i = int($num/100);
	$str = $char[$i];
	if ($i != 0) { $str .= "•S"; }
	
	$num = $num % 100;
	$i = int($num/10);
	if ($i==0) {
		if ($str ne "" and $num != 0) { $str .= "—ë"; }
	} else {
		if ($i ==1) {
			if ($str eq "") {
				$str = '\\';
			} else {
				$str .= 'ˆê\\';
 			}
		} else {
 		  $str .= $char[$i] . '\\';
 		}
 	}
	
 	$i = $num % 10;
 	$str .= $char[$i];
 	return $str;
}

# ’†•¶Éš -> ˆ¢f”ŒÉš
# created by Ray 2000/2/21 04:39PM
sub cn2an {
	my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	my %map = (
    '›',0,
    'ˆê',1,
 	  '“ñ',2,
 	  'O',3,
 	  'l',4,
 	  'ŒÜ',5,
 	  '˜Z',6,
 	  'µ',7,
 	  '”ª',8,
 	  '‹ã',9
  );
	my @chars = ();
	push(@chars, $s =~ /$big5/g);
	
	my $result=0;
	my $n=0;
	my $old='';
	foreach $c (@chars) {
		if ($c eq '•S') { 
			$result += $n*100; $n=0;
		} elsif ($c eq '\\') { 
		  if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
		} elsif (exists $map{$c}) { 
		  if (($n%10) != 0 or $old eq '›') { $n *= 10; }
		  $n += $map{$c}; 
		}
		$old = $c;
	}
	$result += $n;
	if ($result == 0) { $result=''; }
	else { $result=sprintf('%d',$result); }
	return $result;
}


1;
