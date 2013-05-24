#open(O, ">gaiji-m.txt" ) || die "can't open $gfile\n";
open(O, ">temp.txt" ) || die "can't open $gfile\n";
select O;

use Win32::ODBC;
my $cb,$zu,$ent,$mojikyo;
print STDERR "Reading Gaiji-m.mdb ....";
my $db = new Win32::ODBC("gaiji-m");
if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
while($db->FetchRow()){
	undef %row;
	%row = $db->DataHash();
	$des = $row{"des"};
	$uni = $row{"uni"};
	#print $row{"cb"}, $row{"des"}, "\n";
	if ($des ne "" and $uni ne "") {
		print $des, " -> U+", uc($uni), "\n";
	}
}
$db->Close();
print STDERR "ok\n";

close O;