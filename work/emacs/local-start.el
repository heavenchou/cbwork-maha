;;;local-start.el   startup configurations for work in cbeta -*- coding: chinese-big5-dos -*-
;;;================================================================
;;;================================================================
;;file emacs-std.el
;;configuration for GNU-emacs 20.7
;;created 2000-10-06 Christian Wittern
;;last changed: Time-stamp: <2001-04-06 09:23:08 (Tokyo Standard Time) chris>


(setq default-major-mode 'text-mode)
;;(set-default-font "-*-²Ó©úÅé-*-r-*-*-12-90-*-*-c-*-*-*")
;;(set-default-font "-*-MingLiu-*-r-*-*-12-90-*-*-c-*-*-*")
;;Set frame format to a filename:
(setq-default frame-title-format '("%f"))
(setq-default icon-title-format '("%f"))

;;This lets you cycle buffers with C-TAB
(require 'ibs)

;;This saves stuff between sessions
(require 'session)

(add-hook 'after-init-hook 'session-initialize)

;; this is only for windoze
;; Maximize emacs window
(defun minimize-frame ()
  (interactive)
  (w32-send-sys-command ?\xf020))

(defun maximize-frame ()
  (interactive)
  (w32-send-sys-command ?\xf030))

(defun restore-frame ()
  (interactive)
  (w32-send-sys-command ?\xf120))
(maximize-frame)

(setq compilation-window-height 10)

;;

;;

;;(setq initial-frame-alist '((top -50) (left  -50 )(width . 92) (height . 33)))


;; maximize command
;;(w32-send-sys-command 61488)

;; Add text mode hooks"
;; (including all modes based on it, e.g., indented-text-mode and mail-mode).
;;
;;  enable auto-fill
 (add-hook 'text-mode-hook 'turn-on-auto-fill)

;;(add-hook 'text-mode-hook 'turn-on-filladapt-mode)



(require 'sams-lib)
(sams-gnus-filling)
(autoload 'perl-mode "cperl-mode" "alternate mode for editing Perl programs" t)

;(autoload 'dl-mode "dui" "Edict dictionary" t)


;; hightling of the marked sections
(if sams-Gnu-Emacs-p
  (transient-mark-mode t)
)

(setq line-number-display-limit 100000)
(setq line-number-mode t)
(setq column-number-mode t)
(setq next-line-add-newlines nil)

;; timestamp

(add-hook 'write-file-hooks 'time-stamp)
;(setq time-stamp-line-limit 8)

;; customize file
(setq custom-file "~/emacs/config/customize.el")
(load custom-file)


;; CUA = Common User Interface, e.g. C-x, C-c etc.
(if sams-Gnu-Emacs-p 
 (progn
  (load "cua-mode")
  (CUA-mode t)
  (setq CUA-mode-normal-cursor-color "black")
  (setq CUA-mode-overwrite-cursor-color "yellow")
  (setq CUA-mode-read-only-cursor-color "green")
))


(if (win32-p)
;; load gnuserv cw 3.10.2000
  (progn
  (require 'gnuserv)
  (gnuserv-start)
))

(setq gnuserv-frame (selected-frame))


;; load jka-compr cw 3.10.2000
(require 'jka-compr)


;; Turn on syntax coloring
(cond ((fboundp 'global-font-lock-mode)
			 ;; Turn on font-lock in all modes that support it
			 (global-font-lock-mode t)
			 ;; maximum colors
			 (setq font-lock-maximum-decoration t)))

(setq w32-use-w32-font-dialog t)

(setq tab-width 2)

(autoload 'all "all" nil t)
(autoload 'igrep "igrep" nil t)
(autoload 'ibuffer "ibuffer" nil t)

  


(defun insert-date-time()
  (interactive)
  (insert (format-time-string "[%Y-%m-%dT%T%z]" (current-time))))


;; dired stuff to open files a la Windows from Howard Melman
(defun dired-execute-file (&optional arg)
  (interactive "P")
  (mapcar #'(lambda (file)
      (w32-shell-execute "open" (convert-standard-filename file)))
          (dired-get-marked-files nil arg)))

(defun dired-mouse-execute-file (event)
  "In dired, execute the file or goto directory name you click on."
  (interactive "e")
  (set-buffer (window-buffer (posn-window (event-end event))))
  (goto-char (posn-point (event-end event)))
  (if (file-directory-p (dired-get-filename))
      (dired-find-file)
    (dired-execute-file)))
(global-set-key [?\C-x mouse-2] 'dired-mouse-execute-file)

(defun hrm-dired-mode-hook ()
  "Hook run when entering dired-mode."
    (define-key dired-mode-map "X" 'dired-execute-file)
    (define-key dired-mode-map [M-down-mouse-1] 'dired-mouse-mark-file))

(add-hook 'dired-mode-hook 'hrm-dired-mode-hook)


;; swap mouse-2 and mouse-3
(setq w32-swap-mouse-buttons t) 
(global-unset-key (kbd "<mouse-2>"))

;;;================================================================
;;;================================================================
;;;last changed: Time-stamp: <2001-02-19 11:53:07 chris>
;; file modes.el
;; Configuration file for emacs modes
;; Created 2000-10-06
;; The following modes are covered:
;; html-mode
;; sgml-mode
;; xml-mode
;; dtd-mode
;; xsl-mode




;; Add the psgml directory to the path Emacs searches for Lisp code
;;
(setq load-path (cons (concat my-site-lisp-path "/psgml") load-path))

;; html-mode 

;; from cw 2000-10-03

;; define html mode


;; ugly:  .html files as XHTML; .htm files as HTML
(or (assoc "\\.html$" auto-mode-alist)
(setq auto-mode-alist (cons '("\\.html$" . xml-mode)
auto-mode-alist)))
(or (assoc "\\.xhtml$" auto-mode-alist)
(setq auto-mode-alist (cons '("\\.xhtml$" . xml-mode)
auto-mode-alist)))
(or (assoc "\\.htm$" auto-mode-alist)
(setq auto-mode-alist (cons '("\\.htm$" . sgml-html-mode)
auto-mode-alist)))

(defun sgml-html-mode ()
"This version of html mode is just a wrapper around sgml mode."
(interactive)
(sgml-mode)
(make-local-variable 'sgml-declaration)
(make-local-variable 'sgml-default-doctype-name)
(setq
sgml-default-doctype-name    "html"
sgml-declaration             (concat my-setup-path-prefix "/sgml/dtd/html/html4.dcl")
sgml-always-quote-attributes t
sgml-indent-step             2
sgml-indent-data             t
sgml-minimize-attributes     t
sgml-omittag                 t
sgml-shorttag                t
)
)

(setq-default sgml-indent-data t)
(setq
sgml-always-quote-attributes   t
sgml-auto-insert-required-elements t
sgml-auto-activate-dtd         t
sgml-indent-data               t
sgml-indent-step               2
sgml-minimize-attributes       t
sgml-omittag                   nil
sgml-shorttag                  nil
)
      
;; end of html-mode cw 3.10.2000



(autoload 'sgml-mode "psgml" "Major mode to edit SGML files." t)

;; Automatically start PSGML mode on files with extension .tei
;;

(setq auto-mode-alist (cons '("\.tei$" . sgml-mode) auto-mode-alist))


;; Variable definitions for psgml-jade
;;
(setq sgml-sgml-file-extension "tei")
;; (setq sgml-dsssl-spec "c:/TEI/Jade/tei-dsl/tei-lite.dsl")


(autoload 'sgml-dsssl-make-spec "psgml-dsssl" nil t)
      

;; Name of the file used to translate entities <--> display characters
;;
(setq sgml-display-char-list-filename (concat my-setup-path-prefix "/sgml/ent/iso88591.map"))

;; Automatically activate the dtd when a file is loaded.
;; This immediately colours the tags, for example.
;;

(setq sgml-auto-activate-dtd t)

;; CW, 13.2.2001
;; This controls insertion of defaulted elements and attributs (new in 1.2.2)

(setq sgml-insert-defaulted-attributes t)
 

;; Tag colouring definitions
;; stolen from David Meggison (very slightly modified)
;;
(setq-default sgml-set-face t)
  (make-face 'sgml-comment-face)
  (make-face 'sgml-doctype-face)
  (make-face 'sgml-tag-face)
  (make-face 'sgml-entity-face)
  (make-face 'sgml-ignored-face)
  (make-face 'sgml-ms-end-face)
  (make-face 'sgml-ms-start-face)
  (make-face 'sgml-pi-face)
  (make-face 'sgml-sgml-face)
  (make-face 'sgml-short-ref-face)

  (set-face-foreground 'sgml-comment-face "dark green")
  (set-face-foreground 'sgml-doctype-face "lime green")
  (set-face-foreground 'sgml-tag-face "red")
  (set-face-foreground 'sgml-entity-face "midnight blue")
  (set-face-foreground 'sgml-ignored-face "maroon")
  (set-face-background 'sgml-ignored-face "gray90")
  (set-face-foreground 'sgml-ms-end-face "maroon")
  (set-face-foreground 'sgml-ms-start-face "maroon")
  (set-face-foreground 'sgml-pi-face "maroon")
  (set-face-foreground 'sgml-sgml-face "maroon")
  (set-face-foreground 'sgml-short-ref-face "goldenrod")

  (setq-default sgml-markup-faces
   '((comment . sgml-comment-face)
     (doctype . sgml-doctype-face)
     (end-tag . sgml-tag-face)
     (entity . sgml-entity-face)
     (ignored . sgml-ignored-face)
     (ms-end . sgml-ms-end-face)
     (ms-start . sgml-ms-start-face)
     (pi . sgml-pi-face)
     (sgml . sgml-sgml-face)
     (short-ref . sgml-short-ref-face)
     (start-tag . sgml-tag-face)))

;; end of D. Megginsons colours


;; This is for XML mode. Thanks to Karl Eichwaelder at comp.text.xml cw 4.10.2000

(add-to-list 'auto-mode-alist '("\\.xml\\'" . xml-mode))
(autoload 'xml-mode "psgml" nil t)
 (setq sgml-xml-declaration (concat my-setup-path-prefix "/xml/xml.dcl")
  sgml-shorttag t)
(or (assoc "\\.xtm$" auto-mode-alist)
(setq auto-mode-alist (cons '("\\.xtm$" . xml-mode)
auto-mode-alist)))

;; end of XML mode defs. cw 4.10.2000


;;autoload xpointer
(autoload 'sgml-xpointer "psgml-xpointer" nil t)
;;


;; load psgml-jade extension
(setq
  sgml-command-list 
  (list 
   (list "TEI XSL" (concat (getenv "PFILES") "/bin/xt %file " (getenv "HOME") "/xsl/mytei.xsl")  
     'sgml-run-command t
     )
   (list "Slides from TEI" "doslides.bat %file"     'sgml-run-command t
     )
;    (list "Jade" "/pfiles/bin/openjade -c%catalogs -t%backend -d%stylesheet %file" 
;      'sgml-run-command t
;      '(("jade:\\(.*\\):\\(.*\\):\\(.*\\):E:" 1 2 3)))
;    (list "JadeTeX" "jadetex %tex" 
;      'sgml-run-command nil)
;    (list "JadeTeX PDF" "pdfjadetex %tex"
;      'sgml-run-command t)
;    (list "dvips" "dvips -o %ps %dvi"
;      'sgml-run-command nil)
;    (list "View dvi" "yap %dvi" 
;      'sgml-run-background t)
;    (list "View PDF" "gsview32 %pdf" 
;      'sgml-run-command nil)
;    (list "View ps" "gsview32 %ps"
;      'sgml-run-command nil)
)
)

(setq sgml-sgml-file-extension "sgml")

(setq sgml-dsssl-file-extension "dsl")

(setq sgml-expand-list 
  (list 
   (list "%file" 'file nil)     ; the current file as is
   (list "%sgml" 'file sgml-sgml-file-extension) ;   with given extension
   (list "%htm" 'file "")        ;   dito 
   (list "%tex" 'file "tex")        ;   dito 
   (list "%dvi" 'file "dvi")        ;   dito
   (list "%pdf" 'file "pdf")        ;   dito
   (list "%ps" 'file "ps")      ;   dito
   (list "%dsssl" 'file sgml-dsssl-file-extension) ;   dito
   (list "%dir" 'file nil t)        ; the directory part  
   (list "%stylesheet" 'sgml-dsssl-spec) ; the specified style sheet
   (list "%backend" 'sgml-jade-backend) ; the selected backend
   (list "%catalogs" 'sgml-dsssl-catalogs 'sgml-catalog-files 'sgml-local-catalogs)
                    ; the catalogs listed in sgml-catalog-files and sgml-local-catalogs.
   )
)

;(setq sgml-shell "sh")
(setq sgml-shell-flag "/c")

(setq sgml-shell (concat my-setup-path-prefix "/emacs207/bin/cmdproxy.exe"))

(add-hook 'sgml-mode-hook '(lambda ()
														 (require 'psgml-jade)
														 (define-key sgml-mode-map
                              "\C-c\C-b"
                              'sgml-xpointer)
))


   
;; load dsssl support
(autoload 'sgml-dsssl-make-spec "psgml-dsssl" nil t)

      ;; add TeX-support
      (load "tex-site")
      (custom-set-variables
      '(TeX-expand-list (quote (("%p" TeX-printer-query)
      ("%q" (lambda nil (TeX-printer-query TeX-queue-command 2)))
      ("%v" TeX-style-check (("^a5$" "yap %d -paper a5")
      ("^landscape$" "yap %d -paper a4r -s 4") ("." "yap %d")))
      ("%l" TeX-style-check (("." "latex"))) ("%s" file nil t) ("%t" file t t)
      ("%n" TeX-current-line) ("%d" file "dvi" t) ("%f" file "ps" t)
      ("%a" file "pdf" t)))))
      

;;sgml-custom-dtd  
;; PSGML menus for creating new documents
(setq sgml-custom-dtd
'(
  ( "TEILite XML"
    "<?xml version =\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE TEI.2 PUBLIC \"-//TEI//DTD TEI Lite XML ver. 1.1//EN\" 
    \"/pfiles/xml/dtd/tei/teixlite.dtd\">")
  ( "XTM TopicMaps"
    "<?xml version =\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE topicMap PUBLIC \"-//TopicMaps.Org//DTD XML Topic Map (XTM) 1.0//EN-\" 
    \"/pfiles/xml/dtd/xtm/xtm1.dtd\">")
  ( "XHTML"
    "<?xml version =\"1.0\" encoding=\"utf-8\"?><!-- -*- mode: xml -*- -->\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"/pfiles/xml/dtd/xhtml/xhtml1-strict.dtd\">")
  ( "XHTML Frameset"
    "<?xml version =\"1.0\" encoding=\"utf-8\"?><!-- -*- mode: xml -*- -->\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\" \"/pfiles/xml/dtd/xhtml/xhtml1-frameset.dtd\">")
  ( "XHTML Transitional"
    "<?xml version =\"1.0\" encoding=\"utf-8\"?><!-- -*- mode: xml -*- -->\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"/pfiles/xml/dtd/xhtml/xhtml1-transitional.dtd\">")
  ( "HTML 4"
    "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"/pfiles/sgml/dtd/html/html4-s.dtd\">")
  ( "HTML 4 Frameset"
    "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Frameset//EN\" \"/pfiles/sgml/dtd/html/html4-f.dtd\">")
  ( "HTML 4 Transitional"
    "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"/pfiles/sgml/dtd/html/html4.dtd\">")
  ("DocBook 4.1"
   "<!DOCTYPE Book PUBLIC \"-//OASIS//DTD DocBook V4.1//EN\" \"/pfiles/xml/dtd/docbk412/docbookx.dtd\">")
  )
)

      
;; ecat support
;; Filename for the "electronic catalogue" -- the list of .ced files for
;; storing parsed DTDs for each formal public identifier
;;
;;(setq sgml-ecat-files '(""))
(setq sgml-ecat-files
  (list
    (concat my-setup-path-prefix  "/sgml/ecat")
    (concat my-setup-path-prefix "/xml/ecat")
;    (expand-file-name "c:/pfiles/xml/dtd/docbk41/ecatalog")
))
            

;; DTD mode installed cw 3.10.2000
(autoload 'dtd-mode "tdtd" "Major mode for SGML and XML DTDs." t)
(autoload 'dtd-etags "tdtd"
  "Execute etags on FILESPEC and match on DTD-specific regular expressions."
  t)
(autoload 'dtd-grep "tdtd" "Grep for PATTERN in files matching FILESPEC." t)

;; Turn on font lock when in DTD mode
(add-hook 'dtd-mode-hooks
	  'turn-on-font-lock)

(setq auto-mode-alist
      (append
       (list
	'("\\.dcl\\'" . dtd-mode)
	'("\\.dec\\'" . dtd-mode)
	'("\\.dtd\\'" . dtd-mode)
	'("\\.ele\\'" . dtd-mode)
	'("\\.ent\\'" . dtd-mode)
	'("\\.mod\\'" . dtd-mode))
       auto-mode-alist))


;; end of init-code for tdtd-mode cw 3.10.2000
;; To use resize-minibuffer-mode, uncomment this and include in your .emacs:
;;(resize-minibuffer-mode)



;; XSL mode
(autoload 'xsl-mode "xslide" "Major mode for XSL stylesheets." t)

;; Turn on font lock when in XSL mode
(add-hook 'xsl-mode-hook
	  'turn-on-font-lock)

(setq auto-mode-alist
      (append
       (list
	'("\\.xsl\\'" . xsl-mode))
       auto-mode-alist))


;;;================================================================
;;;================================================================
;;; emacs-18.el
;;Configuration file for various aspects of internationalization:
;;selecting fonts, input methods, encodings etc.
;;created 2000-10-06
;; for using bdf-fonts, cw 28.9.2000
;;last changed: Time-stamp: <2001-02-17 11:52:57 chris>



;; The following three lines are for BIG5 environment remove the comment marks in the first line to activate
(set-language-environment "Chinese-BIG5")
;(setup-chinese-big5-environment)
(set-keyboard-coding-system 'chinese-big5-dos) ; windows IME
(set-selection-coding-system 'chinese-big5-dos) ; Copy/Paste

;; no font dialog
(setq w32-use-w32-font-dialog nil)


(create-fontset-from-fontset-spec
 "-*-Courier New-normal-r-*-*-15-*-*-*-c-*-fontset-most,
 latin-iso8859-2:-*-Courier New-normal-r-*-*-15-*-*-*-c-*-iso8859-2,
 latin-iso8859-3:-*-Courier New-normal-r-*-*-15-*-*-*-c-*-iso8859-3,
 latin-iso8859-4:-*-Courier New-normal-r-*-*-15-*-*-*-c-*-iso8859-4,
 cyrillic-iso8859-5:-*-Courier New-normal-r-*-*-15-*-*-*-c-*-iso8859-5,
 greek-iso8859-7:-*-Courier New-normal-r-*-*-15-*-*-*-c-*-iso8859-7,
 latin-iso8859-9:-*-Courier New-normal-r-*-*-15-*-*-*-c-*-iso8859-9,
 japanese-jisx0208:-*-MS Gothic-normal-r-*-*-15-*-*-*-c-*-jisx0208-sjis,
 katakana-jisx0201:-*-MS Gothic-normal-r-*-*-15-*-*-*-c-*-jisx0208-sjis,
 latin-jisx0201:-*-MS Gothic-normal-r-*-*-15-*-*-*-c-*-jisx0208-sjis,
 japanese-jisx0208-1978:-*-MS Gothic-normal-r-*-*-15-*-*-*-c-*-jisx0208-sjis,
 japanese-jisx0212:-*-MS Gothic-normal-r-*-*-15-*-*-*-c-*-jisx0212-sjis,
 korean-ksc5601:-*-Gungsuh-normal-r-*-*-15-*-*-*-c-*-ksc5601-*,
 chinese-gb2312:-*-NSimSun-normal-r-*-*-15-*-*-*-c-*-gb2312-*,
 chinese-big5-1:-*-MingLiU-normal-r-*-*-15-*-*-*-c-*-big5-*,
 chinese-big5-2:-*-MingLiU-normal-r-*-*-15-*-*-*-c-*-big5-*" t)


(set-default-font "fontset-most")


;; the unicode files are in /site-lisp/ucs

(setq load-path (cons (concat my-site-lisp-path "/Mule-UCS/lisp") load-path))

(require 'un-define)
(require 'oc-tools)

(setq unicode-data-path "~/uni/UnicodeData-Latest.txt")




;;;================================================================
;;;================================================================
;; Example function definition to be called by the redefined F5 key
;;
;;last changed: Time-stamp: <2001-02-17 13:00:45 chris>



;; redefining keys

;; Redefine [home] and [end] to act like usual on PCs
;;

(global-set-key [end] 'end-of-line)
(global-set-key [home] 'beginning-of-line)
(global-set-key "\C-home" 'beginning-of-buffer)
;;(global-set-key "\C-end" 'end-of-buffer)

;; Redefine a few function keys
;;

(global-set-key [f2] 'delete-other-windows)
(global-set-key [(f4)] 'tags-search)

(global-set-key [(f6)] 'undo)
(global-set-key [(shift f6)] 'redo)

;----------------------------------------------------------------------
;                                    F8
;----------------------------------------------------------------------
(global-set-key [(f8)] 'bookmark-jump)
(global-set-key [(shift f8)] 'bookmark-set)
(global-set-key [(control f8)] 'list-bookmarks)



(global-set-key [f9] 'sgml-insert-end-tag)

;; To access the menus by pressing alt
(setq w32-pass-alt-to-system t)   

(global-set-key [\C-\M-left] 'backward-sexp)
(global-set-key [\C-\M-right] 'forward-sexp)

(global-set-key '[(meta g)] 'goto-line)


;; Unicode keymapping
(global-set-key "\C-c?" 'unicode-what)
(global-set-key "\C-ci" 'insert-ucs-character)


;; key-bindings for changing the selection encoding

(global-set-key "\C-cb" (sams-definteractive (set-selection-coding-system 'chinese-big5-dos))) ; Copy/Paste
(global-set-key "\C-cj" (sams-definteractive (set-selection-coding-system 'japanese-shift-jis-dos))) ; Copy/Paste
(global-set-key "\C-cu" (sams-definteractive (set-selection-coding-system 'utf-8-dos))) ; Copy/Paste

;; key-bindings for changing the input encoding
(global-set-key "\C-cB" (sams-definteractive (set-keyboard-coding-system 'chinese-big5-dos))) ; windows IME

(global-set-key "\C-cJ" (sams-definteractive (set-keyboard-coding-system 'japanese-shift-jis))) ; windows IME

(global-set-key "\C-ct" 'insert-date-time)

;;redefine the set-mark from "C-SPC": this activates the Windows IME
;;[2001-02-23T10:43:22+0800]
(global-set-key "\M- " 'set-mark-command) 

(setq initial-frame-alist '((top -50) (left  -50 )(width . 82) (height . 31)))



;; local-start.el ends here


