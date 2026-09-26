;; -*- lexical-binding: t -*-

;; Stupid Emacs force me to add docstrings.
;; Anyways self-explanatory.

(defgroup indent-dots nil
  "Customization group for indent-dots."
  :group 'convenience
  :prefix "indent-dots-")

(defcustom indent-dots-char ?·
  "Character used to represent indentation spaces."
  :type 'character
  :group 'indent-dots)

(defcustom indent-dots-face 'font-lock-comment-face
  "Face used to style the indentation dots."
  :type 'face
  :group 'indent-dots)

(defvar indent-dots--keywords nil)

(defun indent-dots--make-display (spaces)
  (let* ((len (length spaces))
         (dots (make-string len indent-dots-char)))
    (propertize dots 'face indent-dots-face)))

(defun indent-dots--matcher (limit)
  (when (re-search-forward "^\\( +\\)" limit t)
    (let* ((start (match-beginning 1))
           (end   (match-end 1))
           (spaces (buffer-substring-no-properties start end)))
      (put-text-property start end 'display
                         (indent-dots--make-display spaces))
      t)))

(defun indent-dots--remove ()
  (with-silent-modifications
    (remove-text-properties (point-min) (point-max) '(display nil))))

;;;###autoload
(define-minor-mode indent-dots-mode
  "Toggle indent-dots mode."
  :lighter " ·"  ;; A nice thing abt this is it kinda acts like a separator in the mode line
  :group 'indent-dots
  (if indent-dots-mode
      (progn
        (setq indent-dots--keywords
              `((indent-dots--matcher (0 nil))))
        (font-lock-add-keywords nil indent-dots--keywords t)
        (font-lock-flush))
    (font-lock-remove-keywords nil indent-dots--keywords)
    (indent-dots--remove)
    (font-lock-flush)))

;;;###autoload
(define-globalized-minor-mode global-indent-dots-mode
  indent-dots-mode
  (lambda () (when (derived-mode-p 'prog-mode)
               (indent-dots-mode 1))))

(provide 'indent-dots)
