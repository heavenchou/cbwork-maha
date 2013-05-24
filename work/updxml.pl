#update xml

@num = ("--", "一",  "二" , "三" , "四" , "五" , "六" , "七" , "八" , "九"  , "十"  ,
			"十一"  , "十二"  , "十三"  , "十四"  , "十五"  , "十六"  , "十七"  , "十八"  , "十九"  , "二十"  ,
			"二十一"  , "二十二"  , "二十三"  , "二十四"  , "二十五"  , "二十六"  , "二十七"  , "二十八"  , "二十九"  , "三十"  , 
			"三十一"  , "三十二"  , "三十三"  , "三十四"  , "三十五"  , "三十六"  , "三十七"  , "三十八"  , "三十九"  , 
			"四十"  ,  "四十一"  , "四十二"  , "四十三"  , "四十四"  , "四十五"  , "四十六"  , "四十七"  , "四十八"  , "四十九"  , 
			"五十"  ,  "五十一"  , "五十二"  , "五十三"  , "五十四"  , "五十五"  , "五十六"  , "五十七"  , "五十八"  , "五十九"  , 
			);

#$gfile = "j:\\bsin\\cbeta\\bin\\gaiji-m.txt";
$gfile = "c:\\cbeta\\bin\\gaiji-m.txt";

