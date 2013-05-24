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

# hh3.bat �аO���ˬd�ؿ���
# v 1.1.1, modified by Ray 2003/9/17 03:59�U��
# v 1.2.1, ���w�r��, modifiedy by Ray 2003/9/22 04:56�U��
# v 1.3.1, �[�k�䤺���, 2003/9/30 10:10�W�� by Ray

### �]�w�� ###
$buildNumber = 7;
$lastVol = 32;    # �̫�@�U

$outDir = "c:/release/htmlhelp";
mkdir($outDir, MODE);

### command line parameter ###
$vol = shift;
$inputFile = shift;

$vol = uc($vol);
$dir = $vol;

# $vol = substr($vol,0,3);		# �U�ƥi��W�L�G���
$vol =~ /(^.\d+)/;
$vol = $1;

$chm=$vol;
$nid=0;
$ed=substr($vol,0,1);

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

#mkdir($cfg{"OUTDIR"}, MODE);
#mkdir($cfg{"OUTDIR"} . "\\HTMLHELP", MODE);
#mkdir($cfg{"OUTDIR"} . "\\HTMLHELP" . "\\$dir", MODE);

#opendir (INDIR, $cfg{"DIR"} . "$dir");
opendir (INDIR, ".");
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

#big5 pattern
  $big5zi = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "hhead.pl";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

openVTOC();  # ���U�ؿ� T99.hhc
openOF();    # ���U�g�� T99.htm
openHHP();   # HTML Help Project T99.hhp

use XML::Parser;
#use Image::Size;

my $debug=0;
my %Entities = ();
local %no_nor = ();
local $no_nor = 0;
my $ent;
my $val;
my $text;
my $headText;
my $div1head;
my $div2head;
my $juanText;
my $juanNum;
my $juanURL;
my $juanOld="";
my $flagSource=0;
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
my @tagBeforeLine=();
my @elements=();
my @mulu=();      # $mulu[$i][0] �ؿ����O
                  # $mulu[$i][1] �ؿ��h��
                  # $mulu[$i][2] ������ URL
                  # $mulu[$i][3] �ؿ����D
                  # $mulu[$i][4] �O�_���l�ؿ�
                  # $mulu[$i][5] �ؿ��Ҧb����
                  # $mulu[$i][6] �Ҧb���ƹ����� URL
local @close=();

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
my $juanOpen=0;
my $mostDeepLevel="";
my $jingURL="";
my $jingLabel="";
local $lastChm='';

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

local @LastPageOfVol = (
 "T010924c",
 "T020884b",
 "T030975c",
 "T040802b",
 "T051074c",
 "T061073b",
 "T071110b",
 "T080917b",
 "T090788b",
 "T101047b",
 "T110977a",
 "T121119b",
 "T130998a",
 "T140968c",
 "T150807a",
 "T160857c",
 "T170963a",
 "T180946a",
 "T190744b",
 "T200940a",
 "T210968c",
 "T221072a",
 "T231057b",
 "T241122a",
 "T250914a",
 "T261031c",
 "T271004a",
 "T281001b",
 "T290977c",
 "T301035b",
 "T310896b"
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
	  print STDERR "\nparse $file\n";
	  $parser->parsefile($file);
  }     
} else {
  $file = $inputFile;
  print STDERR "\nparse $file\n";
  $parser->parsefile($file);
}       


my $nextChm='';
if ($vol eq "T02") { $nextChm="BenYuan.chm::/"; }
elsif ($vol eq "T04") { $nextChm="BoRuo.chm::/"; }
elsif ($vol eq "T08") { $nextChm="FaHua.chm::/"; }
elsif ($vol eq "T10") { $nextChm="BaoJi.chm::/"; }
elsif ($vol eq "T12") { $nextChm="DaJi.chm::/"; }
elsif ($vol eq "T13") { $nextChm="JingJi.chm::/"; }
elsif ($vol eq "T17") { $nextChm="MiJiao.chm::/"; }
elsif ($vol eq "T21") { $nextChm="Vinaya.chm::/"; }
elsif ($vol eq "T24") { $nextChm="JingLun.chm::/"; }
elsif ($vol eq "T29") { $nextChm="ZhonGuan.chm::/"; }
elsif ($vol eq "T31") { $nextChm="LunJi.chm::/"; }

# my $temp = substr($vol,1,2)+1;	# �U�ƥi��W�L�G�U
$vol =~ /.(\d+)/;
my $temp = $1 + 1;
if ($temp < $lastVol) {
  $temp = $nextChm . 'T' . sprintf("%2.2d",$temp) . "0001a";
  printPageBottom($temp);
} else {
  print "<hr>";
}

print VTOC "</UL><!-- end of Volume -->\n</BODY></HTML>";
        
print STDERR "M �X�O��...\n";
my @mojikyo;
if ($inputFile eq "") {
  for $file (sort(@allfiles)) { processM($file);  }
} else {
  processM($inputFile);
}       
#foreach $m (sort @mojikyo) { print HHP "images\\$m.GIF\n"; }
print HHP "\n\n[INFOTYPES]\n";  # added by Ray 1999/11/9 12:07PM
        
print STDERR "����!!\n";
        
