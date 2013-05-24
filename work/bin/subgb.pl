sub cNum {
  my $num = shift;
 	my $i, $str;
 	my @char=("","һ","��","��","��","��","��","��","��","��");
 	
 	$i = int($num/100);
 	$str = $char[$i];
 	if ($i != 0) { $str .= "��"; }
 	
 	$num = $num % 100;
 	$i = int($num/10);
 	if ($i==0) {
 	  if ($str ne "" and $num != 0) { $str .= "��"; }
 	} else {
 		if ($i ==1) {
 			if ($str eq "") {
 				$str = "ʮ";
 		  } else {
 		  	$str .= "һʮ";
 			}
 	  } else {
 		  $str .= $char[$i] . "ʮ";
 		}
 	}
 	
 	$i = $num % 10;
 	$str .= $char[$i];
 	return $str;
}

# ���Ĕ��� -> ����������
# created by Ray 2000/2/21 04:39PM
sub cn2an {
  my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
  my %map = (
    "��",0,
    "һ",1,
 	  "��",2,
 	  "��",3,
 	  "��",4,
 	  "��",5,
 	  "��",6,
 	  "��",7,
 	  "��",8,
 	  "��",9
  );
  my @chars = ();
  push(@chars, $s =~ /$big5/g);
  
  my $result=0;
  my $n=0;
  my $old="";
  foreach $c (@chars) {
    if ($c eq "��") { $result += $n*100; $n=0;}
    elsif ($c eq "ʮ") { 
      if ($n==0) { $result+=10; } else { $result += $n*10; $n=0;}
    } elsif (exists $map{$c}) { 
      if (($n%10) != 0 or $old eq "��") { $n *= 10; }
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
