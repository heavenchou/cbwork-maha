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

#
# xml2xml.bat
# 這個程式會讀入一個 XML, 輸出一個完全一樣的 XML
# created by Ray 2000/3/9 09:47AM
#
$vol = shift;
$inputFile = shift;

$chm;
$nid=0;
$vol = uc($vol);
$dir = "j:/bsin/cbeta/";
$vol = substr($vol,0,3);

mkdir($dir . "new-xml/" . $vol, MODE);

opendir (INDIR, $dir . $vol);
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "utf8b5o.plx";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;


my %Entities = ();
my %dia = (
 "Amacron","A^",
 "amacron","a^",
 "ddotblw","d!",
 "Ddotblw","D!",
 "hdotblw","h!",
 "imacron","i^",
 "ldotblw","l!",
 "Ldotblw","L!",
 "mdotabv","m%",
 "mdotblw","m!",
 "ndotabv","n%",
 "ndotblw","n!",
 "Ndotblw","N!",
 "ntilde","n~",
 "rdotblw","r!",
 "sacute","s/",
 "Sacute","S/",
 "sdotblw","s!",
 "Sdotblw","S!",
 "tdotblw","t!",
 "Tdotblw","T!",
 "umacron","u^"
);      
        
my $parser = new XML::Parser(NoExpand => True);
        
        
$parser->setHandlers
				(Start => \&start_handler,
				Init => \&init_handler,
				End => \&end_handler,
		     	Char  => \&char_handler,
		     	Entity => \&entity,
		     	Default => \&default);
        
if ($inputFile eq "") {
  for $file (sort(@allfiles)) { process1file($file); }
} else {
  $file = $inputFile;
  process1file($file);
}       
        
print STDERR "完成!!\n";
        
sub process1file {
  $file = shift;
  $file =~ s/^t/T/;
	print STDERR "\n$file\n";
  open O, ">${dir}new-xml/$vol/$file";
  select O;
	$parser->parsefile($file);
	close O;
}

#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	print STDERR "開啟 Entity 定義檔: $file\n";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		$Entities{$ent} = $ent;
		print STDERR "Entity: $ent -> $ent\n";
  }
}       
        
        
sub default {
    my $p = shift;
    my $string = shift;
  $string =~ s/^&(.+);$/$1/;
	if ( defined($Entities{$string}) )
    { print "&$string;"; }
}       
        
sub init_handler
{       
  my $s = $file;
  $s =~ s/\.xml/\.ent/;
	print <<"EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd"
[<!ENTITY % ENTY  SYSTEM "$s" >
<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
%ENTY;
%CBENT;
]>
EOD
}       
        
        
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);

  print "<$el";
  while (($key,$value) = each %att) {
    $value = myDecode($value);
    print " $key=\"$value\"";
  }
  if ($el eq "lb" or $el eq "pb") { print "/"; }
  print ">";
}       
        
sub rep{
	local($x) = $_[0];
	return $x;
}       
        
        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
  if ($el ne "lb" and $el ne "pb") { print "</$el>"; }
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	$char =~ s/($pattern)/$utf8out{$1}/g;
  print $char;
}       
        

sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
	return 1;
}       
        
        
sub myDecode {
  my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}

        
__END__ 
:endofperl
