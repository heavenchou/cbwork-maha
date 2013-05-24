print STDERR "require b52uni.plx...";
require "b52uni.plx";
print STDERR "ok\n";

$big5 = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
open_htm();
open I,"dfb.txt" or die;
while (<I>) {
	print STDERR ".";
	chomp;
	m#<ENTRY n=\"\d*?\"><HEAD>(.*?)</HEAD><DEF>(.*?)</DEF></ENTRY>#;
	$head = $1;
	$def = $2;
	$file = $head;
	$file =~ s/($big5)/&rep($1)/eg;
	select O;
	print "<!---New Topic--->\n";
	print "<OBJECT type='application/x-oleobject' classid='clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e'>\n";
	print "\t<param name='New HTML file' value='$file.htm'>\n";
	print "\t<param name='New HTML title' value='$head (丁福保)'>\n";
	print "</OBJECT>\n";
	print "<Object type='application/x-oleobject' classid='clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e'>\n";
	print "\t<param name=\"Keyword\" value=\"$head\">\n";
	print "</OBJECT>\n";
	print "<h3>丁福保: 佛學大辭典</h3>\n";
	print "<h2>$head</h2>\n";
	print "<p>$def\n";
}
close_htm();

sub close_htm {
	print O "</body></html>";
	close O;
}

sub open_htm {
	open O,">dfb.htm" or die;	
	print O << "XXX";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD><meta http-equiv="Content-Type" content="text/html; charset=big5">
<script LANGUAGE="JAVASCRIPT" SRC="dfbsrch.js">
</script>
<script LANGUAGE="JAVASCRIPT">
<!--
function showpic(name)
{window.open("../../" + name,"pic","width=30,height=25,scrollbars,resizable");}
//-->
</script>
<TITLE>丁福保佛學大辭典</TITLE>
</HEAD>
<BODY>
XXX
}

sub rep {
	my $x = shift;
	if (exists $b52uni{$x}) {
		return "%u" . $b52uni{$x};
	} else {
		return $x;
	}
}