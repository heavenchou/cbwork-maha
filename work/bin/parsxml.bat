@echo off
c:\bin\w32\sp\bin\nsgmls.exe -w xml -e -s -E20 -ferr.txt c:\bin\w32\sp\pubtext\xml.dcl %1
c:\bin\w32\sp\bin\sed {s/^.*?NSGMLS.EXE://;} err.txt
