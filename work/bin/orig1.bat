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
# 原行首資訊使用"║"，本程式改用 ##
#
my $vol = shift;
$vol = uc($vol);
$file = "CBETA.CFG";
if ($vol eq ""){
	print "\t$0: Produces CBETA ORIG Files from XML source\nUsage: \n\t$0 T10\n";
	print "T10 is the subdirectory where the XML files are found\n";
	print "The program also needs a config file CBETA.CFG\n";
	print "The config file should to be in the current directory or in the directory of this program\n";
	print "\tConfig File Format SAMPLE:\n\nDIR=C:\\CBETA\\T10\n";
	print "OUTDIR=C:\\RELEASE\n";
	print "#CHAR can be NOR or ORG\n";
	print "CHAR=ORG\n";   
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
mkdir($cfg{"OUTDIR"} . "\\ORIG", MODE);
mkdir($cfg{"OUTDIR"} . "\\ORIG" . "\\$vol", MODE);

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

#ausnahme!
$utf8out{"\xe2\x97\x8e"} = '◎';


use XML::Parser;


my %Entities = ();
my %type = ();
my $ent;
my $val;
my $text;

# added by Ray 1999.10.4
my $FirstLineOfFile=1;
my $CountJieSong=0;
my $LinesOfJieSong=0;
my $FuWen=0;           # 是否在卷末附文裏
my @saveatt=();   # 儲存 attribute


$cfg{"CHAR"} = "ORG";
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
	$text .= $string if ($pass == 0);
}

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$inel = "";
#!> 	$fileopen = 0;
#!> 	$num = 0;
	$close = "";
}



