@echo off
rem edith note 2005/5/27
rem 程式名稱：juan.bat
rem 程式位置：C:\cbwork\work\bin
rem 程式用途：檢查XML檔中的卷首資訊。
rem 程式步驟：
rem C:\xml
rem C:\cbwork\xml>cd Xxx
rem C:\cbwork\xml\Xxx>juan Xxx
rem _根據dos執行狀況修改XML檔。
rem _若執行到一半便停止的檔案，即表示該檔有錯誤。
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
# edith modify 2005/5/30 不中斷程式, 給提示訊息, 例如跑 X55n0882卷不連續卷數
#
# Revision 1.7  2005/05/27 03:26:59  edith
# edith modify 2005/5/27 <J> 表示切卷，
# xml 只會轉出 milestone 及 mulu ，並不會轉出 juan open
# 作法:不中斷程式, 只留提示訊息:
# print "$file 卷未Open 行號, 可能是切卷, 請留意：$lineNum\n";
#
# Revision 1.6  2005/05/27 02:36:38  edith
# edith modify 2005/5/27 卷數n值可能包含1a、lb、lc...,
# 作法將字母(a,b,c,...)轉成(10,11,12...)十六進位去比較
#
# Revision 1.5  2004/07/22 02:40:19  ray
# 無卷首資訊的列出訊息
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

#2004/7/22 10:38上午
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
		$error .= "$file 無卷首資訊\n";
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
				#edith modify 2005/5/27 卷數n值可能包含1a、lb、lc...
				if ($n =~ /([0-9])([a-z])/) {
				    #print "\n\n edith $file 　[$n]  [" .  $juanNum+1 ."]\n";
				    $number = hex($2);  #作法將字母(a,b,c,...)轉成(10,11,12...)十六進位去比較				    
				    if ($juanNum_temp1 ne 0 and $juanNum_temp2 ne 0)
				    {
            				   if ($1 eq  $juanNum_temp1 and $number > $juanNum_temp2)
            				    {
            				        #符合條件:pass
            				     }
            				     else
            				     {
            				        print "\n$file 卷數錯誤　[$n]  [" .  $1.$2 ."], ";
            				        print "$file 卷數錯誤　行號：$lineNum\n";
            				        #exit;  #edith modify 2005/5/30 不中斷程式, 給提示訊息, 例如跑 X55n0882卷不連續卷數
            				     }            				    
            		             }
            		             $juanNum_temp1 = $1;
            			    $juanNum_temp2 = $number;
				}
				#if ($n != $juanNum+1) {
				elsif ($n != $juanNum+1) {
					#print "$file 卷數錯誤　[$n]  [" .  $juanNum+1 ."]\n";
					print "\n$file 卷數錯誤, 有可能是不連續行號, 行號：$lineNum\n";
					#exit;   #edith modify 2005/5/30 不中斷程式, 給提示訊息, 例如跑 X55n0882卷不連續卷數
				}				
			}
			$juanNum = $n;
			$juanOpen = 1;
			$juan_open_count++;
		} elsif ($fun eq "close") {
			if (not $juanOpen) {
				#edith modify 2005/5/27 <J> 表示切卷，xml 只會轉出 milestone 及 mulu ，並不會轉出 juan open
				print "$file 卷未Open 行號, 可能是切卷, 行號：$lineNum\n";
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
	#2004/7/22 10:30上午
	#print "\n$file\n";
	if ($vol eq "T06") { $juanNum = 200; }
	elsif ($vol eq "T07") { $juanNum = 400; }
	else { $juanNum = 0; }
	$parser->parsefile($file);
	
	# 2004/7/7 09:35上午
	#if ($juanOpen) {
	#	print "$file 卷未Close 行號：$lineNum\n";
	#	exit;
	#}
}

print "\n",$error;

__END__
:endofperl
