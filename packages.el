;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;;(package! lsp-mode :pin "aa6c5f943c691952c78ad0ce659e4626ca942fdc")
(package! rg)
;;(package! ormolu)
(package! persistent-soft)
(package! ellama)
(package! just-mode)
(package! justl)
(package! lsp-biome
  :recipe `(:host github :repo "cxa/lsp-biome"))
(package! claude-code-ide
  :recipe `(:host github :repo "manzaltu/claude-code-ide.el"))

(when (file-exists-p! "packages-local.el" doom-user-dir)
  (load! "packages-local.el" doom-user-dir))
