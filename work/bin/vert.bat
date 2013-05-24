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

require "utf8.pl";
$file = shift;
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

open (F, "$file");
$ofile = $file;
$ofile =~ s/\\[^\\]*$//;
binmode(F);
while(<F>){
	s/<[^>]*>//;
	$f = $1 if ($_ =~ /($pattern)/ );
	if ($f ne $oldf){
		$oldf = $f;
		($f1, $f2) = split(//, &toucs2($f));
		if ($f2 ne $oldf2){
			$oldf2 = $f2;
		open(OF,	sprintf(">>$ofile\\%2.2X.TSY", ord($f2))); 
		select (OF);
		binmode(OF);
		}
	}
	print;
}


__END__
:endofperl
