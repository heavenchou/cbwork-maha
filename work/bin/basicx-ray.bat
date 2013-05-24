@rem = '--*-Perl-*--
@echo off
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

$inw = 0;
#read configuration;
open (BAT, ">go.bat");
$cfg = shift;
if ($cfg eq ""){
	print "\t$0: Converts simple Markup to Basic Markup (XML)\n";
	print "Usage: $0 CFG.FILE\n";
	exit;
}

open(CFG, $cfg) || die "can't open $cfg!!\n";;
while(<CFG>){
	chop;
	($type, $file) = split(/=/, $_);
	$files{$type} = $file;
}

#regex for big5
$big5 = '[\xA1-\xFE][\x40-\x7E\xA1-\xFE]|[\x00-\x7F]';



#regex for gaiji expression
$pattern = << 'EOP';
		(									#capture open
		(?:髣|搪|礔)?
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char 匕 or parens expr (匕*矢)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?卍]
		\]
		(?:跪|竮)?
		)									#capture close
EOP

#regex for corr expression
$corrpat = << 'EOP';
#first part: gaiji or char or nothing or * of any of these
		\[
		(									#capture open
		(?:
		(?:									#atom open
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char 匕 or parens expr (匕*矢)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?卍]
		\]
		)									#atom close
		|
		[\xa1-\xfe][\x40-\xfe]
		|
		)*
		)									#capture close
		>									#this is it!
#second part: gaiji or char or nothing or * of any of these
		(									#capture open
		(?:
		\[
		(?:									#atom open
		\[
		(?:(?:\?|[\xa1-\xfe][\x40-\xfe]|\((?:[\xa1-\xfe][\x40-\xfe]|[\x28-\x2f\x40])+\))	#one char-element: char 匕 or parens expr (匕*矢)
		[\x2a-\x2f\x40])+							#together with the operator, maybe many times
		(?:\?|[\xa1-\xfe][\x40-\xfe]|\(.*?\))		#another char
		\]
		|
		\[
		\?[\xa1-\xfe][\x40-\xfe]			#this is for [?卍]
		\]
		)									#atom close
		|
		[\xa1-\xfe][\x40-\xfe]
		|
		)*
		)									#capture close
		\]
		
EOP

