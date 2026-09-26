;; -*- lexical-binding: t; -*-

;; Better git info.

(defvar-local gm/--git-status nil)

(defun gm/--format-git-status (output)
  (let ((branch nil)
        (new 0)
        (modified 0)
        (deleted 0)
        (renamed 0))
    (dolist (line (split-string output "\n" t))
      (let ((prefix (substring line 0 2)))
        (cond
          ((string-equal prefix "##")
           (setq branch
                 (car (split-string (substring line 3) "\\.\\.\\." t))))
          ((member prefix '("??" "A " " A"))
           (setq new (1+ new)))
          ((member prefix '("MM" "M " " M"))
           (setq modified (1+ modified)))
          ((member prefix '("D " " D"))
           (setq deleted (1+ deleted)))
          ((member prefix '("R " " R"))
           (setq renamed (1+ renamed))))))
    (let ((status
           (string-join
            (delq nil
                  (list
                   (when (> new 0) (format "+%d" new))
                   (when (> modified 0) (format "~%d" modified))
                   (when (> deleted 0) (format "-%d" deleted))
                   (when (> renamed 0) (format ">%d" renamed))))
            " ")))
      (setq gm/--git-status
            (if (string-empty-p status)
                branch
              (format "%s: %s" branch status))))))


(defun gm/update-git-status ()
  (interactive)
  (let ((output ""))
    (make-process
     :name "gm/git-status"
     :buffer nil
     :command '("git" "status" "--porcelain" "-b")
     :filter (lambda (_ chunk)
               (setq output (concat output chunk)))

     :sentinel (lambda (_ event)
                 (when (string-match-p "finished" event)
                   (gm/--format-git-status output)
                   (force-mode-line-update t))))))

(add-hook 'dired-mode-hook 'gm/update-git-status)
(add-hook 'dired-after-readin-hook
          (lambda ()
            (when (derived-mode-p 'dired-mode)
              (gm/update-git-status))))
(setq-default mode-line-format
              (mapcar
               (lambda (item)
                 (if (equal item '(vc-mode vc-mode))
                     '(:eval gm/--git-status)
                   item))
               mode-line-format))

(provide 'git-modeline)
