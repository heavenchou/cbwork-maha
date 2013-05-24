#####################################################################
# multigrep.pl                                             ~by heaven
# 萬用搜尋程式
# CVS版本 $Id: multigrep.pl,v 1.2 2004/11/16 13:33:03 heaven Exp $
# 說明：
#   萬用搜尋程式, 參數請依下列的順序輸入.
#
# 參數依序如下 :
#   來源目錄 : 搜尋的起始目錄, 請用 / 取代 \ 使用, 若目錄中有空白, 請用雙引號 " " 將目錄名括起來.
#   檔名樣式 : 可用多組萬用字元, 分隔請用用半型空格, 外面用雙引號 " " 將目錄名括起來, 例如 : "a*.txt b*.dat"
#   輸出檔名 : 輸出的結果檔名, 可配合漢書搜尋.
#   搜尋字串檔 (或字串) : 可為單一字串, 或是有多字串的檔名, 後者要用 -f: 當成開頭, 例如 -f:a.txt
#   是否包含子目錄 : 1 表示搜尋包含子目錄 , 0 表示不包含子目錄
#   是否為正規式搜尋 : 1 表示正規式(regular expression)搜尋, 請注意中文問題, 0 表示一般文字搜尋
#   區分大小寫 : 1 表示區分大小寫,但速度比較慢, 0 表示不區分大小寫
#   日期 (還沒做, 以後再說)
#   大小 (還沒做, 以後再說)
# Copyright (C) 1998-2004 CBETA
# Copyright (C) 2004 Heaven Chou
#####################################################################
#2004/11/15 V0.1 : 測試版完成
#2004/11/11 V0.0 : 開始
#####################################################################

use strict;
use Cwd;

my $SourcePath = shift;
my $FilePattern = shift;
my $OutputFileName = shift; 
my $SearchFileName = shift; 
my $IsIncludeSubDir = shift;
my $IsRegEx = shift; 
my $IsCaseSen = shift; 
my $DateRange = shift; 
my $SizeRange = shift; 

#$SourcePath = "D:/cbeta.src/";
#$FilePattern = "\"so*.txt re*\"";
#$OutputFileName = "findlog.txt";
#$SearchFileName = "-f:findword.txt";
#$SearchFileName = "臚";
#$IsIncludeSubDir = 1;
#$IsRegEx = 0;
#$IsCaseSen = 1;

#####################################################################
# 變數
#####################################################################

local *IN;
local *OUT;
local *DIR;

my @SearchWord = ();		# 存放搜尋的字詞
my @SearchWordU = ();		# 存放搜尋的字詞, 若不區分大小寫, 則換成大寫, 而且要加 \Q\E 處理正規式

my $TotalSearchFileNum = 0;		# 總共搜尋檔案數
#my $TotalMatchFileNum = 0;		# 符合要求檔案數
#my $TotalMatchLineNum = 0;		# 符合要求的總行數, 要給 @LineData , @FoundLines 用的

#輸出檔的架構
#尋找 '賚' 於 'C:\cbwork\xml\T54\T54n2130.xml' :
#3579: <lb n="1027a02"/><item>須闍<note place="inline">應云脩闍低　譯曰好生</note></item>
#找到 '賚' 1 次。

my @FoundFiles = ();	# 每一個找到的檔名 C:\cbwork\xml\T54\T54n2130.xml
my @LineData = ();		# 每一個找到的行的相關資料, <fn><n><n>...., <fn>第幾個檔案, <n>第幾個要找的字
my @FoundLines = ();	# 每一個找到的行, 3579: <lb n="1027a02"/><item>須闍<note place="inline">應云脩闍低　譯曰好生</note></item>


my @WordFoundFiles = (); 		# 每個詞共在幾個檔案中發現
my @WordLastFoundFile = (); 	# 記錄剛剛找到此詞的檔, 若和目前不同, $WordFoundFiles[$] 就加 1
my @TotalSearchWordNum = ();	# 儲存每一個詞共找到幾次
	
my $big5='(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
#####################################################################
# 主程式
#####################################################################

AnalysisPara();					# 檢查一切參數
SearchDir($SourcePath);			# 開始搜尋
OutputFile();					# 將結果輸出

print STDOUT "OK, 任意鍵結束...";
<>;

# 主程式結束

