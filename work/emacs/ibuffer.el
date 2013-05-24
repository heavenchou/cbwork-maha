;;; ibuffer.el --- operate on buffers like dired

;; Copyright (C) 2000 Free Software Foundation, Inc.

;; Emacs Lisp Archive Entry
;; Author: Colin Walters <walters@cis.ohio-state.edu>
;; Created: 8 Sep 2000
;; Version: 1.2
;; URL: http://www.cis.ohio-state.edu/~walters
;; Keywords: buffer, convenience

;; This file is not currently part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; ibuffer.el is an advanced replacement for the `buffer-menu' which
;; is normally distributed with Emacs.  Just type 'M-x ibuffer' to get
;; started, and 'h' after that for more information.

;;; Change Log:

;; Changes from 1.1 to 1.2:
;;  * Add ability to limit by content (not as slow as you might
;;    think).
;;  * New operations: 'A' to view all of the marked buffers in the
;;    selected frame, and 'H' to view them each in a separate frame.
;;  * Many compatibility keybindings with `buffer-menu' added.
;;  * Add %w format specifier to display narrowing state.
;;  * Add %p format specifier to display buffer process status
;;  * Add %{ %} format modifiers for making text bold
;;  * Add buffer process status to the default display
;;  * New function: ibuffer-diff-with-file, bound to = by default
;;  * Allow using 'd' to mark buffers explicitly for deletion, and
;;    'x' to delete them.  This is orthogonal to the regular marks.
;;  * More documentation.
;;  * Default limiting keybinding changed from # to / (thanks Kai
;;    Großjohann)
;;  * Allow using 0-9 for digit prefix arguments
;;  * New function `ibuffer-other-window', to begin viewing an ibuffer
;;    in another window.
;;  * Move point to the beginning of the buffer when updating (thanks
;;    Kai Großjohann)
;;  * Bury the ibuffer when switching to another buffer (thanks Kai
;;    Großjohann)
;;  * Byte compile the format specifier when entering ibuffer-mode.

;; Changes from 1.0 to 1.1:
;;  * Addition of of "limiting".  You can view only buffers that match
;;    a certain predicate.
;;  * mouse-1 now toggles the highlighting state of a buffer.
;;  * mouse-3 now pops up a menu of operations
;;  * Switch to the buffer being saved if we're prompted for a
;;    filename.
;;  * Do an update every time after 'M-x ibuffer'.
;;  * Keep mark information even when doing an update (g)
;;  * Allow customization of status characters
;;  * Remove killed buffers during mapping (prevents weird errors)
;;  * Start from the beginning of the buffer during a query-replace
;;  * Downcase major mode name during major-mode sorting to prevent
;;    e.g. Man-mode from being first.
;;  * Hide the 'Edit' menu.
;;  * Fix highlighting bug when name is at the beginning
;;  * Don't change point while doing a query replace.

;;; Bugs:

;; - mouse stuff doesn't work on XEmacs.  Patches accepted.
;; - The cursor moves up a line when toggling the marks.

;;; Code:

(require 'easymenu)

;; currently really only used by the Gnus functions.
(eval-when-compile
  (require 'cl))

;; XEmacs compatibility stuff
(if (fboundp 'line-beginning-position)
    (defalias 'ibuffer-line-beginning-position 'line-beginning-position)
  (defun ibuffer-line-beginning-position ()
    (save-excursion
      (beginning-of-line)
      (point))))

(if (fboundp 'line-end-position)
    (defalias 'ibuffer-line-end-position 'line-end-position)
  (defun ibuffer-line-end-position ()
    (save-excursion
      (end-of-line)
      (point))))

(defgroup ibuffer nil
  "An advanced replacement for `buffer-menu'.

Ibuffer allows you to operate on buffers in a manner much like Dired.
Operations include sorting, marking by regular expression, and
selectable views."
  :group 'convenience)

(defcustom ibuffer-default-sorting-mode 'recency
  "The criteria by which to sort the buffers.

Note that this variable is local to each ibuffer buffer.  Thus, you
can have multiple ibuffer buffers open, each with a different sorted
view of the buffers."
  :type '(choice (const :tag "Last view time" recency)
		 (const :tag "Lexicographic" alphabetic)
		 (const :tag "Buffer size" size)
		 (const :tag "Major mode" major-mode))
  :group 'ibuffer)
(defvar ibuffer-sorting-mode nil)

