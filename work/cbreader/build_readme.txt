build.pl 使用方法

 
建一個子目錄, 裡面放二個檔案, 一個是 build.pl , 一個是 buildlist.txt
 
其中 buildlist.txt 如下:
 
10
C:\cbeta\Normal\T01\T0001_001.txt
C:\cbeta\Normal\T01\T0001_002.txt
C:\cbeta\Normal\T01\T0001_003.txt
C:\cbeta\Normal\T01\T0001_004.txt
C:\cbeta\Normal\T01\T0001_005.txt
C:\cbeta\Normal\T01\T0001_006.txt
C:\cbeta\Normal\T01\T0001_007.txt
C:\cbeta\Normal\T01\T0001_008.txt
C:\cbeta\Normal\T01\T0001_009.txt
C:\cbeta\Normal\T01\T0001_010.txt
 
它就是每一卷普及版的位置, 第一行只是告訴程式, 底下有幾卷, 本例是 10 卷
然後執行 build.pl 就行了. 
 
執行後會再產生二個檔, 將那二個檔及 buildlist.txt 放在
cbreader 目錄下的 Index 子目錄就 ok 了.
