@echo off

REM ���R�� log ��
del valid_vol.log

REM �A����U�R��
valid_vol.py -r c:\cbwork\xml-p5\schema\cbeta-p5a.rnc -d c:\cbwork\xml-p5a\T\T01
valid_vol.py -r c:\cbwork\xml-p5\schema\cbeta-p5a.rnc -d c:\cbwork\xml-p5a\T\T02