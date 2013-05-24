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

$crlfu="\x0d\x00\x0a\x00";
$tabu="\x09\x00";
require "utf8.pl";
$file = "CBIND.CFG";

if (open (CFG, $file)){
} else {
	$f = $0;
	$f =~ s/\/.*//;
	open (CFG, "$f\\$file") || die "can't open neither $file nor $f\\$file!!\n";
}


while(<CFG>){
	next if (/^#/); #comments
	chop;
	($key, $val) = split(/=/, $_);
	$key = lc($key);
	if ($key =~ s/^<//){
		@v = split(/\&/, $val);
		for $v (@v){
			($vkey, $vval) = split(/:/, $v);
			if ($vval ne ""){
				$tags{"$key:$vkey"} = "$vval";
#				print "$key:$vkey=$vval\n";
			} else {
				$tags{"$key"} = "$vkey";
#				print "$key=$vkey\n";
			}
		}
	} else {
		$cfg{$key}=$val; #store cfg values
		print "$key\t$cfg{$key}\n";
	}
}
opendir (INDIR, $cfg{"outdir"} . "\\Index");


@allfiles = grep(/\.tty$/i, readdir(INDIR));

for $_ (@allfiles){
	$_ = uc($_);
}

die "No files to process\n" unless @allfiles;

###

open (F, ">$cfg{'outdir'}\\Index\\Taisho.dic");


open (JDX, ">$jfile");
open (JDX, ">$cfg{'outdir'}\\Index\\Taisho.jdx");
binmode(JDX);

#open (P, ">prot.txt");
binmode(F);
select(F);

print "\xff\xfe#\x00D\x00I\x00C\x001\x00 \x00";
for $file (sort(@allfiles)){
print STDERR "$file\n";
open (IN, $cfg{"outdir"} . "\\Index\\$file" );
while(<IN>){
	chop;
	($ent, $ref) = split(/\t/);
	if ($ent eq $oldent){
		print  &enc($ref);
	} else {
#print location in file to JDX file, add 4 because we not have the linebreak yet
		print JDX pack("L", tell(F) + 4 );
#		print JDX  tell(F)+4, "\n";
		print $crlfu, &toucs2($ent),  $tabu, &enc($ref);
	}
	$oldent = $ent;
#	print STDERR $ref, $ent, "\n";
}

}

sub enc{
	my $ref = shift;
	if (length($ref) > 7){
		$x = substr($ref, 7, 1);
		#	print STDERR substr($ref, 7, 1), "\t";
		if ($x == 2){
			$x = 4;
		} elsif ($x == 3){
			$x =  7;
		} elsif ($x == 4){
			$x =  2;
		} elsif ($x == 6){
			$x =  8;
		}
		substr($ref, 7, 1) = $x;
	}
#	print STDERR substr($ref, 7, 1), "\n";
	my $r1 = int($ref / 4294967296);
	my $r2 = $ref - ($r1* 4294967296);
	return pack("sss", $r1 , int($r2 / 65536), $r2 % 65536);
}

__END__
:endofperl
