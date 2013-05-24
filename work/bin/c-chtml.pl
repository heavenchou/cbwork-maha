$gifdir="n:\\HTMLHelp\\images";
$reldate = "03/10/99";
$relver = "0.3";
$pid = 0;
$jid = 0;
$first = 1;
$cbeta = $0;
$cbeta =~ s/.c-chtml.*/\\/;
#require "file.plx";
$file = $ARGV[0];
$type = $ARGV[1];
if ($type eq "H"){
	$fonti = "<font color=\"blue\">";
	$fontc = "<font color=\"red\">";
	$fontj = "<font color=\"green\">";
	$fonte = "</font>";
} else {
	$fonti = "";
	$fontc = "";
	$fontj = "";
	$fonte = "";
}


#c:\cbeta\t10\T10N0280.sgml
$file =~ s/\.sgm/\.ent/;

open(E, $file);
while(<E>){
	chop;
	s/<!ENTITY //;
	s/" >//;
	($ent, $val) = split(/ CDATA "/);
	$nor{$ent} = $val;
}


sub expnor{
	local($e) = $_[0];
	return $nor{$e} if ($nor{$e} !~/]$/);
	$f = $e;
	$f =~ s/M-([0-9]{5})./M$1/;
	$img{$f}++;
	$misimg{$f}++ if (!$imglist{$f});
	return "<A HREF=javascript:showpic(\"images/$f.gif\")>$nor{$e}</A>";
}

opendir(THISDIR, $gifdir);
while ($g = readdir(THISDIR)){
	next if ($g !~ /\.gif/i);
	$g =~ tr/A-Z/a-z/;
	$g =~ s/\.gif//i;
	$imglist{$g}++;
#	print STDERR "$g\n";
}


