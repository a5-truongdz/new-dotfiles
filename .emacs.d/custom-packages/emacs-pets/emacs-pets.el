;;; emacs-pets.el --- Animated virtual pets in your modeline  -*- lexical-binding: t; -*-

;; Author: emacs-pets contributors
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1"))
;; Keywords: games
;; URL: https://github.com/emacs-pets/emacs-pets

;;; Commentary:

;; Place an animated pet in your Emacs modeline.  The pet wanders
;; left and right, occasionally pausing to idle.  Enable with
;; `M-x emacs-pets-mode'.

;;; Code:
(require 'cl-lib)

(defconst emacs-pets--directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing the emacs-pets package files.")

;;;; Customization


(defgroup emacs-pets nil
  "Animated virtual pets in the modeline."
  :group 'games
  :prefix "emacs-pets-")

(defcustom emacs-pets-tick-interval 0.3
  "Seconds each animation frame is displayed.
Controls walk speed, idle/sleep frame cycling, and state durations.
Lower values make the pet move and animate faster."
  :type '(restricted-float :min 0.05 :max 5.0)
  :group 'emacs-pets)

(defcustom emacs-pets-field-width 22
  "Total character width of the pet display area in the modeline.
The pet occupies exactly this many columns at all times, moving
within the space. Must be at least 2."
  :type 'integer
  :group 'emacs-pets)

(defcustom emacs-pets-step-size 0.85
  "Columns the pet moves on each walking frame.
May be a fraction (e.g. 0.25) for sub-column movement.
Does not affect idle or sleep. Must be greater than 0."
  :type '(restricted-float :min 0.05)
  :group 'emacs-pets)

(defcustom emacs-pets-idle-chance 0.05
  "Probability of entering idle state each tick."
  :type 'float
  :group 'emacs-pets)

(defcustom emacs-pets-idle-duration 3
  "Number of seconds to remain idle."
  :type 'integer
  :group 'emacs-pets)

(defcustom emacs-pets-sleep-chance 0.005
  "Probability of entering sleep state each tick."
  :type 'float
  :group 'emacs-pets)

(defcustom emacs-pets-sleep-duration 60
  "Number of seconds to remain sleeping (1-2 minutes recommended)."
  :type 'integer
  :group 'emacs-pets)

(defcustom emacs-pets-scale 1
  "Scale factor for the pet sprite.
Values >= 1 enlarge: each pixel becomes an NxN block.
Values < 1 shrink: every Nth pixel/row is sampled (e.g. 0.5 = half size)."
  :type 'number
  :group 'emacs-pets)

(defcustom emacs-pets-pet 'duck
  "Pet to display in the modeline.
Currently available pets: 'duck, 'ns-train"
  :type 'symbol
  :group 'emacs-pets)

(defcustom emacs-pets-sprite-files nil
  "Ordered list of sprite file paths forming a walk-cycle animation.
Each file is a .txt with raw pixel rows.  Frames are cycled on every walking step.
Colors come from `emacs-pets-sprite-colors'."
  :type '(repeat file)
  :group 'emacs-pets)

