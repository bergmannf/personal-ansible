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
(setq doom-font (font-spec :family "Fira Mono" :size 16 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "sans" :size 16))

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

(use-package! indium
  :config
  (set-company-backend! 'indium-repl-mode 'company-indium-repl))

(after! lsp-rust-analyzer
  (setq lsp-rust-analyzer-server-display-inlay-hints t))

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

; Make local-variables ask for confirmations
;; This was changed: https://github.com/hlissner/doom-emacs/commit/5e7864838a7f65204b8ad3fe96febc603675e24a
(setq enable-local-variables 't)

;; Setup MU4E
(setq smtpmail-smtp-server "smtp.gmail.com")
(setq smtpmail-smtp-service 587)

(set-email-account! "gmail.com"
  '((mu4e-sent-folder       . "/gmail/Sent")
    (mu4e-drafts-folder     . "/gmail/[Google Mail]/Drafts")
    (mu4e-trash-folder      . "/gmail/Trash")
    (mu4e-refile-folder     . "/gmail/[Google Mail]/All Mail")
    (smtpmail-smtp-user     . "bergmann.f@gmail.com")
    (user-mail-address      . "bergmann.f@gmail.com")    ;; only needed for mu < 1.4
    (user-full-name         . "Florian Bergmann")
    (mu4e-compose-signature . "Florian Bergmann"))
  t)
