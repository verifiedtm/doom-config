;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq display-line-numbers-type t)

(setq org-directory "~/org/")

(setq doom-font "New Heterodox Mono")

(setq-default tab-width 4
              indent-tabs-mode nil
              fill-column 100
              vc-handled-backends `(Git))

(add-hook! fundamental-mode 'flyspell-mode)
(add-hook! fundamental-mode 'turn-on-auto-fill)
(add-hook! fundamental-mode 'display-fill-column-indicator-mode)
(add-hook! markdown-mode 'turn-on-auto-fill)
(add-hook! org-mode 'turn-on-auto-fill)

(add-hook 'dired-after-readin-hook 'dired-git-info-auto-enable)

(defun haskell-company-backends ()
  (set (make-local-variable 'company-backends)
       (append '((company-capf company-dabbrev-code company-yasnippet)) company-backends)))

;; (set-formatter! 'fourmolu "fourmolu" :modes '(haskell-mode))

(setq haskell-stack-compile-command "stack build --test --bench --no-run-tests --no-run-benchmarks --ghc-options='-j4 +RTS -A256m -I0 -RTS -Wwarn' --no-interleaved-output"
      haskell-stack-test-command "stack build --test"
      lsp-haskell-server-path "haskell-language-server-wrapper"
      lsp-haskell-formatting-provider 'ormolu-format-buffer
      lsp-haskell-tactic-on nil
      lsp-haskell-check-project nil
      lsp-haskell-plugin-stan-global-on nil
      lsp-haskell-diagnostics-on-change nil)

(setq-hook! 'haskell-mode-hook
  compile-command haskell-stack-compile-command
  display-fill-column-indicator-column 100
  ormolu-process-path "fourmolu")

(add-hook! haskell-mode 'display-fill-column-indicator-mode)
(add-hook! haskell-mode 'ormolu-format-on-save-mode)
(add-hook! haskell-mode 'haskell-company-backends)
(add-hook! haskell-mode (set (make-local-variable 'compile-command)
                             haskell-stack-compile-command))

;; LSP
(after! lsp-mode
  (setq lsp-ui-sideline-enable nil
        lsp-ui-doc-enable nil
        lsp-ui-doc-max-height 30
        lsp-ui-doc-max-height 100
        lsp-enable-file-watchers nil
        lsp-enable-semantic-highlighting nil
        lsp-enable-semantic-tokens nil
        lsp-semantic-tokens-enable nil
        lsp-enable-symbol-highlighting nil
        lsp-haskell-plugin-stan-global-on nil
        lsp-haskell-plugin-tactics-global-on nil
        lsp-haskell-check-project nil
        lsp-before-save-edits nil))

(setq +format-on-save-enabled-modes
      '(not emacs-lisp-mode
        haskell-mode
        sql-mode
        yaml-mode
        sh-mode))

;; Ivy
(add-to-list 'completion-ignored-extensions ".hie")
(add-to-list 'completion-ignored-extensions ".stack-work")
(setq! ivy-case-fold-search t
       ivy-virtual-abbreviate 'full
       ivy-extra-directories nil
       counsel-find-file-ignore-regexp (concat (regexp-opt completion-ignored-extensions) "\\'"))

;; Smudge
;; (after! smudge
;;   (setq! smudge-oauth2-client-secret "")
;;   (setq! smudge-oauth2-client-id "")
;;   (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)
;;   (setq! smudge-transport 'connect))

;; Slack
;; (setq! slack-prefer-current-team t)
;; (setq! slack-buffer-emojify t)

;; Secrets
(when (file-exists-p! "secrets.el" doom-user-dir)
  (load! "secrets.el" doom-user-dir))

;; (require 'org-table)
;; (defun md-table-align ()
;;   (interactive)
;;   (org-table-align)
;;   (save-excursion
;;     (goto-char (point-min))
;;     (while (search-forward "-+-" nil t) (replace-match "-|-"))))


(after! projectile
  (projectile-register-project-type 'haskell-stack '("stack.yaml")
                                    :compile haskell-stack-compile-command
                                    :test haskell-stack-test-command)
  )

(set-eshell-alias! "shake" "stack exec shake --")

;; (add-hook! rjsx-mode 'prettier-js-mode)

(put 'haskell-hoogle-command 'safe-local-variable #'stringp)
(put 'haskell-hoogle-server-command 'safe-local-variable (lambda (_) t))

(map! :leader (:prefix ("s" . "search") :desc "Rg" "g" #'rg))

(use-package! ellama
  :defer t
  :init
  (setopt ellama-language "English")
  (require 'llm-ollama)
  (setopt ellama-provider
          (make-llm-ollama
           :chat-model "deepseek-r1"
           :embedding-model "deepseek-r1")))

(use-package! lsp-biome
  :config (setq lsp-biome-format-on-save t))

(defun zz/file-exists-p (filepath)
  "Determine if a given file exists returning the FILEPATH if it does."
  (when (file-exists-p filepath)
    filepath))

(defun zz/is-haskell-package-p (dir)
  "Determine if the given DIR is a haskell package directory.
Returns the full path to the detected Haskell package file."
  (let ((hs-files '("package.yaml" "*.cabal" "cabal.project" "stack.yaml")))
    (-any (lambda (x)
            (or (zz/file-exists-p (concat dir x))
                (-any 'zz/file-exists-p (file-expand-wildcards (concat dir x)))))
          hs-files)))

(defun zz/is-package-dir (dir)
  "Determine if the given DIR refers to a package.
Returns the full path to the detected package file.
Useful to use when `locate-dominating-file'."
  ;; TODO Should be refactored so we have a mapping from 'major-mode -> package-file-list'
  (cond ((derived-mode-p 'haskell-mode 'haskell-cabal-mode) (zz/is-haskell-package-p dir))
        ((derived-mode-p 'clojure-mode) (zz/is-clojure-package-p dir))
        (t (message (concat "Finding package for " (symbol-name major-mode) " is not supported!"))
           nil)))

(defun zz/projectile-package-dir ()
  "Open closest package directory found upwards starting from `default-directory'."
  (interactive)
  (let ((package-dir (projectile-locate-dominating-file default-directory #'zz/is-package-dir)))
    (when package-dir (dired package-dir))))

(defun zz/projectile-package-file ()
  "Open closest package file found upwards starting from `default-directory'."
  (interactive)
  (let ((package-dir (projectile-locate-dominating-file default-directory #'zz/is-package-dir)))
    (when package-dir
      (find-file (zz/is-package-dir package-dir)))))

(after! projectile
  (map! :localleader :desc "Package description file" :nv "," #'zz/projectile-package-file))
