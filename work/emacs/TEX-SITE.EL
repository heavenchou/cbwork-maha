;;; tex-site.el - Site specific variables.

;; Copyright (C) 1991 Kresten Krab Thorup 
;; Copyright (C) 1993, 1994, 1997, 1999 Per Abrahamsen 

;; Author: Per Abrahamsen <abraham@dina.kvl.dk>
;; Maintainer: Per Abrahamsen <auc-tex@sunsite.auc.dk>
;; Version: 9.10p
;; Keywords: wp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; This file contains variables customized for the local site.

;; It also contains all necessary autoloads, so the user can simple
;; enable AUC TeX by putting (load "tex-site") in his .emacs file,
;; or the administrator can insert it in the site-start.el file.
;;
;; The ideal place for this file is in the `site-lisp' directory.

;;; Code:

(when (< emacs-major-version 20)
  (error "AUC TeX requires Emacs 20 or later"))

(defvar no-doc
  "This function is part of AUC TeX, but has not yet been loaded.
Full documentation will be available after autoloading the function."
  "Documentation for autoload functions.")

;;; Customization:
;;
;; Copy variables you need to change from the start of `tex.el' and
;; insert them here.

(defvar TeX-lisp-directory "~/emacs/auctex"
  "*The directory where the AUC TeX lisp files are located.")


;; Change this to point to the place where the TeX macros are stored
      ;; at yourt site.
      (defcustom TeX-macro-global '("c:/bin/texmf/tex/")
      "Directories containing the sites TeX macro files and style files.
      The directory names *must* end with a slash."
      :group 'TeX-file
      :type '(repeat (directory :format "%v")))

      ;; The 'TeX-command-list' (pull-down menu at the top of emacs appearing when 
      ;; emacs is in TeX major mode) consists of the options below.
      ;; Invoking 'C-c C-c' in a TeX major mode will run the "LaTeX" command
      ;; of the command list. (After compiling, errors can be retrieved by
      ;; invoking 'C-c `' (Control-c accent-gr\`ave).
      ;; If no errors occur and if all cross-references are known, a second
      ;; 'C-c C-c' will run the 'View' command of the list.
      (defvar TeX-command-list 
      (list (list "TeX" "tex '\\nonstopmode\\input{%t}'" 'TeX-run-TeX nil t)
      (list "LaTeX" "latex '\\nonstopmode\\input{%t}'" 
      'TeX-run-LaTeX nil t) 
      (list "View DVI" "yap.exe %d" 
      'TeX-run-command nil t) 
      (list "PDFLaTeX" "pdflatex '\\nonstopmode\\input{%t}'" 
      'TeX-run-LaTeX nil t) 
      (list "View PDF" "gsview32.exe %a" 
      'TeX-run-command nil t) 
      (list "dviPS" "dvips %d -o %f" 
      'TeX-run-command nil t) 
      (list "View PostScript" "gsview32.exe %f" 
      'TeX-run-command nil t) 
      (list "BibTeX" "bibtex %s" 'TeX-run-BibTeX nil nil) 
      (list "Index" "makeindex %s" 'TeX-run-command nil t) 
      (list "Check" "lacheck %s" 'TeX-run-compile nil t) 
      (list "Other" "" 'TeX-run-command t t)))

      (setq TeX-default-mode 'LaTeX-mode)
      (setq LaTeX-command-style '(("." "latex --src-specials")))
      (setq TeX-view-style '(("^a5$" "yap %d -paper a5")
      ("^landscape$" "yap %d -paper a4r -s 4")
      ("^epsf$" "gsview32 %f")
      ("." "yap -1 -s%n%b %d")))
      
   


;;; Try to make life easy for MikTeX users.

;(when (memq system-type '(windows-nt))
;  (require 'tex-mik))

;;; Autoloads:

(add-to-list 'load-path TeX-lisp-directory)

;; This hook will store bibitems when you save a BibTeX buffer.
(add-hook 'bibtex-mode-hook 'BibTeX-auto-store)
(autoload 'BibTeX-auto-store "latex" no-doc t)

(autoload 'tex-mode "tex" no-doc t)
(autoload 'plain-tex-mode "tex" no-doc t)
(autoload 'ams-tex-mode "tex" no-doc t)
(autoload 'TeX-auto-generate "tex" no-doc t)
(autoload 'TeX-auto-generate-global "tex" no-doc t)
(autoload 'TeX-insert-quote "tex" no-doc t)
(autoload 'TeX-submit-bug-report "tex" no-doc t)
(autoload 'japanese-plain-tex-mode "tex-jp" no-doc t)
(autoload 'japanese-latex-mode "tex-jp" no-doc t)
(autoload 'japanese-slitex-mode "tex-jp" no-doc t)
(autoload 'texinfo-mode "tex-info" no-doc t)
(autoload 'latex-mode "latex" no-doc t)

(provide 'tex-site)

;;; tex-site.el ends here
