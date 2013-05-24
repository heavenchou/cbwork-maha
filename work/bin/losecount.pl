############################################
#
# 執行本程式, 會統計缺字的使用頻率
#
# $Id: losecount.pl,v 1.1.1.1 2003/05/05 04:06:59 ray Exp $
#
############################################

my %gaiji_nr ;
my %gaiji_zu;
my %gaiji_mojikyo;
my %gaiji_cb;		# 表示資料庫有此字
my %count;
my %countt;

$to = 85;	# 要執行到第幾冊?


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
\# ? 開頭表示資料庫當中無此字, 也可能是資料庫有點問題.
\# 最底下的資料是資料庫有, 但沒有出現在經文中的 CB 碼
\#
\#  CB碼     總頻次    M碼      通用字                                  組 字 式     各冊出現的頻次, 依序第一冊, 第二冊.....每五冊出現冊號
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
	
	# 印出沒出現的缺字
	
	print OUT "\n\n############################################################\n#\n";
	print OUT "# 這些缺字有出現在資料庫裡, 但卻沒有出現在經文中.\n#\n";
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
				$count{$cb}++;		# 全部統計
				$countt{$cbt}++;		# 各冊統計
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
		$zu      = $row{"des"};			# 組字式
		#$ent     = $row{"entity"};
		#$uni     = $row{"uni"};
		$ty      = $row{"nor"};		# 通用字

		next if ($cb =~ /^#/);

		#$ty = "" if ($ty =~ /none/i);
		#$ty = "" if ($ty =~ /\x3f/);

		#die "ty=[$ty]" if ($ty =~ /\?/);

		$gaiji_nr{$cb} = $ty;
		$gaiji_zu{$cb} = $zu;
		$gaiji_mojikyo{$cb} = $mojikyo;
		$gaiji_cb{$cb} = 1;		# 表示資料庫有此字
		#$gaiji_ent{$cb} = $ent;
	}
	$db->Close();
	print STDERR " ok\n";
}