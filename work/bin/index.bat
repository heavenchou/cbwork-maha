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
$file = "CBIND.CFG";
if ($vol eq ""){
	print "\t$0: Produces CBETA Index Files from XML source\nUsage: \n\t$0 T10\n";
	print "T10 is the subdirectory where the XML files are found\n";
	print "The program also needs a config file CBIND.CFG\n";
	print "The config file should to be in the current directory or in the directory of this program\n";
	print "\tConfig File Format SAMPLE:\n\nDIR=C:\\CBETA\\T10\n";
	print "outdir=C:\\RELEASE\n";
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
	$key = lc($key);
	if ($key =~ s/^<//){
		@v = split(/\&/, $val);
		for $v (@v){
			($vkey, $vval) = split(/:/, $v);
			if ($vval ne ""){
				$tags{"$key:$vkey"} = "$vval";
				print "$key:$vkey=$vval\n";
			} else {
				$tags{"$key"} = "$vkey";
				print "$key=$vkey\n";
			}
		}
	} else {
		$cfg{$key}=$val; #store cfg values
		print "$key\t$cfg{$key}\n";
	}
}
#die;

#rdg:wit:¡i©ú¡j=3
#rdg:wit:¡i¤T¡j=4
#p:type:z=2
#p:type:w=7
#lb=1
#juan=3
#byline=4
#note=6

mkdir($cfg{"outdir"}, MODE);
mkdir($cfg{"outdir"} . "\\Index", MODE);

open (LST, ">" . $cfg{"outdir"} . "\\Index\\" . $vol . ".lst");

opendir (INDIR, $cfg{"dir"} . "\\$vol");


@allfiles = grep(/\.xml$/i, readdir(INDIR));

for $_ (@allfiles){
	$_ = uc($_);
}

die "No files to process\n" unless @allfiles;

#print STDERR "Initialising....\n";

$open = $cfg{"open"};
$rchars = $cfg{"rchars"} - 1;
$lchars = $cfg{"lchars"} - 1;

if ($lchars > -1){
	for ($i=0; $i < $lchars+1; $i++){
#big5:
#		push(@lch, "¡@");
#utf8:
		push(@lch, "\xe3\x80\x80");
	}
}


open (OF, ">$cfg{'outdir'}\\Index\\$vol.tmp");
select (OF);


#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';
	$kanji = '[\xe4-\xef][\x80-\xbf][\x80-\xbf]|&[^;]*;|\<[^\>]*\>'; #oder entity

($path, $name) = split(/\//, $0);
push (@INC, $path);
 if ($cfg{"out"} ne ""){
	require $cfg{"out"}; #utf-tabelle fuer big5, jis..
} else {
	require "m2utf8.plx";
	require "b5jpiz.plx" if ($cfg{"dojpiz"} == 1);
}
	
require "utf8.pl";
require "head.pl";
if ($cfg{"out"} ne ""){
	$utf8out{"\xe2\x97\x8e"} = '';
}

use XML::Parser;


my %Entities = ();
my $ent;
my $val;
my $text;

sub openent{
	local($file) = $_[0];
	if ($cfg{"out"} eq "" ){
		local($k) = ".ut8";
		$file =~ s/\....$/$k/e;
	} else {
	}
#	$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
	$file =~ s#/#\\#g;
	$file =~ s/\.\./$cfg{"dir"}/;
	print STDERR "$file\n";
	open(T, $file) || die "can't open $file\n";
#	while(<T>){
#		chop;
#		s/<!ENTITY\s+//;
#		s/[SC]DATA//;
#		s/\s+>$//;
#		($ent, $val) = split(/\s+/);
#		$val =~ s/"//g;
#		$Entities{$ent} = $val;
#	}
	while(<T>){
#new entity format with gaiji tag
#<!ENTITY M004264 "<gaiji cb='CB0046' des='[¤f*(¦Û/(µR-¤r-¤û)/¤Q)]' nor='¶ç' mojikyo='M004264' mofont='Mojikyo M101' mochar='6FDB'/>" >
#ENTITY M000262
		if (/ENTITY ([^ ]*)/) {
			$ent = $1;
		}  else {
			next;
		}
		if (/des='([^']*)/) {
			$des = $1;
		} else {
			$des = "";
		}
		if (/nor='([^']*)/) {
			$nor = $1;
		} else {
			$nor = "";
		}
