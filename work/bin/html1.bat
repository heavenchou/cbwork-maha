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

print STDERR << "XXX";
+----------------------------------
| html1.bat
| Version 0.1, 2002/6/26 05:23PM
| �@���@��
+----------------------------------
XXX

$imgpath = "../images/";
$scriptpath = "../script/";
$csspath = "../";
$fontpath = "../fontimg/";
$absFontPath = "x:/cbeta/html/fontimg";

open O, ">c:/cbwork/err.txt";
close O;

$chm;
$nid=0;
$vol = shift;
$inputFile = shift;
$vol = uc($vol);
$dir = $vol;
$vol = substr($vol,0,3);

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
	chomp;
	($key, $val) = split(/=/, $_);
	$key = uc($key);
	$cfg{$key}=$val; #store cfg values
	print "$key\t$cfg{$key}\n";
}

$outDir = $cfg{"OUTDIR"};
mkdir($cfg{"OUTDIR"}, MODE);
mkdir($cfg{"OUTDIR"} . "\\HTML", MODE);
mkdir($cfg{"OUTDIR"} . "\\HTML" . "\\$dir", MODE);

opendir (INDIR, $cfg{"XML_ROOT"} . "/$dir");
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "hhead.pl";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

#openOF();    # ���U�g�� T99.htm

use XML::Parser;
use Image::Size;

my $debug=0;
my %Entities = ();
my $ent;
my $val;
my $text;
my $headText;
my $div1head;
my $juanText;
my $juanNum;
my $juanURL;
my $flagSource=0;
local $no_nor;  # �ʦr���γq�Φr
my $source;
my $column="";    # �O���ثe���X�A�p�G0001a
my $preColumn=""; # �W�@��
my $sutraNum="";  # �O���ثe�g���A�p�G1111
my $sutraName=""; # �g�W
my $div1Type="";
my $div2Type="";
my $headId="";
my @saveatt=();   # �x�s attribute
my @lines=();     # �x�s�W�@�檺�g��
my @elements=();
my %saveXu=();
my %saveJuan=();
my %savePin=();   # �~
my %savePin2=();  # �~ (div2)
my %saveHui=();   # �|
my %saveFen=();   # ��
my %saveJing=();  # �g
my %saveOther=();
my $version;
my $firstLineOfSutra;
my $firstLineOfPage;
my $saveof = "";
my $CorrCert;

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

my %lastpage = (
  "T01","0924c",
  "T02","0884b",
  "T03","0975c",
  "T04","0802b",
  "T05","1074c",
  "T06","1073b",
  "T07","1110b",
  "T08","0917b",
  "T09","0788b",
  "T10","1047b",
  "T11","0977a",
  "T12","1119b",
  "T13","0998a",
  "T14","0968c",
  "T15","0807a",
  "T16","0857c",
  "T17","0963a",
  "T22","1072a",
  "T23","1057b",
  "T24","1122a",
  "T25","0914a",
  "T26","1031c",
  "T27","1004a",
  "T28","1001b",
  "T29","0977c",
  "T30","1035b",
  "T31","0896b",
  "T32","0790c"
);

#my $parser = new XML::Parser(Style => Stream, NoExpand => True);
my $parser = new XML::Parser(NoExpand => True);
        

$parser->setHandlers
				(Start => \&start_handler,
				Init => \&init_handler,
				End => \&end_handler,
		     	Char  => \&char_handler,
		     	Entity => \&entity,
		     	Default => \&default);
        
if ($inputFile eq "") {
  for $file (sort(@allfiles)){
	  print STDERR "\n$file\n";
	  $parser->parsefile($file);
  }     
} else {
  $file = $inputFile;
  print STDERR "\n$file\n";
  $parser->parsefile($file);
}       
        
print STDERR "����!!\n";
unlink "c:/cbwork/err.txt";
        
