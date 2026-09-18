;; -*- lexical-binding: t; -*-

(defvar-local bl/--birthday nil)
(defvar bl/--timer nil)

(defvar bl/tracked-despite-being-system-buffers '("*scratch*" "*compilation*"))

(defun bl/--system-buffer-p (buffer)
  (let ((name (buffer-name buffer)))
    (and name
         (not (member name bl/tracked-despite-being-system-buffers))
         (or (string-prefix-p " " name)
             (string-match-p "\\`\\*.*\\*\\'" name)))))

(defun bl/--mark-buffer (&optional buffer)
  (let ((buffer (or buffer (current-buffer))))
    (unless (bl/--system-buffer-p buffer)
      (with-current-buffer buffer
        (unless bl/--birthday
          (setq-local bl/--birthday (current-time)))))))

(defun bl/--format-duration (seconds &optional long)
  (let* ((sec (truncate seconds))
         (hours (/ sec 3600))
         (minutes (/ (% sec 3600) 60))
         (secs (% sec 60))
         (unit (lambda (n short-suffix long-word)
                 (when (> n 0)
                   (if long
                       (format "%d %s%s" n long-word (if (= n 1) "" "s"))
                     (format "%d%s" n short-suffix)))))
         (parts (delq nil (list (funcall unit hours "h" "hour")
                                 (funcall unit minutes "m" "minute")
                                 (funcall unit secs "s" "second")))))
    (cond
     (parts (string-join parts (if long ", " "")))
     (long "0 seconds")
     (t "0s"))))

(defun bl/--age-seconds ()
  (when bl/--birthday
    (float-time (time-subtract (current-time) bl/--birthday))))

(defun bl/--age-mode-line ()
  (format "[age: %s]"
          (if-let ((age (bl/--age-seconds)))
              (bl/--format-duration age)
            "ded")))

;;;###autoload
(defun bl/age-current ()
  (interactive)
  (let ((result (if-let ((age (bl/--age-seconds)))
                     (bl/--format-duration age t)
                   "Dead.")))
    (when (called-interactively-p 'interactive)
      (message "%s" result))
    result))

(mapc #'bl/--mark-buffer (buffer-list))
(add-hook 'buffer-list-update-hook #'bl/--mark-buffer)
(add-to-list 'global-mode-string '(:eval (bl/--age-mode-line)))

(when (timerp bl/--timer)
  (cancel-timer bl/--timer))
(setq bl/--timer (run-at-time 1 1 (lambda () (force-mode-line-update t))))

(provide 'buffer-life)
