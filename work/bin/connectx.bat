del allxml.txt
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

@file = <*.xml>;
open OUT, ">allxml.txt";
foreach $filename (sort (@file))
{
	print STDERR "$filename\n";
	open IN, "$filename" || die "open error:$filename $!";
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