#-------------------------------------------------------------------
sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) { return; }
	#local($k) = "." . $cfg{"CHAR"};
	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
	#$file =~ s#/#\\#g;
	#$file =~ s/\.\./$cfg{"DIR"}/;
	print STDERR "�}�� Entity �w�q��: $file\n";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
			/^(.+)\s+\"(.*)\".*/;
			$ent = $1;
			$val = $2;
			$ent =~ s/ //g;

			if ($file=~/jap\.ent/) { # �p�G�O���
				if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # �u���ϥ� Unicode
				$no_nor{$ent} = $val;
			} elsif ($ent =~ /SD-.{4}/) {
				$Entities{$ent} = "��";
				$no_nor{$ent} = "��";
				next;
			} else {
				if ( $val=~/mojikyo=\'(.+?)\'/) {
					my $m=$1;  # �_�h�� M �X
					my $des = "";
					if ( $val=~/des=\'(.+?)\'/) { $des=$1; } # �_�h�� M �X
					else { $des = $m; }
					#if ($des=~/\[(.*)\]/) { $des = $1; }
					$m =~ s/^M//;
					push @mojikyo,$m;
					if (-e "$absFontPath/$m.gif") {
						my $href = "javascript:showpic(\"${fontpath}$m.gif\")";
						if ($des=~/^(.*?)\[(.*)\](.*)$/) {  # �i��O�q�ε�
							$no_nor{$ent} = $1 . "[<a href='$href'>$2</a>]" . $3;
						} else {
							$no_nor{$ent} = "[<a href='$href'>$des</a>]";
						}
					} else {
						$no_nor{$ent} = $des;
					}
				} elsif ( $val=~/des=\'(.+?)\'/) {  # �զr��
					$no_nor{$ent} = $1;
				} else { 
					$no_nor{$ent} = $ent; 
				} # �̫�� CB �X
				
				if ($val=~/nor=\'(.+?)\'/) { # �u���ϥγq�Φr
					$val=$1; 
				} else {
					$val = $no_nor{$ent};
				}
			}
		} else {
			s/\s+>$//;
			($ent, $val) = split(/\s+/);
			$val =~ s/"//g;
			$no_nor{$ent} = $val;
		}    
		$Entities{$ent} = $val;
	}     
}       
        
        
sub default {
    my $p = shift;
    my $string = shift;
        
	# added by Ray 1999/11/23 05:25PM
	# <note type="sk">, <note type="foot"> �����e�����
	my $parent = lc($p->current_element);
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
  }     
        
    $string =~ s/^\&(.+);$/&rep($1)/eg;
    if ($bibl == 1){
		$bib .= $string ;
#		print STDERR "$bib\n";
	}
	if ($$text_ref =~ /(.*)<\/font>$/) {
	  my $s1 = $1;
	  if ($string =~ /^<font face=\"CBDia\">(.*)/) {
	    $$text_ref = $s1 . $1;
	  } elsif ($string =~ /^(\w)$/) {
	    $$text_ref = $s1 . $1 . "</font>";
	  } else {	$$text_ref .= $string if ($pass == 0); }
	} else {	$$text_ref .= $string if ($pass == 0); }
}       
        
