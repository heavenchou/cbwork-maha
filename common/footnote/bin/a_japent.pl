#--------------------------------------------------------------------------------------------
# a_japent.pl
#
# 1. �p�G�� &M999999; ���N�[�W jap.ent
# 2. �b <teiHeader> �إ[�W <profildDesc>, <langUsage>
#
# v0.1, 2002/11/20 11:49AM by Ray
# v0.2, �b <teiHeader> �إ[�W <profildDesc>, <langUsage>, 2002/11/25 01:12PM by Ray
#--------------------------------------------------------------------------------------------

# �Ѽư�
$vol="T09";
$out_dir = "c:/release/new-xml"; # ��X�ؿ�
$in_dir = "c:/cbwork/xml"; # �ӷ��ؿ�
# �Ѽưϵ���

%lang_name = (
	"chi" => "Chinese",
	"chi-yy" => "Chinese Yinyi(��Ķ)",
	"eng" => "English",
	"pli" => "Pali",
	"san" => "Sanskrit",
	"san-rj" => "Sanskrit-Ranjan",
	"san-sd" => "Sanskrit-Siddam",
	"tib" => "Tibetan",
	"tib-san" => "���ä���½������r"
);

mkdir("$out_dir/$vol",MODE);

opendir THISDIR, "$in_dir/$vol" or die "opendir error: $dir";
my @allfiles = grep /\.xml$/, readdir THISDIR;
closedir THISDIR;

foreach $file (@allfiles) {
	open I, "$in_dir/$vol/$file" or die;
	$text="";
	while (<I>) {
		$text .= $_;
	}
	close I;

	%langs=();
	$langs{"chi"}=0;
	$text =~ s/(lang=".*?")/&rep($1)/eg;

	$profile = "<profileDesc>\n";
	$profile .= "\t\t<langUsage>\n";
	foreach $lan (keys %langs) {
		$profile .= "\t\t\t<language id=\"$lan\">" . $lang_name{$lan} . "</language>\n";
	}
	$profile .= "\t\t</langUsage>\n";
	$profile .= "\t</profileDesc>\n";

	$text =~ s/(<revisionDesc>)/$profile\t$1/;
	
	if ($text =~ /&M\d{6}/ and $text!~/jap\.ent/) {
		$text =~ s#(<!ENTITY % CBENT  SYSTEM "../dtd/cbeta.ent" >)#$1\n<!ENTITY % JAP  SYSTEM "\.\./dtd/jap.ent" >#;
		$text =~ s#(%CBENT;)#$1\n%JAP;#;
	}

	open O, ">$out_dir/$vol/$file" or die;
	select O;
	print $text;
	close O;
}

sub rep {
	my $s=shift;
	$s=~/lang="(.*?)"/;
	$lang=$1;
	$langs{$lang}=0;
	return $s;
}