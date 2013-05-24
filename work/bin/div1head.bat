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

$vol = shift;
$vol = uc($vol);

open (CFG, "../bin/CBETA.CFG") || die "can't open cbeta.cfg\n";

while(<CFG>){
	next if (/^#/); #comments
	chop;
	($key, $val) = split(/=/, $_);
	$key = uc($key);
	$cfg{$key}=$val; #store cfg values
	#print "$key\t$cfg{$key}\n";
}

opendir (INDIR, $cfg{"DIR"} . "\\$vol");
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "head.pl";
$utf8out{"\xe2\x97\x8e"} = '';

mkdir($cfg{"OUTDIR"} . "\\DIV1HEAD", MODE);
$of = $cfg{"OUTDIR"} . "\\DIV1HEAD\\$vol.txt";
open (OF, ">$of");
print STDERR " --> $of\n";
select(OF);


use XML::Parser;


my %Entities = ();
my $ent;
my $val;
my $text;

sub openent{
	local($file) = $_[0];
	local($k) = "." . $cfg{"CHAR"};
 	$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
 	$file =~ s#/#\\#g;
 	$file =~ s/\.\./$cfg{"DIR"}/;
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		s/\s+>$//;
		($ent, $val) = split(/\s+/);
		$val =~ s/"//g;
		$Entities{$ent} = $val;
	}
}


sub default {
    my $p = shift;
    my $string = shift;
    $string =~ s/^\&(.+);$/&rep($1)/eg;
#    $string =~ s/^\&(\w+)\;$/$Entities{$1}/;
	$bib .= $string if ($bibl == 1);
	$text .= $string if ($pass == 0);
}

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$inxu = 0;
#!> 	$fileopen = 0;
#!> 	$num = 0;
	$close = "";
}



sub start_handler 
{
	my $p = shift;
	$el = shift;
	my (%att) = @_;
	if ($el eq "head") {
	  $text="";
	}
}

sub rep{
	local($x) = $_[0];
	return $Entities{$x} if defined($Entities{$x});
	die "Unknkown entity $x!!\n";
	return $x;
}


sub end_handler 
{
	my $p = shift;
	my $el = shift;
	my $parent = lc($p->current_element);
	if ($el eq "head" && $parent eq "div1" ) {
	  print $text,"\n";
	}
}

sub char_handler 
{
	my $p = shift;
	my $char = shift;

	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	my $parent = lc($p->current_element);
  if ($parent eq "app") { return; }

	$char =~ s/($pattern)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	$bib .= $char if ($bibl == 1);
  if ($parent eq "head") { 	$text .= $char; }
}


sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
	return 1;
}



my $parser = new XML::Parser(Style => Stream, NoExpand => True);


$parser->setHandlers
				(Start => \&start_handler,
				Init => \&init_handler,
				End => \&end_handler,
		     	Char  => \&char_handler,
		     	Entity => \&entity,
		     	Default => \&default);

for $file (sort(@allfiles)){
  print STDERR "$file\n";
  print "\n$file\n";
  $parser->parsefile($file);
}


__END__
:endofperl
