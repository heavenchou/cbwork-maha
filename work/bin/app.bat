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
$infile = shift;
$file = "CBETA.CFG";
if ($vol eq ""){
	print "\t$0: Produces CBETA Normal Files from XML source\nUsage: \n\t$0 T10\n";
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
mkdir($cfg{"OUTDIR"} . "\\APP", MODE);

opendir (INDIR, $cfg{"DIR"} . "\\$vol");

if ($infile eq ""){
	@allfiles = grep(/\.xml$/i, readdir(INDIR));
} else {
	@allfiles = grep(/$infile/i, readdir(INDIR));
}


die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$utf8 = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
	$big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
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
	$bib .= $string if ($bibl == 1);
	$text .= $string if ($pass == 0  && $inp != 1);
	$px .= $string if ($pass == 0 && $inp == 1);
}

sub init_handler
{
	$pass = 1;
	$bibl = 0;
	$fileopen = 0;
	$num = 0;
	$inxu = 0;
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

	if ($el eq "p"){
		$inp = 1 if (lc($att{"rend"}) ne "nopunc");
#		$text =~ s/(　)+$//;
	}


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
			$text .= "(" if ($pass == 0  && $inp != 1);
			$px .= "(" if ($pass == 0 && $inp == 1);
			$close = ")";
	}

	if ($el eq "p" && lc($att{"type"}) eq "inline"){
		$text .= "。" if ($pass == 0  && $inp != 1);
		$px .= "。" if ($pass == 0 && $inp == 1);
#		$text .= "。";
	}
	
#	if ($el eq "p" && lc($att{"type"}) eq "w"){
#		print "(";
#		$text .= "　" if ($pass == 0  && $inp != 1);
#		$px .= "　" if ($pass == 0 && $inp == 1);
#		$text .= "　";
#		$indent = "　";
#	}


	$text .= "　" if $el eq "l";
	if ($el eq "byline"){
		$text .= "　　　　" ;
		$indent = "　　　　";
	}

	if ($el eq "head" && lc($att{"type"}) ne "added" && $inxu == 0){
		$text .=	"　　" ;
		$indent = "　　" ;
	}

	if ($el eq "lb"){
		$lb = $att{"n"};
		#the whole line has been cached to $text, print it now!
		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		if ($fileopen == 1){
			&out;
			$text = "\n$vl$lb║$indent";
		} else {
			$text .= "\n$vl$lb║$indent";
		}
	} elsif ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
	}
	
	
	if ($el eq "div1"){
		if (lc($att{"type"}) eq "xu"){

			# 前序才開新檔，後序不開新檔 modified by Ray 1999.10.6
			#&changefile if ($xu != 1);
			&changefile if ($xu != 1 && $num==0);

			$xu = 1;
			$inxu = 1;
			$num = 0;
		} elsif ($num == 0 && (lc($att{"type"}) eq "juan" || lc($att{"type"}) eq "jing" || lc($att{"type"}) eq "pin" || lc($att{"type"}) eq "other")) {
			$num = 1;
			&changefile;
		}
#		$text .=	"　　" ;
	}

	if ($el eq "juan"){
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
			&changefile;
		} else {
		}
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
	if ($el eq "head"){
		$indent = "" ;
	}
	if ($el eq "note" && $close ne ""){
		$text .= $close if ($pass == 0  && $inp != 1);
		$px .= $close if ($pass == 0 && $inp == 1);
#		$text .= $close if ($close ne "");
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
			&out;
			$text = "";
			$vl = sprintf("T%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("T%2.2d", $1);
			mkdir($cfg{"OUTDIR"} . "\\APP\\$od", MODE);

			#base name for file
			$xu = 0;
			$fileopen = 0;
			$num = 0;
			$bof = $cfg{"OUTDIR"} . sprintf("\\APP\\$od\\%4.4d$c", $2, $3);
		}
		$bib =~ s/^\t+//;
		$ebib = $bib;
	}

	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
	}

	if ($el eq "div1"){
		$inxu = 0;
	}

	if ($el eq "p"){
#header		
		if ($head == 1) {
			$bib =~ s/^\t+//;
			$ly{$lang} = $bib;
		} else {
#text		
			$text .= "-";
		}
		$inp = 0;
	}
	$lang = "" if ($el eq "p");
	if ($el eq "tei.2"){
		&out;
		$text = "";
		close (OF);
		$vl = "";
		$num = 0;
	}
	$bib = "";
}


sub char_handler 
{
	my $p = shift;
	my $char = shift;

	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	my $parent = lc($p->current_element);
  if ($parent eq "app") { return; }

  $char =~ s/($utf8)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	$bib .= $char if ($bibl == 1);
	$text .= $char if ($pass == 0 && $el ne "pb" && $inp != 1);
	$px .= $char if ($pass == 0 && $el ne "pb" && $inp == 1);
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
	print STDERR "$file\t";
	$parser->parsefile($file);
#	die;
}
print STDERR "Done!!\n";

sub shead{
	print $short;
}


sub changefile{
	$text =~ s/\n//;
	$text =~ s/\x0d$//;
	close (OF);
	$of = sprintf("$bof%3.3d.txt", $num);
	open (OF, ">$of");
	$fileopen = 1;
	print STDERR " --> $of\n";
	select(OF);

	if ($num == 0 || ($xu == 0 && $num == 1)){ head("普及App版","App-Format for online search"); }
	else { &shead; }

	print "\n";
	&out;
	$text = "";
	$oldbof = $bof;
}


sub out{
	if ($px ne ""){
		$px =~ s/\[[0-9（[0-9珠\]//g;
		$px =~ s/#[0-9][0-9]#//g;
		#print $px;
		$text =~ s/║//g;
		$text =~ s/(　)+//g;
		$c = @chars;
		if ($c > 99){
			$c = sprintf("%2.2d", $c);
		} else {
			$c = sprintf("(%2.2d", $c);
		}
#		$c = sprintf("%3.3d", $c);
#		if ($text =~ /-/  || $c > 80){
		if ($text =~ /-/ ){
			$text =~ s/-//;
			print "${text}$c)║";
			print join("", @chars);
			@chars = ();
			print $px;
		} else {
      		print "${text}$c)║";
      		if ($px =~ /。|　|\(|\)/){
      			print join("", @chars);
      			@chars = ();
      		}
      		push(@chars, $px =~ /$big5/g);
      		@chars = grep(!/║/, @chars);
      		
      		# 印到沒有 "。" or "　" or "(" or ")"，其餘到下一行
      		while(@chars){
      			$gr = join("", @chars);
      			# 如果最後一個字元是 "("，則將 "(" 印到下一行
      			if ($chars[0] eq "(" && $gr !~ /。|　|\)/) { last; }
      			last if ($gr !~ /。|　|\(|\)/);
      			$c = shift (@chars);
      			print $c if ($c ne "║");
      		}
		}
	} else {
		if ($deug) { print STDERR "426 $text\n"; }
		$text =~ s/\[[0-9（[0-9珠\]//g;
		$text =~ s/#[0-9][0-9]#//g;
#		$text =~ s/(　)+?║/(00)║/g;
		$text =~ s/║/(00)║/g;
		$text =~ s/　\(/(/;
		$text =~ s/　\(/(/;
		$text =~ s/　\(/(/;
		$text =~ s/-//;

		# 如果這一行是空的，要把上一行剩下的印出去 added by Ray 1999.10.8
		if ($text =~ /║$/) { print @chars; @chars=(); }

		print "${text}";
	}
	$px = "";
	$text = "";
}




__END__
:endofperl
