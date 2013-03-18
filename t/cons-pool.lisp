(in-package :cl-user)
(defpackage cons-pool-test
  (:use :cl
        :cons-pool
        :cl-test-more)
  (:import-from :sb-thread :make-thread :join-thread
		:make-semaphore :try-semaphore :signal-semaphore :wait-on-semaphore)
  (:import-from :alexandria :flatten))
(in-package :cons-pool-test)

(plan nil)

(defvar *workers* nil)
(defvar *starter* (make-semaphore :count 1))
(try-semaphore *starter*)

(defun prepare-start ()
  (loop while (try-semaphore *starter*)))

(defun start (n)
  (signal-semaphore *starter* n))

(defun make-worker (work-item)
  (make-thread
   (lambda ()
     (wait-on-semaphore *starter*)
     (funcall work-item))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro save-env ((&rest specials) &rest body)
    (let ((syms (loop for i below (length specials) collect (gensym))))
      `(let ,syms
	 (unwind-protect
	      (psetf 
	       ,@(flatten (mapcar (lambda (sym special)
				    (list special sym))
				  syms specials)))
	   (progn
	     (psetf
	      ,@(flatten (mapcar (lambda (sym special)
				   (list sym special))
				 syms specials)))
	     ,@body))))))

;(save-env (*loop*) (+ 1 2))
       
(let* ((*random-state* (make-random-state t))
       (num (random 10000))
       (count (+ num 2000))
       (source (loop for i below count collect i)))

  (do ((cell source))
      ((null cell) nil)
    (setf cell (prog1 (cdr cell)
		 (release cell))))
  (is cons-pool::*pool* 
      (nreverse (loop for i below count collect i)))

  (save-env
   (cons-pool::*pool*)
   (setf cons-pool::*pool* (nreverse (loop for i below count collect i)))
   (is
    (let* ((thread-count (floor count 1000))
	   (threads
	    (loop for i below thread-count
	       collect (make-worker (lambda ()
				      (loop with allocated = 0
					 for m = (alloc)
					 while m
					 do (incf allocated)
					 finally (return allocated)))))))
      (start thread-count)
      (reduce #'+ (mapcar #'join-thread threads)))
    count)))


(finalize)