sub init_handler
{       
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$div1Type='';
	$fileopen = 0;
	$num = 0;
	$oldof = "";
	$oldpath = "";
	$close = "";
	$no_nor=0;
	$title = "";
	@elements=();
	@close=();
	@no_nor=();
	$text="";
	$text2 = '';
	$text2_dirty = 0;
	$text_ref = \$text;
	$twoLineModeLine = 0;
	$xu=0;
}       
        
        
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	
	push @no_nor, $no_nor;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	
	my $parent = lc($p->current_element);
        
	$elementChar="";
        
	### <body> ###
	$pass = 0 if $el eq "body";
       
	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>�@�@�@�@" ;
		#$indent = "<br>�@�@�@�@";
		$$text_ref .= "<p><span class='byline'>�@�@�@�@" ;
		     
		# marked by Ray 1999/11/30 10:26AM
		#$indent = "�@�@�@�@";
	}     
       
	### <cell>
	if ($el eq "cell" and not $pass) {
		$$text_ref .= "<td";
		if ($att{"rows"} ne '') {
			$$text_ref .= ' rowspan="' . $att{"rows"} . '"';
		}
		if ($att{"cols"} ne '') {
			$$text_ref .= ' colspan="' . $att{"cols"} . '"';
		}
		$$text_ref .= ">";
	}
	
	### <corr>
	if ($el eq "corr") {
	  $CorrCert = lc($att{"cert"});
	  if ($CorrCert ne "" and $CorrCert ne "100") {
	    my $sic = myDecode(lc($att{"sic"}));
	    $$text_ref .= $sic;
	  } else {
		  $$text_ref .= "<span class='corr'>";
	  }
	}
       
	### <div1> ###
	if ($el eq "div1"){
		$div1head = "";
		# div1 �� type �ݩʥi�H����W�@�� div1
		if ($att{"type"} ne "") { 
			$div1Type = lc($att{"type"}); 
		}
		if ($div1Type eq "xu"){
			if ($xu != 1 and $num==0) { changefile(); }
			$xu = 1;
			$num = 0;
		#} elsif ($num == 0 && (div1Type eq "juan" || div1Type eq "jing" || div1Type eq "pin" || div1Type eq "other")) {
		} elsif ($num == 0 && div1Type ne "w") {
			if ($juanNum == 0) {
				if ($vol eq "T06") { $juanNum = 201; }
				elsif ($file eq "T07n0220c.xml") { $juanNum = 401; }
				elsif ($file eq "T07n0220d.xml") { $juanNum = 538; }
				elsif ($file eq "T07n0220e.xml") { $juanNum = 566; }
				elsif ($file eq "T07n0220f.xml") { $juanNum = 574; }
				elsif ($file eq "T07n0220g.xml") { $juanNum = 576; }
				elsif ($file eq "T07n0220h.xml") { $juanNum = 577; }
				elsif ($file eq "T07n0220i.xml") { $juanNum = 578; }
				elsif ($file eq "T07n0220j.xml") { $juanNum = 579; }
				elsif ($file eq "T07n0220k.xml") { $juanNum = 584; }
				elsif ($file eq "T07n0220l.xml") { $juanNum = 589; }
				elsif ($file eq "T07n0220m.xml") { $juanNum = 590; }
				elsif ($file eq "T07n0220n.xml") { $juanNum = 591; }
				elsif ($file eq "T07n0220o.xml") { $juanNum = 593; }
				else { $juanNum = 1; }
			}
			changefile();
			$num = 1;
		}    
	}     
       
	### <div2> ###
	if ($el eq "div2"){
	  # div2 �� type �ݩʥi�H����W�@�� div2
	  if ($att{"type"} ne "") {	$div2Type = lc($att{"type"}); }
	}     
       
	### <figure>
	if ($el eq "figure") {
		my $ent = $att{"entity"};
		my ($x, $y) = imgsize($cfg{"OUTDIR"} . '/html/figures/' . $figure{$ent});
		$x = int($x/2);
		$y = int($y/2);
		$$text_ref .= '<img src="' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
	}

	### <gloss> ###
	$pass++ if $el eq "gloss";
	      
	### <head> ###
	if ($el eq "head") { 
	  $headText=""; 
	  if (lc($att{"type"}) eq "added"){
		  $pass++;
		  $added = 1;
	  } else {
		  $$text_ref .=	"<p><b>�@�@" ;
		  $bibl = 1;
		  $bib = "";
		  $nid++;
		  $$text_ref .= "<A NAME=\"n$nid\"></A>";
	  }   
	      
	  # �V�L <lem>, <term> <corr> �� parent
	  my $i = @elements - 2;
  while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
    if ($parent eq "lem") {
      $i -= 2;
       $parent = $elements[$i];
     } elsif ($parent eq "term") {
       if ($elements[$i-1] eq "skgloss") { 
         $i -= 2;
         $parent = $elements[$i];
       } else { last; }
     }	elsif ($parent eq "corr") {
       $i--;
       $parent = $elements[$i];
     } 
   }   
	      
	  if ($parent eq "div1") {
       $headId = "/$vol$column.htm#$lb";
   }   
  	   
  	# �p�G�O��Y����div2���~
  	if ($chm eq "BoRuo" and $parent eq "div2" and $div2Type eq "pin") {
     my $id = keys(%savePin2) + 1;
     if ($id < 10) { $id = "0" . $id; }
     $headId = "/$vol$column.htm#$lb";
  	}  
	}     
	      
	if ($head == 1){
		#$bibl = 1 if ($el =~ /^bibl|title|p$/);
		$bibl = 1 if ($el =~ /^bibl$/);
	}     
       
	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}    
	}     
       
	### <figure>
	if ($el eq "figure") {
		my $ent = $att{"entity"};
		my ($x, $y) = imgsize($outDir . '/html/' . $figure{$ent});
		$x = int($x/2);
		$y = int($y/2);
		$$text_ref .= '<img src="../' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
		#$text .= '<img src="' . $figure{$ent} . '">';
	}

	### <item> ###
	if ($el eq "item" and $pass==0){
		$$text_ref .= "<li>";
	}
	
	### <juan> ###
	if ($el eq "juan"){
		$juanText="";
		$xu = 0;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
			$juanNum = $num;
			$bibl = 1;
			$bib = "";
			$nid++;
			#$text .= "<A NAME=\"n$nid\"></A>";
			if ($div1Type ne "w") { changefile(); }
		} else {
		}    
		$$text_ref .= "<p class='juan'>\n";
	}     
       
	### <l> ###
	if ($el eq "l"){
		#$text .= "�@";
		my $rend = $att{"rend"};
		$rend =~ s/($pattern)/$utf8out{$1}/g;
		$rend = parseRend($rend);
		if ($rend eq "" and $lgType ne "inline" and $lgRend ne "inline") { 
			$rend = "�@"; 
		}
		# �p�G�U�|�e�� (
		if ($$text_ref =~ /(.*��.*)\($/s) {
			$$text_ref = $1 . $rend . "(";
		} else { $$text_ref .= $rend; }
	}     
       
	### <lb> ###
	if ($el eq "lb"){
		$lb = $att{"n"};
		if ($column eq "") { $column = substr($lb,0,5); }
		#if ($lb =~ /614b28/) { $debug=1; }
		if ($debug) {
			print STDERR "lb=$lb twoLineModeLine=$twoLineModeLine\n";
			print STDERR "text=$text\n";
			print STDERR "text2=$text2\n";
		}
		
		if ($twoLineModeLine == 2) {
			$text_ref = \$text2;
			$$text_ref = "<br>" . $$text_ref;
		} elsif ($twoLineModeLine == 1) {
			$text_ref = \$text;
			$$text_ref = "<br>" . $$text_ref;
		} else {
			$text_ref = \$text;
		}
		
		if ($fileopen == 1) {
			#the whole line has been cached to $text, print it now!
			printOneLine();
			$$text_ref = '';
		}

		if ($twoLineModeLine==1) {
			$twoLineModeLine=2;
		} elsif ($twoLineMode and $twoLineModeLine==2){
			$twoLineModeLine=1;
		} else {
			$twoLineModeLine=0;
		}
		     
		if ($twoLineModeLine==2){
			$text2 = "$br$indent" . $text2;
		} elsif ($pass==0) {
			$text .= "$br$indent";
		}

		if ($twoLineMode and $count_t > 1) {
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}

		if ($firstLineOfPage) { 
			$firstLineOfPage = 0; 
		} else { 
			#$text = "</a>" . $text; 
		}

	  if ($firstLineOfSutra) {
	    my $num = $sutraNum;
	    $num =~ s/^0//;
	    $num =~ s/^0//;
	    $num =~ s/^0//;
	    #print FTOC "<a href=\"$chm.chm::/$vol$column.htm\">No. $num $sutraName</A></TH>\n";
      #print FTOC "</THEAD>\n<TR><TD>\n";
      $firstLineOfSutra = 0;
   }
	}     
       
	### <lg> ###
	if ($el eq "lg" ){
		$lgType = $att{"type"};
		$lgRend = $att{"rend"};
		$$text_ref .= "<p class='lg'>";
		if ($lgType ne "inline" and $lgRend ne "inline") {
			$br = "<br>";
		}
	}     
	      
	### <list> ###
	if ($el eq "list" and $pass==0) {
		if ($att{"id"} ne '') {
			$$text_ref .= '<a name="' . $att{"id"} . '"></a>';
		}
		$$text_ref .= "<ul>";
	}
	
	### <milestone>
	if ($el eq "milestone") {
		$rend = $att{"rend"};
		$rend =~ s/($pattern)/$utf8out{$1}/g;
		$$text_ref .= $rend;
	}

	### <note> ###
	if ($el eq "note") {
		# CBETA �[�� note �����
		if ($att{"resp"} =~ /^CBETA/) {
			$pass++;
		}
		if ($pass==0) {
			if (lc($att{"type"}) eq "inline" or lc($att{"place"}) eq "inline"){
				$$text_ref .= "(";
				$close = ")";
			}
		}
		push @close, $close;
	}
       
	### <p> ###
	if ($el eq "p"){
	  $ptype = lc($att{"type"});
	  if ($ptype eq "w" or $ptype eq "winline") {
		  $$text_ref .= "<blockquote class='FuWen'>";
		  $indent = "";
	  } else {
		  $$text_ref .= "<p>";
	  }   
	  if ($ptype eq "ly" && $head==1) { $flagSource=1; }
	}     
	      
	### <pb> ###
	if ($el eq "pb") {
		$firstLineOfPage = 1;
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
		     
		if ($twoLineModeLine == 2) {
			$text_ref = \$text2;
		}
		printOneLine();
		#print "<hr><br><br>";
	 
		#changefile($att{"n"});
       
		$preColumn = $column;
		$column = $att{"n"};
	      
		#print "<font face='Arial'><h2>$mtit</font> ";
		$juanNum =~ s/^0{1,2}(\d{1,2})/$1/;
		#if ($juanNum ne "") { print "<font face='Arial'>(��$juanNum)</font>" };
		if ($div1head ne "") { 
			if ($div1head =~ /^#\d\d#(.*)/) { $div1head = $1; }
			if ($div1head =~ /(.*��)��$/) { $div1head = $1; }

			# "�@" = \xa4\x40
			if ($div1head =~ /(.*�w)��\xa4\x40$/) { $div1head = $1; }

			if ($div1head =~ /^�].+�^(��.+��)$/) { $div1head = $1; }

			# "�]�@�^�Ĥ@��" -> "�Ĥ@��"
			# \xa1\x5d = "�]" ,  \xa1\x5e = "�^"
			if ($div1head =~ /^\xa1\x5d.+\xa1\x5e(��.+��)$/) { $div1head = $1; }
			#print " $div1head"; 
		}
		#print " <font face='Arial'>$vol, p$column</h2></font><hr>\n";
		#print "<span class='old'>\n";
		#print shift @lines;
		#print shift @lines;
		#print "</span>";
	}     
	      
       
	### <rdg> ###
	$pass++ if $el eq "rdg";
	
	### <ref> ###
	if ($el eq "ref" and not $pass) {
		$$text_ref .= '<a href="#' . $att{"target"} . '">';
	}
	
	### <row> ###
	if ($el eq "row" and not $pass) {
		$$text_ref .= "<tr>";
	}
       
	### <sg> ###
	if ($el eq "sg") {
		my $close='';
		if ($pass==0){
			$$text_ref .= "(";
			$close = ")";
		}
		push @close, $close;
	}     

	### <table> ###
	if ($el eq "table" and not $pass) {
		$$text_ref .= '<table border="1" cellspacing="0" cellpadding="5">';
	}
	
	### <teiHeader> ###
	$head = 1 if $el eq "teiHeader";  #We are in the header now!
       
	### <t> ###
	if ($el eq "t"){
		$count_t ++;
		if ($twoLineMode==1 and $count_t > 1) {
			$text2_dirty = 1;
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
		if (defined($att{"rend"})) { 
			$$text_ref .= $rend;
		} elsif (not $tt_inline and $$text_ref !~ /��$/ and $$text_ref ne '') {
			$$text_ref .= "�@";
		}
	}
	
	### <tt> ###
	if ($el eq "tt") {
		if ($att{"rend"} eq "inline" or $att{"type"} eq "inline") {
			$tt_inline = 1;
		} else {
			$tt_inline=0;
		}
		if (not $tt_inline) {
			$twoLineMode = 1;
			$twoLineModeLine = 1;
			$count_t = 0;
		} else {
			$twoLineMode = 0;
			$twoLineModeLine = 0;
		}
	}
} # end start_handler
        
sub rep{
	local($x) = $_[0];
	local $got=0;

	if ($no_nor) {
		if (defined($no_nor{$x})) { 
			$str = $no_nor{$x}; 
			$got = 1;
		}
	} else {
		if (defined($Entities{$x})) { 
			$str = $Entities{$x}; 
			$got=1;
		}
	}

	if ($str =~ /^\[(.*)\]$/) {
		my $exp = $1;
		if (defined($dia{$exp})) {
			$str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
			if ($debug) { print STDERR "689 $str\n"; }
			return $str;
		}
	}   
	
	if ($got) {
		return $str;
	} else {
		die "667 Unknkown entity $x!! no_nor=$no_nor\n";
	}

	return $x;
}       
        
        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
	
	## </cell> ###
	if ($el eq "cell" and not $pass) {
		$$text_ref .= "</td>";
	}
       
	# </edition>
	if ($el eq "edition") {
	  $version =~ /\b(\d+\.\d+)\b/;
	  $version = $1;
	}     
       
	$head = 0 if $el eq "teiheader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";
	      
	### </juan> ###
	if ($el eq "juan" ){
		$bibl = 0;
		$bib =~ s/\[[0-9�][0-9�]\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$bib = "";
		$$text_ref .= "</p>\n";
		     
		if (lc($att->{"fun"}) eq "open" and $div1Type ne "w") {
     my $id = %saveJuan + 1;
     $id = "/$vol$column.htm#$lb";
     my $num = $juanNum;
     $num =~ s/^0//;
     $num =~ s/^0//;
     $juanText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
     $juanText =~ s/\[��\]//g;
     #$saveJuan{$id}=$num . " " . $juanText;
     $saveJuan{$id}= "��" . cNum($juanNum);
     $juanURL = $id;
		} elsif (lc($att->{"fun"}) eq "close" and $div1Type ne "w") {
     $juanText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
     $juanText =~ s/\[��\]//g;
     my $i = cNum($juanNum);
		  #print FTOC "<TD><A HREF=\"$chm.chm::$juanURL\">����$i</A>\n";
		  #print FTOC "<TR><TD>\n";
		}    
	}     
       
	### </head> ###
	if ($el eq "head" ) {
	  if ($added == 1) {
		  $pass--;
		  $added = 0;
	  }   
       
   my $i = @elements - 1;
  while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
    if ($parent eq "lem") {
      $i -= 2;
       $parent = $elements[$i];
     } elsif ($parent eq "term") {
       if ($elements[$i-1] eq "skgloss") { 
         $i -= 2;
         $parent = $elements[$i];
       } else { last; }
     }	elsif ($parent eq "corr") {
       $i--;
       $parent = $elements[$i];
     } 
   }   
       
   # </div1>
   if ($parent eq "div1") {
     $headText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
     $headText =~ s/\[��\]//g;
     $div1head = $headText;
     if ($debug) { print STDERR "div1Type=[$div1Type]\n"; }
     if ($div1Type eq "xu") {
       #$text .= "</a>";
       $saveXu{$headId}=$headText;
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$headText</A><BR>\n";
     } elsif ($div1Type eq "pin") {
       #$text .= "</a>";
       $headText =~ s/^(.*�~)(��.*)$/$1/;
       $savePin{$headId}=$headText;
       my $i = keys(%savePin);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
       if ($debug) {
         print STDERR "headId=[$headId]\n";
         print STDERR "headText=[$headText]\n";
       }
     } elsif ($div1Type eq "hui") {
       #$text .= "</a>";
       $headText =~ s/^(.*�|)(��.*)$/$1/;
       $saveHui{$headId}=$headText;
       my $i = keys(%saveHui);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
     } elsif ($div1Type eq "fen") {
       #$text .= "</a>";
       $headText =~ s/^(.*��)(��.*)$/$1/;
       $saveFen{$headId}=$headText;
       my $i = keys(%saveFen);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
     } elsif ($div1Type eq "other" or $div1Type eq "jing") {
       #$text .= "</a>";
       $saveOther{$headId}=$headText;
       
       my $aa = quotemeta("�]");
       my $bb = quotemeta("�^");
       if ($headText =~ /^$aa.*$bb$/) {
         #print FTOC "<A HREF=\"$chm.chm::$headId\">$headText</A><BR>\n";
       } else {
         my $i = keys(%saveOther);
         #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
       }
       
       #print STDERR "[$headId,$headText]\n";
     } 
   }   
       
   # </div2>
   if ($parent eq "div2" and $chm eq "BoRuo" and $div2Type eq "pin") {
       $$text_ref .= "</a>";
       #$headText =~ s/^(.*�~)(��.*)$/$1/;
       $savePin2{$headId}=$headText;
       my $i = keys(%savePin2);
       #print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
   }   
       
   $$text_ref .= "</b>";
		$bibl = 0;
		$bib =~ s/\n//g;
		$bib =~ s/\[[0-9�][0-9�]\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$bib = "";
		$indent = "" ;
	}     
	      
	### </lg> ###
	if ($el eq "lg" ){
		$$text_ref .= "</p>";
		$br = "";
	}     
       
	### </byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:34AM
		#$text .= "</span>" ;
		$$text_ref .= "</span><br>" ;
	}     
       
  ## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { $$text_ref .= "</span>"; }
	}     
       
	$indent = "" if ($el eq "byline");
	$indent = "" if ($el eq "p");

	## </l>
	#$text .="�@" if $el eq "l";
	if ($el eq "l") {
		if ($lgType ne "inline" and $lgRend ne "inline") {
			$$text_ref .= "�@";
		}
	}
       
	## </list> ###
	if ($el eq "list") {
		$$text_ref .= "</ul>";
	}

	## </note> ###
	if ($el eq "note"){
		$close = pop @close;
		if ($close ne "") {
			if ($$text_ref =~ /(.*)<\/font>$/) {
				$$text_ref = $1 . $close . "</font>";
			} else { 
				$$text_ref .= $close 
			}
		}
		$close = "";
		if ($att->{"resp"} =~ /^CBETA/) {
			$pass--;
		}
	}     
	      
	### </bibl> ###
	if ($el eq "bibl"){
		$bibl = 0;
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			$prevof = "";
			$sutraNum = $2;
			$chm = getchm($sutraNum);
			if ($3 eq ""){
				$c = "_";
			} else {
				$c = $3;
			  $sutraNum .= $c;
			}  
      
			# �N�g���ɺ��|���
			if ($sutraNum =~ /\d$/) {
				$sutraNum = "0" x (4-length($sutraNum)) . $sutraNum;
			} else {
				$sutraNum = "0" x (5-length($sutraNum)) . $sutraNum;
			}
			#print the rest of the line of the old file!
			printOneLine();
			$$text_ref = "";
			$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("t%2.2d", $1);
			#mkdir($cfg{"OUTDIR"} . "\\htmlhelp\\$od", MODE);
			#		$c = "n" if ($c eq "_");
			#		$oof = $of;
			#base name for file
       
			$xu = 0;
			#$fileopen = 0;
			$num = 0;
			$bof = $cfg{"OUTDIR"} . "/html/$vol/$sutraNum";
			$bof =~ tr/A-Z/a-z/;
			if (length($sutraNum)<5) { $bof .= "_"; }
			print STDERR "764 bof=$bof\n";
			$fhead = $cfg{"OUTDIR"} . sprintf("\\htmlhelp\\$od\\%4.4dh", $2, $3);
			$fhead =~ tr/A-Z/a-z/;
			   
			$mtit = $title;
			$mtit =~ s/Taisho Tripitaka, Electronic version, //;
			$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
			$mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
			$sutraName = $mtit;
			$sutraName =~ s/No\. \d*\w* //;
       
			$firstLineOfSutra = 1;
			$firstLineOfPage = 1;
     
			# added by Ray 1999/12/15 10:50AM
			if ($vol eq "T06") { $juanNum = 201; }
			elsif ($sutraNum eq "0220c") { $juanNum = 401; }
			elsif ($sutraNum eq "0220d") { $juanNum = 538; }
			elsif ($sutraNum eq "0220e") { $juanNum = 566; }
			elsif ($sutraNum eq "0220f") { $juanNum = 574; }
			elsif ($sutraNum eq "0220g") { $juanNum = 576; }
			elsif ($sutraNum eq "0220h") { $juanNum = 577; }
			elsif ($sutraNum eq "0220i") { $juanNum = 578; }
			elsif ($sutraNum eq "0220j") { $juanNum = 579; }
			elsif ($sutraNum eq "0220k") { $juanNum = 584; }
			elsif ($sutraNum eq "0220l") { $juanNum = 589; }
			elsif ($sutraNum eq "0220m") { $juanNum = 590; }
			elsif ($sutraNum eq "0220n") { $juanNum = 591; }
			elsif ($sutraNum eq "0220o") { $juanNum = 593; }
			else { $juanNum = 1; }
		}    
		$bib =~ s/^\t+//;
		$ebib = $bib;
		#&changeSutra;
		#openOF();
		#changefile();
	}

	### </title> ###
	if ($el eq "title"){
		#$bib =~ s/^\t+//;
		#$title = $bib;
	}     
       
	### </div1> ###
	#if ($el eq "div1"){
	#  $div1Type="";
	#}    
       
	### </div> ###
	if ($el =~ /div/i){
		$xu = 0;
	}     
       
	## </item> ###
	if ($el eq "item") {
		$$text_ref .= "</li>";
	}
  ## </p> ###
	if ($el eq "p"){
		if ($head == 1) {
  	$bib =~ s/^\t+//;
		  #$ly{$lang} = $bib;
  	$source =~ s/^\t+//;
		  $ly{$lang} = $source;
		  $flagSource = 0;
		  $source="";
		}    
		if (lc($att->{"type"}) eq "w") { $$text_ref .= "</blockquote>"; }
	}     
       
	if ($el eq "teiHeader"){
#	&head;
	}     
	$lang = "" if ($el eq "p");
	
	### </ref> ###
	if ($el eq "ref" and not $pass) {
		$$text_ref .= "</a>";
	}
	
	### </row> ###
	if ($el eq "row" and not $pass) {
		$$text_ref .= "</tr>";
	}
       
	## </sg> ###
	if ($el eq "sg"){
		$close = pop @close;
		if ($close ne "") {
			if ($$text_ref =~ /(.*)<\/font>$/) {
				$$text_ref = $1 . $close . "</font>";
			} else { 
				$$text_ref .= $close 
			}
		}
	}

	### </table> ###
	if ($el eq "table" and not $pass) {
		$$text_ref .= "</table>";
	}

  ## </tei.2> ###
	if ($el eq "tei.2"){
		$$text_ref =~ s/\[[0-9�][0-9�]\]//g;
		$$text_ref =~ s/#[0-9][0-9]#//g;
       
		$$text_ref =~ s/\xa1\x40$//;
		$$text_ref =~ s/\xa1\x40\)$/)/;
		     
		printOneLine();
		$$text_ref = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>��</a>" if ($prevof ne "");
		#print "</html>\n";
		closeOF();
		$vl = "";
		$num = 0;
	}     
	      
	# </tt>
	if ($el eq "tt"){
		$twoLineMode = 0;
		$text_ref = \$text;
	}
	      
	$bib = "";
	$no_nor = pop @no_nor;
