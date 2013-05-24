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

#--------------------------------------------------------------------------------------------------------------------
# xml2jk.bat
# Version 0.4
# 2002/8/14 03:17PM
#
# �o�ӵ{���|Ū�J�@�� XML, ��X�@�ӥh���հɼаO�� XML, �H�Υt�@�Ӯհɱ�����
#
# �B�z���հɼаO:
#	<anchor>, <app>, <skgloss>, <note type="foot">, <note type="sk">
#
# Version 8, 2002/10/21 06:19PM, xml:stylesheet => xml-stylesheet
# Version 7, 2002/9/5 04:33PM, <app> �� n �ݩʥ����}�Y�O x �� y �μƦr, �~�|�� <anchor>
# Version 6, 2002/9/5 01:48PM, <app n="y999999"> => <anchor id="fx......">
# Version 5, 2002/9/4 05:36PM, �@�ծհɨ�� <note>, �u���ͤ@�� <anchor>
#                                                      <note> �p�G�S�� n �ݩ�, �N������ <anchor>
#                                                      <note type="foot">, <note type="sk">, <note place="foot"> �ت���r�����
# Version 4, 2002/9/4 03:44PM, �h���ťզ�
# Version 3, 2002/9/4 03:33PM, <note type="foot">, <note type="sk"> �]�n�ন <anchor>
# Version 2, 2002/9/3 05:28PM, <rdg> �ت��аO, �p <note>, �����L�X��
# Version 1, 2002/9/3 01:50PM, <skgloss> ���ͪ� <anchor> �֤F id=
#
# created by Ray 2002/5/10
#----------------------------------------------------------------------------------------------------------------------
$vol = shift;
$inputFile = shift;

$chm;
$nid=0;
$vol = uc($vol);
$xml_dir = "c:/cbwork/xml/"; # xml ��J�ؿ�
#$dir = "c:/Documents and Settings/eva.CBETA/�ୱ/T12";  # ��X�ؿ�
$dir = "d:/temp";  # ��X�ؿ�
$vol = substr($vol,0,3);

mkdir($dir . "/new-xml", MODE);
mkdir($dir . "/new-xml/" . $vol, MODE);
mkdir($dir . "/JiaoKan", MODE);
mkdir($dir . "/JiaoKan/" . $vol, MODE);

opendir (INDIR, $xml_dir . $vol);
@allfiles = grep(/\.xml$/i, readdir(INDIR));

die "No files to process\n" unless @allfiles;

print STDERR "Initialising....\n";

#utf8 pattern
	$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

($path, $name) = split(/\//, $0);
push (@INC, $path);

require "utf8b5o.plx";
require "sub.pl";
$utf8out{"\xe2\x97\x8e"} = '';

use XML::Parser;


my %Entities = ();
my %dia = (
 "Amacron","AA",
 "amacron","aa",
 "ddotblw",".d",
 "Ddotblw",".D",
 "hdotblw",".h",
 "imacron","ii",
 "ldotblw",".l",
 "Ldotblw",".L",
 "mdotabv","%m",
 "mdotblw",".m",
 "ndotabv","%n",
 "ndotblw",".n.",
 "Ndotblw",".N",
 "ntilde","~n",
 "rdotblw",".r",
 "sacute","`s",
 "Sacute","`S",
 "sdotblw",".s",
 "Sdotblw",".S",
 "tdotblw",".t",
 "Tdotblw",".T",
 "umacron","^u"
);      
        
my $parser = new XML::Parser(NoExpand => True);
        
        
$parser->setHandlers
				(Start => \&start_handler,
				Init => \&init_handler,
				End => \&end_handler,
		     	Char  => \&char_handler,
		     	Entity => \&entity,
		     	Default => \&default);
        
if ($inputFile eq "") {
  for $file (sort(@allfiles)) { process1file($file); }
} else {
  $file = $inputFile;
  process1file($file);
}       
        
print STDERR "����!!\n";
        
sub process1file {
	$file = shift;
	$file =~ s/^t/T/;

	$jk_file = $file;
	$jk_file =~ s/\.xml$/\.txt/;

	print STDERR "\n==>${dir}/new-xml/$vol/$file $jk_file\n";
	open O, ">$dir/new-xml/$vol/temp.txt" or die;
	open JK, ">$dir/JiaoKan/$vol/$jk_file" or die;
	select O;
	$parser->parsefile($file);
	close O;
	
	# �h���ťզ�
	open I, "$dir/new-xml/$vol/temp.txt" or die;
	open O, ">$dir/new-xml/$vol/$file" or die;
	select O;
	while (<I>) {
		if ($_ eq "\n") {
			next;
		}
		print;
	}
	close I;
	close O;
	unlink "$dir/new-xml/$vol/temp.txt";
}

#-------------------------------------------------------------------
# Ū ent �ɦs�J %Entities
sub openent{
	local($file) = $_[0];
	print STDERR "�}�� Entity �w�q��: $file\n";
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		$Entities{$ent} = $ent;
		#print STDERR "Entity: $ent -> $ent\n";
	}
}       
        
        
sub default {
	my $p = shift;
	my $string = shift;

	my $parent = lc($p->current_element);        
	if ($parent eq "app" or $parent eq "skgloss") {
		return;
	}

	if ($string eq "&lac;") {
		return;
	}
	$string =~ s/^&(.+);$/$1/;
	if ( defined($Entities{$string}) ) { 
		my $s="&$string;";
		if ($pass==0) {
			print "&$string;"; 
		}
		if ($in_gloss) {
			print JK $dia{$string};
		}
		if ($in_lem) {
			$lem .= $s;
		}
		if ($in_rdg) {
			$rdg .= $s;
		}
		if ($in_term and $in_skgloss) {
			print JK $s;
		}
	}
}
        