#-------------------------------------------------------------------
# Ū ent �ɦs�J %Entities
sub openent{
	local($file) = $_[0];
	if ($file =~ /gif$/) { return; }
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
			$gaiji{$ent} = $val;
			if ($file=~/jap\.ent/) { # �p�G�O���
		 		if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # �u���ϥ� Unicode
			} elsif($ent=~/^SD/) {
				$val =~ s#<gaiji .* big5=\'(.+?)\'/>#$1#;
				#$val = "<font face=\"siddam\">$val</font>";
			} else {
				if ( $val=~/mojikyo=\'(.+?)\'/) {
					my $m=$1;  # �_�h�� M �X
					my $des = "";
					if ( $val=~/des=\'(.+?)\'/) { 
						$des=$1; 
						$ent2ZuZiShi{$ent}=$des;
					} else { $des = $m; }
					if ($des=~/\[(.*)\]/) { $des = $1; }
					$m =~ s/^M//;
					push @mojikyo,$m;
					my $href = "javascript:showpic(\"images/$m.gif\")";
					$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				} elsif ( $val=~/des=\'(.+?)\'/ ) {
					$no_nor{$ent} = $1;
				} else { $no_nor{$ent}=$ent; } # �̫�� CB �X

			    if ($val=~/nor=\'(.+?)\'/) {  # �u���ϥγq�Φr
			    	$val=$1; 
			    	$ent2nor{$ent}=$val;
			    } else { $val = $no_nor{$ent}; }
			}
		} else {
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		}    
		$Entities{$ent} = $val;
		if ($debug) { print STDERR "Entity: $ent -> $val\n"; }
  }
}       
        
        
sub default {
    my $p = shift;
    my $string = shift;
        
	my $parent = lc($p->current_element);

  # added by Ray 2000/5/11 09:13AM T10,n299,p892c09, rdg �ت������g�����X�{
  if ($parent eq "rdg") { return; }
  
	# added by Ray 1999/11/23 05:25PM
	# <note type="sk">, <note type="foot"> �����e�����
	if ($parent eq "note") {
		my $att = pop(@saveatt);
		my $noteType = $att->{"type"};
		push @saveatt, $att;
	  if ($noteType eq "sk") {  return;  }
	  if ($noteType eq "foot") {  return;  }
  }     
        
  $string =~ s/^\&(.+);$/&rep($1)/eg;
  if ($bibl == 1){
		$bib .= $string ;
		if ($debug) { print STDERR "bib=$bib\n"; getc;}
	}

	# added by Ray 2000/2/17 03:24PM
	if ($parent eq "head") { $headText .= $string; }
	if ($parent eq "title") { $title .= $string; }
	if ($parent eq "juan" or $parent eq "jhead") { $juanText .= $string; }

	if ($text =~ /(.*)<\/font>$/) {
	  my $s1 = $1;
	  if ($string =~ /^<font face=\"CBDia\">(.*)/) {
	    $text = $s1 . $1;
	  } elsif ($string =~ /^(\w)$/) {
	    $text = $s1 . $1 . "</font>";
	  } else {	$text .= $string if ($pass == 0); }
	} else { $text .= $string if ($pass == 0); }
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
	$title = "";
	$juanOpen=0;
	@elements=();
	@mulu=();
	$inLg = 0;
	@openTags=();
}
        
        
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);
        
	$elementChar="";
        
	### <body> ###
	$pass = 0 if $el eq "body";
       
	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>�@�@�@�@" ;
		#$indent = "<br>�@�@�@�@";
		$text .= "<p><span class='byline'>�@�@�@�@" ;
		     
		# marked by Ray 1999/11/30 10:26AM
		#$indent = "�@�@�@�@";
	}     
       
	### <corr>
	if ($el eq "corr") {
	  $CorrCert = lc($att{"cert"});
	  if ($CorrCert ne "" and $CorrCert ne "100") {
	    my $sic = myDecode(lc($att{"sic"}));
	    $text .= $sic;
	  } else {
		  $text .= "<span class='corr'>";
	  }
	}
       
	### <div1> ###
	if ($el eq "div1"){
	  $div1head = "";
	  $div2head = "";
	  # div1 �� type �ݩʥi�H����W�@�� div1
	  if ($att{"type"} ne "") {	$div1Type = lc($att{"type"}); }
		if (div1Type eq "xu"){
			$xu = 1;
			$num = 0;
	  } elsif ($div1Type eq "w") {  # added by Ray 2000/5/24 11:09AM
		  $text .= "<blockquote class='FuWen'>";
		  $indent = "";
		  $BlockquoteOpen ++;
		} elsif ($num == 0 && (div1Type eq "juan" || div1Type eq "jing" || div1Type eq "pin" || div1Type eq "other")) {
			$num = 1;
		}    
	}     
       
	### <div2> ###
	if ($el eq "div2"){
	  $div2head='';
	  # div2 �� type �ݩʥi�H����W�@�� div2
	  if ($att{"type"} ne "") {	$div2Type = lc($att{"type"}); }
	  if ($div2Type eq "w") {  # added by Ray 2000/5/24 11:09AM
		  $text .= "<blockquote class='FuWen'>";
		  $indent = "";
		  $BlockquoteOpen ++;
		}
	}     
       
	### <figure>
	if ($el eq "figure") {
		# 2004/8/9 04:50�U��
		#my $ent = $att{"entity"};
		#my ($x, $y) = imgsize("u:/work/htmlhelp/" . $figure{$ent});
		#$x = int($x/2);
		#$y = int($y/2);
		#$text .= '<img src="' . $figure{$ent} . "\" height=\"$y\" width=\"$x\">";
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
		  $text .=	"<p><b>�@�@" ;
		  $bibl = 1;
		  $bib = "";
		  $nid++;
		  $text .= "<A NAME=\"n$nid\"></A>";
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
       
	### <item> ###
	if ($el eq "item"){
		if ($att{"n"} ne '') { $text .= myDecode($att{'n'}); }
		$itemLang = $att{"lang"};
		if ($itemLang eq '' and $parent eq "list") { $itemLang = $listLang; }
		if ($itemLang eq 'sk-sd') { 
			my $s = "<font face=\"siddam\">";
			push @openTags, $s;
			$text .= $s;
		}
	}

	### <juan> ###
	if ($el eq "juan"){
		$xu = 0;
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
		  $juanOpen = 1;
		  if ($juanNum ne $att{"n"}) {
	      #$juanURL = "/$vol$column.htm#$lb";
	      $juanText="";
		  }
			$num = "001" if ($att{"n"} eq "");
			$num = $att{"n"};
			$juanNum = $num;
			$bibl = 1;
			$bib = "";
			$nid++;
			#$text .= "<A NAME=\"n$nid\"></A>";
		} elsif ($fun eq "close") {
		  $juanOpen = 0;
		}
		$text .= "<p class='juan'>\n";
	}     
       
	### <l> ###
	if ($el eq "l"){
		$text .= "<td>";
		$text .= "�@";
		my $rend = $att{"rend"};
		$rend =~ s/($pattern)/$utf8out{$1}/g;
		if ($rend eq "") { $rend = "�@"; }
		# �p�G�U�|�e�� (
		if ($text =~ /(.*��.*)\($/s) {
			$text = $1 . $rend . "(";
		} else { $text .= $rend; }
	}
       
	### <lb> ###
	if ($el eq "lb"){
		$lb = $att{"n"};
		if ($column eq "") { $column = substr($lb,0,5); }
		#if ($lb eq "0058a07") { $debug=1; }
		#the whole line has been cached to $text, print it now!
		printOneLine();
		     
		# modified by Ray 1999/11/21 03:26PM
		#$text = "</a>$br<a id=\"$lb\">$indent";
		$text = "$br<a name=\"$lb\" id=\"$lb\">$indent";
		if ($firstLineOfPage) { $firstLineOfPage = 0; }
		#else { $text = "</a>" . $text; }

		if ($firstLineOfSutra) {
			my $num = $sutraNum;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$num =~ s/^0//;
			$jingURL = "$vol$column.htm";
			$firstLineOfSutra = 0;
		}
		if ($inLg) { $text .= "<tr>"; }
	}
       
	### <lg> ###
	if ($el eq "lg" ){
		#$text =~ s/^(.*)(<a name=.+? id=.+?>.*)$/$1<p class='lg'>$2/;
		my $s = '<p><table border="0" cellspacing="5"><tr>';
		push @openTags, $s;
		$text .= $s;
		#$text .= "<p class='lg'>";
		$br = "";
		$inLg = 1;
	}

	if ($el eq "mulu" ) {
		my $typeOfMulu = myDecode($att{"type"});
		my $i=@mulu;
		if ($typeOfMulu eq "��") {
			my $label = myDecode($att{"label"});
			$juanURL = "/$vol$column.htm#$lb";
			my $n = $att{"n"};
			$juanNum = $n;
			if ($label eq '') { $saveJuan{$juanURL}= "��" . cNum($n); }
			else { $saveJuan{$juanURL}= $label; }
		} else {
			my $url = "/$vol$column.htm#$lb";
			my $label = myDecode($att{"label"});
			my $level = int($att{"level"});
			if ($level == 0) { 
				die "level ���ର 0, lb=$lb";
			}
			$mulu[$i][0] = $typeOfMulu;
			$mulu[$i][1] = $level;
			$mulu[$i][2] = $url;
			$mulu[$i][3] = $label;
			$mulu[$i][4] = 0;
			$mulu[$i][5] = int($juanNum);
			$mulu[$i][6] = $juanURL;
			# �p�G��F�@�U�h, �O���W�@�h���l�ؿ�
			if ($level > $mulu[$i-1][1]) { $mulu[$i-1][4] = 1; }
			if ($level > $mostDeepLevel) { $mostDeepLevel = $level; }
		}
	}
	      
	### <list> ###
	if ($el eq "list"){
		$listLang = $att{"lang"};
	}

	### <note> ###
	if ($el eq "note" && lc($att{"type"}) eq "inline"){
	  $close='';
	  if ($pass==0) {
		  $text .= "<font size=-2>(";
		  $close = ")</font>";
		}
		push @close, $close;
	}

	### <p> ###
	if ($el eq "p" and $pass==0){
		$ptype = lc($att{"type"});
		if ($ptype eq "w" or $ptype eq "winline") {
			$text .= "<blockquote class='FuWen'>";
			$indent = "";
			$BlockquoteOpen ++;
		} else {
			$text .= "<p>";
		}   
		if ($att{"lang"} eq "sk-sd") { 
			my $s = "<font face=\"siddam\">"; 
			push @openTags, $s;
			$text .= $s;
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
		     
		printOneLine();
		if ($chm eq $oldChm) { $temp = ''; }
		else { 
		  $temp = "$chm.chm::/"; 
		  $oldChm = $chm;
		}
		printPageBottom ( $temp . $vol . $att{"n"} );

		$preColumn = $column;
		$column = $att{"n"};
		  
		if ($newSutra) { openOF(); $newSutra=0; }
      
		print "<!---New Topic--->\n";
		print "<OBJECT type='application/x-oleobject' classid='clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e'>\n";
		print "  <param name='New HTML file' value='$vol$column.htm'>\n";
		
		#print "  <param name='New HTML title' value='No. $i'>\n";
		print "  <param name='New HTML title' value='$sutraNum $sutraName $column'>\n";
		    
		print "</OBJECT>\n";
		print "<OBJECT type='application/x-oleobject' classid='clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e'>\n";
		print "  <param name='ALink Name' value='$vol-$column'>\n";
		print "  <param name='ALink Name' value='$column'>\n";
		print "  <param name='ALink Name' value='$vol.$sutraNum.$column'>\n";
		print "</OBJECT>\n";
		print "<font face='Arial'><h2>$mtit</font> ";
		$juanNum =~ s/^0{1,2}(\d{1,2})/$1/;
		if ($juanNum ne "") { print "<font face='Arial'>(��$juanNum)</font>" };
		if ($div1head ne "") { 
			if ($div1head =~ /^#\d\d#(.*)/) { $div1head = $1; }
			if ($div1head =~ /(.*��)��$/) { $div1head = $1; }
		
			# "�@" = \xa4\x40
			if ($div1head =~ /(.*�w)��\xa4\x40$/) { $div1head = $1; }
			
			if ($div1head =~ /^�].+�^(��.+��)$/) { $div1head = $1; }
			
			# "�]�@�^�Ĥ@��" -> "�Ĥ@��"
			# \xa1\x5d = "�]" ,  \xa1\x5e = "�^"
			if ($div1head =~ /^\xa1\x5d.+\xa1\x5e(��.+��)$/) { $div1head = $1; }
			print " $div1head"; 
		}
   
		# added by Ray 2000/3/1 07:40PM
		if ($div2head ne "") { 
			print " $div2head"; 
		}
		print " <font face='Arial'>$vol, p$column</h2></font><hr>\n";
   
		# �B�z������� added by Ray 2000/5/24 08:37AM
		my $s = join('',@lines);
		my $i = $BlockquoteOpen;
		while ($s =~ m#</blockquote#) {
			if ($s =~ /<blockquote/) { $s =~ s/<blockquote//; }
			else { $i++; }
			$s =~ s#</blockquote##;
		}
		while ($i) { 
			$i --;
			if ($s =~ /<blockquote/) {
				$s =~ s/<blockquote//;
				next;
			}
			print "<blockquote class='FuWen'>"; 
		}
   
		print "<span class='old'>\n";
		#if ($inLg) { print '<table border="0" cellspacing="5"><tr>';}
		print shift @tagBeforeLine;
		@tagBeforeLine='';
		my $i;
		for ($i=1; $i<=2; $i++) {
			my $s = shift @lines;
			$s =~ s#<td>(.*?)</td>#<td><span class='old'>$1</span></td>#g;
			print $s;
		}
		print "</span>";
		$bottomNeeded = 1;
	}

       
	### <rdg> ###
	$pass++ if $el eq "rdg";
       
	### <t> ###
	if ($el eq "t") {
		if ($att{"lang"} eq "sk-sd") { $text .= "<font face=\"siddam\">"; }
	}

	### <teiHeader> ###
	$head = 1 if $el eq "teiHeader";  #We are in the header now!
       
	### <term> ###
	if ($el eq "term") {
		if ($att{"lang"} eq "sk-sd") { $text .= "<font face=\"siddam\">"; }
	}
	
	#end startchar
}       
        
sub rep{
	local($x) = $_[0];
	if ($debug) { print STDERR "rep($x)="; }
	# modified by Ray 1999/10/13 07:16PM
	#return $Entities{$x} if defined($Entities{$x});
	local $str='';
	#if ($no_nor) {
	  if (defined($no_nor{$x})) { $str = $no_nor{$x}; }
	#} else {
	#  if (defined($Entities{$x})) { $str = $Entities{$x}; }
	#}

	if ($str =~ /^\[(.*)\]$/) {
	  my $exp = $1;
	  if (defined($dia{$exp})) {
	    $str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
	    if ($debug) { print STDERR "$str\n"; }
	    return $str;
	  }
	}   
	  if ($debug) { print STDERR "$str\n"; }
	  return $str;
	die "Unknkown entity $x!!\n";
  if ($debug) { print STDERR "$x\n"; }
	return $x;
}       

        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
       
	### </bibl> ###
	if ($el eq "bibl"){ endBibl(); }
	
	# </body>
	if ($el eq "body") {
	  printOneLine();
	}
	
	### </byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:34AM
		#$text .= "</span>" ;
		$text .= "</span><br>" ;
		$indent = "";
	}     
	
	## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { $text .= "</span>"; }
	}     
	
	### </div> ###
	if ($el =~ /div/i){
		$xu = 0;
		# added by Ray 2000/5/24 11:11AM
		my $s='';
		if ($el eq "div1") {
		  $s = $div1Type;
		} elsif ($el eq "div2") {
		  $s = $div2Type;
		}
		if ($s eq "w" and $pass==0) { 
		  $text .= "</blockquote>"; 
		  $BlockquoteOpen --;
		}
	}     
	
	# </edition>
	if ($el eq "edition") {
	  $version =~ /\b(\d+\.\d+)\b/;
	  $version = $1;
	}     
       
	$head = 0 if $el eq "teiHeader";  #reset HEADER flag
	$pass-- if $el eq "rdg";
	$pass-- if $el eq "gloss";
	      
	### </head> ###
	if ($el eq "head" ) { endHead(); }
	
	### </item> ###
	if ($el eq "item") {
		if ($itemLang eq "sk-sd") { 
			$text .= "</font>"; 
			pop @openTags;
		}
	}

	### </juan> ###
	if ($el eq "juan" ){
		$bibl = 0;
		$bib =~ s/\[[0-9�][0-9�]\]//g;
		$bib =~ s/\[[0-9]{2,3}\]//g;
		#$bib =~ s/#[0-9][0-9]#//g;
		$bib =~ s/#[0-9]{2,3}#//g;
		$bib = "";
		$text .= "</p>\n";
		     
		if (lc($att->{"fun"}) eq "open" and $div1Type ne "w") {
     my $num = $juanNum;
     $num =~ s/^0//;
     $num =~ s/^0//;
     $juanText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
     $juanText =~ s/\[��\]//g;
		} elsif (lc($att->{"fun"}) eq "close" and $div1Type ne "w") {
     $juanText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
     $juanText =~ s/\[��\]//g;
     my $i = cNum($juanNum);
		  #print FTOC "<TD><A HREF=\"$chm.chm::$juanURL\">����$i</A>\n";
		  #print FTOC "<TR>\n";
		}    
	}     
       

	### </l> ###
	if ($el eq "l") {
		#$text .= "�@" if $el eq "l";
		$text .= '</td>';
	}
	
	### </lg> ###
	if ($el eq "lg" ){
		#$text .= "</table></p>";
		$text .= "</table>";
		$br = "";
		$inLg=0;
		pop @openTags;
	}

	### </list> ###
	if ($el eq "list" ){
		#if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}

       
	## </note> ###
	if ($el eq "note"){
	  $close = pop @close;
		if ($close ne "") {
		  if ($text =~ /(.*)<\/font>$/) {
		    $text = $1 . $close . "</font>";
		  } else { $text .= $close }
		}
		$close = "";
	}     
	      
	## </p> ###
	if ($el eq "p"){
		$indent = "";
		if ($head == 1) {
			$bib =~ s/^\t+//;
			#$ly{$lang} = $bib;
			$source =~ s/^\t+//;
			$ly{$lang} = $source;
			$flagSource = 0;
			$source="";
		}    
		if ($att->{"lang"} eq "sk-sd") { 
			$text .= "</font>"; 
			pop @openTags;
		}
		if (lc($att->{"type"}) eq "w" and $pass==0) { 
			$text .= "</blockquote>"; 
			$BlockquoteOpen --;
		}
	}     
       
	### </t> ###
	if ($el eq "t") {
		if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}

	### </term> ###
	if ($el eq "term") {
		if ($att->{"lang"} eq "sk-sd") { $text .= "</font>"; }
	}
	
	### </title> ###
	if ($el eq "title"){
		#$bib =~ s/^\t+//;
		#$title = $bib;
		if ($debug) { print STDERR "title=$title\n"; getc; }
	}     
       
	if ($el eq "teiHeader"){
#	&head;
	}     
	$lang = "" if ($el eq "p");
       
  ## </TEI.2> ###
	if ($el eq "TEI.2"){
		$text = myReplace($text);
       
		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		     
		print OF $text;
		$text = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>��</a>" if ($prevof ne "");
		#print "</html>\n";
		#close (OF);
		$vl = "";
		$num = 0;
		&endSutra;
		     
		# marked by Ray 1999/11/9 12:07PM
		#print HHP "\n\n[INFOTYPES]\n";
		#close HHP;
	}     
	      
	      
	$bib = "";
#	print STDERR "$pass\n";
  $no_nor=0;
}       
        
