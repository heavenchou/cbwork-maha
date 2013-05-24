if "%1"=="" goto end

for /r C:\release\epub_ziped\%1 %%f in (*.epub) do java -jar epubcheck-1.0.5\epubcheck-1.0.5.jar %%f 2>> check_out.txt 1>> check_out_ok.txt

:end