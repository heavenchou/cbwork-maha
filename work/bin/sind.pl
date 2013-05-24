$crlfu="\x00\x0d\x00\x0a";
$tabu="\x00\x09";
require "utf8.pl";
print "#DIC1 ";
while(<>){
	chop;
	($ent, $ref) = split(/\t/);
	if ($ent eq $oldent){
		print "#", $ref;
	} else {
		print $crlfu, &toucs($ent),  $tabu, $ref;
	}
}