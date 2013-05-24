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
    if ($c eq "百") { $result += $n*100; $n=0;}
    elsif ($c eq "十") { 
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


1;