sub endBibl {
	$bibl = 0;
	if ($bib =~ /Vol\.\s+$ed?([0-9]+).*?No\.\s*([A-Za-z]?[0-9]+)([A-Za-z])?/){
		$prevof = "";
		$sutraNum = $2;
		$oldChm = $chm;
		#$chm = getchm($sutraNum);
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
		#$text =~ s/\[[0-9�][0-9�]\]//g;
		#$text =~ s/#[0-9][0-9]#//g;
		$text = myReplace($text);
		print OF $text;
		$text = "";
		$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
		$od = sprintf("t%2.2d", $1);
		mkdir($outDir . "\\htmlhelp\\$od", MODE);
#		$c = "n" if ($c eq "_");
#		$oof = $of;
		#base name for file
       
		$xu = 0;
		#$fileopen = 0;
		$num = 0;
		#$bof = $ourDir . sprintf("\\htmlhelp\\$od\\%4.4d$c", $2, $3);
		$bof = $outDir . "\\";
		$bof =~ tr/A-Z/a-z/;
		$fhead = $outDir . sprintf("\\htmlhelp\\$od\\%4.4dh", $2, $3);
		$fhead =~ tr/A-Z/a-z/;
			   
		my $s='';
		# 5,6,7 �U���O 220�g
		if ($vol eq "T06" or $vol eq "T07") {
			$s = ">>$outDir/T05n0220.htm";
		} else {
			$s = ">$outDir/${vol}" . "N" . $sutraNum . ".htm";
		}
		open (FTOC, $s);
		print STDERR "-> $s\n";
		if ($debug) { print "title=[$title]\n"; }
		$mtit = $title;
		$mtit =~ s/^.*? (No\. .*)$/$1/;
	    $mtit =~ s/(.*)No\. 0(.*)/$1No\. $2/;
	    $mtit =~ s/(.*)No\. 0(.*)/$1No\. $2/;
	    print STDERR "1029 mtit=[$mtit]\n";
		$sutraName = $mtit;
		$sutraName =~ s/No\. \d*\w* //;
		$jingLabel = "No. $sutraNum " . filterAnchor($sutraName);
       
		printTocHead();
		$firstLineOfSutra = 1;
		$firstLineOfPage = 1;
     
		# added by Ray 1999/12/15 10:50AM
		if ($vol eq "T06") { $juanNum = 201; }
		elsif ($vol eq "T07") { $juanNum = 401; }
		else { $juanNum = 1; }
	}    
	$bib =~ s/^\t+//;
	$ebib = $bib;
	&changeSutra;
	#openOF();
	$newSutra=1;
	#&changefile;
}

