#---------------------------------------------------------------
# count.pl
# v1, written by 周邦信 2002/9/2 04:18PM
# v2, 2002/9/2, ◎ 也不算字
# v3, "．" 也不算字, 2002/10/29 10:18AM by Ray
#---------------------------------------------------------------
$f=shift;
open I,$f or die;

my $big5 = '&[^;]*?;|[\x00-\x7f]|[\x80-\xff][\x00-\xff]';

$s='';
while (<I>) {
	chomp;
	$s.=$_;
}

$s=~s#<rdg.*?>.*?</rdg>##g;
$s=~s#<.*?>##g;
$s=~s#【圖】##g;

$count=0;
$s=~s/($big5)/&rep($1)/eg;
print $count;

sub rep {
	$c=shift;
	if ($c eq "。" or $c eq "　" or $c eq "‧" or $c eq "．" or $c eq "（" or $c eq "）" or $c eq "(" or $c eq ")" or $c eq "&lac;" or $c eq "◎") {
		return;
	}
	if ($c eq "&CI0013;") {
		$count += 4;
		return;
	}
	if ($c =~ /^&CI/) {
		$count +=2;
		return;
	}
	$count++;
}
