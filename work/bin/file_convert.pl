############################################################################
#
# files convert                                                    by heaven
#
# 將二個目錄的檔案做一些處理, 例如 big5 to utf8, 組字式 to 通用字 , 或是比對
#
############################################################################

use Win32::ODBC;

#####################
# 參數
#####################

##########################################
# 執行功能
# 1. 二組檔案比對 : comp2file
# 2. 組字式轉成通用字 : des2nor
# 3. big5 轉成 utf8 : big52utf8
# 4. 將 utf8 變成 big5 格式, 不過這裡是一冊接成一檔
##########################################

my $function = "comp2file";		# 比對二個目錄的檔案
# my $function = "des2nor";			# 將 組字式 變成 通用字 格式
# my $function = "big52utf8";		# 將 big5 變成 utf8 格式
# my $function = "utf82big5";		# 將 utf8 變成 big5 格式, 一冊接成一檔, 且不用設 source_root 及target_root

my $source_root = "C:/cbwork/simple/release/normal/";		# 來源目錄

# my $source_root = "C:/release/normal-des/";					# 來源目錄
# my $source_root = "c:/release/app1-des/";					# 來源目錄

# my $source_root = "C:/cbwork/xml/";						# 來源目錄

##my $source_root = "C:/Release/cbr_out/";					# 來源目錄
##my $source_root = "C:/Release/app1/";						# 來源目錄
##my $source_root = "C:/release/utf8-xml/";					# 來源目錄
##my $source_root = "C:/release/xml-utf8/";					# 來源目錄

my $target_root = "c:/release/normal/";			# 目的目錄

# my $target_root = "c:/release/normal-des-nor/";	# 目的目錄
# my $target_root = "c:/release/app1-des-nor/";		# 目的目錄
# my $target_root = "c:/release/normal-des-utf8/";	# 目的目錄
# my $target_root = "c:/release/app1-des-utf8/";		# 目的目錄

# my $target_root = "c:/release/xml-utf8/";			# 目的目錄

my $file_ext = "*.*";								# 要處理的副檔名

my $TFrom = 1; 	# 大正藏處理冊數開始
my $Tto = 85;		# 大正藏處理冊數結束
my $XFrom = 11;		# 卍續藏處理冊數開始
my $Xto = 16;		# 卍續藏處理冊數結束

my $runT = 0;		# 執行大正藏
my $runX = 1;		# 執行卍續藏

# 1. 二組檔案比對 專用變數

my $difffile = "2filediff.txt";		# 功能 1 的差異檔

my $skip_fullspace = 0;				# 忽略全型空白
my $skip_space = 0;					# 忽略半型空白
my $skip_juan_head = 0;				# 忽略卷首資料
my $skip_enter = 1;					# 忽略換行
my $skip_siddam = 0;				# 忽略悉曇字
my $skip_line_head = 0;				# 忽略行首 (app 及 normal)
my $skip_para_head = 0;				# 忽略段首 (pda)

# 2. 組字式轉成通用字 專用變數
# 3. big5 轉成 utf8 專用變數

my $des2uni = 1;					# 是否要將缺字換成 unicode ? (xml 不用, normal, app 要)
my $des2nor = 1;					# 是否要將缺字換成通用字 ? (xml 不用, normal, app 要)(T54n2128 及 2129 會自動取消)

# 4. utf8 轉成 big5 專用變數

my $extispdf = 1;						# 若處理pdf , 則為 1, 否則為 0
my $easyver = 1;						# 若為 1 則自動忽略行首,換行與全半型空格, 用 wincommand 即可比對. 0 則留下行首, 用 wfgfc 比對.

######################## 以下可以不用管 #######################################

my $ext = "_pdf.txt";					# 結合大檔後的附名, 例如 T01_pdf.txt
#app 設為 1
my $remove_linehead_eng = 0;			# 將行首的英文換掉, 比對時才不用忽略英文.
my $onlyTX = 0;							# 只留下行首是 TX 開頭的文字, 也就是排除卷首
#pdf 設為 1
my $skiptag = 1;						# 忽略標記

