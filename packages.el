;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! rg)
(package! ormolu)
(package! prettier-js)
(package! persistent-soft)
(package! ellama)
(package! just-mode)

(when (file-exists-p! "packages-local.el" doom-user-dir)
  (load! "packages-local.el" doom-user-dir))
