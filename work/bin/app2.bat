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


# copy and modified from app.bat by Ray 1999.10.6
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
mkdir($cfg{"OUTDIR"} . "\\APP1", MODE);

opendir (INDIR, $cfg{"DIR"} . "\\$vol");

if ($infile eq ""){
	@allfiles = grep(/\.xml$/i, readdir(INDIR));
} else {
	@allfiles = grep(/$infile$/i, readdir(INDIR));
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
my $debug=0;
my @saveatt=();
my @saveElement=();
my @saveIndent=();

my $pass;          # �b<body>�جO0,
                   # �b<rdg>��<gloss>��<head type="added">�� $pass �|�֥[
my $inp;           # �b<p>�جO1, �b<p>�~�O0
my $inTrailer;
my $inHead;
my $inByline;
my $inJhead;
my $version;
my $pRend;
my $div2Type="";
my $CorrCert;
my $heads;
my $div1Type="";
$date;
$ai=1;

sub openent{
	local($file) = $_[0];
	#local($k) = "." . $cfg{"CHAR"};
	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
	#$file =~ s#/#\\#g;
	#$file =~ s/\.\./$cfg{"DIR"}/;
	print STDERR "open entity $file\n";
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
		  if ($val=~/nor=\'(.+?)\'/) { $val=$1; }  # �u���γq�Φr
		  elsif ($val=~/des=\'(.+?)\'/) { $val=$1; } # �_�h�βզr��
		} else {
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		}
		$Entities{$ent} = $val;
	}
}


sub default {
    my $p = shift;
    my $string = shift;

	# added by Ray 1999/11/23 05:25PM
	my $parent = lc($p->current_element);
  if ($parent eq "note") {
	  my $att = pop(@saveatt);
	  my $noteType = $att->{"type"};
    push @saveatt, $att;
	  if ($noteType eq "sk") {  return;  }
  }

    $string =~ s/^\&(.+);$/&rep($1)/eg;
	$bib .= $string if ($bibl == 1);

	# modified by Ray 2000/2/14 09:58AM
	#$text .= $string if ($pass == 0  && $inp != 1);
	$text .= $string if ($pass == 0);
}

sub init_handler
{
	$pass = 1;
	$bibl = 0;
	$fileopen = 0;
	$num = 0;
	$inxu = 0;
	$close = "";
	$indent="";
	$indentOfThisLine="";
	$indentOfLastLine="";
	$date="";
	$heads=0;
	$inTrailer=0;
	$inHead=0;
	$inByline=0;
	$inJhead=0;
}



sub start_handler 
{
	my $p = shift;
	$el = shift;
	my (%att) = @_;
	push @saveElement, $el;
	push @saveatt , { %att };
	push @saveIndent, $indent;

	if ($debug) { print "[$el]"; }

	$pass++ if $el eq "rdg";
	$pass++ if $el eq "gloss";
	if ($el eq "head" && lc($att{"type"}) eq "added"){
		$pass++;
		$added = 1;
	}
	$head = 1 if $el eq "teiheader";  #We are in the header now!
	$pass = 0 if $el eq "body";

	# <jhead>
	if ($el eq "jhead"){
	  $inJhead=1;
	}

	# <p>
	if ($el eq "p"){
		$inp = 1 if (lc($att{"rend"}) ne "nopunc");
	}

	if ($head == 1){
		$bibl = 1 if ($el =~ /^bibl|title|p$/);
	}
	if ($head == 1 && lc($att{"type"}) eq "ly"){   # �P�_�y��
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}
	}

	### <corr>
	if ($el eq "corr") {
	  $CorrCert = lc($att{"cert"});
	  if ($CorrCert ne "" and $CorrCert ne "100") {
	    my $sic = myDecode(lc($att{"sic"}));
	    
	    # modified by Ray 2000/2/14 09:59AM
	    #$text .= $sic if ($pass == 0 && $inp != 1);
	    $text .= $sic if ($pass == 0);
	  }
	}

	# <note>
	if ($el eq "note" && lc($att{"type"}) eq "inline"){
			# modified by Ray 2000/2/14 10:00AM
			#$text .= "(" if ($pass == 0  && $inp != 1);
			$text .= "(" if ($pass == 0);
			$close = ")";
	}

	# <p>
	if ($el eq "p") {
	  $pRend = "";
	  my $type = $att{"type"};
	  if (lc($att{"type"}) eq "inline") {
		  # modified by Ray 2000/2/14 10:00AM
		  #$text .= "�C" if ($pass == 0  && $inp != 1);
		  # <p type="inline"> �Y�b�歺�h���[�y�I
		  if ($text !~ /(��|�@|�C)$/ and $pass == 0) { $text .= "�C"; }
      #$text .= "�C";
    } elsif (lc($att{"type"}) eq "winline") {
    	# modified by Ray 2000/2/14 10:01AM
		  #$text .= "�C" if ($pass == 0  && $inp != 1);
		  $text .= "�C" if ($pass == 0);
		  
		  $pRend = $att{"rend"};
      $pRend =~ s/($utf8)/$utf8out{$1}/g;
		  if ($pRend eq "") { $pRend = "�@"; }
		  $indent .= $pRend;
		} elsif ($type eq "dharani") {
		  if ($text !~ /(��|�@|�C)$/)
		    { $text .= "�@"; }
    } elsif (lc($att{"type"}) eq "w") {
		  $pRend = $att{"rend"};
      $pRend =~ s/($utf8)/$utf8out{$1}/g;
		  if ($pRend eq "") { $pRend = "�@"; }
		  if ($text =~ /��$/) { $indentOfThisLine .= $pRend; }
		  else { $text .= $pRend; }
		  $indent .= $pRend;
    }
	}
	
	# <l>
	if ($el eq "l") {
	  my $rend = $att{"rend"};
	  $rend =~ s/($utf8)/$utf8out{$1}/g;
	  if ($rend eq "") { $text .= "�@"; }
	  else { $text .= $rend; }
	}
	
	# <byline>
	if ($el eq "byline"){
	  # �p�G�٨S�X�{�L��L<byline>
	  if ($indentOfThisLine !~/�@�@�@�@/) {
		  $indentOfThisLine.="�@�@�@�@";
		  $indent = "�@�@�@�@";
		} elsif ($text !~ /��$/) {
		  $text .= "�@";
		}
		$inByline=1;
	}

	# <head>
	if ($el eq "head") {
		if ($heads == 0) {
	    my $parent = lc($p->current_element);
  	  my $addSpace = 1;
  	  if (lc($att{"type"}) eq "added") { $addSpace = 0; }
  	  if ($inxu) { $addSpace=0; }  # �Ǫ�<head>���Ů�
	    if ($parent eq "lg") { $addSpace=0; }  # <lg>��<head>���Ů�
  	  elsif ($parent eq "div1") {
	      if ($div1Type eq "jing") { $addSpace=0; }
	      elsif ($div1Type eq "xu") { $addSpace=0; }  # �Ǫ�<head>���Ů�
	      elsif ($div1Type eq "hui") { $addSpace=0; }  # �|��<head>���Ů�
  	  } elsif ($parent eq "div2") {
	      if ($div2Type eq "jing") { $addSpace=0; }
  	    if ($div2Type eq "xu") { 
  	      $addSpace=0; 
  	      # �p�G�歺�w�Ũ��A�h���Ů�
  	      if ($text =~/^(.*��)�@�@(.*)$/s) {	$text =	$1 . $2; }
  	    }
  	  }
  	  #if ($text !~ /��(�@)*$/) { $addSpace=0; }
  	  if ($addSpace) {
  		  $indentOfThisLine.="�@�@";
  		  $indent .= "�@�@" ;
  		}
  	}
		$heads++;
		$inHead=1;
	}

	# <lb>
	if ($el eq "lb"){
		$lb = $att{"n"};
		$heads = 0;
		if ($debug) { print STDERR "�{�b�b$lb�o��\n"; } #�{�b��F���@��
		$text =~ s/\xa1\x40$//; # xa140 �O�����ť�, �U�|�������|�h�@�ӥ��Ϊť�
		$text =~ s/\xa1\x40\)$/)/;
		if(debug) {
			print STDERR "lb��쪺text�O��$text�@��$ai��\n";
			$ai++;}
			&out;
			$text = "\n$vl$lb��";
			$indentOfThisLine=$indent;
	} 
	
	# <pb>
	if ($el eq "pb") {
		$id = $att{"id"};
		$vl = $id;
		$vl =~ s/\./n/;
		$vl =~ s/\..*/_p/;
		$vl =~ s/([A-Za-z])_/$1/;
		$vl =~ s/^t/T/;
	}
	
	# <div1>
	if ($el eq "div1"){
		if (lc($att{"type"}) eq "xu"){
			$inxu = 1;
			$num = 0;
		} elsif ($num == 0 && (lc($att{"type"}) eq "juan" || lc($att{"type"}) eq "jing" || lc($att{"type"}) eq "pin" || lc($att{"type"}) eq "other")) {
			$num = 1;
		}
		  
		  if (lc($att{"type"}) eq "w") {
		    my $s="";
		    if (defined($att{"rend"})) { $s = myDecode($att{"rend"}); }
		    else { $s = "�@"; }
		    if ($div1Type ne "w" or $text !~ /���@/)
		      { $text .= $s; }  # �e�@��div1���O����~�[�ť�
		    
		    $+ .= $s;
		    if ($debug) { print STDERR "<div1 type='w'> s=[$s] text=[$text]\n"; }
		    if ($debug) { print STDERR "indent=[$indent]\n"; }
		  }
		
		if (lc($att{"type"}) ne "") { $div1Type = lc($att{"type"}); }
		if ($div1Type ne "w" and $text =~ /��$/) { $indentOfThisLine=""; }
	}

	### <div2> ###
	if ($el eq "div2"){
		if (lc($att{"type"}) ne "") { $div2Type = lc($att{"type"}); }
		if ($div2Type eq "xu") { $inxu = 1; }
	}

	# <juan>
	if ($el eq "juan"){
		$fun = lc($att{"fun"});
		if ($fun eq "open"){
	    print STDERR ".";
			$num = $att{"n"};
			$num = "001" if ($att{"n"} eq "");
		} else {
		}
	}

	### <trailer>
	if ($el eq "trailer") { $inTrailer=1; }
}

