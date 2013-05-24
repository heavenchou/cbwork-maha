;; customize.el

(custom-set-variables
 '(TeX-expand-list (quote (("%p" TeX-printer-query) ("%q" (lambda nil (TeX-printer-query TeX-queue-command 2))) ("%v" TeX-style-check (("^a5$" "yap %d -paper a5") ("^landscape$" "yap %d -paper a4r -s 4") ("." "yap %d"))) ("%l" TeX-style-check (("." "latex"))) ("%s" file nil t) ("%t" file t t) ("%n" TeX-current-line) ("%d" file "dvi" t) ("%f" file "ps" t) ("%a" file "pdf" t))))
 '(mail-default-reply-to "chris@ccbs.ntu.edu.tw" t)
 '(tab-width 2)
 '(blink-matching-paren t)
 '(speedbar-supported-extension-expressions (quote ("\\.vhdl?\\'" ".[ch]\\(\\+\\+\\|pp\\|c\\|h\\|xx\\)?" ".tex\\(i\\(nfo\\)?\\)?" ".el" ".emacs" ".l" ".lsp" ".p" ".java" ".f\\(90\\|77\\|or\\)?" ".ada" ".pl" ".tcl" ".m" ".scm" ".pm" ".py" ".s?html?" ".bat" "Makefile\\(\\.in\\)?" ".\\(sg\\|x\\)ml" ".txt" ".dtd"))))
(custom-set-faces)
