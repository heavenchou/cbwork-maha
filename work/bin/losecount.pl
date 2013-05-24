############################################
#
# ���楻�{��, �|�έp�ʦr���ϥ��W�v
#
# $Id: losecount.pl,v 1.1.1.1 2003/05/05 04:06:59 ray Exp $
#
############################################

my %gaiji_nr ;
my %gaiji_zu;
my %gaiji_mojikyo;
my %gaiji_cb;		# ��ܸ�Ʈw�����r
my %count;
my %countt;

$to = 85;	# �n�����ĴX�U?


readGaiji();

for($i=1; $i<=$to; $i++)
{
	$i = 85 if $i == 56;
	
	$vol = sprintf("T%02d",$i);
	print "run $vol ...";
	run($vol);
	print " ok\n";
}

open OUT, ">losecount.txt";
output();
close OUT;
exit;

############################33

sub output()
{
	my $cb;
	my $tmp;
	
print OUT << "HEAD";
\# ? �}�Y��ܸ�Ʈw���L���r, �]�i��O��Ʈw���I���D.
\# �̩��U����ƬO��Ʈw��, ���S���X�{�b�g�夤�� CB �X
\#
\#  CB�X     �`�W��    M�X      �q�Φr                                  �� �r ��     �U�U�X�{���W��, �̧ǲĤ@�U, �ĤG�U.....�C���U�X�{�U��
\#======================================================================================================
HEAD

	foreach $cb (sort(keys(%count)))
	{
		if($gaiji_cb{$cb})
		{
			print OUT "  ";
		}
		else
		{
			print OUT "? ";
		}
		
		print OUT "&CB${cb}; ";

		$tmp = sprintf("%6d",$count{$cb});
		print OUT "$tmp ";

		$tmp = sprintf("%7s",$gaiji_mojikyo{$cb});
		print OUT "$tmp ";
		
		$tmp = sprintf("%10s",$gaiji_nr{$cb});
		print OUT "$tmp ";

		$tmp = sprintf("%45s",$gaiji_zu{$cb});
		print OUT "$tmp ";
		
		for(my $i=1; $i<=$to; $i++)
		{
			$i = 85 if $i == 56;
			
			$vol = sprintf("T%02d",$i);
			$cbt = "$cb$vol";
			$tmp = sprintf("%5d",$countt{$cbt});
			if($i%5 == 1)
			{
				print OUT "$vol:$tmp ";
			}
			else
			{
				print OUT "$tmp ";
			}
		}
		print OUT "\n";
	}
	
	# �L�X�S�X�{���ʦr
	
	print OUT "\n\n############################################################\n#\n";
	print OUT "# �o�ǯʦr���X�{�b��Ʈw��, ���o�S���X�{�b�g�夤.\n#\n";
	print OUT "############################################################\n\n";
	foreach $cb (sort(keys(%gaiji_cb)))
	{
		if(!$count{$cb})
		{
			print OUT "&CB${cb};  $gaiji_zu{$cb}   $gaiji_nr{$cb}\n";
		}
	}
	
}

sub run()
{
	local $_;
	my $vol = shift;
	my @files = <c:/cbwork/xml/$vol/*.xml>;
	my $file;
	my $cb;
	my $cbt;

	foreach $file (sort(@files))
	{
		open IN, "$file";
		while(<IN>)
		{
			while(/&C[Bx](.*?);/gi)
			{
				$cbt = "$cb$vol";
				$cb = $1;
				$count{$cb}++;		# �����έp
				$countt{$cbt}++;		# �U�U�έp
			}
		}
	}
}



sub readGaiji()
{
	my $cb;
	my $zu;
	#my $ent;
	my $mojikyo;
	#my $uni;
	my $ty;
	my %row;
	use Win32::ODBC;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow())
	{
		%row = $db->DataHash();

		$cb      = $row{"cb"};			# cbeta code
		$mojikyo = $row{"mojikyo"};		# mojikyo code
		$zu      = $row{"des"};			# �զr��
		#$ent     = $row{"entity"};
		#$uni     = $row{"uni"};
		$ty      = $row{"nor"};		# �q�Φr

		next if ($cb =~ /^#/);

		#$ty = "" if ($ty =~ /none/i);
		#$ty = "" if ($ty =~ /\x3f/);

		#die "ty=[$ty]" if ($ty =~ /\?/);

		$gaiji_nr{$cb} = $ty;
		$gaiji_zu{$cb} = $zu;
		$gaiji_mojikyo{$cb} = $mojikyo;
		$gaiji_cb{$cb} = 1;		# ��ܸ�Ʈw�����r
		#$gaiji_ent{$cb} = $ent;
	}
	$db->Close();
	print STDERR " ok\n";
}