sub rep{
	local($x) = $_[0];
	return $Entities{$x} if defined($Entities{$x});
	die "Unknown entity $x!!\n";
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

	# </edition>
	if ($el eq "edition") {
	  $version =~ /\b(\d+\.\d+)\b/;
	  $version = $1;
	  print STDERR "$version\n";
	}

	# </jhead>
	if ($el eq "jhead") {
	  $inJhead=0;
	}
	
  # </head>
	if ($el eq "head" && $added == 1){
		$pass--;
		$added = 0;
	}
	
	# </byline>
	if ($el eq "byline"){
	  $indent = "";
	  $inByline=0;
	}
	
	$text .="�@" if $el eq "l";
	
	# </head>
	if ($el eq "head"){
		$indent = "" ;
		$inHead=0;
	}
	
	# </note>
	if ($el eq "note" && $close ne ""){
		# modified by Ray 2000/2/14 10:01AM
		$text .= $close if ($pass == 0);
		$close = "";
	}
	
	# </bibl>
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
			mkdir($cfg{"OUTDIR"} . "\\APP1\\$od", MODE);
			$c = "n" if ($c eq "_");
			$of = $cfg{"OUTDIR"} . sprintf("\\APP1\\$od\\T%2.2d$c%4.4d.txt", $1, $2);
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

	# </title>
	if ($el eq "title"){
		$bib =~ s/^\t+//;
		$title = $bib;
	}

	# </div1>
	if ($el eq "div1"){
		$inxu = 0;
	}

	# </p>
	if ($el eq "p"){
		if ($head == 1) {  # �p�G�b <teiheader> ��
			$bib =~ s/^\t+//;
			$ly{$lang} = $bib;
		} else {
		}
		$inp = 0;
		
		# added by Ray 1999/12/1 10:22AM
		$indent =~ s/$pRend//;
	}

	# </teiheader>
	if ($el eq "teiheader"){
		#print STDERR "date=[$date]\n";
		head("App���Ϊ�","App-Format",$version);
		$text = "";
	}

	$lang = "" if ($el eq "p");
	
	# </tei.2>
	if ($el eq "tei.2"){
		&out;
		$text = "";
		print "\n";
		close (OF);
		$vl = "";
		$num = 0;
	}

	# </trailer>
	if ($el eq "trailer") { $inTrailer=0; }

	$bib = "";
  pop(@saveElement);
	$indent = pop(@saveIndent);
}


