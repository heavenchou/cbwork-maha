# command line parameters
$vol = shift;
$inputFile = shift;
$vol = uc($vol);
$vol = substr($vol,0,3);

# configuration
$dir = "c:/Release/Fragment/$vol";
$sourcePath = "c:/cbwork";

$sourcePath .= "/$vol";
opendir (INDIR, $sourcePath);
@allfiles = grep(/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

mkdir("c:/Release", MODE);
mkdir("c:/Release/Fragment", MODE);
mkdir($dir, MODE);

#utf8 pattern
$pattern = '[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f]|&[^;]*;|\<[^\>]*\>';

require "utf8b5o.plx";
$utf8out{"\xe2\x97\x8e"} = '';

local $currentFrg=0;

use xml::dom;
my $parser = new XML::DOM::Parser;

if ($inputFile eq "") {
	for $file (sort(@allfiles)) { do1file("$sourcePath/$file"); }
} else {
	$file = $inputFile;
	do1file("$sourcePath/$file");
}

sub do1file {
	my $file = shift;

	$file =~ s/t(\d{2}n\d{4})/T$1/;
	$file =~ /T\d\dn(\d{4})/;
	$sutraNum = $1;
	$outPath = "$dir/n$sutraNum";
	mkdir($outPath, MODE);
	
	print STDERR "移除舊檔...";
	unlink <$outPath/*.xml>;
	unlink <$outPath/*.frg>;
	print STDERR "ok\n";

	my $sutraEnt = "${vol}n$sutraNum.ent";
	

	print STDERR "Parsing $file...";
	my $doc = $parser->parsefile($file);
	print STDERR "ok\n";
	

	$currentFrg = 0;
	$dirty = 1;
	$inFrg=0;
	$juanOpen=0;
	$divOpen=0;
	@tagOpen=();
	
	$mainStruct1 =<< "EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../../dtd/cbetaxml.dtd" [
	<!ENTITY % ENTY  SYSTEM "$sutraEnt" >
	<!ENTITY % FRAG  SYSTEM "frag.ent" >
	<!ENTITY % CBENT  SYSTEM "../../dtd/cbeta.ent" >
EOD

	$mainStruct2 =<< "EOD";
	%ENTY;
	%CBENT;
]>
EOD
	$mainStruct3 = "";

	my $root = $doc->getDocumentElement();
	$deepestDivCrossJuan = "0";
	print STDERR "檢查最小跨卷的 Div...";
	checkDiv($root);
	print STDERR " Div$deepestDivCrossJuan 跨卷\n";

	do1node($root);
	closeJuan();
}

sub do1node {
	my $node = shift;
	my $nodeTypeName = $node->getNodeTypeName;
	if ($nodeTypeName eq "ELEMENT_NODE") {
		start_handler($node);
		for my $kid ($node->getChildNodes) {
			do1node($kid);
		}
		end_handler($node);
	} elsif ($nodeTypeName eq "TEXT_NODE") {
		text_handler($node);
	}
}

sub start_handler 
{       
	my $node = shift;
	local $el = $node->getTagName;

	my $map = $node->getAttributes;
	for my $s ($map->getValues) {
		$att{$s->getName} = $s->getValue;
	}
	my $startTagStr = startTagStr($node);
	unshift @tagOpen, "</$el>";
	
	if ($el =~ /div(\d+)/) {
		$divOpen++;
		my $n = $1;
		if ($n > $deepestDivCrossJuan) {
			if ($inFrg==0) {
				$currentFrg++; 
				openFrg($currentFrg); 
				$inFrg = 1;
			}
			print F_FRG $startTagStr;
		} else {
			$inFrg = 0;
			$buf .= $startTagStr;
			$mainStruct3 .= $startTagStr;
			$n ++;
			$s = "div" . $n;
			my @list = $node->getElementsByTagName($s,0);
			if ($list==0) {
				$currentFrg++; 
				openFrg($currentFrg); 
				$inFrg = 1;
			}
		}
	} elsif	($el eq "juan") {  # T01n0001, p0016b14
		if (!$inFrg) {
			$currentFrg++; 
			openFrg($currentFrg); 
			$inFrg = 1;
		}
		print $startTagStr;
	} elsif	($el eq "milestone") {
		openJuan($att{"n"});
		$buf .= $startTagStr;
		$mainStruct3 .= $startTagStr;
	} else {
		if ($inFrg) {
			print $startTagStr;
		} else { 
			$buf .= $startTagStr;
			$mainStruct3 .= $startTagStr;
		}
	}
}

sub end_handler {
	my $node = shift;
	my $el = $node->getTagName;
	if ($el =~ /div(\d+)/) {
		$n = $1;
		if ($n <= $deepestDivCrossJuan) {
			$inFrg = 0;
			$buf .= "</$el>";
			$mainStruct3 .= "</$el>";
		} else {
			print F_FRG "</$el>";
		}
		$divOpen--;
	} elsif ($el !~ /lb|pb|milestone/) { 
		if ($inFrg) {
			if ($juanOpen) { print "</$el>"; }
		} else {
			$mainStruct3 .= "</$el>";
			$buf .= "</$el>";
		}
	}
	shift @tagOpen;
}

sub startTagStr {
	my $node = shift;
	my $s;
	my $el = $node->getTagName;
	$s = "<" . $el;
	my $map = $node->getAttributes;
	for $attr ($map->getValues) {
		my $attrName = $attr->getName;
		my $attrValue = $attr->getValue;
		$attrValue =~ s/($pattern)/$utf8out{$1}/g;
		$s .= " $attrName=\"$attrValue\"";
	}
	if ($el =~ /lb|pb|milestone/) { $s = "$s/"; }
	$s .= ">";
	return $s;
}

sub text_handler {
	my $node = shift;
	my $s = $node->getData;
	$s =~ s/($pattern)/$utf8out{$1}/g;
	if ($inFrg) {
		if ($juanOpen) { print $s; }
	} else {
		if ($juanOpen and $divOpen and $s ne "\n") {
			$currentFrg++; 
			openFrg($currentFrg); 
			$inFrg = 1;
		} else {
			$mainStruct3 .= $s;
			$buf .= $s;
		}
	}
	$dirty = 1;
}

sub openJuan {
	my $n = shift;
	
	if ($juanOpen) {
		closeJuan();
	}
	$entBuf='';
	
	my $file = sprintf("%4.4d_%3.3d.xml", $sutraNum, $n);
	$file = ">$outPath/$file";
	print STDERR "open $file...\n";
	open F_JUAN, $file;
	select F_JUAN;
	$inFrg=0;
	$juanOpen=1;
}

sub openFrg {
	my $n = shift;
	
	close F_FRG;
	
	my $file = sprintf("%3.3d.frg", $n);
	my $path = ">$outPath/$file";
	print STDERR "open $path...\n";
	open F_FRG, $path;
	select F_FRG;
	print "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
	$buf .= "&frag$n;";
	$entBuf .= "\t<!ENTITY frag$n SYSTEM \"$file\" >\n";
}

sub closeJuan {
	select F_JUAN;
	print $mainStruct1;
	print $entBuf;
	print $mainStruct2;
	$mainStruct2 .= $mainStruct3;
	$mainStruct3 = '';
	print $buf;
	$buf="";
	for my $s (@tagOpen) { 
		if ($s !~ /milestone/) { print $s; }
	}
	close F_JUAN;
}

sub checkDiv {
	my $node = shift;
	my $nodeTypeName = $node->getNodeTypeName;
	if ($nodeTypeName eq "ELEMENT_NODE") {
		my $el = $node->getTagName;
		if ($el =~ /div(\d+)/) {
			my $n = $1;
			my @list = $node->getElementsByTagName("milestone",1);
			if (@list!=0) {
				if ($n > $deepestDivCrossJuan) { $deepestDivCrossJuan = $n; }
			}
		}
		for my $kid ($node->getChildNodes) { checkDiv($kid);	}
	}
}