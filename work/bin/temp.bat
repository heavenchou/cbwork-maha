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


$TocOutputDir = "u:/work/htmlhelp/toc";
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
	chop;
	($key, $val) = split(/=/, $_);
	$key = uc($key);
	$cfg{$key}=$val; #store cfg values
	print "$key\t$cfg{$key}\n";
}

#mkdir($cfg{"OUTDIR"}, MODE);
#mkdir($cfg{"OUTDIR"} . "\\HTMLHELP", MODE);
#mkdir($cfg{"OUTDIR"} . "\\HTMLHELP" . "\\$dir", MODE);
$cfg{"OUTDIR"} = "u:\\work\\htmlhelp";

opendir (INDIR, $cfg{"DIR"} . "\\$dir");
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

openVTOC();  # 全冊目錄 T99.hhc
#openOF();    # 全冊經文 T99.htm
openHHP();   # HTML Help Project T99.hhp

use XML::Parser;

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
my $source;
my $column="";    # 記錄目前頁碼，如：0001a
my $preColumn=""; # 上一頁
my $sutraNum="";  # 記錄目前經號，如：1111
my $sutraName=""; # 經名
my $div1Type="";
my $div2Type="";
my $headId="";
my @saveatt=();   # 儲存 attribute
my @lines=();     # 儲存上一欄的經文
my @elements=();
my %saveXu=();
my %saveJuan=();
my %savePin=();   # 品
my %savePin2=();  # 品 (div2)
my %saveHui=();   # 會
my %saveFen=();   # 分
my %saveJing=();  # 經
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
        
print VTOC "</UL>\n</BODY></HTML>";
        
print STDERR "M 碼記錄...\n";
my @mojikyo;
if ($inputFile eq "") {
  for $file (sort(@allfiles)) { processM($file);  }
} else {
  processM($inputFile);
}       
foreach $m (sort @mojikyo) { print HHP "images\\$m.GIF\n"; }
print HHP "\n\n[INFOTYPES]\n";  # added by Ray 1999/11/9 12:07PM
        
print STDERR "完成!!\n";
        