sub init_handler
{       
	my $s = $file;
	$s =~ s/\.xml/\.ent/;
	print <<"EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml-stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd"
[<!ENTITY % ENTY  SYSTEM "$s" >
<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
%ENTY;
%CBENT;
]>
EOD

	$pb="";
	$pass==0;
	$in_lem=0;
	$in_rdg=0;
	$in_gloss=0;
	$in_skgloss=0;
	$in_term=0;
	%jk=();
}
        
sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);

	# <anchor>
	#if ($el eq "anchor") {
	#	my $id=$att{"id"};
	#	if ($id =~ /^fx/) {
	#		print "[��]";
	#	}
	#	return;
	#}

	# <app>
	if ($el eq "app") {
		my $n=$att{"n"};
		if ($n =~ /^[xy]/) {			
			#my $s=sprintf("%2.2d", $fx);
			print "<anchor id=\"fx${vol}p$pb$fx\"/>";
			$fx++;
		} elsif ($n=~/^\d/) {
			if ($n =~ /^\d{6}[a-z]/) {
				$n=substr($n,4, 3);
			} else {
				$n=substr($n,4,2);
			}
			print "<anchor id=\"fn${vol}p$pb$n\"/>";
			print JK "  $n ";
		}
		return;
	}

	# <gloss>
	if ($el eq "gloss") {
		$in_gloss=1;
		$pass++;
		$gloss="";
		return;
	}

	# <lb>
	if ($el eq "lb") {
		my $n=$att{"n"};
		if ($pb eq '') {
			$pb = substr($n, 0, 5);
		}
	}

	# <lem>
	if ($el eq "lem") {
		$in_lem=1;
		$lem="";
		return;
	}

	# <note>
	if ($el eq "note") {
		my $type=$att{"type"};
		if ($type eq "foot" or $type eq "sk" or $att{"place"} eq "foot") {
			my $n = $att{"n"};
			if ($n ne "") {
				$n = substr($n,4,2);
				my $id = "fn${vol}p$pb$n";
				if (not exists $jk{$id}) {
					$jk{$id}=0;
					print "<anchor id=\"fn${vol}p$pb$n\"/>";
					print JK "  $n ";
				}
			}
			$pass++;
			return;
		}
	}
	# <pb>
	if ($el eq "pb") {
		my $n=$att{"n"};
		#$n=substr($n,0,4);
		if ($n ne $pb) {
			$pb=$n;
			print JK "p$pb\n";
		}
		$fx=1;
	}

	# <rdg>
	if ($el eq "rdg") {
		$wit = myDecode($att{"wit"});
		$in_rdg=1;
		$rdg="";
		$pass++;
		return;
	}

	# <skgloss>
	if ($el eq "skgloss") {
		$in_skgloss=1;
		my $n=$att{"n"};
		$n=substr($n,4,2);
		print "<anchor id=\"fn$vol$pb$n\"/>";
		print JK "  $n ";
		return;
	}

	# <term>
	if ($el eq "term") {
		$in_term=1;
		if ($parent eq "skgloss") {
			return;
		}
	}

	if ($pass==0) {
		print "<$el";
		while (($key,$value) = each %att) {
			$value = myDecode($value);
			print " $key=\"$value\"";
		}
		if ($el =~ /^(anchor)|(lb)|(pb)$/) { print "/"; }
		print ">";
	}
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

	# </anchor>
	if ($el eq "anchor") {
		return;
	}

	# </app>
	if ($el eq "app") {
		print JK "\n";
		return;
	}

	# </gloss>
	if ($el eq "gloss") {
		$pass--;
		$in_gloss=0;
		print JK $gloss;
		return;
	}
	
	# </lem>
	if ($el eq "lem") {
		$in_lem=0;
		if ($lem eq "") {
			print JK "��";
		} else {
			print JK "$lem��";
		}
		return;
	}

	# </note>
	if ($el eq "note") {
		my $type=$att->{"type"};
		if ($type eq "foot" or $type eq "sk" or $att->{"place"} eq "foot")  {
			$pass--;
			return;
		}
	}

	# </rdg>
	if ($el eq "rdg") {
		$in_rdg=0;
		$pass--;
		print JK "$rdg$wit";
		return;
	}

	# </skgloss>
	if ($el eq "skgloss") {
		print JK "\n";
		$in_skgloss=0;
		return;
	}

	# </term>
	if ($el eq "term") {
		$in_term=0;
		if ($parent eq "skgloss") {
			return;
		}
	}

	if ($pass==0) {
		if ($el ne "lb" and $el ne "pb") { 
			print "</$el>"; 
		}
	}
}       


sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	if ($parent eq "app" or $parent eq "skgloss") {
		return;
	}

	$char =~ s/($pattern)/$utf8out{$1}/g;
	if ($pass==0) {
		print $char;
	}

	if ($in_gloss) {
		print JK $char;
	}

	if ($in_lem) {
		$lem .= $char;
	}
	
	if ($in_rdg) {
		$rdg .= $char;
	}

	if ($in_term and $in_skgloss) {
		print JK $char;
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

        
__END__ 
:endofperl