#	print STDERR "$pass\n";
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	# <note type="sk"> �����e�����
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
		if ($noteType eq "sk") {  return;  }
		if ($noteType eq "foot" or $att->{"place"} eq "foot") {  return;  }
	}     

  # added by Ray 1999/12/15 10:14AM
  # ���O 100% ���ɻ~���ϥ�
  if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }
  		     
	$char =~ s/($pattern)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	      
  my $i = @elements - 1;
	while ($parent eq "lem" or $parent eq "term" or $parent eq "corr") {
	  if ($parent eq "lem") {
	    $i -= 2;
      $parent = $elements[$i];
    } elsif ($parent eq "term") {
      if ($elements[$i-1] eq "skgloss") {
        $i -= 2;
        $parent = $elements[$i];
      }  else { last; }
    }	elsif ($parent eq "corr") {
      $i--;
      $parent = $elements[$i];
    }   
  }     
	      
	if ($parent eq "head") { $headText .= $char; }
	if ($parent eq "title") { $title .= $char; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $char; }
  if ($parent eq "edition") { $version .= $char; }
        
	$bib .= $char if ($bibl == 1);
	$source .= $char if ($flagSource);
	if ($pass == 0 && $el ne "pb") {
	  if ($$text_ref =~ /(.*)<\/font>$/) {
	    my $s1 = $1;
	    if ($char =~ /^([\w\s]+)(.*)$/) { $$text_ref = $s1 . $1 . "</font>" . $2; }
	    else { $$text_ref .= $char; }
	  } else { $$text_ref .= $char; }
	}
