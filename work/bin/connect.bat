del alltxt.txt
@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
goto endofperl
@rem ';
#!perl
#line 14

my $outfile = shift;	# 傳入的參數, 這是結果檔

if($outfile eq "")
{
	$outfile = "alltxt.txt";
}

@file = <*.txt>;
open OUT, ">$outfile";
foreach $filename (sort (@file))
{
	print STDERR "$filename\n";
	my $linenum = 0;
	open IN, "$filename" || die "open error:$filename $!";
	while (<IN>)
	{
		chomp ;
		# 處理版本記錄的日期與版本
		#【版本記錄】CBETA 電子佛典 V1.0 (Big5) 普及版，完成日期：2003/08/29
		#【版本記錄】CBETA 電子佛典 Vv.v (Big5) 普及版，完成日期：yyyy/mm/dd
		# CBETA Chinese Electronic Tripitaka V1.0 (Big5) Normalized Version, Release Date: 2003/08/29
		# CBETA Chinese Electronic Tripitaka Vv.v (Big5) Normalized Version, Release Date: yyyy/mm/dd
		s/V\d+\.\d+/Vv.v/;
		s/\d{4}\/\d+\/\d+/yyyy\/mm\/dd/;
		print OUT "$_\n";
		$linenum++;
		last if($linenum > 10);	# 只在前 10 行比對
	}
	while (<IN>)
	{
		chomp ;
		print OUT "$_\n";
	}
	close IN;
}
close OUT;

__END__
:endofperl