if($function eq "utf82big5")
{
	if($extispdf) # pdf 版
	{
		$source_root = "C:/release/pdf/";						# 來源目錄
		$target_root = "c:/release/pdf_out/pdf/";			# 目的目錄
		$ext = ".txt";					# 結合大檔後的附名, 例如 T01_pdf.txt
		$file_ext = "*.txt";
		#app 設為 1
		$remove_linehead_eng = 0;			# 將行首的英文換掉, 比對時才不用忽略英文.
		$onlyTX = 0;						# 只留下行首是 TX 開頭的文字, 也就是排除卷首
		#pdf 設為 1
		$skiptag = 1;						# 忽略標記
	}
	else # app 版
	{
		$source_root = "C:/Release/app1-utf8/";			# 來源目錄
		$target_root = "c:/release/pdf_out/app1/";			# 目的目錄
		$ext = ".txt";					# 結合大檔後的附名, 例如 T01_pdf.txt
		$file_ext = "*.txt";
		#app 設為 1
		$remove_linehead_eng = 1;			# 將行首的英文換掉, 比對時才不用忽略英文.
		$onlyTX = 1;						# 只留下行首是 TX 開頭的文字, 也就是排除卷首
		#pdf 設為 1
		$skiptag = 0;						# 忽略標記
	}
}
####################################################################################
# 變數
####################################################################################

my $utf8 = '(?:\&[^;#]+;|[\xe0-\xef][\x80-\xbf][\x80-\xbf]|[\xc2-\xdf][\x80-\xbf]|[\x0-\x7f])';
my $big5 = '(?:(?:[\x80-\xff][\x00-\xff])|(?:[\x00-\x7f]))';
my $losebig5='(?:(?:[\x80-\xff][\x40-\xff])|[\x00-\x3d]|[\x3f-\x5a]|\x5c|[\x5e-\x7f])';

####################################################################################
# 主程式
####################################################################################

require "b52utf8.plx" if($function eq "big52utf8");  ## this is needed for handling the big5 entity replacements
require "utf8b5o.plx" if($function eq "utf82big5");  ## this is needed for handling the big5 entity replacements
require "siddam.plx"  if($function eq "utf82big5");  ## this is needed for handling the big5 entity replacements

mkdir ($target_root) unless(-d $target_root);

# 讀取缺字

my %table;
readGaiji() if($function eq "big52utf8" or  $function eq "des2nor");

# 處理全部目錄

open OUT, ">$difffile" if($function eq "comp2file");

$TFrom = 999 if($runT == 0);
$XFrom = 999 if($runX == 0);

for(my $i = $TFrom; $i<= $Tto; $i++)
{
	$i = 85 if ($i == 56);
	$vol = sprintf("T%02d", $i);
	dothisdir($vol);
}
for(my $i = $XFrom; $i<= $Xto; $i++)
{
	$i = 7 if ($i == 6);
	#$i = 54 if ($i == 11);
	$vol = sprintf("X%02d", $i);
	dothisdir($vol);
}
close OUT if($function eq "comp2file");
print "ok!\n";
<>;
exit;

# 處理單一目錄

sub dothisdir
{
	my $vol = shift;
	my $source_dir = $source_root . $vol . "/$file_ext";
	my $target_dir = $target_root . $vol . "/";
	if($function eq "utf82big5")	# utf8 2 big5 不需要子目錄, 因為我要一冊接成一大檔
	{
		open OUT, ">${target_root}${vol}${ext}" or die "open ${target_root}${vol}${ext} error";
	}
	else
	{
		mkdir ($target_dir) unless(-d $target_dir);
	}
	my @files = <{$source_dir}>;
	foreach my $file (sort(@files))
	{
		my $outfile = $file;
		if($file =~ /.*\/(.*)/)
		{
			$outfile = $1;
		}
		dothisfile($file, "${target_dir}$outfile");
	}
	close OUT if($function eq "utf82big5");	# utf8 2 big5 不需要子目錄, 因為我要一冊接成一大檔
}

# 處理單一檔案

