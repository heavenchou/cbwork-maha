;; psgml-xpointer.el -- generate XPointers for element in XML and SGML docs.

;; Copyright (c) 1998 Megginson Technologies Ltd.

;; Author: David Megginson (david@megginson.com)

;; $Id: psgml-xpointer.el,v 1.1.1.1 2003/05/05 04:07:02 ray Exp $

;; Modified by Christian Wittern Feb 2001
;;last changed: Time-stamp: <2001-02-20 21:36:48 chris>



;;; Commentary:

;; This file includes a single user-level command for generating an
;; XPointer to a single element in an XML or SGML document (by
;; default, the element containing point).  You must be using Lennart
;; Staflin's PSGML mode (optionally with XML patches).  To obtain an
;; XPointer for the current point in a document, issue the following
;; command (which may be bound to a key sequence for convenience):
;;
;; M-x sgml-xpointer
;;
;; The program will climb the element tree until it finds an element
;; with an ID attribute, then will use child() statements to locate
;; the closest element that contains point.
;;
;; Installation:
;;
;; Put the following in one of your startup files:
;;
;; (autoload 'sgml-xpointer "psgml-xpointer" nil t)
;;

;;; Code:

(require 'psgml-parse)

;;;###autoload
(defun sgml-xpointer (loc)
  "Display an XPointer for the current point in an XML or SGML document.
The XPointer will appear in a temporary buffer."
  (interactive "d")
  (with-output-to-temp-buffer "*XPOINTER*"
    (progn
			(princ (concat "xpointer(" (sgml-xpointer-string (sgml-find-element-of loc)) ")"))
; 			(enlarge-window (- 5 (window-height)
; 												 )
; 											)
			)
		)
	)

(defun sgml-xpointer-string (el)
  "Return a string containing an XPointer for the element containing point.
The XPointer will begin with the nearest ancestor that possesses an ID
attribute, or with the document root if no ancestor has an ID."
  (cond ((= (sgml-element-level el) 0)
	 (error "XPointer Outside of document element!"))
	((= (sgml-element-level el) 1)
;	 "root"
	 (format "/%s" (sgml-element-gi el))
	 )
	((sgml-element-id el)
	 (format "id('%s')" (sgml-element-id el)))
	(t
	 (concat
	  (sgml-xpointer-string (sgml-element-parent el))
;	  (format ".child(%d,#element,'%s')"
		(let ((child-num (sgml-element-child-number el)))
				 (if (= child-num 1)
					(format "/%s"
								 (sgml-element-gi el)
								 )
					(format "/%s[%d]"
								 (sgml-element-gi el)
								 child-num
								 )
					))
		))))

(defun sgml-element-id (el)
  "Return the value of the ID attribute for this element, if any."
  (let ((id (sgml-attribute-with-declared-value
	     (sgml-element-attlist el) 'id)))
    (if id
	(sgml-element-attval el (sgml-attspec-name id))
      nil)))

(defun sgml-element-child-number (el)
  "Return the child number of the current element.
The child number counts only elements with the same GI."
  (let ((sibling (sgml-element-content (sgml-element-parent el)))
	(gi (sgml-element-gi el))
	(n 1))
    (while (not (equal sibling el))
      (if (equal gi (sgml-element-gi sibling))
	  (setq n (1+ n)))
      (setq sibling (sgml-element-next sibling)))
    n))

(provide 'psgml-xpointer)

;;; psgml-xpointer.el ends here.
