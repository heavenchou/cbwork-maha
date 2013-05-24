c:
cd c:\cbwork\xml\%1
call c:\cbwork\work\bin\normal.bat %2 %3
cd c:\release\normal\%1
call c:\cbwork\work\bin\connect.bat
exit