#mojikyo='M004264'
		if (/mojikyo='([^']*)/) {
			$moj = "&" . $1 . ";";
		} else {
			$moj = "";
		}
		$moj{$ent} = $moj if ($moj ne "");
		$nor{$ent} = $nor if ($nor ne "");
		$des{$ent} = $des if ($des ne "");
	}
}


sub default {
    my $p = shift;
    my $string = shift;
#	print STDERR "$string\n";
    $string =~ s/^\&([^;]*);$/&repmoj($1)/eg;
    if ($bibl == 1){
		$bib .= $string ;
#		print STDERR "$bib\n";
	}
	$text .= $string if ($pass == 0);
#Ci in entities
	if ($pass == 0){
	$tag = sprintf("\$%s\$%1.1d%1.1d", $rt, $bt{$btc}, $et);
#b5 specific!!	
	if ($string =~ /([\xa4-\xfe][\x40-\xfe])([\xa4-\xfe][\x40-\xfe])/){
		&doind($1);
		&doind($2);
	} else {
		&doind ($string) if ($string ne "");
	}
	}
}

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$lbprinted = 0;
	$fileopen = 0;
	$num = 0;
	$ccnt = 0;  #character count (per line)
	$btc =  0;  #number of base character
	$rt =    0;  #
	$rtc =    0;  #number of witness
	$app = 0; #number of open apps
	$rdg =  0; # number of open rdg
	$close = "";
}



sub start_handler 
{
	my $p = shift;
	$el = shift;
	my (%att) = @_;
#	$pass++ if $el eq "rdg";
	$pass++ if $el eq "gloss";

### record auxiliary information on the context
	for $a (keys(%att)){
		$tmp = lc($att{"wit"});
		if  ($cfg{"out"} ne ""){
			$tmp =~ s/($pattern)/$utf8out{$1}/eg;
		}
		$tmp =~ s/\[¡¯\]//;
		$tmp =~ s/\[ï¼Š\]//;
#		print STDERR  "$tmp\n";
		if ($el eq "rdg" && $tmp =~ /$open/){
#$rtc is number of rdg			
			$rt = "";
			@aa = split(/$open/, $tmp);
			for $aa (@aa){
#				$tags{"rdg:¡i¤T¡j"}
#				$rtc++;
					$rt .= "+" . $tags{"$el:$a:$open$aa"} if ($tags{"$el:$a:$open$aa"} ne "");
#add 9 for other, not yet defined readings:
					$rt .= "+" . "9" if ($tags{"$el:$a:$open$aa"} eq "");
#				print STDERR "$el:$a:$aa--$rt\n"
			}
		}
	}
	if ($el eq "p"){
		if (defined($att{'type'})){
			$btx = $tags{"$el:type:$att{'type'}"} if defined($tags{"$el:type:$att{'type'}"});
		} else {
			$btx = $tags{"$el"} if defined($tags{"$el"});
		}
		$btc++;
		$bt{$btc} = $btx;
	}
	if (defined($tags{"$el"})){
		$btx = $tags{"$el"} ;
		$btc++;
		$bt{$btc} = $btx;
	}
	$et = $tags{"e$el"} if defined($tags{"e$el"});
###
#--# save status @ind
	if ($el eq "app"){
		@aftind =();
		$rdg = 0;
		$aft = 0;

		$app++;
		$appind{$app} = join("##", @ind);
		$appcnt{$app}  = $ccnt;
#		print "app:$app$appind{$app}\n";
	}
	if ($el eq "lem"){
#not really necessary??		
		@ind = split(/##/, $appind{$app});
		$ccnt = $appcnt{$app};
	}
	if ($el eq "rdg"){
		$rdg++;
		@ind = split(/##/, $appind{$app});
		$ccnt = $appcnt{$app};
	}
#--#	
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

	if ($el eq "p" && lc($att{"type"}) eq "inline"){
#		print "(";
		$text .= "¡C";
	}

	if ($el eq "p" && lc($att{"type"}) eq "w"){
		$text .= "¡@";
		$indent = "¡@";
	}

	
	$text .= "¡@" if $el eq "l";
#	print "¡@" if $el eq "l";
	if ($el eq "byline"){
		$text .= "¡@¡@¡@¡@" ;
#		print "¡@¡@¡@¡@" ;
		$indent = "¡@¡@¡@¡@";
	}

	if ($el eq "head" && lc($att{"type"}) ne "added"){
		$text .=	"¡@¡@" ;
		$indent = "¡@¡@" ;
	}

	if ($el eq "lb"){
		$lb = $att{"n"};
		if ($lbprinted == 0){
			print LST "$lb\t$file\n";
			$lbprinted = 1;
		}
		#the whole line has been cached to $text, print it now!
#		$text =~ s/\xa1\x40$//;
		$text =~ s/\xe3\x80\x80$//;
		$lb =~ s/a/1/;
		$lb =~ s/b/4/;
		$lb =~ s/c/7/;
		$ccnt = 0;
		if ($fileopen == 1){
			$text =~ s/\[[0-9¡][0-9¯]\]//g;
			$text =~ s/\[ï¼Š\]//;
			$text =~ s/#[0-9][0-9]#//g;
			
#			print "$text";
			$text = "\n$vl$lbùø$indent";
		} else {
			$text .= "\n$vl$lbùø$indent";
		}
	} elsif ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\.*//;
		$vl =~ s/^t//i;
		$vl =~ s/n.*p//;
		$vl = sprintf("%3.3d", $vl);
#		die;
	}
	
	if ($el eq "div1"){
		if (lc($att{"type"}) eq "xu"){
#			&changefile if ($xu != 1);
			$xu = 1;
			$num = 0;
		} elsif ($num == 0 && (lc($att{"type"}) eq "juan" || lc($att{"type"}) eq "jing" || lc($att{"type"}) eq "pin" || lc($att{"type"}) eq "other")) {
			$num = 1;
#			&changefile;
		}
	}
	
	if ($el eq "juan"){
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
#			&changefile;
		} else {
		}
	}
	#end startchar
}

