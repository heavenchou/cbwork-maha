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
@allfiles = grep (/\.xml$/i, readdir(INDIR));
die "No files to process\n" unless @allfiles;

use xml::dom;
my $parser = new XML::DOM::Parser;

if ($inputFile eq "") {
	for $file (sort(@allfiles)) { do1file("$sourcePath/$file"); }
} else {
	$file = $inputFile;
	do1file("sourcePath/$file");
}

sub do1file {
	my $file = shift;
	print "Parsing $file...\n";
	my $doc = $parser->parsefile($file");
	my $root = $doc->getDocumentElement();
	openJuan("001");
	$currentFrg = 0;
	$dirty = 1;
	do1node($root);
}

sub do1node {
	my $node = shift;
	if ($node->getNodeTypeName eq "ELEMENT_NODE") {
		for my $kid ($node->getChildNodes) {
			do1node($kid);
		}
	}
}

sub start_handler 
{       
	my $node = shift;
	$el = $node->getTagName;
	
	if ($el =~ /div(\d+)/) {
		my $n = $1;
		if ($n > $deepestDivCrossJuan) {
			$inFrg = 1;
			print startTag();
		} else {
			$inFrg = 0;
			my $s = startTag();
			print F_JUAN $s;
			if ($dirty) { 
				openFrg(++$currentFrg); 
				$dirty = 0;
			}
			$n ++;
			$s = "div" . $n;
			my @list = $node->getElementsByTagName($s,0);
			if ($list==0) { $inFrg = 1; }
		}
	}

	if ($el eq "juan" and $att{"fun"} eq "open") {
		openJuan($att{"n"});
		openFrg(++$CurrentFrg);
	}
	
	$s = startTag();
	print $s;
	if (not $inFrg) { $mainStruct .= $s; }
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
		$s .= " $attrName=\"$attrValue\"";
	}
	if ($el eq "lb" or $el eq "pb") { $s .= "/"; }
	$s .= ">";
	return $s;
}

sub openJuan {
	my $n = shift;
	
	close F_JUAN;
	
	my $file = sprintf("%4.4d_%3.3d.xml", $sutraNum, $n);
	$file = ">$dir/n$sutraNum/$file";
	print STDERR "open $file...\n";
	open F_JUAN, $file;
	select F_JUAN;
	print <<"EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd" [
	<!ENTITY % ENTY  SYSTEM "$s" >
	<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
EOD
	print $mainStruct;
	if ($inFrg) { select F_FRG; }
}

sub openFrg {
	my $n = shift;
	
	close F_FRG;
	
	my $file = sprintf("%3.3d.frg", $n);
	$file = ">$dir/n$sutraNum/$file";
	print STDERR "open $file...\n";
	open F_FRG, $file;
	select F_FRG;
	print <<"EOD";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd" [
	<!ENTITY % ENTY  SYSTEM "$s" >
	<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
EOD
	print F_JUAN "&frag$n;";
}
