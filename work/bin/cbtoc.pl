$dir = "c:/release/hh2001";

%allfiles = (
"01 01AhanToc.htm" => "阿含部類 T01-02,25,33",
"02 02BenYuanToc.htm" => "本緣部 T03-04",
"03 03BoRuoToc.htm" => "般若部類 T05-08,25,33,40,85",
"04 04FaHuaToc.htm" => "法華部類 T09a,26a,33-34,40,46,85",
"05 05HuaYanToc.htm" => "華嚴部類 T09b-10,26a,35-36,45,85",
"06 06BaoJiToc.htm" => "寶積部類 T11-12a,26a,37,40b,85",
"07 07NiePanToc.htm" => "涅槃部類 T12b,26a,37-38,40b,85",
"08 08DaJiToc.htm" => "大集部類 T13,26a",
"09 09JingJiToc.htm" => "經集部類 T14-17,19,21,26a,38-39,85",
"10 10MiJiaoToc.htm" => "密教部類 T18-21,39,46",
"11 11VinayaToc.htm" => "律部類 T22-24,40a,45,85",
"12 12PiTanToc.htm" => "毗曇部類 T26b-29,41,85",
"13 21ZhongGuanToc.htm" => "中觀部類 T30a,42,45,85",
"14 14YogacaraToc.htm" => "瑜伽部類 T30b-32,42-45,85",
"15 15LunJiToc.htm" => "論集部類 T32,44a,85",
"16 22PureLandToc.htm" => "淨土宗類 T11-12a,26a,37,40b,47,85",
"17 17ChanToc.htm" => "禪宗類 T47-48,85",
"18 18HistoryToc.htm" => "史傳部類 T49-52,54",
"19 19MiscToc.htm" => "事彙部類 T53-55,85",
"20 23DunHuangToc.htm" => "敦煌寫本類 T85"
);

open O, ">$dir/common/CBToc.htm";
select O;
print << "XXX";
<html>
<body>
<basefont face="Times New Roman">
<h1>CBETA 經錄</h1>
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