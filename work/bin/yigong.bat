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
# YiGong.bat
# Copied from x2rtf.pl 2001/1/4 10:34上午
#

# command line parameters
$vol = shift;
$inputFile = shift;
$vol = uc($vol);
$vol = substr($vol,0,3);

($path, $name) = split(/\//, $0);
push (@INC, $path);
require "sub.pl";

$cVol = "第" . cNum(substr($vol,1,2)) . "冊";

# configuration
$dir = "c:/Release/YiGong/$vol";
$sourcePath = "c:/cbwork";

$sourcePath .= "/$vol";
opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

$par = '\pard\plain \s21\qj \fi-2340\li2340\ri0\sl240\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin2340\itap0\cufi-975 \fs24\lang1024\langfe1024\loch\af0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 ' . "\n";
mkdir("c:/Release", MODE);
mkdir("c:/Release/YiGong", MODE);
mkdir($dir, MODE);

#utf8 pattern
$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

print STDERR "Require UTF8B5O.plx...";
require "utf8b5o.plx";
print STDERR "ok\n";
$utf8out{"\xe2\x97\x8e"} = '';

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


use XML::Parser;
my $parser = new XML::Parser(NoExpand => True);

$parser->setHandlers
				(Start => \&start_handler,
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

sub do1file {
	my $file = shift;

	$file =~ s/t(\d{2}n\d{4})([A-Za-z])?/T$1$2/;
	$file =~ /T\d\dn(\d{4}[A-Za-z]?)/;
	$sutraNum = $1;
	
	$shortSutraNum = $sutraNum;
	$shortSutraNum =~ s/^0+//g;
	
	$outPath = $dir;
	mkdir($outPath, MODE);
	
	print STDERR "$file\n";
	openDoc();
	$parser->parsefile($file);

	print "\n}";
	close;
}

sub init_handler {
	$inBody=0;
}

sub default {
    my $p = shift;
    my $string = shift;
	my $parent = lc($p->current_element);

	if (not $inBody) { return; }
	
	$string =~ s/^\&(.+);$/&rep($1)/eg;
	print $string;
}

sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my (%att) = @_;
	push @saveatt , { %att };
	my $parent = lc($p->current_element);

	### <anchor>  校勘
	if ($el eq "anchor") {
		my $id = $att{"id"};
		if ($id =~ /^fx/) { 
			print "[＊]"; 
		} elsif ($id =~ /^fnT\d\dp\d{4}[abc](\d+)/) {
			print "[$1]";
		}
	}
	
	### <bibl>
	if ($el eq "bibl") {
		if ($inHeader) { $text =''; }
	}
	
	### <body>
	if ($el eq "body") {
		$inBody = 1;
	}
	
	### <byline>
	if ($el eq "byline") {
		print '　　　　';
	}

	### <corr>
	if ($el eq "corr") {
		print '{\cs29\cf6';
	}
		
	### <distributor>
	if ($el eq "distributor") {
		if ($inHeader) { $text =''; }
	}
	
	### <edition>
	if ($el eq "edition") {
		if ($inHeader) { $text =''; }
	}
	
	### <gaiji>
	if ($el eq "gaiji") {
		if (exists($att{"uni"})) {
			print STDERR "##";
			print '{\uc1\u',hex($att{"uni"}),'}';
		}
	}

	### <head>
	if ($el eq "head") {
		if ($parent =~ /div(\d+)/) {
		}
	}
	
	### <item>
	if ($el eq "item") {
		if ($att{"n"} ne '') {
			print myDecode($att{"n"});
		}
	}
	
	### <juan>
	if ($el eq "juan") {
	}
	
	### <l>
	if ($el eq "l") {
		print '　';
	}
	
	### <lb>
	if ($el eq "lb") {
		$lb = $att{"n"};
		print '\par';
		print '\loch\af0\hich\af0\dbch\f18';
		#print '{\line }',"\n";
		print "${vol}n${sutraNum}_p$lb═";
	}
	
	### <lg>
	if ($el eq "lg") {
	}
	
	### <note>
	if ($el eq "note") {
		print '(';
	}

	### <p>
	if ($el eq "p") {
		if ($inHeader) {
			$text = '';
		} else {
		}
	}
	
	### <teiHeader>
	if ($el eq "teiHeader") { 
		$inHeader=1;
	}
	
	### <title>
	if ($el eq "title") {
		if ($inHeader) { $text =''; }
	}
}

sub end_handler {
	my $p = shift;
	my $el = shift;
	my $att = pop(@saveatt);
	
	### </bibl>
	if ($el eq "bibl") { 
		if ($inHeader) {
			$bibl = $text;
		}
	}
	
	### </corr>
	if ($el eq "corr") { 
		print '}';
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
		}
	}
	
	### </l>
	if ($el eq "l") { 
		print "　";
	}
	
	### </note>
	if ($el eq "note") { 
		print ')',"\n";

	}
	
	### </p>
	if ($el eq "p") { 
		if ($inHeader and $att->{"lang"} eq "zh") {
			$projectDesc = $text;
		}
	}
	
	### </teiHeader>
	if ($el eq "teiHeader") { 
		$inHeader=0;
		printHeader();
	}
	
	### </title>
	if ($el eq "title") {  
		if ($inHeader) {
			$text =~ / (\S*)$/;
			$sutraName = $1;
		}
	}
}

