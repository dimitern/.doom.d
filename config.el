;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Dimiter Naydenov"
      user-mail-address "dimiter@naydenov.net")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:

(when IS-MAC
  (setq doom-font (font-spec :family "Input Mono" :style "Light" :size 12)
        doom-variable-pitch-font (font-spec :family "Input Sans" :size 12)
        doom-big-font (font-spec :family "Input Mono" :style "Light" :size 16)))

(when IS-LINUX
  (setq doom-font (font-spec :family "Input Mono Light" :size 10.5)
        doom-variable-pitch-font (font-spec :family "Input Sans" :size 11)
        doom-big-font (font-spec :family "Input Mono Light" :size 16)))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq-default doom-theme 'doom-vibrant)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Nextcloud/Dropbox/org-home/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Set up Python Language Server (pyls) with LSP
(use-package! lsp
  :init
  (setq lsp-pyls-plugins-pylint-enabled t)
  (setq lsp-pyls-plugins-autopep8-enabled nil)
  (setq lsp-pyls-plugins-yapf-enabled t)
  (setq lsp-pyls-plugins-flake8-max-line-length 120)
  (setq lsp-pyls-plugins-pycodestyle-max-line-length 120)
  (setq lsp-pyls-plugins-jedi-use-pyenv-environment t)
  (setq lsp-pyls-plugins-pyflakes-enabled nil)
  (setq lsp-pyls-plugins-pycodestyle-enabled nil)
  (setq lsp-python-ms-completion-add-brackets nil)
  (setq lsp-ui-doc-max-height 60))

;; Persist Emacs’ initial frame position, dimensions and/or full-screen state across sessions
(when-let (dims (doom-store-get 'last-frame-size doom-store-location (list '(3911 . 26) 417 121 'maximized)))
  (cl-destructuring-bind ((left . top) width height fullscreen) dims
    (setq initial-frame-alist
          (append initial-frame-alist
                  `((left . ,left)
                    (top . ,top)
                    (width . ,width)
                    (height . ,height)
                    (fullscreen . ,fullscreen))))))

(defun save-frame-dimensions ()
  (doom-store-put 'last-frame-size
                  (list (frame-position)
                        (frame-width)
                        (frame-height)
                        (frame-parameter nil 'fullscreen))))

(add-hook 'kill-emacs-hook #'save-frame-dimensions)

;; Use python-flake8 as default flycheck checker.
(after! flycheck
  (setq-default
   flycheck-flake8-maximum-line-length 120
   flycheck-disabled-checkers '(python-pylint python-mypy lsp)))

(defcustom format-enabled nil
  "Enable running blacken and isort on save for python-mode"
  :local t)

;; Remap shift+arrows to switch windows
(after! windmove
  (windmove-default-keybindings 'shift))

(map! [S-up]    #'windmove-up
      [S-down]  #'windmove-down
      [S-left]  #'windmode-left
      [S-right] #'windmove-right)

;; add default docsets for +lookup/...
(after! dash-docs
  (add-to-list 'dash-docs-common-docsets 'Tcl)
  (add-to-list 'dash-docs-common-docsets 'Python3))

;; Disable automatic insertion of parenthesis/quote pairs.
(remove-hook! 'doom-first-buffer-hook #'smartparens-global-mode)

;; focus-autosave-mode: save buffers on focus loss.
(after! frame
  (focus-autosave-mode t))

(defun toggle-formatting ()
  "Toggles blacken-mode, and py-sort-buffer before save in the current buffer"
  (interactive)
  (if format-enabled
      (progn
        (setq format-enabled nil)
        (blacken-mode -1)
        (remove-hook 'before-save-hook #'py-isort-buffer)
        (message "Disabled blacken-mode, and py-isort-buffer hook"))
    (progn
      (setq format-enabled t)
      (call-interactively 'blacken-mode)
      (add-hook 'before-save-hook #'py-isort-buffer)
      (message "Enabled blacken-mode, and py-isort-buffer hook"))))

(defun reset-formatting ()
  "Toggles the formatting on save twice."
  (interactive)
  (progn
    (toggle-formatting)
    (toggle-formatting)))

(defun my-python-hook ()
  ;; Treat underscores as word delimiters.
  (modify-syntax-entry ?_ "w")
  (subword-mode)
  (anaconda-eldoc-mode 1)
  (anaconda-mode 1)
  (flycheck-select-checker 'python-flake8)
  (set-formatter! 'black "cat") ;; Disable format-all-mode's black formatter using different args.
  (setq format-enabled nil)
  (call-interactively 'toggle-formatting)
  (message "my-python-hook completed"))

(defun my-blacken-hook ()
  (set (make-local-variable 'fill-column) 120)
  (set (make-local-variable 'blacken-line-length) 120)
  (message "my-blacken-hook completed"))

(add-hook 'python-mode-hook #'my-python-hook)
(add-hook 'blacken-mode-hook #'my-blacken-hook)

(map! :map python-mode-map
      ;; Toggle automatic formatting with black in python
      "C-c t T" 'toggle-formatting
      ;; Reset formatting (toggle twice).
      "C-c t R" 'reset-formatting
      ;; Easier lookup definition (than C-c c d)
      "M-." '+lookup/definition
      ;; Navigate between references with M-p/
      "M-p" #'occur-prev
      "M-n" #'occur-next)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
