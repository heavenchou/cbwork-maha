while(<>){
	chop;
	open(F, $_);
	$f = $_;
	while(<F>){
		chop;
#		if (/Y CB/ && !/mojikyo/ && !/nor/){
#			$noent{"$_:$f"}++ ;
			$noent{"$_"}++ ;
#			print "$f:$_";
#		}
	}
}

for $k (sort(keys(%noent))){
	print "$k\n";
}