(defcustom emacs-pets-idle-files nil
  "Ordered list of sprite file paths forming a 2-frame idle animation.
Each file is a .txt with raw pixel rows.  When non-nil, these frames
are shown (and cycled) while the pet is idle instead of the walk frame.
Colors come from `emacs-pets-sprite-colors'."
  :type '(repeat file)
  :group 'emacs-pets)

(defcustom emacs-pets-sleep-files nil
  "Ordered list of sprite file paths forming a sleep animation.
Each file is a .txt with raw pixel rows.  When non-nil, these frames
are shown (and cycled) while the pet is sleeping.
Colors come from `emacs-pets-sprite-colors'."
  :type '(repeat file)
  :group 'emacs-pets)

(defcustom emacs-pets-sprite-colors nil
  "XPM color map used when loading sprites.
Each entry is an XPM color definition string."
  :type '(repeat string)
  :group 'emacs-pets)

;;;; Pet loading

(defun emacs-pets--load-pet (pet)
  "Load the pet definition for PET and set the appropriate variables."
  (let ((pet-module (intern (format "emacs-pets-%s" pet)))
        (walk-var (intern (format "emacs-pets-%s-walk-files" pet)))
        (idle-var (intern (format "emacs-pets-%s-idle-files" pet)))
        (sleep-var (intern (format "emacs-pets-%s-sleep-files" pet)))
        (colors-var (intern (format "emacs-pets-%s-sprite-colors" pet))))

    ;; Load the pet module
    (require pet-module)

    ;; Set the main variables from the pet-specific variables
    (setq emacs-pets-sprite-files (symbol-value walk-var))
    (setq emacs-pets-idle-files (symbol-value idle-var))
    (setq emacs-pets-sleep-files (symbol-value sleep-var))
    (setq emacs-pets-sprite-colors (symbol-value colors-var))))

;; Load the default pet
(emacs-pets--load-pet emacs-pets-pet)

;; Set up variable watcher to reload pet when changed
(defun emacs-pets--on-pet-change (symbol new-value operation where)
  "Reload pet when `emacs-pets-pet' is customized."
  (when (boundp symbol)
    (emacs-pets--load-pet new-value)
    ;; Recreate images with new pet
    (when emacs-pets-mode
      (emacs-pets--create-images)
      (force-mode-line-update t))))

;; Watch for changes to emacs-pets-pet
(add-variable-watcher 'emacs-pets-pet 'emacs-pets--on-pet-change)

;;;; Internal state

(defvar emacs-pets--position 0.0
  "Current horizontal padding in canonical columns (may be fractional).")

(defvar emacs-pets--direction 'right
  "Current movement direction (`left' or `right').")

(defvar emacs-pets--state 'walking
  "Current pet state (`walking', `idle', or `sleeping').")

(defvar emacs-pets--idle-counter 0
  "Remaining seconds of idle state.")

(defvar emacs-pets--sleep-counter 0
  "Remaining seconds of sleep state.")

(defvar emacs-pets--timer nil
  "Timer driving the animation loop.")

(defvar emacs-pets--walk-frames nil
  "Vector of (LEFT-IMAGE . RIGHT-IMAGE) cons cells, one per walk frame.")

(defvar emacs-pets--frame-index 0
  "Index into `emacs-pets--walk-frames' for the current walk frame.")

(defvar emacs-pets--idle-frames nil
  "Vector of (LEFT-IMAGE . RIGHT-IMAGE) cons cells, one per idle frame.")

(defvar emacs-pets--idle-frame-index 0
  "Index into `emacs-pets--idle-frames' for the current idle frame.")

(defvar emacs-pets--sleep-frames nil
  "Vector of (LEFT-IMAGE . RIGHT-IMAGE) cons cells, one per sleep frame.")

(defvar emacs-pets--sleep-frame-index 0
  "Index into `emacs-pets--sleep-frames' for the current sleep frame.")

;;;; Core functions

(defun emacs-pets--move ()
  "Advance the pet by `emacs-pets-step-size' in the current direction.
Reverse at field boundaries."
  (let ((max-pos (max 0.0 (float (1- emacs-pets-field-width))))
        (step (max 0.0 emacs-pets-step-size)))
    (pcase emacs-pets--direction
      ('right
       (if (>= emacs-pets--position max-pos)
           (setq emacs-pets--direction 'left
                 emacs-pets--position (max 0.0 (- emacs-pets--position step)))
         (setq emacs-pets--position (min max-pos (+ emacs-pets--position step)))))
      ('left
       (if (<= emacs-pets--position 0)
           (setq emacs-pets--direction 'right
                 emacs-pets--position (min max-pos (+ emacs-pets--position step)))
         (setq emacs-pets--position (max 0.0 (- emacs-pets--position step))))))))

(defun emacs-pets--tick ()
  "Advance one animation frame."
  (pcase emacs-pets--state
    ('sleeping
     (when (and emacs-pets--sleep-frames
                (> (length emacs-pets--sleep-frames) 1))
       (setq emacs-pets--sleep-frame-index
             (mod (1+ emacs-pets--sleep-frame-index)
                  (length emacs-pets--sleep-frames))))
     (setq emacs-pets--sleep-counter (- emacs-pets--sleep-counter emacs-pets-tick-interval))
     (when (<= emacs-pets--sleep-counter 0)
       (setq emacs-pets--state 'walking
             emacs-pets--sleep-frame-index 0)))
    ('idle
     (when (and emacs-pets--idle-frames
                (> (length emacs-pets--idle-frames) 1))
       (setq emacs-pets--idle-frame-index
             (mod (1+ emacs-pets--idle-frame-index)
                  (length emacs-pets--idle-frames))))
     (setq emacs-pets--idle-counter (- emacs-pets--idle-counter emacs-pets-tick-interval))
     (when (<= emacs-pets--idle-counter 0)
       (setq emacs-pets--state 'walking
             emacs-pets--idle-frame-index 0)))
    ('walking
     (if (< (cl-random 1.0) emacs-pets-sleep-chance)
         (setq emacs-pets--state 'sleeping
               emacs-pets--sleep-counter emacs-pets-sleep-duration
               emacs-pets--sleep-frame-index 0)
       (if (< (cl-random 1.0) emacs-pets-idle-chance)
           (setq emacs-pets--state 'idle
                 emacs-pets--idle-counter emacs-pets-idle-duration)
         (emacs-pets--move)
         (when (and emacs-pets--walk-frames
                    (> (length emacs-pets--walk-frames) 1))
           (setq emacs-pets--frame-index
                 (mod (1+ emacs-pets--frame-index)
                      (length emacs-pets--walk-frames))))))))
  (force-mode-line-update t))

;;;; Image functions

(defun emacs-pets--build-xpm (rows colors)
  "Build XPM data string from ROWS with COLORS."
  (let* ((width (length (car rows)))
         (height (length rows)))
    (concat
     "/* XPM */\nstatic char *pet[] = {\n"
     (format "\"%d %d %d 1\",\n" width height (length colors))
     (mapconcat (lambda (c) (format "\"%s\"" c)) colors ",\n")
     ",\n"
     (mapconcat (lambda (row) (format "\"%s\"" row)) rows ",\n")
     "\n};")))

(defun emacs-pets--mirror-rows (rows)
  "Return ROWS mirrored horizontally."
  (mapcar (lambda (row)
            (apply #'string (nreverse (string-to-list row))))
          rows))

(defun emacs-pets--scale-rows (rows factor)
  "Scale ROWS by FACTOR.
When FACTOR >= 1, each pixel becomes an NxN block (enlarged).
When FACTOR < 1, every Nth pixel and row is sampled (shrunk)."
  (if (>= factor 1)
      (let ((n (max 1 (round factor)))
            result)
        (dolist (row rows (nreverse result))
          (let ((scaled-row
                 (apply #'concat
                        (mapcar (lambda (ch) (make-string n ch))
                                (string-to-list row)))))
            (dotimes (_ n)
              (push scaled-row result)))))
    (let* ((step (max 2 (round (/ 1.0 factor))))
           (row-idx 0)
           result)
      (dolist (row rows (nreverse result))
        (when (= 0 (mod row-idx step))
          (let* ((chars (string-to-list row))
                 (sampled (cl-loop for ch in chars
                                   for i from 0
                                   when (= 0 (mod i step))
                                   collect ch)))
            (push (apply #'string sampled) result)))
        (setq row-idx (1+ row-idx))))))

(defun emacs-pets--load-sprite-file (file)
  "Read FILE and return a list of pixel-row strings.
All rows are padded with spaces to the width of the longest row."
  (with-temp-buffer
    (insert-file-contents file)
    (let* ((lines (split-string (buffer-string) "\n"))
           ;; Drop empty trailing lines
           (lines (let ((l (reverse lines)))
                    (while (and l (string-empty-p (car l)))
                      (setq l (cdr l)))
                    (nreverse l)))
           (max-w (apply #'max (mapcar #'length lines))))
      (mapcar (lambda (row)
                (if (< (length row) max-w)
                    (concat row (make-string (- max-w (length row)) ?\s))
                  row))
              lines))))

(defun emacs-pets--pad-rows (rows width)
  "Pad each row in ROWS with transparent pixels, centered, to WIDTH.
The space character must map to None in the sprite color map."
  (mapcar (lambda (row)
            (let* ((diff (max 0 (- width (length row))))
                   (left (/ diff 2))
                   (right (- diff left)))
              (concat (make-string left ?\s) row (make-string right ?\s))))
          rows))

(defun emacs-pets--make-frame (rows colors)
  "Return a (LEFT-IMAGE . RIGHT-IMAGE) cons cell for ROWS and COLORS."
  (let ((scaled (emacs-pets--scale-rows rows emacs-pets-scale)))
    (cons (create-image (emacs-pets--build-xpm scaled colors)
                        'xpm t :ascent 'center)
          (create-image (emacs-pets--build-xpm
                         (emacs-pets--mirror-rows scaled) colors)
                        'xpm t :ascent 'center))))

(defun emacs-pets--create-images ()
  "Create and cache walk, idle, and sleep frames for the current pet configuration.
All frames are padded with transparent pixels to a common width so the
rendered image always has the same size regardless of frame or state."
  (when (and (display-graphic-p) (image-type-available-p 'xpm))
    (let* ((load-set (lambda (files)
                       (mapcar #'emacs-pets--load-sprite-file
                               (cl-remove-if-not #'file-readable-p files))))
           (walk-rows (funcall load-set emacs-pets-sprite-files))
           (idle-rows (funcall load-set emacs-pets-idle-files))
           (sleep-rows (funcall load-set emacs-pets-sleep-files))
           (all-rows (append walk-rows idle-rows sleep-rows))
           (max-w (if all-rows
                      (apply #'max (mapcar (lambda (rows) (length (car rows)))
                                           all-rows))
                    0))
           (make-set (lambda (rows-list)
                       (when rows-list
                         (vconcat
                          (mapcar (lambda (rows)
                                    (emacs-pets--make-frame
                                     (emacs-pets--pad-rows rows max-w)
                                     emacs-pets-sprite-colors))
                                  rows-list))))))
      (setq emacs-pets--walk-frames (or (funcall make-set walk-rows) (vector)))
      (setq emacs-pets--idle-frames (funcall make-set idle-rows))
      (setq emacs-pets--sleep-frames (funcall make-set sleep-rows)))))

;;;; Mode-line display

(defun emacs-pets--space (width)
  "Return a mode-line space of WIDTH canonical columns, or empty if WIDTH <= 0.
WIDTH may be fractional.  Uses `space :width' as a number (columns),
not a pixel list, so the field stays a stable column count."
  (if (> width 0)
      (propertize " " 'display `(space :width ,width))
    ""))

(defun emacs-pets--mode-line-string ()
  "Return the mode-line string for the pet.
Left pad plus pet plus right pad always occupy `emacs-pets-field-width'
canonical columns, so the rest of the mode line does not shift."
  (let* ((frame (cond ((eq emacs-pets--state 'idle)
                       (and emacs-pets--idle-frames
                            (aref emacs-pets--idle-frames emacs-pets--idle-frame-index)))
                      ((eq emacs-pets--state 'sleeping)
                       (and emacs-pets--sleep-frames
                            (aref emacs-pets--sleep-frames emacs-pets--sleep-frame-index)))
                      (t (and emacs-pets--walk-frames
                              (aref emacs-pets--walk-frames emacs-pets--frame-index)))))
         (img (when frame
                (if (eq emacs-pets--direction 'left)
                    (car frame)
                  (cdr frame))))
         (left emacs-pets--position)
         (right (max 0.0 (- emacs-pets-field-width left 1)))
         (pet (if img
                  (propertize " " 'display img)
                " ")))
    (concat (emacs-pets--space left) pet (emacs-pets--space right))))

;;;; Mode-line integration

(defvar emacs-pets--mode-line-construct
  '(:eval (when emacs-pets-mode (emacs-pets--mode-line-string)))
  "Mode-line construct that renders the pet.")

(defun emacs-pets--install-mode-line ()
  "Add the pet construct to `global-mode-string'."
  (add-to-list 'global-mode-string emacs-pets--mode-line-construct t))

(defun emacs-pets--remove-mode-line ()
  "Remove the pet construct from `global-mode-string'."
  (setq global-mode-string
        (delete emacs-pets--mode-line-construct global-mode-string)))

;;;; Timer management

(defun emacs-pets--start-timer ()
  "Start the animation timer."
  (unless emacs-pets--timer
    (setq emacs-pets--timer
          (run-with-timer emacs-pets-tick-interval
                          emacs-pets-tick-interval
                          #'emacs-pets--tick))))

(defun emacs-pets--stop-timer ()
  "Stop the animation timer."
  (when emacs-pets--timer
    (cancel-timer emacs-pets--timer)
    (setq emacs-pets--timer nil)))

(defun emacs-pets--restart-timer ()
  "Restart the animation timer with the current `emacs-pets-tick-interval'."
  (emacs-pets--stop-timer)
  (emacs-pets--start-timer))

(defun emacs-pets--on-tick-interval-change (symbol new-value operation where)
  "Restart timer when `emacs-pets-tick-interval' is customized."
  (when (and (boundp symbol) emacs-pets-mode)
    (emacs-pets--restart-timer)))

(add-variable-watcher 'emacs-pets-tick-interval 'emacs-pets--on-tick-interval-change)

;;;; Minor mode

;;;###autoload
(define-minor-mode emacs-pets-mode
  "Toggle an animated pet in the modeline."
  :global t
  :lighter nil
  (if emacs-pets-mode
      (progn
        (setq emacs-pets--position 0.0
              emacs-pets--direction 'right
              emacs-pets--state 'walking
              emacs-pets--idle-counter 0
              emacs-pets--sleep-counter 0
              emacs-pets--frame-index 0
              emacs-pets--idle-frame-index 0
              emacs-pets--sleep-frame-index 0)
        (emacs-pets--create-images)
        (emacs-pets--install-mode-line)
        (emacs-pets--start-timer))
    (emacs-pets--stop-timer)
    (emacs-pets--remove-mode-line)
    (force-mode-line-update t)))

(provide 'emacs-pets)
;;; emacs-pets.el ends here
