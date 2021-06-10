(setq inhibit-statup-message t)

;; global setting
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(global-hl-line-mode t)

(setq mac-command-modifire 'meta)
(setq scroll-step 1)
(setq ring-bell-function 'ignore)
(setq visible-bell t)
(global-linum-mode t)

(setq custom-file "~/.emacs.d/custom-file.el")
(load-file custom-file)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
;; bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "GOPATH" "GOBIN"))
  (exec-path-from-shell-initialize))

(use-package spacemacs-theme
  :ensure t  
  :config
  (setq spacemacs-theme-comment-bg nil)
  (setq spacemacs-theme-comment-italic t)
  :init
  (load-theme 'spacemacs-dark))

;; general
(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer yun/leader-key-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))
  
;; company
(use-package company
  :ensure
  :config
  (setq company-idle-delay 0.3)
  (global-company-mode t))

;; Enhance M-x to allow easier execution of commands
(use-package smex
  :ensure t
  ;; Using counsel-M-x for now. Remove this permanently if counsel-M-x works better.
  :config
  (progn
  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  (smex-initialize)))


;; Git integration for Emacs
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

;; load evil
(use-package evil
  :ensure t ;; install the evil package if not installed
  :init ;; tweak evil's configuration before loading it
  (setq evil-search-module 'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-shift-round nil)
  (setq evil-want-C-u-scroll t)
  :config ;; tweak evil after loading it
  (evil-mode))


(use-package dired
  :commands dired-mode
  :bind (:map dired-mode-map ("C-o" . dired-omit-mode))
  :config
  (progn
    (setq dired-dwim-target t)
    (setq-default dired-omit-mode t)
    (setq-default dired-omit-files "^\\.?#\\|^\\.$\\|^\\.\\.$\\|^\\.")
    (define-key dired-mode-map "i" 'dired-subtree-insert)
    (define-key dired-mode-map ";" 'dired-subtree-remove)))

(use-package dired-subtree
  :ensure t
  :commands (dired-subtree-insert))

;; ivy/swiper
(use-package ivy
  :ensure t)
(use-package swiper
  :ensure t
  :diminish ivy-mode
  :bind (("C-r" . swiper)
         ("C-c C-r" . ivy-resume)
         ("C-c h m" . woman)
         ("C-x b" . ivy-switch-buffer)
         ("C-c u" . swiper-all))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t))
(use-package counsel
  :ensure t
  :commands (counsel-mode)
  :bind (("C-s" . counsel-grep-or-swiper)
         ("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-h f" . counsel-describe-function)
         ("C-h v" . counsel-describe-variable)
         ("C-h i" . counsel-info-lookup-symbol)
         ("C-h u" . counsel-unicode-char)
         ("C-c k" . counsel-rg)
         ("C-x l" . counsel-locate)
         ("C-c g" . counsel-git-grep)
         ("C-c h i" . counsel-imenu)
         ("C-x p" . counsel-list-processes))
  :init (counsel-mode)
  :config
  (ivy-set-actions
           'counsel-find-file
           '(("j" find-file-other-window "other")))
  (ivy-set-actions 'counsel-git-grep
                   '(("j" find-file-other-window "other"))))
(use-package ivy-hydra
  :ensure t)
(use-package ivy-xref
  :ensure t
  :init (setq xref-show-xrefs-function #'ivy-xref-show-xrefs))

;;  projectile
(use-package projectile
  :ensure t
  :commands (projectile-mode)
  ;:bind
  :config
  (progn
    (setq projectile-completion-system 'ivy)))
(use-package counsel-projectile
  :ensure t
  :commands (counsel-projectile-mode)
  :init
  (progn
    (projectile-mode +1)
    (counsel-projectile-mode)))

;; org
(use-package org
  :ensure t
  :init
  (progn
    (setq org-directory "~/Dropbox/note")
    (setq org-agenda-files (directory-files-recursively "~/Dropbox/note/" "\\.org$"))
    (setq org-default-notes-file (concat org-directory "/notes.org"))

    (setq org-major-mode-map (make-sparse-keymap))
    (define-key org-major-mode-map "d" ''org-dealine)
    )
  :config
  (progn
    (defun generate-org-note-name ()
      (setq my-org-note--name (read-string "title: "))
      (expand-file-name (format "%s.org" my-org-note--name) org-directory))
    (setq org-capture-templates
      '(("t" "Todo" entry (file "todo.org")
	 "* TODO %?" :empty-lines 1)
	("i" "Inbox" entry (file "inbox.org")
	 ,(concat "* TODO %?\n" "/Entered on/ %U"))
      ("n" "note" plain (file generate-org-note-name)
      "%(format \"#+TITLE: %s\n\" my-org-note--name)" :empty-lines 1)))
    ))

(use-package evil-org
  :ensure t
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; org-fancy-priorities
(use-package org-fancy-priorities
  :ensure t
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕")))

(use-package org-superstar
  :ensure t
  :after org
  :hook
  (org-mode . org-superstar-mode))

(use-package org-journal
  :ensure t
  :defer t
  :init
  (setq org-journal-dir "~/Dropbox/note/journal/"
        org-journal-date-format "%A, %d %B %Y"))

(use-package org-roam
      :ensure t
      :hook
      (after-init . org-roam-mode)
      :custom
      (org-roam-directory "~/Dropbox/note/")
      :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-insert))
              (("C-c n I" . org-roam-insert-immediate))))

(use-package which-key
  :ensure t
  :init
  (which-key-mode 1)
  :config
  (which-key-setup-side-window-bottom))

(use-package smooth-scrolling
  :ensure t
  :init
  (setq smooth-scroll-margin 5)
  :config
  (smooth-scrolling-mode 1))

(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode t)

  (sp-pair "'" nil :actions :rem)
  (sp-pair "`" nil :actions :rem)
  (setq sp-highlight-pair-overlay nil))

(use-package evil-smartparens
  :ensure t
  :after smartparens
  :diminish evil-smartparens-mode)

; treemacs
(use-package treemacs
  :ensure t)

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)
; lsp
(use-package lsp-mode
  :ensure t
  :init
  :general
  (yun/leader-key-def
    "l" '(:keymap lsp-mode-map lsp-command-map :which-key "lsp")
    "l =" '(:ignore t :wk "formatting")
    "l T" '(:ignore t :wk "toggles")
    "l s" '(:ignore t :wk "session management")
    "l g" '(:ignore t :wk "go to")
    "l h" '(:ignore t :wk "help")
    "l r" '(:ignore t :wk "refactor")
    "l a" '(:ignore t :wk "action")
    "l F" '(:ignore t :wk "folder")
    "l G" '(:ignore t :wk "peek"))
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (python-mode . lsp)
         (rust-mode . lsp)
         (go-mode . lsp-deferred)
         (haskell-mode . lsp)
         (cc-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :commands lsp-treemacs-errors-list)

; load for different language
(defun load-language-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file (expand-file-name "lang" user-init-dir))))

;; language plugins
(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
         user-emacs-directory)
        ((boundp 'user-init-directory)
         user-init-directory)
        (t "~/.emacs.d/")))

(load-language-file "python.el")
(load-language-file "cc.el")
(load-language-file "rust.el")
(load-language-file "haskell.el")
(load-language-file "go.el")
(load-language-file "markdown.el")

; ibuffer
(yun/leader-key-def
 "b" '(:ignore t :which-key "buffer")
 "bb" 'switch-to-buffer
 "bi" 'ibuffer
 "bn" 'next-buffer
 "bp" 'previous-buffer
 "bk" 'kill-buffer)

;; evil window
(yun/leader-key-def
  "w" 'evil-window-map
  "w <up>" 'evil-window-up
  "w <down>" 'evil-window-down
  "w <left>" 'evil-window-left
  "w <right>" 'evil-window-right)

;; file operation
(yun/leader-key-def
  "f" '(:ignore t :which-key "file")
  "ff" 'find-file)

;; org command
(yun/leader-key-def
  "o" '(:ignore t :which-key "org")
  "oa" 'org-agenda
  "oc" 'org-capture
  "on" 'org-add-note)

;; journal
(yun/leader-key-def
  "j" '(:ignore t :which-key "journal")
  "jc" 'org-journal-new-entry
  "jn" 'org-journal-next-entry
  "jp" 'org-journal-previous-entry
  "jd" 'org-journal-new-date-entry
  "js" 'org-journal-search-forever)

;; projectile
(yun/leader-key-def
  "p" 'projectile-command-map)

(yun/leader-key-def
  :keymap 'projectile-mode-map
  "/" 'projectile-ag)

(evil-define-key 'normal lsp-mode-map (kbd "SPC l") lsp-command-map)
