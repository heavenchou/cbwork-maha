#CW 25.08.97
#printf("%c%c", 254, 255);
#print &toutf8("\x4e\x01\x4e\x02");

#print &toucs2(&toutf8("\x4e\x01"));



sub toutf8
{
	my $in = $_[0];
	my $old;
	# encode UTF-8
	my $uc;
	for $uc (unpack("n*", $in)) {
#        print "$uc\n";
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
	                chr(0x80 | ($uc & 0x3F));
	    } else {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    }
	}
	return $old;
}

sub toucs2
{
	local (@in) = (@_);
	local ($out) = "";
	if (defined $_[0]) {
	    my $bytes = shift @in;
	    $bytes =~ s/^[\200-\277]+//;  # can't start with 10xxxxxx
	    while (length $bytes) {
			if ($bytes =~ s/^([\000-\177]+)//) {
			    $out .= pack("n*", unpack("C*", $1));
			} elsif ($bytes =~ s/^([\300-\337])([\200-\277])//) {
			    my($b1,$b2) = (ord($1), ord($2));
			    $out .= pack("n", (($b1 & 0x1F) << 6) | ($b2 & 0x3F));
			} elsif ($bytes =~ s/^([\340-\357])([\200-\277])([\200-\277])//) {
			    my($b1,$b2,$b3) = (ord($1), ord($2), ord($3));
			    $out .= pack("n", (($b1 & 0x0F) << 12) |
	                         (($b2 & 0x3F) <<  6) |
					         ($b3 & 0x3F));
			} elsif ($bytes =~ s/^([\360-\367])([\200-\277])([\200-\277])([\200-\277])//) {
			    my($b1,$b2,$b3,$b4) = (ord($1), ord($2), ord($3), ord($4));
			    $out .= pack("N", (($b1 & 0x07) << 18) |
	                         (($b2 & 0x3F) <<  12) |
	                         (($b3 & 0x3F) <<  6) |
					         ($b4 & 0x3F));
			} else {
#		    	croak "Bad UTF-8 data";
			}
	    }
	} else {
	    $out = undef;
	}

    return $out;
}

1;