@echo off
rem edith note 2005/5/27
rem �{���W�١Gjuan.bat
rem �{����m�GC:\cbwork\work\bin
rem �{���γ~�G�ˬdXML�ɤ���������T�C
rem �{���B�J�G
rem C:\xml
rem C:\cbwork\xml>cd Xxx
rem C:\cbwork\xml\Xxx>juan Xxx
rem _�ھ�dos���檬�p�ק�XML�ɡC
rem _�Y�����@�b�K����ɮסA�Y��ܸ��ɦ����~�C
@rem = '--*-Perl-*--
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
# $Log: juan.bat,v $
# Revision 1.8  2005/05/30 00:23:19  edith
# edith modify 2005/5/30 �����_�{��, �����ܰT��, �Ҧp�] X55n0882�����s�����
#
# Revision 1.7  2005/05/27 03:26:59  edith
# edith modify 2005/5/27 <J> ��ܤ����A
# xml �u�|��X milestone �� mulu �A�ä��|��X juan open
# �@�k:�����_�{��, �u�d���ܰT��:
# print "$file ����Open �渹, �i��O����, �Яd�N�G$lineNum\n";
#
# Revision 1.6  2005/05/27 02:36:38  edith
# edith modify 2005/5/27 ����n�ȥi��]�t1a�Blb�Blc...,
# �@�k�N�r��(a,b,c,...)�ন(10,11,12...)�Q���i��h���
#
# Revision 1.5  2004/07/22 02:40:19  ray
# �L������T���C�X�T��
#
# Revision 1.4  2004/07/07 01:20:15  ray
# no message
#

$vol = shift;
$vol = uc($vol);

open (CFG, "../../work/bin/CBETA.CFG") || die "can't open cbeta.cfg\n";

while(<CFG>){
	next if (/^#/); #comments
	chop;
	($key, $val) = split(/=/, $_);
	$key = uc($key);
	$cfg{$key}=$val; #store cfg values
	#print "$key\t$cfg{$key}\n";
}

opendir (INDIR, ".");
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require $cfg{"OUT"}; #utf-tabelle fuer big5, jis..
require "head.pl";
$utf8out{"\xe2\x97\x8e"} = '';

#2004/7/22 10:38�W��
#mkdir($cfg{"OUTDIR"} . "\\DIV1HEAD", MODE);
#$of = $cfg{"OUTDIR"} . "\\DIV1HEAD\\$vol.txt";
#open (OF, ">$of");
#print STDERR " --> $of\n";
#select(OF);


use XML::Parser;


my %Entities = ();
my $ent;
my $val;
my $text;
my $juanNum=0;
my $juanNum_temp1=0;
my $juanNum_temp2=0;
my $lineNum="";
my $juanOpen=0;
my $inDiv1=0;
$error='';
$div1Type="";

sub openent{
	local($file) = $_[0];
	#local($k) = "." . $cfg{"CHAR"};
 	#$file =~ s/\....$/$k/e;# if ($k =~ /ORG/i);
 	$file =~ s#/#\\#g;
 	#$file =~ s/\.\./$cfg{"DIR"}/;
 	if ($file =~ /gif$/) {
 		return;
 	}
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
	$bib .= $string if ($bibl == 1);
	$text .= $string if ($pass == 0);
}

sub init_handler
{
#	print "CBETA donokono";
	$pass = 1;
	$bibl = 0;
	$inxu = 0;
#!> 	$fileopen = 0;
#!> 	$num = 0;
	$close = "";
	$div1Type="";
	$juanOpen = 0;
	$inDiv1=0;
	$juan_open_count=0;
}

sub final_handler {
	if ($juan_open_count==0) {
		$error .= "$file �L������T\n";
	}
}
	
sub start_handler 
{
	my $p = shift;
	$el = shift;
	my (%att) = @_;

	### <div1> ###
	if ($el eq "div1"){
		if (lc($att{"type"}) ne "") { $div1Type = lc($att{"type"}); }
		$inDiv1=1;
	}

	if ($el eq "juan" and ($div1Type ne "w" or not $inDiv1) ) {
		my $fun = lc($att{"fun"});
		my $n = $att{"n"};
		printf "%5s",$fun;
		print " $n,";
		if ($fun eq "open") {
			if ($div1Type ne "w") {
				#edith modify 2005/5/27 ����n�ȥi��]�t1a�Blb�Blc...
				if ($n =~ /([0-9])([a-z])/) {
				    #print "\n\n edith $file �@[$n]  [" .  $juanNum+1 ."]\n";
				    $number = hex($2);  #�@�k�N�r��(a,b,c,...)�ন(10,11,12...)�Q���i��h���				    
				    if ($juanNum_temp1 ne 0 and $juanNum_temp2 ne 0)
				    {
            				   if ($1 eq  $juanNum_temp1 and $number > $juanNum_temp2)
            				    {
            				        #�ŦX����:pass
            				     }
            				     else
            				     {
            				        print "\n$file ���ƿ��~�@[$n]  [" .  $1.$2 ."], ";
            				        print "$file ���ƿ��~�@�渹�G$lineNum\n";
            				        #exit;  #edith modify 2005/5/30 �����_�{��, �����ܰT��, �Ҧp�] X55n0882�����s�����
            				     }            				    
            		             }
            		             $juanNum_temp1 = $1;
            			    $juanNum_temp2 = $number;
				}
				#if ($n != $juanNum+1) {
				elsif ($n != $juanNum+1) {
					#print "$file ���ƿ��~�@[$n]  [" .  $juanNum+1 ."]\n";
					print "\n$file ���ƿ��~, ���i��O���s��渹, �渹�G$lineNum\n";
					#exit;   #edith modify 2005/5/30 �����_�{��, �����ܰT��, �Ҧp�] X55n0882�����s�����
				}				
			}
			$juanNum = $n;
			$juanOpen = 1;
			$juan_open_count++;
		} elsif ($fun eq "close") {
			if (not $juanOpen) {
				#edith modify 2005/5/27 <J> ��ܤ����Axml �u�|��X milestone �� mulu �A�ä��|��X juan open
				print "$file ����Open �渹, �i��O����, �渹�G$lineNum\n";
				#exit;
			}
			$juanOpen = 0;
		}
	}
	if ($el eq "lb") { $lineNum = $att{"n"}; }
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
	if ($el eq "div1") { $inDiv1=0; }
}

sub char_handler 
{
	my $p = shift;
	my $char = shift;
}


sub entity{
	my $p = shift;
	my $ent = shift;
	my $entval = shift;
	my $next = shift;
	&openent($next);
	return 1;
}



my $parser = new XML::Parser(NoExpand => True);


$parser->setHandlers (
	Start => \&start_handler,
	Init => \&init_handler,
	Final => \&final_handler,
	End => \&end_handler,
	Char  => \&char_handler,
	Entity => \&entity,
	Default => \&default);

for $file (sort(@allfiles)){
	print STDERR "\n$file\n";
	#2004/7/22 10:30�W��
	#print "\n$file\n";
	if ($vol eq "T06") { $juanNum = 200; }
	elsif ($vol eq "T07") { $juanNum = 400; }
	else { $juanNum = 0; }
	$parser->parsefile($file);
	
	# 2004/7/7 09:35�W��
	#if ($juanOpen) {
	#	print "$file ����Close �渹�G$lineNum\n";
	#	exit;
	#}
}

print "\n",$error;

__END__
:endofperl
