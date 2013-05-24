require "add.plx";
$vol = shift(@ARGV);
$dir = shift(@ARGV);
print STDERR "$vol $dir\n";
$pat = '\xc0([\x30-\x39\x41-\x5a\x61-\x7a\xa0-\xbf]{3})|([0-9]{1,2})|(.)';
$pat1 = '[\x30-\xbf]{3}';

sub numerically { $a <=> $b; }

sub fig{
	local($loc) = $_[0];
		$loc =~ s/\&I-303431;/0/g;
		$loc =~ s/�@/1/g;
		$loc =~ s/�G/2/g;
		$loc =~ s/�T/3/g;
		$loc =~ s/�\|/4/g;
		$loc =~ s/��/5/g;
		$loc =~ s/��/6/g;
		$loc =~ s/�C/7/g;
		$loc =~ s/�K/8/g;
		$loc =~ s/�E/9/g;
		$loc =~ s/�Q/10/g;
		$loc =~ s/��/100/g;
		$loc =~ s/��/0/g;
		$loc =~ s/\s+//g;
		return $loc;
}


#require "ci2ce.plx";
open(F, "file4.txt");

while(<F>){
	chop;
#KanjiBase	Unicode	JOIN	KBOrg	CEF	Char	Unicode	UCOrg

	($kb, $uni, $join, $kborg, $cef, $char, $unic, $ucorg) = split;
	$c = $uni;
	next if ($c =~ /30A4A0/);
	next if ($c =~ /0000/);
	next if ($c =~ /0F0F0F/);
	$cx = sprintf("%c%c%c", hex(substr($c, 0, 2)) , hex(substr($c, 2, 2)), hex(substr($c, 4, 2)));
	$tar = $char if ($cef =~ /C0-/);
	$tar = "&$cef;" if ($cef =~ /C[3-7]-/);
	$ci2ce{$cx} = $tar if (!$ci2ce{$cx});
}

close(F);

open(F, "file4.txt");

while(<F>){
	chop;
#KanjiBase	Unicode	JOIN	KBOrg	CEF	Char	Unicode	UCOrg

	($kb, $uni, $join, $kborg, $cef, $char, $unic, $ucorg) = split;
	$c = $join;
#	next if ($c =~ /30A4A0/);
	next if ($c =~ /0000/);
	next if ($c =~ /0F0F0F/);
	$cx = sprintf("%c%c%c", hex(substr($c, 0, 2)) , hex(substr($c, 2, 2)), hex(substr($c, 4, 2)));
	$tar = $char if ($cef =~ /C0-/);
	$tar = "&$cef;" if ($cef =~ /C[3-7]-/);
	$ci2ce{$cx} = $tar if (!$ci2ce{$cx});
}

close(F);
open(F, "file4.txt");

while(<F>){
	chop;
#KanjiBase	Unicode	JOIN	KBOrg	CEF	Char	Unicode	UCOrg

	($kb, $uni, $join, $kborg, $cef, $char, $unic, $ucorg) = split;
	$c = $kb;
#	next if ($c =~ /30A4A0/);
	next if ($c =~ /0000/);
	next if ($c =~ /0F0F0F/);
	$cx = sprintf("%c%c%c", hex(substr($c, 0, 2)) , hex(substr($c, 2, 2)), hex(substr($c, 4, 2)));
	$tar = $char if ($cef =~ /C0-/);
	$tar = "&$cef;" if ($cef =~ /C[3-7]-/);
	$ci2ce{$cx} = $tar if (!$ci2ce{$cx});
}


opendir(THISDIR, $dir);
@allfiles = sort numerically readdir(THISDIR);
closedir(THISDIR);
for $file (@allfiles){
next if ($file =~ /^\./);
open(FILE, "$dir\\$file") || print STDERR "can't open $dir\\$file\n";
print STDERR "$dir\\$file\n";
while(<FILE>){


	next if (/^~/);
	chop;
	@chars = ();
	push(@chars, /$pat/g);
	$_ = "";
#	print STDERR join("--", @chars), "\n";
	for $x (@chars){
		if ($ci2ce{$x}){
			$x = $ci2ce{$x};
			$x = $add{$x} if ($add{$x} ne "");
			$_ .= $x;
		}
		elsif ($x =~ /$pat1/) {
			$x = sprintf("&I-%2.2X%2.2X%2.2X;", ord(substr($x, 0, 1)), ord(substr($x, 1, 1)), ord(substr($x, 2, 1)));
			$x = $add{$x} if ($add{$x} ne "");
			$_ .= $x 
		} else {
			$x = sprintf("[%2.2d]", $x) if ($x =~ /[0-9]/);
			$x = "[��]" if ($x =~ /\*/);
			$_ .= $x;
		}
#		print STDERR "$_\n";
		
	}
	
	if (/(.*)?�g��\s?:(.*)/){
		$ind = $1;
#		print STDERR "$2\n";
		$num = &fig($2);
		next;
	}
	
	s/^$ind//;
	
	if (/����\s?:(.*)/){
#		print STDERR "$1\n";
		$sz = &fig($1);
#		print STDERR "$sz\n";
		next;
	}
	
	if (/�g�W\s?:(.*)/){
#		$sz = &fig($1);
		next;
	}
    if (/�U\s+��/){
    	$col = "c";
		$ln = 0;
		next;
    }
    if (/��\s+��/){
    	$col = "b";
		$ln = 0;
		next;
    }
    if (/�W\s+��/){
    	$col = "a";
		$ln = 0;
		next;
    }
	next if (/^\s+?$/);    
	next if (/^$/);    
   
	$ln++;	
	printf("T%2.2dn%4.4d_p%4.4d$col%2.2d��$_\n", $vol, $num, $sz, $ln);
}
}
