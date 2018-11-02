;; buildin cedet

(defconst cedet-user-include-dirs
     (list "." ".." "../include" "../inc" "../common" "../public"
           "../.." "../../include" "../../inc" "../../common" "../../public"))



;; (require 'semantic-c nil 'noerror)
(let ((include-dirs cedet-user-include-dirs))
   (mapc (lambda (dir)
           (semantic-add-system-include dir 'c++-mode)
           (semantic-add-system-include dir 'c-mode))
         include-dirs))



(when (and (fboundp 'semantic-mode)
           (not (locate-library "semantic-ctxt"))) ; can't found offical cedet
  (setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
                                    global-semanticdb-minor-mode
                                    global-semantic-idle-summary-mode
                                    global-semantic-mru-bookmark-mode))
  (semantic-mode 1)
  (global-semantic-decoration-mode 1)
  (require 'semantic/decorate/include nil 'noerror)
  (semantic-toggle-decoration-style "semantic-tag-boundary" -1)
  (global-semantic-highlight-edits-mode (if window-system 1 -1))
  (global-semantic-show-unmatched-syntax-mode 1)
  (global-semantic-show-parser-state-mode 1)
  (global-ede-mode 1)
  (when (executable-find "global")
    (semanticdb-enable-gnu-global-databases 'c-mode)
    (semanticdb-enable-gnu-global-databases 'c++-mode)
    (setq ede-locate-setup-options '(ede-locate-global ede-locate-base)))
  ;; (setq semantic-c-obey-conditional-section-parsing-flag nil) ; ignore #if

  (unless (executable-find "python")
    (remove-hook 'python-mode-hook 'wisent-python-default-setup)
    (setq semantic-new-buffer-setup-functions
          (delete (assq 'python-mode semantic-new-buffer-setup-functions)
                  semantic-new-buffer-setup-functions)))
  ;; (add-to-list 'semantic-inhibit-functions
  ;;              (lambda () (cond
  ;;                          ((member major-mode '(Info-mode python-mode))
  ;;                           ;; to disable semantic, return non-nil.
  ;;                           t)
  ;;                          (t nil))))

  
  (mapc (lambda (dir)
          (semantic-add-system-include dir 'c++-mode)
          (semantic-add-system-include dir 'c-mode))
       cedet-user-include-dirs)
  
  
  (defadvice push-mark (around semantic-mru-bookmark activate)
    "Push a mark at LOCATION with NOMSG and ACTIVATE passed to `push-mark'.
If `semantic-mru-bookmark-mode' is active, also push a tag onto
the mru bookmark stack."
    (semantic-mrub-push semantic-mru-bookmark-ring
                        (point)
                        'mark)
    ad-do-it)
  (defun semantic-ia-fast-jump-back ()
    (interactive)
    (if (ring-empty-p (oref semantic-mru-bookmark-ring ring))
        (error "Semantic Bookmark ring is currently empty"))
    (let* ((ring (oref semantic-mru-bookmark-ring ring))
           (alist (semantic-mrub-ring-to-assoc-list ring))
           (first (cdr (car alist))))
      ;; (if (semantic-equivalent-tag-p (oref first tag) (semantic-current-tag))
      ;;     (setq first (cdr (car (cdr alist)))))
      (semantic-mrub-visit first)
      (ring-remove ring 0)))
  (defun semantic-ia-fast-jump-or-back (&optional back)
    (interactive "P")
    (if back
        (semantic-ia-fast-jump-back)
      (semantic-ia-fast-jump (point))))
  (defun semantic-ia-fast-jump-mouse (ev)
    "semantic-ia-fast-jump with a mouse click. EV is the mouse event."
    (interactive "e")
    (mouse-set-point ev)
    (semantic-ia-fast-jump (point)))


  ;;;;;;;;;;;;<pulse>;;;;;;;;;;;;
  (autoload 'pulse-momentary-highlight-one-line "pulse" "" nil)
  (autoload 'pulse-line-hook-function "pulse" "" nil)
  (setq pulse-command-advice-flag t)    ; (if window-system 1 nil)
  (defadvice goto-line (after pulse-advice activate)
    "Cause the line that is `goto'd to pulse when the cursor gets there."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice exchange-point-and-mark (after pulse-advice activate)
    "Cause the line that is `goto'd to pulse when the cursor gets there."
    (when (and pulse-command-advice-flag (interactive-p)
               (> (abs (- (point) (mark))) 400))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice find-tag (after pulse-advice activate)
    "After going to a tag, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice tags-search (after pulse-advice activate)
    "After going to a hit, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice tags-loop-continue (after pulse-advice activate)
    "After going to a hit, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice pop-tag-mark (after pulse-advice activate)
    "After going to a hit, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice imenu-default-goto-function (after pulse-advice activate)
    "After going to a tag, pulse the line the cursor lands on."
    (when pulse-command-advice-flag
      (pulse-momentary-highlight-one-line (point))))
  (defadvice cua-exchange-point-and-mark (after pulse-advice activate)
    "Cause the line that is `goto'd to pulse when the cursor gets there."
    (when (and pulse-command-advice-flag (interactive-p)
               (> (abs (- (point) (mark))) 400))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice switch-to-buffer (after pulse-advice activate)
    "After switch-to-buffer, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice previous-buffer (after pulse-advice activate)
    "After previous-buffer, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice next-buffer (after pulse-advice activate)
    "After next-buffer, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice ido-switch-buffer (after pulse-advice activate)
    "After ido-switch-buffer, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (defadvice beginning-of-buffer (after pulse-advice activate)
    "After beginning-of-buffer, pulse the line the cursor lands on."
    (when (and pulse-command-advice-flag (interactive-p))
      (pulse-momentary-highlight-one-line (point))))
  (add-hook 'next-error-hook 'pulse-line-hook-function))
;;;;;;;;;;;;</pulse>;;;;;;;;;;;;




(load-file "~/.emacs.d/elpa/sourcepair.el")
(setq sourcepair-source-path    '( "." "../*" "../../*" "../../../*"))
(setq sourcepair-header-path    '( "." "include" "../include" "../*" "../../*"))
(setq sourcepair-recurse-ignore '( "CVS" "Obj" "Debug" "Release" ".git"))



(provide 'cedet-buildin)
