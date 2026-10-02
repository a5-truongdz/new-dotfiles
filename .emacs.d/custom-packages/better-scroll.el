;; -*- lexical-binding: t -*-

;; Makes scrolling better.

(defun bs/previous-line ()
  (interactive)
  (let ((would-hit-margin
         (save-excursion
           (previous-line 1)
           (< (cdr (posn-col-row (posn-at-point)))
              scroll-margin))))
    (when would-hit-margin
      (pixel-scroll-down))
    (previous-line 1)))

(defun bs/next-line ()
  (interactive)
  (let ((would-hit-margin
         (save-excursion
           (next-line 1)
           (>= (cdr (posn-col-row (posn-at-point)))
               (- (window-text-height) scroll-margin)))))
    (when would-hit-margin
      (pixel-scroll-up))
    (next-line 1)))

(pixel-scroll-precision-mode 1)
(setq pixel-scroll-precision-interpolate-page t)
(setq scroll-margin 3)
(setq scroll-conservatively 101)

(provide 'better-scroll)