sub repmoj{
	local($x) = $_[0];
	return $moj{$x} if defined($moj{$x});
#	die "NOR Unknown entity $x!!\n";
	return $x;
}


sub repnor{
	local($x) = $_[0];
	return $nor{$x} if defined($nor{$x});
	die "NOR Unknown entity $x!!\n";
	return $x;
}

sub repdes{
	local($x) = $_[0];
	return $des{$x} if defined($des{$x});
	die "DES Unknown entity $x!!\n";
	return $x;
}


sub end_handler 
{
	my $p = shift;
	my $el = shift;
	
	$head = 0 if $el eq "teiheader";  #reset HEADER flag
#	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";
	if ($el eq "head" && $added == 1){
		$pass--;
		$added = 0;
	}
	if (defined($tags{"$el"})){
		$btc--;
	}

#--# save ccnt;
	if ($el eq "lem"){
		$lemccnt{$app} = $ccnt;
		$lemind{$app} = join("##", @ind);
	}
#restore ccnt
	if ($el eq "app"){
		$ccnt = $lemccnt{$app};
		@ind = split(/##/, $lemind{$app});
		$app--;
	}
	if ($el eq "rdg"){
#last rdg??		
		$rdgind{"$rdg"} = join("##", @ind);
	}
#--#
	
	$indent = "" if ($el eq "byline");
	$indent = "" if ($el eq "p");
	$rt = 0 if ($el eq "rdg");
	$text .="¡@" if $el eq "l";
	if ($el eq "head"){
		$indent = "" ;
	}
	if ($el eq "note"){
		$text .= $close if ($close ne "");
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
			$text =~ s/\[[0-9¡][0-9¯]\]//g;
			$text =~ s/\[ï¼Š\]//;
			$text =~ s/#[0-9][0-9]#//g;
#			print OF $text;
			$text = "";
			$vl = sprintf("T%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("T%2.2d", $1);
			mkdir($cfg{"outdir"} . "\\Index\\$od", MODE);
#			$c = "n" if ($c eq "_");
#			$oof = $of;
			#base name for file
			$xu = 0;
			$fileopen = 0;
			$num = 0;
			$bof = $cfg{"outdir"} . sprintf("\\Index\\$od\\%4.4d$c", $2, $3);
		}
		$bib =~ s/^\t+//;
		$ebib = $bib;
	}
	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
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
		$text =~ s/\[ï¼Š\]//;
		$text =~ s/#[0-9][0-9]#//g;
		while(@ind){
			&checkind;
		}
		@ind = ();
		@aftind = ();
#		print OF $text;
		$text = "";
#		close (OF);
		$vl = "";
		$num = 0;
	}
	
	
	$bib = "";
#	print STDERR "$pass\n";
}