#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	#local($k) = "." . $cfg{"CHAR"};
	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
	#$file =~ s#/#\\#g;
	#$file =~ s/\.\./$cfg{"DIR"}/;
	print STDERR "開啟 Entity 定義檔: $file\n";
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
		  if ($val=~/nor=\'(.+?)\'/) { $val=$1; } # 優先使用通用字
		  else {
		    if ( $val=~/mojikyo=\'(.+?)\'/) {
		      my $m=$1;  # 否則用 M 碼
		      my $des = "";
		      if ( $val=~/des=\'(.+?)\'/) { $des=$1; } # 否則用 M 碼
		      else { $des = $m; }
		      if ($des=~/\[(.*)\]/) { $des = $1; }
		      $m =~ s/^M//;
		      push @mojikyo,$m;
	        my $href = "javascript:showpic(\"images/$m.gif\")";
	        $val = "[<a href='$href'>$des</a>]";
		    } else { $val=$ent; } # 最後用 CB 碼
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
        
	# added by Ray 1999/11/23 05:25PM
	# <note type="sk">, <note type="foot"> 的內容不顯示
	my $parent = lc($p->current_element);
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
#		print STDERR "$bib\n";
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
	} else {	$text .= $string if ($pass == 0); }
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
	@elements=();
}       
        
        
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);
        
	$elementChar="";
        
	### <body> ###
	$pass = 0 if $el eq "body";
       
	### <byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:33AM
		#$text .= "<span class='byline'><br>　　　　" ;
		#$indent = "<br>　　　　";
		$text .= "<p><span class='byline'>　　　　" ;
		     
		# marked by Ray 1999/11/30 10:26AM
		#$indent = "　　　　";
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
	  # div1 的 type 屬性可以延續上一個 div1
	  if ($att{"type"} ne "") {	$div1Type = lc($att{"type"}); }
		if (div1Type eq "xu"){
			$xu = 1;
			$num = 0;
		} elsif ($num == 0 && (div1Type eq "juan" || div1Type eq "jing" || div1Type eq "pin" || div1Type eq "other")) {
			$num = 1;
		}    
	}     
       
	### <div2> ###
	if ($el eq "div2"){
	  # div2 的 type 屬性可以延續上一個 div2
	  if ($att{"type"} ne "") {	$div2Type = lc($att{"type"}); }
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
		  $text .=	"<p><b>　　" ;
		  $bibl = 1;
		  $bib = "";
		  $nid++;
		  $text .= "<A NAME=\"n$nid\"></A>";
	  }   
	      
	  # 越過 <lem>, <term> <corr> 找 parent
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
  	   
  	# 如果是般若部的div2的品
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
       
	### <juan> ###
	if ($el eq "juan"){
	  $juanURL = "/$vol$column.htm#$lb";
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
		} else {
		}    
		$text .= "<p class='juan'>\n";
	}     
       
	### <l> ###
	if ($el eq "l"){
		$text .= "　";
	  my $rend = $att{"rend"};
	  $rend =~ s/($pattern)/$utf8out{$1}/g;
	  if ($rend eq "") { $rend = "　"; }
	  # 如果偈頌前有 (
	  if ($text =~ /(.*║.*)\($/s) {
	    $text = $1 . $rend . "(";
	  } else { $text .= $rend; }
	}     
       
	### <lb> ###
	if ($el eq "lb"){
		$lb = $att{"n"};
		if ($column eq "") { $column = substr($lb,0,5); }
		#if ($lb eq "0217a11") { $debug=1; }
		#the whole line has been cached to $text, print it now!
		printOneLine();
		     
		# modified by Ray 1999/11/21 03:26PM
		#$text = "</a>$br<a id=\"$lb\">$indent";
		$text = "$br<a name=\"$lb\" id=\"$lb\">$indent";
		if ($firstLineOfPage) { $firstLineOfPage = 0; }
		else { $text = "</a>" . $text; }

	  if ($firstLineOfSutra) {
	    my $num = $sutraNum;
	    $num =~ s/^0//;
	    $num =~ s/^0//;
	    $num =~ s/^0//;
	    print FTOC "<a href=\"$chm.chm::/$vol$column.htm\">No. $num $sutraName</A></TH>\n";
      print FTOC "</THEAD>\n<TR><TD>\n";
      $firstLineOfSutra = 0;
   }
	}     
       
	### <lg> ###
	if ($el eq "lg" ){
		$text .= "<p class='lg'>";
		$br = "<br>";
	}     
	      
	### <note> ###
	if ($el eq "note" && lc($att{"type"}) eq "inline"){
#	print "(";
		$text .= "(";
		$close = ")";
	}     
       
	### <p> ###
	if ($el eq "p"){
	  $ptype = lc($att{"type"});
	  if ($ptype eq "w" or $ptype eq "winline") {
		  $text .= "<blockquote class='FuWen'>";
		  $indent = "";
	  } else {
		  $text .= "<p>";
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
   print "<hr><br><br>";
		if ($preColumn ne "" or $column ne "") { 
     print "\n<DIV id=waterMark style=\"position:absolute;right:0;bottom:0\" media=\"screen\">\n";
     print "<table align=\"right\"><tr><td>\n";
		  if ($preColumn ne "") {
       print "<a href='$vol${preColumn}.htm'><img src='up.gif' border=0></a>\n"
		  }  
       
		  if ($column ne "") {
		    my $col = $att{"n"};
       print "<a href='$vol${col}.htm'><img src='down.gif' border=0></a>\n";
		  }  
     print "</td></tr></table>\n";
     print "</DIV>\n";
     print "<SCRIPT language=JavaScript1.2 src=\"water.js\"></SCRIPT>\n";
		}    
       
	  $preColumn = $column;
	  $column = $att{"n"};
	      
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
   if ($juanNum ne "") { print "<font face='Arial'>(卷$juanNum)</font>" };
   if ($div1head ne "") { 
     if ($div1head =~ /^#\d\d#(.*)/) { $div1head = $1; }
     if ($div1head =~ /(.*分)初$/) { $div1head = $1; }

     # "一" = \xa4\x40
     if ($div1head =~ /(.*誦)第\xa4\x40$/) { $div1head = $1; }

     if ($div1head =~ /^（.+）(第.+分)$/) { $div1head = $1; }

     # "（一）第一分" -> "第一分"
     # \xa1\x5d = "（" ,  \xa1\x5e = "）"
     if ($div1head =~ /^\xa1\x5d.+\xa1\x5e(第.+分)$/) { $div1head = $1; }
     print " $div1head"; 
   }
   print " <font face='Arial'>$vol, p$column</h2></font><hr>\n";
   print "<span class='old'>\n";
   print shift @lines;
   print shift @lines;
   print "</span>";
	}     
	      
       
	### <rdg> ###
	$pass++ if $el eq "rdg";
       
	### <teiheader> ###
	$head = 1 if $el eq "teiheader";  #We are in the header now!
       
	#end startchar
}       
        
sub rep{
	local($x) = $_[0];
	if ($debug) { print STDERR "rep($x)="; }
	# modified by Ray 1999/10/13 07:16PM
	#return $Entities{$x} if defined($Entities{$x});
	if (defined($Entities{$x})) {
	  my $str = $Entities{$x};
	  if ($str =~ /^\[(.*)\]$/) {
	    my $exp = $1;  # 組字式
	    if ($x=~/M(\d\d\d\d\d\d)/) {
	  #    my $href = "javascript:showpic(\"images/$1.gif\")";
	  #    $str = "[<a href='$href'>$exp</a>]";
	  #    return $str;
	    } elsif (defined($dia{$exp})) {
	      $str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
	      if ($debug) { print STDERR "$str\n"; }
	      return $str;
	    }
	  }   
	  if ($debug) { print STDERR "$str\n"; }
	  return $str;
	}     
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
		$bib =~ s/\[[0-9（[0-9珠\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$bib = "";
		$text .= "</p>\n";
		     
		if (lc($att->{"fun"}) eq "open" and $div1Type ne "w") {
     #my $id = %saveJuan + 1;
     #$id = "/$vol$column.htm#$lb";
     my $num = $juanNum;
     $num =~ s/^0//;
     $num =~ s/^0//;
     $juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
     $juanText =~ s/\[＊\]//g;
     #$saveJuan{$id}=$num . " " . $juanText;
     $saveJuan{$juanURL}= "第" . cNum($juanNum);
     #$juanURL = $id;
		} elsif (lc($att->{"fun"}) eq "close" and $div1Type ne "w") {
     $juanText =~ s/\[\d\d\]//g;  # 去掉校勘符號
     $juanText =~ s/\[＊\]//g;
     my $i = cNum($juanNum);
		  print FTOC "<TD><A HREF=\"$chm.chm::$juanURL\">卷第$i</A>\n";
		  print FTOC "<TR><TD>\n";
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
     $headText =~ s/\[\d\d\]//g;  # 去掉校勘符號
     $headText =~ s/\[＊\]//g;
     $div1head = $headText;
     if ($debug) { print STDERR "div1Type=[$div1Type]\n"; }
     if ($div1Type eq "xu") {
       #$text .= "</a>";
       $saveXu{$headId}=$headText;
       print FTOC "<A HREF=\"$chm.chm::$headId\">$headText</A><BR>\n";
     } elsif ($div1Type eq "pin") {
       #$text .= "</a>";
       $headText =~ s/^(.*品)(第.*)$/$1/;
       $savePin{$headId}=$headText;
       my $i = keys(%savePin);
       print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
       if ($debug) {
         print STDERR "headId=[$headId]\n";
         print STDERR "headText=[$headText]\n";
       }
     } elsif ($div1Type eq "hui") {
       #$text .= "</a>";
       $headText =~ s/^(.*會)(第.*)$/$1/;
       $saveHui{$headId}=$headText;
       my $i = keys(%saveHui);
       print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
     } elsif ($div1Type eq "fen") {
       #$text .= "</a>";
       $headText =~ s/^(.*分)(第.*)$/$1/;
       $saveFen{$headId}=$headText;
       my $i = keys(%saveFen);
       print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
     } elsif ($div1Type eq "other" or $div1Type eq "jing") {
       #$text .= "</a>";
       $saveOther{$headId}=$headText;
       
       my $aa = quotemeta("（");
       my $bb = quotemeta("）");
       if ($headText =~ /^$aa.*$bb$/) {
         print FTOC "<A HREF=\"$chm.chm::$headId\">$headText</A><BR>\n";
       } else {
         my $i = keys(%saveOther);
         print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
       }
       
       #print STDERR "[$headId,$headText]\n";
     } 
   }   
       
   # </div2>
   if ($parent eq "div2" and $chm eq "BoRuo" and $div2Type eq "pin") {
       $text .= "</a>";
       #$headText =~ s/^(.*品)(第.*)$/$1/;
       $savePin2{$headId}=$headText;
       my $i = keys(%savePin2);
       print FTOC "<A HREF=\"$chm.chm::$headId\">$i $headText</A><BR>\n";
   }   
       
   $text .= "</b>";
		$bibl = 0;
		$bib =~ s/\n//g;
		$bib =~ s/\[[0-9（[0-9珠\]//g;
		$bib =~ s/#[0-9][0-9]#//g;
		$bib = "";
		$indent = "" ;
	}     
	      
	### </lg> ###
	if ($el eq "lg" ){
		$text .= "</p>";
		$br = "";
	}     
       
	### </byline> ###
	if ($el eq "byline"){
		# modified by Ray 1999/10/13 09:34AM
		#$text .= "</span>" ;
		$text .= "</span><br>" ;
	}     
       
  ## </corr> ###
	if ($el eq "corr"){
		if ($CorrCert eq "" or $CorrCert eq "100") { $text .= "</span>"; }
	}     
       
	$indent = "" if ($el eq "byline");
	$indent = "" if ($el eq "p");
	$text .="　" if $el eq "l";
       
  ## </note> ###
	if ($el eq "note"){
		if ($close ne "") {
		  if ($text =~ /(.*)<\/font>$/) {
		    $text = $1 . $close . "</font>";
		  } else { $text .= $close }
		}
		$close = "";
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
      
      # 將經號補滿四位數
      if ($sutraNum =~ /\d$/) {
        $sutraNum = "0" x (4-length($sutraNum)) . $sutraNum;
      } else {
        $sutraNum = "0" x (5-length($sutraNum)) . $sutraNum;
      }
			#print the rest of the line of the old file!
			$text =~ s/\[[0-9（[0-9珠\]//g;
			$text =~ s/#[0-9][0-9]#//g;
			print OF $text;
			$text = "";
			$vl = sprintf("t%2.2dn%4.4d%sp", $1, $2, $c);
			$od = sprintf("t%2.2d", $1);
			mkdir($cfg{"OUTDIR"} . "\\htmlhelp\\$od", MODE);
#		$c = "n" if ($c eq "_");
#		$oof = $of;
			#base name for file
       
			$xu = 0;
			#$fileopen = 0;
			$num = 0;
			#$bof = $cfg{"OUTDIR"} . sprintf("\\htmlhelp\\$od\\%4.4d$c", $2, $3);
			$bof = $cfg{"OUTDIR"} . "\\";
			$bof =~ tr/A-Z/a-z/;
			$fhead = $cfg{"OUTDIR"} . sprintf("\\htmlhelp\\$od\\%4.4dh", $2, $3);
			$fhead =~ tr/A-Z/a-z/;
			   
			#open (FTOC, ">${bof}toc.htm");
			my $s = ">$TocOutputDir/${vol}" . "N" . $sutraNum . ".htm";
			open (FTOC, $s);
			print STDERR "-> $s\n";
			if ($debug) { print "title=[$title]\n"; }
			$mtit = $title;
			$mtit =~ s/Taisho Tripitaka, Electronic version, //;
	    $mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
	    $mtit =~ s/(.*)No. 0(.*)/$1No. $2/;
	    if ($debug) { print "mtit=[$mtit]\n"; }
     $sutraName = $mtit;
     $sutraName =~ s/No\. \d*\w* //;
       
     printTocHead();
     $firstLineOfSutra = 1;
     $firstLineOfPage = 1;
     
     # added by Ray 1999/12/15 10:50AM
     if ($vol eq "T06") { $juanNum = 201; }
		 else { $juanNum = 1; }
		}    
		$bib =~ s/^\t+//;
		$ebib = $bib;
		&changeSutra;
		openOF();
		#&changefile;
	}     
       
	### </title> ###
	if ($el eq "title"){
		#$bib =~ s/^\t+//;
		#$title = $bib;
		if ($debug) { print STDERR "title=$title\n"; getc; }
	}     
       
	### </div1> ###
	#if ($el eq "div1"){
	#  $div1Type="";
	#}    
       
	### </div> ###
	if ($el =~ /div/i){
		$xu = 0;
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
		if (lc($att->{"type"}) eq "w") { $text .= "</blockquote>"; }
	}     
       
	if ($el eq "teiheader"){
#	&head;
	}     
	$lang = "" if ($el eq "p");
       
  ## </tei.2> ###
	if ($el eq "tei.2"){
		$text =~ s/\[[0-9（[0-9珠\]//g;
		$text =~ s/#[0-9][0-9]#//g;
       
		$text =~ s/\xa1\x40$//;
		$text =~ s/\xa1\x40\)$/)/;
		     
		print OF $text;
		$text = "";
		#print "</a><hr>";
		#print "<a href=\"${prevof}#start\" style='text-decoration:none'>▲</a>" if ($prevof ne "");
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
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
  # <note type="sk"> 的內容不顯示
  if ($parent eq "note") {
	  my $att = pop(@saveatt);
	  my $noteType = $att->{"type"};
    push @saveatt, $att;
	  if ($noteType eq "sk") {  return;  }
	  if ($noteType eq "foot") {  return;  }
  }     

  # added by Ray 1999/12/15 10:14AM
  # 不是 100% 的勘誤不使用
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
	&openent($next);
#	print STDERR "$ent\t$entval\t$next\n";
	return 1;
}       
        
        
        
        
        
#-----------------------------------------------------------------------
sub shead{
	print $short;
}       
        
# --------------------------------------------------------------------------
# 切換到新的一經時呼叫
sub changeSutra {
  my $title1 = filterAnchor($mtit);
  print VTOC "  <LI><OBJECT type=\"text/sitemap\">\n";
  print VTOC "      <param name=\"Name\" value=\"$title1\">\n";
  print VTOC "      <param name=\"Local\" value=\"$chm.chm::/${vol}N${sutraNum}.htm\">\n";
  print VTOC "      <param name=\"ImageNumber\" value=\"1\">\n";
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
  $div1head="";
  $div1Type="";
  $column="";
  $preColumn="";
}       
        
#-----------------------------------------------------------------------
# 一經結束時呼叫
sub endSutra {
  my $key,$value;
  my $oldFile = select();
  select VTOC;
        
  ### 序 ###
  print "  <UL>\n";
  if (%saveXu > 0) {
    while (($key,$value)=each(%saveXu)) {
      $value=filterAnchor($value);
      if ($value eq "") { $value = "序"; }
      print "    <LI><OBJECT type=\"text/sitemap\">\n";
		  print "          <param name=\"Name\" value=\"$value\">\n";
		  print "          <param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "        </OBJECT>\n";
			#print FTOC "<P><a href='$chm.chm::$key'>$value</a></LI>\n";
		}    
  }     

  ### 一經單卷 ###
  my $i = keys(%saveJuan);
  if ($i == 1) {
      my @keys = keys(%saveJuan);
      $value=filterAnchor($sutraName);
      $key = $keys[0];
      print "		<LI><OBJECT type=\"text/sitemap\">\n";
		  print "					<param name=\"Name\" value=\"$value\">\n";
		  print "					<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				</OBJECT>\n";
  }     

        
  ### 品 ###
  if (%savePin > 0) {
    print "		<LI><OBJECT type=\"text/sitemap\">\n";
    print "					<param name=\"Name\" value=\"品\">\n";
    print "					<param name=\"ImageNumber\" value=\"1\">\n";
    print "				</OBJECT>\n";
    print "		<UL>\n";
  	#print FTOC "<A class=\"lix\" onClick=\"toggledisp('pin')\">品</A><BR>\n";
  	#print FTOC "<UL id=\"pin\"  style=\"display:none\">\n";
        
    my $i=1;
    for $key (sort(keys(%savePin))) {
      $value = $savePin{$key};
      $value=filterAnchor($value);
      print "		<LI><OBJECT type=\"text/sitemap\">\n";
		  print "					<param name=\"Name\" value=\"$i $value\">\n";
		  print "					<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				</OBJECT>\n";
			#print FTOC "<LI><a href='$chm.chm::$key'>$value</a></LI>\n";
			$i ++;
		}    
    print "		</UL>\n";
		#print FTOC "</UL>\n";
  }     
        
  ### 會 ###
  if (%saveHui > 0) {
    print "		<LI><OBJECT type=\"text/sitemap\">\n";
    print "					<param name=\"Name\" value=\"會\">\n";
    print "					<param name=\"ImageNumber\" value=\"1\">\n";
    print "				</OBJECT>\n";
    print "		<UL>\n";
        
    my $i=1;
    for $key (sort(keys(%saveHui))) {
      $value = $saveHui{$key};
      $value=filterAnchor($value);
      print "		　<LI><OBJECT type=\"text/sitemap\">\n";
		  print "			　		<param name=\"Name\" value=\"$i $value\">\n";
		  print "				　	<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				　</OBJECT>\n";
			$i ++;
		}    
		     
		if ($chm eq "BoRuo" and keys(%savePin2)>0) {
     print "		　<UL>\n";
     print "		　　<LI><OBJECT type=\"text/sitemap\">\n";
     print "			　　		<param name=\"Name\" value=\"品\">\n";
     print "				　　	<param name=\"ImageNumber\" value=\"1\">\n";
     print "				　　</OBJECT>\n";
     print "		　　<UL>\n";
     my $j=1;
     for $key1 (sort(keys(%savePin2))) {
       $value = $savePin2{$key1};
       $value=filterAnchor($value);
       print "		　　<LI><OBJECT type=\"text/sitemap\">\n";
		    print "				　	　<param name=\"Name\" value=\"$j $value\">\n";
		    print "					　　<param name=\"Local\" value=\"$chm.chm::$key1\">\n";
		    print "				　　</OBJECT>\n";
			  $j ++;
		  }  
     print "		　　</UL>\n";
     print "		　</UL>\n";
		}    
    print "		</UL>\n";
  }     
        
  ### 分 ###
  if (%saveFen > 0) {
    print "		<LI><OBJECT type=\"text/sitemap\">\n";
    print "					<param name=\"Name\" value=\"分\">\n";
    print "					<param name=\"ImageNumber\" value=\"1\">\n";
    print "				</OBJECT>\n";
    print "		<UL>\n";
        
    my $i=1;
    for $key (sort(keys(%saveFen))) {
      $value = $saveFen{$key};
      $value=filterAnchor($value);
      print "		<LI><OBJECT type=\"text/sitemap\">\n";
		  print "					<param name=\"Name\" value=\"$i $value\">\n";
		  print "					<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				</OBJECT>\n";
			$i ++;
		}    
    print "		</UL>\n";
  }     
        
  ### 一經多卷 ###
  my $i = keys(%saveJuan);
  if ($i>1) {
    print "		<LI><OBJECT type=\"text/sitemap\">\n";
    print "					<param name=\"Name\" value=\"卷\">\n";
    print "					<param name=\"ImageNumber\" value=\"1\">\n";
    print "				</OBJECT>\n";
    print "		<UL>\n";
	  #print FTOC "<P><A class=\"lix\" onClick=\"toggledisp('juan')\">卷</A><BR>\n";
	  #print FTOC "<UL id=\"juan\"  style=\"display:none\">\n";
        
    for $key (sort(keys(%saveJuan))) {
      $value = $saveJuan{$key};
      $value=filterAnchor($value);
      print "		<LI><OBJECT type=\"text/sitemap\">\n";
		  print "					<param name=\"Name\" value=\"$value\">\n";
		  print "					<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				</OBJECT>\n";
			#print FTOC "<LI><a href='$chm.chm::$key'>$value</a></LI>\n";
		}    
    print "		</UL>\n";
		#print FTOC "</UL>\n";
	}
        
  ### 其他 ###
  my $i = keys(%saveOther);
  if ($i > 1) {
    print "		<LI><OBJECT type=\"text/sitemap\">\n";
    print "					<param name=\"Name\" value=\"目錄\">\n";
    print "					<param name=\"ImageNumber\" value=\"1\">\n";
    print "				</OBJECT>\n";
    print "		<UL>\n";
  	#print FTOC "<P><A class=\"lix\" onClick=\"toggledisp('other')\">目錄</A><BR>\n";
  	#print FTOC "<UL id=\"other\"  style=\"display:none\">\n";
        
    my $i=1;
    for $key (sort(keys(%saveOther))) {
      $value = $saveOther{$key};
      $value=filterAnchor($value);
      print "		<LI><OBJECT type=\"text/sitemap\">\n";
        
      my $aa = quotemeta("（");
      my $bb = quotemeta("）");
      if ($value =~ /^$aa.*$bb$/) {
		    print "					<param name=\"Name\" value=\"$value\">\n";
		  } else {
		    print "					<param name=\"Name\" value=\"$i $value\">\n";
		  }  
		  print "					<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				</OBJECT>\n";
			#print FTOC "<LI><a href='$chm.chm::$key'>$value</a></LI>\n";
			$i++;
		}    
    print "		</UL>\n";
		#print FTOC "</UL>\n";
  } elsif ($i == 1) {
      my @keys = keys(%saveOther);
      $key = $keys[0];
      $value = $saveOther{$key};
      $value=filterAnchor($value);
      print "		<LI><OBJECT type=\"text/sitemap\">\n";
		  
		  # modified by Ray 2000/2/17 03:51PM
		  #print "					<param name=\"Name\" value=\"$sutraName\">\n";
		  print "					<param name=\"Name\" value=\"$value\">\n";
		  
		  print "					<param name=\"Local\" value=\"$chm.chm::$key\">\n";
		  print "				</OBJECT>\n";
  }
  
  print "	</UL>\n";
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
				print "<a href=\"${prevof}#start\" style='text-decoration:none'>▲</a>" if ($prevof ne "");
				print "<a href=\"${mof}#start\" style='text-decoration:none'>▼</a>";
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
       
				print OF "\n$text";
				$text = "";
				$prevof = $oldof;
				$oldof = $mof;
				$oldbof = $bof;
			}  
}       
        
#------------------------------------------------------------------------
# 一經目錄
sub printTocHead {
  my $cvol = $vol;
  $cvol =~ s/T//;
  $cvol = cNum($cvol);
        
  my $num = $sutraNum;
  $num =~ s/^0//;
  $num =~ s/^0//;
  $num =~ s/^0//;
        
print FTOC << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>  
<HEAD>  
<TITLE>${sutraName}--目錄</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta name="GENERATOR" content="PERL HTMLHelp.bat">
</HEAD><BODY>
<H2><IMG align="center" SRC="logo1.jpg"> 電子大藏經</H2>
<P>     
       
<HR>    
<H3>目錄  Contents</H3>
<TABLE border="1" cellpadding="2">
<THEAD> 
<TH COLSPAN="2">
XXX
}       
        
#------------------------------------------------------------------------
# 結束一經目錄
sub closeToc {
  my $nvol = $vol;
  $nvol =~ s/T//;
  $cvol = cNum($nvol);
  $nvol =~ s/^0//;
        
print FTOC << "XXX";
</TABLE>
<HR><UL>
<LI>大正新脩大藏經第${cvol}冊 $mtit
<LI>V${version} (Big5) HTMLHelp版，完成日期：$cfg{"CDATE"}
<LI>本資料庫由中華電子佛典協會（CBETA）依大正新脩大藏經所編輯
<LI>比對資料來源：$ly{"zh"}
<LI>本資料庫可自由免費流通，詳細內容請參考<A HREF="cbintr.htm">【中華電子佛典協會資料庫基本介紹】</A>
</UL>   
<UL>    
<LI> Taisho Tripitaka Vol. $nvol, $mtit</A>
<LI> V${version} (Big5) HTMLHelp, Release Date: $cfg{"EDATE"}
<LI> Distributor: Chinese Buddhist Electronic Texts Association (CBETA)
<LI> Source material obtained from: $ly{"en"}
<LI> Distributed free of charge. For details, please refer to <A HREF="cbintr_e.htm">The Brief Introduction of CBETA DATABASE</A>
</UL>   
        
XXX
}       
        
#-----------------------------------------------------------------------
### 全冊目錄 ###
sub openVTOC {
  #open (VTOC, ">" . $cfg{"OUTDIR"} . "\\HTMLHELP\\${vol}toc.htm");
  open (VTOC, ">" . $cfg{"OUTDIR"} . "\\${vol}Toc.hhc");
        
print VTOC << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>  
<HEAD>  
        
<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">
<!-- Sitemap 1.0 -->
</HEAD><BODY>
<OBJECT type="text/site properties">
	<param name="ImageType" value="Folder">
</OBJECT>
<UL>    
XXX
}       
        
        
#-----------------------------------------------------------------------
### 全冊經文 ###
sub openOF {
  my $of1 = getof();
  if ($of1 eq $saveof) { return; }
  if ($saveof ne "") { close OF; }
  $saveof = $of1;
  open (OF, ">" . $cfg{"OUTDIR"} . "\\$of1");
  print STDERR "\n-> " . $cfg{"OUTDIR"} . "\\$of1\n";
  select(OF);
print << "XXX";
<html>  
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<style>\@import url(cbeta.css);</style>
<link disabled rel="stylesheet" href="cbeta.css">
<script LANGUAGE="JAVASCRIPT" SRC="search.js">
</script>
<TITLE>CBETA 電子佛典</TITLE>
</head> 
XXX
  print "<BODY id='$vol'>\n";
}       
        
#-----------------------------------------------------------------------
### HTML Help Project ###
sub openHHP {
  my $oldFile = select();
  my $num = substr($vol,1,2);
  $num = cNum($num);  # cNum() is in sub.pl
  open (HHP, ">" . $cfg{"OUTDIR"} . "\\${vol}.hhp");
  select(HHP);
print << "XXX";
[OPTIONS]
Binary TOC=Yes
Compatibility=1.1 or later
Compiled file=$chm.chm
Contents file=${vol}Toc.hhc
Default Window=CAN
Default topic=$vol.htm
Display compile progress=Yes
Full-text search=Yes
Language=0x404 Chinese (Taiwan)
Title=部
        
[WINDOWS]
CAN="部","$chm.hhc","Edit5.htm","Edit5.htm",,,,,0x23420,211,0x304e,,,,,1,,,0
        
        
[FILES] 
Edit5.htm
cbintr.htm
cbintr_e.htm
logo1.jpg
dialog.htm
dialog1.htm
${vol}.htm
XXX
  select ($oldFile);
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
  if ($text eq "") { return; }
  $text =~ s/\xa1\x40$//;
	$text =~ s/\xa1\x40\)$/)/;
	$text =~ s/\[[0-9（[0-9珠\]//g;
	$text =~ s/#[0-9][0-9]#//g;
	print "$text";
	if (@lines > 1) { shift @lines; }
	push @lines, $text;
	$text = "";
}       

sub myDecode {
  my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}

# created by Ray 2000/2/18 09:08AM
# 過濾缺字的連結標記
sub filterAnchor {
  my $s = shift;
  $s =~ s/^(.*)<a.*>(.*)<\/a>(.*)$/\1\2\3/;
  return $s;
}


        
__END__ 
:endofperl
