#|
  This file is a part of cons-pool project.
|#

(in-package :cl-user)
(defpackage cons-pool-test-asd
  (:use :cl :asdf))
(in-package :cons-pool-test-asd)

(defsystem cons-pool-test
  :author ""
  :license ""
  :depends-on (:cons-pool
               :cl-test-more
	       :alexandria)
  :components ((:module "t"
                :components
                ((:file "cons-pool"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
