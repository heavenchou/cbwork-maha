########################################################
#
# 句讀插入程式  by heaven                2004/08/14
#
# 使用方法：
# pushdot.pl 簡單標記版.txt 舊的xml.xml 結果檔xml.xml
#
########################################################
# 2005/04/26 : 修改小問題
# 10/15 : 處理一些日文
# 10/15 : 處理悉曇字的 …（）三個符號及 <item>
# 10/15 : 更換 <tt> 的處理法
# 10/14 : 加強 <tt> , 容許第二行有【圖】及其它文字
# 10/14 : 加強 <tt> , 容許第二行有【圖】 (還要再加強)
# 10/13 : 處理 <tt> 梵漢隔行對照 及 <sg>
# 10/10 : 處理 <foreign>...</foreign>
# 10/10 : 處理 <head type="added">....</head> 及 &SD-...; 悉曇字
# 10/8 : 將忽略 <t lang="san|pli|..." 改成忽略 <t ... place="foot" 
# 10/8 : 處理 <l lang="unknow" 及校勘數字的修訂 [[04]>]
# 10/6 : 加強昨日的判斷
# 10/5 : 移動不適當的句讀與小黑點. 例如應該移至校勘 <lem> <t> 的範圍之外.
# 10/4 : 處理檔尾的 0x0d 字元
# 10/4 : 處理巴利文轉寫字, <foreign>
# 10/3 : 處理大正的校勘, 星號, <tt>
# 9/8 : 處理二檔一為「。」一為「．」的 bug
# 9/5 : 處理通用詞, 圖, 忽略其它全型英文, 標點不同時一律以 SM 為主

use strict;

local *INTxt;
local *INXml;
local *OUTXml;

my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[+\-*\/\(\)\@\?:0-9])';

########################################################
# 判斷參數
########################################################