sub dothisfile
{
	my $file_from = shift;
	my $file_to = shift;
	print $file_from . "\n";
	
	##########################################################################
	if($function eq "big52utf8" or  $function eq "des2nor")
	{
		open IN, "$file_from" or die "open $file_from error";
		open OUT, ">$file_to" or die "open $file_to error";
		
		while(<IN>)
		{
			$_ = big52utf8ln($_) if ($function eq "big52utf8");
			$_ = des2norln($_) if ($function eq "des2nor");
			print OUT;
		}

		close OUT;
		close IN;
	}
	# utf8 2 big5 ##################################################################
	elsif ($function eq "utf82big5")	
	{
		open IN, "$file_from" or die "open $file_from error";

		if($skiptag)
		{
			while(<IN>)
			{
				last if(/Vol\./);
			}
			<IN>;
		}	
		while(<IN>)
		{
			if($onlyTX)
			{
				next unless(/^[TX]/);
			}
			if($skiptag)
			{
				s/<.*?>//g;
				s/^\s*P. (\d+)$//;
			}
			$_ = utf82big5ln($_);
			#s/大正新脩大正藏經/卍新纂續藏經/;
			#s/2005\/3\/26/2005\/4\/5/;

			print OUT;
		}

		close IN;
	}
	# 比對檔案 ##########################################################################
	elsif ($function eq "comp2file")	
	{
		my $space = '　';
		open IN, "$file_from" or die "1 open $file_from error";
		open IN1, "$file_to" or die "2 open $file_to error";
		print OUT "$file_from\n";
		while(<IN>)
		{
			#next if(/<!ENTITY CB00108/);
			my $line = <IN1>;
		
			#while($line =~ /^(([#=])|(【))/)	###########----------------------------------
			#{
			#	$line = <IN1>;
			#}
			if($_ ne $line)
			{
				#my $skip_fullspace = 0;				# 忽略全型空白
				#my $skip_space = 0;					# 忽略半型空白
				#my $skip_juan_head = 0;				# 忽略卷首資料
				#my $skip_enter = 0;					# 忽略換行
				#my $skip_siddam = 1;					# 忽略悉曇字
				#my $skip_line_head = 0;				# 忽略行首 (app 及 normal)
				#my $skip_para_head = 0;				# 忽略段首 (pda)
				
				my $line1 = $_;
				my $line2 = $line;
				
				if($skip_juan_head)				# 忽略卷首資料
				{
					if(/^((#)|(【))/)
					{
						next;
					}
				}
				if($skip_fullspace)				# 忽略全型空白
				{
					$line1 =~ s/$space//g;
					$line2 =~ s/$space//g;
				}
				if($skip_space)					# 忽略半型空白
				{
					$line1 =~ s/ //g;
					$line2 =~ s/ //g;
				}
				if($skip_enter)					# 忽略換行
				{
					$line1 =~ s/\n$//;
					$line2 =~ s/\n$//;
					$_ =~ s/(\n)?$/\n/;
					$line =~ s/(\n)?$/\n/;
				}
			#	$line1 =~ s/║◎/║/;###########----------------------------------
			#	$line2 =~ s/║◎/║/;###########----------------------------------
			#	$line1 =~ s/◎$//;###########----------------------------------
			#	$line2 =~ s/◎$//;###########----------------------------------

				#while(/^((${big5})*)紩/)
				#{
				#	s/^((${big5})*)紩/$1鐵/;
				#}
				#$_ =~ s=\Q[虫*矞]\E=鷸=g;
				#$_ =~ s=\Q[鹿/霝]\E=羚=g;
				#$_ =~ s=\Q[羊*星]\E=腥=g;
				#$_ =~ s=\Q[赤*(栗-木+土)]\E=胭=g;
				#$_ =~ s=\Q[打-丁+羕]\E=樣=g;
				#$_ =~ s=\Q[卄/附]\E=附=g;
				#$_ =~ s=\Q[赤*支]\E=脂=g;
				#$_ =~ s=\Q[言*勞]\E=嘮=g;
				#$_ =~ s=\Q[打-丁+敖]\E=摮=g;
				#$_ =~ s=\Q[略/手]\E=撂=g;
				#$_ =~ s=\Q[解/魚]\E=蟹=g;
				#$_ =~ s=\Q[香*郁]\E=郁=g;
			
				if($line1 ne $line2)
				{
					if($skip_siddam)					# 忽略悉曇字
					{
						while($line1 =~ /^(?:$big5)*?(([a-zA-Z`\.^~! ])|(【◇】)|(◇)|(□)|(‧)|(〔)|(〕)|(（)|(\Q）\E)|(…))/)
						{
							$line1 =~ s/^(($big5)*?)(([a-zA-Z`\.^~! ])|(【◇】)|(◇)|(□)|(‧)|(〔)|(〕)|(（)|(\Q）\E)|(…))/$1/;
						}
						while($line2 =~ /^(?:$big5)*?(([a-zA-Z`\.^~! ])|(【◇】)|(◇)|(□)|(‧)|(〔)|(〕)|(（)|(\Q）\E)|(…))/)
						{
							$line2 =~ s/^(($big5)*?)(([a-zA-Z`\.^~! ])|(【◇】)|(◇)|(□)|(‧)|(〔)|(〕)|(（)|(\Q）\E)|(…))/$1/;
						}
					}
					
					###############
					#if($line1 =~ /<edition>/) { $line1 =~ s/\(Big5\)/(UTF-8)/;}
					#$line1 =~ s/n="\d+" label/label/;
					#$line1 =~ s/div[321]/divn/;
					#$line2 =~ s/div[321]/divn/;
					#$line1 =~ s/level="[321]"/level="n"/;
					#$line2 =~ s/level="[321]"/level="n"/;
					#$line1 =~ s/uniflag='[210]'//;
					#$line2 =~ s/uniflag='[210]'//;
					#$line1 =~ s/<!-- -\*- charset: CP950 -\*- -->//;
					#$line2 =~ s/<!-- -\*- charset: CP950 -\*- -->//;
					#$line1 =~ s/ uni='.*?'//;
					#$line2 =~ s/ uni='.*?'//;
					###############
					
					if($line1 ne $line2)
					{
						print OUT "$_";
						print OUT "$line";
						print OUT "-----------------------------------------------\n";
					}
				}
			}
		}
		close IN;
		close IN1;		
	}
	##########################################################################
}

#############################################################################
# function : big5 to utf8

sub big52utf8ln
{
	my $line = shift;
	
	$line =~ s/encoding="big5"/encoding="UTF-8"/;		# xml 版
	$line =~ s/coding: big5-dos/charset: CP950/;		# xml 版
	$line =~ s/\(Big5\)/\(UTF-8\)/i;
	my $result = "";
	my $mydes2nor = $des2nor;
	
	if(($line =~ /T54n212[89]/) or ($line =~ /T34n1723_p0776c11/))
	{
		$mydes2nor = 0;
	}
	
	if($mydes2nor)	# 有需要換成通用字, 所以先換通用詞
	{
		if($des2uni == 0)	# 若要換成 unicode , 底下這些就不用換成通用詞
		{
			$line =~ s=\Q髣髣[髟/弗][髟/弗]\E=彷彷彿彿=g;
		
		    $line =~ s/\Q礔[石*歷]\E/霹靂/g;
			$line =~ s/\Q[立*令]竮\E/伶俜/g;
			$line =~ s=\Q髣[髟/弗]\E=彷彿=g;
			$line =~ s/\Q搪[打-丁+突]\E/唐突/g;
			$line =~ s=\Q[髟/弗]髣\E=彿彷=g;
			$line =~ s/\Q嬰[女*亥]\E/嬰孩/g;
			$line =~ s=\Q[辟/石][石*歷]\E=霹靂=g;
			#$line =~ s/\Q琅[王*耶]\E/瑯琊/g;
			#$line =~ s=\Q瑯[王*耶]\E=瑯琊=g;
		}
		
		# 這些是沒有 unicode 的
		
		$line =~ s/\Q[跍*月]跪\E/胡跪/g;
		$line =~ s=\Q鴶[亢*鳥]\E=頡頏=g;
		$line =~ s=\Q[王*頗][王*梨]\E=頗梨=g;
		$line =~ s/\Q[仁-二+唐][仁-二+突]\E/唐突/g;
		$line =~ s=\Q[商*鳥][羊*鳥]\E=商羊=g;
	}

	while($line =~ /^($big5)/)
	{
		my $token = $1;
		if($line =~ /^(\[$losebig5*?\])/)	# 是組字式
		{
			my $loseword = $1;
			if($des2uni)	# 要將組字式換成 unicode 
			{
				if($table_uni{$loseword})				# 此組字式有 unicode
				{
					$result .= $table_uni{$loseword};
					$line =~ s/^\Q$loseword\E//;
					next;
				}
			}

			if($mydes2nor)	# 要將組字式換成 normal
			{
				if($table_nor{$loseword})				# 此組字式有通用字
				{
					$token = $table_nor{$loseword};
					$line =~ s/^\Q$loseword\E/$token/;
				}
			}
		}
		
		# 至此, 組字式不換成 unicode , 或是非組字式, 或是組字式無 unicode 
		
		if (exists $b52utf8{$token}) 
		{
			$result .= $b52utf8{$token};
			$line =~ s/^\Q$token\E//;
		}
		else
		{
			print STDERR "$line\n";
			print STDERR "$token\n";
			die "Error: not in big52utf8 table. char:[$token] hex:" . unpack("H4",$token) ;
		}
	}
	return $result;
}

#############################################################################
# function : 組字式換成通用字

sub des2norln
{
	local $_ = shift;
	
	# 有 2128 及 2129 經及某行不用換通用字
	
	if(($_ !~ /T54n212[89]/) and ($_ !~ /T34n1723_p0776c11/))
	{
		# 換通用詞
		
		s=\Q髣髣[髟/弗][髟/弗]\E=彷彷彿彿=g;
		
		s/\Q礔[石*歷]\E/霹靂/g;
		s/\Q[立*令]竮\E/伶俜/g;
		s=\Q髣[髟/弗]\E=彷彿=g;
		s/\Q[跍*月]跪\E/胡跪/g;
		s/\Q搪[打-丁+突]\E/唐突/g;
		s=\Q[髟/弗]髣\E=彿彷=g;
		s=\Q鴶[亢*鳥]\E=頡頏=g;
		s/\Q嬰[女*亥]\E/嬰孩/g;
		s=\Q[辟/石][石*歷]\E=霹靂=g;
		#s/\Q琅[王*耶]\E/瑯琊/g;
		s=\Q[王*頗][王*梨]\E=頗梨=g;
		s/\Q[仁-二+唐][仁-二+突]\E/唐突/g;
		s=\Q[商*鳥][羊*鳥]\E=商羊=g;
		#s=\Q瑯[王*耶]\E=瑯琊=g;
		
		# 換通用字
		
		s/(\[$losebig5*?\])/($table_nor{$1}||$1)/ge;
	}
	return $_;
}

#############################################################################
# function : utf82big5

sub utf82big5ln
{
	local $line = shift;
	my $result = "";
	
	while($line =~ /^($utf8)/)
	{
		my $token = $1;

		if (exists $utf8out{$token}) 
		{
			if($easyver == 1)
			{ 
				if($utf8out{$token} eq "◎")	# 這些是不比對的符號
				{
				}
				elsif($utf8out{$token} eq "。")
				{
				}
				else
				{
					$result .= $utf8out{$token};
				}
			}
			else
			{
				$result .= $utf8out{$token};
			}
			$line =~ s/^\Q$token\E//;
		}
		else
		{			
			my $tmp = uc(unpack("H*",$token));
			my $c = uc(unpack("H*",UTF8toUCS2($token)));
			
			if(exists $sd2dia{$c})
			{
				$tmp = cbdia2smdia($sd2dia{$c});		# 悉曇字
			}
			else
			{
				$tmp = "&$tmp;";
			}

			$tmp = "AA" if($tmp eq "&C480;");
			$tmp = "aa" if($tmp eq "&C481;");
			$tmp = "ii" if($tmp eq "&C4AB;");
			$tmp = "^n" if($tmp eq "&E1B985;");
			$tmp = "~n" if($tmp eq "&C3B1;");
			$tmp = ".t" if($tmp eq "&E1B9AD;");
			$tmp = ".n" if($tmp eq "&E1B987;");
			$tmp = "uu" if($tmp eq "&C5AB;");
			$tmp = ".d" if($tmp eq "&E1B88D;");	
			$tmp = "`s" if($tmp eq "&C59B;");	
			$tmp = ".m" if($tmp eq "&E1B983;");
			$tmp = ".s" if($tmp eq "&E1B9A3;");
			$tmp = ".h" if($tmp eq "&E1B8A5;");
			$tmp = ".r" if($tmp eq "&E1B99B;");
			$tmp = "^m" if($tmp eq "&E1B981;");
			$tmp = "（" if($tmp eq "&EE8D9A;");
			$tmp = "）" if($tmp eq "&EE8D9B;");
			$tmp = "…" if($tmp eq "&EDA593;");
			$tmp = "□" if($tmp eq "&EE8D87;");
			$tmp = "‧" if($tmp eq "&EE8EBA;");
			$tmp = "◇" if($tmp eq "&EDA597;");
			$tmp = "◇" if($tmp eq "&ED9F84;");	
			$tmp = "◇" if($tmp eq "&ED96B4;");
			$tmp = "◇" if($tmp eq "&EDA786;");
			$tmp = "◇" if($tmp eq "&EE8D95;");
			
		
			$result .= $tmp;
			$line =~ s/^\Q$token\E//;
		}
	}
	if($remove_linehead_eng)
	{
		# T01n0098_p0924b02(02)║
		if($easyver)
		{
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d).(\d\d).*?║//i;
		}
		else
		{
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)a(\d\d).*?║/$1_$2_$3_1_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)b(\d\d).*?║/$1_$2_$3_2_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)c(\d\d).*?║/$1_$2_$3_3_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)d(\d\d).*?║/$1_$2_$3_4_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)e(\d\d).*?║/$1_$2_$3_5_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)f(\d\d).*?║/$1_$2_$3_6_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)g(\d\d).*?║/$1_$2_$3_7_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)h(\d\d).*?║/$1_$2_$3_8_$4/i;
			$result =~ s/^[TX](\d\d)n(\d\d\d\d).p(\d\d\d\d)i(\d\d).*?║/$1_$2_$3_9_$4/i;
		}
	}
	if($easyver)
	{
		$result =~ s/ //g;
		$result =~ s/　//g;
		$result =~ s/\n//g;
		$result =~ s/【圖】//g;
	}
	$result =~ s/\x0c//g;
	return $result;
}