sub endHead {
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
			} elsif ($parent eq "corr") {
				$i--;
				$parent = $elements[$i];
			} 
		} # end of while
       
		# </head> �b <div1> ��
		if ($parent eq "div1") {
			$headText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
			$headText =~ s/\[��\]//g;
			$div1head = $headText;
			if ($debug) { print STDERR "div1Type=[$div1Type]\n"; }
		}

		# </div2>
		if ($parent eq "div2") {
			$headText =~ s/\[\d\d\]//g;  # �h���հɲŸ�
			$headText =~ s/\[��\]//g;
			$div2head = $headText;
		}

		$text .= "</b>";
		$bibl = 0;
		$bib =~ s/\n//g;
		$bib =~ s/\[[0-9�][0-9�]\]//g;
		$bib =~ s/\[[0-9]{2,3}\]//g;
		#$bib =~ s/#[0-9][0-9]#//g;
		$bib =~ s/#[0-9]{2,3}#//g;
		$bib = "";
		$indent = "" ;
}
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);

	# <app>�ت���r�u��X�{�b<lem>��<rdg>�� added by Ray
  if ($parent eq "app") { return; }

  # <note type="sk"> �����e�����
  if ($parent eq "note") {
	  my $att = pop(@saveatt);
	  my $noteType = $att->{"type"};
    push @saveatt, $att;
	  if ($noteType eq "sk") {  return;  }
	  if ($noteType eq "foot") {  return;  }
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
	  if ($text =~ /(.*)<\/font>$/) {
	    my $s1 = $1;
	    if ($char =~ /^([\w\s]+)(.*)$/) { $text = $s1 . $1 . "</font>" . $2; }
	    else { $text .= $char; }
	  } else { $text .= $char; }
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
	return 1;
}       
        
        
        
        
        
