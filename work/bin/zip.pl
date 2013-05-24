use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

$in_dir=shift; # 輸入目錄
$out_dir=shift; # 輸出目錄

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