sub char_handler {
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
	
	if ($parent =~ /address|distributor/) {
		return;
	}
	
	my $big5 = '[\x00-\x7f]|[\x80-\xff].';
	$char =~ s/($pattern)/$utf8out{$1}/g;
	if ($inHeader) {
		$text .= $char;
	} else {
		while ($char =~ /^(($big5)*?)。/) {
			$char =~ s/^(($big5)*?)。/$1\{\\cs45 \\'a1\\'43\}/;
		}
		print $char;
	}
}


sub rep {
	my $x = shift;
	if (defined($Entities{$x})) { return $Entities{$x}; }
	else { die "Unknkown entity $x!!\n"; }
}

sub openDoc {
	close OF;
	
	my $file = "${vol}n$sutraNum.rtf";
	$file = ">$outPath/$file";
	print STDERR "\topen $file...\n";
	open OF, $file;
	select OF;
	print '{\rtf1\ansi\ansicpg950\uc2 \deff0\deflang1033\deflangfe1028';
}

sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) { return; }
	my $big5 = '\[|\]|\*|[\xa1-\xfe][\x40-\xfe]';
	my $des;
	$file = "$sourcePath/$file";
	print STDERR "\t\tRead entity $file...";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		/<!ENTITY\s+(\S+)\s+"(.*)"\s*>/;
		$ent = $1;
		$val = $2;
		if ($val=~/gaiji/) {
			if ($ent =~ "SD") {
				if ($val =~ /big5=\'(.*?)\'/) {
					$val = '{\dbch\af138 \loch\af0\hich\af0\dbch\f138 ' . "$1}";
				} else { die "321"; }
			} else {
				$val=~s#/>$#>#;
				if ($val =~ /uni=\'(.*?)\'/) {
					$val = '{\dbch\af28 \loch\af0\hich\af0\dbch\f28 \uc1\u' . hex($1) . "\\'3f}";
				} elsif ($val =~ /mofont=\'(.*?)\'/) {
					my $f = $mFont{$1};
					$val =~ /mochar=\'(.*?)\'/;
					$val = "{\\loch\\a$f\\hich\\a$f\\dbch\\$f";
					$val .= '{\uc1\u' . hex($1) . "\\'3f}" . "}";
				}
			}
		}
		$Entities{$ent} = $val;
	}
	print STDERR "ok\n";
}

sub entity {
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $sysid = shift;
	&openent($sysid);
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
{\s21\qj \fi-2340\li2340\ri0\sl240\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin2340\itap0\cufi-975 \fs24\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \snext15 \sautoupd Cbeta;}
{\s22\ql \li2268\ri0\sa120\sl-320\slmult0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin1020\itap0 \fs24\cf18\lang1024\langfe1024\loch\f0\hich\af0\dbch\af18\cgrid\noproof\langnp1033\langfenp1028 \sbasedon21 \snext22 CbetaBYLINE;}
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

\paperw11906\paperh16838\margl400\margr400\margt1440\margb1440\gutter0 \deftab8430\ftnbj\aenddoc\linkstyles\formshade\horzdoc\dgmargin\dghspace180\dgvspace180\dghorigin1153\dgvorigin1440\dghshow0\dgvshow2\jcompress\lnongrid
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

{\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}
{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}
{\*\pnseclvl3\pndec\pnstart1\pnindent720\pnhang{\pntxta \dbch .}}
{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta \dbch )}}
{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}
{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb \dbch (}{\pntxta \dbch )}}

HEADER

print $par;;
print '\loch\af0\hich\af0\dbch\f18';
}

sub myDecode {
	my $s = shift;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	return $s;
}


__END__
:endofperl
