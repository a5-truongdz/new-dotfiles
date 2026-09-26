;; -*- lexical-binding: t; -*-

;; Better git info.

(defvar-local gm/--git-status nil)

(defun gm/--format-git-status (output)
  ;; ???
)

(defun gm/--update-git-status ()
  (let ((output ""))
    (make-process
     :name "gm/git-status"
     :buffer nil
     :command '("git" "status" "--porcelain" "-b")
     :filter (lambda (_ chunk)
               (setq output (concat output chunk)))

     :sentinel (lambda (_ event)
                 (when (string-match-p "finished" event)
                   (gm/--format-git-status output))))))

(add-hook 'dired-mode-hook 'gm/--update-git-status)
(add-hook 'after-revert-hook
          (lambda ()
            (when (derived-mode-p 'dired-mode)
              (gm/--update-git-status))))

(provide 'git-modeline)
