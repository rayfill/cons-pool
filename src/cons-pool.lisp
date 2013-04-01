(in-package :cl-user)
(defpackage cons-pool
  (:use :cl)
  (:import-from :sb-ext :atomic-update)
  (:import-from :kmrcl :with-gensyms)
  (:export :release :alloc))
(in-package :cons-pool)

(defvar *pool* nil)

(defmacro release (cell place)
  (with-gensyms (cellsym)
    `(let ((,cellsym ,cell))
       (atomic-update ,place (lambda (pool)
			       (rplacd ,cellsym pool))))))

(defmacro alloc (place &optional new-alloc)
  `(let (result)
     (atomic-update ,place
		    (lambda (pool)
		      (setf result pool)
		      (cdr pool)))
     (when result
       (setf (cdr result) nil))
     (or result (and ,new-alloc (cons nil nil)))))
