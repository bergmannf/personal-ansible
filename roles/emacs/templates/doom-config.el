;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Florian Bergmann"
      user-mail-address "Bergmann.F@gmail.com")

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
(setq doom-font (font-spec :family "Cascadia Mono" :size 12.0 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "sans" :size 12.0))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Nextcloud/org/")
;; Setup org-roam directory
(setq org-roam-directory "~/Nextcloud/org/roam/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


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

(after! evil-escape
  (setq evil-escape-key-sequence "jk"))

(after! lsp-rust-analyzer
  (setq lsp-rust-analyzer-server-display-inlay-hints t))

(after! poetry
  (setq poetry-tracking-strategy 'projectile))

;; Use <C-l> to move further down the selection - same as ivy.
(after! vertico
  (define-key vertico-map (kbd "C-l") 'vertico-insert))

(defun poetry-find-virtualenv-path ()
  "Find the virtualenv path that poetry is using."
  (let ((output (shell-command-to-string "poetry show -v")))
    (save-match-data
      (and (string-match "Using virtualenv: \\(.*\\)" output)
           (match-string 1 output)))))

(defun poetry-to-pyright (&optional source-control-witness)
  "Create the configuration for pyright to point to the correct virtualenv."
  (interactive)
  (if (vc-find-root (buffer-file-name (current-buffer)) (or source-control-witness ".git"))
      (let* ((pyright-config-path (concat (vc-root-dir) "pyrightconfig.json"))
             (venv-name (car (last (split-string (poetry-find-virtualenv-path) "/"))))
             (dir-parts (remove venv-name (split-string (poetry-find-virtualenv-path) "/")))
             (venv-dir (mapconcat 'identity dir-parts "/")))
        (if (not (file-exists-p pyright-config-path))
            (progn
              (message "Writing new pyright config file")
              (write-region (json-encode '(("venvPath" . venv-dir) ("venv" . venv-name))) nil pyright-config-path))
          (progn
            (message "Pyright config exists - adjusting it")
            (let ((pyright-alist (json-read-file pyright-config-path)))
              (setf (alist-get 'venvPath pyright-alist venv-dir) venv-dir)
              (setf (alist-get 'venv pyright-alist venv-name) venv-name)
              (write-region (json-encode pyright-alist) nil pyright-config-path)))))
    (message "Not inside a projectile project. Will not setup pyrightconfig.")))

;; This is apparently needed because evil has some problems with dir-locals.
(defadvice! fix-local-vars (&rest _)
  :before #'turn-on-evil-mode
  (when (eq major-mode 'fundamental-mode)
    (hack-local-variables)))

;; Make local-variables ask for confirmations
;; This was changed: https://github.com/hlissner/doom-emacs/commit/5e7864838a7f65204b8ad3fe96febc603675e24a
(setq enable-local-variables 't)

;; Define own layer for lsp-shortcuts
(map! :leader
      (:prefix-map ("l" . "lsp")
                   (:desc "Find references" "r" #'lsp-find-references
                          (:prefix ("d" . "debug")
                           :desc "Add new breakpoint" "a" #'dap-breakpoint-add
                           :desc "Delete breakpoing" "d" #'dap-breakpoint-delete
                           :desc "Toggle breakpoint" "t" #'dap-breakpoint-toggle))))

(defun my-update-env (fn)
  ;; Update the environment in emacs - should be called from a shell with the
  ;; desired environment
  (let ((str
         (with-temp-buffer
           (insert-file-contents fn)
           (buffer-string))) lst)
    (setq lst (split-string str "\000"))
    (while lst
      (setq cur (car lst))
      (when (string-match "^\\(.*?\\)=\\(.*\\)" cur)
        (setq var (match-string 1 cur))
        (setq value (match-string 2 cur))
        (setenv var value))
      (setq lst (cdr lst)))))

(defun doom/ediff-init-and-example ()
  "ediff the current `init.el' with the example in doom-emacs-dir"
  (interactive)
  (ediff-files (concat doom-private-dir "init.el")
               (concat doom-emacs-dir "templates" "/" "init.example.el")))

;; Setup doom emacs for fish
(setq shell-file-name (executable-find "bash"))

(setq-default vterm-shell "/usr/bin/fish")
(setq-default explicit-shell-file-name "/usr/bin/fish")
