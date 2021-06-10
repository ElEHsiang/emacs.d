(use-package rustic
  :ensure t
  :mode ("\\.rs$" . rustic-mode)
  :init
  (setq rustic-babel-format-src-block nil
        rustic-format-trigger nil)
  (remove-hook 'rustic-mode-hook #'flycheck-mode)
  (remove-hook 'rustic-mode-hook #'flymake-mode-off))
