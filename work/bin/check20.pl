#######################################################################
# $Id: check20.pl,v 1.4 2003/09/21 15:16:35 heaven Exp $
#
# 檢查續藏經是否每行 20 字的程式
# 相關參數請修改 check20_pre.pl 這支程式
# maha:
# 
# 續藏每行不是20字的情況，我目前想到的有：
# 經號行，經名行，作者編者行，標題行，偈頌行，含小字的行，段落最後一行
# 計算字數時需要忽略的，我目前想到的有：
# 全形圈點"。"，全形黑點"．"，Ｐ
# 「組字式」、「數字校勘」、「全形空白」要當作一個字來算。
# 留意簡單標記版的縮排標記（標記第三欄的半形阿拉伯數字）。
# 
# kaitser:
# 
# 若是以我們標好的簡單標記版本去分析，可以做成類似像check-p.pl這支程式一樣
# 可自行增加或減少忽略該行分析的標記符號。
# 前題，若為非簡單標記的版本，當程式沒有填入任何的標記符號時，則每行都會去做分析檢查。
# 這可以讓程式有多元化的用途。
# 以上是針對有標記與無標記部份，當然該行中，一些基本要忽略的，還是要有。
# 忽略的東東，最好也可以手動增加減。
# 我考慮到的字有，"Ｚ、Ｑ、Ｔ、◎、〔、〕、﹂、Ｐ、．、　、。"等字。
# 還有一個是否要考慮忽略呢？→→"【圖】"，建議也可以設成對稱符號中當成一字或忽略，舉例如下：
# 可手動設定對稱符號當成一個字→→"[]" ←←前題，中間有包含數字則忽略不算字，
# 因為非組字的狀況有[科/10]、[01]。
# 可手動設定針對跨行的對稱符號，不列入檢查→→"()"  ←←此用意是忽略連續行的夾註小字判斷。
#
# 處理原則:
#
# 如果下一行是空白行, 則忽略此行.
# 如果此行是空白行, 忽略它
# 如果此行是只有一個"【圖】", 忽略它
# 將組字式變成一個單一的字 (這樣一來就沒有組字式的括號了, 若有括號都是雙行小註)
# 凡是該行屬於跨行的雙行小註, 一律忽略它.
# 若此行有雙行小註, 一律忽略
# 此行有特殊標記, 則忽略, 例如 "Q"
# 若下一行有特殊標記, 則忽略, 例如下一行是 "P"
# 如果此行有特殊文字, 則忽略, 例如 "【暫時找不到例子】"
# 將移位及勘誤還原, 以取得正確數字
# 將特殊的字變成一個字, 例如 "【經】"
# 將特殊的字或詞變成沒有字, 例如 "。"
# 將簡單標記中的數字加入字數中
# 如果字數不是在指定的範圍中 , 則印出來
# 
#
# Copyright (C) CBETA, 1998-2003
# Copyright (C) Heaven Chou, 2003
#######################################################################

#use strict;

#######################################
# 可調整的參數
#######################################

# 相關參數請修改 check20_pre.pl 這支程式

require "check20_pre.pl";

#######################################
# 變數
#######################################

my $big5='(?:(?:[\xa1-\xfe][\x40-\xfe])|[\x00-\x7f])';
# $losebig5 忽略 0-9, > [ ] 這些符號
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x00-\x2f]|[\x3a-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])';

my $simple;			# 判斷是不是簡單標記版, 1: 是, 0: 一般的文字版, 沒有簡單標記
my $hasnote=0;		# 判斷是不是有跨行的雙行小註, 1: 是, 0: 不是

my $data_pos;		# 因應不同的情況, 計算資料的起點
my @line;			# 全部的資料
my @outline;		# 輸出的資料
my $sign;			# 行首的簡單標記
my $linehead;		# 目前的行首
my $nextsign="";	# 下一行的行首
my $nextdata="";	# 下一行的資料
my $num;			# 行數
my $startline;		# 第一筆有資料的行數

my $line1921=-999;	# 特別為檢查是不是前一行19下一行21的行數.

local *IN;
local *OUT;

########################################################
## 主程式
########################################################

open IN, $infile or die "open $infile error!";
@line = <IN>;
close IN;

