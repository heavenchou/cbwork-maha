#
# sm2xml.pl
# 從簡單標記版 插入 "◎" 到 xml 版
# V 0.1, 2002/7/10 02:06PM written by Ray Chou
# V 0.2, 2002/10/9 03:26PM by Ray
# V 0.3, 2002/10/14 03:00PM by Ray
#
$sm_dir = "c:/cbwork/simple";    # 簡單標記版所在目錄
$xml_dir = "c:/cbwork/xml";      # xml 版所在目錄
$out_dir = "c:/release/new-xml"; # 輸出目錄
$log = "c:/temp/sm2xml.txt";

open LOG, ">$log" or die "cannot open $log\n";

mkdir($out_dir, MODE);

my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
$xml_text="";
for ($i=8; $i<=8; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$dir = "$sm_dir/$vol/new.txt";
	if (not -e $dir) { next; }

	print STDERR "$vol\n";
	
	open SM, "$dir" or die;

		$found=0;

		$opened_xml = "#";
		while ($sm=<SM>) {
			#print STDERR "27 $sm\n";
			if ($sm=~/^(T\d\dn\d{4})([_a-zA-Z])p(\d{4}[a-z])(\d\d)/) {
				$sutra_no = $1;
				$c = $2;
				$pb = "p$3";
				$lb = "$3$4";
				if ($c ne "_") {
					$sutra_no .= $c;
				}
				if ($sutra_no ne $opened_xml) {
					if ($found) {
						print $xml_text;
						close O;
						$found=0;
					}
				}
						
			}
			if ($sm =~ /^($big5)*◎/) {
				if ($found==0) {
					if ($opened_xml ne $sutra_no) {
						$found=1;
						open_xml();
					}
				}
				if ($sm =~ /◎\[(\d\d)\]/) {
					$a = $1;
					$a = "<anchor id=\"fn${vol}$pb$a\"/>";
					$xml_text =~ s/$a/◎$a/;
				} elsif ($sm =~ /\[(\d\d)\]◎/) {
					$a = $1;
					$a = "<anchor id=\"fn${vol}$pb$a\"/>";
					$xml_text =~ s/$a/$a◎/;
					$xml_text =~ s#(</p>\n?)($a◎)#$2$1#;
				} else {
					print LOG "雙圈前後無校勘符號：$sm";
				}
			}
		}
	if ($found) {
			print $xml_text;
			close O;
	}
	close SM;
}

sub open_xml {
	$opened_xml = $sutra_no;
	$f = "$xml_dir/$vol/$sutra_no.xml";
	open XML,"$f" or die "[39] cannot open $f, file=[$file]\n";
	print STDERR "read $f ....";
	$xml_text="";
	while (<XML>) {
		$xml_text .= $_;
	}
	close XML;
	print STDERR "ok\n";
	
	mkdir("$out_dir/$vol", MODE);
	$f = "$out_dir/$vol/$sutra_no.xml";
	open O, ">$f" or die;
	select O;
	print STDERR "=> $f\n";
}