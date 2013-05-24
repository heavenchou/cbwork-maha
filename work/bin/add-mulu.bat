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
$inputFile = shift;

$vol = uc($vol);
$dir = "j:/bsin/cbeta/old-xml/";
$vol = substr($vol,0,3);

opendir (INDIR, $dir . $vol);
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

#big5 pattern
  $big5zi = "[\xa1-\xfe][\x40-\xfe]";

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "utf8b5o.plx";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '◎';

use XML::Parser;

my $begin=0;
my $inHead=0;
my $inJHead=0;
my %Entities = ();
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

my %typeName = (
  "jing" => "經",
  "hui" => "會",
  "fen" => "分",
  "xu" => "序",
  "pin" => "品",
  "other" => "其他"
);
        
my $parser = new XML::Parser(NoExpand => True);
        
        
$parser->setHandlers
				(Start => \&start_handler,
				Init => \&init_handler,
				End => \&end_handler,
		     	Char  => \&char_handler,
		     	Entity => \&entity,
		     	Default => \&default);
        
open M, ">j:/bsin/cbeta/new-xml/$vol/temp.txt";
if ($inputFile eq "") {
  for $file (sort(@allfiles)) { process1file($file); }
} else {
  $file = $inputFile;
  process1file($file);
}       
close M;
        
print STDERR "完成!!\n";
        
sub process1file {
  $file = shift;
  $file =~ s/^t/T/;
	print STDERR "\n$file\n";
	print M "$file\n";
  open O, ">j:/bsin/cbeta/$vol/$file";
	$parser->parsefile($dir . $vol . "/" . $file);
	close O;
}

#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
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
		  elsif ( $val=~/des=\'(.+?)\'/ ) { $val = $1; } 
		  else { $val=$ent; } # 最後用 CB 碼
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
    my $normal = $string;

	my $parent = lc($p->current_element);

  $string =~ s/^&(.+);$/$1/;
	if ( defined($Entities{$string}) ) { 
	  $normal = $Entities{$string};
	  $string = "&$string;"; 
	}
	if ($parent eq "head" or $parent eq "jhead") { 
	  $headText .= $normal;
	  $text .= $string;
	}
	elsif ($begin) { 
	  if ($inHead or $inJHead) { $text .= $string; }
	  else { print O $string; }
	}
}       
        
sub init_handler
{       
  my $s = $file;
  $s =~ s/\.xml/\.ent/;
	print O <<"EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd"
[<!ENTITY % ENTY  SYSTEM "$s" >
<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
%ENTY;
%CBENT;
]>
EOD
  %numberOfDiv=();
  $begin=0;
}
        
        
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);

  if ($el eq "tei.2") { $begin=1; }
  
  if ($el =~ /div(.*)/) {
    my $level = $1;
    my $t = $att{"type"};
    $t = $typeName{$t};
    $typeOfDiv{$level} = $t;
    if ($t ne "序") {
      if (defined($numberOfDiv{$level})) { $numberOfDiv{$level} ++; }
      else { $numberOfDiv{$level} = 1; }
    }

    if ($el eq "div1") {
      $numberOfDiv{"2"} = 0;
      $numberOfDiv{"3"} = 0;
    } elsif ($el eq "div2") { $numberOfDiv{"3"} = 0; }
  } elsif ($el eq "head") {
    $inHead = 1;
	  $text = "<head";
    for $key (sort(keys(%att))) {
      $value = $att{$key};
      $value = myDecode($value);
      $text .= " $key=\"$value\"";
    }
    $text .= ">";
  } elsif ($el eq "jhead") {
    $inJHead = 1;
	  $text = "<jhead";
    for $key (sort(keys(%att))) {
      $value = $att{$key};
      $value = myDecode($value);
      $text .= " $key=\"$value\"";
    }
    $text .= ">";
  } elsif ($el eq "juan") {
    $numberOfJuan = $att{"n"};
    $juanFun = $att{"fun"};
  }
  
  my $buf="";
  if ($el ne "head" and $el ne "jhead") {
    $buf = "<$el";
    for $key (sort(keys(%att))) {
      $value = $att{$key};
      $value = myDecode($value);
      $buf .= " $key=\"$value\"";
    }
    if ($el eq "lb" or $el eq "pb") { $buf .= "/"; }
    $buf .= ">";
  }
  
  if ($inHead or $inJHead) { $text .= $buf; }
  else { print O $buf; }
}
        
