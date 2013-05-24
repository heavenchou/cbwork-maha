#
# Toc_T_H.pl
# ���� html �����g��
# written by Ray 2001/6/15 03:53�U��
#
require "cbetasub.pl";
require "sub.pl";
$i_dir = "c:/cbwork/xml";
open O, ">c:/release/html/index.htm";
select O;
print << "XXX";
<html>  
<head>  
	<meta http-equiv="Content-Type" content="text/html; charset=big5">
	<script LANGUAGE="JAVASCRIPT" SRC="script/search.js"></script>
	<TITLE>�j���øg��</TITLE>
</head>
<BODY vlink="#0000FF">
XXX

print "<h1 align='center'>�j���øg��</h1>\n";
print_links();

$old_boo = '';
$block_open = 0;
for ($i=1; $i<=85; $i++) {
	$vol = "T" . sprintf("%2.2d",$i);
	$dir = "$i_dir/$vol";
	if (not -e $dir) { next; }
	
	block_close();

	print "<h1><a name='$vol'>��" . cNum($i) . "�U</a></h1>\n";
	$open = 1;
		
	opendir THISDIR, $dir or die "opendir error: $dir";
	my @allfiles = grep /\.xml$/, readdir THISDIR;
	closedir THISDIR;
	foreach $file (sort @allfiles) {
		print STDERR "$file\n";
		$file =~ /T\d\dn(.*)\.xml/i;
		$sutraNum = $1;
		$boo = num2TaishoBoo($sutraNum);
		if ($boo ne $old_boo) {
			block_close();
			print "<h1><a name='$boo'>$boo</a></h1>\n";
			$old_boo = $boo;
			$open = 1;
		}
		if ($open) {
			block_open();
			$open = 0;
		}
		openent("$dir/${vol}n$sutraNum.ent");
		open I, "$dir/$file" or die "$dir/$file";
		while (<I>) {
			if (m#<title>.*? (\S+)</title>#) {
				$sutraName = $1;
				$sutraName =~ s/\&(.+);/&rep($1)/eg;
				if (length($sutraNum)==4) {
					$c = "_";
				} else {
					$c = '';
				}
				print "<tr><td nowrap valign='top'><a href=\"$vol/${sutraNum}${c}001.htm\">No. $sutraNum</a>";
				print "<td>$sutraName\n";
				last;
			}
		}
		close I;
	}
}
block_close();
print "</body></html>";
close O;