sub doind{
	local($c) = $_[0];
#	print STDERR "--$c\n" if ($c =~ /\xef/);
	return if ($c =~ /^\xef\xbc\x8a$/);  #so krieg ich endlich die Sternchen weg!
#	print STDERR $c, "\n"  if ($c =~ /M[0-9]{6}/);
	if ($cfg{"out"} ne ""){
		$c =~ s/($pattern)/$utf8out{$1}/eg;
	}
#b5 specific!!	
	if ($pass == 0){
		if (($c =~ /[\xa4-\xfe][\x40-\xfe]|\&[CM][^;]*;/ && $cfg{"out"} ne "") || ($c =~ /[\xe4-\xef][\x80-\xbf][\x80-\xbf]|\&[CM][^;]*;/ &&  $cfg{"out"} eq "") ){
##?		'[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|&[^;]*;|\<[^\>]*\>'
			$ccnt++ if ($rt == 0);
#			print STDERR "$rt\n" if ($rt != 0);
			$ccnt = sprintf("%2.2d", $ccnt);
			$tag = sprintf("\$%s\$%1.1d%1.1d", $rt, $bt{$btc}, $et);
			push (@ind, "$c\t$vl$lb$ccnt$tag");
			push (@aftind, "$c\t$vl$lb$ccnt$tag") if ($app ==0 && $aft <= $rchars);
			if ($#ind > $rchars){
				&checkind;
			}
		}
	}
}

