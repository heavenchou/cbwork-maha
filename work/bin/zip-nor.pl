# zip-nor.pl 將所有 normal 版, 一冊壓成一個 zip
#
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );


$in_dir="e:/release/normal";
$out_dir="x:/normal";

opendir DIR, "$in_dir" or die;
@alldir = grep !/^\.\.?$/, readdir DIR;
closedir DIR;
foreach $vol (@alldir) {
	zip();
}

sub zip {
	my $zip = Archive::Zip->new();

	opendir THISDIR, "$in_dir/$vol" or die "serious dainbramage: $!";
	@allfiles = grep !/^\.\.?$/, readdir THISDIR;
	closedir THISDIR;
	
	my $file;
	foreach $file (@allfiles) {
		print STDERR "$file ";
		$zip->addFile("$in_dir/$vol/$file", $file);
	}
	print STDERR "\n$vol.zip\n";
	die 'write error' if $zip->writeToFileNamed( "$out_dir/$vol.zip" ) != AZ_OK;
}