#	print $char if ($pass == 0 && $el ne "pb");
}       
        
        
sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	if ($ent =~ /Fig/) {
		$figure{$ent} = $next;
	} else {
		&openent($next);
	}
#	print STDERR "$ent\t$entval\t$next\n";
	return 1;
}       
        
        
        
        
        
#-----------------------------------------------------------------------
sub shead{
	print $short;
}       
        
      
        
#-----------------------------------------------------------------------
sub changefile{
	#my $col = shift;
	$$text_ref =~ s/\n//;
	$$text_ref =~ s/\x0d$//;

	$of = sprintf("$bof%3.3d.htm", $juanNum);
	if ($of eq $oldof) { return; }
	
	$mof = $of;
	$mof =~ s/.*\\//;
	#print STDERR "1206 of=$of mof=$mof oldof=$oldof\n";
	#getc;
	if ($oldof ne $mof){
		if ($newpath ne $oldpath) {
			mkdir($newpath, MODE);
			$oldpath = $newpath;
		}
		#$xtoc = "${bof}toc.htm";
		$xtoc = "${bof}${vol}toc.hhc";
		$xtoc =~ s/.*\\//;
		$xtoc =~ tr/A-Z/a-z/;
		$ytoc = $bof;
		$ytoc =~ s/.*\\//;
		$ytoc =~ s/_//;
				
		closeOF();
		$fh = sprintf("$fhead%3.3d.htm", $num);
		open (OF, ">$of");
		$fileopen = 1;
		print STDERR " --> $of\n";
		select(OF);
		if ($num == 0 || ($xu == 0 && $num == 1)){
			#&head;
		} else {
			#&head;
		}
		#open(FHED, ">$fh");
		#print FHED $fhed;
       
		print "<html>\n";
		print "<head>\n";
		print '<meta http-equiv="Content-Type" content="text/html; charset=big5">' . "\n";
		print "<style>\@import url(${csspath}cbeta.css);</style>\n";
		print "<link disabled rel=\"stylesheet\" href=\"${csspath}cbeta.css\">\n";
		print "<script LANGUAGE=\"JAVASCRIPT\" SRC=\"${scriptpath}search.js\"></script>\n";
		print "<TITLE>CBETA $vol $col</TITLE>\n";
		print "</head>\n";
		print "<BODY>\n\n";
		printOneLine();
		$$text_ref = "";
		$prevof = $oldof;
		$oldof = $mof;
		$oldbof = $bof;
	}
}       

