#############################################
# $Id: cbr2t.pl,v 1.5 2009/03/16 09:02:38 heaven Exp $
# 將 cbreader 產生的 html 檔弄成純文字檔
#############################################

$vol = shift;
#exit if $vol eq "";

# 來源目錄, 也就是 cbreader 產生的 html 檔目錄
$source_path = "c:/release/cbr_out/";

$filename = "$source_path${vol}/*.htm";
$big5='(?:(?:[\x80-\xff][\x40-\xff])|(?:[\x00-\x7f]))';


@files = <${filename}>;
open OUT, ">${vol}_cbr.txt";

foreach $file (sort(@files))
{
	open IN, $file;
	h2t();
	close IN;
}

close OUT;

###########################

sub h2t()
{
	local $_;
	
	while(<IN>)
	{
		next unless (/^name="\d{4}.\d\d"/);

		# name="0016b19" id="0016b19"><span class="linehead">T01n0001_p0016b19║</span>
		# 去頭去尾
		
		s/^.*?class="linehead">(.*?)<\/span>/$1/;
		s/<br><a \n/\n/;

		s/＆lac；//g;
		s#<span class="corr">(.*?)</span>#$1#g;		# 因為標記有巢狀, 所以要先處理
		s/<img src=".*?sd-gif.*?">/◇/g;
		s/<img src=.*?>/【圖】/g;
		s/<[^<]*?>//g;		# 去標記
		s/<[^<]*?>//g;		# 去標記
		s/<[^<]*?>//g;		# 去標記
		s/\[(\d[a-zA-Z]?)\]/\[0$1\]/g;	# 將校勘數字弄成二位數
		if(/^T/)
		{
			s/\[(\d\d)[a]\]/\[$1\]/g;
			s/\[\d\d[b-z]\]//g;
		}
		else
		{
			s/\[(\d\d)[a-z]\]/\[$1\]/g;
		}
		print OUT;
	}
}