#-------------------------------------------------------------------
# Ū ent �ɦs�J %Entities
sub openent{
	my $file = shift;
	open(T, $file) || die "can't open $file\n";
	while(<T>){
		chop;
		s/<!ENTITY\s+//;
		s/[SC]DATA//;
		if (/gaiji/) {
			/^(.+)\s+\"(.*)\".*/;
			$ent = $1;
			$val = $2;
			$ent =~ s/ //g;
			$gaiji{$ent} = $val;
			if ($file=~/jap\.ent/) { # �p�G�O���
				if ($val=~/uni=\'(.+?)\'/) { $val= "&#x" . $1 . ";" ; } # �u���ϥ� Unicode
			} elsif($ent=~/^SD/) {
				$val =~ s#<gaiji .* big5=\'(.+?)\'/>#$1#;
				#$val = "<font face=\"siddam\">$val</font>";
			} else {
				if ( $val=~/mojikyo=\'(.+?)\'/) {
					my $m=$1;  # �_�h�� M �X
					my $des = "";
					if ( $val=~/des=\'(.+?)\'/) { 
						$des=$1; 
						$ent2ZuZiShi{$ent}=$des;
					} else { $des = $m; }
					if ($des=~/\[(.*)\]/) { $des = $1; }
					$m =~ s/^M//;
					$mojikyo{$m}=0;
					my $href = "javascript:showpic(\"fontimg/$m.gif\")";
					$no_nor{$ent} = "[<a href='$href'>$des</a>]";
				} elsif ( $val=~/des=\'(.+?)\'/ ) {
					$no_nor{$ent} = $1;
				} else { $no_nor{$ent}=$ent; } # �̫�� CB �X

			    if ($val=~/nor=\'(.+?)\'/) {  # �u���ϥγq�Φr
			    	$val=$1; 
			    	$ent2nor{$ent}=$val;
			    } else { $val = $no_nor{$ent}; }
			}
		} else {
		  s/\s+>$//;
		  ($ent, $val) = split(/\s+/);
		  $val =~ s/"//g;
		}    
		$Entities{$ent} = $val;
		if ($ent eq "CB02664") {
			#print STDERR "91 $ent $val\n"; getc;
		}
		if ($debug) { print STDERR "Entity: $ent -> $val\n"; }
	}
	close T;
}       

sub rep{
	local($x) = $_[0];
	if ($debug) { print STDERR "rep($x)="; }
	# modified by Ray 1999/10/13 07:16PM
	#return $Entities{$x} if defined($Entities{$x});
	local $str='';
	if ($no_nor) {
		if (defined($no_nor{$x})) { $str = $no_nor{$x}; }
	} else {
		if (defined($Entities{$x})) { $str = $Entities{$x}; }
	}

	if ($str =~ /^\[(.*)\]$/) {
	  my $exp = $1;
	  if (defined($dia{$exp})) {
	    $str = "<font face=\"CBDia\">" . $dia{$exp} . "</font>";
	    if ($debug) { print STDERR "$str\n"; }
	    return $str;
		}
	}   
	if ($debug) { print STDERR "$str\n"; }
	return $str;
	die "Unknkown entity $x!!\n";
	if ($debug) { print STDERR "$x\n"; }
	return $x;
}

sub block_close {
	if ($block_open > 0) {
		print "</table>";
		print "</blockquote>";
		$block_open--;
	}
}

sub block_open {
	print "<blockquote>\n";
	print "<table>";
	$block_open++;
}

sub print_links {
	print "<center><table border='0'>";
	print "<tr><td><a href='#���t��'>���t��</a><td> <a href='#T01'>T1</a>, <a href='#T02'>T2</a>\n";
	print "<tr><td><a href='#���t��'>���t��</a><td> <a href='#T03'>T3</a>, <a href='#T04'>T4</a>\n";
	print "<tr><td><a href='#��Y��'>��Y��</a><td> <a href='#T05'>T5</a>, <a href='#T06'>T6</a>, <a href='#T07'>T7</a>, <a href='#T08'>T8</a>\n";
	print "<tr><td><a href='#�k�س�'>�k�س�</a><td> <a href='#T09'>T9</a>a\n";
	print "<tr><td><a href='#���Y��'>���Y��</a><td> T9b, <a href='#T10'>T10</a>\n";
	print "<tr><td><a href='#�_�n��'>�_�n��</a><td> <a href='#T11'>T11</a>, <a href='#T12'>T12</a>a\n";
	print "<tr><td><a href='#�I�n��'>�I�n��</a><td> T12b\n";
	print "<tr><td><a href='#�j����'>�j����</a><td> <a href='#T13'>T13</a>\n";
	print "<tr><td><a href='#�g����'>�g����</a><td> <a href='#T14'>T14</a>, <a href='#T15'>T15</a>, <a href='#T16'>T16</a>, <a href='#T17'>T17</a>\n";
	print "<tr><td><a href='#�K�г�'>�K�г�</a><td> <a href='#T18'>T18</a>, <a href='#T19'>T19</a>, <a href='#T20'>T20</a>, <a href='#T21'>T21</a>\n";
	print "<tr><td><a href='#�߳�'>�߳�</a><td> <a href='#T22'>T22</a>, <a href='#T23'>T23</a>, <a href='#T24'>T24</a>\n";
	print "<tr><td><a href='#���g�׳�'>���g�׳�<td> </a><a href='#T25'>T25</a>, <a href='#T26'>T26</a>a\n";
	print "<tr><td><a href='#�s�賡'>�s�賡</a><td> T26b, <a href='#T27'>T27</a>, <a href='#T28'>T28</a>, <a href='#T29'>T29</a>\n";
	print "<tr><td><a href='#���[��'>���[��</a><td> <a href='#T30'>T30</a>a\n";
	print "<tr><td><a href='#�����'>�����</a><td> T30b, <a href='#T31'>T31</a>\n";
	print "<tr><td><a href='#�׶���'>�׶���</a><td> <a href='#T32'>T32</a>\n";
	print "<tr><td><a href='#�g����'>�g����</a><td> <a href='#T33'>T33</a>, <a href='#T34'>T34</a>, <a href='#T35'>T35</a>, <a href='#T36'>T36</a>, <a href='#T37'>T37</a>, <a href='#T38'>T38</a>, <a href='#T39'>T39</a>\n";
	print "<tr><td><a href='#�߲���'>�߲���</a><td> <a href='#T40'>T40</a>a\n";
	print "<tr><td><a href='#�ײ���'>�ײ���</a><td> T40b, <a href='#T41'>T41</a>, <a href='#T42'>T42</a>, <a href='#T43'>T43</a>, <a href='#T44'>T44</a>a\n";
	print "<tr><td><a href='#�ѩv��'>�ѩv��</a><td> T44b, <a href='#T45'>T45</a>, <a href='#T46'>T46</a>, <a href='#T47'>T47</a>, <a href='#T48'>T48</a>\n";
	print "<tr><td><a href='#�v�ǳ�'>�v�ǳ�</a><td> <a href='#T49'>T49</a>, <a href='#T50'>T50</a>, <a href='#T51'>T51</a>, <a href='#T52'>T52</a>\n";
	print "<tr><td><a href='#�ƷJ��'>�ƷJ��</a><td> <a href='#T53'>T53</a>, <a href='#T54'>T54</a>a\n";
	print "<tr><td><a href='#�~�г�'>�~�г�</a><td> T54b\n";
	print "<tr><td><a href='#�ؿ���'>�ؿ���</a><td> <a href='#T55'>T55</a>\n";
	print "<tr><td><a href='#�j�h��'>�j�h��</a><td> <a href='#T85'>T85</a>a\n";
	print "<tr><td><a href='#�æ���'>�æ���</a><td> T85b\n";
	print "</td></tr></table></center>";
}