#-----------------------------------------------------------------------
sub shead{
	print $short;
}       
        
# --------------------------------------------------------------------------
# ������s���@�g�ɩI�s
sub changeSutra {
  print VTOC "  <LI><OBJECT type=\"text/sitemap\">\n";
  print VTOC "        <param name=\"Name\" value=\"$jingLabel\">\n";
  print VTOC "        <param name=\"Local\" value=\"$chm.chm::/${vol}N${sutraNum}.htm\">\n";
  print VTOC "        <param name=\"ImageNumber\" value=\"1\">\n";
  print VTOC "      </OBJECT>\n";
  print HHP "${vol}N${sutraNum}.htm\n";
  %saveXu=();
  %saveJuan=();
  %savePin=();
  %savePin2=();
  %saveHui=();
  %saveFen=();
  %saveOther=();
  @lines=();
  @tagBeforeLine=();
  $div1head="";
  $div2head="";
  $div1Type="";
  $BlockquoteOpen = 0;
  
  # marked by Ray 2000/3/7 09:09PM
  #$column="";
  #$preColumn="";
}       

#-----------------------------------------------------------------------
# created by Ray 2000/3/15 06:14PM
sub printJuan {
  my $a=shift;
  my $newCell = 0;
  my $deepest;
  
  $juanNum  = $mulu[$a][5];
  
  if ($juanOld eq "" or $juanNum ne $juanOld) {
      $label = "��" . cNum($juanNum) . "��";
      $url = $mulu[$a][6];
      #print FTOC "�]<A HREF=\"$chm.chm::$url\">$label</A>�^\n";
      print FTOC "�]$label�^\n";
      $juanOld = $juanNum;
  }
}
        
