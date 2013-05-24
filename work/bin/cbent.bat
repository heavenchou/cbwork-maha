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
# v 0.1, debug, 2002/11/20 03:56PM by Ray
# v 0.2, CB碼取消四碼的, 2002/12/7 11:47AM by Ray
# v 0.3, lac-space, 2002/12/24 06:25PM by Ray
# v 0.4, 不產生 &unrec;, 2003/12/15 11:16上午 by Ray
# v 0.5, 2003/12/25 02:11下午 by Ray
#        <!ENTITY SD-xxxx "<gaiji cb='SD-xxxx' cbdia='....' udia='....' sdchar='..'/>" >
# v 0.6.1, 2003/12/28 09:41上午 by Ray
# v 0.7.1, 通用詞 &CI...; 增加 <gaiji cx='...'> 
# v 0.8, 2007/06/15 : 增加蘭札體 &RJ-xxxx; 的處理 , 格式仿悉曇字
# v 0.9, 2010/03/18 : &Uxxxx; 這類標準 unicode 字元不產生在 ent 檔中
# v 0.10, 2012/11/02 : 增加 <gaiji nor_uni="..."> , 這是通用的 unicode

#########################################################
# 初始化
#########################################################

print STDERR "use odbc .... ";
use Win32::ODBC;
print STDERR "ok\n";

#$gfile = "gaiji-m.txt";
#$gfile = "gaiji-m.xml";

($path, $name) = split(/\//, $0);
push (@INC, $path);

#print STDERR "$path\n";

require "cbetasub.pl";
print STDERR "require mjchar.plx .... ";
require "mjchar.plx";
print STDERR "ok\n";
print STDERR "require b52utf8.plx .... ";
require "b52utf8.plx";
print STDERR "ok\n";
print STDERR "require siddam.plx .... ";
require "siddam.plx";
print STDERR "ok\n";
print STDERR "require ranjana.plx .... ";
require "ranjana.plx";
print STDERR "ok\n";

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

# added by Ray 2000/3/3 03:46PM
# 從 Jap.ent 讀入日文 M 碼放入 %add
print STDERR "Reading jap.ent .... ";
open(T, "../dtd/jap.ent" ) || die "can't open jap.ent\n";
while (<T>) {
  if (/<!ENTITY (.+?) .*/) { 
    $add{"&$1;"} = 1; 
  }
}
close T;
print STDERR "ok\n";

$big5 = q{
[\x00-\x7F] # ASCII/CNS-Roman
| [\xA1-\xFE][\x40-\x7E\xA1-\xFE] # Big Five
};

#$path .= "\\";

readGaiji();
opendir(THISDIR, ".");
@allfiles = grep(/\.xml$/i, readdir(THISDIR));

#########################################################
# 主程式 -- 逐檔處理
#########################################################

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
	print OF "<?xml version=\"1.0\" encoding=\"big5\" ?>\n";
	$inTeiHeader = 1;
	%arr=();
	
	# 逐行讀取 XML
	
	while(<F>){
		if (/<\/teiHeader>/) { $inTeiHeader = 0; }
		if ($inTeiHeader and /^<!--/) {				# 過濾 <teiHeader> 裡面的註解
			while (<F>) {
				chomp;
				if (/^-->$/) { last; }
			}
		}
		s/(&[^;]*;)/\&ent_found($1)/eg;								# 把 &xxx; 放入 %arr 之中
		s/(?=[^&])(M[0-9]{6})(?=[^;])/\&ent_found("&$1;")/eg;		# 只有 Mxxxxxx , 而不是 &Mxxxxxx;
		#s/(?=[^&])(CB[0-9]{4,5})(?=[^;\d])/\&ent_found("&$1;")/eg;
		s/(?=[^&])(CB[0-9]{5})(?=[^;\d])/\&ent_found("&$1;")/eg;	# 只有 CBxxxxx , 而不是 &CBxxxxx;
	}
	
	# 把結果逐一處理並寫入輸出檔
	
	for $k (sort(keys(%arr))){
		$e = $k;
		$e =~ s/\&|;//g;
		
		# 取出並判斷類型
		
		if ($k =~ /(SD-\w{4})/){			# 悉曇體梵文
			$cb = $1;
		} elsif ($k =~ /(RJ-\w{4})/){		# 蘭札體梵文
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
		} elsif (exists $cb{$e}) {
			$cb = $cb{$e};					# 由缺字資料庫的 entity 找回 CB 欄位
			#edith modify 2005/3/4
			#print OF "<!ENTITY $e \"<gaiji cb='$cb' nor='", $nor{$cb}, "' uni='", $uni{$cb},  "'/>\" >\n";
			print OF "<!ENTITY $e \"<gaiji uniflag='" . $uniflag{$cb} . "' cb='$cb' nor='", $nor{$cb}, "' uni='", $uni{$cb},  "'/>\" >\n";
			next;
		} else {
			$k =~ s/\&|;//g;
			if (($k ne "unrec") && ($k ne "lac") && ($k ne "desc") && ($k ne "lac-space")) {	# 這些都在 cbeta.ent 定義了
				if($k !~ /^U/)	# &Uxxxx; 這種 unicode 格式也不要處理
				{
					print OF "<!ENTITY $e \"$k\" >\n";
				}
			}
			next;
		}
		next if ($e !~ /^[MCSR]/);		# 不是 MCSR 開頭的 entity 不理它
		
		print OF "<!ENTITY $e \"<gaiji ";
		if ($e =~ /^(SD|RJ)/){  				# 梵文悉曇體,蘭札體
			#edith modify 2005/3/4			
			#print OF "cb='$cb' ";
			print OF "uniflag='" .  "' cb='$cb' "
		}
		else {
			$des = $des{$cb};
			#edith modify 2005/3/4
			#print OF "cb='CB$cb' des='$des' " ;
			print OF "uniflag='" . $uniflag{$cb} ."' cb='CB$cb' des='$des' " ;
			if ($unicode{$cb} ne "") {
				$uent = $unicode{$cb};
				print OF "uni='$uent' " ;
			}
			if ($nor_uni{$cb} ne "") {
				$nor_uent = $uni{$cb};	# 因為 nor_uni 是 "字" , 所以要用 uni 欄位的內容, 那是編碼
				print OF "nor_uni='$nor_uent' " ;
			}
			$s = $nor{$cb};
			if ($s ne ""){
				print OF "nor='$s' ";
			}
			if (exists $cx{$e}) {
				print OF "cx='" . $cx{$e} . "' ";
			}
		}
		
		if ($e =~ /^M/){		# &M 碼要額外處理的資料
			$e =~ s/M//;
			$f = int($e / 5640) + 1;
			$tt = $ttf{$f};
			$c = ($e % 5640);
			print OF "mojikyo='M$e' mofont='$tt' mochar='$mjchar{$c}'/>\" >\n";
		}
		elsif ($e =~ /^SD\-(.*)/) {					# 悉曇字要額外處理的資料
			my $s = $1;
			if (exists $sd2b5{$s}) {
				print OF "big5='",$sd2b5{$s},"' ";		# 印出悉曇字的對應 big5 字
			}
			if (exists $sd2dia{$s}) {					# 印出悉曇字的羅馬轉寫字
				$cbdia=$sd2dia{$s};
				#$cbdia=~s/%/&#x25;/g;
				$udia=cbdia2unicode($cbdia);
				$cbdia=cbdia2smdia($cbdia);
				print OF "cbdia='$cbdia' ";
				print OF "udia='$udia' ";
			}
			$s = pack("H4", $s);
			print OF "sdchar='$s'/>\" >\n";
		}
		elsif ($e =~ /^RJ\-(.*)/) {  				# 蘭札體要額外處理的資料
			my $s = $1;
			if (exists $rj2b5{$s}) {
				print OF "big5='",$rj2b5{$s},"' ";		# 印出蘭札體的對應 big5 字
			}
			if (exists $rj2dia{$s}) {					# 印出蘭札體的羅馬轉寫字
				$cbdia=$rj2dia{$s};
				#$cbdia=~s/%/&#x25;/g;
				$udia=cbdia2unicode($cbdia);
				$cbdia=cbdia2smdia($cbdia);
				print OF "cbdia='$cbdia' ";
				print OF "udia='$udia' ";
			}
			$s = pack("H4", $s);
			print OF "rjchar='$s'/>\" >\n";
		}
		else {
			$d1 = $cb2m{$cb};		# CB 碼本身有 M 碼資訊
		 	if ($d1 =~ /^M/){
				$e = $d1;
				$e =~ s/M//;
				$f = int($e / 5640) + 1;
				$tt = $ttf{$f};
				$c = ($e % 5640);
				print OF "mojikyo='M$e' mofont='$tt' mochar='$mjchar{$c}'/>\" >\n";
		 	} 
			else {
				print OF "/>\" >\n";
			}
		}
	}
	%arr = ();
}

