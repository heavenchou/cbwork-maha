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

opendir DIR, ".";
@all = readdir DIR;
close DIR;
foreach $file (@all) {
	if (not $file=~/\.xml$/) { next; }
	$file =~ s/\.xml$//;
	print STDERR "$file\n";
	system "c:\\bin\\w32\\sp\\bin\\nsgmls.exe -e -s -E20 -f$file.err c:\\bin\\w32\\sp\\pubtext\\xml.dcl $file.xml";
}
#system "dir *.err /OS";
print STDERR "\n";
opendir DIR, ".";
@all = grep(/\.err$/i, readdir(DIR));
foreach $file (@all) {
	if (-s $file) {
		print STDERR "$file parse error\n";
	}
	unlink $file;
}

__END__
:endofperl
