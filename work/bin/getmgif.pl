# --------------------------------
# GetMGif.pl 抓M碼的GIF檔
# Input: *.ent
# Created by Ray 1999/10/29
# --------------------------------

use File::Basename;
use File::Path;
use HTML::LinkExtor;
use LWP::Simple;
use URI::URL;

### 環境參數
$SourceURL="http://www.mojikyo.gr.jp/gif/";
$xmlPath = "c:/cbwork/xml";
#$savePath = "u:/work/htmlhelp/images/";  # 抓下來後存放的地方
$savePath = "d:/MyDocs/work/hh_cd9/fontimg/";  # 抓下來後存放的地方

#mkdir("images",MODE);

@log=();
$logLen=0;

for ($i=1; $i <=85; $i++) {
	if ($i<10) { $vol = "T0" . $i; } 
	else { $vol = "T" . $i; }
	$dir = "$xmlPath/$vol";
	if (not -e $dir) { next; }
  if (opendir(DIR1, $dir)) {
	  print $dir,"\n";
    @allfiles = grep(/T\d\dn.*\.ent$/i, readdir(DIR1));
    for $file (sort(@allfiles)){
	    open(F1, "$xmlPath/$vol/$file") || die "can't open $file\n";
	    print "$file\n";
	    while (<F1>) {
		    if (/mojikyo=\'M(\d\d\d)(\d\d\d)\'/) {
			    $url = $SourceURL . $1 . "/" . $1 . $2 . ".gif";
          fetchImg($url);
		    }
	    }
    }
  }
}

#--------------------------------------------------------------
sub fetchImg
{
  my ($u) = @_;
  
  my $uu = new URI::URL $u;
  $u = $uu->scheme . '://' . $uu->host . $uu->path;

  ($name,$path,$suffix) = fileparse($uu->path);
  
  if (-e $savePath . $name) { return; }

  print "$file\n";
  print "\nGet Image:\n$u\n";
  # fetch file
  my $c;
  unless ($c = get($u))
  {
    print "Can't fetch Image $url\n";
    return;
  }
  print "Succeed.\n";
  
  # save file
  open OUT1, '>' . $savePath . $name or die "open file error";
  binmode OUT1;
  print OUT1 $c;
  close OUT1;
}