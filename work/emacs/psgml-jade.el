;	$Id: psgml-jade.el,v 1.1.1.1 2003/05/05 04:07:02 ray Exp $	
;; psgml-jade.el --- add jade, jadetex and customize support to psgml.
;; Copyright (C) 1997, 1998 Matthias Clasen.  Free redistribution permitted.
;; USE AT YOUR OWN RISK!
;;
;; Author: Matthias Clasen (clasen@mathematik.uni-freiburg.de)


;;; Commentary:

;; Thanks:
;;
;; The code is heavily borrowed from AUCTeX 9.5. 
;;
;; Patches to make psgml-jade work on Windows NT are due to 
;; Dr. Markus Hoenicka (Hoenicka@pbmail.me.kp.dlr.de)
;;
;;
;; Installation:
;;
;; This file requires Gnu Emacs or XEmacs, together with Lennart
;; Staflin's PSGML mode (tested with version 1.0.1) and David Megginson's 
;; DSSSL extensions (psgml-dsssl.el). I have tested it with GNU Emacs 19.34
;; and GNU Emacs 20.2.1
;;
;; Install this file somewhere on your load path, byte-compile it, and
;; include the following in your .emacs or site-start.ed file:
;;
;;  (add-hook 'sgml-mode-hook '(lambda () (require 'psgml-jade)))
;;
;; Make the file `customize.dtd' accessible to jade and psgml. This
;; typically means adding a catalog entry for this file.
;;
;; Now, whenever you are editing an SGML document with PSGML, you will
;; see an additional menu with title `DSSSL'. It contains entries 
;;
;;  `Jade'       calls jade with sensible command line parameters
;;  `JadeTeX'    calls jadetex with sensible command line parameters
;;  `View dvi'   calls `xdvi' by default
;;  `Kill Job'   kills a job started with one of the above entries
;;  `Recenter Output Buffer'    displays the output of a job started 
;;               with one of the above entries.
;;  `File Options >'    opens a submenu that allows you to select the 
;;               DSSSL style sheet and the backend to use with jade.
;;  `Make new style sheet'    executes David Megginson's `sgml-dsssl-make-spec'
;;               for this you need the file `psgml-dsssl.el'.
;;  `Edit style sheet'    brings up a buffer with the selected style sheet.
;;  `Customize style sheet'   If the style sheet is following the DTD
;;               `customize.dtd' distributed with this file, this contains
;;               a submenu for changing variable settings in the style sheet.
;;  `Save customizations'     Asks you for the name of a file to save the
;;               customized values to. The generated file is a fully valid
;;               DSSSL style sheet. You may reload your customizations from 
;;               this file by selecting it as style sheet. 
;;
;; The menu entries (except `File Options >') are also reachable by commands:
;; `M-x sgml-command' prompts you for the command to execute. You can use 
;;    completion to select one of the menu entries for the external commands.
;; `M-x sgml-recenter-output-buffer'
;; `M-x sgml-kill-job' 
;; `M-x sgml-dsssl-make-spec'
;; `M-x sgml-dsssl-edit-spec'
;;
;; For details how to add commands to the menu, see the documentation of
;; the variables below. 


;;; Code:

;;;; Variables to be customized.


(defvar sgml-shell "/bin/sh"
  "*Name of the shell to use for external programs. This is probably
`/bin/sh' on Unix systems. I have been told that `cmd' works on
Windows NT.")

(defvar sgml-shell-flag "-c"
  "*This is must be set to the flag used by `sgml-shell' for commands.
`-c' works on Unix systems, `/c' on Windows NT.")

(defvar
  sgml-command-list 
  (list 
; this is how `Validate' could be done here; note that this is better than
; the solution in the `SGML' menu, since it automatically includes the catalogs.
;   (list "Validate" 
;	 "nsgmls -s -m%catalogs %file" 'sgml-run-command t 
;	 '((":\\(.+\\):\\([0-9]+\\):\\([0-9]+\\):[EX]: " 1 2 3)
;	   ("\\(error\\|warning\\) at \\([^,]+\\), line \\([0-9]+\\)" 2 3)
;	   ("\n[a-zA-Z]?:?[^0-9 \n\t:]+:[ \t]*\\([^ \n\t:]+\\):\
;\\([0-9]+\\):\\(\\([0-9]+\\)[: \t]\\)?" 1 2 4)))
   (list "Jade" "jade -c%catalogs -t%backend -d%stylesheet %file" 
	 'sgml-run-command nil
	 '(("jade:\\(.*\\):\\(.*\\):\\(.*\\):E:" 1 2 3)))
   (list "JadeTeX" "jadetex '\\nonstopmode\\input %tex'" 
         'sgml-run-command nil)
   (list "Dvips" "dvips %dvi -o %ps"
	 'sgml-run-command nil)
   (list "View dvi" "xdvi %dvi" 
         'sgml-run-background t)
   (list "View ps" "gv %ps"
         'sgml-run-command nil))
  "*List of commands. 

The first entry is the string appearing in the `DSSSL' menu. 
The second entry is the command to run after expansion with `sgml-command-expand'. 
The third one is the hook used to run the command. A hook should be a function of
four arguments: the name (first entry), the command to run (the expanded second 
entry), the file name and an error regexp (the fifth entry).
The fourth entry is set to t to enforce confirmation in the minibuffer.
The (optional) fifth entry is an error regexp to be used by `compile-internal'.")

(defvar sgml-sgml-file-extension "sgml"
  "*Extension used for the expansion of %sgml in `sgml-command-expand'.")

(defvar sgml-dsssl-file-extension "dsl"
  "*Extension used for the expansion of %dsssl in `sgml-command-expand'
and for the default file name when saving the `**DSSSL**' buffer.")


(defvar sgml-expand-list 
  (list 
   (list "%file" 'file nil)                         ; the current file as is
   (list "%sgml" 'file sgml-sgml-file-extension)    ;   with given extension
   (list "%tex" 'file "tex")                        ;   dito 
   (list "%dvi" 'file "dvi")                        ;   dito
   (list "%ps" 'file "ps")                          ;   dito
   (list "%dsssl" 'file sgml-dsssl-file-extension)  ;   dito
   (list "%dir" 'file nil t)                        ; the directory part  
   (list "%stylesheet" 'sgml-dsssl-spec)            ; the specified style sheet
   (list "%backend" 'sgml-jade-backend)             ; the selected backend
   (list "%catalogs" 'sgml-dsssl-catalogs 'sgml-catalog-files 'sgml-local-catalogs)
        ; the catalogs listed in sgml-catalog-files and sgml-local-catalogs.
   )
  "*List of matched patterns in commands.

The first entry is the placeholder in the command string. 
The second entry is a function which is evaluated to produce a string 
replacing the placeholder.

The function should accept all remaining list entries as arguments plus a 
first argument which is a string holding a possible flag preceding the 
placeholder in the command string or the empty string if there is no flag.

If the replacement is more than one item (like for catalogs), the function 
would normally repeat the flag for each item.")

(defvar sgml-jade-backends 
  '(("TeX" . tex)
    ("RTF" . rtf)
    ("FOT" . fot)
    ("SGML" . sgml)
    ("XML" . xml)
    ("HTML" . html))
  "*List of supported backends for jade. 

Each backend is specified as a cons cell containing a string to appear in the 
`Jade backend' menu and a symbol whose name is used as replacement for %backend."  
)

(defvar sgml-show-compilation nil
  "*If non-nil, show output of compilation in other window.")

;;;; Internal variables.

;; This variable is shared with `compile.el'.
(defvar compilation-in-progress nil 
  "List of compilation processes now running.")

(or (assq 'compilation-in-progress minor-mode-alist)
    (setq minor-mode-alist (cons '(compilation-in-progress " Compiling")
				 minor-mode-alist)))

(defvar sgml-jade-backend 'tex 
  "*Symbol whose name is used as replacement for %backend in `sgml-command-expand'. 

Possible values are given in `sgml-jade-backends'.")
(make-variable-buffer-local 'sgml-jade-backend)
(put 'sgml-jade-backend 'sgml-type sgml-jade-backends)
(put 'sgml-jade-backend 'sgml-desc "Jade backend")

(defvar sgml-dsssl-spec nil 
  "*String used as file name part in the replacement for %stylesheet 
in `sgml-command-expand'.

The value should be a file name or nil.")
(make-variable-buffer-local 'sgml-dsssl-spec)
(put 'sgml-dsssl-spec 'sgml-type 'file-or-nil)
(put 'sgml-dsssl-spec 'sgml-desc "DSSSL style sheet")

(defvar sgml-dsssl-subspec nil
  "*String used as style-specification part in the replacement for
%stylesheet in `sgml-command-expand'.

The value should be the ID of a style-specification in 
`sgml-dsssl-spec' or nil.")
(make-variable-buffer-local 'sgml-dsssl-subspec)
(put 'sgml-dsssl-subspec 'sgml-type 'string-or-nil)
(put 'sgml-dsssl-subspec 'sgml-desc "DSSSL style specification")

(defvar sgml-dsssl-customize-spec nil 
  "*String used as file name when saving customizations.

The value should be a file name or nil.")
(make-variable-buffer-local 'sgml-dsssl-customize-spec)
(put 'sgml-dsssl-customize-spec 'sgml-type 'file-or-nil)
(put 'sgml-dsssl-customize-spec 'sgml-desc "Customizations go to")

(defvar sgml-dsssl-language "DE"
  "*String identifying the language preferred for customization info.")
(put 'sgml-dsssl-language 'sgml-type 'string-or-nil)
(put 'sgml-dsssl-language 'sgml-desc "Language")

(defvar sgml-dsssl-customize nil 
  "*An alist holding customized values of style sheet variables
and characteristics.")
(make-variable-buffer-local 'sgml-dsssl-customize)
(put 'sgml-dsssl-customize 'sgml-type 'list)
(put 'sgml-dsssl-customize 'sgml-desc "Customize value alist")

(defvar sgml-dsssl-customize-info nil 
  "*An alist holding customization info about style sheet variables 
and characteristics.")
(make-variable-buffer-local 'sgml-dsssl-customize-info)
(put 'sgml-dsssl-customize-info 'sgml-type 'list)
(put 'sgml-dsssl-customize-info 'sgml-desc "Customize info alist")

(defvar sgml-dsssl-added-characteristics nil
  "*The name of a customizable style sheet containing a description
of DSSSL characteristics which should be offered for customization.")
(put 'sgml-dsssl-added-characteristics 'sgml-type 'file-or-nil)
(put 'sgml-dsssl-added-characteristics 'sgml-desc "Additional characteristics")

(defconst sgml-dsssl-customize-identifier 
  "<!-- This file has been automatically generated by psgml. -->"
"A string inserted at the beginning of customization files.")

(defconst sgml-dsssl-file-options
  '(
    sgml-jade-backend
    sgml-dsssl-spec
    sgml-dsssl-subspec
    sgml-dsssl-language
    )
  "Options for the current file, can be saved or set from menu."
  )

(defvar sgml-confirm-command-history nil
    "The minibuffer history list for `sgml-command-execute''s COMMAND argument.")

(defvar sgml-read-command-history nil
    "The minibuffer history list for `sgml-read-command-name'.")

;;;; Command expansion   

(defun sgml-jade-backend (flag) 
  "Used in `sgml-command-expand' to produce the replacement text for %backend."
  (concat (when sgml-jade-backend flag) (symbol-name sgml-jade-backend)))

(defun sgml-dsssl-spec (flag) 
  "Used in `sgml-command-expand' to produce the replacement text for %stylesheet.

If the style sheet has customization info, this has the side effect of creating
a temporary style sheet."
  (cond 
   ((null sgml-dsssl-spec) "") ; no style sheet
   ((null sgml-dsssl-customize)  ; a style sheet without customize info
    (concat flag 
	    sgml-dsssl-spec 
	    (when sgml-dsssl-subspec "#") sgml-dsssl-subspec)) ; might have subspec
   (t (let ( (the-spec (make-temp-name (concat "/tmp/" "psgml"))) ) 
	(sgml-dsssl-write-customize the-spec)
	(concat flag the-spec)))))

(defun sgml-dsssl-write-customize (&optional filename)
  (interactive 
   (list (setq sgml-dsssl-customize-spec 
	       (read-from-minibuffer "Filename: " sgml-dsssl-customize-spec))))
  (let ( (the-spec sgml-dsssl-spec)
	 (the-subspec sgml-dsssl-subspec)
	 (the-cust sgml-dsssl-customize) 
	 (the-info sgml-dsssl-customize-info) )
    (when (and the-spec the-cust filename)
      (save-excursion 
	(set-buffer (find-file-noselect filename))
	(erase-buffer)
	(insert sgml-dsssl-customize-identifier "\n")
	(insert "<!doctype style-sheet "
		"PUBLIC \"-//James Clark//DTD DSSSL Style Sheet//EN\" [\n")
	(insert "<!entity base system \"" 
		the-spec 
		"\" cdata dsssl>\n")
	(insert "]>\n")
	(insert "<style-specification use=x>\n")
	(let ( (val nil) 
	       (info nil) )
	  (while the-cust
	    (setq desc (car the-cust))
	    (setq info (cdr (assoc (car desc) the-info))) 
	    (when (cdr desc) ; write out only customized values
	      (cond 
	       ((equal 'characteristic (aref info 4))
		(insert "(declare-initial-value " (car desc) " " (cdr desc) ")\n"))
	       ((equal 'variable (aref info 4))
		(insert "(define " (car desc) " " (cdr desc) ")\n"))))
	    (setq the-cust (cdr the-cust))))
	(insert "</style-specification>\n")
	(insert "<external-specification id=x document=base") 	
	(when the-subspec (insert " specid=" the-subspec))
	(insert ">\n")
	(save-buffer)))))

(defun sgml-dsssl-catalogs (flag &rest lists)
  "Used in `sgml-command-expand' to produce the replacement text for %catalogs."
  (mapconcat 
   (lambda (cats) 
     (mapconcat (lambda (cat) (concat flag cat)) (eval cats) " "))
   lists " ")
)

; should this somehow deal with `sgml-parent-document' ?
(defun sgml-file (&optional extension dir) 
  "If DIR is non-nil, return the directory part of the current file,
else the current file without directory part. Replace the extension 
by EXTENSION, if non-nil."
  (if dir 
      (file-name-directory (buffer-file-name))
    (if extension
	(concat (sgml-strip-extension 
		 (file-name-nondirectory (buffer-file-name))) "." extension)
      (file-name-nondirectory (buffer-file-name))
      )
    )
  )

(defun sgml-command-expand (command file)
  "Expand COMMAND for FILE as described by `sgml-expand-list'."
  (let ( (list sgml-expand-list) )
  (while list
    (let ( (case-fold-search nil)                 ; Do not ignore case.
	   (string (car (car list)))	          ; First element
	   (expansion (car (cdr (car list))))     ; Second element
	   (arguments (cdr (cdr (car list)))) )   ; Remaining elements
      (while (string-match (concat " \\(-.*\\|\\)" string) command)
	(let ( (prefix (substring command 0 (match-beginning 1)))
	       (flag (substring command (match-beginning 1) (match-end 1)))
	       (postfix (substring command (match-end 0))) )
	  (setq command 
		(concat prefix
			(cond ((sgml-function-p expansion)
			       (apply expansion flag arguments))
			      ((boundp expansion)
			       (concat flag (apply (eval expansion) arguments)))
			      (t
			       (error "Nonexpansion %s" expansion)))
			postfix)))))
    (setq list (cdr list)))
  command))

;;;; Hooks for `sgml-command-list'

(defun sgml-run-background (name command file error-regexp)
  "Start process with second argument, show output when and if it arrives."
  (save-excursion
    (set-buffer (get-buffer-create "*SGML background*"))
    (erase-buffer)
  (let ((process (start-process (concat name " background")
				nil sgml-shell sgml-shell-flag command)))
    (process-kill-without-query process))))
  
(defun sgml-run-command (name command file error-regexp)
  "Hook for `sgml-command-list'."
  (let ( (buffer (sgml-process-buffer-name file)) 
	 (fname (file-name-nondirectory file))
	 (dir (file-name-directory file)) )
    (sgml-process-check file)
    (get-buffer-create buffer)
    (set-buffer buffer)
    (erase-buffer)    
    (if dir (cd dir))
    (insert "Running `" name "' on `" file "' with ``" command "''\n")
    (compilation-minor-mode)
    (setq compilation-error-regexp-alist error-regexp)
    (setq compilation-error-message "No more errors")
    (setq mode-name name)	
    (if sgml-show-compilation 
	(display-buffer buffer)
      (message "Type `%s' to display results of compilation." 
	       (substitute-command-keys "\\[sgml-recenter-output-buffer]")))
    (let ((process (start-process name buffer sgml-shell sgml-shell-flag command)))
      (set-marker (process-mark process) (point-max))
      (setq compilation-in-progress (cons process compilation-in-progress))
      process)
    )
  )

(defun sgml-recenter-output-buffer (line)
  "Redisplay buffer of job output so that most recent output can be seen.
The last line of the buffer is displayed on line LINE of the window, or
at bottom if LINE is nil." 
  (interactive "P")
  (let ( (buffer (sgml-process-buffer (sgml-file))) )
    (if buffer
	(let ((old-buffer (current-buffer)))
	  (pop-to-buffer buffer t)
	  (bury-buffer buffer)
	  (goto-char (point-max))
	  (recenter (if line
			(prefix-numeric-value line)
		      (/ (window-height) 2)))
	  (pop-to-buffer old-buffer))
      (message "No process for this document."))))

;;;; Command execution

(defun sgml-command-execute (name file)
  "Run the command NAME from `sgml-command-list' on FILE.

This function relies on NAME being a valid element of `sgml-command-list'
and on FILE being function returning a file name. For interactive calls, 
use `sgml-command'."
  (let* ( (entry (assoc name sgml-command-list))
	  (command (sgml-command-expand (nth 1 entry) file))
	  (hook (nth 2 entry))
	  (confirm (nth 3 entry)) 
	  (error-regexp (nth 4 entry)) )
    (if confirm
	(setq command
	      (read-from-minibuffer (concat name " command: ") command
				    nil nil 'sgml-confirm-command-history)))
    (if sgml-offer-save
	(save-some-buffers nil nil))
    (apply hook name command (apply file nil) error-regexp nil)))

(defun sgml-command (name)
  "Execute command NAME from `sgml-command-list' from a menu or interactively."
  (interactive (list 
		(completing-read "Run command: " sgml-command-list nil t nil
				 'sgml-read-command-history)))
  (setq name (car-safe (sgml-assoc name sgml-command-list)))
  (when name (sgml-command-execute name 'sgml-file))
  )

(defun sgml-kill-job ()
  (interactive)
  (let ( (process (sgml-process (sgml-file))) )
    (if process
	(kill-process process)
      (error "No process to kill"))))

;;;; Process handling 

(defun sgml-process-buffer-name (name)
  (concat "*" (abbreviate-file-name (expand-file-name name)) " output*"))

(defun sgml-process-buffer (name)
  (get-buffer (sgml-process-buffer-name name)))

(defun sgml-process (name)
  (get-buffer-process (sgml-process-buffer name)))

(defun sgml-process-check (name)
  "Check if a process for the document NAME already exists. If so, 
give the user the choice of aborting the process or the current command."
  (let ((process (sgml-process name)))
    (cond ((null process))
	  ((not (eq (process-status process) 'run)))
	  ((yes-or-no-p (concat "Process `"
				(process-name process)
				"' for document `"
				name
				"' running, kill it? "))
	   (delete-process process))
	  (t
	   (error "Cannot have two processes for the same document")))))

;;;; The menu
 
(defun sgml-command-menu-entry (entry)
  "Return `sgml-command-list' entry ENTRY as a menu item."
  (let ( (name (car entry)) )
    (vector name (list 'sgml-command name) t)))

(defun sgml-dsssl-file-options-menu (&optional event)
  "If `sgml-dsssl-spec' is changed, update `sgml-dsssl-customize' and the 
   customize menu."
  (interactive "e")
  (let ( (old-spec sgml-dsssl-spec) 
	 (old-subspec sgml-dsssl-subspec)
	 (old-lang sgml-dsssl-language) ) 
    (sgml-options-menu event sgml-dsssl-file-options)
    (unless (equal old-spec sgml-dsssl-spec)
      (setq sgml-dsssl-subspec nil))
    (unless (and (equal old-spec sgml-dsssl-spec)
		 (equal old-subspec sgml-dsssl-subspec)
		 (equal old-lang sgml-dsssl-language))
      (sgml-dsssl-check-customize))))

(easy-menu-define sgml-command-menu sgml-mode-map "DSSSL menu"
 (append '("DSSSL")
	 (let ( (file 'buffer-file-name) )
	   (mapcar 'sgml-command-menu-entry sgml-command-list))
	 '("--"
	   ["Kill job" sgml-kill-job (sgml-process (sgml-file))]
	   ["Recenter output buffer" sgml-recenter-output-buffer 
	    (sgml-process-buffer (sgml-file))]
           "--"
	   ["File Options >" sgml-dsssl-file-options-menu 't]
	   ["Create new style sheet" sgml-dsssl-new-spec 't]  
	   ["Edit style sheet" sgml-dsssl-edit-spec sgml-dsssl-spec]
	   ["Customize style sheet" t 'nil]
	   ["Save customizations" sgml-dsssl-write-customize sgml-dsssl-customize])))


;;;; Auxiliary functions

; You might want to find David Love's new scheme.el which implements dsssl-mode. 
(if (not (fboundp 'dsssl-mode)) (fset 'dsssl-mode 'scheme-mode))

(defun sgml-function-p (arg)
  "Return non-nil if ARG is callable as a function."
  (or (and (fboundp 'byte-code-function-p)
	   (byte-code-function-p arg))
      (and (listp arg)
	   (eq (car arg) 'lambda))
      (and (symbolp arg)
	   (fboundp arg))))

(defun sgml-member (elt list how)
  "Returns the member ELT in LIST.  Comparison done with HOW.

Return nil if ELT is not a member of LIST."
  (while (and list (not (funcall how elt (car list))))
    (setq list (cdr list)))
  (car-safe list))

(defun sgml-assoc (elem list)
  "Like assoc, except case incentive."
  (let ((case-fold-search t))
    (sgml-member elem list
		(function (lambda (a b)
		  (string-match (concat "^" (regexp-quote a) "$")
				(car b)))))))

(defun sgml-strip-extension (name)
  "Return NAME with final `.*' stripped."
  (string-match "^\\(.*\\)[.][^.]*$" name)
  (substring name (match-beginning 1) (match-end 1))
  )


;;; Integration of psgml-dsssl.el with psgml-jade.el

(defun sgml-dsssl-ask-for-spec ()
  (let ( (dsssl (buffer-file-name)) )
    (save-excursion 
      (set-buffer sgml-current-sgml-buffer)
      (when (and
	     (not (equal sgml-dsssl-spec dsssl))
	     (y-or-n-p "Select style sheet ")
	     (setq sgml-dsssl-spec dsssl)
	     (sgml-dsssl-check-customize))))))

(defun sgml-dsssl-write ()
  (if (equal (buffer-name) "**DSSSL**") 
      (progn 
       (setq buffer-file-name 
	     (expand-file-name (read-file-name 
	     "File to save in: " (file-name-directory buffer-file-name) 
	     buffer-file-name nil (file-name-nondirectory buffer-file-name))))
       (rename-buffer (file-name-nondirectory buffer-file-name))))
  nil)

(defun sgml-dsssl-edit-spec ()
  (interactive)
  (when (or (null sgml-dsssl-customize) 
	    (y-or-n-p "Editing the style sheet will destroy 
your customizations. Continue? "))
    (display-buffer (find-file-noselect sgml-dsssl-spec))
    (setq sgml-current-sgml-buffer (current-buffer))
    (select-window (get-buffer-window (get-file-buffer sgml-dsssl-spec)))
    (dsssl-mode)
    (font-lock-mode)
    (goto-char (point-min))
    (setq buffer-offer-save t)
    (add-hook 'after-save-hook 'sgml-dsssl-check-customize)))

(defun sgml-dsssl-new-spec ()
  (interactive)
  (sgml-dsssl-make-spec)
  (setq sgml-current-sgml-buffer (current-buffer))
  (let* ( (name (sgml-file sgml-dsssl-file-extension))
	  (buffer (get-buffer "**DSSSL**")) )
    (select-window (get-buffer-window buffer))
    (dsssl-mode)
    (font-lock-mode)
    (goto-char (point-min))
    (setq buffer-offer-save t)
    (setq buffer-file-name name)
    (make-local-variable 'after-save-hook)
    (add-hook 'after-save-hook 'sgml-dsssl-ask-for-spec)
    (add-hook 'local-write-file-hooks 'sgml-dsssl-write)))

;;; Customization of style sheets

(defun sgml-dsssl-read-desc (elt) 
  (let ( (sub-elt (sgml-element-content elt))
	 (retval nil) )
    (while sub-elt
      (setq retval (cons (buffer-substring-no-properties 
			  (sgml-element-stag-end sub-elt)
			  (sgml-element-etag-start sub-elt)) retval))
      (setq sub-elt (sgml-element-next sub-elt)))
    (reverse retval))) 

(defun sgml-dsssl-read-var-or-char (elt) 
  (let* ( (sub-elt (sgml-element-content elt))
	  (desc nil)
	  (default-desc (list (sgml-element-attval elt "name")))
	  (values nil) 
	  (types nil) )
    (while sub-elt
      (let ( (elname (symbol-name (sgml-element-name sub-elt))) )
	(cond
	 ((equal "description" elname)
	  (let ( (lang (sgml-element-attval sub-elt "language")) )
	    (cond 
	     ((equal lang sgml-dsssl-language)
	      (setq desc (sgml-dsssl-read-desc sub-elt)))
	     ((null lang)
	      (setq default-desc (sgml-dsssl-read-desc sub-elt))))))
	 ((equal "value" elname)
	  (let ( (value-desc nil)
		 (sub-sub-elt (sgml-element-content sub-elt)) )
	    (while sub-sub-elt
	      (let ( (sub-elname (symbol-name (sgml-element-name sub-sub-elt))) )
		(cond 
		 ((equal "type" sub-elname) 
		  (setq newval (sgml-element-attval sub-sub-elt "class"))
		  (when (null value-desc) 
		    (setq value-desc (list newval "")))
		  (setq types (cons (cons (nth 0 value-desc) (list newval)) types)) 
		  (setq sub-sub-elt nil))
		 ((equal "content" sub-elname) 
		  (setq newval (buffer-substring-no-properties
				(sgml-element-stag-end sub-sub-elt)
				(sgml-element-etag-start sub-sub-elt)))
		  (when (null value-desc)
		    (setq value-desc (list newval "")))
		  (setq values (cons (cons (nth 0 value-desc) newval) values)) 
		  (setq sub-sub-elt nil))
		 ((equal "description" sub-elname) 
		  (let ( (lang (sgml-element-attval sub-sub-elt "language")) )
		    (cond 
		     ((equal lang sgml-dsssl-language)
		      (setq value-desc (sgml-dsssl-read-desc sub-sub-elt)))
		     ((and (null lang) (null value-desc))
		      (setq value-desc (sgml-dsssl-read-desc sub-sub-elt)))))
		  (setq sub-sub-elt (sgml-element-next sub-sub-elt)))
		 ((setq sub-sub-elt (sgml-element-next sub-sub-elt)))))))))
	(setq sub-elt (sgml-element-next sub-elt))))
    (let* ( (is-variable (equal "variable" (symbol-name (sgml-element-name elt))))
	    (name (sgml-element-attval elt "name"))
	    (default (if is-variable 
			 (sgml-element-attval elt "default")
		       (sgml-element-attval elt "initial"))) )
      (when (null desc) (setq desc default-desc))
      (setq types (reverse types))
      (setq values (reverse values))

      ; build up the alists of per-variable information.
      (setq new-cust (cons (cons name default) new-cust))
      (setq new-cust-info 
	    (cons (cons name 
			(vector desc default types values
				(if is-variable 'variable 'characteristic)))
		  new-cust-info))

      (vector (nth 0 desc)  
	      (`(sgml-dsssl-var-menu (quote ,name) 't))
	      't))))

(defun sgml-dsssl-read-section (elt &optional start)
  (let* ( (sub-elt (sgml-element-content elt))
	  (desc nil)
	  (default-desc (list (cond (start) ("???"))))
	  (retval (list nil)) ) 
    (while sub-elt
      (let ( (elname (symbol-name (sgml-element-name sub-elt))) ) 
	(cond
	 ((equal "description" elname)
	  (let ( (lang (sgml-element-attval sub-elt "language")) )
	    (cond
	     ((equal lang sgml-dsssl-language)
	      (setq desc (sgml-dsssl-read-desc sub-elt)))
	     ((null lang)
	      (setq default-desc (sgml-dsssl-read-desc sub-elt))))))
	 ((equal "section" elname)
	  (setq retval (append retval (list (sgml-dsssl-read-section sub-elt)))))
	 ((equal "variable" elname) 
	  (unless (assoc (sgml-element-attval sub-elt "name") new-cust)
	    (setq retval 
		  (append retval (list (sgml-dsssl-read-var-or-char sub-elt))))))
	 ((equal "characteristic" elname)
	  (when (equal "ignored" (sgml-element-attval sub-elt "ignored"))
	    (setq ignored-chars 
		  (cons (sgml-element-attval sub-elt "name") ignored-chars)))
	  (unless (or (member (sgml-element-attval sub-elt "name") ignored-chars) 
		      (assoc (sgml-element-attval sub-elt "name") new-cust)) 
	    (setq retval 
		  (append retval (list (sgml-dsssl-read-var-or-char sub-elt))))))
	 (t (error "Confusion in `read-section'")))
	(setq sub-elt (sgml-element-next sub-elt))))
    (when (null desc) (setq desc default-desc))
    (if (equal (length retval) 1) 
	'() ;  empty section; do not add to menu 
      (cons (nth 0 desc) (cdr retval)))))

(defun sgml-dsssl-check-customize ()
  (interactive)
  (easy-menu-change 
   nil "DSSSL" 
   (append (let ( (file 'buffer-file-name) )
	     (mapcar 'sgml-command-menu-entry sgml-command-list))
	   (list "--"
		 ["Kill job" sgml-kill-job (sgml-process (sgml-file))]
		 ["Recenter output buffer" sgml-recenter-output-buffer 
		  (sgml-process-buffer (sgml-file))]
		 "--"
		 ["File Options >" sgml-dsssl-file-options-menu 't]
		 ["Create new style sheet" sgml-dsssl-new-spec 't]  
		 ["Edit style sheet" sgml-dsssl-edit-spec sgml-dsssl-spec])
	   (list (sgml-dsssl-analyze-spec)
		 ["Save customizations" sgml-dsssl-write-customize 
		  sgml-dsssl-customize])))) 

(defun sgml-dsssl-check-auto-generated ()
  (let* ( (true-spec nil) 
	  (true-subspec nil) )
    (save-excursion 
      (set-buffer (find-file-noselect sgml-dsssl-spec))
      
      ; check for psgml-generated customization file
      (goto-char (point-min))
      (when (and
	     (search-forward-regexp "<!--.*-->" (save-excursion 
						  (goto-line 2) (point)) t) 
	     (equal (buffer-substring-no-properties 
		     (match-beginning 0) (match-end 0))
		    sgml-dsssl-customize-identifier))
          ; (message "Its my baby!")

	  ; find the style sheet which is customized here
	(search-forward-regexp "<!entity base system \"\\(.*\\)\" cdata dsssl>"
			       nil t)
	(setq true-spec (buffer-substring-no-properties 
			 (match-beginning 1) (match-end 1)))
	
	  ; find a possible style-specification
	(when (search-forward-regexp 
	       "<external-specification id=x document=base specid=\\(.*\\)>" 
	       nil t)
	  (setq true-subspec (buffer-substring-no-properties 
			      (match-beginning 1) (match-end 1))))
	  
	  ; find the customized values.
	(goto-char (point-min))
	  ; we match to the end of line, since the value might 
	  ; be an arbitrary DSSSL expression containing parens 
	(while (search-forward-regexp 
		"^[ ]*(declare-initial-value \\([^ ]*\\) \\(.*\\))[ ]*$" nil t)
	  (setq saved-variables
		(cons (cons (buffer-substring-no-properties
			     (match-beginning 1) (match-end 1))
			    (buffer-substring-no-properties
			     (match-beginning 2) (match-end 2))) 
		      saved-variables)))
	  ; find the customized values.
	(goto-char (point-min))
	  ; we match to the end of line, since the value might 
	  ; be an arbitrary DSSSL expression containing parens 
	(while (search-forward-regexp 
		"^[ ]*(define \\([^ ]*\\) \\(.*\\))[ ]*$" nil t)
	  (setq saved-variables
		(cons (cons (buffer-substring-no-properties
			     (match-beginning 1) (match-end 1))
			    (buffer-substring-no-properties
			     (match-beginning 2) (match-end 2))) 
		      saved-variables))))) ; end of excursion
    (when true-spec 
      (setq sgml-dsssl-customize-spec sgml-dsssl-spec)
      (setq sgml-dsssl-spec true-spec) 
      (setq sgml-dsssl-subspec true-subspec))))

; cut string into a list of strings at whitespace
(defun explode-string (s)
  (let ( (i 0) 
	 (retval nil) )
    (while (< i (length s)) 
      (string-match "[ ]*\\([^ ]+\\)[ ]*" s i) 
      (setq retval (cons (substring s (match-beginning 1) (match-end 1)) retval))
      (setq i (match-end 0)))
    (reverse retval)))
  
(defun sgml-dsssl-analyze-spec ()
  "Return menu tree from spec, also setting `sgml-dsssl-customize'."
  ; reset stuff depending on sgml-dsssl-spec.
  (setq sgml-dsssl-customize nil)
  (setq sgml-dsssl-customize-info nil)
  (put 'sgml-dsssl-language 'sgml-type 'string-or-nil)
  (put 'sgml-dsssl-subspec 'sgml-type 'string-or-nil)

  ; analyze sgml-dsssl-spec, rebuilding all dependent stuff.
  (if (null sgml-dsssl-spec)
      ["Customize style sheet" 't 'nil]
    (let ( (new-cust nil) 
	   (new-cust-info nil)
	   (ignored-chars nil)
	   (lang-list (list nil))
	   (id-list (list nil))
	   (use-list nil)
	   (menu-so-far (list "Customize style sheet")) 
	   (local-catalogs sgml-local-catalogs) 
	   (saved-variables nil) )
      (sgml-dsssl-check-auto-generated) 
      (setq use-list (list sgml-dsssl-subspec))

      ; if we had a psgml-generated file, we now switch to the style sheet.
      (save-excursion 
	(set-buffer (find-file-noselect sgml-dsssl-spec))
	
	; treat an non-psgml-generated style sheet
	(sgml-mode)
	(setq sgml-local-catalogs local-catalogs)
	(sgml-need-dtd)
	(sgml-parse-to (point-max))
        
	; find all available style-specifications
	(when (sgml-top-element)
	  (let* ( (style-spec (sgml-element-content (sgml-top-element))) 
		  (id nil) 
		  (i 0) )
	    (while style-spec
            ; might need to check for partial attribute here 
	    (when (equal "style-specification" 
			 (symbol-name (sgml-element-name style-spec)))
	      (setq i (+ 1 i))
	      (setq id (sgml-element-attval style-spec "id"))
	      (when id (setq id-list (append id-list (list id)))))
	    (setq style-spec (sgml-element-next style-spec)))
	    (message (format "%d style-specification(s) found." i)))

	  ; analyze the customize
	  (let* ( (style-spec (sgml-element-content (sgml-top-element)))  
		  (count 0) )
	    (while (and style-spec use-list (< count 1000)) 
	      (when (or (null (car use-list)) ; special case for first spec 
			(equal (sgml-element-attval style-spec "id") 
			       (car use-list))) 

	        ; update use-list
		(setq use-list 
		      (append use-list
			      (explode-string 
			       (sgml-element-attval style-spec "use"))))
		(setq use-list (remove-duplicates (cdr use-list)))
		
		(let ( (cust (sgml-element-content style-spec)) )
                  ; this silently drops external-specification's
		  (when (and cust
			     (equal "customize" 
				    (symbol-name (sgml-element-name cust))))
		  
                    ; append languages
		    (setq lang-list 
			  (append lang-list 
				  (explode-string 
				   (sgml-element-attval cust "languages"))))

                    ; append the customize info
		    (setq menu-so-far 
			  (append menu-so-far (list "---")
				  (cdr (sgml-dsssl-read-section cust)))))))
	      
	      ; continue loop over style-spec
	      (setq count (+ 1 count))
	      (setq style-spec (sgml-element-next style-spec))
	      (when (null style-spec) ; loop from the beginning
		(setq style-spec (sgml-element-content (sgml-top-element))))))))
                ; end of excursion

      (when sgml-dsssl-added-characteristics
	(save-excursion 
	  (set-buffer (find-file-noselect sgml-dsssl-added-characteristics))
	  
	  (sgml-mode)
	  (setq sgml-local-catalogs local-catalogs)
	  (sgml-need-dtd)
	  (sgml-parse-to (point-max))
	  
	  (when (sgml-top-element)
	    (let* ( (cust (sgml-element-content 
			   (sgml-element-content 
			    (sgml-top-element)))) )
	      (when (and cust
			 (equal "customize" 
				(symbol-name (sgml-element-name cust))))
		  
		; append the customize info
		(setq menu-so-far 
		      (append menu-so-far (list "---")
			      (cdr (sgml-dsssl-read-section cust)))))))))

      ; check if we found any customize info
      (when (equal 1 (length menu-so-far)) 
	  (setq menu-so-far [ "Customize style sheet" 't 'nil]))
      
      ; set the buffer-local variables to their new values
      (put 'sgml-dsssl-language 'sgml-type 
	   (or (remove-duplicates (cdr lang-list)) 'string-or-nil))
      (put 'sgml-dsssl-subspec 'sgml-type 
	   (or (remove-duplicates (cdr id-list)) 'string-or-nil))

      ; if we had a psgml-generated file, we use the values from 
      ; there instead of the default ones
      ;(setq sgml-dsssl-customize (or saved-variables new-cust))
      (while saved-variables
	(setcdr (assoc (car (car saved-variables)) new-cust) 
		(cdr (car saved-variables)))
	(setq saved-variables (cdr saved-variables)))
      (setq sgml-dsssl-customize new-cust)
      (setq sgml-dsssl-customize-info new-cust-info)
      menu-so-far)))

(defun sgml-dsssl-var-menu (var event)
 (let* ( (info (cdr (assoc var sgml-dsssl-customize-info)))
	 (desc (aref info 0))
	 (types (copy-alist (aref info 2)))
	 (values (copy-alist (aref info 3))) ) 
   ; treat boolean variables as having two explicit values
   (let ( (bool (rassoc '("boolean") types)) )
     (when bool 
       (setq types (delete bool types))
       (setq values (append (list (cons "#t" "#t") (cons "#f" "#f")) values))))
  
   (let* ( (pair (assoc var sgml-dsssl-customize))
	   (current (cdr pair))
	   (choice nil) )

     ; treat variables with just one type without popup-menu
     (if (and (null values) (equal 1 (length types)))
	 (setq choice (cdr (nth 0 types)))

       ; create a popup-menu 
       (progn
	 ; mark the current value
	 (when current 
	   (let ( (curval (rassoc current values)) )
	     (if curval 
		 (setcar curval (concat (car curval) " *")) 
	       (setq values 
		     (append values 
			     (list (cons (concat current " *") current)))))))
	 (setq choice (sgml-popup-menu event (nth 0 desc) (append values types)))))

     ; now choice is the value we have to analyze
     (cond
      ((stringp choice) 
       (sgml-dsssl-set-variable var choice))
      ((and choice (listp choice))
       (sgml-dsssl-set-variable var nil (car choice))))))) 

(defun sgml-dsssl-set-variable (&optional var val type)
  (interactive)
  (unless var
    (setq var (completing-read "Variable/Characteristic: " 
			       sgml-dsssl-customize nil t)))
  (let ( (pair (assoc var sgml-dsssl-customize)) )
    (unless val
      (let* ( (info (cdr (assoc var sgml-dsssl-customize-info)))
	      (desc (aref info 0))
	      (current (cdr pair))
	      (types (aref info 2))
	      (values (aref info 3)) 
	      (l nil) )
	(when (and (null type)
		   (equal 1 (length types)))
	  (setq type (nth 0 (cdr (nth 0 types)))))
	(with-output-to-temp-buffer "*Help*"
	  (cond
	   (type (princ (concat "Please enter a new value of type " type 
				"\n(or a DSSSL expression of that type) ")))
         ; in this case we know that types is of length > 1.
	   (types (princ "Please enter a new value of type ")
		  (setq l types)
		  (while l 
		    (princ (nth 0 (cdr (car l))))
		    (setq l (cdr l))
		    (when l (princ " or ")))
		  (princ "\n(or a DSSSL expression of one of that types) "))
	   (t (princ "Please choose a new value among ")
	      (setq l values)
	      (while l 
		(princ (cdr (nth 0 l)))
		(setq l (cdr l))
		(when l (princ ", ")))))
	  (if (equal 'variable (aref info 4))  
	      (princ (concat "\nfor the variable `" var "' (" (nth 0 desc) ").\n"))
	    (princ (concat "\nfor the characteristic `" var "' (" 
			   (nth 0 desc) ").\n")))
	  (princ (concat "The current value of `" var "' is " 
			 (or current "unspecified") ".\n\n"))
	  (when (nth 1 desc) (princ (nth 1 desc))))
	(setq val (completing-read "Value: " (unless type values) 
				   nil (null types) current))))
    (setcdr pair val)))

;;; my ideas for additions to psgml-edit.el

(defun sgml-entity-under-point ()
  "Return the entity found whose name is under point or nil. If there is an 
entity, leave point after ERO, else don't move point."
  (sgml-with-parser-syntax  
   (let ( (pnt (point))
	  (entity) )
     (when (or (sgml-parse-delim "ERO")
	       (progn (search-backward-regexp "[&>;]")
		      (sgml-parse-delim "ERO")))
	   (setq pnt (point))
	   (setq sgml-markup-start (- (point) (length "&")))
	   (setq entity (sgml-lookup-entity 
			 (sgml-parse-name t)
			 (sgml-dtd-entities (sgml-pstate-dtd
					     sgml-buffer-parse-state)))))
     
     (goto-char pnt)
     entity
     )
   )
  )

(defun sgml-edit-external-entity ()
  "Open	a new window and display the external entity at the point."
  (interactive)
  (sgml-need-dtd)
  (save-excursion                     
    (sgml-with-parser-syntax  
     (setq sgml-markup-start (point))
     (unless (sgml-parse-delim "ERO")
       (search-backward-regexp "[&>;]")
       (setq sgml-markup-start (point))
       (sgml-check-delim "ERO"))
     (sgml-parse-to-here)		; get an up-to-date parse tree
     (let* ( (parent (buffer-file-name)) ; used to be (sgml-file)
	     (ename (sgml-check-name t))
	     (entity (sgml-lookup-entity ename       
					 (sgml-dtd-entities
					  (sgml-pstate-dtd
					   sgml-buffer-parse-state))))
	     (buffer nil)
	     (ppos nil))
       (unless entity
	 (error "Undefined entity %s" ename))
       (unless (and (eq (sgml-entity-type entity) 'text)               
		    (not (stringp (sgml-entity-text entity))))
	 (error "The entity %s is not an external text entity" ename))

       ;; here I try to construct a useful value for
       ;; `sgml-parent-element'.

       ;; find sensible values for the HAS-SEEN-ELEMENT part
       (let ((seen nil)
	     (child (sgml-tree-content sgml-current-tree)))
	 (while (and child
		     (sgml-tree-etag-epos child)
		     (<= (sgml-tree-end child) (point)))
	   (push (sgml-element-gi child) seen)
	   (setq child (sgml-tree-next child)))
	 (push (nreverse seen) ppos))
       
       ;; find ancestors
       (let ((rover sgml-current-tree))
	 (while (not (eq rover sgml-top-tree))
	   (push (sgml-element-gi rover) ppos)
	   (setq rover (sgml-tree-parent rover))))

       (find-file-other-window
	(sgml-external-file (sgml-entity-text entity)
			    (sgml-entity-type entity)
			    (sgml-entity-name entity)))
       (goto-char (point-min))
       (sgml-mode)
       (setq sgml-parent-document (cons parent ppos))
       ;; update the live element indicator of the new window
       (sgml-parse-to-here)))))

(defun sgml-edit-external-entity-mouse (event)
  (interactive "e")
  (mouse-set-point event)
  (sgml-edit-external-entity)
)

(defun sgml-expand-entity-reference-mouse (event)
  (interactive "e")
  (mouse-set-point event)
  (sgml-expand-entity-reference)
)

(define-key sgml-mode-map [S-mouse-1] 'sgml-edit-external-entity-mouse)
(define-key sgml-mode-map [S-double-mouse-1] 'sgml-expand-entity-reference-mouse)

;;;; Autoload

(autoload 'sgml-dsssl-make-spec "psgml-dsssl" nil t)
(autoload 'sgml-options-menu "psgml-edit" nil t)
(autoload 'sgml-with-parser-syntax "psgml-parse" nil t)

;;;; Provide

(provide 'psgml-jade)

;;; psgml-jade.el ends here

