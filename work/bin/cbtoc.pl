$dir = "c:/release/hh2001";

%allfiles = (
"01 01AhanToc.htm" => "���t���� T01-02,25,33",
"02 02BenYuanToc.htm" => "���t�� T03-04",
"03 03BoRuoToc.htm" => "��Y���� T05-08,25,33,40,85",
"04 04FaHuaToc.htm" => "�k�س��� T09a,26a,33-34,40,46,85",
"05 05HuaYanToc.htm" => "���Y���� T09b-10,26a,35-36,45,85",
"06 06BaoJiToc.htm" => "�_�n���� T11-12a,26a,37,40b,85",
"07 07NiePanToc.htm" => "�I�n���� T12b,26a,37-38,40b,85",
"08 08DaJiToc.htm" => "�j������ T13,26a",
"09 09JingJiToc.htm" => "�g������ T14-17,19,21,26a,38-39,85",
"10 10MiJiaoToc.htm" => "�K�г��� T18-21,39,46",
"11 11VinayaToc.htm" => "�߳��� T22-24,40a,45,85",
"12 12PiTanToc.htm" => "�s�賡�� T26b-29,41,85",
"13 21ZhongGuanToc.htm" => "���[���� T30a,42,45,85",
"14 14YogacaraToc.htm" => "������� T30b-32,42-45,85",
"15 15LunJiToc.htm" => "�׶����� T32,44a,85",
"16 22PureLandToc.htm" => "�b�g�v�� T11-12a,26a,37,40b,47,85",
"17 17ChanToc.htm" => "�I�v�� T47-48,85",
"18 18HistoryToc.htm" => "�v�ǳ��� T49-52,54",
"19 19MiscToc.htm" => "�ƷJ���� T53-55,85",
"20 23DunHuangToc.htm" => "���׼g���� T85"
);

open O, ">$dir/common/CBToc.htm";
select O;
print << "XXX";
<html>
<body>
<basefont face="Times New Roman">
<h1>CBETA �g��</h1>
<ul>
XXX

for $key (sort keys %allfiles) {
	print '<li><a href="#', substr($key,3,2), '">', $allfiles{$key}, "</a>\n";
}
print "</ul>\n";
print "<hr>\n";
for $key (sort keys %allfiles) {
	$key =~ /^\d\d (.*)$/;
	$file = $1;
	print '<a name="', substr($key,3,2), '"></a>', "\n";
	open I, "$dir/$file" or die "open file error: $file\n";
	while (<I>) {
		s#/fontimg#../fontimg#g;
		print O;
	}
	close I;
}
print "</body></html>";
close O;