($path, $name) = split(/\//, $0);
push (@INC, $path);

push (@INC, "c:\\cbeta\\bin");

require "mjchar.plx";
#require "b52utf8.plx";

%ttf = (
    1 => "Mojikyo M101",
    2 => "Mojikyo M102",
    3 => "Mojikyo M103",
    4 => "Mojikyo M104",
    5 => "Mojikyo M105",
    6 => "Mojikyo M106",
    7 => "Mojikyo M107",
    8 => "Mojikyo M108",
    9 => "Mojikyo M109",
    10 => "Mojikyo M110",
    11 => "Mojikyo M111",
    12 => "Mojikyo M112",
    13 => "Mojikyo M113",
    14 => "Mojikyo M114",
    15 => "Mojikyo M115",
    16 => "Mojikyo M116",
    17 => "Mojikyo M117",
    18 => "Mojikyo M118",
    19 => "Mojikyo M119",
    20 => "Mojikyo M120",
    21 => "Mojikyo M121",
    22 => "Mojikyo M181",
    23 => "Mojikyo M182",
    24 => "Mojikyo M183",
);



%add = (
"&M024261;" => 1,
"&M040426;" => 1,
"&M034294;" => 1,
"&M005505;" => 1,
"&M010527;" => 1,
#"&M010528;" => 1,
"&M026945;" => 1,
"&M006710;" => 1,
);


$big5 = q{
[\x00-\x7F] # ASCII/CNS-Roman
| [\xA1-\xFE][\x40-\x7E\xA1-\xFE] # Big Five
};


open(T, $gfile) || die "can't open $gfile\n";

while(<T>){
	next if (/^#/);
	chop;
	($cb, $d1, $ent, $uni, $uent, $des, $ty, $ref, $exm) = split(/\t/, $_);
	$ty = "" if ($ty =~ /none/i);
	$ty = "" if ($ty =~ /\x3f/);
	if ($ent =~ /^[\?\x80-\xfe]/){
		$ent ="&$d1;";
	}
#	print STDERR "$zu\n";
	$g = "<gaiji cb='CB$cb' des='$des' ";
	if ($uent ne "") {
		$char = $uent;
		$uent =~ s/\&U-|;//g;
		$g .=  "uni='$uent' " ;
	} elsif ($ty ne ""){
		$g .= "nor='$ty' ";
		$char = $ty;
	} elsif ($ent =~ /M/){
#		$char = $mjchar{$c};
	} else {
		$char = $des;
	}
	if ($d1 =~ /M/ && $uent eq ""){
			$e = $d1;
#			die if ("&$d1;" ne $ent && $ent =~ /M/);
			$e =~ s/\&|;//g;
			$e =~ s/M//;
			$f = int($e / 5640) + 1;
			$tt = $ttf{$f};
			$c = ($e % 5640);
			$g .= "mojikyo='M$e' mofont='$tt' mochar='$mjchar{$c}'>";
			$char = $mjchar{$c} if ($ty eq "");
	} else {
		$g .= ">";
	}
	$g .= "$char</gaiji>";
#	print STDERR "$g\n";
	$cbx = "&CB${cb};";
	die if ($ty =~ /\?/);
	$qz{$zu} = $ent;
	$nr{$ent} = $ty;
	$ent{$ent} = $g;
	$cb{$cbx} = $g;
}



	





$ext = ".NEW";
$/="<lb";
$file = shift (@ARGV);
opendir(THISDIR, ".");
@allfiles = grep(/${file}$/i, readdir(THISDIR));
for $_ (@allfiles){
	$_ = uc($_);
}

closedir(THISDIR);
for $file (sort(@allfiles)){
	$ofile = substr($file, 0, index($file, ".")) . $ext;
	die if $ofile eq $file;
	print STDERR "$file -> $ofile\n";
	open(FILE, $file);
	open(OF, ">$ofile");
	select OF;
	while(<FILE>){
		s#\t##g;
		s#\<title\>(.*)\</title\>#&newtitle($1)#e if (index($_, "teiheader") > 0);
		s#\<name\>(.*)\</name\>#&newname($1)#eg;
		s#\<bibl\>(.*)\</bibl\>#&newbibl($1)#eg;
		s#\</revisiondesc\>\n#&addrev#e;
		s/\<edition\>Version/\<edition\>V/;
		s/ \(Big5\)//;
		s/\n//g;
		s#\\>[ \t]+\\<#\\>\\<#g;
		s/\>\t*\</\>\</g;
#		s/(\<p[ \>])/\n$1/g;
		s#\</p\>#\</p\>\n#g;
		$loc = substr($_, 4, 7);
		s/\<p([ \>])/\<p loc="[$loc]"$1/g if ($loc =~ /^[0-9]/);
		s#\</jhead\>#\</jhead\>\n#g;
		s#\</head\>#\</head\>\n#g;
		s#\</byline\>#\</byline\>\n#g;
		s#\</lg\>#\</lg\>\n#g;
		s#\</bibl\>#\</bibl\>\n#g;
		s#\</title\>#\</title\>\n# if (index($_, "teiheader") > 0);
		s#\</title\>\<respstmt\>#\</title\>\n\<respstmt\>#;
		s#\<date\>[^\<]*\</date\>#\<date\>\</date\>#;		
		s#\<addrline\>#\<addrline\> #;		
		s#\<titlestmt\>#\<titlestmt\>\n#;
		s#\</name\>#\</name\>\n#g;
#		s#\<name #\n\<name #g;
		s#by\</resp\>#by\</resp\>\n#;
		s#\</address\>#\</address\>\n#g;
		s#\</edition\>#\</edition\>\n#g;
		s#\</item\>#\</item\>\n#g;
		s#\?\>#\?\>\n#g;
		s#\<tei.2\>#\n\<tei.2\>#g;
		s/encoding="big5"/encoding="utf-8"/;
		s/(\&[^;]*;)/&rep($1)/eg;
		s/\[<.*?\]>/>/;
		
		print;
	}
	close (FILE);
	close (OF);
}


sub newtitle{
	my $title = shift;
	$titlec = $title;
	$titlec =~ s/^.* //;
	$titlec = "《$titlec》CBETA電子版";
	return "<title lang=\"zh\">$titlec</title><title lang=\"en\">$title</title>";
}

sub newname{
	my $name = shift;
	if ($name =~ /CBETA/){
		$namec = $name;
		return "<name lang=\"zh\">中華電子佛典協會 (CBETA)</name><name lang=\"en\">Chinese Buddhist Electronic Text Association (CBETA)</name>";
	} else {
		return "<name>$name</name>";
	}
	
}

sub newbibl{
	my $bibl = shift;
	$bibl =~ s/\&desc;//;
	($base, $vol, $num) = split(/Vol\.|No\./, $bibl);
	$num =~ s/^\s?0+//;
	$vol =~ s/^\s?,?0+//;
	$biblc = "大正新脩大藏經 第${num[$vol]}冊 No.$num" ;
	return "<bibl lang=\"zh\">$biblc</bibl><bibl lang=\"en\">Taisho Tripitaka Vol.$vol No.$num</bibl>";
}

sub addrev{
my $out =<< "EOF";
	<change>
		<date>19991105</date>
		<respstmt><name>CW</name><resp>ed.</resp></respstmt>
		<item>converted to new xml format</item>
	</change>
</revisiondesc>
EOF
return $out;
}

sub rep {
	my $ent = shift;
	if ($ent{$ent} ne ""){
		return $ent{$ent};
	} else {
		if ($cb{$ent} ne ""){
			return $cb{$ent};
		} else {
			return "" if ($ent eq "&desc;");
			return "" if ($ent eq "&lac;");

			if ($ent eq "&Amacron;") {return "&U-0100;";}
			if ($ent eq "&amacron;") {return "&U-0101;";}
			if ($ent eq "&ddotblw;") {return "&U-1E0D;";}
			if ($ent eq "&Ddotblw;") {return "&U-1E0C;";}
			if ($ent eq "&hdotblw;") {return "&U-1E25;";}
			if ($ent eq "&imacron;") {return "&U-012B;";}
			if ($ent eq "&ldotblw;") {return "&U-1E37;";}
			if ($ent eq "&Ldotblw;") {return "&U-1E36;";}
			if ($ent eq "&mdotabv;") {return "&U-1E41;";}
			if ($ent eq "&mdotblw;") {return "&U-1E43;";}
			if ($ent eq "&ndotabv;") {return "&U-1E45;";}
			if ($ent eq "&ndotblw;") {return "&U-1E47;";}
			if ($ent eq "&Ndotblw;") {return "&U-1E46;";}
			if ($ent eq "&ntilde;") {return "&U-00F1;";}
			if ($ent eq "&rdotblw;") {return "&U-1E5B;";}
			if ($ent eq "&sacute;") {return "&U-015B;";}
			if ($ent eq "&Sacute;") {return "&U-015A;";}
			if ($ent eq "&sdotblw;") {return "&U-1E63;";}
			if ($ent eq "&Sdotblw;") {return "&U-1E62;";}
			if ($ent eq "&tdotblw;") {return "&U-1E6D;";}
			if ($ent eq "&tdotnlw;") {return "&U-1E6D;";}
			if ($ent eq "&Tdotblw;") {return "&U-1E6C;";}
			if ($ent eq "&umacron;") {return "&U-016B;";}
			if ($ent eq "&eacute;") {return "&U-00E9;";}
			if ($ent eq "&ecirc;") {return "&U-00E9;";}
			if ($ent eq "&unknown;") {return "●";}
			return "碁" if ($ent eq "&M024261;");
			return "銹" if ($ent eq "&M040426;");
			return "裏" if ($ent eq "&M034294;");
			return "墻" if ($ent eq "&M005505;");
			return "恒" if ($ent eq "&M010527;");
			return "粧" if ($ent eq "&M026945;");
			return "嫺" if ($ent eq "&M006710;");
			die "$ent unknown entity!!\n";
		}
	}
}
