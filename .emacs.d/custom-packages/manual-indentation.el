;; -*- lexical-binding: t -*-

;; For someone tired of Emacs' indentation system.
;; It sucks. I hate it.

(defvar-local mi/tab-width 4)
(defvar mi/roast-mode nil)

(defun mi/msg (roast polite)
  (message (if mi/roast-mode roast polite)))

(defun mi/delete-char-or-dedent ()
  (interactive)
  (cond
   ((use-region-p)
    (delete-region (region-beginning) (region-end)))
   ((let ((col (current-column)))
      (and (<= col (current-indentation))
           (>= col mi/tab-width)
           (= (% col mi/tab-width) 0)))
    (delete-char (- mi/tab-width)))
   (t
    (delete-char -1))))

(defun mi/insert-newline-and-indent ()
  (interactive)
  (let ((col (current-indentation)))
    (if (save-excursion (beginning-of-line) (looking-at-p "[[:space:]]*$"))
        (delete-region (line-beginning-position) (line-end-position)))
    (newline)
    (indent-to col)))

(defun mi/indent-rigidly-keep-region (beg end amount)
  (let ((beg-marker (copy-marker beg nil))
        (end-marker (copy-marker end t)))
    (indent-rigidly beg-marker end-marker amount)
    (setq deactivate-mark nil)
    (goto-char end-marker)
    (set-mark beg-marker)
    (exchange-point-and-mark)
    (set-marker beg-marker nil)
    (set-marker end-marker nil)))

(defun mi/insert-tab-or-indent-region ()
  (interactive)
  (if (use-region-p)
      (mi/indent-rigidly-keep-region (region-beginning) (region-end) mi/tab-width)
    (insert (make-string mi/tab-width ?\s))))

(defun mi/dedent-region ()
  (interactive)
  (if (use-region-p)
      (mi/indent-rigidly-keep-region (region-beginning) (region-end) (- mi/tab-width))
    (mi/msg
     "Are you dumb? Select a region!"
     "No region selected.")))

(setq-default tab-always-indent nil)
(electric-indent-mode -1)
(add-hook 'prog-mode-hook
           (lambda ()
             (setq-local indent-line-function 'ignore)
             (setq-local indent-tabs-mode nil)))

(provide 'manual-indentation)
