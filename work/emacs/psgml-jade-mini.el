
;; psgml-jade-mini.el
;; Kevin Russell, June 26, 1997
;;
;; Very rudimentary routines for invoking Jade from Emacs
;; (since I couldn't get Matthias Clasen's psgml-jade to work with 
;; the NTEmacs windowing system)


(defvar sgml-current-dsssl-stylesheet 
  "c:/TEI/Jade/tei-dsl/tei-lite.dsl"
  "Name of the DSSSL style-sheet that Jade will be invoked with.")

(defun sgml-invoke-jade-rtf ()
  (interactive)
  (sgml-invoke-jade "rtf"))

(defun sgml-invoke-jade-tex ()
  (interactive)
  (sgml-invoke-jade "tex"))

(defun sgml-invoke-jade-sgml ()
  (interactive)
  (sgml-invoke-jade "sgml"))

(defun sgml-invoke-jade-xml ()
  (interactive)
  (sgml-invoke-jade "xml"))

(defun sgml-invoke-jade (backend)
  (start-process "Jade process"  ;; internal process name
		 "Jade output"   ;; name of output buffer
		 "jade"          ;; name of DOS command
		 ;;                 arguments to DOS command
		 "-c" (sgml-make-catalog-list sgml-catalog-files)
		 "-t" backend
		 "-d" sgml-current-dsssl-stylesheet
		 buffer-file-name))

(defun sgml-make-catalog-list (file-list)
  (if (> (length file-list) 1)
      (concat (car file-list) ";" (sgml-make-catalog-list (cdr file-list)))
      (car file-list)))

(easy-menu-define sgml-jade-menu sgml-mode-map "Jade menu"
		 '("Jade"
		   ["Output RTF" sgml-invoke-jade-rtf t]
		   ["Output TeX" sgml-invoke-jade-tex t]
		   ["Output SGML" sgml-invoke-jade-sgml t]
		   ["Output XML"  sgml-invoke-jade-xml t]))


;;;; Provide

(provide 'psgml-jade-mini)