#############################################################################
# 讀缺字

sub readGaiji {
	my $cb,$des,$nor,$uni,$uniflag;
	print STDERR "Reading Gaiji-m.mdb ....";
	my $db = new Win32::ODBC("gaiji-m");
	if ($db->Sql("SELECT * FROM gaiji")) { die "gaiji-m.mdb SQL failure"; }
	while($db->FetchRow())
	{
		undef %row;
		%row = $db->DataHash();
		
		$cb  = $row{"cb"};		# cbeta code
		$des = $row{"des"};		# 組字式
		$nor = $row{"nor"};		# 通用字
		$uni = $row{"uni"};		# unicode
		$uniflag = $row{"uni_flag"};		# unicode flag : 0 看不到, 1 看的到, 2 還沒確定
		
		next if ($cb !~ /^\d/);
		
		if($uni and $uniflag == 1)
		{
			my $val = pack "H4", $uni;
			$val = toutf8($val);		# unicode -> utf8
			$table_uni{$des} = $val;
		}
		
		if($nor)
		{
			$table_nor{$des} = $nor;
		}
	}
	$db->Close();

	# 額外的, 這是在 des2normal 時, 某些字先不要處理, 以配合舊的通用字內容
	
	#$table_nor{"[金*失]"} = "紩";
	#$table_nor{"[虫*矞]"} = "";
	#$table_nor{"[鹿/霝]"} = "";
	#$table_nor{"[羊*星]"} = "";
	#$table_nor{"[赤*(栗-木+土)]"} = "";
	#$table_nor{"[打-丁+羕]"} = "";
	#$table_nor{"[卄/附]"} = "";
	#$table_nor{"[赤*支]"} = "";
	#$table_nor{"[言*勞]"} = "";
	#$table_nor{"[打-丁+敖]"} = "";
	#$table_nor{"[略/手]"} = "";
	#$table_nor{"[解/魚]"} = "";
	#$table_nor{"[香*郁]"} = "";

	print STDERR "ok\n";
}