### 讀缺字檔 ###
open(T, $files{"gaiji"}) || die "can't open $files{\"gaiji\"}\n";
while(<T>){
	chop;
# 0006|[(王*巨)/木]                           |  M21123 |磲
#0247	&CI0005;	搪[打-丁+突]	唐突	&M012388;
#	($cb, $ent, $zu, $ty, $exm) = split(/\t/, $_);
#	$ty = "" if ($ty =~ /none/i);
#	$qz{$zu} = $ent;
#	$nr{$ent} = $ty if ($ty ne "none");
#	$cb{$zu} = $cb;
	next if (/^#/);
	($cb, $d1, $ent, $uni, $uent, $zu, $ty, $ref, $exm) = split(/\t/, $_);
	$ty = "" if ($ty =~ /none/i);
	$ty = "" if ($ty =~ /\x3f/);
	if ($ent =~ /^[\?\x80-\xfe]/){
		$ent ="&$d1;";
	}
	$gcnt++;
	die "line: $gcnt\t$_\n" if ($ent !~ /\&/);
	die if ($ty =~ /\?/);
	$qz{$zu} = $ent;
	$nr{$ent} = $ty;
#	$ent{$ent} = $_;
	$cb{$zu} = $cb;
}

### 讀來源檔 ###
open(T, $files{"laiyuan"}) || die "can't open laiyuan\n";
while(<T>){
#S:蕭鎮國
	chop;
	if (/^.:/){
		($key, $value) = split(/:/, $_);
		($c, $e) = split(/, /, $value, 2);
		$namc{$key} = $c; 
		$name{$key} = $e; 
	} else {
#4SJ    T1421-22-p0001 K0895-22 30 彌沙塞部和醯五分律(30卷)【劉宋 佛陀什共竺道生等譯】
		($ls, $sid, $k, $juan, $rest) = split(/\s+/, $_, 5);
		($tnum, $tvol, $d1, $tpage) = unpack("A6 A2 A1 A5", $sid);
		$rest =~ s/\([ 0-9].*//;
		$rest =~ s/$pattern/&rep($1)/egx;
		$tnum =~ s/-//;
		$tnum =~ s/T/n/;
		$tit{$tnum} = $rest;
		die "no title $_\n" if ($tnum eq "" && $tnum ne "");
#		print STDERR "$tnum \t$rest\n";
		$sid = $tnum;
		$sid =~ s/n//;
#		print STDERR "$tnum\t$sid\n";
		@ly = split(//, $ls);
		$outc = "";
		$oute = "";
		for $l (@ly){
			next if ($namc{$l} eq "");
			$outc .= "$namc{$l}，";
			$oute .= "$name{$l}, ";
		}
		$outc =~ s/， $//;
		$oute =~ s/, $//;
		$lyc{$sid} = $outc;
		$lye{$sid} = $oute;
	}
	
}


#[這-言+亦]

$x = 0;
#%qz =();
#open(T, $files{"titles"}) || die "can't open $files{\"titles\"}\n";
#while(<T>){
#	chop;
# T12-0374 K09-0105  G08-0107  大般涅槃經(40卷)【北涼 曇無讖譯】
#	s/^\s+//;
#	($sid, $title) = split(/\s+/, $_);
#	$title =~ s/\(.*//;
#	print STDERR $title, "\n";
#	$title =~ s/$pattern/&rep($1)/egx;
#	$sid =~ s/.*?N/n/;
#	$tit{$sid} = $title;
#}


$oldnum = 0;
$oldp = 0;
$x = "";

### 讀經文檔 ###
open(T, $files{"jingwen"}) || die "can't open jingwen\n";
while(<T>){
	chop;
	if ($_ eq "") { next; } # added by Ray 2000/1/27 11:50AM
	($aline, $text) = unpack("A22 A*", $_);
#T12n0374_p0365a01N║No. 374
	($vol, $num, $p, $sec, $line, $tag) = unpack("A3 A6 A5 A1 A2 A3", $aline);
	$tag =~ s/#//g;

#these tags are not used yet!	
#this line has characters in siddham script	
	$tag =~ s/H//;
#there are some images on this location	
	$tag =~ s/G//;

#	die if ((length($tag) > 1 )&& ($tag  !~ /W[ZP]/));
	$num =~ s/_//;
	$p =~ s/p//;
	if ($num ne $oldnum){
		print &checkopen("p", "jhead", "juan", "div1");
		print F "\n</body></text></tei.2>\n";
		close (F);
		open (F, ">$oldvol$oldnum.org") if ($oldvol ne "");
		print F "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
		print F "<!ENTITY desc \"\" >\n";
		open (N, ">$oldvol$oldnum.nor") if ($oldvol ne "");
		print N "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
		print N "<!ENTITY desc \"\" >\n";
		open (E, ">$oldvol$oldnum.ent") if ($oldvol ne "");
		print E "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
		print E "<!ENTITY desc \"\" >\n";
		for $k (sort(keys(%lq))){
#&MX000144;	[(匕/禾)*(企-止+米)]
			$e = $lq{$k};
			$n = $nr{$e};
			$e =~ s/\&|;//g;
#ent: Nicht normalisiert
			print F "<!ENTITY $e \"$k\" >\n";
#			print E "<!ENTITY $e \"<gaiji cb='CB$cb{$k}' des='$k' " ;
##changed entity to always CB (00-01-05)
			print E "<!ENTITY CB$cb{$k}  \"<gaiji cb='CB$cb{$k}' des='$k' " ;
#ent: normalisiert
			if ($n ne ""){
				print N "<!ENTITY $e \"$n\" >\n" ;
				print E "nor='$n' ";
			} else {
				print N "<!ENTITY $e \"$k\" >\n";
			}
			if ($e =~ /^M/){
				print E "mojikyo='$e'/>\" >\n";
			} else {
				print E "/>\" >\n"
			}
			
		}
		$oldnum = $num;
		$oldvol = $vol;
		%lq = ();
		close(F);
		%open = ();
		$injuan = 0;
		open (F, ">$vol$num.xml");
		print STDERR "$vol$num.xml\n";
		print BAT "call cparsxml.bat $vol$num $vol$num\n";
		select (F);
		&header ("$vol$num", $vol, $num, $tit{$num});
		print "<text><body>";
		$oldp = "$p$sec" if ($line ne "01");
	}
	if ("$p$sec" ne $oldp){
#		print STDERR "$oldp:$line-P${p}S${sec}..$num:$oldnum\n";
		$oldp = "$p$sec";
#<PB ed="T" id="T10.0302.0912c" n="0912c">
		$num =~ s/n//;
		$pb = "\n<pb ed=\"T\" id=\"$vol.$num.$p$sec\" n=\"$p$sec\"/>";
	} else {
		$pb = ""
	}
	# don't do this in the line that contains the number
	if ($tag ne "N"){
		$text =~ s/<([0-9][0-9])>/#$1#/g;
		$text =~ s/$corrpat/<corr sic="$1">$2<\/corr>/xg;
		$text =~ s/$pattern/&rep($1)/egx;
# wegen gaiji-tag
		$text =~ s/sic="&([^;]*);"/sic="$1"/g;
#		
		$text =~ s/\(/<note type="inline">/g;
		$text =~ s/\)/<\/note>/g;
		if ($text =~ /Ｐ/){
			$text =~ s/($big5)/&addp($1)/eg;
		}
		if ($text =~ /Ｚ/){
			$text =~ s/($big5)/&addp($1)/eg;
		}
		if ($text =~/\xf9[\xd6-\xdc]/){
			@ch = ();
 			push(@ch, $text =~ /([\xa1-\xfe][\x40-\xfe]|[\x00-\xfe])/g);
 			for $c (@ch){
 				$c = &rep2($c) if ($c=~/\xf9[\xd6-\xdc]/);
	 		}
 			$text = join("", @ch);
		}

#		$text =~ s/(\&[^;]*;)/&revrep($1)/eg;
	}
	$lb = "$pb\n<lb n=\"$p$sec$line\"/>";


	if ($open{"juan"} > 0 && $tag ne "J"){
		$juan =~ s/open">(.*卷.*?第)(.*)/&cjuan($1, $2)/se;
		$juan =~ s/open">(.*卷.*?)((上|中|下))/&cjuan($1, $2)/se;
		$juan =~ s/open">(.*一卷.*)/open" n="001">$1/s;
		if ($juan =~ /open">/){
			$juan =~ s/open">/open" n="001">/;
		}
		if ($juan =~ /open/){
			$injuan = 1;
		} else {
			$injuan = 0;
		}
#		print STDERR "juan: $juan\n";
#		 || /卷(上|中|下)/
		print "$juan</jhead></juan>";
		$open{"jhead"} = 0;
		$open{"juan"} = 0;
		$juan = "";
	}
	if ($open{"byline"} > 0 && $tag !~ /[AY]/){
#		print STDERR "$tag";
		print "</byline>";
		$open{"byline"} = 0;
	}
	if ($open{"head"} > 0 && $tag !~ /[DXQ]/){
#		print STDERR "$tag";
		print "</head>";
		$open{"head"} = 0;
	}
	
	 if ($tag =~ /^W/) {  #changed meaning of W 10.10.1999
		$tag =~ s/^W//;
		$tag = "_" if ($tag eq "");
	 	if ($inw == 0){
			print &checkopen ("p", "div1");
			print "<div1 type=\"W\">";
			print "<p>";
			$open{"div1"}++;
			$open{"p"}++;
			$inw = 1;
		}
	} else {
		$inw = 0;
	}

	# added by Ray 2000/1/27 11:50AM
	### 如果簡單標記裏有問號 ###
	if ($tag =~ /\?/) {
		$tag =~ s/\?//;
		$tag = "_" if ($tag eq "");
		$text = "<xx>" . $text;
	}

	if ($tag eq "N"){
#This needs some attention: "N"lines > 1 not yet handled!
		print "$lb";
#		if ($open{"head"} == 0){
			print "<head type=\"no\">";
#			$open{"head"}++;
#		} 
		print "$text";
		print "</head>";
	} elsif ($tag eq "X") {
		print "$lb";
		if ($open{"div1"} == 0){
			print "<div1 type=\"xu\"><head>";
			$open{"div1"}++;
			$open{"head"}++;
#added 990628, T11-12		
#not good .. 
#		} else {
#			print &checkopen("lg", "p");
#			print "</div1><div1 type=\"xu\"><head>";
		}
		print "$text";

	} elsif ($tag eq "D") {
		if ($open{"head"} == 0){
			print &checkopen("lg", "p", "div1");
		}
		print "$lb";
		if ($open{"div1"} == 0){
			print "<div1 type=\"pin\"><head>";
			$open{"div1"}++;
			$open{"head"}++;
		} 
		print "$text";
	} elsif ($tag eq "Q") {
		if ($open{"head"} == 0){
			print &checkopen("lg", "p", "div1");
		}
		print "$lb";
		if ($open{"div1"} == 0){
			print "<div1 type=\"other\"><head>";
			$open{"div1"}++;
			$open{"head"}++;
		} 
		print "$text";
	} elsif ($tag eq "A") {
		if ($oldtag =~ /YCE/){
			print "</byline>";
			$open{"byline"}--;
		}
		print "$lb";
		if ($open{"byline"} == 0){
			print "<byline type=\"Author\">";
			$open{"byline"}++;
		} 
		print "$text";
	} elsif ($tag eq "Y") {
		if ($oldtag =~ /ACE/){
			print "</byline>";
			$open{"byline"}--;
		}
		print "$lb";
		if ($open{"byline"} == 0){
			print "<byline type=\"Translator\">";
			$open{"byline"}++;
		} 
		print "$text";
	} elsif ($tag eq "C") {
		if ($oldtag =~ /YAE/){
			print "</byline>";
			$open{"byline"}--;
		}
		print "$lb";
		if ($open{"byline"} == 0){
			print "<byline type=\"Collector\">";
			$open{"byline"}++;
		} 
		print "$text";
	} elsif ($tag eq "E") {
		if ($oldtag =~ /YAC/){
			print "</byline>";
			$open{"byline"}--;
		}
		print "$lb";
		if ($open{"byline"} == 0){
			print "<byline type=\"Editor\">";
			$open{"byline"}++;
		} 
		print "$text";
	} elsif ($tag eq "P") {
		if ($open{"div1"} < 1){
			$lb .= "<div1 type=\"jing\">";
			$open{"div1"}++;
		}
		print &checkopen("head", "byline", "lg", "p");
		if ($injuan == 0){
			print "$lb<p type=\"W\">$text";
		} else {
			print "$lb<p>$text";
		}
		$open{"p"}++;
#	} elsif ($tag eq "WP") {
#		print &checkopen("head", "byline", "lg", "p");
#		print "$lb<p type=\"W\">$text";
#		$open{"p"}++;
#	} elsif ($tag eq "WZ") {
#		print &checkopen("head", "byline", "lg", "p");
#		print "$lb<p type=\"Wdharani\">$text";
#		$open{"p"}++;
	} elsif ($tag eq "PZ") {
		print &checkopen("p");
		if ($injuan == 0){
			print "$lb<p type=\"Wdharani\">$text";
		} else {
			print "$lb<p type=\"dharani\">$text";
		}
#		print "$lb<p type=\"dharani\">$text";
		$open{"p"}++;
	} elsif ($tag eq "Z") {
		if ($open{"div1"} < 1){
			$lb .= "<div1 type=\"dharani\">";
			$open{"div1"}++;
		}
		print &checkopen("head", "byline", "lg", "p");
		if ($injuan == 0){
			print "$lb<p type=\"Wdharani\">$text";
		} else {
			print "$lb<p type=\"dharani\">$text";
		}
#		print "$lb<p type=\"dharani\">$text";
		$open{"p"}++;
#L could be removed
	} elsif ($tag eq "L") {
		if ($open{"div1"} < 1){
			$lb .= "<div1 type=\"jing\">";
			$open{"div1"}++;
		}
		$text =~ s/^　//;
		$text =~ s/(　)+/<\/l><l>/g;
		print &checkopen("head", "byline", "p");
		if ($open{"lg"} > 0){
			$lg = "";
		} else {
			$lg = "<lg>";
		}
		print "$lb$lg<l>$text</l>";
		$open{"lg"}++;
		
	} elsif ($tag eq "S") {
		if ($open{"div1"} < 1){
			$lb .= "<div1 type=\"jing\">";
			$open{"div1"}++;
		}
		$text =~ s/^　//;
		$text =~ s/(　)+/<\/l><l>/g;
		print &checkopen("head", "byline", "p");
		if ($open{"lg"} > 0){
			$lg = "";
		} else {
			if ($injuan == 0){
				$lg =  "<lg type=\"W\">";
			} else {
				$lg = "<lg>";
			}
		}
		print "$lb$lg<l>$text</l>";
		$open{"lg"}++;
##
	} elsif ($tag eq "I") {
		if ($open{"div1"} < 1){
			$lb .= "<div1 type=\"jing\">";
			$open{"div1"}++;
		}
		$text =~ s/^　//;
		$text =~ s/(　)+/<\/item><item>/g;
		print &checkopen("head", "byline", "p");
		if ($open{"list"} > 0){
			$list = "";
		} else {
			if ($injuan == 0){
				$list =  "<list type=\"W\">";
			} else {
				$list = "<list>";
			}
		}
		print "$lb$list<item>$text</item>";
		$open{"list"}++;
##
	} elsif ($tag eq "s") {
		$text =~ s/^　//;
		$text =~ s/　\$//;
		$text =~ s/(　)+/<\/l><l>/g;
		print "$lb<l>$text</l></lg>";
		$open{"lg"} = 0;
#l could be removed
	} elsif ($tag eq "l") {
		$text =~ s/^　//;
		$text =~ s/(　)+/<\/l><l>/g;
		print "$lb<l>$text</l></lg>";
		$open{"lg"} = 0;
	} elsif ($tag =~  /^J/) {
		print &checkopen("lg", "p");
		if ($open{"juan"} > 0){
			$juan .= "$lb$text";
#			print "$lb$text";
		} else {
			if ($tag =~ /D/){
				$juan = "$lb<juan fun=\"open\"><jhead type=\"D\">$text";
			} else {
				$juan = "$lb<juan fun=\"open\"><jhead>$text";
			}
			$open{"jhead"}++;
			$open{"juan"}++;
		}
	} elsif ($tag eq "j") {
		print &checkopen("lg", "p");
		print "$lb<juan fun=\"close\" n=\"$x\"><jhead>$text";
		$open{"jhead"}++;
		$open{"juan"}++;
#	} elsif ($tag =~ /G/) {
#there are some images on this location	
#no action is taken upon encountering this tag	
#		print "$lb$text";
#	} elsif ($tag =~ /H/) {
#this line has characters in siddham script	
#no action is taken upon encountering this tag	
#		print "$lb$text";
	} elsif ($tag eq "_") {
		print "$lb$text";
	} else {
		die "$tag\nunrecognized tag: $_\n";
	}
	$oldtag = $tag;
}

print &checkopen("p", "jhead", "juan", "div1");
print F "\n</body></text></tei.2>\n";
close (F);
###
open (F, ">$oldvol$oldnum.org") if ($oldvol ne "");
print F "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
print F "<!ENTITY desc \"\" >\n";
open (N, ">$oldvol$oldnum.nor") if ($oldvol ne "");
print N "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
print N "<!ENTITY desc \"\" >\n";
open (E, ">$oldvol$oldnum.ent") if ($oldvol ne "");
print E "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
print E "<!ENTITY desc \"\" >\n";
for $k (sort(keys(%lq))){
#&MX000144;	[(匕/禾)*(企-止+米)]
	$e = $lq{$k};
	$n = $nr{$e};
	$e =~ s/\&|;//g;
#ent: Nicht normalisiert
	print F "<!ENTITY $e \"$k\" >\n";
	print E "<!ENTITY CB$cb{$k} \"<gaiji cb='CB$cb{$k}' des='$k' " ;
#ent: normalisiert
	if ($n ne ""){
		print N "<!ENTITY $e \"$n\" >\n" ;
		print E "nor='$n' ";
	} else {
		print N "<!ENTITY $e \"$k\" >\n";
	}
	if ($e =~ /^M/){
		print E "mojikyo='$e'/>\" >\n";
	} else {
		print E "/>\" >\n"
	}
	
}



open (E, ">ENT.TXT");
for $k (sort(keys(%qz))){
	print E "$qz{$k}\t$k\n";
}



sub checkopen{
	local (@op) = @_;
	for (@op){
		if ($open{$_} > 0){
			$open{$_} = 0;
			$_ = "</$_>";
		} else {
			$_ = "";
		}
	}
	return join("", @op);
}

sub header {
	local($file, $bd, $no, $title) = @_;
	local($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time());
	$today = sprintf("%4.4d%2.2d%2.2d/%2.2d:%2.2d:%2.2d", $year+1900, $mon+1, $day, $hour, $min, $sec);
	$no=~s/_|n//g;
	$lye = $lye{$no};
	$lyc = $lyc{$no};
	$no=~s/^0//;

#	$title =~ s/\\/\\\\xx/g;
#	print STDERR 
	$bd =~ s/T//;
#	print STDERR $title, "\n";
	print << "EOF";
<?xml version="1.0" encoding="big5" ?>
<?xml:stylesheet type="text/xsl" href="../dtd/cbeta.xsl" ?>
<!DOCTYPE tei.2 SYSTEM "../dtd/cbetaxml.dtd"
[<!ENTITY % ENTY  SYSTEM "${file}.ent" >
<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >
%ENTY;
%CBENT;
]>
<tei.2>
<teiheader>
	<filedesc>
		<titlestmt>
			<title>Taisho Tripitaka, Electronic version, No. $no $title</title>
			<respstmt>
				<resp>Electronic Version by</resp>
				<name>CBETA</name>
			</respstmt>
		</titlestmt>
	<editionstmt>
		<edition>Version 1.0 (Big5)</edition>
	</editionstmt>
	<publicationstmt>
		<distributor>
			<name>中華電子佛典協會 (CBETA)</name>
			<address>
				<addrline>cbeta\@ccbs.ntu.edu.tw</addrline>
			</address>
		</distributor>
		<availability>
			<p>Available for non-commercial use when distributed with this header intact.</p>
		</availability>
		<date>$date</date>
	</publicationstmt>
	<sourcedesc>
		<bibl>Taisho Tripitaka Vol. $bd, No. $no &desc;</bibl>
	</sourcedesc>
</filedesc>
<encodingdesc>
	<projectdesc>
		<p lang="en" type="ly">$lye</p>
		<p lang="zh" type="ly">$lyc</p>
	</projectdesc>
</encodingdesc>
<revisiondesc>
	<change>
		<date>$today</date>
		<respstmt><name>CW</name><resp>ed.</resp></respstmt>
		<item>Created initial TEI XML version with BASICX.BAT (00/01/05)</item>
	</change>
</revisiondesc>
</teiheader>
EOF
}
	
#replaces gaiji with entities
sub rep {
	local($quezi) = $_[0];
#	print STDERR "$quezi\t$qz{$quezi}\n";
	if ($qz{$quezi} eq ""){
		$x++;
		$y = sprintf("&MX%6.6d;", $x);
		$qz{$quezi} = $y;
		$revqz{$y} = $quezi;
	}
	$lq{$quezi}=$qz{$quezi};
#this returns M - number:
#	return "$qz{$quezi}";
#now it will return only CB-number
	return "&CB$cb{$quezi};";
}

sub revrep {
	local($quezi) = $_[0];
#	print STDERR "$quezi\n";
	if ($revqz{$quezi} eq ""){
		die "$quezi not found!!\n";
	}
	return "$revqz{$quezi}";
}

%xnum=(
	"一", "1",
	"二", "2",
	"三", "3",
	"四", "4",
	"五", "5",
	"六", "6",
	"七", "7",
	"八", "8",
	"九", "9",
	"○", "0",
	"十", "",
	"百", "",
);

sub exnum{
	local($_) = $_[0];
	return "1000" if ($_ eq "千");
	return "100" if ($_ eq "百");
	return "10" if ($_ eq "十");
	s/^千([^因[^佉)/10$xnum{$1}/;
	s/千([^因[^佉)/0$xnum{$1}/;
	s/^千/1/;
	s/^百十$/110/;
	s/十$/0/;
	s/^百([^也[^Q])/10$xnum{$1}/;
	s/百([^也[^Q])/0$xnum{$1}/;
	s/^百/1/;
	s/^([0-9])?十/${1}1/;
	s/百十/1/;
	s/([\xa1-\xfe][\x40-\xfe])/$xnum{$1}/g;
	return $_;
}

sub fig{
	local($loc) = $_[0];
		$loc =~ s/一/1/g;
		$loc =~ s/二/2/g;
		$loc =~ s/三/3/g;
		$loc =~ s/功|/4/g;
		$loc =~ s/五/5/g;
		$loc =~ s/六/6/g;
		$loc =~ s/七/7/g;
		$loc =~ s/八/8/g;
		$loc =~ s/九/9/g;
		$loc =~ s/^十$/10/g;
		$loc =~ s/之十$/\.10/;
		$loc =~ s/^十(.)/1$1/g;
		$loc =~ s/(.)十$/${1}0/g;
		$loc =~ s/之十/\.1/;
		$loc =~ s/十//g;
		$loc =~ s/百/100/g;
		$loc =~ s/○/0/g;
		$loc =~ s/\s+//g;
		$loc =~ s/之/\./;
		if (length($loc) == 4){
			substr($loc, 1, 1) = "";
		}
		if (length($loc) == 5){
			substr($loc, 1, 2) = "";
		}
		if (length($loc) == 6){
			substr($loc, 1, 3) = "";
		}
		return $loc;
}


sub addp {
	local($p) = $_[0];
	if ($p eq "Ｐ"){
#		print STDERR "$p\n";
		if ($open{"lg"} > 0){
			return "</l><l type=\"inline\">";
		} else {
#			print STDERR "open:", $open{"lg"}, "\n";
			return "</p><p type=\"inline\">";
		}
	} elsif ($p eq "Ｚ"){
#		print STDERR "$p\n";
		if ($open{"lg"} > 0){
			return "</l><l type=\"idharani\">";
		} else {
#			print STDERR "open:", $open{"lg"}, "\n";
			return "</p><p type=\"idharani\">";
		}
	} else {
		return $p;
	}
}

sub cjuan {
	local($c1, $c2) = @_;
	local($x2) = $c2;
	$c2 =~ s/\[[0-9（[0-9珠\]//g;
	$c2 =~ s/<note [^>]*>.*?<\/note>//;
	$c2 =~ s/<lb[^>]*>//;
	$c2 =~ s/\n//;
#	print STDERR "$c2\n";
	if ($c2 eq "上"){
		$x = 1;
		$jcnt = 1;
	} elsif($c2 eq "下" || $c2 eq "中"){
		$jcnt++;
		$x = $jcnt;
	} else {
		$x = &fig($c2);
	}
	$x = sprintf("%3.3d", $x);
#	print STDERR "$c1\t$c2\n";
	return "open\" n=\"$x\">$c1$x2";
}

sub rep2 {
	local($x2, $x1) = @_;
	return "$x1&M024261;" if ($x2 eq "碁");
	return "$x1&M040426;" if ($x2 eq "銹");
	return "$x1&M034294;" if ($x2 eq "裏");
	return "$x1&M005505;" if ($x2 eq "墻");
	return "$x1&M010527;" if ($x2 eq "恒");
	return "$x1&M026945;" if ($x2 eq "粧");
	return "$x1&M006710;" if ($x2 eq "嫺");
	return "$x1$x2";
}



__END__
:endofperl