#-----------------------------------------------------------------------
sub getof {
  my $num = $sutraNum;
  my $str = "T09,T12,T26,T30";
  if ($str !~ /$vol/) { return $vol . ".htm"; }
  if ($num < 278) { return "T09-1.htm"; }
  if ($num < 279) { return "T09-2.htm"; }
  if ($num < 374) { return "T12-1.htm"; }
  if ($num < 397) { return "T12-2.htm"; }
  if ($num < 1536) { return "T26-1.htm"; }
  if ($num < 1545) { return "T26-2.htm"; }
  if ($num < 1579) { return "T30-1.htm"; }
  return "T30-2.htm";
}       
        
#-----------------------------------------------------------------------
sub getchm {
  my $num = shift;
  if ($num < 152) { return "AHan"; }
  if ($num < 220) { return "BenYuan"; }
  if ($num < 262) { return "BoRuo"; }
  if ($num < 278) { return "FaHua"; }
  if ($num < 310) { return "HuaYan"; }
  if ($num < 374) { return "BaoJi"; }
  if ($num < 397) { return "NiePan"; }
  if ($num < 425) { return "DaJi"; }
  if ($num < 848) { return "JingJi"; }
  if ($num < 1421) { return "MiJiao"; }
  if ($num < 1505) { return "Vinaya"; }
  if ($num < 1536) { return "JingLun"; }
  if ($num < 1564) { return "PiTan"; }
  if ($num < 1579) { return "ZhonGuan"; }
  if ($num < 1628) { return "YogaCara"; }
  if ($num < 1693) { return "LunJi"; }
}       
        
        
#-----------------------------------------------------------------------
# Created by Ray 1999/11/30 08:38AM
#-----------------------------------------------------------------------
sub printOneLine {
	my $big5 = '[\x00-\x7f]|[\x80-\xff][\x00-\xff]';
	if ($$text_ref eq "") { return; }
	$$text_ref =~ s/\xa1\x40$//;
	$$text_ref =~ s/\xa1\x40\)$/)/;
	$$text_ref =~ s/\[[0-9�][0-9�]\]//g;
	$$text_ref =~ s/#[0-9][0-9]#//g;
	if ($debug) { print STDERR "1296 [$$text_ref]\n"; }
	while ($$text_ref =~ /^($big5)*��((��)|( )|(�@))*��/) {
		$$text_ref =~ s/^(($big5)*?)��((��)|( )|(�@))*��/$1�i���j/;
	}
	if ($debug) { print STDERR "1300 [$$text_ref]\n"; getc; }
	print "$$text_ref";
	#if (@lines > 1) { shift @lines; }
	#push @lines, $text;
	$$text_ref = "";
}       

sub myDecode {
  my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}


sub getlast {
  my $lastvol = substr($vol,1,2) - 1;
  if ($lastvol < 10) { $lastvol = '0' . $lastvol; }
  $lastvol = 'T' . $lastvol;
  my $page = $lastpage{$lastvol};
  return "../../$lastvol/" . substr($page,0,2) . "/" . $page;
}

sub closeOF {
	print "</body></html>\n";
	close (OF);
}

sub parseRend {
	my $s = shift;
	if ($s =~ /margin-left:(\d+)/) {
		$s = "�@" x $1;
	}
	return $s;
}
        
        
__END__ 
:endofperl