sub char_handler 
{
	my $p = shift;
	my $char = shift;

	# <app>�ت���r�u��X�{�b<lem>��<rdg>�� added by Ray
	my $parent = lc($p->current_element);
  if ($parent eq "app") { return; }
  
  if ($parent eq "note") {
	  my $att = pop(@saveatt);
	  my $noteType = $att->{"type"};
    push @saveatt, $att;
	  if ($noteType eq "sk" or $noteType eq "foot") {  return;  }
  }

  # added by Ray 1999/12/15 10:14AM
  # ���O 100% ���ɻ~���ϥ�
  if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }

  $char =~ s/($utf8)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	
	# added by Ray 2000/1/25 03:12PM
  if ($parent eq "date") {
    my $len = @saveElement;
    if ($saveElement[$len-2] eq "edition") {
      $date .= $char;
      return;
    }
  }
  
  if ($parent eq "edition") { $version .= $char; }
	$bib .= $char if ($bibl == 1);
	
	# modified by Ray 2000/2/14 10:02AM
	#$text .= $char if ($pass == 0 && $el ne "pb" && $inp != 1);
	$text .= $char if ($pass == 0 && $el ne "pb");
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

sub out{
  my $lineHead;
  my $firstChar=1;
  my $thisLineIsEmpty=1;
  if ($text =~ /0001a01/) { $debug=1; }
  $text =~ /(.*)\xf9\xf8(.*)$/s;  # xf9f8 �O��
	$lineHead = $1;
  my $rend = $indentOfThisLine;
	$text = $2;
	if ($debug) { print STDERR "�歺�O��$lineHead\n";
	                    print STDERR "����O    $text\n";}
	$count = @chars;
	if ($count > 99){
			$count = sprintf("%2.2d", $count);
		} else {
			$count = sprintf("(%2.2d", $count);
		}
    $text =~ s/\[[0-9!][0-9��]\]//g;
    #$text =~ s/\[[0-9�][0-9�]\]//g;                  #�h��[\d\d]
	if (debug){print STDERR "�h�����ѽX�᪺text\n$text\n";}
    # �U�@���x�}�A�o�˥i�H�@�r�@�r���R
    my @nextLineChars=();
    push(@nextLineChars, $text =~ /$big5/g);
    if(debug){print STDERR "�Ntext���x�}  [@nextLineChars]\ntext�٬O[$text]\n";}
      		# �զr�������P�@�r
      		my @temp = @nextLineChars;
      		@nextLineChars = ();
      		while (@temp>0) {   #���r����
      		  $cc = shift @temp;
       	     if ($cc eq "[") {  #��x�}�J��[
			     $s1 = join("", @temp);  #��@temp�ѤU�����X���@�r
			     if($debug){print STDERR "����̦�[�As1=$s1";}
			       if ($s1 =~ /\]/) {  #�p�G�r�̦�]
			           $c = "##";
      		           while ($c ne "]" and @temp>0) {
      		             $c = shift @temp;
      		             $cc .= $c;
      		           }
      		       }else{print STDERR "��[�S��]";}
      		     push @nextLineChars, $cc;
      		     next;
      		 }
      			 if ($cc =~ /^(.{2})(\[.*\])$/) {
      			   print STDRR "�o�O�H";
      			   push @nextLineChars, $1;
      			   push @nextLineChars, $2;
      		 	 } else { push @nextLineChars, $cc;}
      		}

    # �U�@��u�Ĥ@�Ӧr���v�O�_���j�r��
    my $delimiter = "�@�C�D�B,. �]�^()[]��";  # ���j�r��
    $char = $nextLineChars[0]; #�Ĥ@�Ӧr��
    $cc = quotemeta($char);
    if ($delimiter =~ /$cc/ or $text eq "") { #�p�G�Ĥ@�Ӧr���ݩ���j�r���A�άO$text�S�r
      if (@chars > 0) {                               #�ӥB�٦��r�S�L
    	    print $indentOfLastLine;
    	    print @chars; @chars=(); # �L�X�W�@��H�γo�@��b���j�r���e���r
    	    $count="(00"; # ���U�@�檺�r�Ƭ�0
   	  }
    }

    # �L�X�U�@��渹
    if ($lineHead ne "") { print "${lineHead}$count)��"; }
	if ($debug) { print STDERR "�bp[$inp]�bTrailer=[$inTrailer]�bHead[$inHead]\n"; }
	if (($inp or $inTrailer or $inHead or $inByline or $inJhead) and $text ne "") { #$text���r�A�ӥB�bp��trailer��head��byline��jhead��
		if ($debug) { print STDERR "�L���歺��text=[$text]\nchar���e�٦�@chars�S�L\n";}
      		push(@chars, @nextLineChars);
      		if ($debug) {
      		  foreach $cc (@chars) { print STDERR $cc,","; }
      		}
      		my $cut=0;  # ����U�@�檺��m�A��$cut�@�ӭ�
      		for ($i=@chars-1; $i>=0; $i--) {
      		  $c = $chars[$i];
      		  $cc = quotemeta($c);
      		  if ($delimiter =~ /$cc/) {
      		    if ($c eq "�]" or $c eq "(" or $c eq "[" or $c eq "�@") 
      		      { $cut = $i; }
      		    else { $cut=$i+1;}
      		    last;
      		  }
      		}
      		if ($debug) { print STDERR "\n��X�n�L$cut�Ӧr�A�M��}�l�L\n"; } #�L$cut��
      		for ($i=0; $i<$cut; $i++) {                   #�q�o�̦L�X����
      			$c = shift (@chars);
      			if ($i==($cut-1) and $c eq "�@") { next; } #�Y��̫�@�r�Anext
      			if ($c ne "��" and $c ne "��") {
      				if ($firstChar) { print $rend; $firstChar=0; }
      			  print $c;
      			  $thisLineIsEmpty=0; # ���L�X�F��A�o�@�椣�O�Ŧ�
      			}
      		}
	} 
	else {                                                                                                   #$text�S�r�A�άO���box�̭�
	   if ($debug) {
	     print STDERR "indent=[$indent]\n"; 
	     my $i = @chars;
	     print STDERR "chars $i\n";getc; #���X�Ӧr�n�L
	   }
	   if ($text ne "" or @chars > 0) {   #�Y$text���F��Τ��e���r�S�L,�N�L$rend,�ӥB�O$thisLineIsEmpty=0
	     if ($debug) { print STDERR "�Lrend�M��ŧi�o�椣��\n"; }
	     print $rend;                     #�L�ť�
	     $thisLineIsEmpty=0;
	   }
	   print @chars; @chars=(); #��@char�L�X�h�A�M��
	   print "${text}"; #�L$text
	}
	$text = "";
	# �o�@��O�Ŧ�A��indent�s�_�A�U�@��n�L�ɥ�
	if ($thisLineIsEmpty) { $indentOfLastLine = $indentOfThisLine; }
	else { $indentOfLastLine = ""; }  #��ܤW�@��w�M
	if ($debug) { print STDERR "�٦��ť�[$indentOfLastLine]�S�L\n";}  #�ݬݤW�@��Ѥ���
}

sub myDecode {
  my $s = shift;
  $s =~ s/($utf8)/$utf8out{$1}/g;
	return $s;
}




__END__
:endofperl