#-----------------------------------------------------------------------
# �@�g�����ɩI�s
sub endSutra {
  my $i;
  my $key,$value;
  my $type, $level, $label, $url, $child;
  my $openUL=0;
  my $juanPrinted=0;

  #for $array_ref (@mulu) {
  #  print STDERR "\t [@$array_ref],\n";
  #}

  my $oldFile = select();
  select FTOC;
  $i = int($mostDeepLevel) + 1;
  if ($i > 4) { $i = 4; }
  if ($vol ne "T06" and $vol ne "T07") {
	  print "<A HREF=\"$chm.chm::/$jingURL\">$jingLabel</A>\n";
	}
	$lastLevel = 0;
  $juanOld = "";
  my $len = @mulu;
  for ($i=0; $i<$len; $i++) {
      $level = $mulu[$i][1];
      $url   = $mulu[$i][2];
      $label = $mulu[$i][3];
      print "<BR>";
      print "�@�@" x $level;
      print "<A HREF=\"$chm.chm::$url\">$label</A>\n";
      printJuan($i);
      $lastLevel = $level;
  }
  if ($len>0) { printJuan($len-1); }

  select VTOC;
  print "	<UL>\n";

  ### �@�g��� ###
  my $i = keys(%saveJuan);
  if ($i == 1) {
      my @keys = keys(%saveJuan);
      $value=filterAnchor($sutraName);
      $key = $keys[0];
      print "    <LI><OBJECT type=\"text/sitemap\">\n";
		  print "          <param name=\"Name\" value=\"$value\">\n";
		  print "          <param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "        </OBJECT>\n";
  }     
  
  my $i = @mulu;
  if ($i > 0) {
    print "    <LI><OBJECT type=\"text/sitemap\">\n";
    print "          <param name=\"Name\" value=\"�ؿ�\">\n";
    print "          <param name=\"ImageNumber\" value=\"1\">\n";
    print "        </OBJECT>\n";
    print "    <UL>\n";
    
    for ($j=0; $j<$i; $j++) {
      $level = $mulu[$j][1];
      $url   = $mulu[$j][2];
      $label = $mulu[$j][3];
      $child = $mulu[$j][4];
	   $label =~ s#<a href='.*?'>(.*?)</a>#$1#g;  # added by Ray 2000/6/2 11:20AM
      if ($j>0 and $level < $mulu[$j-1][1]) {
        while ($openUL >= $level ) {
          print "  " x ($openUL+2) . "</UL><!-- end of Level $openUL -->\n";
          $openUL --;
        }
      }
      print "  " x ($level+2) . "<LI><OBJECT type=\"text/sitemap\">\n";
		  print "  " x ($level+2) . "      <param name=\"Name\" value=\"$label\">\n";
		  print "  " x ($level+2) . "      <param name=\"Local\" value=\"$chm.chm::$url\">\n";
		  if ($child) {
      print "  " x ($level+2) . "      <param name=\"ImageNumber\" value=\"1\">\n";
		  }
		    print "  " x ($level+2) . "</OBJECT>\n";
		  if ($child) {
        print "  " x ($level+2) . "<UL>\n";
        $openUL ++;
		  }
    }
    while ($openUL > 0) { 
        print "  " x ($openUL+2) . "</UL><!-- end of Level $openUL -->\n";
        $openUL --;
      }
    print "    </UL><!-- end of Mulu -->\n";
  }
        
  ### �@�g�h�� ###
  my $i = keys(%saveJuan);
  if ($i>1) {
    print "    <LI><OBJECT type=\"text/sitemap\">\n";
    print "          <param name=\"Name\" value=\"��\">\n";
    print "          <param name=\"ImageNumber\" value=\"1\">\n";
    print "        </OBJECT>\n";
    print "    <UL>\n";
        
    for $key (sort(keys(%saveJuan))) {
      $value = $saveJuan{$key};
      $value=filterAnchor($value);
      print "      <LI><OBJECT type=\"text/sitemap\">\n";
		  print "            <param name=\"Name\" value=\"$value\">\n";
		  print "            <param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "          </OBJECT>\n";
		}    
    print "    </UL><!-- end of Juan -->\n";
	}
        
  print "  </UL><!-- end of Jing -->\n";
  select $oldFile;
  closeToc();
}       
        
