#---------------------------------------------------------------
# count.pl
# v1, written by �P���H 2002/9/2 04:18PM
# v2, 2002/9/2, �� �]����r
# v3, "�D" �]����r, 2002/10/29 10:18AM by Ray
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
$s=~s#�i�ϡj##g;

$count=0;
$s=~s/($big5)/&rep($1)/eg;
print $count;

sub rep {
	$c=shift;
	if ($c eq "�C" or $c eq "�@" or $c eq "�E" or $c eq "�D" or $c eq "�]" or $c eq "�^" or $c eq "(" or $c eq ")" or $c eq "&lac;" or $c eq "��") {
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
