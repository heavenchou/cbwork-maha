# --------------------------------
# GetMGif.pl 抓M碼的GIF檔
# Input: *.nor
# Created by Ray 1999/10/29
# --------------------------------

use File::Basename;
use File::Path;
use HTML::LinkExtor;
use LWP::Simple;
use URI::URL;

$SourceURL="http://www.mojikyo.gr.jp/gif/";


# 抓下來後存放的地方
$savePath = "j:/bsin/cbeta/images/";

@log=();
$logLen=0;

open(F1, "j:/bsin/cbeta/mojikyo/add19.txt") || die "can't open $file\n";
while (<F1>) {
  if (/.*@(\d\d\d)(\d\d\d);.*/) {
			    $url = $SourceURL . $1 . "/" . $1 . $2 . ".gif";
          fetchImg($url);
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