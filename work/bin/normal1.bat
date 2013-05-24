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
$file = "CBETA.CFG";
if ($vol eq ""){
	print "\t$0: Produces CBETA Normal1 Files from XML source\nUsage: \n\t$0 T10\n";
	print "T10 is the subdirectory where the XML files are found\n";
	print "The program also needs a config file CBETA.CFG\n";
	print "The config file should to be in the current directory or in the directory of this program\n";
	print "\tConfig File Format SAMPLE:\n\nDIR=C:\\CBETA\\T10\n";
	print "OUTDIR=C:\\RELEASE\n";
	print "#CHAR can be NOR or ORG\n";
	print "CHAR=NOR\n";   
	exit;
}
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
	$key = uc($key);
	$cfg{$key}=$val; #store cfg values
	print "$key\t$cfg{$key}\n";
}

mkdir($cfg{"OUTDIR"}, MODE);
mkdir($cfg{"OUTDIR"} . "\\NORMAL1", MODE);

opendir (INDIR, $cfg{"DIR"} . "\\$vol");

@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "head.pl";
$utf8out{"\xe2\x97\x8e"} = '';

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
#	print STDERR "$file\n";
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
#	print STDERR $string if ($pass == 0);
#	print $string if ($pass == 0);
#	print STDERR "$string\n";
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
	$pass++ if $el eq "rdg";
	$pass++ if $el eq "gloss";

	if ($el eq "head" && lc($att{"type"}) eq "added"){
		$pass++;
		$added = 1;
	}

	$head = 1 if $el eq "teiheader";  #We are in the header now!
	$pass = 0 if $el eq "body";
	if ($head == 1){
		$bibl = 1 if ($el =~ /^bibl|title|p$/);
	}
	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}
	}

	if ($el eq "note" && lc($att{"type"}) eq "inline"){
		# 不在 <rdg> 裏才要顯示 <note>
		if ($pass==0) {
		  $text .= "(";
		  $close = ")";
		}
	}

	if ($el eq "p" && lc($att{"type"}) eq "inline"){
#		print "(";
		$text .= "。";
	}

	if ($el eq "p" && lc($att{"type"}) eq "w"){
		$text .= "　";
		$indent = "　";
	}
	
	# added by Ray 1999.10.7
	if ($el eq "item"){
	  my $rend = $att{"rend"};
	  $rend =~ s/($pattern)/$utf8out{$1}/g;
		$text .= $rend;
	}

	$text .= "　" if $el eq "l";
#	print "　" if $el eq "l";
	if ($el eq "byline"){
		$text .= "　　　　" ;
#		print "　　　　" ;
		$indent = "　　　　";
	}

	if ($el eq "head" && lc($att{"type"}) ne "added" && $inxu==0){
		$text .=	"　　" ;
		$indent = "　　" ;
	}

	if ($el eq "lb"){
		$lb = $att{"n"};
		#the whole line has been cached to $text, print it now!
		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		$text =~ s/\[[0-9（[0-9珠\]//g;
		$text =~ s/#[0-9][0-9]#//g;
		print "$text";
		$text = "";
		print "\n$vl$lb║$indent";
	} elsif ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
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
	
	$head = 0 if $el eq "teiheader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";
	if ($el eq "head" && $added == 1){
		$pass--;
		$added = 0;
	}
	$indent = "" if ($el eq "byline");
	$text .="　" if $el eq "l";
#	print "　" if $el eq "l";
	if ($el eq "head"){
		$indent = "" ;
	}

	if ($el eq "note"){
		$text .= $close if ($close ne "");
#		print $close if ($close ne "");
		$close = "";
	}
	
	if ($el eq "bibl"){
		$bibl = 0;
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			if ($3 eq ""){
				$c = "_";
			} else {
				$c = $3;
			}
			#print the rest of the line of the old file!
			$vl = sprintf("T%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("T%2.2d", $1);
			mkdir($cfg{"OUTDIR"} . "\\NORMAL1\\$od", MODE);
			$c = "n" if ($c eq "_");
			$of = $cfg{"OUTDIR"} . sprintf("\\NORMAL1\\$od\\T%2.2d$c%4.4d.txt", $1, $2);
			$text =~ s/\n//;
			$text =~ s/\x0d$//;
			print "$text\n";

			open (OF, ">$of");
			print STDERR " --> $of\n";
			select(OF);
		}
		$bib =~ s/^\t+//;
		$ebib = $bib;
	}

	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
#		die;
	}

	if ($el eq "div1"){
		$inxu = 0;
	}

	if ($el eq "p"){
		$bib =~ s/^\t+//;
		$ly{$lang} = $bib;
	  $indent="";  # added by Ray 1999.10.5
	}

	if ($el eq "teiheader"){
		head("普及版","normalized version");
		$text = "";
	}
	$lang = "" if ($el eq "p");
	if ($el eq "tei.2"){
		$text =~ s/\[[0-9（[0-9珠\]//g;
		$text =~ s/#[0-9][0-9]#//g;
		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		
		print OF $text;
		$text = "";
		close (OF);
		$vl = "";
		$num = 0;
	}
#	print "$text";
	$bib = "";
#	print STDERR "$pass\n";
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
	$text .= $char if (($pass == 0 && $el ne "pb"));
#	print $char if ($pass == 0 && $el ne "pb");
}


sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
#	print STDERR "$ent\t$entval\t$next\n";
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
	print STDERR "$file\t";
	$parser->parsefile($file);
#	die;
}
print STDERR "Done!!\n";




__END__
:endofperl
