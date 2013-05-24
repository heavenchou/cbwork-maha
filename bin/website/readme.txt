本目錄的程式主要是經文上網更新使用

	1. Xnor2Rnor.pl	　將 normal/app X 版轉成 normal/app R 版.
 	   Xnor2Rnor_uni.pl	　將 unicode normal/app X 版轉成 unicode normal/app R 版.

		以上要下的參數主要有二個
		
		$from_vol = 11; # 開始冊數
		$to_vol = 16; # 結束冊數
		
		而且各版都有 normal 及 app1 要處理，所以二支程式共會產生四個版本：normal, app1, normal_utf8, app1_utf8 
		
		因為有這二組參數要分別執行。 (unicode 版依此類推)
		
		$source_path = "c:/release/normal/";
		$out_path = "c:/release/normal_R/";
		
		$source_path = "c:/release/app1/";
		$out_path = "c:/release/app1_R/";

	2.用 c:\cbwork\bin\website\make_Txxhtm.pl 是將大正藏每一冊的目錄索引做成 html 檔
	   用 c:\cbwork\bin\website\make_Xnnhtm.pl 是將卍續藏每一冊的目錄索引做成 html 檔

		要先改程式的日期變數，表示上網的日期。
		
		my $updatedate = '2006/06/23'; # 完成日期
		
		並且要記得加上各冊部類名稱
		
		sub get_part()
		{
		$part[0] = '印度撰述一';
		...... 
		$part[87] = '史傳部十四';
		}
		
		執行時要下參數，分別是起始冊及終止冊，否則就是全部。底下是第 11 冊至第 16 冊的例子：

		perl make_Xnnhtm.pl 11 16 
	  
	  
	3.使用程式 c:\cbwork\bin\website\make_Ttoc.pl 是將大正藏每一經的目錄索引做成 html 檔.
	  使用程式 c:\cbwork\bin\website\make_Xtoc.pl 是將卍續藏每一經的目錄索引做成 html 檔.

		要先改程式的日期變數，表示上網的日期。
		
		my $updatedate = '2006/06/23'; # 完成日期
		
		若有特殊卷或不連續卷，要在程式中特別處理。
		
		執行時要下參數，分別是起始冊及終止冊，否則就是全部。底下是第 11 冊至第 16 冊的例子：
		
		perl make_Xtoc.pl 11 16 

	4.normal2htm.pl   將 normal(app) 版做成 html 線上版.

		主要可能會修改的參數如下:
		
		$TX = "X"; # 大正藏用 "T" , 卍續藏用 "X"
		$from_vol = 11; # 起始冊數
		$to_vol = 16; # 終止冊數
		$run_x2r = 1; # 1: 要, 0: 不是, 是否要處理卍續藏X版轉換R版的動作
		$out_path = "d:/cbeta.www/result/normal/"; # 輸出目錄

		參數設定好之後，直接執行即可。