sub checkind{
#indexed character
	local($lc) = "";
	local($x) = shift(@ind);
#following two characters	
	local($c) = join("", @ind);
#indicate last character of line	
	my $tc = 			substr($c, index($c, "\t") +9, 2) ;
	my $tx = 			substr($x, index($x, "\t") +9, 2) ;
	if ($tc == $tx +1){
#add 1 if last character of line	
		substr($x, index($x, "\t") +8, 1) +=  1 ;
#		print STDERR "$tx\t$tc\t$x\n";

#	} elsif (substr($c, index($c, "\t") +11, 2) == "01"){
#		substr($x, index($x, "\t") +8, 1) +=  3 ;
	}
	$c =~ s/\+//g;
	$c =~ s/\$//g;
	$c =~ s/\t[0-9]+//g;
	if ($lchars > -1){
		$lc = join("", @lch);
		$lc =~ s/\+//g;
		$lc =~ s/\$//g;
		$lc =~ s/\t[0-9]+//g;
		$c .= ",$lc";
		shift(@lch);
		push(@lch, $x);
	}
	if ($x =~ /\$\+/){
		while	 ($x =~ /\+/){
#		010044510403$+3+4$40
			$y = $x;
			$y =~ s/\$\+/\$/;
			$y =~ s/\+[0-9]//g;
			$y =~ s/\$//g;
			substr($y, index($y, "\t"), 1) = "$c\t";
			&outpr ("$y\n");
			$x =~ s/\$\+[0-9]/\$/;
		}
	} else {
		$x =~ s/\$//g; 
		substr($x, index($x, "\t"), 1) = "$c\t";
		&outpr ("$x\n");
	}
	if ($app == 0 && $aft <= $rchars ){
		$aft++;
		for ($i=1; $i <= $rdg; $i++){
			@rind = split(/##/, $rdgind{$i});
			$x = shift (@rind); 
			$rdgind{$i} = join("##", @rind);
			$c = join("", @rind);
			$c .= join ("", @aftind);
			$c =~ s/\+//g;
			$c =~ s/\$//g;
			$c =~ s/\t[0-9]+//g;
			$c .= ",$lc" if ($lchars > -1);

			if ($x =~ /\+/){
				while ($x =~ /\$\+/){
		#			010044510403$+3+4$40
					$y = $x;
					$y =~ s/\$\+/\$/;
					$y =~ s/\+[0-9]//g;
					$y =~ s/\$//g;
					substr($y, index($y, "\t"), 1) = "$c\t";
					&outpr ("$y\n");
					$x =~ s/\$\+[0-9]/\$/;
				}
				
			} else {
				$x =~ s/\$//g; 
				substr($x, index($x, "\t"), 1) = "$c\t";
				&outpr ("$x\n");
			}
		}
	}
}


sub b5jp{
	my $c = shift;
	return $b5jpiz{$c} if ($b5jpiz{$c} ne "");
	return $c;
}

sub outpr {
	local ($p) = shift;
	local ($q) = $p;
	my $fn = "";
#jpiz	
	if ($cfg{"dojpiz"} == 1) {
		$q =~ s/($pattern)/&b5jp($1)/eg;
		print $q if ($p ne $q);
	}
	
	if ($p =~ /\&([^;]*);/){
		local($char) = $1;
		$q = $p;
#		print STDERR "$char\t$nor{$char}\t$des{$char}\n";
		if ($m2utf8{"&$char;"}){
#				print STDERR "$m\n" if ($char =~ /00262|48305|06209|72201/);
				$q =~ s/(\&[^;]*;)/$m2utf8{$1}/eg;
				print $q;
		} else {
#no utf char for this &M, so shift to shiftmojikyo	 if ^&M
			if ($q =~ /\&M/){
#				print STDERR "$q\n";
				$q =~ s/(\&[^;]*;)/&toutf8(&shiftm($1))/eg;
				print $q;
			} else {
				print $q;
			}
##  normalized
		if ($cfg{"donor"} == 1){
			if ($nor{$char} ne ""){
				$q =~ s/0$/1/ if ($q =~ /^\&/);
				$q =~ s/\&([^;]*);/&repnor($1)/eg;
				print $q;
			} 
		}
		if ($cfg{"dodes"} == 1){
## description
			if ($des{$char} ne ""){
				$q = $p;
				$q =~ s/0$/2/ if ($q =~ /^\&/);
				$q =~ s/\&([^;]*);/&repdes($1)/eg;
				print $q;
			}
		}	
		}
	} else {
#no entity:	
		print $p;
	}
}


sub char_handler 
{
	my $p = shift;
	my $char = shift;
#	print STDERR "$char\n" if( $char =~ /Taisho/);
	$char =~ s/($pattern)/&doind($1)/eg;
	$char =~ s/\n//g;
	
	$bib .= $char if ($bibl == 1);
	$text .= $char if ($pass == 0 && $el ne "pb");
#	print STDERR "$char\t$vl $lb $bt\n" if ($char ne "");
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
	$lbprinted = 0;
	$vl = substr($file, 1, 2);
	$parser->parsefile($file);
#	die;
}
print STDERR "Done!!\n";

sub shead{
	print $short;
}



sub xchangefile{
			$text =~ s/\n//;
			$text =~ s/\x0d$//;
			close (OF);
			$of = sprintf("$bof%3.3d.txt", $num);
			open (OF, ">$of");
			$fileopen = 1;
			print STDERR " --> $of\n";
			select(OF);
			if ($num == 0 || ($xu == 0 && $num == 1)){
				&head;
			} else {
				&shead;
			}
#			print OF "\n$text";
			$text = "";
			$oldbof = $bof;
}


sub shiftm{
	my $m = shift;
	$m =~ s/\&|;|M//g;
#	print STDERR "$m\n" if ($m =~ /00262|48305|06209|72201/);
	my $u1 = pack("s", ($m / 1024) + 0xF000 );
	my $u2 = pack("s", ($m % 1024) + 0xF400 );
	return "$u1$u2";
}




__END__
:endofperl
