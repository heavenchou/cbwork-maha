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

$file = shift;
$ofile = $file;
$ofile =~ s/\..*$/\.jdx/;
open (F, ">$ofile");

binmode(F);
select(F);

open (IN, $file);
while(<IN>){
	
}

__END__
:endofperl
