;;; bosss.el --- Support for the BoSSS solver

;; Copyright (C) 2019 Dario Klingenberg

;; Author: Dario Klingenberg <dario.klingenberg@web.de>
;; Created: 30 Aug 2019
;; Keywords: languages
;; Homepage: http://github.com/dakling/emacs-bosss
;; Version: 0.1

;; This file is not part of GNU Emacs.

;; This file is free software
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

;;; repl stuff

;; (defvar bosss-repl-path "/usr/bin/bosss-console")
(defvar bosss-repl-path "/usr/local/bin/sdb")

(defvar bosss-repl-arguments nil)

(defvar bosss-repl-mode-map (make-sparse-keymap))

(defvar bosss-repl-prompt-regexp "^\\(?:\\[[^@]+@[^@]+\\]\\)")

;; (defvar bosss-repl-prompt-regexp ">")

(defvar bosss--block-beginning-mark  "==============")

(defvar bosss--block-end-mark  "**************")

(defun bosss-repl-load-my-assembly ()
  "load the personal project into the repl"
  (interactive)
  (when bosss-path-reference
    (comint-send-string "*bosss*" (concat "LoadAssembly(\"" bosss-path-reference "\")\n"))))

(defun bosss-repl-start-bosss-pad ()
  "only makes sense if bossspad is wrapped inside a debugger"
  (interactive)
  (comint-send-string
   "*bosss*"
   "args --simpleconsole \n")
  (comint-send-string
   "*bosss*"
   (concat "run " bosss-pad-path "\n")))

(defun run-bosss-repl ()
  "start the repl in a new or existing buffer"
  (interactive)
  (let* ((bosss-program bosss-repl-path)
	 (buffer (comint-check-proc "bosss")))
    (pop-to-buffer-same-window
     (if (or buffer (not (derived-mode-p 'bosss-mode))
	     (comint-check-proc (current-buffer)))
	 (get-buffer-create (or buffer "*bosss*"))
       (current-buffer)))
    (unless buffer
      (apply 'make-comint-in-buffer "bosss" buffer
       bosss-program bosss-repl-arguments)
      (bosss-repl-mode)))
  (bosss-repl-start-bosss-pad))

(defun bosss--repl-initialize ()
  (setq comint-process-echoes nil)
  (setq comint-input-sender-no-newline nil)
  (setq comint-use-prompt-regexp t))

;;;###autoload
(define-derived-mode bosss-repl-mode comint-mode "bosss-repl"
  (setq comint-prompt-regexp bosss-repl-prompt-regexp)
  (setq comint-prompt-read-only t)
  (set (make-local-variable 'paragraph-separate) "\\'")
  ;; (set (make-local-variable 'font-lock-defaults) '(bosss-repl-font-lock-keywords t))
  (set (make-local-variable 'paragraph-start) bosss-repl-prompt-regexp))

(add-hook 'bosss-repl-mode-hook 'bosss--repl-initialize)

(defun run-bosss-repl-other-window ()
  "start the repl in another window"
    (interactive)
    (switch-to-buffer-other-window "*bosss*")
    (run-bosss-repl))

;; (defun bosss-repl-send-region (beg end)
;;   (interactive "r")
;;   (comint-send-region "*bosss*" beg end))

(defun bosss--format-input (input-string)
  "formats the input as a single line, which is better handled by comint"
  ;; remove linebreaks
 (replace-regexp-in-string
                       "\n"
                       ""
  ;; remove comments first
                       (replace-regexp-in-string
                        (rx (or (and "\*" (*? anything) "*/") (and "//" (*? anything) eol)))
                        ""
                         input-string)))

(defun bosss-repl-send-region (beg end)
  "send the active region to comint"
  (interactive "r")
  (comint-send-string "*bosss*"
                      (concat
                       (bosss--format-input
                        (buffer-substring beg end))
                       "\n")))

(defun bosss-repl-send-current-field ()
  "send the current field to comint"
  (interactive)
  (save-excursion
   (search-backward bosss--block-beginning-mark)
   (forward-line 1)
   (let ((beg (point)))
     (search-forward bosss--block-end-mark)
     (move-end-of-line 0)
     (bosss-repl-send-region beg (point)))))

;; not working; we need to check if each command has finished!
;; (defun bosss-repl-send-buffer ()
;;   (interactive)
;;   (save-excursion
;;     (goto-line 0)
;;     (while (search-forward bosss--block-beginning-mark nil t)
;;       (bosss-eval-and-next-field))))


;; worksheet stuff

;;;###autoload
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

;;; bosss.el ends here