#-----------------------------------------------------------------------
sub changefile{
			$text =~ s/\n//;
			$text =~ s/\x0d$//;
			#$of = sprintf("$bof%3.3d.htm", $num);
			$of = $bof . $vol . ".htm";
			$mof = $of;
			$mof =~ s/.*\\//;
			if ($oldof ne $mof){
				#$xtoc = "${bof}toc.htm";
				$xtoc = "${bof}${vol}toc.hhc";
				$xtoc =~ s/.*\\//;
				$xtoc =~ tr/A-Z/a-z/;
				$ytoc = $bof;
				$ytoc =~ s/.*\\//;
				$ytoc =~ s/_//;
				print "</a><hr><p align='right'>";
				print "<a href=\"${prevof}#start\" style='text-decoration:none'>��</a>" if ($prevof ne "");
				print "<a href=\"${mof}#start\" style='text-decoration:none'>��</a>";
				print "</p></html>\n";
				close (OF);
				$fh = sprintf("$fhead%3.3d.htm", $num);
				#open (OF, ">$of");
				$fileopen = 1;
				print STDERR " --> $of\n";
				#select(OF);
				if ($num == 0 || ($xu == 0 && $num == 1)){
					#&head;
					#print VTOC "<LI><A ID=\"$ytoc\" NAME=\"$ytoc\" HREF=\"$vol/$xtoc\" target=\"ftoc\">$title</A></LI>\n";
				} else {
					#&head;
				}
				#open(FHED, ">$fh");
				#print FHED $fhed;
       
				$text = myReplace($text);
				print OF "\n$text";
				$text = "";
				$prevof = $oldof;
				$oldof = $mof;
				$oldbof = $bof;
			}  
}       
        
#------------------------------------------------------------------------
# �@�g�ؿ�
sub printTocHead {
  my $cvol = $vol;
  $cvol =~ s/T//;
  $cvol = cNum($cvol);
        
  my $num = $sutraNum;
  $num =~ s/^0//;
  $num =~ s/^0//;
  $num =~ s/^0//;
  
  if ($vol eq "T06" or $vol eq "T07") { return; }

print FTOC << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>  
<HEAD>  
<script LANGUAGE="JAVASCRIPT" SRC="search.js"></script>
<TITLE>${sutraName}--�ؿ�</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta name="GENERATOR" content="PERL HTMLHelp.bat">
</HEAD><BODY>
<H2><IMG align="center" SRC="logo1.jpg"> �q�l�j�øg</H2>
<P>     
       
<HR>    
<H3>�ؿ�  <font face="Times New Roman">Contents</font></H3>
XXX
}       
        
#------------------------------------------------------------------------
# �����@�g�ؿ�
sub closeToc {
  my $nvol = $vol;
  $nvol =~ s/T//;
  $cvol = cNum($nvol);
  $nvol =~ s/^0//;
  
  if ($vol eq "T05" or $vol eq "T06") { return; }
  
print FTOC << "XXX";
<HR><UL>
<LI>�j���s��j�øg��${cvol}�U $mtit
<LI>V${version} (Big5) HTMLHelp�� Build $buildNumber�A��������G$cfg{"CDATE"}
<LI>����Ʈw�Ѥ��عq�l����|�]CBETA�^�̤j���s��j�øg�ҽs��
<LI>����ƨӷ��G$ly{"zh"}
<LI>����Ʈw�i�ۥѧK�O�y�q�A�ԲӤ��e�аѦ�<A HREF="cbintr.htm">�i���عq�l����|��Ʈw�򥻤��Сj</A>
</UL>   
<UL>    
<LI> Taisho Tripitaka Vol. $nvol, $mtit</A>
<LI> V${version} (Big5) HTMLHelp Build $buildNumber, Release Date: $cfg{"EDATE"}
<LI> Distributor: Chinese Buddhist Electronic Texts Association (CBETA)
<LI> Source material obtained from: $ly{"en"}
<LI> Distributed free of charge. For details, please refer to <A HREF="cbintr_e.htm">The Brief Introduction of CBETA DATABASE</A>
</UL>   
        
XXX
}       
        
#-----------------------------------------------------------------------
### ���U�ؿ� ###
sub openVTOC {
  my $s = ">" . $outDir . "\\${vol}Toc.hhc";
  open (VTOC, $s);
  print STDERR "open $s\n";
        
print VTOC << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>  
<HEAD>  
        
<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- Sitemap 1.0 -->
</HEAD><BODY>
<OBJECT type="text/site properties">
	<param name="ImageType" value="Folder">
</OBJECT>
<UL>    
XXX
}       
        
        
#-----------------------------------------------------------------------
### ���U�g�� ###
sub openOF {
	my $of1 = getof();
	if ($of1 eq $saveof) { return; }
	if ($saveof ne "") { close OF; }
	$saveof = $of1;
	open (OF, ">" . $outDir . "\\$of1");
	print STDERR "\n-> " . $outDir . "\\$of1\n";
	select(OF);
print << "XXX";
<html>  
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<style>\@import url(cbeta.css);</style>
<link disabled rel="stylesheet" href="cbeta.css">
<script LANGUAGE="JAVASCRIPT" SRC="search.js">
</script>
<TITLE>CBETA �q�l���</TITLE>
</head> 
XXX
  # �C�L�e���äW�U�������ʶs
  print "<BODY id='$vol' onbeforeprint='hide()' onafterprint='show()'>\n";
  $bottomNeeded = 0;
}       
        
#-----------------------------------------------------------------------
### HTML Help Project ###
sub openHHP {
  my $oldFile = select();
  my $num = substr($vol,1,2);
  $num = cNum($num);  # cNum() is in sub.pl
  open (HHP, ">" . $outDir . "\\${vol}.hhp");
  select(HHP);
print << "XXX";
[OPTIONS]
Compatibility=1.1 or later
Compiled file=$chm.chm
Contents file=${vol}Toc.hhc
Default Font=�s�ө���,10,136
Default Window=win1
Default topic=default.htm
Display compile progress=Yes
Error log file=$vol.log
Full-text search=Yes
Language=0x404 ���� (�x�W)
Title=$vol
        
[WINDOWS]
win1="$vol","${vol}Toc.hhc",,"default.htm",,,,,,0x21420,,0x64,,,,,,,,0

        
[FILES] 
default.htm
$vol.htm
XXX
  select ($oldFile);
}       

