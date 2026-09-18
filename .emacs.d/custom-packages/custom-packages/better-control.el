;; -*- lexical-binding: t -*-

;; Makes control easier.

(defalias 'bc/undo 'undo-only)
(defalias 'bc/redo 'undo-redo)

(defun bc/move-line-up ()
  (transpose-lines 1)
  (forward-line -2))

(defun bc/move-line-down ()
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(defun bc/move-region (start end n)
  (let ((region (delete-and-extract-region start end)))
    (forward-line n)
    (let ((new-start (point)))
      (insert region)
      (set-mark new-start)
      (goto-char (+ new-start (length region)))
      (setq deactivate-mark nil))))

(defun bc/move-line-or-region-up ()
  (interactive)
  (if (use-region-p)
      (bc/move-region (region-beginning) (region-end) -1)
    (bc/move-line-up)))

(defun bc/move-line-or-region-down ()
  (interactive)
  (if (use-region-p)
      (bc/move-region (region-beginning) (region-end) 1)
    (bc/move-line-down)))

(defun bc/delete-whole-line ()
  (interactive)
  (delete-region (line-beginning-position) (line-end-position))
  (delete-char 1))

(defun bc/mark-whole-line-text ()
  (interactive)
  (beginning-of-line-text)
  (set-mark-command nil)
  (end-of-line))

(defun bc/skip-same-char-backward (c)
  (while (and (not (bobp)) (eq (char-before) c))
    (backward-char 1)))

(defun bc/backward-text ()
  (interactive "^")
  (unless (bobp)
    (let ((c (char-before)))
      (cond
       ((memq c '(?- ?_))
        (skip-chars-backward "_-")
        (skip-chars-backward "[:alnum:]"))
       ((and (characterp c) (string-match-p "[[:alnum:]]" (string c)))
        (skip-chars-backward "[:alnum:]"))
       ((bolp)
        (backward-char 1))
       ((save-excursion (skip-chars-backward " \t") (bolp))
        (skip-chars-backward " \t"))
       (t
        (skip-chars-backward " \t")
        (unless (bobp)
          (let ((c2 (char-before)))
            (cond
             ((string-match-p "[[:alnum:]]" (string c2))
              (skip-chars-backward "[:alnum:]"))
             ((eq c2 ?.)
              (bc/skip-same-char-backward c2)
              (when (and (not (bobp))
                         (string-match-p "[[:alnum:]]" (string (char-before))))
                (skip-chars-backward "[:alnum:]")))
             (t
              (bc/skip-same-char-backward c2))))))))))

(defun bc/skip-same-char-forward (c)
  (while (and (not (eobp)) (eq (char-after) c))
    (forward-char 1)))

(defun bc/forward-text ()
  (interactive "^")
  (unless (eobp)
    (let ((c (char-after)))
      (cond
       ((memq c '(?- ?_))
        (skip-chars-forward "_-")
        (skip-chars-forward "[:alnum:]"))
       ((and (characterp c) (string-match-p "[[:alnum:]]" (string c)))
        (skip-chars-forward "[:alnum:]"))
       ((eolp)
        (forward-char 1))
       ((save-excursion (skip-chars-forward " \t") (eolp))
        (skip-chars-forward " \t"))
       (t
        (skip-chars-forward " \t")
        (unless (eobp)
          (let ((c2 (char-after)))
            (cond
             ((string-match-p "[[:alnum:]]" (string c2))
              (skip-chars-forward "[:alnum:]"))
             ((eq c2 ?.)
              (bc/skip-same-char-forward c2)
              (when (and (not (eobp))
                         (string-match-p "[[:alnum:]]" (string (char-after))))
                (skip-chars-forward "[:alnum:]")))
             (t
              (bc/skip-same-char-forward c2))))))))))

(defun bc/backward-delete-word ()
  (interactive)
  (delete-region (point) (progn (bc/backward-text) (point))))

(provide 'better-control)
