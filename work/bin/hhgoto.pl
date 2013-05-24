$oldVol = "#";

open O, ">u:/work/hh2001/goto.js" or dir;
select O;
printHead();
open I, "sutralst.txt" or die;
while (<I>) {
	chomp;
	($vol, $num, $nam, $juan, $lb) = split /##/;
	if ($vol ne $oldVol) {
		if ($oldVol ne "#") {
			print "\t\t\treturn \"$oldNum\";\n";
		}
		$vol =~ /T(\d\d)/;
		print "\t\tcase $1:\n";
	} else {
		print "\t\t\tif (page<\"$lb\") return \"$oldNum\";\n";
	}
	$oldVol = $vol;
	$oldLb = $lb;
	$oldNum = $num;
	$num2pb{$num} = substr($lb,0,5);
}
print "\t}\n";
print "}\n";
print "function num2pb(num) {\n";
while ( ($key,$val) = each %num2pb) {
	print "\tif (num == \"$key\") return \"$val\";\n";
}
print "}\n";

print_num2vol();
close I;

print "\n";
print "function getBoo(num) {\n";
local @chms = qw(01AHan 02BenYuan 03BoRuo 04FaHua 05HuaYan 06BaoJi 07NiePan 08DaJi 09JingJi 10MiJiao 11Vinaya 12PiTan 13ZhongGuan 14Yogacara 15LunJi 16PureLand 17Chan 18History 19Misc 20Apoc);
open I, "BuLei.txt" or die;
%BuLeiDir=();
while (<I>) {
	chomp;
	($num, $nam) = split /##/;
	$BuLeiDir{$num}=$nam;
}
close I;

foreach $k (sort keys %BuLeiDir) {
	if (not exists($BuLeiDir{$k."001"})) { # 如果沒有下一層
		$i = substr($k,0,3);
		$chm = $chms[$i-1];
		$BuLeiDir{$k} =~ /^(\d{4}\w?)/;
		$num = $1;
		print "\tif (num == \"$num\") return \"$chm\";\n";
	}
}
print "}\n";
close O;

sub printHead {
	print <<'HEAD';
function go() {
	var vol,num,page,col,line;
	var col,url,boo;
	with (form1) {
		vol = t_vol.value;
		num = t_num.value;
		page = t_page.value;
		i = s_col.selectedIndex;
		col = s_col.options[i].value;
	}
	if (page!='') {
		if (page.length==1) page = "000" + page;
		if (page.length==2) page = "00" + page;
		if (page.length==3) page = "0" + page;
	}
	if (num=='') {
		num = getNum(vol,page+col+line);
		if (col=='') col='a';
	} else {
		var rs1 = num.match(/^(\d+)([a-zA-Z]?)$/);
		d = RegExp.$1;
		c = RegExp.$2;
		if (d.length==1) d = "000" + d;
		if (d.length==2) d = "00" + d;
		if (d.length==3) d = "0" + d;
		num = d + c;
		if (page=='') {
			page = num2pb(num);
			col='';
		} else {
			if (col=='') col='a';
		}
	}
	boo = getBoo(num);
	if (boo=="#") {
		alert("本冊經文未提供");
		return false;
	}

	if (vol=='') {
		vol = num2vol(num);
	} else {
		if (vol.length==1) vol = "0" + vol;
		vol = "T" + vol;
	}
	url = boo + ".chm::/" + vol + page + col + ".htm#" + page + col + line;
	location = url;
	return false;
}
	
function getNum(vol,page) {
	i = parseInt(vol);
	//alert("page="+page);
	switch (i) {
HEAD
}

sub print_num2vol {
	print << "XXX";
function num2vol (num) {
	if (num <= "0099") { return "T01"; }
	if (num < "0152") { return "T02"; }
	if (num < "0192") { return "T03"; }
	if (num < "0220a") { return "T04"; }
	if (num < "0220b") { return "T05"; }
	if (num < "0220c") { return "T06"; }
	if (num <= "0220o") { return "T07"; }
	if (num < "0262") { return "T08"; }
	if (num < "0279") { return "T09"; }
	if (num < "0310") { return "T10"; }
	if (num < "0321") { return "T11"; }
	if (num < "0397") { return "T12"; }
	if (num < "0425") { return "T13"; }
	if (num < "0585") { return "T14"; }
	if (num < "0656") { return "T15"; }
	if (num < "0721") { return "T16"; }
	if (num < "0848") { return "T17"; }
	if (num < "0918") { return "T18"; }
	if (num < "1030") { return "T19"; }
	if (num < "1199") { return "T20"; }
	if (num < "1421") { return "T21"; }
	if (num < "1435") { return "T22"; }
	if (num < "1448") { return "T23"; }
	if (num < "1505") { return "T24"; }
	if (num < "1519") { return "T25"; }
	if (num < "1545") { return "T26"; }
	if (num == "1545") { return "T27"; }
	if (num <= "1557") { return "T28"; }
	if (num <= "1563") { return "T29"; }
	if (num <= "1584") { return "T30"; }
	if (num <= "1627") { return "T31"; }
	if (num <= "1692") { return "T32"; }
	if (num <= "1717") { return "T33"; }
	if (num <= "1730") { return "T34"; }
	if (num <= "1735") { return "T35"; }
	if (num <= "1743") { return "T36"; }
	if (num <= "1764") { return "T37"; }
	if (num <= "1782") { return "T38"; }
	if (num <= "1803") { return "T39"; }
	if (num <= "1820") { return "T40"; }
	if (num <= "1823") { return "T41"; }
	if (num <= "1828") { return "T42"; }
	if (num <= "1834") { return "T43"; }
	if (num <= "1851") { return "T44"; }
	if (num <= "1910") { return "T45"; }
	if (num <= "1956") { return "T46"; }
	if (num <= "2000") { return "T47"; }
	if (num <= "2025") { return "T48"; }
	if (num <= "2039") { return "T49"; }
	if (num <= "2065") { return "T50"; }
	if (num <= "2101") { return "T51"; }
	if (num <= "2120") { return "T52"; }
	if (num <= "2122") { return "T53"; }
	if (num <= "2144") { return "T54"; }
	if (num <= "2184") { return "T55"; }
	return "T85";
}
XXX
}