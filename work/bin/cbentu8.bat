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

# 修改記錄:
# 2000/4/12 不產生 *.nor, *.ut8, *.org, modified by Ray
# 2000/5/17 gaiji-m 改用Access

print STDERR "use odbc...";
use Win32::ODBC;
print STDERR "ok\n";

#$gfile = "gaiji-m.txt";
#$gfile = "gaiji-m.xml";

($path, $name) = split(/\//, $0);
push (@INC, $path);

#print STDERR "$path\n";

print STDERR "require mjchar.plx....";
require "mjchar.plx";
print STDERR "ok\n";

print STDERR "require b52utf8.plx....";
require "b52utf8.plx";
print STDERR "ok\n";

require "subutf8.pl";

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

%dia=(
"Amacron" => "Ā",
"amacron" => "ā",
"ddotblw"} = "ḍ",
"Ddotblw"} = "Ḍ",
"hdotblw"} = ".h";
"imacron"} = "ii";
"ldotblw"} = ".l";
"Ldotblw"} = ".L";
"mdotabv"} = "^m";
"mdotblw"} = ".m";
"ndotabv"} = "^n";
"ndotblw"} = ".n";
"Ndotblw"} = ".N";
"ntilde"}  = "~n";
"rdotblw"} = ".r";
"sacute"}  = "`s";
"Sacute"}  = "`S";
"sdotblw"} = ".s";
"Sdotblw"} = ".S";
"tdotblw"} = ".t";
"Tdotblw"} = ".T";
"umacron"} = "uu";
);

# added by Ray 2000/3/3 03:46PM
# 從 Jap.ent 讀入日文 M 碼放入 %add
print STDERR "Reading jap.ent ....\n";
open(T, "../dtd/jap.ent" ) || die "can't open jap.ent\n";
while (<T>) {
  if (/<!ENTITY (.+?) .*/) { 
    $add{"&$1;"} = 1; 
  }
}
close T;

$big5 = q{
[\x00-\x7F] # ASCII/CNS-Roman
| [\xA1-\xFE][\x40-\x7E\xA1-\xFE] # Big Five
};

#$path .= "\\";

readGaiji();

opendir(THISDIR, ".");

@allfiles = grep(/\.xml$/i, readdir(THISDIR));

#open FG, ">go.bat";

for $f (sort(@allfiles)){
	$f =~ /(.*)\.xml$/;
	$s = $1;
	#print FG "call cparsxml.bat $s $s\n";

	open(F, $f);
	$of = $f;
	$of =~ s/\.xm(?:l)?/\.ent/i;
	die "identical file\n" if ($f eq $of);
	print STDERR "$f --> $of\n";
	open(OF, ">$of");
	print OF "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
	$inTeiHeader = 1;
	while(<F>){
		if (/<\/teiHeader>/) { $inTeiHeader = 0; }
		if ($inTeiHeader and /^<!--/) {
			while (<F>) {
				chomp;
				if (/^-->$/) { last; }
			}
		}
		s/(&[^;]*;)/$arr{$1}++/eg;
		s/(?=[^&])(M[0-9]{6})(?=[^;])/$arr{"&$1;"}++/eg;
		s/(?=[^&])(CB[0-9]{4,5})(?=[^;\d])/$arr{"&$1;"}++/eg;
	}
	for $k (sort(keys(%arr))){
		$e = $k;
		$e =~ s/\&|;//g;
		if ($k =~ /(SD-\w{4})/){
			$cb = $1;
		} elsif ($k =~ /CB([a]?\d{4,5})/){
			$cb = $1;
			die "120 $k $cb not in quezi table!!\n" if (not exists $uni{$cb});
		} elsif ($k =~ /(M\d{6})/){
			$ex = $1;
			die "123 $k not in quezi table!!\n" if (not exists $cb{$ex} and $add{$k} eq "");
			$cb = $cb{$ex};
			next if ($add{$k} == 1);
		} elsif ($k =~ /(CI\d{4})/){
			$ex = $1;
			die "128 $k not in quezi table!!\n" if (not exists $cb{$ex});
			$cb = $cb{$ex};
		} elsif (exists $dia{$e}) {
			print OF "<!ENTITY $e \"" , $dia{$e}, "\" >\n";
			next;
		} else {
			$k = "" if ($k =~ /lac/);
			$k = "" if ($k =~ /desc/);
			$k =~ s/\&|;//g;
			print OF "<!ENTITY $e \"$k\" >\n";
			next;
		}
		next if ($e !~ /^[MCS]/);

		print OF "<!ENTITY $e \"<gaiji ";
		if ($e =~ /^SD/){  # 悉曇字
			print OF "cb='$cb' ";
		} else {
			$des = $des{$cb};
			print OF "cb='CB$cb' des='$des' " ;
			if ($uni{$cb} ne "") {
				$uent = $uni{$cb};
				print OF "uni='$uent' " ;
			}
			$s = $nor{$cb};
			if ($s ne ""){
				print OF "nor='$s' ";
			}
		}
		
		if ($e =~ /^M/){
			$e =~ s/M//;
			$f = int($e / 5640) + 1;
			$tt = $ttf{$f};
			$c = ($e % 5640);
			print OF "mojikyo='M$e' mofont='$tt' mochar='$mjchar{$c}'/>\" >\n";
		} elsif ($e =~ /^SD-(.*)/){  # 悉曇字
			my $s = $1;
			$s = pack("H4", $s);
			print OF "big5='$s'/>\" >\n";
		} else {
		  $d1 = $cb2m{$cb};
		  if ($d1 =~ /^M/){
			  $e = $d1;
			  $e =~ s/M//;
			  $f = int($e / 5640) + 1;
			  $tt = $ttf{$f};
			  $c = ($e % 5640);
			  print OF "mojikyo='M$e' mofont='$tt' mochar='$mjchar{$c}'/>\" >\n";
		  } else {
			  print OF "/>\" >\n";
			}
		}
	}
	%arr = ();
}

sub urep{
	my $c = shift;
	$c =~ s/($big5)/$b52utf8{$1}/gx;
	return $c;
}

sub readGaiji {
  my $cb,$zu,$ent,$mojikyo;
  print STDERR "Reading Gaiji-m.mdb ....";
  my $db = new Win32::ODBC("gaiji-m");
  if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
  while($db->FetchRow()){
    undef %row;
    %row = $db->DataHash();
    $cb      = $row{"cb"};       # cbeta code
    $mojikyo = $row{"mojikyo"};  # mojikyo code
    $zu      = b52utf8($row{"des"});      # 組字式
    $ent     = $row{"entity"};
    $uni     = $row{"uni"};

  	next if ($cb =~ /^#/);

  	$qz{$zu} = $ent;
  	$des{$cb} = $zu;
  	$cb{$ent} = $cb;
  	$cb2m{$cb} = $mojikyo;
  	$uni{$cb} = uc($uni);
  	$nor{$cb} = b52utf8($row{"nor"});
  }
  $db->Close();
  print STDERR "ok\n";
}

__END__
:endofperl
