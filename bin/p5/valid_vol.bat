@echo off

REM 先刪除 log 檔
del valid_vol.log

REM 再執行各刪數
valid_vol.py -r c:\cbwork\xml-p5\schema\cbeta-p5a.rnc -d c:\cbwork\xml-p5a\T\T01
valid_vol.py -r c:\cbwork\xml-p5\schema\cbeta-p5a.rnc -d c:\cbwork\xml-p5a\T\T02