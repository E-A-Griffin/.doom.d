;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name    "Emma Griffin"
      user-mail-address "emma.audrey.g@gmail.com")

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
(setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-monokai-pro)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq org-latex-create-formula-image-program 'dvisvgm)

(setq org-latex-listings 'minted
      org-latex-packages-alist '(("" "minted"))
      org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

(use-package org
  :mode ("\\.org\\'" . org-mode)
  :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(after! org
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.2)))

;; (map! :after evil-org
;;       :map evil-org-mode-map
;;       :n "C-c C-r" verb-command-map)

;; (map! :after org
;;       :map org-mode-map
;;       :n "C-c C-r" verb-command-map)

;(with-eval-after-load 'org
;  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;(setq tramp-use-ssh-controlmaster-options nil)

(setq python-indent-offset 4)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq c-basic-offset 2)
;; Fix OpenMP #pragma warnings
(setq flycheck-gcc-openmp t)

(elpy-enable)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")

(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; *.erb => web-mode
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))

;; *.dj => java-mode
(add-to-list 'auto-mode-alist '("\\.dj\\'" . java-mode))

;; *.dism => asm-mode
(add-to-list 'auto-mode-alist '("\\.dism\\'" . asm-mode))

;; -*- mode: emacs-lisp -*-

;; This file contains code to set up Emacs to edit PostgreSQL source
;; code.  Copy these snippets into your .emacs file or equivalent, or
;; use load-file to load this file directly.
;;
;; Note also that there is a .dir-locals.el file at the top of the
;; PostgreSQL source tree, which contains many of the settings shown
;; here (but not all, mainly because not all settings are allowed as
;; local variables).  So for light editing, you might not need any
;; additional Emacs configuration.


;;; C files

;; Style that matches the formatting used by
;; src/tools/pgindent/pgindent.  Many extension projects also use this
;; style.
(c-add-style "postgresql"
             '("bsd"
               (c-auto-align-backslashes . nil)
               (c-basic-offset . 4)
               (c-offsets-alist . ((case-label . +)
                                   (label . -)
                                   (statement-case-open . +)))
               (fill-column . 78)
               (indent-tabs-mode . t)
               (tab-width . 4)))

(add-hook 'c-mode-hook
          (defun postgresql-c-mode-hook ()
            (when (string-match "/postgres\\(ql\\)?/" buffer-file-name)
              (c-set-style "postgresql")
              ;; Don't override the style we just set with the style in
              ;; `dir-locals-file'.  Emacs 23.4.1 needs this; it is obsolete,
              ;; albeit harmless, by Emacs 24.3.1.
              (set (make-local-variable 'ignored-local-variables)
                   (append '(c-file-style) ignored-local-variables)))))


;;; Perl files

;; Style that matches the formatting used by
;; src/tools/pgindent/perltidyrc.
(defun pgsql-perl-style ()
  "Perl style adjusted for PostgreSQL project"
  (interactive)
  (setq perl-brace-imaginary-offset 0)
  (setq perl-brace-offset 0)
  (setq perl-continued-statement-offset 2)
  (setq perl-continued-brace-offset (- perl-continued-statement-offset))
  (setq perl-indent-level 4)
  (setq perl-label-offset -2)
  ;; Next two aren't marked safe-local-variable, so .dir-locals.el omits them.
  (setq perl-indent-continued-arguments 4)
  (setq perl-indent-parens-as-block t)
  (setq indent-tabs-mode t)
  (setq tab-width 4))

(add-hook 'perl-mode-hook
          (defun postgresql-perl-mode-hook ()
             (when (string-match "/postgres\\(ql\\)?/" buffer-file-name)
               (pgsql-perl-style))))


;;; documentation files

;; *.sgml files are actually XML
(add-to-list 'auto-mode-alist '("/postgres\\(ql\\)?/.*\\.sgml\\'" . nxml-mode))

(add-hook 'nxml-mode-hook
          (defun postgresql-xml-mode-hook ()
             (when (string-match "/postgres\\(ql\\)?/" buffer-file-name)
               (setq fill-column 78)
               (setq indent-tabs-mode nil))))

;; The *.xsl files use 2-space indent, which is consistent with
;; docbook-xsl sources and also the nxml-mode default.  But the *.sgml
;; files use 1-space indent, mostly for historical reasons at this
;; point.
(add-hook 'nxml-mode-hook
          (defun postgresql-xml-src-mode-hook ()
             (when (string-match "/postgres\\(ql\\)?/.*\\.sgml\\'" buffer-file-name)
               (setq nxml-child-indent 1))))


;;; Makefiles

;; use GNU make mode instead of plain make mode
(add-to-list 'auto-mode-alist '("/postgres\\(ql\\)?/.*Makefile.*" . makefile-gmake-mode))
(add-to-list 'auto-mode-alist '("/postgres\\(ql\\)?/.*\\.mk\\'" . makefile-gmake-mode))
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