sub start_handler 
{
	my $p = shift;
	$el = shift;
	my (%att) = @_;
	push @saveatt , { %att };
	my $parent = lc($p->current_element);

	$pass++ if $el eq "rdg";
	$pass++ if $el eq "gloss";

	# added by Ray 1999.10.4
	### <head> ###
	if ($el eq "head"){
    if ($type{$parent} eq "other") {
      $rep .= "Q";
      $inel .= "Q";
    } elsif ($type{$parent} eq "xu") {
      $rep .= "X";
      $inel .= "X";
    } elsif ($type{$parent} eq "pin") {
      $rep .= "D";
      $inel .= "D";
    }	elsif ($type{$parent} eq "dharani") {
      $rep .= "Z";
      $inel .= "Z";
    }
	}

	### <head type="added"> ###
	if ($el eq "head" && lc($att{"type"}) eq "added"){
		$pass++;
		$added = 1;
	}
	if ($el eq "head" && lc($att{"type"}) eq "no"){
		$rep .= "N";
	}

  # modified by Ray 1999.10.4
	### <div1> ###
	if ($el eq "div1"  or $el eq "div2") {
		  $type{$el} = lc($att{"type"});
		  if ($type{"div1"} eq "w") { $FuWen=1; }
	}
	
	### <juan> ###
	if ($el eq "juan" && lc($att{"fun"}) eq "open"){
		$rep .= "J";
		$inel .= "J";
	}
	if ($el eq "juan" && lc($att{"fun"}) eq "close"){
		$rep .= "j";
		$inel .= "j";
	}
	
	### <byline> ###
	if ($el eq "byline") {
	  if (lc($att{"type"}) eq "author") {
		  $rep .= "A";
		  $inel .= "A";
	  } elsif (lc($att{"type"}) eq "translator") {
		  $rep .= "Y";
		  $inel .= "Y";
		} elsif (lc($att{"type"}) eq "collector") {
		  $rep .= "C";
		  $inel .= "C";
		} else {
		  $rep .= "B";
		  $inel .= "B";
		}
	}
	
	### <p> ###
	if ($el eq "p" && lc($att{"type"}) ne "inline"){
		if (lc($att{"type"}) eq "dharani"){
			$rep .= "Z";
		} elsif (lc($att{"type"}) eq "w"){
			$rep = "WP#";
			$FuWen=1;
		} else {
			$rep .= "P";
		}
	}
	if ($el eq "p" && lc($att{"type"}) eq "inline"){
		$text .= "Ｐ";
	}
	
	### <l> ###
	if ($el eq "l"){
		$text .= "　" ;
		if ($rep !~ /S/) { $rep .= "S"; }
		$CountJieSong++;
	}

	### <corr> ###
	if ($el eq "corr"){
#		print STDERR "\n$text $att{'sic'}\n" if ( $att{'sic'} =~ /^\&?[MC]/);
		$att{"sic"} =~ s/($pattern)/&repu($1)/eg;
		$att{"sic"} =~ s/(M[0-9]{6})/&rep($1)/eg;
		$text .= "[" . $att{"sic"} . ">";
#		print STDERR "\n$text $att{'sic'}\n" if ( $att{'sic'} =~ /^\&?[MC]/);
#		die  if ( $att{'sic'} =~ /^\&?[MC]/);
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
	
	### <app> ###
	if ($el eq "app"){
		$fnx = lc($att{"n"});
		if ($fnx =~ /^x/){
#			$text .= "[＊]";
		} elsif ($fnx =~ /([0-9]{2})$/){
#			$text .= "[$1]";
		}
	}
	
	### <note> ###
	if ($el eq "note" && lc($att{"type"}) eq "inline"){
#		print "(";
		$text .= "(" if ($pass == 0);
		$close = ")" if ($pass == 0);
	}
	
	if ($el eq "byline"){
#		$text .= "　　　　" ;
#		$indent = "　　　　";
	}

	if ($el eq "head" && lc($att{"type"}) ne "added"){
#		$text .=	"　　" ;
#		$indent = "　　" ;
	}

	### <lb> ###
	if ($el eq "lb"){
		if ($rep =~ /S/) {
		  if ($CountJieSong>0) { $LinesOfJieSong++; }
		  else { $LinesOfJieSong=0; }
		}

	  $lb = $att{"n"};
	  
	  if ($FuWen && $rep !~ /^W/) {
	    if ($rep eq "") { $rep = "W##"; }
	    else {
	      $rep = "W" . $rep;
	    }
	  }
	  
	  if ($rep eq "") { $rep="_##║"; }
	  else { 
	    $rep .= "##"; 
	    $rep = substr($rep,0,3); 
	    $rep .= "║";
	  }

		#the whole line has been cached to $text, print it now!
		$text =~ s/\xa1\x40$//;
		$text =~ s/\[[0-9（[0-9珠\]//g;
		$text =~ s/#[0-9][0-9]#//g;
		$text =~ s/(M[0-9]{6})/&rep($1)/eg;
		$text =~ s/(CB[0-9]{4})/&rep($1)/eg;
		$text =~ s/([0-9]{2})_##║/${1}$rep/; 
		
		# added by Ray 1999.10.4
		$text =~ s/\[＊>\]//;
		$text =~ s/\[>\]//;

		print "$text";

    # modified by Ray 1999.10.4
		#$text = "\n$vl${lb}_##$indent";
		if ($FirstLineOfFile) {
		  $text = "$vl${lb}_##║$indent";
		  $FirstLineOfFile=0; 
		} else {
		  $text = "\n$vl${lb}_##║$indent";
		}

#		print "\n$vl${lb}_##$indent";
		$rep = "" if ($inel eq "");
	} elsif ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
	}
}


sub repu{
	local($x) = $_[0];
	return $utf8out{$x} if defined($utf8out{$x});
	return $x;
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
	my $att = pop(@saveatt);
	
	$head = 0 if $el eq "teiheader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";

  # added by Ray 1999.10.4
  ### </div1> ###
	if ($el eq "div1") {
	  $FuWen=0;  # div1 結束，附文也一定結束
	}
  
	### </corr> ###
	if ($el eq "corr"){
		$text .= "]";
	}

	### </head> ###
	if ($el eq "head" && $added == 1){
		$pass--;
		$added = 0;
	}
	if ($el eq "head"){
		$indent = "" ;
		$inel = "";
	}

	$indent = "" if ($el eq "byline");
	$text .="　" if $el eq "l";
#	print "　" if $el eq "l";
	
	### </note> ###
	if ($el eq "note"){
		$text .= $close if ($close ne "");
#		print $close if ($close ne "");
		$close = "";
	}
#rep	
	
	### </lg> ###
	if ($el eq "lg"){
		#modified by Ray 1999.10.4
		#$rep = "s##";# if ($rep ne "S##");
		if ($LinesOfJieSong>0) {
		  $rep =~ s/S/s/;
		  $LinesOfJieSong=0;
		}
		else { $CountJieSong=0; }
	}
	if ($el eq "juan"){
		$inel = "";
	}
	if ($el eq "byline"){
		$inel = "";
	}
	
	if ($el eq "bibl"){
		$bibl = 0;
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			if ($3 eq ""){
				$c = "_";
			} else {
				$c = $3;
			}
			$vl = sprintf("T%2.2dn%4.4d%sp", $1, $2, $c);
		}
			#print the rest of the line of the old file!
		$bib =~ s/^\t+//;
		$ebib = $bib;
		select (OF);
	}

	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
	}

	### </p> ###
	if ($el eq "p"){
		if (lc($att->{"type"}) eq "w") { $FuWen=0; }
		$bib =~ s/^\t+//;
		$ly{$lang} = $bib;
	}
	
	if ($el eq "teiheader"){
#		&head;
		$text = "";
	}
	
	$lang = "" if ($el eq "p");
	
	### </tei.2> ###
	if ($el eq "tei.2"){
	  $rep .= "##";
	  $rep = substr($rep,0,3);
		$text =~ s/\[[0-9（[0-9珠\]//g;
		$text =~ s/#[0-9][0-9]#//g;
		$text =~ s/([0-9]{2})_##/$1$rep/;
		print $text;
		$text = "";
#		close (OF);
		select (FOO);
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
		     	
$od = $vol;
mkdir($cfg{"OUTDIR"} . "\\ORIG\\$od", MODE);
$of = $cfg{"OUTDIR"} . "\\ORIG\\$od\\${vol}ORG.txt";
open (OF, ">$of");
#print STDERR " --> $of\n";


$pass = 1;

for $file (sort(@allfiles)){
	print STDERR "$file  --> $of\n ";
	$parser->parsefile($file);
#	die;
}
print STDERR "Done!!\n";




__END__
:endofperl
