#|
  This file is a part of cons-pool project.
|#

(in-package :cl-user)
(defpackage cons-pool-asd
  (:use :cl :asdf))
(in-package :cons-pool-asd)

(defsystem cons-pool
  :version "0.1"
  :author ""
  :license ""
  :depends-on (:kmrcl)
  :components ((:module "src"
                :components
                ((:file "cons-pool"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (load-op cons-pool-test))))