# unicode to utf8

sub toutf8
{
	my $in = $_[0];
	my $old;
	# encode UTF-8
	my $uc;
	for $uc (unpack("n*", $in)) {
#        print "$uc\n";
	    if ($uc < 0x80) {
		# 1 byte representation
		$old .= chr($uc);
	    } elsif ($uc < 0x800) {
		# 2 byte representation
		$old .= chr(0xC0 | ($uc >> 6)) .
	                chr(0x80 | ($uc & 0x3F));
	    } else {
		# 3 byte representation
		$old .= chr(0xE0 | ($uc >> 12)) .
		        chr(0x80 | (($uc >> 6) & 0x3F)) .
			chr(0x80 | ($uc & 0x3F));
	    }
	}
	return $old;
}

sub UTF8toUCS2 () {
	my $bytes = shift;
	if ($bytes eq "") {
		return "";
	}
	my $save = $bytes;
	if ($bytes =~ /^([\x00-\x7f])$/) {
		pack("n*",unpack("C*",$1));
	} elsif ($bytes =~ /^([\xC0-\xDF])([\x80-\xBF])$/) {
		pack("n", ((ord($1) & 31) << 6) | (ord($2) & 63) );
	} elsif ($bytes =~ /^([\xE0-\xEF])([\x80-\xBF])([\x80-\xBF])/) {
		pack("n", ((ord($1) & 15) << 12) | ((ord($2) & 63) << 6) | (ord($3) & 63));
	} else {
		die "bad UTF-8 data: [$save][" . unpack("H*",$save) . "]";
	}
}

