;; -*- lexical-binding: t -*-

;; Optimize stuff
;; (benchmark-init/activate)
(setq gc-cons-threshold (* 100 1024 1024))

;; MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install and load packages
(defun load-packages (&rest packages)
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))    ;; Refresh repositories if not fetched
  (dolist (pkg packages)
    (unless (package-installed-p pkg)
      (package-install pkg))
    (require pkg)))

;; Settings
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(cua-mode 1)    ;; For C-c, C-v,...
(electric-pair-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(fido-mode 1)    ;; Autocomplete in minibuffer
(blink-cursor-mode -1)
(column-number-mode 1)

;; Change the welcome message
(defun display-startup-echo-area-message ()
  (message "If it works, don't touch it."))

;; Fonts
(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font Mono-10"))

;; Required packages for this config
(load-packages 'company
               'all-the-icons
               'multiple-cursors
               'ligature
               'eldoc-box
               'yasnippet
               'kotlin-ts-mode
               'hl-todo
               'zig-mode
               'go-mode
               'nerd-icons-dired
               'nord-theme
               'magit)

(add-to-list 'load-path "~/.emacs.d/custom-packages/")    ;; Custom packages live here

;; https://github.com/rexim/simpc-mode
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))

;; https://github.com/harrybournis/emacs-pets
(add-to-list 'load-path "~/.emacs.d/custom-packages/emacs-pets/")
(add-to-list 'load-path "~/.emacs.d/custom-packages/emacs-pets/pets/duck/")
(require 'emacs-pets)
(setq emacs-pets-scale 0.9)
(emacs-pets-mode)

;; indent-dots (custom package)
(require 'indent-dots)    ;; Show indentation as dots
(add-hook 'prog-mode-hook 'indent-dots-mode)

;; company
(add-hook 'after-init-hook 'global-company-mode)
(with-eval-after-load 'company
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map (kbd "<escape>") 'company-abort))
(add-hook 'simpc-mode-hook (lambda ()
                             (setq-local company-backends
                                         '((company-capf company-yasnippet)))))

;; ligature
(ligature-set-ligatures 'prog-mode
                        '("==" "!=" "<=" ">=" "->" "=>" "&&" "||" "::" "++" "--" "<-"))
(global-ligature-mode t)

;; eglot
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(simpc-mode . ("clangd" "--background-index" "--header-insertion=never")))
  (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-stay-out-of 'company-backends)
  (add-to-list 'eglot-stay-out-of 'flymake)
  (add-hook 'zig-mode-hook
            (lambda ()
              (add-to-list 'eglot-ignored-server-capabilities :documentFormattingProvider)
              (add-to-list 'eglot-ignored-server-capabilities :documentRangeFormattingProvider)))

  (add-hook 'go-mode-hook
            (lambda ()
              (add-to-list 'eglot-ignored-server-capabilities :documentFormattingProvider)
              (add-to-list 'eglot-ignored-server-capabilities :documentRangeFormattingProvider))))

;; Disable flymake + set up eldoc
(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (flymake-mode -1)
            (eldoc-box-hover-at-point-mode)
            (eglot-inlay-hints-mode -1)))

;; eglot hooks
(add-hook 'simpc-mode-hook 'eglot-ensure)
(add-hook 'python-mode-hook 'eglot-ensure)
(add-hook 'zig-mode-hook 'eglot-ensure)
(add-hook 'go-mode-hook 'eglot-ensure)

;; Fixing pyright
(setq-default eglot-workspace-configuration
              '(:python (:pythonPath "/home/tr43212/.venv/bin/python")
                        :pyright (:analysis (:diagnosticMode "openFilesOnly"
                                                             :autoSearchPaths t
                                                             :useLibraryCodeForTypes t))))

;; manual-indentation.el (custom package)
;; Provides mi/*
(require 'manual-indentation)

;; Tab width
(setq mi/tab-width 4)
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq mi/tab-width 2)))

;; Support for Kotlin
(setq treesit-language-source-alist
      '((kotlin "https://github.com/fwcd/tree-sitter-kotlin")))
(add-to-list 'auto-mode-alist '("\\.kts?\\'" . kotlin-ts-mode))

;; better-control.el (custom package)
;; Provides bc/*
(require 'better-control)

;; buffer-life.el (custom package)
(require 'buffer-life)

;; yasnippet
(yas-global-mode 1)

;; hl-todo
(global-hl-todo-mode 1)

;; Variables stuff
(setq-default indent-tabs-mode nil)
(setq-default cursor-type '(hbar . 1))

;; Dired
(add-hook 'dired-mode-hook
          (lambda ()
            (auto-revert-mode)
            (nerd-icons-dired-mode)))

;; Auto use hexl for binary files
(defun detect-binary-file ()
  (unless (derived-mode-p 'hexl-mode)
    (save-excursion
      (goto-char (point-min))
      (when (search-forward "\0" (min (+ (point-min) 1024) (point-max)) t)
        (hexl-mode)))))
(add-hook 'find-file-hook 'detect-binary-file)

(setq custom-file "~/.emacs.d/custom.el")
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t)))
(setq lock-file-name-transforms '((".*" "~/.emacs.d/auto-saves/" t)))
(setq echo-keystrokes 0.01)
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)
(setq inhibit-startup-screen t)
(setq eglot-autoshutdown t)
(setq use-short-answers t)
(setq eglot-connect-timeout 600)
(setq eglot-sync-connect 0)
(setq eglot-max-file-watches 20000)
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-listing-switches "-ahgo --group-directories-first")
(setq warning-minimum-level :error)
(setq eldoc-box-max-pixel-width 600)
(setq eldoc-box-max-pixel-height 400)
(setq global-auto-revert-mode-non-file-buffer t)
(setq auto-revert-verbose t)
(setq zig-format-on-save nil)
(setq tab-width 4)
(setq mi/roast-mode t)

;; comint for compile
(defun compile-with-comint ()
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively 'compile)))

;; Disable annoying keys
(global-unset-key (kbd "M-<down-mouse-1>"))
(global-unset-key (kbd "M-<mouse-1>"))
(global-unset-key (kbd "C-<down-mouse-1>"))
(global-unset-key (kbd "C-<mouse-1>"))
(global-unset-key (kbd "C-x C-z"))
(global-unset-key (kbd "C-<return>"))

;; Keybinds
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "C-w") 'delete-window)
(global-set-key (kbd "C-b") 'eval-buffer)
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
(global-set-key (kbd "S-<left>") 'windmove-left)
(global-set-key (kbd "S-<right>") 'windmove-right)
(global-set-key (kbd "C-S-w") 'kill-current-buffer)
(global-set-key (kbd "C-/") 'replace-regexp)
(global-set-key (kbd "C-z") 'bc/undo)
(global-set-key (kbd "C-S-z") 'bc/redo)
(global-set-key (kbd "C-<tab>") 'indent-region)
(global-set-key (kbd "C-s") 'isearch-forward)
(global-set-key (kbd "M-<left>") 'backward-char)    ;; This is required for shift-selection to works
(global-set-key (kbd "M-<right>") 'forward-char)
(global-set-key (kbd "C-c c") 'compile-with-comint)

;; Sometime my hand slips
(global-set-key (kbd "C-x s") 'save-buffer)
(global-set-key (kbd "C-c <mouse-1>") 'kill-ring-save)

;; fido-mode
(define-key icomplete-fido-mode-map (kbd "<tab>") 'icomplete-force-complete)

;; Dired
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "w") 'wdired-change-to-wdired-mode)
  (define-key dired-mode-map (kbd "r") 'dired-do-rename)
  (define-key dired-mode-map (kbd "d") 'dired-do-delete))

;; WDired
(with-eval-after-load 'wdired
  (define-key wdired-mode-map (kbd "C-g") 'wdired-abort-changes)
  (define-key wdired-mode-map (kbd "C-x C-g") 'wdired-abort-changes))

;; better-control
(global-set-key (kbd "M-<up>") 'bc/move-line-or-region-up)
(global-set-key (kbd "M-<down>") 'bc/move-line-or-region-down)
(global-set-key (kbd "C-S-a") 'bc/mark-whole-line-text)
(global-set-key (kbd "C-<delete>") 'bc/delete-whole-line)
(global-set-key (kbd "C-<backspace>") 'bc/backward-delete-word)
(global-set-key (kbd "C-<left>") 'bc/backward-text)
(global-set-key (kbd "C-<right>") 'bc/forward-text)

;; multiple-cursors
(global-set-key (kbd "M-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)

;; manual-indentation
(global-set-key (kbd "<tab>") 'mi/insert-tab-or-indent-region)
(global-set-key (kbd "<backtab>") 'mi/dedent-region)
(add-hook 'prog-mode-hook    ;; Required to not call these in the minibuffer
          (lambda ()
            (local-set-key (kbd "<backspace>") 'mi/delete-char-or-dedent)
            (local-set-key (kbd "<return>") 'mi/insert-newline-and-indent)))

(load custom-file)

;; Restore GC threshold
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))
(put 'downcase-region 'disabled nil)
