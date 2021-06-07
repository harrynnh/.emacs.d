(defvar efs/default-font-size 160)
(defvar efs/default-variable-font-size 160)
;; Make frame transparency overridable
(defvar efs/frame-transparency '(95 . 95))
(setq mac-option-modifier 'meta)

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))

(setq inhibit-startup-message t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar
;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
;; Wrap long lines
(global-visual-line-mode 1)

(set-face-attribute 'default nil :font "Fira Mono for Powerline" :height efs/default-font-size)
;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Mono for Powerline" :height efs/default-font-size)
;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :init (load-theme 'doom-zenburn t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; Prefer g-prefixed coreutils version of standard utilities when available
  (let ((gls (executable-find "gls")))
    (when gls (setq insert-directory-program gls)))

  (use-package dired
    :ensure nil
    :commands (dired dired-jump)
    :bind (("C-x C-j" . dired-jump))
    :custom ((dired-listing-switches "-agho --group-directories-first")))
  (use-package dired-single
    :commands (dired dired-jump))

  (use-package all-the-icons-dired
    :hook (dired-mode . all-the-icons-dired-mode))

  (use-package dired-open
    :commands (dired dired-jump)
    :config
    ;; Doesn't work as expected!
    ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
    (setq dired-open-extensions '(("png" . "feh")
                                  ("mkv" . "mpv"))))

  (use-package dired-hide-dotfiles
    :hook (dired-mode . dired-hide-dotfiles-mode))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/workspace/")
    (setq projectile-project-search-path '("~/workspace/")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package company
  :ensure t
  :init
  ;;:after lsp-mode
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (define-key company-mode-map (kbd "M-/") 'company-complete)
  (define-key company-mode-map [remap completion-at-point] 'company-complete)
  (define-key company-mode-map [remap indent-for-tab-command] 'company-indent-or-complete-common)
  ;; :hook ((prog-mode-hook . company-mode)
  ;;        (org-src-mode-hook . company-mode))
  ;; :bind (:map company-active-map
  ;;       ("<tab>" . company-complete-common-or-cycle))
  :custom
  (company-minimum-prefix-length 3)
  (company-idle-delay 0.36)
  (company-tooltip-align-annotations 't))
(use-package company-box
  :after company
  :hook (company-mode . company-box-mode))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :bind (:map org-mode-map
              ("C-c i". org-toggle-item))
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/org/work.org"
          "~/org/habit.org"
          "~/org/birthday.org"
          "~/org/journal.org"))
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("work.org" :maxlevel . 1)
      ("habit.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
 (advice-add 'org-agenda-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/org/work.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/org/journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/org/journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/org/journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)))

  (efs/org-font-setup))
(global-set-key (kbd "C-c c") 'org-capture)
(define-key global-map (kbd "C-c a") 'org-agenda)

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;; (defun org-export-output-file-name-modified (orig-fun extension &optional subtreep pub-dir)
;;   (unless pub-dir
;;     (setq pub-dir "../output")
;;     (unless (file-directory-p pub-dir)
;;       (make-directory pub-dir)))
;;   (apply orig-fun extension subtreep pub-dir nil))
;; (advice-add 'org-export-output-file-name :around #'org-export-output-file-name-modified)

(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("r" . "src R")))

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(defun efs/org-start-presentation ()
  (setq text-scale-mode-amount 3)
  (org-display-inline-images)
  (text-scale-mode 1))

(defun efs/org-end-presentation ()
  (text-scale-mode 0))

(use-package org-tree-slide
  :defer t
  :after org
  :commands org-tree-slide-mode
  :hook ((org-tree-slide-play . efs/org-start-presentation)
         (org-tree-slide-stop . efs/org-end-presentation))
  :config
  (setq org-tree-slide-slide-in-effect t
        org-tree-slide-activate-message "Presentation started."
        org-tree-slide-deactivate-message "Presentation ended."
        org-tree-slide-header t
        org-image-actual-width nil))

(use-package org-roam
  :ensure t
  :hook (after-init . org-roam-mode)
  :custom
  (org-roam-db-update-method 'immediate)
  (org-roam-directory "~/org/kalapa/")
  ;; (org-roam-directory "/tmp/slip-box/")
  (org-roam-index-file "index.org")
  (org-roam-dailies-directory "scratch/")
  :bind (:map org-roam-mode-map
         (("C-c m l" . org-roam)
          ("C-c m F" . org-roam-find-file)
          ("C-c m r" . org-roam-find-ref)
          ("C-c m ." . org-roam-find-directory)
          ("C-c m d" . org-roam-dailies-map)
          ("C-c m j" . org-roam-jump-to-index)
          ("C-c m b" . org-roam-switch-to-buffer)
          ("C-c m g" . org-roam-graph))
         :map org-mode-map
         (("C-c m i" . org-roam-insert)))
  :config
  (setq org-roam-capture-templates
        '(("d" "default" plain
           (function org-roam-capture--get-point)
           "%?"
           :file-name "%<%Y%m%d%H%M%S>_${slug}"
           :head "#+title: ${title}\n#+created: %u\n#+last_modified: %U\n\n"
           :unnarrowed t))
        org-roam-capture-ref-templates
        '(("r" "ref" plain
           (function org-roam-capture--get-point)
           ""
           :file-name "web/${slug}"
           :head "#+title: ${title}\n#+roam_key: ${ref}\n#+created: %u\n#+last_modified: %U\n\n%(zp/org-protocol-insert-selection-dwim \"%i\")"
           :unnarrowed t)
          ("i" "incremental" plain
           (function org-roam-capture--get-point)
           "* %?\n%(zp/org-protocol-insert-selection-dwim \"%i\")"
           :file-name "web/${slug}"
           :head "#+title: ${title}\n#+roam_key: ${ref}\n#+created: %u\n#+last_modified: %U\n\n"
           :unnarrowed t
           :empty-lines-before 1))
        org-roam-dailies-capture-templates
        '(("d" "default" entry
           #'org-roam-capture--get-point
           "* %?"
           :file-name "scratch/%<%Y-%m-%d>"
           :head "#+title: %<%Y-%m-%d>\n\n"
           :add-created t))))

(use-package org-ref
  :ensure t
  :after (org org-roam)
  :config
  (setq org-ref-bibliography-notes "~/org/bib/notes.org"
        org-ref-default-bibliography '("~/org/bib/ref.bib")
        org-ref-pdf-directory "~/papers/"
        org-ref-show-broken-links nil))
;;(setq bibtex-dialect 'biblatex)

(defvar orb-title-format "${author-or-editor-abbrev} (${date}).  ${title}."
"Format of the title to use for `orb-templates'.")
(use-package org-roam-bibtex
    :ensure t
    :hook (org-roam-mode . org-roam-bibtex-mode)
    :bind (:map org-roam-bibtex-mode-map
           (("C-c m f" . orb-find-non-ref-file))
           :map org-mode-map
           (("C-c m t" . orb-insert-non-ref)
            ("C-c m a" . orb-note-actions)))
    :init
    :custom
    (orb-autokey-format "%a%y")
    (orb-templates
     `(("r" "ref" plain
        (function org-roam-capture--get-point)
        ""
        :file-name "refs/${citekey}"
        :head ,(s-join "\n"
                       (list
                        (concat "#+title: "
                                orb-title-format)
                        "#+roam_key: ${ref}"
                        "#+created: %U"
                        "#+last_modified: %U\n\n"))
        :unnarrowed t)
       ("p" "ref + physical" plain
        (function org-roam-capture--get-point)
        ""
        :file-name "refs/${citekey}"
        :head ,(s-join "\n"
                       (list
                        (concat "#+title: "
                                orb-title-format)
                        "#+roam_key: ${ref}"
                        ""
                        "* Notes :physical:")))
       ("n" "ref + noter" plain
        (function org-roam-capture--get-point)
        ""
        :file-name "refs/${citekey}"
        :head ,(s-join "\n"
                       (list
                        (concat "#+title: "
                                orb-title-format)
                        "#+roam_key: ${ref}"
                        ""
                        "* Notes :noter:"
                        ":PROPERTIES:"
                        ":NOTER_DOCUMENT: %(orb-process-file-field \"${citekey}\")"
                        ":NOTER_PAGE:"
                        ":END:"))))))

(setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f"))

(with-eval-after-load "ox-latex"
    (add-to-list 'org-latex-classes
          '("koma-article"
             "\\documentclass[
  ,a4paper
  ,DIV=12
  ,12pt
  ,abstract
  ]{scrartcl}
  \\author{Harry Nguyen}"
             ("\\section{%s}" . "\\section*{%s}")
             ("\\subsection{%s}" . "\\subsection*{%s}")
             ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
             ("\\paragraph{%s}" . "\\paragraph*{%s}")
             ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(use-package pdf-tools
 :pin manual
 :magic ("%PDF" . pdf-view-mode)
 :config
 (pdf-tools-install :no-query)
 (setq pdf-view-use-scaling t)
 (setq-default pdf-view-display-size 'fit-page)
 ;; automatically annotate highlights
 (setq pdf-annot-activate-created-annotations t)
 ;; Speed up start up by not looking for unicode symbols
 (setq pdf-view-use-unicode-ligther nil)
 ;; use normal isearch
 (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
 ;; turn off cua so copy works
 (add-hook 'pdf-view-mode-hook (lambda () (cua-mode 0)))
 (setq pdf-view-resize-factor 1.1)
 (define-key pdf-view-mode-map (kbd "h") 'pdf-annot-add-highlight-markup-annotation)
 (define-key pdf-view-mode-map (kbd "t") 'pdf-annot-add-text-annotation)
 (define-key pdf-view-mode-map (kbd "D") 'pdf-annot-delete))

;; convert org to html with jekyll
(setq org-publish-project-alist
      '(("harrynnh.github.io"
         ;; Path to org files.
         :base-directory "~/harrynnh.github.io/org"
         :base-extension "org"

         ;; Path to Jekyll Posts
         :publishing-directory "~/harrynnh.github.io/_posts/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-extension "html"
         :body-only t
         )))

(electric-pair-mode 1)
(setq electric-pair-preserve-balance nil)

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :ensure t
  ;;:commands (lsp lsp-deferred)
 ;;  :config
 ;;  (lsp-register-custom-settings
 ;; '(("pyls.plugins.pyls_mypy.enabled" t t)
 ;;   ("pyls.plugins.pyls_mypy.live_mode" nil t)
 ;;   ("pyls.plugins.pyls_black.enabled" t t)
 ;;   ("pyls.plugins.pyls_isort.enabled" t t)))
  :hook ((lsp-mode . efs/lsp-mode-setup)
         (python-mode . lsp)
         (prog-mode-hook . lsp)
         (ess-mode . lsp)
         (lsp-mode-hook . lsp-enable-which-key-integration))
  :init
  (setq lsp-keymap-prefix "C-c l"))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-sideline-show-hover t
              lsp-ui-sideline-delay 0.5
              lsp-ui-doc-delay 5
              lsp-ui-sideline-ignore-duplicates t
              lsp-ui-doc-position 'bottom
              lsp-ui-doc-alignment 'frame
              lsp-ui-doc-header nil
              lsp-ui-doc-include-signature t
              lsp-ui-doc-use-childframe t))
(use-package dap-mode
  :after lsp-mode)

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands dap-debug
  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup)) ;; Automatically installs Node debug adapter if needed

(use-package yasnippet
:ensure t
:init
(yas-global-mode 1)
:after lsp)

;; (eval-after-load 'python-mode
;;   '(bind-key "C-RET" 'python-shell-send-statement))
(setq python-indent-guess-indent-offset-verbose nil)
    ;;(setq python-shell-interpreter "python3")
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --simple-prompt --pprint")

(setenv "WORKON_HOME" "/usr/local/anaconda3/envs")
(use-package pyvenv
  :demand t
  :config
  (setq pyvenv-workon "emacs")  ; Default venv
  (pyvenv-tracking-mode 1))
  ;;(pyvenv-mode 1))
;;(pyvenv-activate "/usr/local/anaconda3/envs/emacs")

;; Cancel fancy comments ess r
(defun my-ess-settings ()
  (setq-local ess-indent-with-fancy-comments nil))
;; Bindings for pipe
(defun my_pipe_operator ()
  "R/ESS %>% operator"
  (interactive)
  (just-one-space 1)
  (insert "%>%")
  (reindent-then-newline-and-indent))
;; ESS-R setup
(use-package ess
  :ensure t
  :init (require 'ess-site)
  :hook ((ess-mode . my-ess-settings)
         (org-babel-after-execute . org-display-inline-images))
  :bind (:map ess-mode-map
              (";" . ess-insert-assign)
              ("M-_" . my_pipe_operator)
              :map inferior-ess-mode-map
              (";" . ess-insert-assign)
              ("M-_" . my_pipe_operator)))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))