sub toucs2
{
	local (@in) = (@_);
	local ($out) = "";
	if (defined $_[0]) {
	    my $bytes = shift @in;
	    $bytes =~ s/^[\200-\277]+//;  # can't start with 10xxxxxx
	    while (length $bytes) {
		if ($bytes =~ s/^([\000-\177]+)//) {
		    $out .= pack("n*", unpack("C*", $1));
		} elsif ($bytes =~ s/^([\300-\337])([\200-\277])//) {
		    my($b1,$b2) = (ord($1), ord($2));
		    $out .= pack("n", (($b1 & 0x1F) << 6) | ($b2 & 0x3F));
		} elsif ($bytes =~ s/^([\340-\357])([\200-\277])([\200-\277])//) {
		    my($b1,$b2,$b3) = (ord($1), ord($2), ord($3));
		    $out .= pack("n", (($b1 & 0x0F) << 12) |
                                        (($b2 & 0x3F) <<  6) |
				         ($b3 & 0x3F));
		} else {
#		    croak "Bad UTF-8 data";
		}
	    }
	} else {
	    $out = undef;
	}

    return $out;
}

sub cbdia2smdia {
	my $s=shift;
	$s=~s/n~/~n/g;
	$s=~s/a\^/aa/g;
	$s=~s/i\^/ii/g;
	$s=~s/s\//`s/g;
	$s=~s/u\^/uu/g;
	$s=~s/d!/\.d/g;
	$s=~s/h!/\.h/g;
	$s=~s/l!\^/\.ll/g;
	$s=~s/l!/\.l/g;
	$s=~s/m!/\.m/g;
	$s=~s/n%/^n/g;
	$s=~s/n!/\.n/g;
	$s=~s/r!\^/\.rr/g;
	$s=~s/r!/\.r/g;
	$s=~s/s!/\.s/g;
	$s=~s/t!/\.t/g;
	return $s;
}