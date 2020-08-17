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

;; default font size smaller on linux, larger on mac.
(setq-default dimitern/font-size 11)
(when IS-LINUX (setq dimitern/font-size 10.5))
(when IS-MAC (setq dimitern/font-size 12))

(setq doom-font (font-spec :family "Input Mono" :size dimitern/font-size)
      doom-variable-pitch-font (font-spec :family "Input Sans" :size dimitern/font-size)
      doom-big-font (font-spec :family "Input Mono" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Persist Emacs’ initial frame position, dimensions and/or full-screen state across sessions
(when-let (dims (doom-store-get 'last-frame-size))
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
   flycheck-disabled-checkers '(python-pylint python-mypy)))

;; Treat underscores as word delimiters.
(after! python
  (add-hook 'python-mode-hook
            (lambda ()
              (modify-syntax-entry ?_ "w")
              (subword-mode)
              (anaconda-eldoc-mode 1)
              (anaconda-mode 1))))

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
(remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)

;; focus-autosave-mode: save buffers on focus loss.
(after! frame
  (focus-autosave-mode t))

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