sub rep{
	local($x) = $_[0];
	return $x;
}       
        
        
sub end_handler 
{       
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	pop @elements;
	my $parent = lc($p->current_element);
	
	if ($el eq "head") {
	  if ($parent =~ /div(.*)/ and $headText ne "") {
	    my $level = $1;
	    print STDERR "level=$level\n";
	    print M "level=$level\n";
	    my $n = $numberOfDiv{$level};

	    my $t = $typeOfDiv{$level};
      my $label = myReplace($headText);

	    print O "<mulu type=\"$t\" level=\"$level\"";
	    if ($t ne "序") { print O " n=\"$n\""; }
	    print O " label=\"$label\"/>";
	  }
    print O "$text</head>";
    $headText = '';
    $inHead=0;
	} elsif ($el eq "jhead") {
	  if ($juanFun eq "open") {
	    print O "<mulu type=\"卷\" n=\"$numberOfJuan\"/>";
	  }
    print O "$text</jhead>";
    $headText = '';
    $inJHead=0;
	} elsif ($el ne "lb" and $el ne "pb") { 
	  if ($inHead or $inJHead) { $text .= "</$el>"; }
	  else { print O "</$el>"; }
	}
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	$char =~ s/($pattern)/$utf8out{$1}/g;

  # 跳過 <lem>, <term>, <corr> 找 parent
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

  if ($parent eq "head" or $parent eq "jhead") { 
      $headText .= $char; 
      $text .= $char;
  }	else { 
    if ($inHead or $inJHead) { $text .= $char; }
    else { print O $char; }
  }
}       
        

sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
	return 1;
}       
        
        
sub myDecode {
  my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}

sub myEnt {
	local($s) = $_[0];
  if (defined($Entities{$s})) { return $Entities{$s}; }
  return $s;
}

sub myReplace {
  my $s = shift;
  my @type = ("品","分","會","經","\xa6\x61","章","緣起");
	$s =~ s/\[\d\d\]//g;
	$s =~ s/\[[0-9（[0-9珠\]//g;
	$s =~ s/#[0-9][0-9]#//g;
	$s =~ s/\n//g;
  $s =~ s/\&(.+);/&myEnt($1)/eg;
  $s =~ s/(?:$big5zi|[0-9])*?(◎)(?:$big5zi|[0-9])*?//;

  print M "[$s]\n";
  print STDERR "[$s]\n";
  
	$s =~ s/^（.+）第.+分(.+經第.+)$/$1/;
	# "（" = \xa1\x5d, "）" = \xa1\x5e
	$s =~ s/^\xa1\x5d.+\xa1\x5e第.+分(.+經第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e第.+分.+經(.+品第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(.+品第.+)$/$1/;
	$s =~ s/^第.+分.+經(.+品第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e第.+分(.+經)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(.+經第.+)$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(第.+分)初$/$1/;
	$s =~ s/^\xa1\x5d.+\xa1\x5e(第.+分)$/$1/;
	$s =~ s/^初分(.+品第.+)$/$1/;
	$s =~ s/^第.+分(.+品第.+)$/$1/;
	$s =~ s/^第.+分(.+品第.+)$/$1/;
	$s =~ s/^.+\xb7\x7c第.+之(一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+(.+品第.+)$/$2/;  # \xb7\x7c 會
	$s =~ s/^.+\xb7\x7c第(一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+(.+品第.+)$/$2/;  # \xb7\x7c 會
	$s =~ s/^.+\xb7\x7c(.+品第.+)$/$1/;  # \xb7\x7c 會
	$s =~ s/^.+分第(一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+(.+品第.+)$/$2/;  # \xb7\x7c 會
	if ($s !~ /分別/) { $s =~ s/^.+分(.+品第.+)$/$1/; }
	$s =~ s/^.+經(.+品第.+)$/$1/;
	$s =~ s/^(.+第.+)之.+$/$1/;


  foreach $type (@type) {
	  $type = quotemeta($type);
	  if ($s =~ /^第(.+)$type$/) {
	    my $a = cn2an($1);
	    if ($a ne "") { $s = "$a $s"; }
	  }
	}

  if ($s !~ /^\d+ /) {
    if ($s =~ /^(.+)第((一|二|三|\xa5\x7c|五|六|七|八|九|十|百)+)(之)*.*$/) {
	    $s = $1;
	    $a = cn2an($2);
	    if ($a ne "") { $s = "$a $s"; }
	  }
	}

	if ($s =~ /^\xa1\x5d(.+)\xa1\x5e(.*)$/) {
	  $s = $2;
	  my $a = cn2an($1);
	  if ($a ne "" and $s ne "") { $s = " $s"; }
	  $s = $a . $s;
	}

	print M "[$s]\n\n";
	print STDERR "[$s]\n\n";
	return $s;
}

        
__END__ 
:endofperl
