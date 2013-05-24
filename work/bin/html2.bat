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

$nid=0;
$vol = shift;
$file = "CBETA.CFG";
if ($vol eq ""){
	print "\t$0: Produces CBETA HTML Files from XML source\nUsage: \n\t$0 T10\n";
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
mkdir($cfg{"OUTDIR"} . "\\HTML", MODE);

opendir (INDIR, $cfg{"DIR"} . "\\$vol");

open (VTOC, ">" . $cfg{"OUTDIR"} . "\\HTML\\${vol}toc.htm");

print VTOC << "EOF";
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
</HEAD>
<BODY>
<UL>
EOF


@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "hhead.pl";
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
	print STDERR "$file\n";
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
    if ($bibl == 1){
		$bib .= $string ;
#		print STDERR "$bib\n";
	}
	$text .= $string if ($pass == 0);
}

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$fileopen = 0;
	$num = 0;
	$oldof = "";
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
#		print "(";
		$text .= "(";
		$close = ")";
	}


	if ($el eq "p" && lc($att{"type"}) eq "w"){
		$text .= "<p>¡@";
		$indent = "¡@";
	} elsif ($el eq "p" ){
		$text .= "<p>";
	}

	if ($el eq "lg" ){
		$text .= "<p class='lg'>";
		$br = "<br>";
	}

	if ($el eq "corr"){
		$text .= "<span class='corr'>";
	}

	
	if ($el eq "l"){
		$text .= "¡@";
	}
	
	
#	print "¡@" if $el eq "l";
	if ($el eq "byline"){
		$text .= "<span class='byline'><br>¡@¡@¡@¡@" ;
#		print "¡@¡@¡@¡@" ;
		$indent = "<br>¡@¡@¡@¡@";
	}

	if ($el eq "head" && lc($att{"type"}) ne "added"){
		$text .=	"<br>¡@¡@" ;
#		$indent = "¡@¡@" ;
		$bibl = 1;
		$bib = "";
		$nid++;
		$text .= "<A NAME=\"n$nid\"></A>";
		if ($xu == 0){
			$arr{"pin"} .= "<A HREF=\"$oldof#n$nid\" target=\"main\">";
		} else {
			$arr{"xu"} .= "<A HREF=\"$oldof#n$nid\" target=\"main\">";
		}
	}

	if ($el eq "lb"){
		$lb = $att{"n"};
		#the whole line has been cached to $text, print it now!
		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		if ($fileopen == 1){
			$text =~ s/\[[0-9¡][0-9¯]\]//g;
			$text =~ s/#[0-9][0-9]#//g;
			print "$text";
			$text = "</a>$br<a \nname=\"$lb\">$indent";
		} else {
			$text .= "</a>$br<a \nname=\"$lb\">$indent";
		}
	} elsif ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
