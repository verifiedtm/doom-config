;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! rg)
(package! ormolu)
(package! persistent-soft)
(package! ellama)
(package! just-mode)
(package! justl)
(package! lsp-biome :recipe `(:host github :repo "cxa/lsp-biome"))

(when (file-exists-p! "packages-local.el" doom-user-dir)
  (load! "packages-local.el" doom-user-dir))
