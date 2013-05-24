# 檢查 cbeta xml 檔, 是否符合規則
# 使用例: checkxml2.pl x60
# 規則
#	1. div 下不能直接有文字

$dir = "/cbwork/xml";

$vol = shift;
$inputFile = shift;

$vol = uc($vol);
$vol = substr($vol,0,3);

$dir = "$dir/$vol";

opendir (INDIR, $dir);
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
       
print STDERR "完成!!\n";
        
sub process1file {
	$file = shift;
	$file =~ s/^t/T/;
	$parser->parsefile("$dir/$file");
}

#-------------------------------------------------------------------
# 讀 ent 檔存入 %Entities
sub openent{
	local($file) = $_[0];
	if ($file =~ /\.gif$/) {
		return;
	}
	open(T, "$dir/$file") || die "61 can't open $dir/$file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		$Entities{$ent} = $ent;
	}
}       
        
        
sub default {
	my $p = shift;
	my $string = shift;
	$string =~ s/^&(.+);$/$1/;
	#if ( defined($Entities{$string}) )	{ 
	#	print "&$string;"; 
	#}
}       
        
sub init_handler
{       
	my $s = $file;
	$s =~ s/\.xml/\.ent/;
}

sub start_handler 
{       
	my $p = shift;
	$el = shift;
	my %att = @_;
	push @saveatt , { %att };
	push @elements, $el;
	my $parent = lc($p->current_element);

	if ($el eq "lb") {
		$lb = $att{"n"}
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
}       
        
        
sub char_handler 
{       
	my $p = shift;
	my $char = shift;
	my $parent = lc($p->current_element);
        
	$char =~ s/($pattern)/$utf8out{$1}/g;
	$char =~ s/\n//g;
	if ($char ne "") {
		if ($parent =~ /^div/) {
			print "132 div 下不能有文字 $file $lb $parent\n";
		}
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