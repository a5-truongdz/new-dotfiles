;;; emacs-pets-duck.el --- Duck pet definition for emacs-pets  -*- lexical-binding: t; -*-

;;; Code:

(defconst emacs-pets-duck-walk-files
  (mapcar (lambda (f) (expand-file-name f (file-name-directory load-file-name)))
          '("duck-walk-1.txt"
            "duck-walk-2.txt"
            "duck-walk-3.txt"
            "duck-walk-4.txt"))
  "Walk cycle animation files for the duck pet.")

(defconst emacs-pets-duck-idle-files
  (mapcar (lambda (f) (expand-file-name f (file-name-directory load-file-name)))
          '("duck-idle-1.txt"
            "duck-idle-2.txt"))
  "Idle animation files for the duck pet.")

(defconst emacs-pets-duck-sleep-files
  (mapcar (lambda (f) (expand-file-name f (file-name-directory load-file-name)))
          '("duck-sleep-1.txt" "duck-sleep-1.txt" "duck-sleep-1.txt"
            "duck-sleep-2.txt" "duck-sleep-2.txt" "duck-sleep-2.txt"
            "duck-sleep-3.txt" "duck-sleep-3.txt" "duck-sleep-3.txt"
            "duck-sleep-4.txt" "duck-sleep-4.txt" "duck-sleep-4.txt"))
  "Sleep animation files for the duck pet.")

(defconst emacs-pets-duck-sprite-colors
  '("  c None"
    "= c #ecb187"
    ". c #ffffff"
    "* c #aa6738"
    "@ c #000000"
    "Z c #508cdc")
  "XPM color map for the duck pet.")

(provide 'emacs-pets-duck)