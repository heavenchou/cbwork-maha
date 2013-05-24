#require "add.plx";
$vol = shift(@ARGV);
$dir = shift(@ARGV);
print STDERR "$vol $dir\n";
open (ERR, ">$vol.err");

$pat = '\xc0([\x30-\x39\x41-\x5a\x61-\x7a\xa0-\xbf]{3})|([0-9]{1,2})|(.)';
$pat1 = '[\x30-\xbf]{3}';

sub numerically { $a <=> $b; }

sub fig{
	local($loc) = $_[0];
		$loc =~ s/://g;
		$loc =~ s/\&I-303431;/0/g;
		$loc =~ s/\&I-304546;/1/g;
		$loc =~ s/\&I-304547;/2/g;
		$loc =~ s/\&I-304548;/3/g;
		$loc =~ s/\&I-304549;/4/g;
		$loc =~ s/\&I-30454A;/5/g;
		$loc =~ s/\&I-30454B;/6/g;
		$loc =~ s/\&I-30454C;/7/g;
		$loc =~ s/\&I-30454D;/8/g;
		$loc =~ s/\&I-30454E;/9/g;
		$loc =~ s/\&I-30454F;/0/g;
		$loc =~ s/�@/1/g;
		$loc =~ s/�G/2/g;
		$loc =~ s/�T/3/g;
		$loc =~ s/�\|/4/g;
		$loc =~ s/��/5/g;
		$loc =~ s/��/6/g;
		$loc =~ s/�C/7/g;
		$loc =~ s/�K/8/g;
		$loc =~ s/�E/9/g;
		$loc =~ s/�Q/10/g;
		$loc =~ s/��/100/g;
		$loc =~ s/��/0/g;
		$loc =~ s/\s+//g;
		return $loc;
}


#require "ci2ce.plx";


opendir(THISDIR, $dir);
@allfiles = sort numerically readdir(THISDIR);
closedir(THISDIR);
for $file (@allfiles){
next if ($file =~ /^\./);
open(FILE, "$dir\\$file") || print STDERR "can't open $dir\\$file\n";
print STDERR "$dir\\$file\n";
while(<FILE>){


	next if (/^~/);
	chop;
	
	if (/(.*)?�g��\s?:(.*)/){
		$ind = $1;
#		print STDERR "$2\n";
		$num = &fig($2);
		if (($num > ($oldnum + 1))|| $num < $oldnum ){
			print STDERR "$_\t$num\t$oldnum\t$numcnt\n";
			print ERR "$_\t$num\t$oldnum\t$numcnt\n";
			if ($numcnt < 0){
				$num = $oldnum;
				$numcnt++;
			} else {
				$oldnum = $num;
				$numcnt = 0;
			}
		} else {
			$oldnum = $num;
			$numcnt = 0;
		}
		next;
	}
	
	s/^$ind//;
	
	if (/����\s?:(.*)/){
#		print STDERR "$1\n";
		$sz = &fig($1);
#		print STDERR "$sz\n";
		if (($sz > ($oldsz + 1)) || $sz < $oldsz ){
			print STDERR "$_\t$sz\t$oldsz\t$szcnt\n";
			print ERR "$_\t$sz\t$oldsz\t$szcnt\n";
			if ( $szcnt < 0){
				$sz = $oldsz + 1 ;
				$szcnt++;
			} else {
				$oldsz = $sz;
			}
		} else {
			$szcnt = 0;
		}
		$oldsz = $sz;
		next;
	}
	
	if (/�g�W\s?:(.*)/){
#		$sz = &fig($1);
		$ming{$_}++;
		next;
	}
    if (/(�U|��|�W)\s+��/){
    if (/�U\s+��/){
    	$col = "c";
		$ln = 0;
		next;
    }
    if (/��\s+��/){
    	$col = "b";
		$ln = 0;
		next;
    }
    if (/�W\s+��/){
    	$col = "a";
		$ln = 0;
		next;
    }
    if (($col eq "a" && $oldcol ne "c") || ($col eq "b" && $oldcol ne "a") || ($col eq "c" && $oldcol ne "b")){
    	print STDERR "$_\t$oldcol\t$col\n";
    } else {
    	$oldcol = $col;
    }
    }
    
	next if (/^\s+?$/);    
	next if (/^$/);    
   s/([0-9]{1,2})/sprintf("[%2.2d]", $1)/eg;
	$ln++;	
	printf("T%2.2dn%4.4d_p%4.4d$col%2.2d��$_\n", $vol, $num, $sz, $ln);
}
}

for $k (sort(keys(%ming))){
#	printf("%4.4d\t$k\n" , $ming{$k});
}
