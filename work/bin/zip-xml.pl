# zip-xml.pl
# 分冊 zip 全部 xml files
# v 1.1.1 2004/1/2 02:09下午 by Ray
# v 1.1.2 2004/1/6 08:54上午 by Ray

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

require "config.pl";

mkdir($xml_out_dir, MODE);

opendir DIR, "$xml_in_dir" or die;
@alldir = grep /^[TX]/, readdir DIR;
closedir DIR;
foreach $vol (@alldir) {
	$dir = "$xml_in_dir/$vol";
	zip();
}

sub zip {
	my $zip = Archive::Zip->new();

	opendir THISDIR, "$xml_in_dir/$vol" or die "serious dainbramage: $!";
	@allfiles = grep /\.(xml|ent)$/, readdir THISDIR;
	closedir THISDIR;
	
	my $file;
	foreach $file (@allfiles) {
		print STDERR "$file ";
		$zip->addFile("$xml_in_dir/$vol/$file", $file);
	}
	print STDERR "\n> $xml_out_dir/$vol.zip\n";
	die 'write error' if $zip->writeToFileNamed( "$xml_out_dir/$vol.zip" ) != AZ_OK;
}