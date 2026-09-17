;;; emacs-pets-ns-train.el --- Ns-Train pet definition for emacs-pets  -*- lexical-binding: t; -*-

;;; Code:

(defconst emacs-pets-ns-train-walk-files
  (mapcar (lambda (f) (expand-file-name f (file-name-directory load-file-name)))
          '("ns-train-idle-1.txt"))
  "Walk cycle animation files for the ns-train pet.")

(defconst emacs-pets-ns-train-idle-files
  (mapcar (lambda (f) (expand-file-name f (file-name-directory load-file-name)))
          '("ns-train-idle-1.txt"))
  "Idle animation files for the ns-train pet.")

(defconst emacs-pets-ns-train-sleep-files
  (mapcar (lambda (f) (expand-file-name f (file-name-directory load-file-name)))
          '("ns-train-idle-1.txt"))
  "Sleep animation files for the ns-train pet.")

(defconst emacs-pets-ns-train-sprite-colors
  '("  c None"
    "+ c #f6c63f"
    "= c #e6b029"
    "' c #b08f41"
    ": c #282a80"
    "@ c #66605e"
    "Z c #a1a0a1"
    "[ c #3d3a33")
  "XPM color map for the ns-train pet.")

(provide 'emacs-pets-ns-train)
