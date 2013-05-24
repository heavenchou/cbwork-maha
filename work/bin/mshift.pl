$beshiftmojpattern = "(.[\xF0-\xF3])(.[\xF4-\xF7])";
$shiftmojpattern = "([\xF0-\xF3].)([\xF4-\xF7].)";
binmode(STDOUT);
$crlfu="\x0d\x00\x0a\x00";
$tabu="\x09\x00";
$bo = "\xff\xfe";
require("utf8.pl");
$m = "&M040812;";
$m = "&M073098;";
$m = "&M048305;";
$m = "&M000262;";
$m = "&M006209;";
$m = "&M021123;";
$z = &shiftm($m);

#print "$bo$z$crlfu";

print &toutf8($z), "\n";

$z =~ s/$beshiftmojpattern/&unshiftm($1, $2)/eg;

#$z = &beshiftm($m);
#$z =~ s/$beshiftmojpattern/&beunshiftm($1, $2)/eg;

#print "$z\n";

sub shiftm{
	my $m = shift;
	$m =~ s/\&|;|M//g;
	my $u1 = pack("s", ($m / 1024) + 0xF000 );
	my $u2 = pack("s", ($m % 1024) + 0xF400 );
	return "$u1$u2";
}
#0xF000 <= u1 <= 0xF3FF, 0xF400 <= u2 <= 0xF7FF

sub unshiftm{
	my $u1 = shift;
	my $u2 = shift;
	$u1 = unpack("n", $u1);
	$u2 = unpack("n", $u2);
	return (($u1 - 0xF000) * 1024) + ($u2 - 0xF400);
}

sub beshiftm{
	my $m = shift;
	$m =~ s/\&|;|M//g;
	my $u1 = pack("s", ($m / 1024) + 0xF000 );
	my $u2 = pack("s", ($m % 1024) + 0xF400 );
	return "$u1$u2";
}
#0xF000 <= u1 <= 0xF3FF, 0xF400 <= u2 <= 0xF7FF

sub beunshiftm{
	my $u1 = shift;
	my $u2 = shift;
	$u1 = unpack("s", $u1);
	$u2 = unpack("s", $u2);
	return (($u1 - 0xF000) * 1024) + ($u2 - 0xF400);
}
