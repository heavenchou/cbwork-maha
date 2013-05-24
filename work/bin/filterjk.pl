# 過濾已知類型的校勘
require "b52utf8.plx";
require "subutf8.pl";
open I, "c:/cbwork/work/footnote/T01校勘條目.txt" or dir;
while(<I>) {
	chomp;
	$_ = b52utf8($_);
	
	if (/^#/) {
		next;
	}
	
	if (/^p\d+$/) {
		$pb = $_;
		next;
	}
	
	s/^(  \d\d )//;
	$lb = $1;
		
	if (/^.*?＝.*?【.*?】(＊)?(～.*?)?$/) {
		next;
	}
	
	if (/^（.*?）＋.*?【.*?】$/) {
		next;
	}
	
	if (/^.*?＋（.*?）【.*?】$/) {
		next;
	}

	if (/^〔.*?〕－【.*?】$/) {
		next;
	}
	print "$pb$lb$_\n";
}