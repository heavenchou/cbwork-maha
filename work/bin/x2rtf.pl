# ------------------------------------
# x2rtf.pl
# Transfer XML format to RTF format
# Written by Ray 2000/12/18
# ------------------------------------

open O, ">c:/cbwork/err.txt";
close O;

print STDERR "x2rtf\n";
use Getopt::Std;
getopts('v:e:n:i:o:sdtu:z');

if ($opt_v eq '' and $opt_n eq '') {
	print <<EOD;
 -v 冊數
 -n 經號 例：perl x2rtf.pl -n T01n0001.xml
 -e output encoding
 -i input directory
 -o output directory
 -s 精簡版
 -d 以經為目錄單位, 目錄名稱使用中文長檔名
 -t 產生標記 如 <p>, <lb>, <gaiji> 等
 -x 缺字不使用Unicode
 -z 缺字不使用通用字
 -y 缺字不使用 Mojikyo TTF
 -m 缺字使用M碼
EOD
	exit;
}

require "sub.pl";

$vol = $opt_v;
$inputFile='';
if ($opt_n ne '') {
	$inputFile = $opt_n;
	$vol = substr($inputFile,0,3);
}

$vol = uc($vol);
$vol = substr($vol,0,3);
$cVol = "第" . cNum(substr($vol,1,2)) . "冊";

print STDERR "Vol: $vol\n";
# configuration
if ($opt_o ne '') {
	$dir = "$opt_o/doc/$vol";
} else {
	$dir = "c:/Release/Doc/$vol";
}

if ($opt_i ne '') {
	$sourcePath = $opt_i;
} else {
	$sourcePath = "c:/cbwork/xml";
}

$sourcePath .= "/$vol";
opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

mkdir("c:/Release", MODE);
mkdir("c:/Release/Doc", MODE);
mkdir($dir, MODE);

#utf8 pattern
$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

require "utf8b5o.plx";
$utf8out{"\xe2\x97\x8e"} = '';

$newPar = '\par\pard\plain \s21\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ' . "\n";

%mFont = (
"Mojikyo M101","f39",
"Mojikyo M102","f40",
"Mojikyo M103","f41",
"Mojikyo M104","f42",
"Mojikyo M105","f43",
"Mojikyo M106","f44",
"Mojikyo M107","f45",
"Mojikyo M108","f46",
"Mojikyo M109","f47",
"Mojikyo M110","f48",
"Mojikyo M111","f49",
"Mojikyo M112","f50",
"Mojikyo M113","f51",
"Mojikyo M114","f52",
"Mojikyo M115","f53",
"Mojikyo M116","f54",
"Mojikyo M117","f55",
"Mojikyo M118","f56",
"Mojikyo M119","f57",
"Mojikyo M120","f58",
"Mojikyo M121","f59",
"Mojikyo M181","f60",
"Mojikyo M182","f61",
"Mojikyo M183","f62"
);


my %dia = (
	"Amacron", "256",
	"amacron", "257",
	"ddotblw", "7693",
	"Ddotblw", "7692",  
	"hdotblw", "7717",  
	"imacron", "299",
	"ldotblw", "7735",
	"Ldotblw", "7734",  
	"mdotabv", "7745",  
	"mdotblw", "7747",  
	"ndotabv", "7749",  
	"ndotblw", "7751",  
	"Ndotblw", "7750",  
	"ntilde ", "tilde",
	"rdotblw", "7771",
	"sacute ", "347", 
	"Sacute ", "346",  
	"sdotblw", "7779",
	"Sdotblw", "7778", 
	"tdotblw", "7789",
	"Tdotblw", "7788",
	"umacron", "363",
);

local $no_nor;

use XML::Parser;
my $parser = new XML::Parser(NoExpand => True);

$parser->setHandlers(
	Start => \&start_handler,
	Init => \&init_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default);

if ($inputFile eq "") {
	for $file (sort(@allfiles)) { do1file("$sourcePath/$file"); }
} else {
	$file = $inputFile;
	do1file("$sourcePath/$file");
}
unlink "c:/cbwork/err.txt";


sub do1file {
	my $file = shift;

	$file =~ s/t(\d{2}n\d{4})([A-Za-z])?/T$1$2/;
	$file =~ /T\d\dn(\d{4}[A-Za-z]?)/;
	$sutraNum = $1;
	
	$shortSutraNum = $sutraNum;
	$shortSutraNum =~ s/^0+//g;
	
	$outPath = $dir;
	mkdir($outPath, MODE);
	
	openDoc();
	$parser->parsefile($file);

	printBuffer();
	print "\n}";
	close;
}

sub init_handler {
	$pass=1;
	$in_list=0;
	$lang='';
	$text='';
	$text2='';
	$text2_dirty = 0;
	$text_ref = \$text;
	@no_nor=();
	@pass=();
}