#		die;
	}
	
	if ($el eq "div1"){
		if (lc($att{"type"}) eq "xu"){
			#&changefile;# if ($xu == 0);
			$xu = 1;
			$num = 0;
		} elsif ($num == 0 && (lc($att{"type"}) eq "juan" || lc($att{"type"}) eq "jing" || lc($att{"type"}) eq "pin" || lc($att{"type"}) eq "other")) {
			$num = 1;
			#&changefile;
		}
	}
	
	if ($el eq "juan"){
		$xu = 0;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
			$bibl = 1;
			$bib = "";
			#&changefile;
			$nid++;
			$text .= "<A NAME=\"n$nid\"></A>";
			$arr{"juan"} .= "<A HREF=\"$oldof#n$nid\" target=\"main\">";
		} else {
		}
		$text .= "<p class='juan'>\n";
	}
	#end startchar
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

  ### </head> ###
	if ($el eq "head" && $added == 1){
		$pass--;
		$added = 0;
	}

  ### </juan> ###
	if ($el eq "juan" ){
#		print STDERR $bib, "\n";
		$bibl = 0;
		$bib =~ s/\[[0-9¡][0-9¯]\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$arr{"juan"} .= "$bib</A>\n";
		$bib = "";
	}

  ### </head> ###
	if ($el eq "head" ){
#		print STDERR $bib, "\n";
		$bibl = 0;
		$bib =~ s/\n//g;
		$bib =~ s/\[[0-9¡][0-9¯]\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		if ($xu == 0){
			$arr{"pin"} .= "$bib</A>\n" if ($bib !~/No/);
		} else {
			$arr{"xu"} .= "$bib</A>\n";
		}
		$bib = "";
	}
	
	### </lg> ###
	if ($el eq "lg" ){
		$text .= "</p>";
		$br = "";
	}
	
	### </juan> ###
	if ($el eq "juan"){
		$text .= "</p>\n";
	}
	
	### </byline> ###
	if ($el eq "byline"){
		$text .= "</span>" ;
	}
	
	### </corr> ##
	if ($el eq "corr"){
		$text .= "</span>";
	}

	$indent = "" if ($el eq "byline");
	$indent = "" if ($el eq "p");
	$text .="¡@" if $el eq "l";
	
	### </head> ###
	if ($el eq "head"){
		$indent = "" ;
	}

	### </note> ###
	if ($el eq "note"){
		$text .= $close if ($close ne "");
		$close = "";
	}
	
	### </bibl> ###
	if ($el eq "bibl"){
		$bibl = 0;
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			$prevof = "";
			if ($3 eq ""){				#$c = "_";			} else {				$c = $3;			}

			#print the rest of the line of the old file!
			$text =~ s/\[[0-9¡][0-9¯]\]//g;
			$text =~ s/#[0-9][0-9]#//g;
			print OF $text;
			$text = "";
			$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("t%2.2d", $1);
			mkdir($cfg{"OUTDIR"} . "\\html\\$od", MODE);
#			$c = "n" if ($c eq "_");
#			$oof = $of;
			#base name for file

			$xu = 0;
			$fileopen = 0;
			$num = 0;
			$bof = $cfg{"OUTDIR"} . sprintf("\\html\\$od\\%4.4d$c", $2, $3);
			$bof =~ tr/A-Z/a-z/;
			$fhead = $cfg{"OUTDIR"} . sprintf("\\html\\$od\\%4.4dh", $2, $3);
			$fhead =~ tr/A-Z/a-z/;
			open (FTOC, ">${bof}toc.htm");
			$mtit = $title;
			$mtit =~ s/Taisho Tripitaka, Electronic version, //;
print FTOC << "EOF";
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<script>
	function toggledisp(object){
		if (document.all[object].style.display == "none") {
			document.all[object].style.display = "";
		} else {
			document.all[object].style.display = "none";
		}
	}
</script>
<script FOR="window" EVENT="onload">
	if (document.links.length == 1){
		parent.main.location = document.links[0].href;
	}
</script>
<style>
	.lix{color:purple;text-decoration:underline;}
</style>
</HEAD>
<BODY>
<H2>$mtit</H2>

EOF
	
		  $bib =~ s/^\t+//;
		  $ebib = $bib;
		  
      # added by Ray 1999.10.11
      &changefile;	
		}
		#$bib =~ s/^\t+//;
		#$ebib = $bib;
	}
	
	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
	}
	if ($el =~ /div/i){
		$xu = 0;
	}
	if ($el eq "p"){
		$bib =~ s/^\t+//;
		$ly{$lang} = $bib;
	}
	if ($el eq "teiheader"){
#		&head;
	}
	$lang = "" if ($el eq "p");
	if ($el eq "tei.2"){
		$text =~ s/\[[0-9¡][0-9¯]\]//g;
		$text =~ s/#[0-9][0-9]#//g;

		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		
		print OF $text;
		$text = "";
		print "</a><hr>";
		print "<a href=\"${prevof}#start\">¡¶</a>" if ($prevof ne "");
#		print "<a href=\"${of}#start\">¡¿</a>";
		print "</html>\n";
		close (OF);
		$vl = "";
		$num = 0;
		if ($arr{"xu"} ne ""){
#			print FTOC "<UL>§Ç\n";
			print FTOC "<A class=\"lix\" onClick=\"toggledisp('xu')\">§Ç</A><BR>\n<UL id=\"xu\"  style=\"display:none\">\n";
			@f = split(/\n/, $arr{"xu"});
			for $f (@f){
				next if ($f eq "</A>");
				print FTOC "<LI>$f</LI>\n";
			}
			print FTOC "</UL>\n";
		}
		if ($arr{"juan"} ne ""){
			print FTOC "<A class=\"lix\" onClick=\"toggledisp('juan')\">¨÷</A><BR>\n<UL id=\"juan\" style=\"display:none\">\n";
			@f = split(/\n/, $arr{"juan"});
			for $f (@f){
				next if ($f eq "</A>");
				print FTOC "<LI>$f</LI>\n";
			}
			print FTOC "</UL>\n";
		}
		if ($arr{"pin"} =~ /<\/A>/){
#			print FTOC "<UL>«~\n";
			print FTOC "<A class=\"lix\" onClick=\"toggledisp('pin')\">«~</A><BR>\n<UL id=\"pin\"  style=\"display:none\">\n";
			@f = split(/\n/, $arr{"pin"});
			for $f (@f){
				next if ($f eq "</A>");
				print FTOC "<LI>$f</LI>\n";
			}
			print FTOC "</UL>\n";
		}
		print FTOC "</UL></BODY></HTML>\n";
		%arr = ();
	}
	
	
#	$bib = "";
#	print STDERR "$pass\n";
}


sub char_handler 
{
	my $p = shift;
	my $char = shift;
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

sub shead{
	print $short;
}


sub changefile{
			$text =~ s/\n//;
			$text =~ s/\x0d$//;
			
			# modified by Ray 1999.10.11
			#$of = sprintf("$bof%3.3d.htm", $num);
			$of = $bof . ".htm";
			$mof = $of;
			$mof =~ s/.*\\//;
			if ($oldof ne $mof){
				$xtoc = "${bof}toc.htm";
				$xtoc =~ s/.*\\//;
				$xtoc =~ tr/A-Z/a-z/;
				$ytoc = $bof;
				$ytoc =~ s/.*\\//;
				$ytoc =~ s/_//;
				print "</a><hr>";
				print "<a href=\"${prevof}#start\">¡¶</a>¡@¡@¡@" if ($prevof ne "");
				print "<a href=\"${mof}#start\">¡¿</a>";
				print "</html>\n";
				close (OF);
				$fh = sprintf("$fhead%3.3d.htm", $num);
				open (OF, ">$of");
				$fileopen = 1;
				print STDERR " --> $of\n";
				select(OF);
				if ($num == 0 || ($xu == 0 && $num == 1)){
					&head;
					print VTOC "<LI><A ID=\"$ytoc\" NAME=\"$ytoc\" HREF=\"$vol/$xtoc\" target=\"ftoc\">$title</A></LI>\n";
				} else {
					&shead;
				}
				open(FHED, ">$fh");
				print FHED $fhed;

				print OF "\n$text";
				$text = "";
				$prevof = $oldof;
				$oldof = $mof;
				$oldbof = $bof;
			}
}




__END__
:endofperl