(defcustom ibuffer-default-sorting-reversep nil
  "If non-`nil', reverse the default sorting order."
  :type 'boolean
  :group 'ibuffer)
(defvar ibuffer-sorting-reversep nil)

(defcustom ibuffer-line-format "%o%m%r %(%-16,999n%) %s  %-13,999M %{%p%} %f"
  "An extended `format' string describing how to display the buffer.

Control parameters:
%o is a single character, representing the current mark.
   See `ibuffer-marked-char'.
%m is a single character, representing the modification state.
   See `ibuffer-modified-char'.
%r is a single character, representing the writability of the buffer.
   See `ibuffer-read-only-char'.
%n is a string, the name of the buffer.
%s is a number, the size of the buffer.
%M is a string, the name of the major mode of the buffer.
%f is a string, the name of the associated file of the buffer, \"\" otherwise.
%w is a string, \"narrow\" if the buffer is narrowed, \"\" otherwise.
%p is a string like \"(process-name process-status)\" if the buffer has
   an associated process, \"\" otherwise."
  :type 'string
  :group 'ibuffer)

(defcustom ibuffer-modified-char ?*
  "The character to display for modified buffers (%m)."
  :type 'character
  :group 'ibuffer)

(defcustom ibuffer-read-only-char ?%
  "The character to display for read-only buffers (%r)."
  :type 'character
  :group 'ibuffer)

(defcustom ibuffer-marked-char ?>
  "The character to display for marked buffers (%o)."
  :type 'character
  :group 'ibuffer)

(defcustom ibuffer-deletion-char ?D
  "The character to display for buffers marked for deletion (%d)."
  :type 'character
  :group 'ibuffer)

(defcustom ibuffer-expert nil
  "If non-`nil', don't ask for confirmation of \"dangerous\" operations."
  :type 'boolean
  :group 'ibuffer)

(defcustom ibuffer-old-time 3
  "The number of days before a buffer is considered \"old\"."
  :type 'integer
  :group 'ibuffer)

(defcustom ibuffer-view-ibuffer nil
  "If non-`nil', display the current ibuffer buffer itself."
  :type 'boolean
  :group 'ibuffer)

(defcustom ibuffer-special-modeline t
  "If non-`nil', display a customized Ibuffer modeline."
  :type 'boolean
  :group 'ibuffer)

(defcustom ibuffer-hooks nil
  "Hooks run when `ibuffer' is called."
  :type 'hook
  :group 'ibuffer)

(defcustom ibuffer-mode-hooks nil
  "Hooks run upon entry into `ibuffer-mode'."
  :type 'hook
  :group 'ibuffer)

(defface ibuffer-marked-face '((t (:foreground "green")))
  "Face used for displaying marked buffers."
  :group 'ibuffer)

(defface ibuffer-deletion-face '((t (:foreground "red")))
  "Face used for displaying buffers marked for deletion."
  :group 'ibuffer)

(defvar ibuffer-line-format-form nil
  "A cached version of the form to `funcall' to display the buffer line.
Set this to `nil' to force `ibuffer-line-format' to be re-parsed.")

(defvar ibuffer-mode-map nil)
(unless ibuffer-mode-map
  (setq ibuffer-mode-map (make-sparse-keymap))

  (define-key ibuffer-mode-map (kbd "0") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "1") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "2") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "3") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "4") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "5") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "6") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "7") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "8") 'digit-argument)
  (define-key ibuffer-mode-map (kbd "9") 'digit-argument)  

  (define-key ibuffer-mode-map (kbd "m") 'ibuffer-mark-forward)
  (define-key ibuffer-mode-map (kbd "t") 'ibuffer-toggle-marks) 
  (define-key ibuffer-mode-map (kbd "u") 'ibuffer-unmark-forward)
  (define-key ibuffer-mode-map (kbd "=") 'ibuffer-diff-with-file)
  (define-key ibuffer-mode-map (kbd "DEL") 'ibuffer-unmark-backward)
  (define-key ibuffer-mode-map (kbd "M-DEL") 'ibuffer-unmark-all)
  (define-key ibuffer-mode-map (kbd "* *") 'ibuffer-unmark-all)
  (define-key ibuffer-mode-map (kbd "* M") 'ibuffer-mark-by-mode)
  (define-key ibuffer-mode-map (kbd "* m") 'ibuffer-mark-modified-buffers)
  (define-key ibuffer-mode-map (kbd "* s") 'ibuffer-mark-special-buffers)
  (define-key ibuffer-mode-map (kbd "* r") 'ibuffer-mark-read-only-buffers)
  (define-key ibuffer-mode-map (kbd "* /") 'ibuffer-mark-dired-buffers)
  (define-key ibuffer-mode-map (kbd "* h") 'ibuffer-mark-help-buffers)
  (define-key ibuffer-mode-map (kbd ".") 'ibuffer-mark-old-buffers)
    
  (define-key ibuffer-mode-map (kbd "d") 'ibuffer-mark-for-delete)
  (define-key ibuffer-mode-map (kbd "k") 'ibuffer-mark-for-delete)  
  (define-key ibuffer-mode-map (kbd "x") 'ibuffer-do-kill-on-deletion-marks)
  
  ;; immediate operations
  (define-key ibuffer-mode-map (kbd "n") 'forward-line)
  (define-key ibuffer-mode-map (kbd "SPC") 'forward-line)  
  (define-key ibuffer-mode-map (kbd "p") 'previous-line)
  (define-key ibuffer-mode-map (kbd "l") 'ibuffer-redisplay)
  (define-key ibuffer-mode-map (kbd "g") 'ibuffer-update)
  (define-key ibuffer-mode-map (kbd ",") 'ibuffer-toggle-sorting-mode)
  (define-key ibuffer-mode-map (kbd "s i") 'ibuffer-invert-sorting)
  (define-key ibuffer-mode-map (kbd "s a") 'ibuffer-do-sort-by-alphabetic)
  (define-key ibuffer-mode-map (kbd "s v") 'ibuffer-do-sort-by-recency)
  (define-key ibuffer-mode-map (kbd "s s") 'ibuffer-do-sort-by-size)
  (define-key ibuffer-mode-map (kbd "s m") 'ibuffer-do-sort-by-major-mode)

  (define-key ibuffer-mode-map (kbd "/ m") 'ibuffer-limit-by-mode)
  (define-key ibuffer-mode-map (kbd "/ n") 'ibuffer-limit-by-name)
  (define-key ibuffer-mode-map (kbd "/ c") 'ibuffer-limit-by-content)
  (define-key ibuffer-mode-map (kbd "/ f") 'ibuffer-limit-by-filename)
  (define-key ibuffer-mode-map (kbd "/ >") 'ibuffer-limit-by-size-gt)
  (define-key ibuffer-mode-map (kbd "/ <") 'ibuffer-limit-by-size-lt)    
  (define-key ibuffer-mode-map (kbd "/ /") 'ibuffer-limit-disable)
  
  (define-key ibuffer-mode-map (kbd "q") 'ibuffer-quit)
  (define-key ibuffer-mode-map (kbd "h") 'describe-mode)
  (define-key ibuffer-mode-map (kbd "?") 'describe-mode)

  (define-key ibuffer-mode-map (kbd "% n") 'ibuffer-mark-by-name-regexp)
  (define-key ibuffer-mode-map (kbd "% m") 'ibuffer-mark-by-mode-regexp)
  (define-key ibuffer-mode-map (kbd "% f") 'ibuffer-mark-by-file-name-regexp)
  
  ;; marked operations
  (define-key ibuffer-mode-map (kbd "S") 'ibuffer-do-save)
  (define-key ibuffer-mode-map (kbd "A") 'ibuffer-do-view)
  (define-key ibuffer-mode-map (kbd "H") 'ibuffer-do-view-other-frame)
  ;;  (define-key ibuffer-mode-map (kbd "R") 'ibuffer-do-rename)
  (define-key ibuffer-mode-map (kbd "T") 'ibuffer-do-toggle-read-only)  
  (define-key ibuffer-mode-map (kbd "V") 'ibuffer-do-revert)
  (define-key ibuffer-mode-map (kbd "D") 'ibuffer-do-delete)
  (define-key ibuffer-mode-map (kbd "Q") 'ibuffer-do-query-replace)
  (define-key ibuffer-mode-map (kbd "I") 'ibuffer-do-query-replace-regexp)
  (define-key ibuffer-mode-map (kbd "P") 'ibuffer-do-print)
  (define-key ibuffer-mode-map (kbd "X") 'ibuffer-do-shell-command)
  (define-key ibuffer-mode-map (kbd "N") 'ibuffer-do-shell-command-replace)
  (define-key ibuffer-mode-map (kbd "E") 'ibuffer-do-eval)
  (define-key ibuffer-mode-map (kbd "W") 'ibuffer-do-view-and-eval)
  (define-key ibuffer-mode-map (kbd "k") 'ibuffer-do-kill-lines)
  
  (define-key ibuffer-mode-map (kbd "RET") 'ibuffer-visit-buffer)
  (define-key ibuffer-mode-map (kbd "e") 'ibuffer-visit-buffer)
  (define-key ibuffer-mode-map (kbd "f") 'ibuffer-visit-buffer)
  (define-key ibuffer-mode-map (kbd "o") 'ibuffer-visit-buffer-other-window)
  (define-key ibuffer-mode-map (kbd "C-o") 'ibuffer-visit-buffer-other-window-noselect)
  (define-key ibuffer-mode-map (kbd "v") 'ibuffer-do-view)
  (define-key ibuffer-mode-map (kbd "C-x 4 RET") 'ibuffer-visit-buffer-other-window)
  (define-key ibuffer-mode-map (kbd "C-x 5 RET") 'ibuffer-visit-buffer-other-frame)
)

(defvar ibuffer-name-map (make-sparse-keymap))
(set-keymap-parent ibuffer-name-map ibuffer-mode-map)
(define-key ibuffer-name-map [mouse-1] 'ibuffer-mouse-toggle-mark)
(define-key ibuffer-name-map [mouse-2] 'ibuffer-mouse-visit-buffer)
(define-key ibuffer-name-map [down-mouse-3] 'ibuffer-mouse-popup-menu)

;; quiet the byte-compiler
(defvar ibuffer-mode-operate-menu nil)
(defvar ibuffer-mode-mark-menu nil)
(defvar ibuffer-mode-regexp-menu nil)
(defvar ibuffer-mode-sort-menu nil)
(defvar ibuffer-mode-limit-menu nil)
(defvar ibuffer-mode-immediate-menu nil)

(defvar ibuffer-mode-hooks nil)
(defvar ibuffer-tmp-buffer-mark nil)
(defvar ibuffer-tmp-buffer nil)
(defvar ibuffer-tmp-buffer-modified nil)
(defvar ibuffer-tmp-buffer-read-only nil)
(defvar ibuffer-tmp-buffer-name nil)
(defvar ibuffer-tmp-buffer-size nil)
(defvar ibuffer-tmp-buffer-mode nil)
(defvar ibuffer-tmp-buffer-narrowed nil)
(defvar ibuffer-tmp-buffer-filename nil)
(defvar ibuffer-tmp-buffer-process nil)

(defvar ibuffer-delete-window-on-quit nil
  "Whether or not to delete the window upon exiting `ibuffer'.")

(defvar ibuffer-line-format-alist
  '((?o ibuffer-tmp-buffer-mark ?c)
    (?m ibuffer-tmp-buffer-modified ?c)
    (?r ibuffer-tmp-buffer-read-only ?c)
    (?n ibuffer-tmp-buffer-name ?s)
    (?s ibuffer-tmp-buffer-size ?d)
    (?M ibuffer-tmp-buffer-mode ?s)
    (?w ibuffer-tmp-buffer-narrowed ?s)    
    (?f ibuffer-tmp-buffer-filename ?s)
    (?p ibuffer-tmp-buffer-process ?s))    
  "An alist describing how to format a `ibuffer' line.
Each element should be like (FORMAT-SPECIFIER FUNCTION FORMAT-TYPE).")
  
(defvar ibuffer-sorting-functions-alist
  (list
   (list 'recency "last view time" nil)
   (list 'major-mode "major mode"
	 (function
	  (lambda (a b)
	    (string-lessp (downcase
			   (symbol-name (with-current-buffer
					    (car a)
					  major-mode)))
			  (downcase
			   (symbol-name (with-current-buffer
					    (car b)
					  major-mode)))))))
   (list 'alphabetic "buffer name"
	 (function
	  (lambda (a b)
	    (string-lessp
	     (buffer-name (car a))
	     (buffer-name (car b))))))
   (list 'size "size"
	 (function
	  (lambda (a b)
	    (< (with-current-buffer (car a)
		 (buffer-size))
	       (with-current-buffer (car b)
		 (buffer-size)))))))
  "An alist describing the possible sorting modes.
Each element should be like (SYMBOL DESCRIPTION FUNCTION).")
  

(defvar ibuffer-limiting-qualifiers '()
  "A list like (SYMBOL . QUALIFIER) which filters the current buffer list.
See also `ibuffer-limiting-alist'.")

(defvar ibuffer-limiting-alist
  (list
   (list 'mode "mode"
	 (function
	  (lambda (buf qualifier)
	    (with-current-buffer buf
	      (eq major-mode qualifier)))))
   (list 'filename "filename"
	 (function
	  (lambda (buf qualifier)
	    (when (buffer-file-name buf)
	      (string-match qualifier (buffer-file-name buf))))))
   (list 'size-gt "size>"
	 (function
	  (lambda (buf qualifier)
	    (> (with-current-buffer buf (buffer-size))
	       qualifier))))
   (list 'size-lt "size<"
	 (function
	  (lambda (buf qualifier)
	    (< (with-current-buffer buf (buffer-size))
	       qualifier))))
   (list 'name "name"
	 (function
	  (lambda (buf qualifier)
	    (string-match qualifier (buffer-name buf)))))
   (list 'content "content"
	 (function
	  (lambda (buf qualifier)
	    (with-current-buffer buf
	      (save-excursion
		(goto-char (point-min))
		(re-search-forward qualifier nil t)))))))
  "A list of (SYMBOL DESCRIPTION FUNCTION) which describes a filter.

SYMBOL is the symbolic name of the filter.  DESCRIPTION is used when
displaying information to the user.  FUNCTION is given a buffer and
the value of the qualifier, and returns non-`nil' if and only if the
buffer should be displayed.")
  

(unless ibuffer-mode-limit-menu
  (easy-menu-define
   ibuffer-mode-limit-menu ibuffer-mode-map ""
   '("Limit"
     ["Disable all limiting" ibuffer-limit-disable t]
     ["Limit by major mode..." ibuffer-limit-by-mode t]          
     ["Limit by buffer name..." ibuffer-limit-by-name t]
     ["Limit by filename..." ibuffer-limit-by-filename t]
     ["Limit by size less than..." ibuffer-limit-by-size-lt t]
     ["Limit by size greater than..." ibuffer-limit-by-size-gt t]
     ["Limit by content..." ibuffer-limit-by-content t])))

(unless ibuffer-mode-sort-menu
  (easy-menu-define
   ibuffer-mode-sort-menu ibuffer-mode-map ""
   '("Sort"
     ["Toggle sorting mode" ibuffer-toggle-sorting-mode t]
     ["Reverse sorting order" ibuffer-invert-sorting t]          
     ["Sort by view time" ibuffer-do-sort-by-recency t]
     ["Sort lexicographically" ibuffer-do-sort-by-alphabetic t]
     ["Sort by buffer size" ibuffer-do-sort-by-size t]     
     ["Sort by major mode" ibuffer-do-sort-by-major-mode t])))

(unless ibuffer-mode-immediate-menu
  (easy-menu-define
   ibuffer-mode-immediate-menu ibuffer-mode-map ""
   '("Immediate"
     ["View this buffer" ibuffer-visit-buffer t]
     ["View (other window)" ibuffer-visit-buffer-other-window t]
     ["View (other frame)" ibuffer-visit-buffer-other-frame t]
     ["Diff with file" ibuffer-diff-with-file t]     
     ["Redisplay" ibuffer-redisplay t]
     ["Update" ibuffer-update t])))

(unless ibuffer-mode-regexp-menu
  (easy-menu-define
   ibuffer-mode-regexp-menu ibuffer-mode-map ""
   '("Regexp"
     ["Mark by buffer name..." ibuffer-mark-by-name-regexp t]
     ["Mark by major mode..." ibuffer-mark-by-mode-regexp t]
     ["Mark by file name..." ibuffer-mark-by-file-name-regexp t])))

(unless ibuffer-mode-mark-menu
  (easy-menu-define
   ibuffer-mode-mark-menu ibuffer-mode-map ""
   '("Mark"
     ["Toggle marks" ibuffer-toggle-marks t]
     ["Mark" ibuffer-mark-forward t]
     ["Unmark" ibuffer-unmark-forward t]
     ["Mark by mode..." ibuffer-mark-by-mode t]     
     ["Mark modified buffers" ibuffer-mark-modified-buffers t]
     ["Mark read-only buffers" ibuffer-mark-read-only-buffers t]     
     ["Mark special buffers" ibuffer-mark-special-buffers t]
     ["Mark dired buffers" ibuffer-mark-dired-buffers t]
     ["Mark help buffers" ibuffer-mark-help-buffers t]
     ["Mark old buffers" ibuffer-mark-old-buffers t]     
     ["Unmark All" ibuffer-unmark-all t])))

(unless ibuffer-mode-operate-menu
  (easy-menu-define
   ibuffer-mode-operate-menu ibuffer-mode-map ""
   '("Operate"
     ["View" ibuffer-do-view t]
     ["View (separate frame)" ibuffer-do-view-other-frame t]          
     ["Save" ibuffer-do-save t]
     ["Query Replace..." ibuffer-do-query-replace t]
     ["Query Replace Regexp..." ibuffer-do-query-replace-regexp t]
     ["Print" ibuffer-do-print t]     
     ["Revert" ibuffer-do-revert t]
     ["Kill" ibuffer-do-delete t]
     ["Shell Command..." ibuffer-do-shell-command t]
     ["Shell Command (replace)..." ibuffer-do-shell-command-replace t]          
     ["Eval..." ibuffer-do-eval t]
     ["Eval (viewing buffer)..." ibuffer-do-view-and-eval t])))

(defvar ibuffer-popup-menu
  '("Ibuffer"
    ("Operate"
     ("Save" . ibuffer-do-save)
     ("Query Replace..." . ibuffer-do-query-replace)
     ("Query Replace Regexp..." . ibuffer-do-query-replace-regexp)
     ("Print" . ibuffer-do-print)
     ("Revert" . ibuffer-do-revert)
     ("Kill" . ibuffer-do-delete)
     ("Shell Command..." . ibuffer-do-shell-command)
     ("Shell Command (replace)..." . ibuffer-do-shell-command-replace)
     ("Eval..." . ibuffer-do-eval)
     ("Eval (viewing buffer)..." . ibuffer-do-view-and-eval))))

;; shamelessly stolen from gnus-util.el
(defun ibuffer-delete-alist (key alist)
  "Delete all entries in ALIST that have a key eq to KEY."
  (let (entry)
    (while (setq entry (assq key alist))
      (setq alist (delq entry alist)))
    alist))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-tilde-max-form (el max-width)
  "Return a form that limits EL to MAX-WIDTH."
  (let ((max (abs max-width)))
    (if (symbolp el)
	`(if (> (length ,el) ,max)
	     ,(if (< max-width 0)
		  `(substring ,el (- (length el) ,max))
		`(substring ,el 0 ,max))
	   ,el)
      `(let ((val (eval ,el)))
	 (if (> (length val) ,max)
	     ,(if (< max-width 0)
		  `(substring val (- (length val) ,max))
		`(substring val 0 ,max))
	   val)))))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-tilde-cut-form (el cut-width)
  "Return a form that cuts CUT-WIDTH off of EL."
  (let ((cut (abs cut-width)))
    (if (symbolp el)
	`(if (> (length ,el) ,cut)
	     ,(if (< cut-width 0)
		  `(substring ,el 0 (- (length el) ,cut))
		`(substring ,el ,cut))
	   ,el)
      `(let ((val (eval ,el)))
	 (if (> (length val) ,cut)
	     ,(if (< cut-width 0)
		  `(substring val 0 (- (length val) ,cut))
		`(substring val ,cut))
	   val)))))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-tilde-ignore-form (el ignore-value)
  "Return a form that is blank when EL is IGNORE-VALUE."
  (if (symbolp el)
      `(if (equal ,el ,ignore-value)
	   "" ,el)
    `(let ((val (eval ,el)))
       (if (equal val ,ignore-value)
	   "" val))))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-parse-format (format spec-alist &optional insert)
  ;; This function parses the FORMAT string with the help of the
  ;; SPEC-ALIST and returns a list that can be eval'ed to return the
  ;; string.  If the FORMAT string contains the specifiers %( and %)
  ;; the text between them will have the mouse-face text property.
  ;; If the FORMAT string contains the specifiers %[ and %], the text between
  ;; them will have the balloon-help text property.
  (if (string-match
       "\\`\\(.*\\)%[0-9]?[{(«]\\(.*\\)%[0-9]?[»})]\\(.*\n?\\)\\'"
       format)
      (ibuffer-parse-complex-format format spec-alist)
    ;; This is a simple format.
    (ibuffer-parse-simple-format format spec-alist insert)))

;; for use with the stuff shamelessly stolen from gnus-spec.el :)
(defun ibuffer-set-work-buffer ()
  (set-buffer (get-buffer-create " *ibuffer-work*"))
  (erase-buffer))

(defun ibuffer-mouse-face-function (form type)
  `(let ((beg (point))
	 (end (progn ,@form (point))))
     (put-text-property beg end
			'mouse-face
			'highlight)))

(defun ibuffer-bold-face-function (form type)
  `(let ((beg (point))
	 (end (progn ,@form (point))))
     (put-text-property beg end
			'face
			'bold)))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-parse-complex-format (format spec-alist)
  (save-excursion
    (ibuffer-set-work-buffer)
    (insert format)
    (goto-char (point-min))
    (while (re-search-forward "\"" nil t)
      (replace-match "\\\"" nil t))
    (goto-char (point-min))
    (insert "(\"")
    (while (re-search-forward "%\\([0-9]+\\)?\\([«»{}()]\\)" nil t)
      (let ((number (if (match-beginning 1)
			(match-string 1) "0"))
	    (delim (aref (match-string 2) 0)))
	(if (or (= delim ?\()
		(= delim ?\{)
		(= delim ?\?)
	    (replace-match (concat "\"("
				   (cond ((= delim ?\() "mouse")
					 ((= delim ?\{) "bold")
					 (t "balloon"))
				   " " number " \""))
	  (replace-match "\")\""))))
    (goto-char (point-max))
    (insert "\")")
    (goto-char (point-min))
    (let ((form (read (current-buffer))))
      (cons 'progn (ibuffer-complex-form-to-spec form spec-alist)))))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-complex-form-to-spec (form spec-alist)
  (delq nil
	(mapcar
	 (lambda (sform)
	   (if (stringp sform)
	       (ibuffer-parse-simple-format sform spec-alist t)
	     (funcall (intern (format "ibuffer-%s-face-function" (car sform)))
		      (ibuffer-complex-form-to-spec (cddr sform) spec-alist)
		      (nth 1 sform))))
	 form)))

;; shamelessly stolen from gnus-spec.el
(defun ibuffer-parse-simple-format (format spec-alist &optional insert)
  ;; This function parses the FORMAT string with the help of the
  ;; SPEC-ALIST and returns a list that can be eval'ed to return a
  ;; string.
  (let ((max-width 0)
	spec flist fstring elem result dontinsert user-defined
	type value pad-width spec-beg cut-width ignore-value
	tilde-form tilde elem-type)
    (save-excursion
      (ibuffer-set-work-buffer)      
      (insert format)
      (goto-char (point-min))
      (while (re-search-forward "%" nil t)
	(setq user-defined nil
	      spec-beg nil
	      pad-width nil
	      max-width nil
	      cut-width nil
	      ignore-value nil
	      tilde-form nil)
	(setq spec-beg (1- (point)))

	;; Parse this spec fully.
	(while
	    (cond
	     ((looking-at "\\([-.0-9]+\\)\\(,[-0-9]+\\)?")
	      (setq pad-width (string-to-number (match-string 1)))
	      (when (match-beginning 2)
		(setq max-width (string-to-number (buffer-substring
						   (1+ (match-beginning 2))
						   (match-end 2)))))
	      (goto-char (match-end 0)))
	     ((looking-at "~")
	      (forward-char 1)
	      (setq tilde (read (current-buffer))
		    type (car tilde)
		    value (cadr tilde))
	      (cond
	       ((memq type '(pad pad-left))
		(setq pad-width value))
	       ((eq type 'pad-right)
		(setq pad-width (- value)))
	       ((memq type '(max-right max))
		(setq max-width value))
	       ((eq type 'max-left)
		(setq max-width (- value)))
	       ((memq type '(cut cut-left))
		(setq cut-width value))
	       ((eq type 'cut-right)
		(setq cut-width (- value)))
	       ((eq type 'ignore)
		(setq ignore-value
		      (if (stringp value) value (format "%s" value))))
	       ((eq type 'form)
		(setq tilde-form value))
	       (t
		(error "Unknown tilde type: %s" tilde)))
	      t)
	     (t
	      nil)))
	;; User-defined spec -- find the spec name.
	(when (eq (setq spec (char-after)) ?u)
	  (forward-char 1)
	  (setq user-defined (char-after)))
	(forward-char 1)
	(delete-region spec-beg (point))

	;; Now we have all the relevant data on this spec, so
	;; we start doing stuff.
	(insert "%")
	(if (eq spec ?%)
	    ;; "%%" just results in a "%".
	    (insert "%")
	  (cond
	   ;; Do tilde forms.
	   ((eq spec ?@)
	    (setq elem (list tilde-form ?s)))
	   ;; Treat user defined format specifiers specially.
	   (user-defined
	    (setq elem
		  (list
		   (list (intern (format "ibuffer-user-format-function-%c"
					 user-defined))
			 'ibuffer-tmp-buffer)
		   ?s)))
	   ;; Find the specification from `spec-alist'.
	   ((setq elem (cdr (assq spec spec-alist))))
	   (t
	    (setq elem '("*" ?s))))
	  (setq elem-type (cadr elem))
	  ;; Insert the new format elements.
	  (when pad-width
	    (insert (number-to-string pad-width)))
	  ;; Create the form to be evaled.
	  (if (or max-width cut-width ignore-value)
	      (progn
		(insert ?s)
		(let ((el (car elem)))
		  (cond ((= (cadr elem) ?c)
			 (setq el (list 'char-to-string el)))
			((= (cadr elem) ?d)
			 (setq el (list 'int-to-string el))))
		  (when ignore-value
		    (setq el (ibuffer-tilde-ignore-form el ignore-value)))
		  (when cut-width
		    (setq el (ibuffer-tilde-cut-form el cut-width)))
		  (when max-width
		    (setq el (ibuffer-tilde-max-form el max-width)))
		  (push el flist)))
	    (insert elem-type)
	    (push (car elem) flist))))
      (setq fstring (buffer-string)))

    ;; Do some postprocessing to increase efficiency.
    (setq
     result
     (cond
      ;; Emptyness.
      ((string= fstring "")
       nil)
      ;; Not a format string.
      ((not (string-match "%" fstring))
       (list fstring))
      ;; A format string with just a single string spec.
      ((string= fstring "%s")
       (list (car flist)))
      ;; A single character.
      ((string= fstring "%c")
       (list (car flist)))
      ;; A single number.
      ((string= fstring "%d")
       (setq dontinsert)
       (if insert
	   (list `(princ ,(car flist)))
	 (list `(int-to-string ,(car flist)))))
      ;; Just lots of chars and strings.
      ((string-match "\\`\\(%[cs]\\)+\\'" fstring)
       (nreverse flist))
      ;; A single string spec at the beginning of the spec.
      ((string-match "\\`%[sc][^%]+\\'" fstring)
       (list (car flist) (substring fstring 2)))
      ;; A single string spec in the middle of the spec.
      ((string-match "\\`\\([^%]+\\)%[sc]\\([^%]+\\)\\'" fstring)
       (list (match-string 1 fstring) (car flist) (match-string 2 fstring)))
      ;; A single string spec in the end of the spec.
      ((string-match "\\`\\([^%]+\\)%[sc]\\'" fstring)
       (list (match-string 1 fstring) (car flist)))
      ;; A more complex spec.
      (t
       (list (cons 'format (cons fstring (nreverse flist)))))))

    (if insert
	(when result
	  (if dontinsert
	      result
	    (cons 'insert result)))
      (cond ((stringp result)
	     result)
	    ((consp result)
	     (cons 'concat result))
	    (t "")))))

(defun ibuffer-mouse-toggle-mark (event)
  (interactive "e")
  (unwind-protect
      (save-excursion
	(goto-char (posn-point (event-end event)))
	(let ((mark (ibuffer-current-mark)))
	  (setq buffer-read-only nil)
	  (if (eq mark ibuffer-marked-char)
	      (ibuffer-set-mark ? )
	    (ibuffer-set-mark ibuffer-marked-char))))
    (setq buffer-read-only t)))

(defun ibuffer-mouse-visit-buffer (event)
  (interactive "e")
  (switch-to-buffer
   (save-excursion
     (goto-char (posn-point (event-end event)))
     (ibuffer-current-buffer))))

(defun ibuffer-mouse-popup-menu (event)
  (interactive "e")
  (let ((pt (posn-point (event-end event))))
    (unwind-protect    
	(save-excursion
	  (setq buffer-read-only nil)
	  (let ((choice (x-popup-menu t ibuffer-popup-menu)))
	    (message "choice: %s" choice)	
	    (when choice
	      (ibuffer-save-marks
		;; hm.  we could probably do this in a better fashion
		(ibuffer-unmark-all)
		(setq buffer-read-only nil)
		(goto-char pt)
		(ibuffer-set-mark ibuffer-marked-char)
		(setq buffer-read-only nil)
		(call-interactively choice)
		(setq buffer-read-only nil)))))
      (setq buffer-read-only t))))

(defmacro ibuffer-save-marks (&rest body)
  `(let ((ibuffer-save-marks-tmp-mark-list (ibuffer-current-state-list)))
     (unwind-protect
	 (progn
	   ,@body)
       (ibuffer-insert-buffers-and-marks ibuffer-save-marks-tmp-mark-list))
     (ibuffer-redisplay t)))
(put 'ibuffer-save-marks 'lisp-indent-function 0)

(defun ibuffer-visit-buffer ()
  "Enter the buffer on this line."
  (interactive)
  (let ((buf (ibuffer-current-buffer)))
    (unless (buffer-live-p buf)
      (error "Buffer %s has been killed!" buf))
    (bury-buffer (current-buffer))
    (switch-to-buffer buf)))

(defun ibuffer-visit-buffer-other-window (&optional noselect)
  "Enter the buffer on this line in another window."
  (interactive)
  (let ((buf (ibuffer-current-buffer)))
    (unless (buffer-live-p buf)
      (error "Buffer %s has been killed!" buf))
    (bury-buffer (current-buffer))
    (if noselect
      (let ((curwin (selected-window)))
	(pop-to-buffer buf)
	(select-window curwin))
      (switch-to-buffer-other-window buf t))))

(defun ibuffer-visit-buffer-other-window-noselect ()
  "View the buffer on this line in another window, but don't select it."
  (interactive)
  (ibuffer-visit-buffer-other-window t))

(defun ibuffer-visit-buffer-other-frame ()
  "Enter the buffer on this line in another frame."
  (interactive)
  (let ((buf (ibuffer-current-buffer)))
    (unless (buffer-live-p buf)
      (error "Buffer %s has been killed!" buf))
    (bury-buffer (current-buffer))
    (switch-to-buffer-other-frame buf t)))

(defun ibuffer-diff-with-file ()
  "View the differences between this buffer and its associated file."
  (interactive)
  (let ((buf (ibuffer-current-buffer)))
    (unless (buffer-live-p buf)
      (error "Buffer %s has been killed!" buf))
    (unless
    (with-current-buffer buf
      (unless buffer-file-name
	(error "Buffer %s has no associated file!" buf))
      (let ((diff-buf (get-buffer-create "*Ibuffer-diff*")))
	(shell-command-on-region
	 (point-min) (point-max)
	 (concat "diff " buffer-file-name " -") diff-buf)
	(display-buffer (get-buffer-create "*Ibuffer-diff*")))))))

(defun ibuffer-mark-on-buffer (func)
  (let ((count
	 (ibuffer-map-lines
	  (function (lambda (buf mark beg end)
		      (when (funcall func buf)
			(ibuffer-set-mark ibuffer-marked-char)
			t))))))
    (ibuffer-redisplay t)
    (message "Marked %s buffers." count)))

(defun ibuffer-mark-by-name-regexp (regexp)
  "Mark all buffers whose name matches REGEXP."
  (interactive "sMark by name (regexp): ")
  (ibuffer-mark-on-buffer
   (function
    (lambda (buf)
      (string-match regexp (buffer-name buf))))))

(defun ibuffer-mark-by-mode-regexp (regexp)
  "Mark all buffers whose major mode matches REGEXP."
  (interactive "sMark by major mode (regexp): ")
  (ibuffer-mark-on-buffer
   (function
    (lambda (buf)
      (with-current-buffer buf
	(string-match regexp mode-name))))))

(defun ibuffer-mark-by-file-name-regexp (regexp)
  "Mark all buffers whose file name matches REGEXP."
  (interactive "sMark by file name (regexp): ")
  (ibuffer-mark-on-buffer
   (function
    (lambda (buf)
      (let ((name (buffer-file-name buf)))
	(when name
	  (string-match regexp name)))))))

(defun ibuffer-mark-by-mode (mode)
  "Mark all buffers whose major mode equals MODE."
  (interactive
   (list (intern (completing-read "Mark by major mode: " obarray
				  (function
				   (lambda (e)
				     ;; kind of a hack...
				     (string-match "-mode$"
						   (symbol-name e))))
				  t
				  (let ((buf (ibuffer-current-buffer)))
				    (if buf
					(with-current-buffer buf
					  (symbol-name major-mode))
				      ""))))))
  (ibuffer-mark-on-buffer
   (function
    (lambda (buf)
      (with-current-buffer buf
	(eq major-mode mode))))))
  

(defun ibuffer-mark-modified-buffers ()
  "Mark all modified buffers."
  (interactive)
  (ibuffer-mark-on-buffer
   (function (lambda (buf) (buffer-modified-p buf)))))

(defun ibuffer-mark-special-buffers ()
  "Mark all buffers whose name begins and ends with '*'."
  (interactive)
  (ibuffer-mark-on-buffer
   (function (lambda (buf) (string-match "^\\*.+\\*$"
					 (buffer-name buf))))))

(defun ibuffer-mark-read-only-buffers ()
  "Mark all read-only buffers."
  (interactive)
  (ibuffer-mark-on-buffer
   (function (lambda (buf)
	       (with-current-buffer buf
		 buffer-read-only)))))

(defun ibuffer-mark-dired-buffers ()
  "Mark all `dired' buffers."
  (interactive)
  (ibuffer-mark-on-buffer
   (function (lambda (buf)
	       (with-current-buffer buf
		 (eq major-mode 'dired-mode))))))

(defun ibuffer-mark-help-buffers ()
  "Mark buffers like *Help*, *Apropos*, *Info*."
  (interactive)
  (ibuffer-mark-on-buffer
   (function (lambda (buf)
	       (with-current-buffer buf
		 (or
		  (eq major-mode 'apropos-mode)
		  (eq major-mode 'help-mode)
		  (eq major-mode 'info-mode)))))))

(defun ibuffer-mark-old-buffers ()
  "Mark buffers which have not been viewed in `ibuffer-old-time' days."
  (interactive)
  (ibuffer-mark-on-buffer
   (function
    (lambda (buf)
      (with-current-buffer buf
	;; hacked from midnight.el
	(when buffer-display-time
	  (let* ((tm (current-time))
		 (now (+ (* (float (ash 1 16)) (car tm))
			 (float (cadr tm)) (* 0.0000001 (caddr tm))))
		 (then (+ (* (float (ash 1 16))
			     (car buffer-display-time))
			  (float (cadr buffer-display-time))
			  (* 0.0000001 (caddr buffer-display-time)))))
	    (> (- now then) (* 24 60 60 ibuffer-old-time)))))))))

(defun ibuffer-do-view (&optional other-frame)
  "View marked buffers.
If optional argument OTHER-FRAME is non-`nil', then display each
marked buffer in a new frame.  Otherwise, display each buffer as
a new window in the current frame."
  (interactive)
  (let ((marked-bufs (ibuffer-get-marked-buffers)))
    (if (null marked-bufs)
	(message "No buffers marked; use 'm' to mark a buffer.")
      (unless (and other-frame
		   (not ibuffer-expert)
		   (> (length marked-bufs) 3)
		   (not (y-or-n-p (format "Really create a new frame for %s buffers? "
					  (length marked-bufs)))))
	(delete-other-windows)
	(switch-to-buffer (pop marked-bufs))
	(let ((height (/ (1- (frame-height)) (1+ (length marked-bufs)))))
	  (mapcar (if other-frame
		      #'(lambda (buf)
			  (let ((curframe (selected-frame)))
			    (select-frame (new-frame))
			    (switch-to-buffer buf)
			    (select-frame curframe)))
		    #'(lambda (buf)
			(split-window nil height)
			(other-window 1)
			(switch-to-buffer buf)))
		  marked-bufs))))))

(defun ibuffer-do-view-other-frame ()
 "View each of the marked buffers in a separate frame."
  (interactive)
  (ibuffer-do-view t))

(defun ibuffer-do-save ()
 "Save marked buffers as with `save-buffer'."
  (interactive)
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(when (buffer-modified-p buf)
			  (if (not (with-current-buffer buf
				     buffer-file-name))
			      ;; handle the case where we're prompted
			      ;; for a file name
			      (save-excursion
				(switch-to-buffer buf)
				(save-buffer))
			    (with-current-buffer buf
			      (save-buffer)))
			  t))))))
      (message "Saved %s buffers." count))))  

(defun ibuffer-do-print ()
  "Print marked buffers as with `print-buffer'."
  (interactive)
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")  
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(with-current-buffer buf
			  (print-buffer))
			t)))))
      (message "Printed %s buffers." count))))

(defun ibuffer-do-query-replace (from-str to-str &optional arg)
  "Perform a `query-replace' in marked buffers."
  (interactive (query-replace-read-args "Query replace" nil))
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")  
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(save-window-excursion
			  (switch-to-buffer buf)
			  (save-excursion
			    (goto-char (point-min))
			    (query-replace from-str to-str arg))
			  t))))))
      (message "Replaced in %s buffers." count))))

(defun ibuffer-do-query-replace-regexp (from-str to-str &optional arg)
  "Perform a `query-replace-regexp' in marked buffers."
  (interactive (query-replace-read-args "Query replace regexp" t))
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")  
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(save-window-excursion
			  (switch-to-buffer buf)
			  (save-excursion
			    (goto-char (point-min))			  
			    (query-replace-regexp from-str to-str arg))
			  t))))))
      (message "Replaced in %s buffers." count))))

(defun ibuffer-do-delete ()
  "Kill marked buffers as with `kill-this-buffer'."
  (interactive)
  (let ((mark-count (ibuffer-count-marked-lines)))
    (when (and (or (> mark-count 0)
		   (progn
		     (message "No buffers marked; use 'm' to mark a buffer.")
		     nil))
	       (or ibuffer-expert
		   (y-or-n-p (format "Really kill %s buffers? " mark-count))))
      (let ((count
	     (ibuffer-map-marked-lines
	      (function (lambda (buf mark beg end)
			  (with-current-buffer buf
			    (kill-this-buffer))
			  (delete-region beg end)
			  ;; tell the mapper we removed this line
			  'killed)))))
	(message "Killed %s buffers." count)))))

(defun ibuffer-do-revert ()
  "Revert marked buffers as with `revert-buffer'."  
  (interactive)
  (let ((mark-count (ibuffer-count-marked-lines)))
    (when (and (or (> mark-count 0)
		   (progn (message "No buffers marked; use 'm' to mark a buffer.")
			  nil))
	       (or ibuffer-expert
		   (y-or-n-p (format "Really revert %s buffers? "
				     mark-count))))
      (let ((count
	     (ibuffer-map-marked-lines
	      (function (lambda (buf mark beg end)
			  (with-current-buffer buf
			    (revert-buffer t t)
			    t))))))
	(message "Reverted %s buffers." count)))))

(defun ibuffer-do-shell-command (command)
  "Execute shell command COMMAND on the contents of each marked buffer."
  (interactive "sShell command: ")
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")  
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(with-current-buffer buf
			  (shell-command-on-region
			   (point-min) (point-max) command
			   (get-buffer-create "* ibuffer-shell-output*")))
			t)))))
      (message "Shell command executed on %s buffers." count))))

(defun ibuffer-do-shell-command-replace (command)
  "Replace the contents of each marked buffer with the output of COMMAND."
  (interactive "sShell command (replace): ")
  (let ((mark-count (ibuffer-count-marked-lines)))
    (when (and (or (> mark-count 0)
		   (progn
		     (message "No buffers marked; use 'm' to mark a buffer.")
			  nil))
	       (or ibuffer-expert
		   (y-or-n-p
		    (format "Really replace the contents of %s buffers? "
				     mark-count))))
      (let ((count
	     (ibuffer-map-marked-lines
	      (function (lambda (buf mark beg end)
			  (with-current-buffer buf
			    (shell-command-on-region (point-min) (point-max)
						     command nil t))
			  t)))))
	(message "Buffer contents replaced in %s buffers." count)))))

(defun ibuffer-do-eval (form)
  "Evaluate FORM in each of the buffers.
Does not display the buffer during evaluation. See
`ibuffer-do-view-and-eval' for that."
  (interactive "xEval in buffers (form): ")
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")  
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(with-current-buffer buf
			  (eval form))
			t)))))
      (message "Evaluated in %s buffers." count))))

(defun ibuffer-do-view-and-eval (form)
  "Evaluate FORM while displaying each of the marked buffers.
To evaluate a form without viewing the buffer, see `ibuffer-do-eval'."
  (interactive "xEval viewing buffers (form): ")
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")  
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(let ((ibuffer-buf (current-buffer)))
			  (unwind-protect
			      (progn
				(switch-to-buffer buf)
				(eval form))
			    (switch-to-buffer ibuffer-buf))
			  t))))))
      (message "Evaluated in %s buffers." count))))

(defun ibuffer-do-kill-on-deletion-marks ()
  "Kill buffers marked for deletion as with `kill-this-buffer'."
  (interactive)
  (let ((mark-count (ibuffer-count-deletion-lines)))
    (when (and (or (> mark-count 0)
		   (progn
		     (message "No buffers marked for deletion.")
		     nil))
	       (or ibuffer-expert
		   (y-or-n-p (format "Really kill %s buffers? " mark-count))))
      (let ((count
	     (ibuffer-map-deletion-lines
	      (function (lambda (buf mark beg end)
			  (with-current-buffer buf
			    (kill-this-buffer))
			  (delete-region beg end)
			  ;; tell the mapper we removed this line
			  'killed)))))
	(message "Killed %s buffers." count)))))

(defun ibuffer-do-kill-lines ()
  "Hide all of the currently marked lines."
  (interactive)
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")    
    (let ((count
	   (ibuffer-map-marked-lines
	    (function (lambda (buf mark beg end)
			(let ((pt (point)))
			  (delete-region beg end)
			  (goto-char pt))
			;; tell the mapper not to move forward, because
			;; we already killed this line
			'killed)))))
      (message "Killed %s lines." count))))

(defun ibuffer-unmark-all ()
  "Unmark all currently marked buffers."
  (interactive)
  (if (= (ibuffer-count-marked-lines) 0)
      (message "No buffers marked; use 'm' to mark a buffer.")      
    (ibuffer-map-marked-lines
     (function (lambda (buf mark beg end)
		 (ibuffer-set-mark ? )
		 t)))))

(defun ibuffer-toggle-marks ()
  "Toggle which buffers are marked.
In other words, unmarked buffers become marked, and marked buffers
become unmarked."
  (interactive)
  (let ((count
	 (ibuffer-map-lines
	  (function (lambda (buf mark beg end)
		      (cond ((eq mark ibuffer-marked-char)
			     (ibuffer-set-mark ? )
			     nil)
			    ((eq mark ? )
			     (ibuffer-set-mark ibuffer-marked-char)
			     t)
			    (t
			     nil)))))))
    (message "%s buffers marked." count))
  (ibuffer-redisplay t))

(defun ibuffer-mark-forward (arg)
  "Mark the buffer on this line, and move forward one line."
  (interactive "P")
  (ibuffer-mark-interactive arg ibuffer-marked-char 1))

(defun ibuffer-unmark-forward (arg)
  "Unmark the buffer on this line, and move forward one line."  
  (interactive "P")
  (ibuffer-mark-interactive arg ?  1))

(defun ibuffer-unmark-backward (arg)
  "Unmark the buffer on this line, and move backward one line."    
  (interactive "P")
  (ibuffer-mark-interactive arg ?  -1))

(defun ibuffer-do-sort-by-major-mode ()
  "Sort the buffers by major modes.
Ordering is lexicographic."
  (interactive)
  (setq ibuffer-sorting-mode 'major-mode)
  (ibuffer-redisplay t))

(defun ibuffer-do-sort-by-alphabetic ()
  "Sort the buffers by their names.
Ordering is lexicographic."
  (interactive)
  (setq ibuffer-sorting-mode 'alphabetic)
  (ibuffer-redisplay t))

(defun ibuffer-do-sort-by-recency ()
  "Sort the buffers by last view time."
  (interactive)
  (setq ibuffer-sorting-mode 'recency)
  (ibuffer-redisplay t))

(defun ibuffer-do-sort-by-size ()
  "Sort the buffers by size."
  (interactive)
  (setq ibuffer-sorting-mode 'size)
  (ibuffer-redisplay t))

(defun ibuffer-mark-interactive (arg mark movement)
  (unless arg
    (setq arg 1))
  (while (> arg 0)
    (unwind-protect
	(progn
	  (setq buffer-read-only nil)
	  (ibuffer-set-mark mark)
	  (ibuffer-redisplay-current))
      (setq buffer-read-only t))
    (forward-line movement)
    (setq arg (1- arg))))

(defun ibuffer-set-mark (mark)
  (let ((beg (ibuffer-line-beginning-position))
	(end (ibuffer-line-end-position)))
    (put-text-property beg end
		       'ibuffer-properties
		       (list (ibuffer-current-buffer)
			     mark))
    (ibuffer-redisplay-current)))

(defun ibuffer-mark-for-delete (arg)
  "Mark the buffer on this line for deletion."
  (interactive "P")
  (ibuffer-mark-interactive arg ibuffer-deletion-char 1))

(defun ibuffer-put-face-on-name (face)
  ;; we have to search for where the name is - it should have the
  ;; mouse-face property
  (let ((beg (ibuffer-line-beginning-position))
	(end (ibuffer-line-end-position)))
    (let ((namebeg (or
		    ;; the user might have put %n right at the
		    ;; beginning
		    (when (get-text-property beg 'mouse-face) beg)
		    (next-single-property-change beg
						 'mouse-face
						 (current-buffer)
						 end))))
      (unless (= namebeg end)
	(let ((nameend (next-single-property-change namebeg 'mouse-face
						    (current-buffer)
						    end)))
	  (unless (= nameend (1+ end))
	    (put-text-property namebeg nameend
			       'face
			       face)
	    (put-text-property namebeg nameend
			       'local-map ibuffer-name-map)))))))

(defun ibuffer-current-buffer ()
  (car (get-text-property (ibuffer-line-beginning-position)
			  'ibuffer-properties)))
      
(defun ibuffer-current-mark ()
  (let* ((props (get-text-property (ibuffer-line-beginning-position)
				   'ibuffer-properties))
	 (buf (car props))
	 (mark (cadr props)))
    (unless mark
      (error "Ibuffer error: buffer %s: invalid mark %s" buf mark))
    mark))

(defun ibuffer-insert-buffer-line (buffer mark)
  (with-current-buffer buffer
    (setq
     ibuffer-tmp-buffer buffer
     ibuffer-tmp-buffer-mark mark
     ibuffer-tmp-buffer-modified (if (buffer-modified-p)
				     ibuffer-modified-char ? )
     ibuffer-tmp-buffer-read-only (if buffer-read-only
				      ibuffer-read-only-char ? )
     ibuffer-tmp-buffer-name (buffer-name)
     ibuffer-tmp-buffer-size (buffer-size)
     ibuffer-tmp-buffer-mode mode-name
     ibuffer-tmp-buffer-narrowed (if (and (= 1 (point-min))
					  (= (1+ (buffer-size)) (point-max)))
				     ""
				   "narrow")
     ibuffer-tmp-buffer-filename (or buffer-file-name ""))
    
     (let ((proc (get-buffer-process (current-buffer))))
       (setq ibuffer-tmp-buffer-process
	     (if proc (concat
		       "(" (process-name proc) " "
		       (symbol-name (process-status proc)) ")")
	       ""))))
  (let ((beg (point))
	(end (progn (funcall ibuffer-line-format-form)
		    (point))))
    (put-text-property beg end 'ibuffer-properties
		       (list 
			ibuffer-tmp-buffer
			ibuffer-tmp-buffer-mark))
    (cond ((eq ibuffer-tmp-buffer-mark ibuffer-marked-char)
	   (ibuffer-put-face-on-name 'ibuffer-marked-face))
	  ((eq ibuffer-tmp-buffer-mark ibuffer-deletion-char)
	   (ibuffer-put-face-on-name 'ibuffer-deletion-face))
	  (t
	   (ibuffer-put-face-on-name 'default)))
    (insert "\n")
    (goto-char beg)))

(defun ibuffer-redisplay-current ()
  (save-excursion
    ;; handle special cases
    (unless (and (eobp) (bobp))
      (when (eobp)
	(forward-line -1))
      (progn
	(beginning-of-line)  
	(let ((buf (ibuffer-current-buffer))
	      (mark (ibuffer-current-mark)))
	  (delete-region (point) (1+ (ibuffer-line-end-position)))
	  (ibuffer-insert-buffer-line buf mark))))))

(defun ibuffer-count-marked-lines ()
  (ibuffer-map-lines
   (function (lambda (buf mark beg end)
	       (eq mark ibuffer-marked-char)))))

(defun ibuffer-count-deletion-lines ()
  (ibuffer-map-lines
   (function (lambda (buf mark beg end)
	       (eq mark ibuffer-deletion-char)))))

(defun ibuffer-map-deletion-lines (func)
  (ibuffer-map-on-mark ibuffer-deletion-char func))

(defun ibuffer-map-marked-lines (func)
  (ibuffer-map-on-mark ibuffer-marked-char func))
   
(defun ibuffer-map-on-mark (mark func)
  (ibuffer-map-lines
   (function
    (lambda (buf mk beg end)
      (if (eq mark mk)
	  (prog1 (funcall func buf mark beg end)
	    (ibuffer-redisplay-current))
	nil)))))

(defun ibuffer-map-lines (function)
  (save-excursion
    (unwind-protect
	(let ((ibuffer-map-lines-count 0))
	  (setq buffer-read-only nil)
	  (goto-char (point-min))
	  (while (not (eobp))
	    ;; The function should return `killed' if it removed the line
	    (let ((result
		   (if (buffer-live-p (ibuffer-current-buffer))
		       (funcall function
				(ibuffer-current-buffer)
				(ibuffer-current-mark)
				(ibuffer-line-beginning-position)
				(1+ (ibuffer-line-end-position)))
		     ;; Kill the line if the buffer is dead
		     (progn (delete-region (ibuffer-line-beginning-position)
					   (1+ (ibuffer-line-end-position)))
			    'dead))))
	      
	      ;; A given mapping function should return:
	      ;; `nil' if it chose not to affect the buffer
	      ;; `killed' if it removed the line from the buffer list
	      ;; `t' otherwise
	      (cond ((null result)
		     (forward-line 1))
		    ((eq result 'killed)
		     (setq ibuffer-map-lines-count
			   (1+ ibuffer-map-lines-count)))
		    ((eq result 'dead)
		     ;; do nothing
		     )
		    (t
		     (setq ibuffer-map-lines-count
			   (1+ ibuffer-map-lines-count))
		     (forward-line 1)))))
	  ibuffer-map-lines-count)
      (setq buffer-read-only t))))

(defun ibuffer-get-marked-buffers ()
  (delq nil
	(mapcar (lambda (e)
		  (when (eq (cadr e) ibuffer-marked-char)
		    (car e)))
		(ibuffer-current-state-list))))

(defun ibuffer-current-state-list ()
  ;; A list like (BUF MARK) of all buffers listed in the ibuffer buffer.
  (let ((ibuffer-tmp-result-tmp '()))
    ;; ah, if only we had closures.  I bet this will mysteriously
    ;; break later.  Don't blame me.
    (ibuffer-map-lines (function
			(lambda (buf mark beg end)
			  (when (buffer-live-p buf)
			    (setq ibuffer-tmp-result-tmp
				  (cons (list buf mark)
					ibuffer-tmp-result-tmp))))))
    ibuffer-tmp-result-tmp))

(defun ibuffer-canonicalize-state-list (bmarklist)
  ;; Order BMARKLIST in the same way as the current buffer list.
  (delq nil
	(mapcar #'(lambda (buf) (assq buf bmarklist)) (buffer-list))))

(defun ibuffer-current-buffers-with-marks ()
  ;; A list like (BUF MARK) of all active buffers.
  (let ((bufs (ibuffer-current-state-list)))
    (mapcar #'(lambda (buf) (let ((e (assq buf bufs)))
			      (if e
				  e
				(list buf ? ))))
	    (buffer-list))))

(defun ibuffer-filter-by-limits (bmarklist)
  (delq nil
	(mapcar
	 ;; element should be like (BUFFER MARK)
	 #'(lambda (element)
	     (unless (memq nil ;; a filter will return nil if it failed
			   (mapcar
			    ;; filter should be like (TYPE . QUALIFIER)
			    #'(lambda (filter)
				;; filterdat should be like (TYPE DESCRIPTION FUNC)
				(let ((filterdat (assq (car filter)
						       ibuffer-limiting-alist)))
				  ;; just a sanity check
				  (unless filterdat
				    (ibuffer-limit-disable)
				    (error "Undefined filter %s" (car filter)))
				  (funcall (caddr filterdat)
					   (car element)
					   (cdr filter))))
			    ibuffer-limiting-qualifiers))
	       element))
	 bmarklist)))

(defun ibuffer-limit-disable ()
  (interactive)
  (setq ibuffer-limiting-qualifiers nil)
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-update-mode-name ()
  (setq mode-name "Ibuffer")
  (mapcar
   #'(lambda (q)
       ;; q should be like (TYPE . QUALIFIER)
       (let ((qual (assq (car q) ibuffer-limiting-alist)))
	 (unless qual
	   (error "ibuffer: bad qualifier %s" qual))
	 (setq mode-name (concat mode-name " ["
				 (cadr qual) ": " (format "%s]" (cdr q))))))
   ibuffer-limiting-qualifiers))

(defun ibuffer-add-qualifier (type qual)
  (setq ibuffer-limiting-qualifiers
	(cons (cons type qual)
	      ibuffer-limiting-qualifiers)))

(defun ibuffer-remove-qualifier (type)
  (setq ibuffer-limiting-qualifiers
	(ibuffer-delete-alist type
			      ibuffer-limiting-qualifiers)))

(defun ibuffer-get-qualifier (type)
  (cdr (assq type ibuffer-limiting-qualifiers)))

(defun ibuffer-limit-by-mode (mode)
  "Toggle current view to buffers with major mode MODE.
To disable the limit, call this function again." 
  (interactive
   (cons 
    (if (ibuffer-get-qualifier 'mode)
	nil
      (intern
       (completing-read "Limit by major mode: " obarray
			(function
			 (lambda (e)
			   (string-match "-mode$"
					 (symbol-name e))))
			t)))
    nil))
  (cond (mode
	 (ibuffer-add-qualifier 'mode mode)
	 (message "View limited by major mode: %s" mode))
	(t
	 (ibuffer-remove-qualifier 'mode)
	 (message "Limiting by major mode disabled.")))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-limit-by-name (regexp)
  "Toggle current view to buffers with name matching REGEXP.
To disable the limit, call this function again."
  (interactive (cons (if (ibuffer-get-qualifier 'name)
			 nil
		       (read-from-minibuffer "Limit by name (regexp): "))
		     nil))
  (cond (regexp
	 (ibuffer-add-qualifier 'name regexp)
	 (message "View limited by buffer name: %s" regexp))
	(t
	 (ibuffer-remove-qualifier 'name)
	 (message "Limiting by buffer name disabled.")))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-limit-by-filename (regexp)
  "Toggle current view to buffers with filename matching REGEXP.
To disable the limit, call this function again."
  (interactive (cons (if (ibuffer-get-qualifier 'filename)
			 nil
		       (read-from-minibuffer "Limit by filename (regexp): "))
		     nil))
  (cond (regexp
	 (ibuffer-add-qualifier 'filename regexp)
	 (message "View limited by file name: %s" regexp))
	(t
	 (ibuffer-remove-qualifier 'filename)
	 (message "Limiting by file name disabled.")))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-limit-by-size-gt (size)
  "Toggle current view to buffers with size greater than SIZE.
To disable the limit, call this function again."
  (interactive (cons (if (ibuffer-get-qualifier 'size-gt)
			 nil
		       (string-to-number
			(read-from-minibuffer "Limit by size greater than: ")))
		     nil))
  (cond (size
	 (ibuffer-add-qualifier 'size-gt size)
	 (message "View limited by size greater than: %s" size))
	(t
	 (let ((cursize (ibuffer-get-qualifier 'size-gt)))
	   (ibuffer-remove-qualifier 'size-gt)
	   (message "Limiting by size greater than %s disabled." cursize))))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-limit-by-size-lt (size)
  "Toggle current view to buffers with size less than SIZE.  
To disable the limit, call this function again."
  (interactive (cons (if (ibuffer-get-qualifier 'size-lt)
			 nil
		       (string-to-number
			(read-from-minibuffer "Limit by size less than: ")))
		     nil))
  (cond (size
	 (ibuffer-add-qualifier 'size-lt size)
	 (message "View limited by size less than: %s" size))
	(t
	 (let ((cursize (ibuffer-get-qualifier 'size-lt)))
	   (ibuffer-remove-qualifier 'size-lt)
	   (message "Limiting by size less than %s disabled." cursize))))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-limit-by-content (regexp)
  "Toggle current view to buffers whose contents match REGEXP.
To disable the limit, call this function again."
  (interactive (cons (if (ibuffer-get-qualifier 'content)
			 nil
		       (read-from-minibuffer "Limit by content (regexp): "))
		     nil))
  (cond (regexp
	 (ibuffer-add-qualifier 'content regexp)
	 (message "View limited by content: %s" regexp))
	(t
	 (ibuffer-remove-qualifier 'content)
	 (message "Limiting by content disabled.")))
  (ibuffer-update-mode-name)
  (ibuffer-update nil t))

(defun ibuffer-toggle-sorting-mode ()
  "Toggle the current sorting mode.
Possible sorting modes are:
 Recency - the last time the buffer was viewed
 Name - the name of the buffer
 Major Mode - the name of the major mode of the buffer
 Size - the size of the buffer" 
  (interactive)
  (let* ((keys (mapcar #'car ibuffer-sorting-functions-alist))
	 (entry (memq ibuffer-sorting-mode keys))
	 (next (or (cadr entry) (car keys)))
	 (nextentry (assq next ibuffer-sorting-functions-alist)))
    (if (and entry nextentry)
	(progn
	  (setq ibuffer-sorting-mode next)
	  (message "Sorting by %s." (cadr nextentry)))
      (progn
	(setq ibuffer-sorting-mode 'recency)
	(message "Sorting by last view time."))))
  (ibuffer-redisplay t))

(defun ibuffer-invert-sorting ()
  "Toggle whether or not sorting is in reverse order."
  (interactive)
  (setq ibuffer-sorting-reversep (not ibuffer-sorting-reversep))
  (message "Sorting order %s."
	   (if ibuffer-sorting-reversep
	       "reversed"
	     "normal"))
  (ibuffer-redisplay t))

(defun ibuffer-update-format ()
  (interactive)
  (setq ibuffer-line-format-form
	(byte-compile
	 (nconc (list
		 'lambda '()
		 (ibuffer-parse-format ibuffer-line-format
				       ibuffer-line-format-alist t))))))


(defun ibuffer-redisplay (&optional silent)
  "Redisplay the current list of buffers.
Do not generate progress messages if SILENT is non-`nil'."
  (interactive)
  (unless silent
    (message "Redisplaying current buffer list..."))
  (let ((blist (ibuffer-filter-by-limits
		(ibuffer-canonicalize-state-list
		 (ibuffer-current-state-list)))))
    (when (null blist)
      (if ibuffer-limiting-qualifiers
	  (message "No buffers! (note: limiting in effect)")
	(error "No buffers!")))
    (ibuffer-insert-buffers-and-marks blist t)
    (unless silent
      (message "Redisplaying current buffer list...done"))))
  
(defun ibuffer-update (arg &optional silent)
  "Regenerate the list of all buffers.
Display buffers whose name begins with a space if and only if prefix
arg ARG is non-nil.
Do not display messages if SILENT is non-`nil'."
  (interactive "P")
  (let ((blist (ibuffer-filter-by-limits
		(ibuffer-current-buffers-with-marks))))
    (when (null blist)
      (if ibuffer-limiting-qualifiers
	  (message "No buffers! (note: limiting in effect)")
	(error "No buffers!")))
    (unless silent
      (message "Updating buffer list..."))
    (ibuffer-insert-buffers-and-marks blist
				      arg)
    (unless silent
      (message "Updating buffer list...done")))
  (goto-char (point-min)))

(defun ibuffer-insert-buffers-and-marks (bmarklist &optional all)
  ;; BMARKLIST should be a list of (BUFFER MARK)
  (setq bmarklist
	;; filter out unwanted buffers
	(delq nil
	      (mapcar #'(lambda (e)
			  (when (and (or all
					 (not (string-match "^ "
							    (buffer-name
							     (car e)))))
				     (or ibuffer-view-ibuffer
					 (not (eq (current-buffer)
						  (car e)))))
			    e))
		      bmarklist)))
  (let ((pt (point)))
    (unwind-protect
	(progn
	  (setq buffer-read-only nil)
	  (erase-buffer)
	  (or ibuffer-line-format-form
	      (ibuffer-update-format))
	  (mapcar
	   ;; insert the buffers
	   (function (lambda (entry)
		       (let ((buf (car entry))
			     (mark (cadr entry)))
			 (ibuffer-insert-buffer-line buf mark))))
	   (let* ((sortdat (assq ibuffer-sorting-mode
				 ibuffer-sorting-functions-alist))
		  (func (caddr sortdat)))
	     (let ((result
		    ;; actually sort the buffers
		    (if (and sortdat func)
			(sort bmarklist func)
		      bmarklist)))
	       ;; perhaps reverse the sorted buffer list
	       (if ibuffer-sorting-reversep
		   result
		 (nreverse result))))))
      (setq buffer-read-only t)		
      (goto-char pt))))

(defun ibuffer-quit ()
  "Quit this `ibuffer' session.
Delete the current window iff `ibuffer-delete-window-on-quit' is non-nil."
  (interactive)
  (if ibuffer-delete-window-on-quit
      (progn
	(bury-buffer)
	(unless (= (count-windows) 1)
	  (delete-window)))
    (bury-buffer)))

(defun ibuffer-other-window ()
  "Begin using `ibuffer' to edit a list of buffers in another window.
Type 'h' after entering ibuffer for more information."
  (interactive)
  (ibuffer t))

(defun ibuffer (&optional other-window-p)
  "Begin using `ibuffer' to edit a list of buffers.
Type 'h' after entering ibuffer for more information.

Optional argument POP says to use another window."
  (interactive "P")
  (if other-window-p
      (pop-to-buffer (get-buffer-create "*Ibuffer*"))
    (switch-to-buffer (get-buffer-create "*Ibuffer*")))
  (unless (eq major-mode 'ibuffer-mode)
    (ibuffer-mode))
  (setq ibuffer-delete-window-on-quit other-window-p)
  (ibuffer-update nil)
  (run-hooks 'ibuffer-hooks)
  (unless ibuffer-expert
    (message "Commands: m, u, t, RET, g, k, S, D, Q; q to quit; h for help")))
  
(defun ibuffer-mode ()
  "A major mode for viewing a list of buffers.
In ibuffer, you can conveniently perform many operations on the
currently open buffers.

Here is a short summary of keybindings.  An exhaustive summary follows
below.

Simple commands include:
 '\\[ibuffer-mark-forward]' to mark a buffer for processing, and '\\[ibuffer-unmark-forward]' to unmark a buffer.
 '\\[ibuffer-do-save]' to save all the marked buffers.
 '\\[ibuffer-do-print]' to print all the marked buffers (using `print-buffer').
 '\\[ibuffer-do-delete]' to kill all the marked buffers.
 '\\[ibuffer-toggle-marks]' to toggle the mark state of each buffer.
 '\\[ibuffer-redisplay]' to refresh the current list of buffers.
 '\\[ibuffer-update]' to regenerate the list of buffers.
 '\\[ibuffer-toggle-sorting-mode]' to toggle the sorting mode.
 '\\[ibuffer-do-kill-lines]' to hide marked lines (doesn't kill the buffer) 

More complex commands include:
 '\\[ibuffer-do-sort-by-recency]' to sort the buffers by last view time.
 '\\[ibuffer-do-sort-by-size]' to sort the buffers by size.
 '\\[ibuffer-mark-by-name-regexp]' to mark buffers by their name,
         using a regular expression.
 '\\[ibuffer-mark-by-file-name-regexp]' to mark buffers by their filename,
         using a regular expression.
 '\\[ibuffer-mark-modified-buffers]' to mark modified buffers.
 '\\[ibuffer-mark-dired-buffers] to mark Dired buffers.

Limiting:

 You can limit your ibuffer view to a selection of the buffers, via
different critera.  For example, suppose you are working on an Emacs
Lisp project.  You can create an Ibuffer buffer which is limited to
just `emacs-lisp' modes via '\\[ibuffer-limit-by-mode]
emacs-lisp-mode RET'.

To undo a limit, type the limit keybinding again.  For instance, you
can undo the limit in the example above by typing '\\[ibuffer-limit-by-mode]' again.

You can even combine limits: Suppose you only want to see buffers in
`emacs-lisp' mode, whose names begin with \"gnus\".  You can
accomplish this via: '\\[ibuffer-limit-by-mode] emacs-lisp-mode RET
                      \\[ibuffer-limit-by-name] ^gnus RET'.

If you wish to disable all limiting currently in effect, use
  '\\[ibuffer-limit-disable]'.

Operations on marked buffers:

  '\\[ibuffer-do-save]' - Save the marked buffers
  '\\[ibuffer-do-view]' - View the marked buffers in this frame.
  '\\[ibuffer-do-view-other-frame]' - View the marked buffers in another frame.
  '\\[ibuffer-do-revert]' - Revert the marked buffers.
  '\\[ibuffer-do-delete]' - Kill the marked buffers.
  '\\[ibuffer-do-query-replace]' - Query replace in each of the marked buffers. 
  '\\[ibuffer-do-query-replace-regexp]' - As above, with a regular expression.
  '\\[ibuffer-do-print]' - Print the marked buffers.
  '\\[ibuffer-do-shell-command]' - Run a shell command on the contents of
          the marked buffers.
  '\\[ibuffer-do-shell-command-replace]' - Replace the contents of the marked
          buffers with the output of a shell command.  
  '\\[ibuffer-do-eval]' - Evaluate a form in each of the marked buffers.  This
          is a very flexible command.  For example, if you want to make all
          of the marked buffers read only, try using (toggle-read-only 1) as
          the input form.
  '\\[ibuffer-do-view-and-eval]' - As above, but view each buffer while the form
          is evaluated.
  '\\[ibuffer-do-kill-lines]' - Remove the marked lines from the *Ibuffer* buffer,
          but don't kill the associated buffer.
  '\\[ibuffer-do-kill-on-deletion-marks]' - Kill all buffers marked for deletion.

Marking commands:

  '\\[ibuffer-mark-forward]' - Mark the buffer at point.
  '\\[ibuffer-toggle-marks]' - Unmark all currently marked buffers, and mark
          all unmarked buffers.
  '\\[ibuffer-unmark-forward]' - Unmark the buffer at point.
  '\\[ibuffer-unmark-backward]' - Unmark the buffer at point, and move to the
          previous line.
  '\\[ibuffer-unmark-all]' - Unmark all marked buffers.
  '\\[ibuffer-mark-by-mode]' - Mark buffers by major mode.
  '\\[ibuffer-mark-modified-buffers]' - Mark all modified buffers.
  '\\[ibuffer-mark-special-buffers]' - Mark all buffers whose name begins and
          ends with '*'.
  '\\[ibuffer-mark-read-only-buffers]' - Mark all read-only buffers.
  '\\[ibuffer-mark-dired-buffers]' - Mark buffers in `dired' mode.
  '\\[ibuffer-mark-help-buffers]' - Mark buffers in `help-mode', `apropos-mode', etc.
  '\\[ibuffer-mark-old-buffers]' - Mark buffers older than `ibuffer-old-time'.
  '\\[ibuffer-mark-for-delete]' - Mark the buffer at point for deletion.
  '\\[ibuffer-mark-by-name-regexp]' - Mark buffers by their name, using a regexp.
  '\\[ibuffer-mark-by-mode-regexp]' - Mark buffers by their major mode, using a regexp.
  '\\[ibuffer-mark-by-file-name-regexp]' - Mark buffers by their filename, using a regexp.

Limiting commands:

  '\\[ibuffer-limit-by-mode]' - Limit the view by major mode.
  '\\[ibuffer-limit-by-name]' - Limit the view by buffer name.
  '\\[ibuffer-limit-by-content]' - Limit the view by buffer content.
  '\\[ibuffer-limit-by-filename]' - Limit the view by filename.
  '\\[ibuffer-limit-by-size-gt]' - Limit the view by buffer size.
  '\\[ibuffer-limit-by-size-lt]' - Limit the view by buffer size.
  '\\[ibuffer-limit-disable]' - Remove all limiting currently in effect.
    
Sorting commands:

  '\\[ibuffer-toggle-sorting-mode]' - Rotate between the various sorting modes.
  '\\[ibuffer-invert-sorting]' - Reverse the current sorting order.
  '\\[ibuffer-do-sort-by-alphabetic]' - Sort the buffers lexicographically.
  '\\[ibuffer-do-sort-by-recency]' - Sort the buffers by last viewing time.
  '\\[ibuffer-do-sort-by-size]' - Sort the buffers by size.
  '\\[ibuffer-do-sort-by-major-mode]' - Sort the buffers by major mode.

Other commands:

  '\\[forward-line]' - Move point to the next line. 
  '\\[previous-line]' - Move point to the previous line.
  '\\[ibuffer-redisplay]' - Redisplay the current buffer list.
  '\\[ibuffer-update]' - As above, but add new buffers to the list.
  '\\[ibuffer-quit]' - Bury the Ibuffer buffer.
  '\\[describe-mode]' - This help.
  '\\[ibuffer-diff-with-file]' - View the differences between this buffer
          and its associated file.
  '\\[ibuffer-visit-buffer]' - View the buffer on this line.
  '\\[ibuffer-visit-buffer-other-window]' - As above, but in another window.
  '\\[ibuffer-visit-buffer-other-window-noselect]' - As both above, but don't select
          the new window."
  (interactive)
  (kill-all-local-variables)
  (use-local-map ibuffer-mode-map)
  (setq major-mode 'ibuffer-mode)
  (setq mode-name "Ibuffer")
  (setq buffer-read-only t)
  (buffer-disable-undo)
  (setq truncate-lines t)
  (set (make-local-variable 'ibuffer-sorting-mode)
       ibuffer-default-sorting-mode)
  (set (make-local-variable 'ibuffer-sorting-reversep)
       ibuffer-default-sorting-reversep)
  (set (make-local-variable 'ibuffer-limiting-qualifiers) nil)
  (set (make-local-variable 'ibuffer-delete-window-on-quit) nil)  
  (easy-menu-add ibuffer-mode-operate-menu)
  (easy-menu-add ibuffer-mode-mark-menu)
  (easy-menu-add ibuffer-mode-regexp-menu)
  (easy-menu-add ibuffer-mode-immediate-menu)  
  (easy-menu-add ibuffer-mode-sort-menu)
  (easy-menu-add ibuffer-mode-limit-menu)  
  (define-key ibuffer-mode-map [menu-bar edit] 'undefined)
  (ibuffer-update-format)
  (run-hooks 'ibuffer-mode-hooks)
  ;; called after mode hooks to allow the user to add limits
  (ibuffer-update-mode-name))

(provide 'ibuffer)

;; Local Variables:
;; coding: iso-8859-1
;; End:

;;; ibuffer.el ends here
    