#####################################################################
# 檢查一切參數
#####################################################################
sub AnalysisPara
{
    CheckSourcePath();		# check source path
	CheckFilePattern();		# check File Pattern
	CheckOutputFile();		# check output file
	CheckSearchWord();		# check search word or file
	CheckIncludeSubDir();	# check is Include SubDir
	CheckIsRegEx();			# check is Regular Expression
	CheckIsCaseSen();		# check is case sensitive
}
#--------------------------------------------------------------------
sub CheckSourcePath
{
    unless(-d $SourcePath)
    {
        print STDERR "錯誤 : 找不到 $SourcePath , 任意鍵離開...";
        <>;
        exit;
    }
    $SourcePath =~ s#/#\\#g;
    $SourcePath =~ s#\\$##g;
}
#--------------------------------------------------------------------
sub CheckFilePattern
{
	if($FilePattern =~ /^"(.*)"$/)
	{
		$FilePattern = $1;
	}

    if($FilePattern eq "")
    {
    	$FilePattern = "*.*";
    }
}
#--------------------------------------------------------------------
sub CheckOutputFile
{
    if($OutputFileName eq "")
    {
	    print STDERR "錯誤 : 沒有輸出檔名, 任意鍵離開...";
        <>;
        exit;
    }
}
#--------------------------------------------------------------------
sub CheckSearchWord
{
	local $_;
    if($SearchFileName eq "")
    {
	    print STDERR "錯誤 : 沒有要查詢的字串, 任意鍵離開...";
        <>;
        exit;
    }
    
	# 如果是 -f: 開頭, 就當成檔案, 一行一個 searchword, 否則就是以參數當成 searchword
	if($SearchFileName =~ /^\-f:/i)
	{
		$SearchFileName =~ s/^\-f://i;
		
		open IN, $SearchFileName || die "open $SearchFileName error. $!";
		while(<IN>)
		{
			chomp();
			push(@SearchWord, $_);
			push(@SearchWordU, $_);
			push(@TotalSearchWordNum, 0);	# 每一詞找到的數目
			push(@WordFoundFiles, 0);		# 每一詞在幾個檔案中找到
			push(@WordLastFoundFile, -1);	# 記錄剛剛找到此詞的檔, 若和目前不同, $WordFoundFiles[$] 就加 1
		}
		close IN;
	}
	else
	{
		$SearchWord[0] = $SearchFileName;
		$SearchWordU[0] = $SearchFileName;
		$TotalSearchWordNum[0] = 0;			# 每一詞找到的數目
		$WordFoundFiles[0] = 0;				# 每一詞在幾個檔案中找到
		$WordLastFoundFile[0] = -1;			# 記錄剛剛找到此詞的檔, 若和目前不同, $WordFoundFiles[$] 就加 1
	}
	
	#判斷有沒有用區分大小寫
	if(!$IsCaseSen)
	{
			for(my $i = 0; $i<= $#SearchWordU; $i++)		# 不區分大小寫, 就全部變大寫
			{
				$_ = $SearchWordU[$i];
				# 先換原句
				my $tmp = "";
				while(s/^($big5)//)
				{
					my $word = $1;
					if(length($word) == 1)
					{
						$tmp .= uc($word);		# 英文字換大寫
					}
					else
					{
						$tmp .= $word;			# 中文字不換
					}
				}
				$SearchWordU[$i] = $tmp;
			}
	}
	
		# 處理正規式
		for(my $i=0; $i<=$#SearchWordU; $i++)
		{
			# 判斷有沒有用正規式
			if($IsRegEx)
			{
				# 正規式, 所有中文之都要加 \Q \E
				$_ = $SearchWordU[$i];
				# 先換原句
				my $tmp = "";
				while(s/^($big5)//)
				{
					my $word = $1;
					if(length($word) == 1)
					{
						$tmp .= $word;			# 英文字不管
					}
					else
					{
						$tmp .= "\Q$word\E";	# 中文字加 \Q \E
					}
				}
				$SearchWordU[$i] = $tmp;
			}
			else
			{
				# 若不是正規式, 則要將中文的特殊文字避開
				$SearchWordU[$i] = "\Q$SearchWordU[$i]\E";
			}
		}
}
#--------------------------------------------------------------------
sub CheckIncludeSubDir
{
	if($IsIncludeSubDir eq "")
    {
	    $IsIncludeSubDir = 1;
    }
}
#--------------------------------------------------------------------
sub CheckIsRegEx
{
	if($IsRegEx eq "")
    {
	    $IsRegEx = 0;
    }
}
#--------------------------------------------------------------------
sub CheckIsCaseSen
{
	if($IsCaseSen eq "")
    {
	    $IsCaseSen = 1;
    }
}
#####################################################################
# 開始搜尋
#####################################################################
sub SearchDir
{
	my $ThisDir = shift;
	
	my $myPath = getcwd();
	chdir($ThisDir);
	my @files = glob($FilePattern);
	chdir($myPath);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);
		$file = $ThisDir . "\\" . $file ;
		if (-f $file)
		{
			print "$file\n";
			$TotalSearchFileNum++;		# 搜尋檔案數 + 1
			SearchFile($file);
		}
	}
	
	return unless($IsIncludeSubDir);	# 若不搜尋子目錄就離開
	
	opendir (DIR, "$ThisDir");
	@files = readdir(DIR);
	closedir(DIR);
	
	foreach my $file (sort(@files))
	{
		next if($file =~ /^\./);
		$file = $ThisDir . "\\" . $file ;
		if (-d $file)
		{
			SearchDir($file);
		}
	}	
}
#####################################################################
# 在檔案中搜尋
#####################################################################
sub SearchFile
{
	my $file = shift;
	my $LineNum = 0;
	local $_;
	my $IsFound = 0;	# 找到才設為 1
	
	open IN, "$file" || die "open $file error : $!";
	while(<IN>)
	{
		my $ThisLine = $_;	# 若不區分大小寫, $_ 會變成大寫, 而 $ThisLine 則是要輸出用的標準句子
		$LineNum++;
		my $ThisLineRecord = 0;		# 若此行有找到, 則設為 1
		for(my $i=0; $i<= $#SearchWord; $i++)
		{
			my $SearchWord = $SearchWordU[$i];
						
			#判斷有沒有用區分大小寫
			if(!$IsCaseSen)		# 不區分大小寫, 就全部變大寫
			{
				# 先換原句
				my $tmp = "";
				while(s/^($big5)//)
				{
					my $word = $1;
					if(length($word) == 1)
					{
						$tmp .= uc($word);		# 英文字換大寫
					}
					else
					{
						$tmp .= $word;			# 中文字不換
					}
				}
				$_ = $tmp;
			}

			# 判斷是否找到此字串
			if(/$SearchWord/)
			{
				if(/^(($big5)*?$SearchWord)/)
				{
					# 若此檔第一次找到要找的, 就將此檔記錄起來
					if($IsFound == 0)
					{
						$IsFound = 1;
						push(@FoundFiles , $file);		# 將檔名存起來
					}
					#my @FoundFiles = ();	# 每一個找到的檔名 C:\cbwork\xml\T54\T54n2130.xml
					#my @LineData = ();		# 每一個找到的行的相關資料, <fn><n><n>...., <fn>第幾個檔案, <n>第幾個要找的字
					#my @FoundLines = ();	# 每一個找到的行, 3579: <lb n="1027a02"/><item>須闍<note place="inline">應云脩闍低　譯曰好生</note></item>
				
					# 若此行第一次找到要找的, 就將此行記錄起來
					if($ThisLineRecord == 0)
					{
						$ThisLineRecord = 1;
						my $tmp = sprintf("%06d:%s", $LineNum, $ThisLine);	# 要用原始的 $ThisLine
						push(@FoundLines , $tmp);		# 將該行存起來
						$LineData[$#FoundLines] = "<f$#FoundFiles>";
					}
					$LineData[$#FoundLines] .= "<$i>";
					
					if($WordLastFoundFile[$i] != $#FoundFiles)
					{
						$WordLastFoundFile[$i] = $#FoundFiles;
						$WordFoundFiles[$i]++;				# 此字出現的檔案數
					}
					
					# 計算此行共出現幾次此詞
					
					my $tmp = $_;
					while($tmp =~ /^($big5)*?$SearchWord/)
					{
						$tmp =~ s/^($big5)*?$SearchWord//;
						$TotalSearchWordNum[$i]++;	# 找到詞的數目 + 1
					}
				}
			}
		}
	}
	close IN;	
}
#####################################################################
# 將結果輸出
#####################################################################
sub OutputFile
{
	print STDERR "處理輸出檔";

	#my @FoundFiles = ();	# 每一個找到的檔名 C:\cbwork\xml\T54\T54n2130.xml
	#my @LineData = ();		# 每一個找到的行的相關資料, <fn><n><n>...., <fn>第幾個檔案, <n>第幾個要找的字
	#my @FoundLines = ();	# 每一個找到的行, 3579: <lb n="1027a02"/><item>須闍<note place="inline">應云脩闍低　譯曰好生</note></item>
	
	open OUT, ">$OutputFileName" || die "open $OutputFileName error :$!";
	
	print OUT "總共搜尋 $TotalSearchFileNum 個檔案\n";
	
	# 先印出每一個詞共出現幾次
	for(my $i=0; $i<= $#SearchWord; $i++)
	{
		print OUT "$SearchWord[$i] : 出現在 $WordFoundFiles[$i] 個檔案中, 共出現過 $TotalSearchWordNum[$i] 次\n";
	}
	print OUT "\n";
	
	# 先依詞, 再依檔, 再依行印出結果
	
	for(my $i=0; $i<= $#SearchWord; $i++)
	{
		my $NowFile = -1;					# 目前正在處理的檔案
		my $NowFileLineNum = 0;
		for(my $j=0; $j<= $#LineData; $j++)
		{
			# $j 行有第 $i 個要查的字
			if($LineData[$j] =~ /<$i>/)
			{
				$LineData[$j] =~ /^<f(\d+)>/;	# 取出此行的檔案資料
				my $tmp = $1;
				if($NowFile != $tmp)	# 第一次出現則要印出檔名
				{
					print STDERR ".";
					if($NowFile != -1)
					{
						#C:\Documents and Settings\maha.MAHA1\桌面\B01_p0071.txt : found 4=> 經
						print OUT "$FoundFiles[$NowFile] : found $NowFileLineNum ==> $SearchWord[$i]\n\n";
					}
					$NowFile = $tmp;
					$NowFileLineNum = 0;	# 此檔的行數計數歸 0
				}
				$NowFileLineNum++;				# 此檔找到的行數 + 1
				print OUT $FoundLines[$j];
			}
		}
		print OUT "$FoundFiles[$NowFile] : found $NowFileLineNum ==> $SearchWord[$i]\n\n";
	}
	close OUT;	
	
	print STDERR "ok\n";
}
#####################################################################