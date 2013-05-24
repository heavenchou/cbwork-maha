c:
cd c:\cbwork\xml\%1
rem .txt
del c:\release\app1\%1\%3.txt
rem .xml
call c:\cbwork\work\bin\app1.bat %2 %3.xml
exit