for($i=0;$i<=$#line;$i++)
{
	if($line[$i] ne "\n")
	{
		$startline = $i;
		last;
	}
}

$simple = check_simple();		# 判斷是不是簡單標記版
$data_pos = get_data_pos();		# 因應不同的情況, 計算資料的起點

open OUT, ">$outfile" or die "open $outfile error!";
if ($simple == 1)
{
	simple_ver();				# 簡單標記版的判斷
}
else
{
	none_simple_ver();			# 非簡單標記版的判斷
}


foreach (@outline)
{
	print OUT;
}

print OUT "$infile : found => ";

close OUT;

#######################################
# 判斷是不是簡單標記版
#######################################

sub check_simple()
{
	$sign = substr($line[$startline], 17,3);

	if ($sign =~ /[a-zA-Z0-9_#\?]{3}/)
	{
		return 1;	# 簡單標記版
	}
	else
	{
		return 0;	# 非簡單標記版
	}
}

#######################################
# 因應不同的情況, 計算資料的起點
#######################################

sub get_data_pos()
{
	if($simple == 1)	# 簡單標記版
	{
		my $tmp = substr($line[$startline],20,2);
		if ($tmp eq "║")		# 有分隔線
		{
			$data_pos = 22;
		}
		else
		{
			$data_pos = 20;
		}
	}
	else
	{
		my $tmp = substr($line[$startline],17,2);
		if ($tmp eq "║")		# 有分隔線
		{
			$data_pos = 19;
		}
		else
		{
			$data_pos = 17;
		}
	}
}

#######################################
# 簡單標記版的判斷
#######################################

sub simple_ver()
{
	my $data;
	
	for ($num = $startline; $num < $#line; $num++)		# 先不看最後一行
	{
		
		if($line[$num] =~ /X84n1579_p0003a24/)
		{
			my $debug;
			$debug = 1;
		}
		# 不能先處理簡單標記, 因為要先處理跨行的雙行小註, 免得找不到跨行的 ) 符號

		$sign = substr($line[$num], 17,3);			# 取出簡單標記
		$nextsign = substr($line[$num+1], 17,3);	# 取出下一行的簡單標記

		# 如果下一行是空白行, 忽略它
		
		$nextdata = substr($line[$num+1], $data_pos);		# 取出下一行的資料
		#next if ($nextdata eq "\n" or $nextdata eq "");		# 下一行是空白行, 忽略它 (不可現在處理, 以免此行有 ) 要處理)

		$linehead = substr($line[$num], 0, $data_pos);	# 取出行首
		$data = substr($line[$num], $data_pos);			# 取出資料
		check_data($data);								# 檢查是否是 20 個字
	}
	
	# 最後一行, 要處理嗎?

	$sign = substr($line[$#line], 17,3);			# 取出簡單標記
	$nextsign = "";								# 取出下一行的簡單標記
	if ($sign !~ /[${skip_sign}]/)				# 沒有特殊標記
	{
		$linehead = substr($line[$#line], 0, $data_pos);	# 取出行首
		$data = substr($line[$#line], $data_pos);		# 取出資料
		check_data($data);
	}
	
}

#######################################
# 非簡單標記版的判斷
#######################################

sub none_simple_ver()
{
	my $data;
	
	for ($num = $startline; $num <= $#line; $num++)
	{
		# 如果下一行是空白行, 忽略它
		
		$nextdata = substr($line[$num+1], $data_pos);		# 取出下一行的資料
		#next if ($nextdata eq "\n" or $nextdata eq "");		# 下一行是空白行, 忽略它 (不可現在處理, 以免此行有 ) 要處理)

		$linehead = substr($line[$num], 0, $data_pos);	# 取出行首
		$data = substr($line[$num], $data_pos);			# 取出資料
		check_data($data);								# 檢查是否是 20 個字
	}
}

#######################################
# 檢查某行是否是 20 個字
#######################################

sub check_data()
{
	my $data = shift;
	
	my $linecount = 0;			# 此行的字數
	my $data_other = $data;
	my $data_doing = "";

	chomp($data_other);

	return if ($data_other eq "");			# 忽略空白行
	return if ($data_other eq "【圖】");	# 忽略單一的圖檔

	# 再將組字式變成一個字, 就用 "組" 字好了

	while($data_other =~ /^$big5*?\[$losebig5{2,}\]/)	# 缺字要二個以上, 否則 [＊] 會判成組字式
	{
		$data_other =~ s/^($big5*?)\[$losebig5{2,}\]/$1組/;	# 換成 "組" 這個字
	}
	
	# 如果有跨行的雙行小註, 就忽略
	# 這行一定要在處理組字式之後, 才不會被干擾, 又要在其它判斷之前, 免得找不到雙行小註的右括號

	if($data_other =~ /\(/)
	{
		my $tmp = $data_other;
		while($tmp =~ /\([^\(]*?\)/)
		{
			$tmp =~ s/\([^\(]*?\)//;	# 將對稱性的先換掉
		}
		if($tmp =~ /\(/)
		{
			$hasnote = 1;			# 有跨行的雙行小註
			return;
		}
	}
	
	# 判斷跨行的雙行小註結束了沒?
	
	if($data_other =~ /\)/)
	{
		my $tmp = $data_other;
		while($tmp =~ /\([^\(]*?\)/)
		{
			$tmp =~ s/\([^\(]*?\)//;	# 將對稱性的先換掉
		}
		if($tmp =~ /\)/)
		{
			$hasnote = 0;				# 結束跨行的雙行小註
			return;
		}
	}
	
	return if ($hasnote == 1);

	return if($data_other =~ /[\(\)]/);		# 有括號就不要

	if($simple ==1)
	{
		return if ($sign =~ /[${skip_sign}]/);		# 有特殊標記, 忽略它
		return if ($nextsign =~ /[$skip_next_sign]/);	# 下一行有特殊標記, 忽略它
	}

	# 判斷是不是忽略此行

	return if(skip_this_line($data));


	return if ($nextdata eq "\n" or $nextdata eq "");		# 下一行是空白行, 忽略它

	# 將 [a>b] [a>>b] 換成 a , 還原成經文原來的字數
	
	if($data_other =~ />/)
	{
		$data_other =~ s/\[($losebig5*?)>>$losebig5*?\]/$1/g;
		$data_other =~ s/\[($losebig5*?)>$losebig5*?\]/$1/g;
	}
	
	# 將特殊的字或詞變成一個字
	
	$data_other = equal_one($data_other);
	
	# 將特殊的字或詞變成沒有字
	
	$data_other = equal_zero($data_other);

	# 開始一字一字去分析
	
	my $data1921 = $data_other;		# 先存起來, 要判斷第一個字是不是全型空格

	while($data_other ne "")	# 表示還沒結束
	{	
		$data_other =~ s/^($big5)//;	# 取一個字出來
		$data_doing = $1;
		
		if($data_doing eq "")			# 有奇怪現像, 所以讓它超過 20 個字
		{
			$linecount= 99;
			last;
		}
		$linecount++;
	}
	
	# 判斷簡單標記中有沒有數字
	
	my $sign_tmp = $sign;
	while($sign_tmp =~ /\d/)
	{
		$sign_tmp =~ s/(\d)//;
		$linecount = $linecount + $1;
	}
	
	# 不是指定的個字數範圍

	$min_count = 19 if($min_count==0);		# 擔心使用者沒有用 check20_pre.pl
	$max_count = 21 if($max_count==0);

	if($linecount < $min_count or  $linecount > $max_count)
	{
		my $tmp = $num+1 . ":" . $linehead . $data;
		
		if($skip1921)		# 忽略第一行19字, 第二行21字, 且第二行開頭為全型空格
		{

			if(($linecount == 21) and (substr($data1921,0,2) eq '　') and ($num == $line1921))
			{
				pop(@outline);
			}
			else
			{
				if($linecount == 19)
				{
					$line1921 = $num+1;		# 記下19字的行數
				}
				push(@outline, $tmp);
			}
		}
		else
		{
			push(@outline, $tmp);
		}
	}
}

#######################################
# 判斷是不是忽略此行
#######################################

sub skip_this_line()
{
	local $_ = shift;
	
	for (my $i = 0; $i<=$#skip_word; $i++)
	{
		return 1 if /^${big5}*?$skip_word[$i]/;		# 此行包含要略過此行的字
	}
	return 0;
}

#######################################
# 將特殊的字或詞變成一個字
#######################################

sub equal_one()
{
	local $_ = shift;
	for (my $i = 0; $i<=$#equal_1; $i++)
	{
		while(/^$big5*?$equal_1[$i]/)
		{
			s/^($big5*?)$equal_1[$i]/$1一/;			# 換成 "一" 這個字
		}
	}
	return $_;
}

#######################################
# 將特殊的字或詞變成沒有字
#######################################

sub equal_zero()
{
	local $_ = shift;
	for (my $i = 0; $i<=$#equal_0; $i++)
	{
		while(/^$big5*?$equal_0[$i]/)
		{
			s/^($big5*?)$equal_0[$i]/$1/;			# 拿掉這個字
		}
	}
	return $_;
}

#######################################
# end
#######################################