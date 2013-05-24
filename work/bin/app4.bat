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

my $pass;          # 在<body>裏是0,
                   # 在<rdg>或<gloss>或<head type="added">裏 $pass 會累加
my $inp;           # 在<p>裏是1, 在<p>外是0
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
		  if ($val=~/nor=\'(.+?)\'/) { $val=$1; }  # 優先用通用字
		  elsif ($val=~/des=\'(.+?)\'/) { $val=$1; } # 否則用組字式
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
    my $parent = lc($p->current_element);
  if ($parent eq "note") {
	  my $att = pop(@saveatt);
	  my $noteType = $att->{"type"};
    push @saveatt, $att;
	  if ($noteType eq "sk") {  return;  }
  }

    $string =~ s/^\&(.+);$/&rep($1)/eg;
	$bib .= $string if ($bibl == 1);
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
	#卷首，jhead=1
	if ($el eq "jhead"){
	  $inJhead=1;
	}

	# <p>
	#在段落裡而且沒標點時，p=1
	#在段落裡的標題時，bibl=1
	#在標題時，判斷語言
	if ($el eq "p"){
		$inp = 1 if (lc($att{"rend"}) ne "nopunc");
	}

	if ($head == 1){
		$bibl = 1 if ($el =~ /^bibl|title|p$/);
		print "bib2";
	}
	if ($head == 1 && lc($att{"type"}) eq "ly"){
		if ($att{"lang"} eq "zh"){
			$lang = "zh";
		} else {
			$lang = "en";
		}
	}

	### <corr>
	#如果有校訂訊息，把cert指定給CorrCert
	#如果沒百分之百確定，就呼叫myDecode
	if ($el eq "corr") {
	  $CorrCert = lc($att{"cert"});
	  if ($CorrCert ne "" and $CorrCert ne "100") {
	    my $sic = myDecode(lc($att{"sic"}));
	    $text .= $sic if ($pass == 0);
	  }
	}

	# <note>
	#校勘的一種inline為夾註
	if ($el eq "note" && lc($att{"type"}) eq "inline"){
			$text .= "(" if ($pass == 0);
			$close = ")";
	}

	# <p>
	if ($el eq "p") {
	  $pRend = "";
	  my $type = $att{"type"};
	  if (lc($att{"type"}) eq "inline") {
		  if ($text !~ /(║|　|。)$/ and $pass == 0) { $text .= "。"; }
        } elsif (lc($att{"type"}) eq "winline") {
    	  $text .= "。" if ($pass == 0);
		  
		  $pRend = $att{"rend"};
      $pRend =~ s/($utf8)/$utf8out{$1}/g;
		  if ($pRend eq "") { $pRend = "　"; }
		  $indent .= $pRend;
		} elsif ($type eq "dharani") {
		  if ($text !~ /(║|　|。)$/)
		    { $text .= "　"; }
    } elsif (lc($att{"type"}) eq "w") {
		  $pRend = $att{"rend"};
      $pRend =~ s/($utf8)/$utf8out{$1}/g;
		  if ($pRend eq "") { $pRend = "　"; }
		  if ($text =~ /║$/) { $indentOfThisLine .= $pRend; }
		  else { $text .= $pRend; }
		  $indent .= $pRend;
    }
	}
	
	# <l>
	if ($el eq "l") {
	  my $rend = $att{"rend"};
	  $rend =~ s/($utf8)/$utf8out{$1}/g;
	  if ($rend eq "") { $text .= "　"; }
	  else { $text .= $rend; }
	  if ($debug) { print STDERR "$text\n"; getc; }
	}
	
	# <byline>
	if ($el eq "byline"){
	  # 如果還沒出現過其他<byline>
	  if ($indentOfThisLine !~/　　　　/) {
		  $indentOfThisLine.="　　　　";
		  $indent = "　　　　";
		} elsif ($text !~ /║$/) {
		  $text .= "　";
		}
		$inByline=1;
	}

	# <head>
	if ($el eq "head") {
		if ($heads == 0) {
	    my $parent = lc($p->current_element);
  	  my $addSpace = 1;
  	  if (lc($att{"type"}) eq "added") { $addSpace = 0; }
  	  if ($inxu) { $addSpace=0; }  # 序的<head>不空格
	    if ($parent eq "lg") { $addSpace=0; }  # <lg>的<head>不空格
  	  elsif ($parent eq "div1") {
	      if ($div1Type eq "jing") { $addSpace=0; }
	      elsif ($div1Type eq "xu") { $addSpace=0; }  # 序的<head>不空格
	      elsif ($div1Type eq "hui") { $addSpace=0; }  # 會的<head>不空格
  	  } elsif ($parent eq "div2") {
	      if ($div2Type eq "jing") { $addSpace=0; }
  	    if ($div2Type eq "xu") { 
  	      $addSpace=0; 
  	      # 如果行首已空兩格，去掉空格
  	      if ($text =~/^(.*║)　　(.*)$/s) {	$text =	$1 . $2; }
  	    }
  	  }
  	  #if ($text !~ /║(　)*$/) { $addSpace=0; }
  	  if ($addSpace) {
  		  #$text .=	"　　" ;
  		  $indentOfThisLine.="　　";
  		  $indent .= "　　" ;
  		}
  	}
		$heads++;
		$inHead=1;
	}

	# <lb>
	if ($el eq "lb"){
		$lb = $att{"n"};
		$heads = 0;
		#if ($lb =~ /692b22/) { $debug=1; }
		if ($debug) { print STDERR "$lb "; }#現在到了哪一行
		$text =~ s/\xa1\x40\)$/)/;
			&out;
			$text = "\n$vl$lb║";
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
	#如果是在序裡面就指定inxu=1 num=0
	#如果不在序裡而在經或卷或品裡或其他而num=0 就改成 num=1
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
		    else { $s = "　"; }
		    if ($div1Type ne "w" or $text !~ /║　/)	{ # 前一個div1不是附文才加空白
		      $text .= $s;
		      $indent .= $s;
		      $indentOfThisLine=$indent;
		    }
		    
		    if ($debug) { print STDERR "<div1 type='w'> s=[$s] text=[$text]\n"; }
		    if ($debug) { print STDERR "indent=[$indent]\n"; }
		  }
		
		if (lc($att{"type"}) ne "") { $div1Type = lc($att{"type"}); }
		if ($div1Type ne "w" and $text =~ /║$/) { $indentOfThisLine=""; }
	}

	### <div2> ###
	#檢查在不在序裡
	if ($el eq "div2"){
		if (lc($att{"type"}) ne "") { $div2Type = lc($att{"type"}); }
		if ($div2Type eq "xu") { $inxu = 1; }
	}

	# <juan>
	#開卷
	#有卷就印一個點
	#num沒有指定就給001
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
	#卷首=0
	if ($el eq "jhead") {
	  $inJhead=0;
	}
	
  # </head>
	if ($el eq "head" && $added == 1){
		$pass--;
		$added = 0;
	}
	
	# </byline>
	#將indent設成0
	if ($el eq "byline"){
	  $indent = "";
	  $inByline=0;
	}
	#</l>
	#如果遇到l結尾，就加上全形空白
	$text .="　" if $el eq "l";
	
	# </head>
	#將indent=0
	if ($el eq "head"){
		$indent = "" ;
		$inHead=0;
	}
	
	# </note>
	#將close設成0
	if ($el eq "note" && $close ne ""){
		$close = "";
	}
	
	# </bibl>
	#行首資訊處理
	if ($el eq "bibl"){
		$bibl = 0;
		if ($bib =~ /Vol\.\s+([0-9]+).*?([0-9]+)([A-Za-z])?/){
			if ($3 eq ""){
				$c = "_";
			} else {
				$c = $3;
			}
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
		print "bib3=$bib";
		$ebib = $bib;
	}

	# </title>
	if ($el eq "title"){
		$bib =~ s/^\t+//;
		#print "bib4=$bib";
		$title = $bib;
	}

	# </div1>
	if ($el eq "div1"){
		$inxu = 0;
	}

	# </p>
	if ($el eq "p"){
		if ($head == 1) {  # 如果在 <teiheader> 裏
			$bib =~ s/^\t+//;
		    print "bib5=$bib";
			$ly{$lang} = $bib;
		} else {
		  #$text .= "-";
		}
		$inp = 0;
		
		# added by Ray 1999/11/10 09:16AM
		if ($px ne "") { $px .= "Ｐ"; }
		
		# added by Ray 1999/12/1 10:22AM
		$indent =~ s/$pRend//;
	}

	# </teiheader>
	if ($el eq "teiheader"){
		head("App普及版","App-Format",$version);
		$text = "";
	}

	$lang = "" if ($el eq "p");
	
	# </tei.2>
	#印出去，結束
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

	# <app>裏的文字只能出現在<lem>或<rdg>裏 added by Ray
	my $parent = lc($p->current_element);
  if ($parent eq "app") { return; }
  
  if ($parent eq "note") {
	  my $att = pop(@saveatt);
	  my $noteType = $att->{"type"};
    push @saveatt, $att;
	  if ($noteType eq "sk" or $noteType eq "foot") {  return;  }
  }

                              # added by Ray 1999/12/15 10:14AM
                              # 不是 100% 的勘誤不使用
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
  if ($text =~ /860c10/) { $debug=1; }
  if ($debug) { print STDERR "px=[$px]\n"; }

  # 取出行首資訊
  # added by Ray 1999/12/1 11:52AM
  $text =~ /(.*)\xf9\xf8(.*)$/s;  # xf9f8 是║
	$lineHead = $1;
  my $rend = $indentOfThisLine;
	$text = $2;

	if ($debug) { print STDERR "lineHead=[$lineHead]\n"; }#印出行首

	$count = @chars;

	if ($count > 99){
			$count = sprintf("%2.2d", $count);
		} else {
			$count = sprintf("(%2.2d", $count);
		}

  if ($debug) { print STDERR "text=[$text]\n"; }
	if ($debug) { print STDERR "611\n"; }
  #print "${text}$c)║$rend";
  #if ($lineHead ne "") { print "${lineHead}$c)║$rend"; }
		
	$text = myReplace($text);
		
    # 下一行拆成矩陣
    my @nextLineChars=();
    push(@nextLineChars, $text =~ /$big5/g);
       #marked by ascetic 2000/2/19 08:25AM
 		#@nextLineChars = grep(!/║/, @nextLineChars);

      		# 組字式視為同一字
      		my @temp = @nextLineChars;
      		@nextLineChars = ();
      		while (@temp>0) {
      		  $cc = shift @temp;
       	  if ($cc eq "[") {
			        $s1 = join("", @temp);
			        if ($s1 =~ /\]/) {
			          $c = "##";          
      		      while ($c ne "]" and @temp>0) {
      		      	 #added by ascetic 2000/2/18 10:10AM
      		        #$i++;
      		        $c = shift @temp;
      		        $cc .= $c;
      		      }
      		    }
      		    push @nextLineChars, $cc;
      		    next;
      		  }
      			if ($cc =~ /^(.{2})(\[.*\])$/) {
      			  push @nextLineChars, $1;
      			  push @nextLineChars, $2;
      			} else { push @nextLineChars, $cc; }
      		}

    # 下一行第一個字元是否分隔字元
    my $delimiter = "　。．、,. （）【】()[]Ｐ";  # 間隔字元
    $char = $nextLineChars[0];
    $cc = quotemeta($char);
    if ($delimiter =~ /$cc/ or $text eq "") { 
      if (@chars > 0) {
    	    print $indentOfLastLine;
    	    print @chars; @chars=(); # 印出上一行
    	    $count="(00"; # 折到下一行的字數為0
   	  }
    }

    # 印出下一行行號
    if ($lineHead ne "") { print "${lineHead}$count)║"; }

	# modified by Ray 2000/2/14 10:09AM
	#if ($px ne ""){
	if ($debug) { print STDERR "inp=$inp inTrailer=$inTrailer inHead=$inHead\n"; }
	if ($debug) { print STDERR "Line:677 text=[$text]\n"; }
	if (($inp or $inTrailer or $inHead or $inByline or $inJhead) and $text ne "") {

		if ($debug) { print STDERR "Line:667 text=[$text]\n"; }
      		
    push(@chars, @nextLineChars);
      		
      		if ($debug) {
      		  foreach $cc (@chars) { print STDERR $cc,","; }
      		  getc;
      		}
      		
      		my $cut=0;  # 切到下一行的位置
      		for ($i=@chars-1; $i>=0; $i--) {
      		  $c = $chars[$i];
      		  $cc = quotemeta($c);                      #為什麼這裡要多用一個$cc？quotemeta
      		  if ($delimiter =~ /$cc/) {
      		    # modified by Ray 2000/2/24 10:15AM
      		    #if ($c eq "（" or $c eq "(" or $c eq "[") { $cut = $i; }
      		    if ($c eq "【" or $c eq "（" or $c eq "(" or $c eq "[" or $c eq "　") 
      		      { $cut = $i; }
      		    else { $cut=$i+1;}
      		    last;
      		  }
      		}
      		if ($debug) { print STDERR "cut=[$cut]\n"; }
      		for ($i=0; $i<$cut; $i++) {                   #從這裡印出本文
      			$c = shift (@chars);
      			if ($i==($cut-1) and $c eq "　") { next; }
      			if ($c ne "║" and $c ne "Ｐ") {
      				if ($firstChar) { print $rend; $firstChar=0; }
      			  print $c;
      			  $thisLineIsEmpty=0; # 有印出東西，這一行不是空行
      			}
      		}
	} else {
	  if ($debug) { 
	    print STDERR "716 indent=[$indent]\n"; 
	    my $i = @chars;
	    print STDERR "chars $i\n";
	  }
	  if ($text ne "" or @chars > 0) { 
	    if ($debug) { print STDERR "721\n"; }
	    print $rend; 
	    $thisLineIsEmpty=0;
	  }
	  #	$text =~ s/#[0-9][0-9]#//g;
#		$text =~ s/(　)+?║/(00)║/g;
#		$text =~ s/║/(00)║/g;
#		$text =~ s/║/(00)║/g;
		
		# marked by Ray 2000/2/27 06:26PM
		#$text =~ s/　\(/(/;
		#$text =~ s/　\(/(/;
		#$text =~ s/　\(/(/;
		
		# marked by Ray 2000/2/11 04:14PM 會把組字式中的 "-" 去掉
		#$text =~ s/-//;
		
		# 如果這一行是空的，要把上一行剩下的印出去 added by Ray 1999.10.8
		#if ($text =~ /║$/) { print @chars; @chars=(); }
		print @chars; @chars=();
		
		print "${text}";
	}
	#$px = "";
	$text = "";
	
	# 這一行是空行，把indent存起，下一行要印時用
	if ($thisLineIsEmpty) { $indentOfLastLine = $indentOfThisLine; }
	else { $indentOfLastLine = ""; }
	if ($debug) { print STDERR "indentOfLastLine=[$indentOfLastLine]\n"; getc; }
}

sub myDecode {
  my $s = shift;
  $s =~ s/($utf8)/$utf8out{$1}/g;
	return $s;
}

sub myReplace {
  my $s = shift;
	my $big5 = '[0-9\xa1-\xfe][\x40-\xfe]\[[\xa1-\xfe][\x40-\xfe].*?[\xa1-\xfe][\x40-\xfe]\)?\]|[\xa1-\xfe][\x40-\xfe]|\<[^\>]*\>|.';
	$s =~ s/\[[0-9（[0-9珠\]//g;
	$s =~ s/#[0-9][0-9]#//g;

	# 兩個以上的★, 換成〔◇〕
	$s =~ s/(★){2,}/【◇】/g;
	
  # 單獨一個★, 換成◇
  my @a=();
  push(@a, $s =~ /$big5/gs);
  $s="";
	foreach $c (@a) {	$c =~ s/★/◇/; $s.=$c;}
	return $s;
}



__END__
:endofperl
