open(T, "gaiji-m.txt" ) || die "can't open $gfile\n";

open O1, ">gaiji-m.xml";
select O1;
print '<?xml version="1.0" encoding="big5" ?>',"\n";
print '<!DOCTYPE gaijis SYSTEM "gaiji-m.dtd">',"\n";
print "<gaijis>\n";

<T>;
while(<T>){
	chop;
	($cb, $d1, $ent, $uni, $uent, $zu, $ty, $ref, $note) = split(/\t/, $_);
	$ent =~ s/&(.+);/$1/;
	$uni =~ s/^u//;
	$ty =~ s/none//;
	$ref =~ s/&.+?;//g;
	$note =~ s/◎//;
	$note =~ s/&.+?;//g;
	if ($ref =~ /none/) { $ref=''; }
	print "\n<gaiji>\n";
	print "  <cb>$cb</cb>\n";
	print "  <mojikyo>$d1</mojikyo>\n";
	print "  <entity>$ent</entity>\n";
	print "  <uni>$uni</uni>\n";
	print "  <des>$zu</des>\n";
	print "  <nor>$ty</nor>\n";
	print "  <ref>$ref</ref>\n";
	print "  <note>$note</note>\n";
	print "</gaiji>\n";
}
print "\n</gaijis>";
close O1;