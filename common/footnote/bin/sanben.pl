#-------------------------------------------------------------------------------------
# sanben.pl
# �N��ӬO "�i�T�j�� " �� "�i���j�i���j�i���j��" �令 "�i���j���i���j���i���j��"
#
# v0.1, 2002/12/17 05:24PM by Ray
# V0.2, 2002/12/19 10:58AM by Ray
#------------------------------------------------------------------------------------
$xml_dir = "c:/cbwork/xml/T03";
$out_dir = "d:/temp/T03";

$debug = 0;

mkdir($out_dir,MODE);

opendir THISDIR, $xml_dir or die "opendir error: $xml_dir";
my @allfiles = grep /\.xml$/, readdir THISDIR;
closedir THISDIR;

foreach $file (@allfiles) {
	open I, "$xml_dir/$file" or die;
	open O, ">$out_dir/$file" or die;
	select O;
	while (<I>) {
		s#(<note[^>]*?type="orig"[^>]*?>[^<]*?�i�T�j��.*?</note><note[^>]*?type="mod">.*?)�i���j�i���j�i���j��(.*?</note>)#$1�i���j���i���j���i���j��$2#g;
		s#(<note[^>]*?type="orig"[^>]*?>[^<]*?�i�T�j�U�P[^<]*?</note><note[^>]*?type="mod">.*?)�i���j�i���j�i���j�U�P(.*?</note>)#$1�i���j�U�P�i���j�U�P�i���j�U�P$2#g;
		print;
	}
	close O;
	close I;
}