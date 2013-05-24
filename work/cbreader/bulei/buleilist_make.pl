
open IN, "c:/cbwork/work/cbreader/bulei/bulei1_orig.txt" or die "open error";
@lines = <IN>;
close IN;

open OUT, ">BuleiList.txt";

my $nowpart;

for($i =0; $i<=$#lines; $i++)
{
	
#01 ���t���� T01-02,25,33
#	T0001-25 �����t�g�� T01
#		T0001 �����t�g22��
#		T0002-25 �����t�g�楻
#			T0002 �C��g1��

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
		$body[$i] = "T0220" if($body[$i] eq "T0220a");	# �B�z�j��Y�g
		next if($body[$i] =~ /T0220[b-o]/);
		print OUT "#" if($body[$i] eq "T0310(5)");		# �L�X #16,T0310(5)
		$body[$i] = "X1568" if($body[$i] eq "X1568a");	# �B�z��U���g
		next if($body[$i] eq "X1568b");					# �B�z��U���g
		$body[$i] = "X1571" if($body[$i] eq "X1571a");	# �B�z��U���g
		next if($body[$i] eq "X1571b");					# �B�z��U���g
		$body[$i] = "X0240" if($body[$i] eq "X0240a");	# �B�z��U���g
		next if($body[$i] eq "X0240b");					# �B�z��U���g
		$body[$i] = "X0367" if($body[$i] eq "X0367a");	# �B�z��U���g
		next if($body[$i] eq "X0367b");					# �B�z��U���g
		$body[$i] = "X0714" if($body[$i] eq "X0714a");	# �B�z��U���g
		next if($body[$i] eq "X0714b");					# �B�z��U���g
		$body[$i] = "X0822" if($body[$i] eq "X0822a");	# �B�z��U���g
		next if($body[$i] eq "X0822b");					# �B�z��U���g
		
		print OUT "$nowpart,$body[$i]\n";
	}
}

print OUT "$nowpart,$body[$#lines]\n";

close OUT;