while(<>){
	$cnt++;
	#file.plx
	s/\&(.*);/&expnor($1)/eg;
	next if (/<\/TEXT>/i);
	if (/DOCTYPE/){
		while(1){
			$_=<>;
			if (/\/TITLE>/){
				s/TITLE>/H1>/g;
				s/Taisho Tripitaka, Electronic version, //;
				s/\&(.*);/&expnor($1)/eg;
				s/<A HREF=.*?\.gif"\)>//ig;
				s/<\/A>//ig;
				$tit = $_;
				$tit =~ s/\(|\)//g;
				$tit =~ s/佛說//s;
				$mtit = $tit;
				$mtit =~ s/.* //;
				$mtit =~ s/<\/?H1>\n?//ig;
				$mtit =~ s/^佛說//;
#				print STDERR "$mtit\n";
			}
			if (/<P lang="en" type="ly">(.*)<\/P>/){
				$lye = $1;
			}
			if (/<P lang="zh" type="ly">(.*)<\/P>/){
				$lyc = $1;
			}
			
			if (/<BIBL>(.*)<\/SOUR/){
				$bibl = $1;
				($bibl =~ /Vol\. ([0-9]+).*N.\. ([0-9]*)([A-Za-z])?/) ? ($idn = "T${1}N${2}") : ($idn = "");
				die if ($idn eq "");
				$a = $3;
				$bd = "T$1";
				$tx = sprintf ("%4.4d", $2);
				if ($a ne ""){
					$idn = "${bd}$a$tx";
				} else {
					$idn = "${bd}N$tx$a";
				}
				$idn = uc($idn);
				$pg = $idn;
#				print STDERR "$idn\n";
#				die;
				$ltit = $tit;
				$ltit =~ s/<\/?H1>\n?//ig;
				($bibl =~ m#(<P>.*</P>)#) ? ($anm = $1) : ($anm = "");
			}
			
			last if (/<TEXT><BODY>/);
		}
		$_=<>;
	}
	s/\[[0-9（[0-9珠\]//g;
	s/<[0-9][0-9]>//g;
	if (/<LB n="([0-9a-c]{5})([0-9]{2})/){
		$lbn = "$1$2";
		$pg = lc($1);
		if ($first == 1){
			$first = 0;
				&startx;
				print $tit;
				$tit =~ s/<\/?H1>\n?//sig;
				print TOC << "EOF";
	</UL>
		<LI> <OBJECT type="text/sitemap">
				<param name="Name" value="$tit">
				<param name="Local" value="${bd}.chm::/$idn.htm">
			</OBJECT>
	<UL>
EOF
		$ooldpg = $oldpg;
		$oldpg = $pg;
}
	}
	s/\[lac\]//ig;
	s/\&lac;//ig;
	s/lac//ig;
	s/--//g;
	s/<note.*?foot.*?">.*?<\/note>//ig;
	s/<note.*?inline">/(/ig;
	s#</note>#)#ig;
	s/<APP[^>]*>//ig;
	s#</APP>##ig;
	s#<RDG[^>]*>.*?</RDG>##ig;
	s#<GLOSS[^>]*>[^<]*</GLOSS>##ig;
	s#</?ITEM>#　#ig;
	s#</?LIST>##ig;
	s#<LEM>##ig;
	s#</LEM>##ig;
	s#<SKGLOSS>##ig;
	s#</SKGLOSS>##ig;
	s#<TERM>##ig;
	s#</TERM>##ig;
	s#title#h2#g;


	s/\[[0-9]{2}\]//g;	
	s/<[0-9]{2}>//g;	
	s/<corr[^>]*>/$fontc<span class="corr">/gi;
	s/<\/corr>/<\/span>$fonte/gi;
	if (/<head>(.*)<\/head>/i){
		$xx = $1;
		$xx =~ s#<span [^>]*>##;
		$xx =~ s#</span>##;
		$xx =~ s/<LB [^>]*>//ig;
		$xx =~ s/<PB[^>]*>//ig;
		$xx =~ s/<note[^>]*>[^<]*<\/note>//ig;
		$xx =~ s/\(.*?\)//;
#		print STDERR "$xx\n";
		$xx =~ s/^(.*)第(.*)/&rep($1, $2)/e;
		$xx =~ s/<[^>]*>//g;
#		print STDERR $mtit, "\n";
		$xx =~ s/$mtit//;
#		$xx =~ s/\) //;

		$id++;
		$pid++;
		$pid = sprintf("%4.4d", $pid);
		$px = << "EOF";
			<LI> <OBJECT type="text/sitemap">
				<param name="Name" value="$xx">
				<param name="Local" value="${bd}.chm::/$pg.htm#id$tx$id">
				</OBJECT>
EOF
		if ($xx =~ /序$/){
			print TOC $px;
		} else {
			$pu{$pid} = $px if ($xx !~/No/);
		}
		if ($type eq "H"){
			print HTM "<A HREF=\"$idn/$pg.htm#id$tx$id\">$xx</A></BR>\n" if ($xx !~/No/);
		} else {			
			print HTM "<A HREF=\"${bd}.chm::/$pg.htm#id$tx$id\">$xx</A></BR>\n" if ($xx !~/No/);
		}
		$xx =~ s/[0-9\.]+//;
		$xx =~ s/^\s//;
		print IDX << "EOF";
		<LI> <OBJECT type="text/sitemap">
			<param name="Name" value="$xx">
			<param name="Local" value="$pg.htm">
			</OBJECT>
EOF
	}
	s/<head>([^<]*)/<h2><A NAME="id$tx$id">$1<\/A>/ig;
	s/<L>/　/g;
#	s/<L>/<span class="l">/g;
	s/<\/L>$/<BR>/;
#	s/<LG [^>]*>/<span class="lg">/ig;
	s/<\/LG>/　/ig;
	s/<byline.*?>/$fontc<span class="byline">　/ig;
	s/<\/byline>/<\/span>$fonte　<br>/ig;
#	$lbn = $1;
	if (/<h2/){
		$h = $_;
		$h =~ s/^.*<h2>//i;
		$h =~ s#</h2>##ig;
		$h =~ s#</head>\n?##i;
		$h =~ s#<A[^>]*>##i;
		$h =~ s#</A>##i;
		$h =~ s#<span [^>]*>##i;
		$h =~ s#</span>##i;
		$h =~ s/<LB[^>]*>//ig;
		$h =~ s/<PB[^>]*>//ig;
#		$h =~ s/<note[^>]*>[^<]*<\/note>//ig;
		$h =~ s/<note[^>]*/(/ig;
		$h =~ s/<\/note>/)/ig;
#		$h =~ s/\(//g;
#		$h =~ s/\)//g;
		$h =~ s/<[^>]*>//g;
	}
	s/<\/head/<\/h2/ig;
	s/<LB\sn=("[0-9a-c]*")(>.*)\n/<A \nid=$1$2<\/A>/i;
	if (/<juan fun="close"[^>]*>/i){
		if ($type eq "H"){
			$jloc =~ s/${bd}.chm::/$idn/;
			print HTM "</TD><TD><A HREF=\"$jloc\">$jtmp</A></TD></TR>\n<TR><TD>";
		} else {
			print HTM "</TD><TD><A HREF=\"$jloc\">$jtmp</A></TD></TR>\n<TR><TD>";
		}
	}
	
	if (/<juan fun="open"[^>]*>(.*)?<\/juan/i){
		$id++;
		$jid++;
		$jid = sprintf("%4.4d", $jid);
		$tmp = $1;
		$tmp =~ s/<LB[^>]*>//ig;
		$tmp =~ s/<PB[^>]*>//ig;
		$tmp =~ s/<note[^>]*>[^<]*<\/note>//ig;
		$tmp =~ s/<corr[^>]*>//ig;
		$tmp =~ s/<\/corr>//ig;
		$tmp =~ s/^(.*)第(.*)/&rep($1, $2)/e;
		$tmp =~ s/<[^>]*>//g;
		$jloc = "${bd}.chm::/$pg.htm#id$tx$id";
		$jtmp = $tmp;
		
		$jx = <<"EOF";
			<LI> <OBJECT type="text/sitemap">
				<param name="Name" value="$tmp">
				<param name="Local" value="${bd}.chm::/$pg.htm#id$tx$id">
				</OBJECT>
EOF
		$ju{$jid} = $jx;
	}
	if (/<juan fun="open" n="([^"]*)"/i){
		$j = $1;
	}
	s/<juan fun="open"[^>]*>([^<]*)/$fontj<h2 class="juan"><A NAME="id$tx$id">$1<\/A>/i;
	s/<\/juan>/<\/h2>$fonte/i;# if (/open/);
	s/<juan fun="close"[^>]*>/<h2>/i;

	s/<h2/<h2 id="$lbn"/ig;
	s/<A NAME/<A id="$lbn" NAME/ig;


#<PB ed="T" id="T09.0262.0001a" n="0001a">
	if (/<PB .*id="(T[0-9]{2})\.([0-9]{4}[a-z]?)\.([0-9]{4}[a-d])/i){
		$vol = $1;
		$no = $2;
		$pg = lc($3);
		if ($first == 1){
			$first = 0;
				&startx;
				print $tit;
				$tit =~ s/<\/?H1>\n?//ig;
				print TOC << "EOF";
	</UL>
		<LI> <OBJECT type="text/sitemap">
				<param name="Name" value="$tit">
				<param name="Local" value="${bd}.chm::/$idn.htm">
			</OBJECT>
	<UL>
EOF
}
	if (!$arr{$pg}){
		print IDX<< "EOF";
		<LI> <OBJECT type="text/sitemap">
			<param name="Name" value="${bd}-$pg">
			<param name="Local" value="$pg.htm">
			</OBJECT>
EOF
		$arr{$pg}++;
		print "<HR>";
		print "<A HREF=\"$ooldpg.htm\">上頁</A>" if ($ooldpg ne "");
		print "﹏@﹏@<A HREF=\"$pg.htm\">下頁</A> \n" if ($pg ne "0001a");
		$ooldpg = $oldpg;
		$oldpg = $pg;
		$js = "($j)" if ($j ne "");
		if ($type eq "H"){
			if ($bd =~ /T0[5-8]/){
				$bds = "T05.htm";
				$bds = "T05.htm#mark4" if ($bd eq "T08");
			} else {
				$bds = "$bd.htm";
			}
			print "　<A HREF=\"../$idn.htm\">$ltit</A>　\n";
			print "　<A HREF=\"../../$bds\">第${cbd}冊</A>　\n";
			print "</BODY></HTML>\n";
			close(CHM);
			open(CHM, ">HTML\\$bd\\$idn\\$pg.htm");
			select(CHM);
			$logo = "<IMG align=\"center\" SRC=\"../../images/logo1.jpg\">　　";
			print << "EOF";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<script LANGUAGE="JAVASCRIPT">
<!--
function showpic(name)
{window.open("../../" + name,"pic","width=30,height=25,scrollbars,resizable");}
//-->
</script>
<TITLE>CBETA 電子大藏經</TITLE>
</head>
<BODY id="$bd">
EOF
		} else {
			$logo = "";
			print << "EOF";
<!---New Topic--->
<OBJECT type="application/x-oleobject" classid="clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e">
<param name="New HTML file" value="$pg.htm">
<param name="New HTML title" value="$no $js $xx">
</OBJECT> 
<OBJECT type="application/x-oleobject" classid="clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e">
	<param name="ALink Name" value="$vol-$pg">
	<param name="ALink Name" value="$pg">
	<param name="ALink Name" value="$vol.$no.$pg">
</OBJECT>
EOF
		}
	print "<b>$tit $js $h, p$pg</b><hr>\n";
	$ntm = "$fonti<i class=\"old\">$oldlast$last</i>$fonte";
	$ntm =~ s/\n//sg;
#	chop($ntm);
	print "$ntm";
#	print STDERR "$ntm";
#	print STDERR "$pg\n";
	}
	}
	s/<PB [^>]*>//;
	s/TRAILER/P/ig;
	s/\(xx\)//g;
	s/\n//sg;
	print;
	$oldlast = $last;
	$last = $_;
}

print HTM "</TABLE></BODY></HTML>\n";

if ($pid > 1 && $jid > 1){
	print TOC <<"EOF";
	<LI><OBJECT type="text/sitemap">
				<param name="Name" value="品">
		</OBJECT>
	<UL>
EOF
	for $i(sort(keys(%pu))){
		print TOC $pu{$i};
	}
	print TOC "\t</UL>\n";
	print TOC <<"EOF";
	<LI><OBJECT type="text/sitemap">
				<param name="Name" value="卷">
		</OBJECT>
	<UL>
EOF

	for $i(sort(keys(%ju))){
		print TOC $ju{$i};
	}
	print TOC "\t</UL>\n";
} else {
	for $i(sort(keys(%pu))){
		print TOC $pu{$i};
	}
	for $i(sort(keys(%ju))){
		print TOC $ju{$i};
	}
	
}

#print TOC "</UL></BODY></HTML>";
#print IDX "</UL></BODY></HTML>";



sub startx{
 	$cbd = $bd;
	$cbd =~ s/T//i;
 	$cbd =~ s/^0//;
 	$cbd =~ s/10/十/;
 	$cbd =~ s/0/十/;
 	$cbd =~ s/1/一/g;
	$cbd =~ s/2/二/g;
	$cbd =~ s/3/三/g;
	$cbd =~ s/4/四/g;
	$cbd =~ s/5/五/g;
	$cbd =~ s/6/六/g;
	$cbd =~ s/7/七/g;
	$cbd =~ s/8/八/g;
	$cbd =~ s/9/九/g;
	$cbd =~ s/0/○/g;
	open (ENT, $file) || die "can't open $idn.nor\n";
	while(<ENT>){
		chop;
#<!ENTITY CB-0006 CDATA "[(王*巨)/木]"  >
		($ent, $rep, $rest) = split(/ CDATA /);
		$ent =~ s/<!ENTITY //g;
		$rep =~ s/^"//;
		$rep =~ s/" .*$//;
#		print STDERR "$ent\t$rep\n";
		$ent{$ent} = $rep;
	}
#die;	
	if ($type ne "H"){

	if (open (HHP, "HTMLHELP\\$bd.hhp")){
	 	open (HHP, ">>HTMLHELP\\$bd.hhp");
	 	print HHP "$idn.htm\n";
	} else {
	 	open (HHP, ">HTMLHELP\\$bd.hhp");
	 	print HHP << "EOF";
[OPTIONS]
Compatibility=1.1
Compiled file=$bd.chm
Contents file=${bd}Toc.hhc
Default Window=CAN
Default topic=${bd}.htm
Display compile progress=Yes
Full-text search=Yes
Index file=${bd}Ind.hhk
Language=0x404 Chinese (Taiwan)
Title=${bd} 

[WINDOWS]
CAN="CBETA 電子大藏經","${bd}Toc.hhc","${bd}Ind.hhk","Default.htm","Default.htm",,,,,0x23420,211,0x304e,,,,,,,,0


[FILES]
Default.htm
cbintr.htm
cbintr_e.htm
logo1.jpg
dialog.htm
dialog1.htm
${bd}.htm
$idn.htm
EOF
	}
	
	

	if (open (TOC, "HTMLHELP\\${bd}Toc.hhc")){
		open (TOC, ">>HTMLHELP\\${bd}Toc.hhc");
	}
	 else {
	 	open (JS, "${cbeta}search.js");
	 	open (JSO, ">HTMLHELP\\search.js");
	 	while(<JS>){
	 		print JSO $_;
	 	}
	 	close(JSO);
	 	open (JS, "${cbeta}Default.htm");
	 	open (JSO, ">HTMLHELP\\Default.htm");
	 	while(<JS>){
	 		print JSO $_;
	 	}
	 	close(JSO);
	 	open (JS, "${cbeta}dialog.htm");
	 	open (JSO, ">HTMLHELP\\dialog.htm");
	 	while(<JS>){
	 		print JSO $_;
	 	}
	 	close(JSO);
	 	open (JS, "${cbeta}dialog1.htm");
	 	open (JSO, ">HTMLHELP\\dialog1.htm");
	 	while(<JS>){
	 		print JSO $_;
	 	}
	 	close(JSO);
	 	open (JS, "${cbeta}cbeta.css");
	 	open (JSO, ">HTMLHELP\\cbeta.css");
	 	while(<JS>){
	 		print JSO $_;
	 	}
	 	close(JSO);
#cbintr.htm
#logo1.jpg
	 	open(JS, "${cbeta}cbintr.htm");
	 	open (JSO, ">HTMLHELP\\cbintr.htm");
	 	while(<JS>){
	 		print JSO;
	 	}
	 	close(JSO);
	 	open(JS, "${cbeta}cbintr_e.htm");
	 	open (JSO, ">HTMLHELP\\cbintr_e.htm");
	 	while(<JS>){
	 		print JSO;
	 	}
	 	close(JSO);
	 	open(JS, "${cbeta}logo1.jpg");
	 	binmode(JS);
	 	open (JSO, ">HTMLHELP\\logo1.jpg");
	 	binmode(JSO);
	 	while(<JS>){
	 		print JSO;
	 	}
	 	close(JSO);
	 	

		open (TOC, ">HTMLHELP\\${bd}Toc.hhc");
print TOC << "EOF";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta name="GENERATOR" content="PERL C-CHTML.PL">
<!-- Sitemap 1.0 -->
</HEAD><BODY>
<UL><UL>
EOF
	}
	if (open (IDX, "HTMLHELP\\${bd}Ind.hhk")){
		open (IDX, ">>HTMLHELP\\${bd}Ind.hhk");
	}
	 else {
		open (IDX, ">HTMLHELP\\${bd}Ind.hhk");
print IDX << "EOF";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta name="GENERATOR" content="PERL C-CHTML.PL">
<!-- Sitemap 1.0 -->
</HEAD><BODY>
<UL>
EOF
	}
}
	if ($type eq "H"){
		mkdir ("HTML\\$bd", 1);
		open(HTM, ">HTML\\$bd\\$idn.htm");
		$ban = "上線";
		$bane = "Online Version";
		$logo = "../images/logo1.jpg";
		$link = "$idn/$pg.htm";
	} else {
		open(HTM, ">HTMLHELP\\$idn.htm");
		$ban = "HTMLHelp";
		$bane = "HTMLHelp";
		$logo = "logo1.jpg";
		$link = "${bd}.chm::/$pg.htm";
	}
	print HTM <<"EOF";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<TITLE>CBETA 電子大藏經 $pg</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta name="GENERATOR" content="PERL C-CHTML.PL">
</HEAD><BODY>
<H2><IMG align="center" SRC="$logo"> 電子大藏經</H2>
<P>
<UL>
<LI>大正新脩大藏經第${cbd}冊 <A HREF="$link">$ltit</A>
<LI>V $relver (Big5) ${ban}版，完成日期：$reldate
<LI>本資料庫由中華電子佛典協會（CBETA）依大正新脩大藏經所編輯
<LI>比對資料來源﹕$ly
<LI>本資料庫可自由免費流通，詳細內容請參閱 <A HREF="cbintr.htm">【中華電子佛典協會資料庫基本介紹】</A>
</UL>
<UL>
<LI> Taisho Tripitaka Vol. $bd, <A HREF="$link">$ltit</A>
<LI> Version $relver (Big5) $bane, Release Date: $reldate
<LI> Distributor: Chinese Buddhist Electronic Texts Association (CBETA)
<LI> Source material obtained from: $lye
<LI> Distributed free of charge. For details, please refer to <A HREF="cbintr_e.htm">The Brief Introduction of CBETA DATABASE</A>
</UL>
$anm
<HR>
<H3>目錄  Contents</H3>
<TABLE border="1" cellpadding="2">
<THEAD>
<TH COLSPAN="2"><A HREF="$link">$ltit</A></TH>
</THEAD>
<TR><TD>
EOF

if ($type eq "H"){
		mkdir ("HTML\\$bd\\$idn", 1);
		open (CHM, ">HTML\\$bd\\$idn\\$pg.htm");
		select(CHM);
		print <<"EOF";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<script LANGUAGE="JAVASCRIPT">
<!--
function showpic(name)
{window.open("../../" + name,"pic","width=30,height=25,scrollbars,resizable");}
//-->
</script>
<TITLE>CBETA 大正大藏經</TITLE>
</head>
<BODY id="$bd">
EOF

} else {

	if (open (CHM, "HTMLHELP\\$bd.htm")){
		open (CHM, ">>HTMLHELP\\$bd.htm");
		select(CHM);
	}
	else {
		open (CHM, ">HTMLHELP\\$bd.htm");
		select(CHM);
print << "EOF";
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<style>\@import url(cbeta.css);</style>
<link disabled rel="stylesheet" href="cbeta.css">
<script LANGUAGE="JAVASCRIPT" SRC="search.js">
</script>
<TITLE>CBETA 大正大藏經</TITLE>
</head>
<BODY id="$bd">
EOF
}
		}
}

#open (HHP, ">>HTMLHELP\\$bd.hhp");
for $k (sort(keys(%img))){
	print HHP "images/$k.gif\n";
}
close (HHP);

open (HHP, ">${bd}mchars.err");
for $k (sort(keys(%misimg))){
	print HHP "$k\n";
}


sub ent{
	local($e) = $_[0];
#	print STDERR "$e\t$ent{$e}\n";
	return $ent{$e} if ($ent{$e} ne "");
	return $e;
}

sub rep {
	local($tit) = $_[0];
	local($zahl) = $_[1];
	if ($zahl =~ /(.*)之(.*)/){
		$z1 = $1;
		$z2 = $2;
		$z1 = &fig($z1);
		$z2 = &fig($z2);
		$zahl = $z1 . "." . $z2;
	} else {
		$zahl = &fig($zahl);
	}
	$tit =~ s/◎//g;
	if ($tit =~ /卷/){
		$tit =~ s/卷//;
		return "$tit $zahl";
	} else {
		return "$tit $zahl";
	}
#	return "$zahl $tit" if ($tit =~ /軌分/);
}

sub fig{
	local($loc) = $_[0];
		$loc =~ s/.*(品|第)//;
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

