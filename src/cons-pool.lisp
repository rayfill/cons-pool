(in-package :cl-user)
(defpackage cons-pool
  (:use :cl)
  (:import-from :sb-ext :atomic-update)
  (:export :release :alloc))
(in-package :cons-pool)

(defvar *pool* nil)

(defun release (cell)
  (atomic-update (symbol-value '*pool*) (lambda (pool)
					  (rplacd cell pool))))

(defun alloc (&optional new-alloc)
  (let (result)
    (atomic-update (symbol-value '*pool*)
		   (lambda (pool)
		     (setf result pool)
		     (cdr pool)))
    (when result
      (setf ;(car result) nil
	    (cdr result) nil))
    (or result (and new-alloc (cons nil nil)))))