#-----------------------------------------------------------------------
sub getof {
  my $num = $sutraNum;

  # �p�G�O�Y�@�����Ĥ@�g, �W�@���b�t�@�� CHM ��
  if    ($num ==  152) { $lastChm = 'AHan.chm::/'; }
  elsif ($num ==  220) { 
    if ($vol eq "T05") { $lastChm = 'BenYuan.chm::/'; }
  } elsif ($num ==  262) { $lastChm = 'BoRuo.chm::/'; }
  elsif ($num ==  278) { $lastChm = 'FaHua.chm::/'; }
  elsif ($num ==  310) { $lastChm = 'HuaYan.chm::/'; }
  elsif ($num ==  374) { $lastChm = 'BaoJi.chm::/'; }
  elsif ($num ==  397) { $lastChm = 'NiePan.chm::/'; }
  elsif ($num ==  425) { $lastChm = 'DaJi.chm::/'; }
  elsif ($num ==  848) { $lastChm = 'JingJi.chm::/'; }
  elsif ($num == 1421) { $lastChm = 'MiJiao.chm::/'; }
  elsif ($num == 1505) { $lastChm = 'Vinaya.chm::/'; }
  elsif ($num == 1536) { $lastChm = 'JingLun.chm::/'; }
  elsif ($num == 1564) { $lastChm = 'PiTan.chm::/'; }
  elsif ($num == 1579) { $lastChm = 'ZhonGuan.chm::/'; }
  elsif ($num == 1628) { $lastChm = 'Yogacara.chm::/'; }

  my $str = "T09,T12,T26,T30";
  if ($str !~ /$vol/) { return $vol . ".htm"; }

  if ($num <   278) { return "T09-1.htm"; }
  if ($num <   279) { return "T09-2.htm"; }
  if ($num <   374) { return "T12-1.htm"; }
  if ($num <   397) { return "T12-2.htm"; }
  if ($num <  1536) { return "T26-1.htm"; }
  if ($num <  1545) { return "T26-2.htm"; }
  if ($num <  1579) { return "T30-1.htm"; }
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
sub processM {
  $file = shift;
  my $m;
  open IN1, $file;
  while (<IN1>) {
    while (/&M(\d{6});/) {
      $m = $1;
      if (!grep /$m/,@mojikyo) { push @mojikyo,$m; }
      s/&M\d{6};//;
    }   
  }     
  close IN1;
}       
        
#-----------------------------------------------------------------------
# Created by Ray 1999/11/30 08:38AM
#-----------------------------------------------------------------------
sub printOneLine {
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	if ($text eq "") { return; }

	$text =~ s/\xa1\x40$//;
	$text =~ s/\xa1\x40\)$/)/;
	$text = myReplace($text);

	if ($text =~ /<a name=.+ id=.+>/) { $text .= "</a>"; }
	print "$text";
	if (@lines > 1) { shift @lines; }
	if (@tagBeforeLine > 2) { shift @tagBeforeLine; }
	my $s = join('',@openTags);
	push @tagBeforeLine,$s;
	push @lines, $text;
	$text = "";
}       

sub myDecode {
  my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	#$s =~ s/M010527/��/g;
	$s =~ s/��(CB\d{5}|CI\d{4}|M\d{6})�F/&rep($1)/eg;
	$s =~ s/(M\d{6})/&rep($1)/eg;
	$s =~ s/(M\d\d\d\d)/&rep($1)/eg;
	$s =~ s/(CB\d{5})/&rep($1)/eg;
	return $s;
}

# created by Ray 2000/2/18 09:08AM
# �L�o�ʦr���s���аO
sub filterAnchor {
  my $s = shift;
  $s =~ s/<a.*?>(.*?)<\/a>/$1/g;
  return $s;
}

# created by Ray 2000/3/1 10:20AM
sub myReplace {
  my $s = shift;
	if ($debug) { print STDERR "{$s}\n"; }
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	$s =~ s/\[[0-9�][0-9�]\]//g;
	$s =~ s/\[[0-9]{2,3}\]//g;
	#$s =~ s/#[0-9][0-9]#//g;
	$s =~ s/#[0-9]{2,3}#//g;
	
  # ��W�@�ӡ�, ������
  while ( $s =~ /^(($big5zi)*?)(��)/) { 
    $s =~ s/^(($big5zi)*?)(��)/$1��/;
  }

  # ��ӥH�W����, �����e���f
  while ($s =~ /^(($big5zi)*?)��((��)|( )|(�@))*��/) {
    $s =~ s/^(($big5zi)*?)��((��)|( )|(�@))*��/$1�i���j/;
  }
	
	if ($debug) { print STDERR "{$s}\n"; getc;}
	return $s;
}

sub printPageBottom {
	if (not $bottomNeeded) { return; }
	
	my $nextPage = shift;
	if ($inLg) { print "</table>"; }
	print "<hr><br><br>";
	print "\n<DIV id=waterMark style=\"position:absolute;right:0;bottom:0\">\n";
	print "<table align=\"right\"><tr><td>\n";
	if ($preColumn eq "") {
		if ($vol ne 'T01') {
			# �s��W�@�U���̫�@��
			my $href = $LastPageOfVol[substr($vol,1,2)-2];
			print "<a href='$lastChm$href.htm'><img src='up.gif' border=0></a>\n";
			$lastChm='';
		}
	} else {
		print "<a href='$lastChm$vol${preColumn}.htm'><img src='up.gif' border=0></a>\n";
		$lastChm = '';
	}

	if ($column ne "") {
		print "<a href='$nextPage.htm'><img src='down.gif' border=0></a>\n";
	}  
	print "</td></tr></table>\n";
	print "</DIV>\n";
	print "<SCRIPT language=JavaScript1.2 src=\"water.js\"></SCRIPT>\n";
}


__END__ 
:endofperl
