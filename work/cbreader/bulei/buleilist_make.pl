
open IN, "c:/cbwork/work/cbreader/bulei/bulei1_orig.txt" or die "open error";
@lines = <IN>;
close IN;

open OUT, ">BuleiList.txt";

my $nowpart;

for($i =0; $i<=$#lines; $i++)
{
	
#01 阿含部類 T01-02,25,33
#	T0001-25 長阿含經類 T01
#		T0001 長阿含經22卷
#		T0002-25 長阿含經單本
#			T0002 七佛經1卷

	$lines[$i] =~ /^(\s*)(\S+)\s/;
	$head[$i] = $1;
	$body[$i] = $2;
}

for($i =0; $i<$#lines; $i++)
{
	if($head[$i] eq "")
	{
		$nowpart = $body[$i];
	}
	elsif(length($head[$i])>=length($head[$i+1]))
	{
		$body[$i] = "T0220" if($body[$i] eq "T0220a");	# 處理大般若經
		next if($body[$i] =~ /T0220[b-o]/);
		print OUT "#" if($body[$i] eq "T0310(5)");		# 印出 #16,T0310(5)
		$body[$i] = "X1568" if($body[$i] eq "X1568a");	# 處理跨冊的經
		next if($body[$i] eq "X1568b");					# 處理跨冊的經
		$body[$i] = "X1571" if($body[$i] eq "X1571a");	# 處理跨冊的經
		next if($body[$i] eq "X1571b");					# 處理跨冊的經
		$body[$i] = "X0240" if($body[$i] eq "X0240a");	# 處理跨冊的經
		next if($body[$i] eq "X0240b");					# 處理跨冊的經
		$body[$i] = "X0367" if($body[$i] eq "X0367a");	# 處理跨冊的經
		next if($body[$i] eq "X0367b");					# 處理跨冊的經
		$body[$i] = "X0714" if($body[$i] eq "X0714a");	# 處理跨冊的經
		next if($body[$i] eq "X0714b");					# 處理跨冊的經
		$body[$i] = "X0822" if($body[$i] eq "X0822a");	# 處理跨冊的經
		next if($body[$i] eq "X0822b");					# 處理跨冊的經
		
		print OUT "$nowpart,$body[$i]\n";
	}
}

print OUT "$nowpart,$body[$#lines]\n";

close OUT;