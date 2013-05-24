#
# �b cbeta.cfg �ث��w xml_txt_root �� T??xml.txt ���Ҧb���|
# �����k:
#         cd c:/cbwork/work/bin
#         perl jktxt2htm.pl T15xml.txt
# ���G�G���� T??xml.htm �b xml_txt_root ���|��
#
$file=shift;
$file =~ /^(.*)\.txt/;
$htm_file = uc($1) . ".htm";
read_cfg();
$dir=$cfg{"xml_txt_root"};
$page='';

open I, "$dir/$file" or die "cannot open $dir/$file\n";
open O, ">$dir/$htm_file" or die "cannot open $dir/$htm_file";
select O;
print_html_head();
LINE: while(<I>) {
	chomp;
	if (/<ID>(.*)<\/ID>/) {
		$id=$1;
		if (substr($id,0,4) ne $page) {
			$page = substr($id,0,4);
			print STDERR "$page\n";
		}
		next;
	}
	if (/<XML>/) {
		while(<I>) {
			chomp;
			next LINE if (/<\/XML>/);
			$xml.=$_;
		}
	}
	if (/<SOURCE>/i) {
		$_ = <I>;
		chomp;
		$source = $_;
		$source =~ s#<s>##g;
		$_ = <I>;
		do1rec();
	}
}
print_html_end();
close O;
close I;

sub do1rec {
	print "<p>�հɽs���G$id</p>\n";
	$xml =~ s#<anchor id=\".*?\"/>##g;
	$xml =~ s#<lb n=\".*?\"/>##g;
	$xml =~ s#&lac;#�i�ʡj#g;
	$xml =~ s/<app n=\".*?\">(.*?)<\/app>/&rep($1)/eg;
	$xml='';
}

sub rep {
	$app=shift;
	$app =~ m#<lem>(.*?)</lem>#;
	$lem=$1;
	print '<table border="1" cellspacing="0" cellpadding="8">',"\n";
	print "<tr><td>�j����<td>$lem";
	$app =~ s#<lem>.*?</lem>##;
	while ($app =~ m#<rdg wit=\"(.*?)\">(.*?)</rdg>#) {
		$wit=$1;
		if ($wit eq '') { $wit="�H"; }
		$rdg=$2;
		$app =~ s#<rdg wit=\".*?\">.*?</rdg>##;
		print "\n<tr><td>$wit<td>$rdg";
	}
	print "</table>\n<p>�հɭ��G$source</p><hr>\n";
	return '';
}
	
sub print_html_head {
	print << "XXX";
<html>
<head>
</head>
<body>
XXX
}

sub print_html_end {
	print "</body>\n";
	print "</html>\n";
}

sub read_cfg {
	open CFG,"cbeta.cfg" or die "cannot open cbeta.cfg\n";
	while (<CFG>) {
		next if (/^#/); #comments
		chomp;
		($key, $val) = split(/=/, $_);
		$cfg{$key}=$val; #store cfg values
		print STDERR "$key\t$cfg{$key}\n";
	}
	close CFG;
}