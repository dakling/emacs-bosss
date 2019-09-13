(defvar bosss--block-beginning-mark  "==============")

(defvar bosss--block-end-mark  "**************")

(define-derived-mode bosss-mode csharp-mode "bosss"
  ;; (setq bosss-highlights
  ;; 	'("==============" . font-lock-comment-face))
  ;; ;; (setq bosss-highlights
  ;; ;; 	'(("==============" . font-lock-comment-face)
  ;; ;;     ("**************" . font-lock-comment-face)))
  ;; (setq font-lock-defaults (cons (list bosss-highlights (car csharp-font-lock-keywords)) (cdr font-lock-defaults)))
  )

(defvar bosss-mode-map (make-sparse-keymap))

(defun bosss-create-new-field ()
  (interactive)
  (search-forward bosss--block-end-mark)
  (newline)
  (insert bosss--block-beginning-mark)
  (newline)
  (newline)
  (newline)
  (insert bosss--block-end-mark)
  (forward-line -2))

(defun bosss-next-field ()
  (interactive)
  (search-forward bosss--block-beginning-mark)
  (forward-line 1))

(defun bosss-previous-field ()
  (interactive)
  (search-backward bosss--block-beginning-mark nil nil 2)
  (forward-line 1))

(defun bosss-eval-and-next-field ()
  (interactive)
  (bosss-repl-send-current-field)
  (bosss-next-field))


;; TODO define text object for a field

(provide 'bosss)
