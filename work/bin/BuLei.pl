$dir = "c:/work/cbetaNormal整套不重複";

$big5 = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

open O, ">c:/cbwork/work/bin/BuLei.txt" or die "open error";
do1dir('',$dir);
close O;

sub do1dir {
	my ($pre, $dir) = @_;
	print STDERR "$dir\n";
	opendir DIR, $dir or die "open dir error";
	my @files = grep !/^\.\.?$/, readdir DIR;
	close DIR;
	my $file, $s;
	my $count=0;
	foreach $file (sort @files) {
		if (-d "$dir/$file") {
			$count ++;
			$s = sprintf("%3.3d",$count);
			my $new = add_space($file);
			print O "$pre$s##$new\n";
			do1dir("$pre$s","$dir/$file");
		}
	}
}

sub add_space {
	my $old = shift;
	my @a=();
	push(@a, $old =~ /$big5/g);
	my $new='';
	my $c, $old_c='';
	foreach $c (@a) {
		if ($c eq '(') { 
			$in_parentheses=1; 
		} elsif ($c eq ')') {
			$in_parentheses=0;
		} else {
			my $len1 = length($old_c);
			my $len2 = length($c);
			if ($old_c eq ';') { $len1 = 2; }
			if ($c eq '&') { $len2 = 2; }
			if ( not $in_parentheses and $old_c ne '' and $len1!=$len2 and 
				$old_c !~ m#^( |\(|／)$# and
				$c !~ m#^(/|卷|\(|\)| |／)$#) {
				$new .= ' ';
			}
		}
		$new .= $c;
		$old_c = $c;
	}
	if ($new =~ /^(.*?)第 ([\w\-]*?) \xb7\x7c(.*?)$/) {
		print STDERR "$new\n";
		$new =~ s/^(.*?)第 ([\w\-]*?) \xb7\x7c(.*?)$/$1第$2會$3/;
		print STDERR "1 $1 2 $2 3 $3\n";
		print STDERR "$new\n";
	}
	return $new;
}