if($#ARGV != 2)
{
	print "使用方法：\n";
	print "    pushdot.pl 簡單標記版.txt 舊的xml.xml 結果檔xml.xml\n";
	print "\n任意鍵結束....\n";
	<STDIN>;
	exit;
}

########################################################
# 主參數
########################################################

my $InTxtFile = shift;
my $InXmlFile = shift;
my $OutXmlFile = shift;

my $hasdot1 = 0;		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點
my $hasdot2 = 0;		# 用來判斷是否有 dot , 0: 沒有, 1:句讀, 2:小黑點
my $tagbuff = "";		# 暫存 tag 的 buff

my $istt = 0;           # 判斷是不是 <tt> 隔行對照, 0:一般狀況, 1:xml 發現 <tt> 2:sm 版已處理成 <tt> 格式(梵漢間格)
my $whicht = 0;         # 目前是在哪一個 <t> 裡面? 梵 : 1 , 漢 : 2 

########################################################
# 主程式
########################################################

open INTxt, "$InTxtFile" or die "open $InTxtFile error$!";
open INXml, "$InXmlFile" or die "open $InXmlFile error$!";
open OUTXml, ">$OutXmlFile" or die "open $OutXmlFile error$!";

my @lines1 = <INTxt>;
my @lines2 = <INXml>;

close INTxt;
close INXml;

my $index1 = 0;
my $index2 = 0;

# 1. 先將不重要的 XML copy 過去

while(1)
{
	print OUTXml "$lines2[$index2]";
	last if($lines2[$index2] =~ /<body>/);
	$index2++;
}
$index2++;

while(1)
{
	$hasdot1 = 0;		# 用來判斷是否有 dot
	$hasdot2 = 0;		# 用來判斷是否有 dot
	
	# ------------------------ 各取一個字
	
	my $word2 = get_word2();
	if($istt == 1)
	{
	    make_tt();
	    $istt = 2;
	}
	if($istt == 2 and $whicht == 2)
	{
	    $index1++;      # <tt> 中的漢字, 所以讀下一行
	}
	my $word1 = get_word1();
	if($istt == 2 and $whicht == 2)
	{
	    $index1--;      # 還原
	}	
	if($word1 ne "" and $word2 eq "")
	{
		print "Error: $InXmlFile no data\n";
		print OUTXml "<?>Out of data";
		last;
	}
	
	# ------------------------ 判斷二個字是否相同
	
	my $result = check_2_word($word1, $word2);

	if($result == 1)	# 二邊同步
	{
		if($hasdot1 == $hasdot2)
		{
			print OUTXml $tagbuff;
		}
		elsif($hasdot1 == 1)
		{
			$tagbuff =~ s/．//;
			
			# <rdg wit="【大】">阿。</rdg></app> ==> <rdg wit="【大】">阿</rdg></app>。
			if($tagbuff =~ /^<((\/rdg)|(\/lem)|(\/t)|(note[^>]*resp="CBETA".*?)|(app.*?))>/)
			{
			    if($tagbuff =~ /^.*<\/((app)|(tt)|(note))>/)
			    {
				    $tagbuff =~ s/^(.*<\/(?:(?:app)|(?:tt)|(?:note))>)/$1。/;
				    print OUTXml "$tagbuff";
				}
				else
				{
				    print OUTXml "。<<?>:<在 rdg,lem,t,note 之前的句讀應該處理掉>>$tagbuff";
				}
			}
			elsif($tagbuff =~ /^<foreign.*?>.*?<\/foreign>/)
			{
			    $tagbuff =~ s/^(<foreign.*?>.*?<\/foreign>)/$1。/;
				print OUTXml "$tagbuff";
			}
			else
			{
				print OUTXml "。$tagbuff";
			}
		}
		elsif($hasdot1 == 2)
		{
			$tagbuff =~ s/。//;
			# <rdg wit="【大】">阿．</rdg></app> ==> <rdg wit="【大】">阿</rdg></app>．
			if($tagbuff =~ /^<((\/rdg)|(\/lem)|(\/t)|(note[^>]*resp="CBETA".*?)|(app.*?))>/)
			{
			    if($tagbuff =~ /^.*<\/((app)|(tt)|(note))>/)
			    {
				    $tagbuff =~ s/^(.*<\/(?:(?:app)|(?:tt)|(?:note))>)/$1．/;
				    print OUTXml "$tagbuff";
				}
				else
				{
				    print OUTXml "．<<?>:<在 rdg,lem,t,note 之前的句讀應該處理掉>>$tagbuff";
				}
			}
			elsif($tagbuff =~ /^<foreign.*?>.*?<\/foreign>/)
			{
			    $tagbuff =~ s/^(<foreign.*?>.*?<\/foreign>)/$1．/;
				print OUTXml "$tagbuff";
			}
			else
			{
				print OUTXml "．$tagbuff";
			}			
		}
		elsif($hasdot1 == 0 and $hasdot2 == 1)
		{
			$tagbuff =~ s/。//;
			print OUTXml "$tagbuff";
		}
		elsif($hasdot1 == 0 and $hasdot2 == 2)
		{
			$tagbuff =~ s/．//;
			print OUTXml "$tagbuff";
		}
		else
		{
			print OUTXml "<?>$tagbuff";		# 大概用不上了
		}

		print OUTXml "$word2";
	}
	else
	{
		print OUTXml "<?>$tagbuff$word2";
		exit;
	}
	
	if($word1 eq "" and $word2 eq "")
	{
		last;
	}
}

close OUTXml;


########################################################
#
# XML 版遇到 <tt> 隔行對照，所以 sm 版要處理成和 xml 版一樣的格式
#例如
#T18n0859_p0178c23Z#H◇◇◇◇◇◇◇◇◇
#T18n0859_p0178c24_##[41]南　麼　三　曼　多　伐　折囉(二合)　赧(一)　唵(二)
#變成
#T18n0859_p0178c23Z#H◇◇◇◇◇◇◇◇◇
#[41]南　麼　三　曼　多　伐　折囉(二合)　赧(一)　唵(二)T18n0859_p0178c24_##
#
# 第一個 <t> 就取第一行, 第二個 <t> 取第二行, 第一行結束後, 再將第二行的 Txxn... 移到前面對
########################################################

sub make_tt
{
    my $data;
    if($index1 == $#lines1)
    {
        return;     #最後一行了, 不用玩了
    }
    
    my $line1 = $lines1[$index1];
    my $line2 = $lines1[$index1+1];
    my $line3 = $lines1[$index1+2];
    
    # 處理修訂與移位

    if($line2 =~ />/)
    {
        if($line3 =~ />>/ and $line2 =~ />>/)
        {
            while($line3 =~ /^$big5*?\[($losebig5+?)\]/)
            {
        	    $line3 =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
	        }
	        $line3 =~ s/\[($losebig5*?)>>($losebig5*?)\]/$2/g;
	        $line3 =~ s/\[($losebig5*?)>($losebig5*?)\]/$2$1/g;
	        $line3 =~ s/:1:/\[/g;
	        $line3 =~ s/:2:/\]/g;
	    }

        while($line2 =~ /^$big5*?\[($losebig5+?)\]/)
        {
    	    $line2 =~ s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
	    }
	    $line2 =~ s/\[($losebig5*?)>>($losebig5*?)\]/$2/g;
	    $line2 =~ s/\[($losebig5*?)>($losebig5*?)\]/$2$1/g;
	    $line2 =~ s/:1:/\[/g;
	    $line2 =~ s/:2:/\]/g;
	}

    if($line2 =~ /^[TX]\d\dn.{5}p.{7}.{3}(.*)/)
    {
        $line2 =~ s/^([TX]\d\dn.{5}p.{7}.{3})(.*)/$2$1/;
    }
    else
    {
        return;     # 第二行沒有行首
    }
    $lines1[$index1+1] = $line2;
    $lines1[$index1+2] = $line3;
}
########################################################
#
# 取得純文字的字
#
########################################################

sub get_word1
{	
	local $_;
	
	while(1)
	{
		if($index1 > $#lines1)		# 結束了
		{
			return "";
		}
		
		if($lines1[$index1] eq "\n") 
		{
			$index1 ++;
			next;
		}
		
		if($lines1[$index1] =~ /^。/)
		{
			$hasdot1 = 1;	
			$lines1[$index1] =~ s/^。//;
			next;
		}
		
		if($lines1[$index1] =~ /^．/)
		{
			$hasdot1 = 2;	
			$lines1[$index1] =~ s/^．//;
			next;
		}
		
		if($lines1[$index1] =~ /^((?:　)|(?:Ｐ)|(?:Ｓ)|(?:ｓ)|(?:Ｗ)|(?:Ｚ)|(?:Ｉ)|(?:Ｍ)|(?:Ｒ)|(?:ｊ)|(?:Ｔ)|(?:Ｄ)|(?:Ｑ)|(?:Ａ)|(?:Ｙ)|(?:Ｂ)|(?:Ｅ))/)
		{
			$lines1[$index1] =~ s/^((?:　)|(?:Ｐ)|(?:Ｓ)|(?:ｓ)|(?:Ｗ)|(?:Ｚ)|(?:Ｉ)|(?:Ｍ)|(?:Ｒ)|(?:ｊ)|(?:Ｔ)|(?:Ｄ)|(?:Ｑ)|(?:Ａ)|(?:Ｙ)|(?:Ｂ)|(?:Ｅ))//;
			next;
		}
		
		if($lines1[$index1] =~ /^<.*?>/)
		{
			$lines1[$index1] =~ s/^<.*?>//;
			next;
		}
		last;
	}
	
	$_ = $lines1[$index1];	# 處理修訂與移位
	
	# 取行首  X79n1563_p0657a09_##

	if(/^[TX]\d\dn.{5}p(.{7}).{3}/)
	{
		# 處理修訂與移位
		
		while(/^$big5*?\[($losebig5+?)\]/)
		{
			s/^($big5*?)\[($losebig5+?)\]/$1:1:$2:2:/;
		}
		s/\[($losebig5*?)>>($losebig5*?)\]/$2$1/g;
		s/\[($losebig5*?)>($losebig5*?)\]/$2$1/g;
		s/:1:/\[/g;
		s/:2:/\]/g;
		
		# 處理通用詞
		
		s=\Q髣髣[髟/弗][髟/弗]\E=&CIxxx;=g;
		s=\Q髣[髟/弗]\E=&CIxxx;=g;
		s=\Q[髟/弗]髣\E=&CIxxx;=g;
		s/\Q搪[打-丁+突]\E/&CIxxx;/g;
		s/\Q礔[石*歷]\E/&CIxxx;/g;
		s/\Q琅[王*耶]\E/&CIxxx;/g;
	
		s/\Q[跍*月]跪\E/&CIxxx;/g;
		s/\Q[立*令]竮\E/&CIxxx;/g;
		s=\Q[辟/石][石*歷]\E=&CIxxx;=g;
		s=\Q[王*頗][王*梨]\E=&CIxxx;=g;
		s=\Q鴶[亢*鳥]\E=&CIxxx;=g;
		
		$lines1[$index1] = $_;
		
		$lines1[$index1] =~ s/^[TX]\d\dn.{5}p(.{7}).{3}//;
		return "n=\"$1\"";
	}
	elsif(/^\[\d+[A-Za-z]?\]/)	# 校勘數字
	{
		$lines1[$index1] =~ s/^(\[\d+[A-Za-z]?\])//;
		return "$1";
	}
	elsif(/^\[＊\]/)	# 星號
	{
		$lines1[$index1] =~ s/^(\[＊\])//;
		return "$1";
	}
	elsif(/^\[($losebig5+?)\]/)	# 缺字
	{
		$lines1[$index1] =~ s/^(\[($losebig5+?)\])//;
		return "$1";
	}
	elsif(/^&CIxxx;/)	# 通用詞
	{
		$lines1[$index1] =~ s/^(&CIxxx;)//;
		return "$1";
	}
	elsif(/^【圖】/)	# 【圖】
	{
		$lines1[$index1] =~ s/^(【圖】)//;
		return "$1";
	}
	elsif(/^([Aaiu])\1/)	# 巴利文
	{
		$lines1[$index1] =~ s/^([Aaiu])\1//;
		return "&$1macron;";
	}
	elsif(/^\.[dDhlLmnNrsStT]/)	# 巴利文
	{
		$lines1[$index1] =~ s/^\.([dDhlLmnNrsStT])//;
		return "&$1dotblw;";
	}
	elsif(/^\^[mn]/)	# 巴利文
	{
		$lines1[$index1] =~ s/^\^([mn])//;
		return "&$1dotabv;";
	}
	elsif(/^~n/)        # 巴利文
	{
		$lines1[$index1] =~ s/^~n//;
		return "&ntilde;";
	}
	elsif(/^\`[sS]/)	# 巴利文
	{
		$lines1[$index1] =~ s/^\`([sS])//;
		return "&$1acute;";
	}
	elsif(/^【MA】/)	# 日文&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^【MA】//;
		return "&M062462;";
	}
	elsif(/^【TA】/)	# 日文&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^【TA】//;
		return "&M062431;";
	}
	elsif(/^【RA】/)	# 日文&M062462;&M062431;&M062473;
	{
		$lines1[$index1] =~ s/^【RA】//;
		return "&M062473;";
	}
	elsif(/^$big5/)     # 一般字
	{
		$lines1[$index1] =~ s/^($big5)//;
		return "$1";
	}
	else
	{
		print "不懂的字:\n";
		print "line = $index1\n";
		print "word = $lines1[$index1]\n";
		print "任意鍵結束...\n";
		<>;
		exit;
	}
}

sub get_word2
{
	local $_;
	$tagbuff = "";	# 暫存 tag 的 buff

	while(1)
	{
		if($index2 > $#lines2)		# 結束了
		{
			return "";
		}

		if($lines2[$index2] eq "\n")		# 先處理換行
		{
			$tagbuff .= "\n";
			$index2 ++;
			next;
		}

		if($lines2[$index2] =~ /^(<lb.*?>)/)
		{
			last;
		}

	    #<head type="added">...</head>
	    if($lines2[$index2] =~ /^<head[^>]*type="added"[^>]*>.*?<\/head>/)
		{
			$lines2[$index2] =~ s/^(<head[^>]*type="added"[^>]*>.*?<\/head>)//;
			$tagbuff .= $1;
			next;
		}
		
		# XML : <item n="（一）">....
		# SM  : （一）
		if($lines2[$index2] =~ /^<item n="(.*?)">/)
		{
		    my $tmp = $1;
		    $lines1[$index1] =~ s/^\Q${tmp}\E//;
			$lines2[$index2] =~ s/^(<item n="(.*?)">)//;
			$tagbuff .= $1;
			next;
		}

        # rdg 有二種, 一種要過濾(校勘), 一種要通過(修訂)

	    #<rdg wit="【大】">叟</rdg>(修訂)
	    if($lines2[$index2] =~ /^<rdg[^>]*wit="【大】"[^>]*>/)
		{
			$lines2[$index2] =~ s/^(<rdg[^>]*wit="【大】"[^>]*>)//;
			$tagbuff .= $1;
			next;
		}
		
	    # 過濾(校勘)
	    if($lines2[$index2] =~ /^<rdg.*?>.*?<\/rdg>/)			
	    {
		    $lines2[$index2] =~ s/^(<rdg.*?>.*?<\/rdg>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # 過濾 <t lang="san" resp="Taisho" place="foot">D&imacron;rgha-&amacron;gama</t>
	    #if($lines2[$index2] =~ /^<t[^>]*lang="(?:(?:san)|(?:pli)|(?:unknown))"[^>]*>.*?<\/t>/)			
	    if($lines2[$index2] =~ /^<t[^>]*place="foot"[^>]*>.*?<\/t>/)	
	    {
            # $lines2[$index2] =~ s/^(<t[^>]*lang="(?:(?:san)|(?:pli)|(?:unknown))"[^>]*>.*?<\/t>)//;
            $lines2[$index2] =~ s/^(<t[^>]*place="foot"[^>]*>.*?<\/t>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0011004" place="foot" type="equivalent">遊行經...</note>
	    if($lines2[$index2] =~ /^<note[^>]*?type="equivalent"[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?type="equivalent"[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0578006" place="foot" type="rest">品末題在卷末題前行【宋】【元】【明】</note>
	    if($lines2[$index2] =~ /^<note[^>]*?type="rest"[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?type="rest"[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    #<foreign n="0434012" lang="pli" resp="Taisho" place="foot">Niga&ndotblw...</foreign>
	    if($lines2[$index2] =~ /^<foreign .*?>.*?<\/foreign>/)			
	    {
		    $lines2[$index2] =~ s/^(<foreign .*?>.*?<\/foreign>)//;
			$tagbuff .= $1;
			next;
	    }
	    #<note n="0030012" place="foot" type="cf.">
	    if($lines2[$index2] =~ /^<note[^>]*?type="cf\."[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?type="cf\."[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # <note n="0150002" resp="CBETA" type="mod">傳＝明【宋】【元】【明】</note>
	    if($lines2[$index2] =~ /^<note[^>]*?resp="CBETA"[^>]*?>.*?<\/note>/)			
	    {
		    $lines2[$index2] =~ s/^(<note[^>]*?resp="CBETA"[^>]*?>.*?<\/note>)//;
			$tagbuff .= $1;
			next;
	    }
	    
	    # 上面的順序要在前
	    # 底下這筆的順序要在後
	    
		if($lines2[$index2] =~ /^<note.*?>/ or $lines2[$index2] =~ /^<\/note>/)
		{
			last;
		}
	
		if($lines2[$index2] =~ /^<anchor.*?>/ or $lines2[$index2] =~ /^<app[^>]*type="＊"[^>]*>/)
		{
			last;
		}
		
		#if($lines2[$index2] =~ /^<p[^>]*?place="inline"[^>]*?>/)
		#{
		#	last;
		#}
		
		if($lines2[$index2] =~ /^<figure.*?>/)
		{
			last;
		}
	
		if($lines2[$index2] =~ /^<tt>/)
		{
		    $lines2[$index2] =~ s/^(<tt>)//;
			$tagbuff .= $1;
			if($istt == 0)
			{
			    $istt = 1;
			}
			next;
		}
		
		if($lines2[$index2] =~ /^<t lang="san-sd">/)
		{
		    $whicht = 1;
		    $lines2[$index2] =~ s/^(<t lang="san-sd">)//;
			$tagbuff .= $1;
			next;
		}
		if($lines2[$index2] =~ /^<t lang="chi">/)
		{
		    $whicht = 2;
		    $lines2[$index2] =~ s/^(<t lang="chi">)//;
			$tagbuff .= $1;
			next;
		}
		
		if($lines2[$index2] =~ /^<sg.*?>/)
		{
			last;
		}
		if($lines2[$index2] =~ /^<\/sg>/)
		{
			last;
		}
		
		# ----- 需要處理的標記在放在此之前

		if($lines2[$index2] =~ /^<.*?>/)
		{
			$lines2[$index2] =~ s/^(<.*?>)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^　/)
		{
			$lines2[$index2] =~ s/^(　)//;
			$tagbuff .= $1;
			next;
		}
		
		if($lines2[$index2] =~ /^&lac;/)
		{
			$lines2[$index2] =~ s/^(&lac;)//;
			$tagbuff .= $1;
			next;
		}

		if($lines2[$index2] =~ /^。/)
		{
			$lines2[$index2] =~ s/^(。)//;
			$tagbuff .= $1;
			$hasdot2 = 1;
			next;
		}

		if($lines2[$index2] =~ /^．/)
		{
			$lines2[$index2] =~ s/^(．)//;
			$tagbuff .= $1;
			$hasdot2 = 2;
			next;
		}
		
		if($lines2[$index2] =~ /^\xd/)
		{
			$lines2[$index2] =~ s/^(\xd)//;
			$tagbuff .= $1;
			next;
		}

		last;
	}
	
	$_ = $lines2[$index2];
	
	# 取行首  X79n1563_p0657a09_##

	if(/^<lb.*?\/>/)
	{
		$lines2[$index2] =~ s/^(<lb.*?\/>)//;
		if($istt == 2 and $index1 < $#lines1)
		{
		    # 把第二行還原
		    $lines1[$index1+1] =~ s/^(.*?)([TX]\d\dn.{5}p.{7}.{3})/$2$1/;
		}
		$istt = 0;
		return "$1";
	}
	
	# <note n="0150001" resp="Taisho" type="orig" place="foot text">西天譯經三藏＝宋【明】</note>
	if(/^<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>/)			
	{
		$lines2[$index2] =~ s/^(<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>)//;
		return "$1";
	}

	if(/^<note.*?>/)			# <note place="inline">...</note>
	{
		$lines2[$index2] =~ s/^(<note.*?>)//;
		return "$1";
	}
	if(/^<\/note>/)				# <note place="inline">...</note>
	{
		$lines2[$index2] =~ s/^(<\/note>)//;
		return "$1";
	}
	if(/^<anchor.*?>/)
	{
		$lines2[$index2] =~ s/^(<anchor.*?>)//;
		return "$1";
	}
	if(/^<app[^>]*type="＊"[^>]*>/)
	{
		$lines2[$index2] =~ s/^(<app[^>]*type="＊"[^>]*>)//;
		return "$1";
	}
	
	#if(/^<p[^>]*?place="inline"[^>]*?>/)
	#{
	#	$lines2[$index2] =~ s/^(<p[^>]*?place="inline"[^>]*?>)//;
	#	return "$1";
	#}
	if(/^&((CB)|(CI)|(M)|(SD)).*?;/)		# 缺字
	{
		$lines2[$index2] =~ s/^(&((CB)|(CI)|(M)|(SD)).*?;)//;
		return "$1";
	}
	if(/^&.((macron)|(dotblw)|(dotabv)|(tilde)|(acute));/)		# 巴利文
	{
		$lines2[$index2] =~ s/^(&.((macron)|(dotblw)|(dotabv)|(tilde)|(acute));)//;
		return "$1";
	}
	if(/^<figure.*?>/)		# 圖
	{
		$lines2[$index2] =~ s/^(<figure.*?>)//;
		return "$1";
	}
	if(/^<sg.*?>/)		# <sg>
	{
		$lines2[$index2] =~ s/^(<sg.*?>)//;
		return "$1";
	}
	if(/^<\/sg>/)		# <sg>
	{
		$lines2[$index2] =~ s/^(<\/sg>)//;
		return "$1";
	}
	
	if(/^\[＊\]/)		# <app><lem resp="CBETA.say"></lem><rdg wit="【大】">[＊]</rdg></app>
	{
		$lines2[$index2] =~ s/^(\[＊\])//;
		return "$1";
	}	
	if(/^\[\d+[A-Za-z]?]/)		# T01n0026 : <lb n="0433a23"/>....rdg wit="【大】">[11]</rdg></app>
	{
		$lines2[$index2] =~ s/^(\[\d+[A-Za-z]?\])//;
		return "$1";
	}

	if(/^$big5/)			# 一般字
	{
		$lines2[$index2] =~ s/^($big5)//;
		return "$1";
	}
}

################################################################
# 判斷二者是否相同
################################################################

sub check_2_word
{
	my $word1 = shift;
	my $word2 = shift;
	
	if($word2 eq "典")
	{
	    my $debug = 1;
	}
	
	if($word1 eq $word2)
	{
		return 1;
	}
	
	# 檢查是不是行首
	
	if($word2 =~ /<lb/ and $word2 =~ /$word1/)
	{
		return 1;
	}
	
	if($word2 =~ /&CB.*?;/ and $word1 =~ /\[/)		# 缺字, 待判斷
	{
		return 1;
	}	
	
	if($word2 =~ /&SD.*?;/ and $word1 =~ /◇/)		# 悉曇字
	{
		return 1;
	}
	if($word2 =~ /&SD-D953;/ and $word1 =~ /…/)		# 悉曇字
	{
		return 1;
	}
	if($word2 =~ /&SD-E35A;/ and $word1 =~ /（/)		# 悉曇字
	{
		return 1;
	}
	if($word2 =~ /&SD-E35B;/ and $word1 =~ /\Q）\E/)		# 悉曇字
	{
		return 1;
	}
	if($word2 =~ /&SD-E347;/ and $word1 =~ /\Q□\E/)		# 悉曇字
	{
		return 1;
	}
	
	
	
	if($word2 =~ /&CI.*?;/ and $word1 eq "&CIxxx;")		# 通用詞
	{
		return 1;
	}
	
	if($word2 =~ /&M.*?;/ and $word1 =~ /(恒)|(墻)|(裏)|(碁)|(銹)|(嫺)|(粧)/)		# 缺字, 待判斷
	{
		return 1;
	}
	
	if($word2 =~ /<note[^>]*?resp="Taisho"[^>]*?>[^<]*?<\/note>/ and $word1 =~ /\[((\d+[A-Za-z]?)|(＊))\]/)
	{
		return 1;
	}	
	
	if($word2 =~ /<anchor.*?>/ and $word1 =~ /\[((\d+[A-Za-z]?)|(＊))\]/)
	{
		return 1;
	}
	
	if($word2 =~ /<app[^>]*type="＊"[^>]*>/ and $word1 =~ /\[＊\]/)
	{
		return 1;
	}
	
	if($word2 =~ /<note.*?>/ and $word1 eq "(")
	{
		return 1;
	}
	
	if($word2 eq "</note>" and $word1 eq ")")
	{
		return 1;
	}
	
	if($word2 =~ /<sg.*?>/ and $word1 eq "(")
	{
		return 1;
	}
	
	if($word2 eq "</sg>" and $word1 eq ")")
	{
		return 1;
	}
	
	#if($word2 =~ /<p[^>]*?place="inline"[^>]*?>/ and $word1 eq "Ｐ")
	#{
	#	return 1;
	#}

	if($word2 =~ /<figure.*?>/ and $word1 eq "【圖】")
	{
		return 1;
	}	

	return 0;
}