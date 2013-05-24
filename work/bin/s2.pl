push(@INC, "C:\\cbwork\\bin");
require "s2ref.plx";
# modified by Ray 2000/6/15 08:47AM
#$subpat = '[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|\[[0-9¡][0-9¯]\]|[\'`Aa\.\^iu~][AadhilmnrstuS]|[\x00-\xff\n]';
$subpat = '[\xa1-\xfe][\x40-\xfe]|&[^;]*;|<[^>]*>|\[[0-9¡][0-9¯]\]|aa|AA|ii|uu|\'s|[`\.\^~][AadhilmnrstuS]|[\x00-\xff\n]';

while(<>){
	push(@chars, /$subpat/g);
	foreach $var (@chars){
		$var = $s2ref{$var} if ($s2ref{$var} ne "");
	}
	print join("", @chars);
	@chars = ();
}