# 遇到 entity reference 時被呼叫
sub default {
	my $p = shift;
	my $s = shift;
	my $parent = lc($p->current_element);
	
	if ($pass) { return; }

	$s =~ s/&(.*);/$1/;
	my $ent = $s;
	if (exists $dia{$ent}) {
		$$text_ref .= '{\f27 \uc1\u' . $dia{$ent} . "\\'3f}";
		return;
	}
	
	if (exists $cbeta_ent{$ent}) {
		$$text_ref .= $cbeta_ent{$ent};
		return;
	}
	
	if (exists $jap_ent{$ent}) {
		$s = $jap_ent{$ent};
		$s =~ /uni=\'(.*?)\'/;
		$$text_ref .= '{\uc1\u' . hex($1) . "\\'3f}";
		return;
	}
	
	$s = $Entities{$s};
	if (not $inHeader) {
		if ($s=~/gaiji/) {
			if ($ent =~ /^SD/) {
				$s =~ /(cb=\'.*?\')/;
				if ($opt_t) {
					$$text_ref .= '{\cs38\v\chshdng0\chcfpat0\chcbpat7 ';
					$$text_ref .= "<gaiji $1>}";
				}
				if ($s =~ /big5=\'(.*?)\'/) { $$text_ref .= $1; }
				else { die "\n Error 365"; }
				if ($opt_t) {
					$$text_ref .= '{\cs38\v\chshdng0\chcfpat0\chcbpat7 </gaiji>}';
				}
			} else {
				$s=~s#/>$#>#;
				if ($opt_t) {
					$$text_ref .= '{\cs38\v\chshdng0\chcfpat0\chcbpat7 ' . $s . '}';
					#print STDERR "$$text_ref\n";
					#getc;
				}
				if (not $opt_x and $s =~ /uni=\'(.*?)\'/) {
					$$text_ref .= '{\uc1\u' . hex($1) . "\\'3f}";
				} elsif (not $opt_z and not $no_nor and $s =~ /nor=\'(.*?)\'/) {
					$$text_ref .= $1;
				} else {
					my $got=0;
					if (not $opt_y and $s =~ /mofont=\'(.+?)\'/ and $1 ne '') {
						my $f = $mFont{$1};
						if ($f ne '') {
							$$text_ref .= "{\\loch\\a$f\\hich\\a$f\\dbch\\$f";
							$s =~ /mochar=\'(.*?)\'/;
							$$text_ref .= '{\uc1\u' . hex($1) . "\\'3f}";
							$$text_ref .= "}";
							$got=1;
						}
					}
					
					if (not $got and $opt_m and $s =~ /mojikyo=\'(.*?)\'/) {
						$$text_ref .= $1;
						$got=1;
					}
					
					if (not $got and $s =~ /des=\'(.*?)\'/) {
						$$text_ref .= $1;
					}
				}
				if ($opt_t) {
					$$text_ref .= '{\cs38\v\chshdng0\chcfpat0\chcbpat7 </gaiji>}';
				}
			}
		} else {
			$$text_ref .= $s;
		}
	}
}

sub start_handler 
{       
	my $p = shift;
	local $el = shift;
	my (%att) = @_;
	my $parent = $p->current_element;
	
	push @saveatt , { %att };
	
	push @no_nor, $no_nor;
	if ($att{"rend"} eq "no_nor") { $no_nor=1; }

	push @lang, $lang;
	if ($att{"lang"} ne '') { 
		$lang = $att{"lang"};
	}

	# added by Ray 2001/6/28
	local $rend = '';
	if (defined($att{"rend"})) { 
		$rend = parseRend($att{"rend"}); 
		$att{"rend"} = $rend;
	}

	### <bibl>
	if ($el eq "bibl") {
		if ($inHeader) { $text =''; }
	}
	
	### <body>
	if ($el eq "body") {
		$pass=0;
		$text='';
		$text2='';
	}
	
	### <byline>
	if ($el eq "byline") {
		$$text_ref .= '\par\pard\plain \s22\ql \li2268\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin2268\itap0 \fs24\cf18\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ';
		$$text_ref .= "\n";
		$$text_ref .= '\loch\af0\hich\af0\dbch\f18 ';
	}

	### <cell> ###
	# added by Ray 2001/6/18
	if ($el eq "cell"){
		if ($pass==0) {
			if (not defined($att{"rend"}) and $text !~ /(║|　|。|）|#Ｐ#)$/) { 
				$rend="　"; 
			}
			$$text_ref .= $rend;
		}
	}

	### <corr>
	if ($el eq "corr") {
		$CorrCert = lc($att{"cert"});
		if ($CorrCert ne "" and $CorrCert ne "100") {
			my $sic = lc($att{"sic"});
			$sic =~ s/($pattern)/$utf8out{$1}/g;
			$$text_ref .= $sic;
		} else {
			$$text_ref .= '{\cs29\cf6';
		}
	}
		
	# <date>
	if ($el eq "date") {
		if ($parent eq "publicationStmt") {
			$text = '';
		}
	}

	### <distributor>
	if ($el eq "distributor") {
		if ($inHeader) { $text =''; }
	}
	
	### <edition>
	if ($el eq "edition") {
		if ($inHeader) { $text =''; }
	}
	
	### <figure>
	if ($el eq "figure") {
		$$text_ref .= "【圖】";
	}
	
	### <gaiji>
	if ($el eq "gaiji") {
		if (exists($att{"uni"})) {
			print STDERR "##";
			$$text_ref .= '{\uc1\u' . hex($att{"uni"}) . '}';
		}
	}

	### <gloss>
	if ($el eq "gloss") {
		$pass++;
	}
	
	### <head>
	if ($el eq "head") {
		push @pass,$pass;
		my $parent = lc($p->current_element);
		if ($att{"type"} eq "added") {
			$pass++;
		}
		if ($att{"type"} ne "added") {
			if ($parent =~ /div(\d+)/) {
				$$text_ref .= '{\par }' . "\n";
				$$text_ref .= '\pard\plain \s50\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\outlinelevel3\adjustright\rin0\lin0\itap0 \fs24\cf18\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ' . "\n";
			}
			$$text_ref .= '\loch\af0\hich\af0\dbch\f18 ';
		}
	}
	
	
	### <item>
	if ($el eq "item") {
		if (not defined($att{"rend"})) { 
			$rend = "　";
		} else {
			$rend = $att{"rend"};
			$rend =~ s/($pattern)/$utf8out{$1}/g;
		}
		$$text_ref .= $rend;
		if (defined($att{"n"})) {
			my $n = $att{"n"};
			$n =~ s/($pattern)/$utf8out{$1}/g;
			if ($curLang eq "sk-sd") {
				$$text_ref .= '{\loch\af0\hich\af0\dbch\f18 ' . $n . '}';
			} else {
				$$text_ref .= $n;
			}
		}
		if ($att{"lang"} eq "sk-sd") { $$text_ref .= '{\dbch\af138 \loch\af0\hich\af0\dbch\f138 '; }
	}
	
	### <juan>
	if ($el eq "juan") {
		$$text_ref .= $newPar . '\loch\af0\hich\af0\dbch\f18 ';
	}
	
	### <l>
	if ($el eq "l") {
		if ($lgType ne "inline" and $lgRend ne "inline") {
			$$text_ref .= '{\tab }';
		}
		$$text_ref .= '\loch\af0\hich\af0\dbch\f18 ';
	}
	
	### <lb>
	if ($el eq "lb") {
		$lb = $att{"n"};
		if ($pass==0) {
			if ($in_list) {
				print '{\line }';
			}
			printBuffer($lb);
		}
	}
	
	### <lg>
	if ($el eq "lg") {
		$lgType = $att{"type"};
		$lgRend = $att{"rend"};
		$$text_ref .= '\par\pard\plain \s32\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\tqc\tx1208\tqc\tx3617\tqc\tx6022\tqc\tx8431\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ' . "\n";
	}
	
	### <list>
	if ($el eq "list") {
		push @curLang, $curLang;
		if ($pass==0) {
			$$text_ref .= '\par\pard\plain \s21\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ' . "\n";
			if ($att{"lang"} eq "sk-sd") { 
				$curLang = "sk-sd";
				$$text_ref .= '{\dbch\af138 \loch\af0\hich\af0\dbch\f138 '; 
			} else { 
				$$text_ref .= '\loch\af0\hich\af0\dbch\f18 '; 
			}
		}
		$in_list = 1;
	}
	
	### <milestone>
	if ($el eq "milestone") {
		$rend = $att{"rend"};
		$rend =~ s/($pattern)/$utf8out{$1}/g;
		$$text_ref .= $rend;
	}
	
	### <note>
	if ($el eq "note") {
		push @pass,$pass;
		# CBETA 加的 note 不顯示
		if ($att{"resp"} =~ /^CBETA/ or $att{"type"} eq "sk" or $att{"type"} eq "foot" or $att{"place"} eq "foot") {
			$pass++;
		}
		if ($pass==0) {
			$$text_ref .= '{\cs33\f27\fs20 \hich\af27\dbch\af18\loch\f27 (}' . "\n";
			$$text_ref .= '{\cs33\f27\fs20 \loch\af27\hich\af27\dbch\f';
			if ($lang eq "sk-sd") { 
				$$text_ref .= '138 '; 
			} else { 
				$$text_ref .= '18 '; 
			}
		}
	}

	### <p>
	if ($el eq "p") {
		if ($inHeader) {
			$text = '';
		} elsif ($pass==0) {
			$$text_ref .= $newPar;
			if ($opt_t) {
				$$text_ref .= '{\cs38\v\chshdng0\chcfpat0\chcbpat7 \hich\af0\dbch\af18\loch\f0 <p loc="}' . "\n";
			}
			
			$$text_ref .= '{\cs28\cf2 \hich\af0\dbch\af18\loch\f0 [';
			$$text_ref .= $lb;
			$$text_ref .= "]}\n";
			
			if ($opt_t) {
				$$text_ref .= '{\cs38\v\chshdng0\chcfpat0\chcbpat7 \hich\af0\dbch\af18\loch\f0 ">}' . "\n";
			}
			if ($att{"lang"} eq "sk-sd") { $$text_ref .= '{\dbch\af138 \loch\af0\hich\af0\dbch\f138 '; }
			else { $$text_ref .= '\loch\af0\hich\af0\dbch\f18 '; }
		}
	}

	### <rdg>
	if ($el eq "rdg") { $pass++ ; }

	### <sg>
	if ($el eq "sg") {
		$$text_ref .= '{\cs33\f27\fs20 \hich\af27\dbch\af18\loch\f27 (}' . "\n";
		$$text_ref .= '{\cs33\f27\fs20 \loch\af27\hich\af27\dbch\f18 ';
	}
	
	### <t>
	if ($el eq "t") {
		$count_t ++;
		if ($twoLineMode and $count_t > 1) {
			$text2_dirty = 1;
			$text_ref = \$text2;
		} else {
			$text_ref = \$text;
		}
		if ($tt_rend ne "inline" and $$text_ref !~ /║$/ and $$text_ref ne '') {
			$$text_ref .= "　";
		}
		if ($lang eq "sk-sd") { 
			$$text_ref .= '{\dbch\af138 \loch\af0\hich\af0\dbch\f138 '; 
		}
	}
	
	### <teiHeader>
	if ($el eq "teiHeader") { 
		$inHeader=1;
	}
	
	### <term>
	if ($el eq "term") {
		if ($att{"lang"} eq "sk-sd") { $$text_ref .= '{\dbch\af138 \loch\af0\hich\af0\dbch\f138 '; }
	}
	
	### <title>
	if ($el eq "title") {
		if ($inHeader) { $text =''; }
	}
	
	### <tt> ###
	if ($el eq "tt") {
		$tt_rend = $att{"rend"};
		if ($tt_rend ne "inline" and $att{"type"} ne "inline") {
			$twoLineMode = 1;
			$count_t = 0;
		}
	}
}

sub end_handler {
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	my $parent = $p->current_element;

	### </bibl>
	if ($el eq "bibl") { 
		if ($inHeader) {
			$bibl = $text;
		}
	}
	
	### </corr>
	if ($el eq "corr") { 
		if ($CorrCert eq "" or $CorrCert eq "100") {
			$$text_ref .= '}';
		}
	}
	
	# </date>
	if ($el eq "date") {
		if ($parent eq "publicationStmt") {
			$date = $text;
			$date =~ s#^.*(..../../..).*$#$1#;
			print STDERR "480 $date\n";
		}
	}
	
	### </distributor>
	if ($el eq "distributor") { 
		if ($inHeader) {
			$distributor = $text;
		}
	}
	
	### </edition>
	if ($el eq "edition") { 
		if ($inHeader) {
			$edition = $text;
			$version =~ /\b(\d+\.\d+)\b/;
			$version = $1;
		}
	}
	
	### </gloss>
	if ($el eq "gloss") {
		$pass--;
	}
	
	### </head>
	if ($el eq "head") {
		$pass = pop(@pass);
	}
	
	### </item>
	if ($el eq "item") {
		if ($att->{"lang"} eq "sk-sd") { $$text_ref .= '}'; }
	}

	### </list>
	if ($el eq "list") {
		if ($att->{"lang"} eq "sk-sd") { $$text_ref .= '}'; }
		$in_list=0;
		$curLang = pop(@curLang);
	}
	
	### </note>
	if ($el eq "note") {
		if ($pass==0) { 
			$$text_ref .= "}\n";
			$$text_ref .= '{\cs33\f27\fs20 \hich\af27\dbch\af18\loch\f27 )}' . "\n";
		}
		$pass = pop(@pass);
	}
	
	### </p>
	if ($el eq "p") { 
		if ($inHeader and $att->{"lang"} eq "zh") {
			$projectDesc = $text;
		}
		if ($att->{"lang"} eq "sk-sd") { $$text_ref .= '}'; }
	}
	
	### </rdg>
	if ($el eq "rdg") { $pass-- ; }

	### </row>
	if ($el eq "row") { 
		if ($pass==0) {
			$$text_ref .= '{\line }';
		}
	}
	
	### </sg>
	if ($el eq "sg") { 
		$$text_ref .= "}\n";
		$$text_ref .= '{\cs33\f27\fs20 \hich\af27\dbch\af18\loch\f27 )}' . "\n";
	}

	### </t>
	if ($el eq "t") {
		if ($att->{"lang"} eq "sk-sd") { 
			$$text_ref .= '}'; 
			
		}
	}
	
	### </teiHeader>
	if ($el eq "teiHeader") { 
		$inHeader=0;
		printHeader();
	}
	
	### </term>
	if ($el eq "term") {
		if ($att->{"lang"} eq "sk-sd") { $$text_ref .= '}'; }
	}
	
	### </title>
	if ($el eq "title") {  
		if ($inHeader) {
			$text =~ / (\S*)$/;
			$sutraName = $1;
		}
	}
	
	# </tt>
	if ($el eq "tt"){
		$twoLineMode = 0;
		$text_ref = \$text;
	}
	
	$no_nor = pop(@no_nor);
	$lang = pop(@lang);
}

sub char_handler {
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);

	if ($parent =~ /address|distributor/) {
		return;
	}
	
	# 不是 100% 的勘誤不使用
	if ($parent eq "corr" and $CorrCert ne "" and $CorrCert ne "100") { return; }
	
	my $big5 = '[\x00-\x7f]|[\x80-\xff].';
	$char =~ s/($pattern)/$utf8out{$1}/g;
	
	if ($parent eq "edition") { $version .= $char; }
	
	if ($inHeader) {
		$text .= $char;
	} elsif ($pass==0) {
		while ($char =~ /^(($big5)*?)。/) {
			$char =~ s/^(($big5)*?)。/$1\{\\cs45 \\'a1\\'43\}/;
		}
		$$text_ref .= $char;
	}
}


sub openDoc {
	close OF;
	
	my $file = "${vol}n$sutraNum.rtf";
	$file = ">$outPath/$file";
	print STDERR "open $file...\n";
	open OF, $file;
	select OF;
	print '{\rtf1\ansi\ansicpg950\uc2 \deff0\deflang1033\deflangfe1028';
}

sub entity {
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $file = shift;
	my $ent, $val;
	if ($file =~ /\.gif/) { return; }
	$file = "$sourcePath/$file";
	#print STDERR "708 open $file\n"; getc;
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chomp;
		/<!ENTITY\s+(\S+)\s+"(.*)"\s*>/;
		$ent = $1;
		$val = $2;
		if ($file =~ /cbeta\.ent$/) {
			$cbeta_ent{$ent} = $val;
			#print STDERR "716 $ent $val\n";
		} elsif ($file =~ /jap\.ent$/) {
			$jap_ent{$ent} = $val;
		} else {
			$Entities{$ent} = $val;
		}
	}
}

sub rep{
	local($x) = $_[0];
	if (defined($Entities{$x})) { return $Entities{$x} ; }
	else { die "Unknkown entity $x!!\n"; }
}

sub printHeader {
print <<'HEADER';
{\fonttbl
{\f0\froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;}
{\f2\fmodern\fcharset0\fprq1{\*\panose 02070309020205020404}Courier New;}
{\f18\froman\fcharset136\fprq2{\*\panose 02020300000000000000}\'b7\'73\'b2\'d3\'a9\'fa\'c5\'e9{\*\falt PMingLiU};}
{\f24\froman\fcharset129\fprq1{\*\panose 00000000000000000000}Gulim{\*\falt ??};}
{\f27\fnil\fcharset0\fprq2{\*\panose 02000503080000020003}Indic Times;}
{\f28\fswiss\fcharset136\fprq2{\*\panose 020b0604020202020204}Arial Unicode MS;}
{\f29\froman\fcharset136\fprq2{\*\panose 02020300000000000000}@\'b7\'73\'b2\'d3\'a9\'fa\'c5\'e9;}
{\f30\fswiss\fcharset136\fprq2{\*\panose 00000000000000000000}@Arial Unicode MS;}
{\f39\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M101{\*\falt MS Mincho};}
{\f40\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M102{\*\falt MS Mincho};}
{\f41\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M103{\*\falt MS Mincho};}
{\f42\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M104{\*\falt MS Mincho};}
{\f43\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M105{\*\falt MS Mincho};}
{\f44\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M106{\*\falt MS Mincho};}
{\f45\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M107{\*\falt MS Mincho};}
{\f46\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M108{\*\falt MS Mincho};}
{\f47\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M109{\*\falt MS Mincho};}
{\f48\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M110{\*\falt MS Mincho};}
{\f49\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M111{\*\falt MS Mincho};}
{\f50\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M112{\*\falt MS Mincho};}
{\f51\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M113{\*\falt MS Mincho};}
{\f52\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M114{\*\falt MS Mincho};}
{\f53\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M115{\*\falt MS Mincho};}
{\f54\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M116{\*\falt MS Mincho};}
{\f55\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M117{\*\falt MS Mincho};}
{\f56\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M118{\*\falt MS Mincho};}
{\f57\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M119{\*\falt MS Mincho};}
{\f58\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M120{\*\falt MS Mincho};}
{\f59\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M121{\*\falt MS Mincho};}
{\f60\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M181{\*\falt MS Mincho};}
{\f61\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M182{\*\falt MS Mincho};}
{\f62\fnil\fcharset128\fprq1{\*\panose 02000609000000000000}Mojikyo M183{\*\falt MS Mincho};}
{\f138\fmodern\fcharset136\fprq1{\*\panose 02010609000101010101}siddam;}
{\f199\froman\fcharset238\fprq2 Times New Roman CE;}
{\f200\froman\fcharset204\fprq2 Times New Roman Cyr;}
{\f202\froman\fcharset161\fprq2 Times New Roman Greek;}
{\f203\froman\fcharset162\fprq2 Times New Roman Tur;}
{\f204\froman\fcharset177\fprq2 Times New Roman (Hebrew);}
{\f205\froman\fcharset178\fprq2 Times New Roman (Arabic);}
{\f206\froman\fcharset186\fprq2 Times New Roman Baltic;}
{\f215\fmodern\fcharset238\fprq1 Courier New CE;}
{\f216\fmodern\fcharset204\fprq1 Courier New Cyr;}
{\f218\fmodern\fcharset161\fprq1 Courier New Greek;}
{\f219\fmodern\fcharset162\fprq1 Courier New Tur;}
{\f220\fmodern\fcharset177\fprq1 Courier New (Hebrew);}
{\f221\fmodern\fcharset178\fprq1 Courier New (Arabic);}
{\f222\fmodern\fcharset186\fprq1 Courier New Baltic;}
{\f345\froman\fcharset0\fprq2 PMingLiU Western{\*\falt PMingLiU};}
{\f425\fswiss\fcharset0\fprq2 Arial Unicode MS Western;}
{\f423\fswiss\fcharset238\fprq2 Arial Unicode MS CE;}
{\f424\fswiss\fcharset204\fprq2 Arial Unicode MS Cyr;}
{\f426\fswiss\fcharset161\fprq2 Arial Unicode MS Greek;}
{\f427\fswiss\fcharset162\fprq2 Arial Unicode MS Tur;}
{\f428\fswiss\fcharset177\fprq2 Arial Unicode MS (Hebrew);}
{\f429\fswiss\fcharset178\fprq2 Arial Unicode MS (Arabic);}
{\f430\fswiss\fcharset186\fprq2 Arial Unicode MS Baltic;}
{\f433\froman\fcharset0\fprq2 @\'b7\'73\'b2\'d3\'a9\'fa\'c5\'e9 Western;}
}

{\colortbl;
\red0\green0\blue0;
\red0\green0\blue255;
\red0\green255\blue255;
\red0\green255\blue0;
\red255\green0\blue255;
\red255\green0\blue0;
\red255\green255\blue0;
\red255\green255\blue255;
\red0\green0\blue128;
\red0\green128\blue128;
\red0\green128\blue0;
\red128\green0\blue128;
\red128\green0\blue0;
\red128\green128\blue0;
\red128\green128\blue128;
\red192\green192\blue192;
\red51\green51\blue51;
\red153\green51\blue0;}

{\stylesheet
{\qj \li0\ri0\nowidctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \snext0 Normal;}
{\s1\qj \fi-284\li284\ri0\sb360\sa240\sl20\slmult0
\keepn\widctlpar\tx284\tx1134\tx1276\aspalpha\aspnum\faauto\adjustright\rin0\lin284\itap0 \b\fs28\lang1033\langfe1031\kerning24\loch\f0\hich\af0\dbch\af18\langnp1033\langfenp1031 \sbasedon0 \snext0 heading 1;}
{\s2\qj \li0\ri0\sl480\slmult1\keepn\nowidctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \b\fs24\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \sbasedon0 \snext0 heading 2;}
{\s3\qj \li0\ri0\sb240\sa120\keepn\widctlpar\tx284\tx1134\tx1276\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \i\fs24\lang1031\langfe1031\loch\f0\hich\af0\dbch\af18\langnp1031\langfenp1031 \sbasedon0 \snext20 heading 3;}
{\*\cs10 \additive Default Paragraph Font;}
{\s15\ql \li0\ri0\nowidctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs20\lang1033\langfe1028\kerning2\loch\f2\hich\af2\dbch\af18\cgrid\langnp1033\langfenp1028 \sbasedon0 \snext15 Plain Text;}
{\*\cs16 \additive \cf2 \sbasedon10 Blue;}
{\*\cs17 \additive \cf6 \sbasedon10 Red;}
{\*\cs18 \additive \cf4 \sbasedon10 Green;}
{\s19\qj \li0\ri0\nowidctlpar\aspalpha\aspnum\faauto\nosnaplinegrid\adjustright\rin0\lin0\itap0 \fs20\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \sbasedon0 \snext19 footnote text;}
{\s20\qj \li480\ri0\nowidctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin480\itap0 \fs24\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \sbasedon0 \snext20 Normal Indent;}
{\s21\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \snext21 Cbeta;}
{\s22\ql \li2268\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin2268\itap0 \fs24\cf18\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext22 CbetaBYLINE;}
{\s23\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext21 CbetaNO;}
{\*\cs24 \additive \v\cf6\lang1031\langfe0\langnp1031 \sbasedon10 CbetaLB;}
{\s25\qj \fi-284\li284\ri0\sb360\sa240\sl20\slmult0\keepn\widctlpar\tx284\tx1134\tx1276\aspalpha\aspnum\faauto\outlinelevel0\adjustright\rin0\lin284\itap0 \b\fs28\lang1033\langfe1031\kerning24\loch\f0\hich\af0\dbch\af18\langnp1033\langfenp1031 \sbasedon1 \snext21 CbetaTITLE;}
{\*\cs26 \additive \cf2 \sbasedon10 CbetaPB;}
{\*\cs27 \additive \v \sbasedon10 CbetaREST;}
{\*\cs28 \additive \v0\cf2\lang0\langfe1028\langfenp1028 \sbasedon10 CbetaLOC;}
{\*\cs29 \additive \cf6 \sbasedon10 CbetaCORR;}
{\s30\ql \li1134\ri0\sl-320\slmult0\widctlpar\tx2835\aspalpha\aspnum\faauto\adjustright\rin0\lin1134\itap0 \fs20\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext30 CbetaFRONT;}
{\s31\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\cf17\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext31 CbetaJUAN;}
{\s32\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\tqc\tx1208\tqc\tx3617\tqc\tx6022\tqc\tx8431\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext32 CbetaLG;}
{\*\cs33 \additive \f27\fs20 \sbasedon10 CbetaNOTE;}
{\s34\qj \li0\ri0\nowidctlpar\tqr\tx9639\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\ul\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \sbasedon0 \snext34 header;}
{\s35\qj \li0\ri0\nowidctlpar\tqc\tx4153\tqr\tx9639\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1033\langfe1028\kerning2\loch\f0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 \sbasedon0 \snext35 footer;}
{\s36\ql \li567\ri567\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin567\lin567\itap0 \fs24\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext36 CbetaW;}
{\s37\ql \li0\ri0\sa120\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon0 \snext37 CbetaZ;}
{\*\cs38 \additive \v\chshdng0\chcfpat0\chcbpat7 \sbasedon10 CbetaTAGS;}
{\*\cs39 \additive \v \sbasedon10 CbetaTEIHeader;}
{\*\cs40 \additive CbetaHTit;}
{\s41\qj \fi-284\li284\ri0\sb360\sa240\sl20\slmult0\keepn\widctlpar\tx284\tx1134\tx1276\aspalpha\aspnum\faauto\outlinelevel0\adjustright\rin0\lin284\itap0 \b\fs28\lang1033\langfe1031\kerning24\loch\f0\hich\af0\dbch\af18\langnp1033\langfenp1031 \sbasedon1 \snext41 CbetaHEADING1;}
{\*\cs42 \additive \v \sbasedon10 CbetaFN;}
{\*\cs43 \additive \dbch\af28 \sbasedon10 CbetaUNI;}
{\*\cs44 \additive \v\cf0\chshdng0\chcfpat0\chcbpat0 \sbasedon10 CbetaRDG;}
{\*\cs45 \additive \v0 \sbasedon10 CbetaPUNC;}
{\*\cs46 \additive \v \sbasedon10 CbetaSK;}
{\s47\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\cf18\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext21 CbetaHEAD;}
{\s48\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\outlinelevel1\adjustright\rin0\lin0\itap0 \fs28\cf18\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext21 CbetaHEAD1;}
{\s49\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\outlinelevel2\adjustright\rin0\lin0\itap0 \fs26\cf18\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext21 CbetaHEAD2;}
{\s50\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\outlinelevel3\adjustright\rin0\lin0\itap0 \fs24\cf18\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext21 CbetaHEAD3;}
{\*\cs51 \additive \v\cf0\chshdng0\chcfpat0\chcbpat16 \sbasedon44 CbetaWIT;}
{\*\cs52 \additive \v \sbasedon10 CbetaLEM;}
{\*\cs53 \additive \v\f27\fs20 \sbasedon33 CbetaHNot;}
{\*\cs54 \additive \f27 \sbasedon10 CbetaSKUNI;}
}
HEADER

print '{\info',"\n";
print '{\title ';
print "《$sutraName》CBETA電子版}";
print '{\author CBETA}{\doccomm ';
$cBibl = "大正新脩大正藏經 $cVol No.$shortSutraNum";
print "$cBibl }\n";

print <<'HEADER';
{\operator RAY}
{\creatim\yr2000\mo11\dy16\hr11\min49}
{\revtim\yr2000\mo11\dy16\hr11\min49}{\version2}{\edmins1}{\nofpages1}{\nofwords435}{\nofchars2482}{\*\company \'a4\'a4\'b5\'d8\'b9\'71\'a4\'6c\'a6\'f2\'a8\'e5\'a8\'f3\'b7\'7c (CBETA)}{\nofcharsws3048}{\vern8249}}

\paperw11906\paperh16838\margl1153\margr1153\margt1440\margb1440\gutter0 \deftab8430\ftnbj\aenddoc\revisions\linkstyles\formshade\horzdoc\dgmargin\dghspace180\dgvspace180\dghorigin1153\dgvorigin1440\dghshow0\dgvshow2\jcompress\lnongrid
\viewkind4\viewscale114\viewzk2\splytwnine\ftnlytwnine\htmautsp\useltbaln\alntblind\lytcalctblwd\lyttblrtgr\lnbrkrule 

{\upr{\*\fchars 
!),.:\'3b?]\'7d\'a2\'46\'a1\'50\'a1\'56\'a1\'58\'a1\'a6\'a1\'a8\'a1\'45\'a1\'4c\'a1\'4b\'a1\'45\'a1\'ac\'a1\'5a\'a1\'42\'a1\'43\'a1\'72\'a1\'6e\'a1\'76\'a1\'7a\'a1\'6a\'a1\'66\'a1\'aa\'a1\'4a\'a1\'57\'a1\'59\'a1\'5b\'a1\'60\'a1\'64\'a1\'68\'a1\'6c
\'a1\'70\'a1\'74\'a1\'78\'a1\'7c\'a1\'5c\'a1\'4d\'a1\'4e\'a1\'4f\'a1\'51\'a1\'52\'a1\'53\'a1\'54\'a1\'7e\'a1\'a2\'a1\'a4\'a1\'49\'a1\'5e\'a1\'41\'a1\'44\'a1\'47\'a1\'46\'a1\'48\'a1\'55\'a1\'62\'a1\'4e}
{\*\ud\uc0{\*\fchars 
!),.:\'3b?]\'7d{\uc2\u162 \'a2F\'a1P\'a1V\'a1X\'a1\'a6\'a1\'a8\u8226 \'a1E\'a1L\'a1K\'a1E\'a1\'ac\'a1Z\'a1B\'a1C\'a1r\'a1n\'a1v\'a1z\'a1j\'a1f\'a1\'aa\'a1J\'a1W\'a1Y\'a1[\'a1`\'a1d\'a1h\'a1l\'a1p\'a1t\'a1x\'a1|\'a1\'5c\'a1M\'a1N\'a1O}
\'a1Q\'a1R\'a1S\'a1T\'a1~\'a1\'a2\'a1\'a4\'a1I\'a1^\'a1A\'a1D\'a1G\'a1F\'a1H\'a1U\'a1b{\uc2\u-156 \'a1N}}}}

{\upr{\*\lchars 
([\'7b\'a2\'47\'a2\'44\'a1\'a5\'a1\'a7\'a1\'ab\'a1\'71\'a1\'6d\'a1\'75\'a1\'79\'a1\'69\'a1\'65\'a1\'a9\'a1\'5f\'a1\'63\'a1\'67\'a1\'6b\'a1\'6f\'a1\'73\'a1\'77\'a1\'7b\'a1\'7d\'a1\'a1\'a1\'a3\'a1\'5d\'a1\'61}
{\*\ud\uc0{\*\lchars 
([\'7b{\uc2\u163 \'a2G\u165 \'a2D\'a1\'a5\'a1\'a7\'a1\'ab\'a1q\'a1m\'a1u\'a1y\'a1i\'a1e\'a1\'a9\'a1_\'a1c\'a1g\'a1k\'a1o\'a1s\'a1w\'a1\'7b\'a1\'7d\'a1\'a1\'a1\'a3\'a1]\'a1a}}}}

\fet0
{\*\template C:\\My Documents\\Templates\\Cbeta.dot}
\sectd \linex0\headery851\footery992\colsx425\endnhere\sectlinegrid360\sectspecifyl 

{\header \pard\plain \s34\qj \li0\ri0\nowidctlpar\tqr\tx9639\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 
\fs24\ul\lang1033\langfe1028\kerning2\loch\af0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 
HEADER

print '{\cs39 \loch\af0\hich\af0\dbch\f18 ', $sutraName, "}\n";

print <<'HEADER';
{\cs39 \hich\af0\dbch\af18\loch\f0 CBETA}
{\cs39 \loch\af0\hich\af0\dbch\f18 \'b9\'71\'a4\'6c\'aa\'a9}
{\cs39 \tab }
{\cs39 \loch\af0\hich\af0\dbch\f18 \'a4\'6a\'a5\'bf\'b7\'73\'b2\'e7\'a4\'6a\'c2\'c3\'b8\'67}
{\cs39 \hich\af0\dbch\af18\loch\f0  }
HEADER

print '{\cs39 \loch\af0\hich\af0\dbch\f18 ', $cVol, "}\n";
print '{\cs39 \hich\af0\dbch\af18\loch\f0  No.', $shortSutraNum, "}\n";

print <<'HEADER';
{\par }
}

{\footer \pard\plain \s35\qj \li0\ri0\nowidctlpar\tqc\tx4153\tqr\tx9639\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1033\langfe1028\kerning2\loch\af0\hich\af0\dbch\af18\cgrid\langnp1033\langfenp1028 
{\hich\af0\dbch\af18\loch\f0 CBETA }
{\loch\af0\hich\af0\dbch\f18 \'b9\'71\'a4\'6c\'a4\'6a\'c2\'c3\'b8\'67\'a8\'74\'a6\'43}
HEADER

print '{\cs39 \hich\af0\dbch\af18\loch\f0 V ', $version, "}\n";
print '{\cs39 \hich\af0\dbch\af18\loch\f0 , ', $date, '\tab }', "\n";

print <<'HEADER';
{\field{\*\fldinst {\cs39 \hich\af0\dbch\af18\loch\f0  PAGE  \\* MERGEFORMAT }}{\fldrslt {\cs39\lang1024\langfe1024\noproof \hich\af0\dbch\af18\loch\f0 1}}}
{\par }
}
{\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}
{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}
{\*\pnseclvl3\pndec\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}
{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta \dbch )}}
{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}

\pard\plain \s21\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 
{\cs38\v\chshdng0\chcfpat0\chcbpat7 {\*\bkmkstart TEIHeader}}
\pard\plain \s25\qj \fi-284\li284\ri0\sb360\sa240\sl20\slmult0\keepn\widctlpar\tx284\tx1134\tx1276\aspalpha\aspnum\faauto\outlinelevel0\adjustright\rin0\lin284\itap0 \b\fs28\lang1033\langfe1031\kerning24\loch\af0\hich\af0\dbch\af18\langnp1033\langfenp1031 
HEADER

print '{\cs39 {\*\bkmkstart Title}\loch\af0\hich\af0\dbch\f18 ';
print "《$sutraName》}";
print '{\cs39\lang1031\langfe1031\langnp1031 \hich\af0\dbch\af18\loch\f0 CBETA}';
print '{\cs39 \loch\af0\hich\af0\dbch\f18 電子版}';
print '{\cs38\v\lang1031\langfe1031\chshdng0\chcfpat0\chcbpat7\langnp1031 {\*\bkmkend Title}}';
print '{\cs39\lang1031\langfe1031\langnp1031 \par }',"\n";
print '\pard\plain \s30\ql \li1134\ri0\sl-320\slmult0\widctlpar\tx2835\aspalpha\aspnum\faauto\adjustright\rin0\lin1134\itap0 \fs20\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ',"\n";
print '{\cs39 \loch\af0\hich\af0\dbch\f18 版本記錄:　';
print "V $version 完成日期：$date}\n";
print '{\cs39\lang1031\langfe1031\langnp1031 \par }',"\n";
print '{\cs39 \loch\af0\hich\af0\dbch\f18 發行單位:　';
print "$distributor}\n";
print '{\cs39\lang1031\langfe1031\langnp1031 \par }',"\n";
print '{\cs39 \loch\af0\hich\af0\dbch\f18 資料底本:　';
print "$cBibl}\n";
print '{\cs39\lang1031\langfe1031\langnp1031 \par }',"\n";
print '{\cs39 \loch\af0\hich\af0\dbch\f18 原始資料:　';
print "$projectDesc}\n";
print '{\cs39\lang1031\langfe1031\langnp1031 \par }',"\n";
print '\pard\plain \s21\ql \li0\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ',"\n";
print '\loch\af0\hich\af0\dbch\f18';
}

sub parseRend {
	my $s = shift;
	if ($s =~ /margin-left:(\d+)/) {
		$s = "　" x $1;
	}
	return $s;
}

sub printBuffer {
	my $s=shift;
	$text = myReplace($text);
	$text2 = myReplace($text2);
	print $text;
	$text = '';
	if ($opt_t and $s ne '') {
		print '{\cs38\v\chshdng0\chcfpat0\chcbpat7 <lb n="';
		print $s;
		print '"/>}{\cs24\v\cf6 \line }',"\n";
	}
	if ($text2 ne '') {
		print "\n", '{\line }', $text2, '{\line }', "\n";
		$text2 = '';
	}
}

sub myReplace {
	my $s = shift;
	$s =~ s/\[[0-9]{2,3}\]//g;
	$s =~ s/#[0-9]{2,3}#//g;
	return $s;
}