sub urep
{
	my $c = shift;
	$c =~ s/($big5)/$b52utf8{$1}/gx;
	return $c;
}

sub readGaiji
{
	#my $cb,$zu,$ent,$mojikyo,$cx;
	my $cb,$zu,$ent,$mojikyo,$cx,$uni_flag;	#edith modify 2005/3/4
	print STDERR "Reading Gaiji-m.mdb .... ";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow()){
		undef %row;
		%row = $db->DataHash();
		$cb      = $row{"cb"};       # cbeta code
		$mojikyo = $row{"mojikyo"};  # mojikyo code
		$zu      = $row{"des"};      # 組字式
		$ent     = $row{"entity"};
		$uni     = $row{"uni"};      # 內容是編碼 , 只要有 unicode 或 nor_uni, 就一定會有這個欄位
		$unicode = $row{"unicode"};	 # unicode 是標準的 unicode, 內容是編碼
		$nor_uni = $row{"nor_uni"};	 # nor_uni 是通用的接近字形unicode, 內容是 "字", 不是編碼
		$cx      = $row{"cx"};
		#edith modify 2005/3/4 uni_flag值用來判斷要不要使用 unicode 
		$uni_flag= $row{"uni_flag"};	
		if ($uni_flag eq "")	{$uni_flag="0";}
		
		next if ($cb =~ /^#/);

		if ($cb eq "") {
			$cb = $ent;
		}
		
		#print STDERR "272 $cb\n";
		
		if ($cx ne '') {
			$cx =~ s/&(.*?);/＆$1；/g;
			$cx{$ent}= $cx;
		}
		
		# 例如 CI0013 的 uni 欄位是 &#x9AE3;&#x9AE3;&#x9AF4;&#x9AF4;
		$uni =~ s/&#x//g;
		$unicode =~ s/&#x//g;

		$qz{$zu} = $ent;
		$des{$cb} = $zu;
		$cb{$ent} = $cb;
		$cb2m{$cb} = $mojikyo;
		#edith modify 2005/4/4 $uni{$cb} 裡的英文字不轉大寫
		#$uni{$cb} = uc($uni);
		$uni{$cb} = $uni;
		$unicode{$cb} = $unicode;
		$nor_uni{$cb} = $nor_uni;

		$nor{$cb} = $row{"nor"};		
		$uniflag{$cb}=$uni_flag;	#edith modify 2005/3/4		
	}
	$db->Close();
	print STDERR "ok\n";
}

sub ent_found
{
	my $ent=shift;
	$arr{$ent}++;
	return "";
}

__END__
:endofperl
