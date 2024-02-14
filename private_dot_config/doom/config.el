(message "> Initializing Emacs")
(setq user-full-name         "Christian Romney"
      user-mail-address      "christian.a.romney@gmail.com"
      calendar-location-name "Pembroke Pines, FL"
      ;; for sunrise, sunset, phases of moon
      calendar-latitude      26.0
      calendar-longitude     -80.3)

(setq doom-scratch-initial-major-mode 'lisp-interaction-mode
      initial-major-mode              'lisp-interaction-mode
      inhibit-startup-message         t)

(setq confirm-kill-emacs              nil
      use-short-answers               t
      enable-dir-local-variables      t
      enable-local-variables          t
      kill-buffer-query-functions     (remq 'process-kill-buffer-query-function
                                            kill-buffer-query-functions))

(setq native-comp-async-report-warnings-errors 'silent)
(setq shell-file-name (executable-find "bash"))
(message "> configuring: ")

(message "  ...custom functions...")

(require 'cl-lib)
(require 'cl-seq)

(defun rk/get-ffmpeg-device ()
  "Gets the list of devices available to ffmpeg.
The output of the ffmpeg command is pretty messy, e.g.
  [AVFoundation indev @ 0x7f867f004580] AVFoundation video devices:
  [AVFoundation indev @ 0x7f867f004580] [0] FaceTime HD Camera (Built-in)
  [AVFoundation indev @ 0x7f867f004580] AVFoundation audio devices:
  [AVFoundation indev @ 0x7f867f004580] [0] Cam Link 4K
  [AVFoundation indev @ 0x7f867f004580] [1] MacBook Pro Microphone
so we need to parse it to get the list of devices.
The return value contains two lists, one for video devices and one for audio devices.
Each list contains a list of cons cells, where the car is the device number and the cdr is the device name."
  (unless (string-equal system-type "darwin")
    (error "This function is currently only supported on macOS"))

  (let ((lines (string-split (shell-command-to-string "ffmpeg -list_devices true -f avfoundation -i dummy || true") "\n")))
    (cl-loop with at-video-devices = nil
             with at-audio-devices = nil
             with video-devices = nil
             with audio-devices = nil
             for line in lines
             when (string-match "AVFoundation video devices:" line)
             do (setq at-video-devices t
                      at-audio-devices nil)
             when (string-match "AVFoundation audio devices:" line)
             do (setq at-audio-devices t
                      at-video-devices nil)
             when (and at-video-devices
                       (string-match "\\[\\([0-9]+\\)\\] \\(.+\\)" line))
             do (push (cons (string-to-number (match-string 1 line)) (match-string 2 line)) video-devices)
             when (and at-audio-devices
                       (string-match "\\[\\([0-9]+\\)\\] \\(.+\\)" line))
             do (push (cons (string-to-number (match-string 1 line)) (match-string 2 line)) audio-devices)
             finally return (list (nreverse video-devices) (nreverse audio-devices)))))

(defun rk/find-device-matching (string type)
  "Get the devices from `rk/get-ffmpeg-device' and look for a device
matching `STRING'. `TYPE' can be :video or :audio."
  (let* ((devices (rk/get-ffmpeg-device))
         (device-list (if (eq type :video)
                          (car devices)
                        (cadr devices))))
    (cl-loop for device in device-list
             when (string-match-p string (cdr device))
             return (car device))))

(defcustom rk/default-audio-device nil
  "The default audio device to use for whisper.el and outher audio processes."
  :type 'string)

(defun rk/select-default-audio-device (&optional device-name)
  "Interactively select an audio device to use for whisper.el and other audio processes.
If `DEVICE-NAME' is provided, it will be used instead of prompting the user."
  (interactive)
  (let* ((audio-devices (cadr (rk/get-ffmpeg-device)))
         (indexes (mapcar #'car audio-devices))
         (names (mapcar #'cdr audio-devices))
         (name (or device-name (completing-read "Select audio device: " names nil t))))
    (setq rk/default-audio-device (rk/find-device-matching name :audio))
    (when (boundp 'whisper--ffmpeg-input-device)
      (setq whisper--ffmpeg-input-device (format ":%s" rk/default-audio-device)))))

(defun cr/list-microphones ()
  "Gets the system audio devices"
  ;; rk/get-ffmpeg-device returns video then audio alists
  (cl-second (rk/get-ffmpeg-device)))

(defun cr/re-find-microphone (regex)
  (cl-rassoc regex (cr/list-microphones)
             :test (lambda (pred s) (string-match-p pred s))))

(defun cr/microphone-name (device)
  "Extracts the label from the microphone DEVICE pair (index . label)."
  (cdr device))

(defun cr/mkdirp (path)
  "Ensures the directory path exists, creating any parents as
needed. Returns the expanded pathname."
  (let ((abspath (expand-file-name path)))
    (if (file-exists-p abspath)
        abspath
      (progn
        (make-directory abspath 'parents)
        abspath))))

(defun cr/touch (path)
  "Ensures the file path exists, creating any parents as needed.
Returns the expanded pathname."
  (let ((abspath (expand-file-name path)))
    (if (file-exists-p abspath)
        abspath
      (progn
        (make-empty-file abspath 'parents)
        abspath))))

(defun cr/read-file-as-string (path)
  "Reads the given file as a string."
  (string-trim
   (with-temp-buffer
     (insert-file-contents (expand-file-name path))
     (buffer-string))))

(defun cr/keychain-api-token-for-host (host)
  "Reads the keychain internet password for the given host."
  (string-trim
   (shell-command-to-string
    (string-join `("security find-internet-password -s " ,host " -w") ""))))

(defun cr/port-open-p (port)
  "Returns t if the given port is in use, nil otherwise."
  (= 0 (call-process "lsof" nil nil nil "-P" "-i"
                     (concat "TCP:" (number-to-string port)))))

(defun cr/read-auth-field (field &rest params)
  (require 'auth-source)
  (let ((match (car (apply #'auth-source-search params))))
    (if match
        (let ((secret (plist-get match field)))
          (if (functionp secret)
              (funcall secret)
            secret))
      (error "%s not found for %S" field params))))

(defun cr/read-auth-username (&rest params)
  (apply #'cr/read-auth-field :user params))

(defun cr/read-auth-password (&rest params)
  (apply #'cr/read-auth-field :secret params))

(defun cr/just-one-space ()
  "Command to delete all but one whitespace character."
  (interactive)
  (just-one-space -1))

(defun cr/delete-horizontal-space ()
  "Command to delete all whitespace. Depends on smartparens, which
Doom loads early."
  (interactive)
  (just-one-space -1)
  (sp-backward-delete-char))

(message "  ...appearance...")
(setq default-frame-alist
      '((fullscreen . maximized)))

(setq display-line-numbers-type       nil
      doom-theme 'doom-tomorrow-day
      doom-font (font-spec :family "JetBrains Mono" :size 20)
      doom-variable-pitch-font (font-spec :family "Metropolis" :size 18)
      doom-serif-font (font-spec :family "Times New Roman" :size 20)
      doom-themes-enable-bold     t
      doom-themes-enable-italic   t
      doom-themes-padded-modeline t)

(setq-default tab-width 2)
(setq-default cursor-type 'bar)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook #'rainbow-mode)

(message "  ...Doom customizations...")
(doom-themes-visual-bell-config)

(add-to-list 'doom-large-file-size-alist
             '("\\.\\(?:clj[sc]?\\|dtm\\|edn\\)\\'" . 0.5))

;; file locations
(setq doom-cache-dir user-emacs-directory)
(setq +file-templates-dir (cr/mkdirp (expand-file-name "snippets" doom-private-dir)))
(setq +default-want-RET-continue-comments nil)

(message "  ...built-ins...")
(setq abbrev-file-name (expand-file-name  "etc/abbrev_defs" doom-private-dir)
      save-abbrevs     'silent)

(setq-default abbrev-mode t)

(use-package auto-save-mode
  :hook (org-mode . auto-save-visited-mode)
  :init
  (setq auto-save-visited-interval 5)) ;; seconds

(setq bookmark-default-file     (expand-file-name "etc/bookmarks" doom-private-dir)
      bookmark-old-default-file bookmark-default-file
      bookmark-file             bookmark-default-file
      bookmark-sort-flag        t)

(after! dired
  (add-hook 'dired-mode-hook #'diredfl-mode)
  (map!
   :map dired-mode-map
   "C-l" #'dired-up-directory)
  (when IS-MAC
    (setq insert-directory-program "gls"
          dired-listing-switches   "-aBhl --group-directories-first")
    (map!
     :map dired-mode-map
     "r"  #'+macos/reveal-in-finder)))

(message "  ...completion...")
(when (modulep! :completion vertico)
  (use-package! vertico
    :demand t
    :defer t
    :bind
    (("C-x B"    . #'+vertico/switch-workspace-buffer)
     :map vertico-map
     ("C-l"      . #'vertico-directory-up)) ;; behave like helm to go up a level
    :config
    (setq vertico-cycle t
          read-extended-command-predicate #'command-completion-default-include-p
          orderless-matching-styles     '(orderless-literal
                                          orderless-initialism
                                          orderless-regexp)
          completion-category-defaults  '((email (styles substring)))
          completion-category-overrides '((file (styles +vertico-basic-remote
                                                        orderless
                                                        partial-completion)))

          marginalia-align              'right))

  (use-package! consult
    :defer t
    :config
    (setq consult-grep-args
          "ggrep --null --line-buffered --color=never --ignore-case \
--exclude-dir=.git --line-number -I -r .")
    :bind
    (("M-g g"   . #'consult-goto-line)
     ("M-i"     . #'consult-imenu)
     ("C-c M-o" . #'consult-multi-occur)
     ("C-x b"   . #'consult-buffer)
     ("C-x 4 b" . #'consult-buffer-other-window)
     ("C-x 5 b" . #'consult-buffer-other-frame)
     ("C-c s r" . #'consult-ripgrep)
     ("C-c s g" . #'consult-git-grep)
     ("C-x r b" . #'consult-bookmark)
     ("C-x r i" . #'consult-register-load)
     ("C-x r s" . #'consult-register-store)
     ("C-h P"   . #'describe-package)
     ("C-h W"   . #'consult-man)))

  (use-package! embark
    :defer t
    :bind
    (("C-." . embark-act)         ;; pick some comfortable binding
     ("M-." . embark-dwim)        ;; good alternative: M-.
     ) ;; alternative for `describe-bindings'
    :init
    ;; Replace the key help with a completing-read interface
    (setq prefix-help-command #'embark-prefix-help-command)
    :config
    ;; Hide the modeline of the Embark live/completions buffers
    (add-to-list 'display-buffer-alist
                 '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

  ;; Consult users will also want the embark-consult package.
  (use-package! embark-consult
    :defer t
    :after (embark consult)
    :demand t ; only necessary if you have the hook below
    ;; if you want to have consult previews as you move around an
    ;; auto-updating embark collect buffer
    :hook
    (embark-collect-mode . consult-preview-at-point-mode)))

(when (modulep! :completion company)
  (use-package! company
    :defer t
    :config
    (setq company-idle-delay 0.5)))

(message "  ...navigation...")
(use-package! pulsar
  :defer t
  :after consult
  :init
  (setq pulsar-pulse t
        pulsar-delay 0.065
        pulsar-iterations 9
        pulsar-face 'pulsar-green
        pulsar-highlight-face 'pulsar-red)
  (pulsar-global-mode t)
  :config
  ;; integration with the `consult' package:
  (add-hook 'consult-after-jump-hook #'pulsar-recenter-middle)
  (add-hook 'consult-after-jump-hook #'pulsar-reveal-entry)

  ;; integration with the built-in `isearch':
  (add-hook 'isearch-mode-end-hook #'pulsar-recenter-middle)
  (advice-add 'isearch-forward :after #'pulsar-recenter-middle)
  (advice-add 'isearch-repeat-forward :after #'pulsar-recenter-middle)
  (advice-add 'isearch-backward :after #'pulsar-recenter-middle)
  (advice-add 'isearch-repeat-backward :after #'pulsar-recenter-middle)

  ;; integration with the built-in `imenu':
  (add-hook 'imenu-after-jump-hook #'pulsar-recenter-top)
  (add-hook 'imenu-after-jump-hook #'pulsar-reveal-entry))

(when (modulep! :checkers spell)
  (message "  ...spell checking...")
  (setq spell-fu-directory
        (cr/mkdirp (expand-file-name "etc/spell-fu/" doom-private-dir)))
  (add-hook 'spell-fu-mode-hook
            (lambda ()
              (spell-fu-dictionary-add (spell-fu-get-ispell-dictionary "en"))
              (spell-fu-dictionary-add
               (spell-fu-get-personal-dictionary
                "en-personal"
                (expand-file-name "aspell.en.pws" spell-fu-directory))))))

;; main directory
(defvar +info-dir "~/Documents/personal/notes"
  "The root for all notes, calendars, agendas, todos, attachments, and bibliographies.")

(setq org-directory              (expand-file-name "content" +info-dir)
      org-clock-persist-file     (expand-file-name "etc/org-clock-save.el" doom-cache-dir))

;; roam notes
(setq org-roam-directory         (expand-file-name "roam" org-directory)
      org-roam-dailies-directory "journal/"
      org-roam-db-location       (expand-file-name ".org-roam.db" org-directory ))

;; agenda
(setq org-agenda-file-regexp     "\\`[^.].*\\.org\\(\\.gpg\\)?\\'"
      org-agenda-files           (directory-files-recursively org-directory "\\.org$"))

;; (setq warning-suppress-types (append warning-suppress-types '((org-element-cache))))

(after! org
    (add-hook 'org-agenda-mode-hook
              (lambda ()
                (setq org-agenda-files
                      (directory-files-recursively org-directory "\\.org$")))))

;; capture
(setq +org-capture-changelog-file "changelog.org"
      +org-capture-notes-file     "notes.org"
      +org-capture-projects-file  "projects.org"
      +org-capture-todo-file      "todo.org"
      +org-capture-journal-file   "journal.org")

(message "  ...org directories and files...")

(defun cr/markup-word (markup-char)
  "Wraps the active region or the word at point with MARKUP-CHAR."
  (cl-destructuring-bind (text start end)
      (if (use-region-p)
          (list
           (buffer-substring-no-properties (region-beginning) (region-end))
           (region-beginning)
           (region-end))
        (let ((bounds (bounds-of-thing-at-point 'word)))
          (list (thing-at-point 'word)
                (car bounds)
                (cdr bounds))))
    (save-excursion
      (replace-region-contents
       start end
       (lambda ()
         (s-wrap text
                 (char-to-string markup-char)
                 (char-to-string markup-char)))))))

(defun cr/org-italicize-word ()
  (interactive)
  (cr/markup-word #x00002F))

(defun cr/org-bold-word ()
  (interactive)
  (cr/markup-word #x00002A))

(defun cr/org-code-word ()
  (interactive)
  (cr/markup-word #x00007E))

(defun cr/org-underline-word ()
  (interactive)
  (cr/markup-word #x00005F))

(defun cr/org-verbatim-word ()
  (interactive)
  (cr/markup-word #x00003D))

(defun cr/org-strike-word ()
  (interactive)
  (cr/markup-word #x00002B))

(message "  ...org custom markup functions...")

;; which modules to load when org starts
(setq org-modules
      '(ol-bibtex
        ol-bookmark
        org-checklist
        ol-docview
        ol-doi
        org-id
        org-tempo))

(after! org
  ;; startup configuration
  (setq org-startup-with-inline-images t
        org-startup-with-latex-preview t
        org-M-RET-may-split-line       t)

  ;; behaviors
  (setq org-export-html-postamble          nil
        org-hide-emphasis-markers          t
        org-html-validation-link           nil
        org-log-done                       nil
        org-outline-path-complete-in-steps nil
        org-return-follows-link            t
        org-src-window-setup               'current-window
        org-use-fast-todo-selection        t
        org-use-sub-superscripts           "{}")

  ;; agenda
  (setq org-agenda-tags-column            0
        org-agenda-block-separator        ?─
        org-agenda-window-setup           'current-window
        org-agenda-include-diary          t
        org-agenda-show-log               t
        org-agenda-skip-deadline-if-done  t
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-timestamp-if-done t
        org-agenda-start-on-weekday       1
        org-agenda-todo-ignore-deadlines  t
        org-agenda-todo-ignore-scheduled  t
        org-agenda-use-tag-inheritance    nil
        org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-agenda-span 10)))
            (tags-todo "+PRIORITY=\"A\"")
            (tags-todo "work")
            (tags-todo "personal")))
          ("n" "Agenda and all TODOs"
           ((agenda "" ((org-agenda-span 10)))
            (alltodo ""))))
        org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "⭠ now ─────────────────────────────────────────────────")

  ;; refiling
  (setq org-refile-use-cache                   t ;; use C-0 C-c C-w to clear cache
        org-refile-use-outline-path            t
        org-refile-allow-creating-parent-nodes t
        org-refile-targets                     '((nil :maxlevel . 5)
                                                 (org-agenda-files :maxlevel . 5)))
  ;; capture
  (setq org-capture-templates
        `(("t" "Todo" entry (file+headline "todo.org" "Todos")
           "* TODO %^{Task} %^G")))

  ;; todos
  (setq org-todo-keywords
        '((sequence "TODO(t)" "WIP(w)" "PAUSE(p)" "|" "DONE(d)" "KILL(k)" "ASSIGNED(a)")))

  ;; tags
  (setq org-tag-alist
        '((:startgrouptag)
          ("study"      . ?s)
          (:grouptags)
          ("book"       . ?b)
          ("paper"      . ?a)
          (:endgrouptag)
          (:startgrouptag)
          ("work"       . ?w)
          ("personal"   . ?m)
          ("FLAGGED"    . ?f)))

  ;; visual appearance
  (setq org-ellipsis                       "…"
        org-fontify-done-headline          t
        org-fontify-emphasized-text        t
        org-fontify-quote-and-verse-blocks t
        org-fontify-whole-heading-line     t
        org-pretty-entities                t
        org-hide-emphasis-markers t
        org-src-fontify-natively           t
        org-src-tab-acts-natively          t
        org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        org-startup-folded                 t
        org-startup-indented               t)

  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))

  ;; change faces
  (face-spec-set 'org-agenda-date
                 '((default :weight normal)))
  (face-spec-set 'org-agenda-date-weekend
                 '((default :foreground "#399ee6" :weight normal)))
  (face-spec-set 'org-agenda-diary
                 '((default :weight normal :foreground "#86b300")))
  (face-spec-set 'org-agenda-date-today
                 '((default :foreground "#f07171" :slant italic :weight normal)))
  (face-spec-set 'org-modern-tag
                 '((default :weight normal :background "#d1bce5")))
  (set-face-background 'fringe (face-attribute 'default :background))

  ;; keybindings
  (map!
   (:map org-mode-map
    :desc "org markup"
    :prefix ("C-, o" . "org markup word")
    :desc "bold"            "b" #'cr/org-bold-word
    :desc "code"            "c" #'cr/org-code-word
    :desc "italics"         "i" #'cr/org-italicize-word
    :desc "strikethrough"   "s" #'cr/org-strike-word
    :desc "underline"       "u" #'cr/org-underline-word
    :desc "verbatim"        "v" #'cr/org-verbatim-word

    )))
(message "  ...org startup, bindings, agenda, tags, todos...")

;; org-modern-star (appearance)
(after! org
  (setq org-modern-star
        '("◉" "○" "▣" "□" "◈" "◇" "✦" "✧" "✻" "✾"))
  (global-org-modern-mode))
(message "  ...org appearance...")

(defface +calendar-holiday
  '((t . (:inherit pulsar-cyan)))
  "Face for holidays in calendar.")

(defface +calendar-today
  '((t . (:foreground "violet red" :box t)))
  "Face for the current day in calendar.")

(defface +calendar-appointment
  '((t . (:inherit pulsar-yellow)))
  "Face for appointment diary entries in calendar.")

(after! org
  (require 'brazilian-holidays)
  (setq calendar-week-start-day              0
        calendar-mark-holidays-flag          t
        calendar-mark-diary-entries-flag     t
        calendar-christian-all-holidays-flag nil
        calendar-holiday-marker              '+calendar-holiday
        calendar-today-marker                '+calendar-today
        diary-entry-marker                   '+calendar-appointment
        cal-html-directory                   "~/Desktop"
        cal-html-holidays                    t
        diary-file
        (expand-file-name "appointment-diary" org-directory)

        calendar-holidays
        (append holiday-general-holidays
                holiday-local-holidays
                holiday-other-holidays
                holiday-christian-holidays
                holiday-solar-holidays
                brazilian-holidays--general-holidays
                brazilian-holidays-sp-holidays))
  (add-hook 'calendar-today-visible-hook #'calendar-mark-today))
  (message "...org calendar...")

(use-package! org-glossary
  :defer t
  :hook (org-mode . org-glossary-mode)
  :init
  (defface org-glossary-term
  '((default :inherit (popup-tip-face)
     :weight normal))
  "Base face used for term references.")
  :config
  (setq org-glossary-fontify-types-differently nil)
  (map!
   (:map org-mode-map
    :prefix ("C-c y" . "glossary")
    :desc "define term"     "d" #'org-glossary-create-definition
    :desc "goto definition" "g" #'org-glossary-goto-term-definition)))

(message "  ...org glossary...")

(when (modulep! :tools biblio)
  (after! org
    (let ((bib (list (expand-file-name "references.bib" +info-dir))))
      (setq bibtex-completion-bibliography bib)
      (setq citar-bibliography bib))
    (citar-capf-setup))
  (message "  ...org citations, citar..."))

(use-package! graphviz-dot-mode
  :defer t
  :config
  (setq graphviz-dot-indent-width 2))

(after! org
  (when (modulep! :lang plantuml)
    (setq plantuml-default-exec-mode 'jar))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((clojure    . t)
     (css        . t)
     (dot        . t)
     (emacs-lisp . t)
     (gnuplot    . t)
     (java       . t)
     (js         . t)
     (makefile   . t)
     (plantuml   . t)
     (prolog     . t)
     (python     . t)
     (R          . t)
     (ruby       . t)
     (scheme     . t)
     (sed        . t)
     (shell      . t)
     (sql        . t))))

(message "  ...org babel...")

(after! org
  (setq reveal_inter_presentation_links    t
        org-re-reveal-center               t
        org-re-reveal-control              t
        org-re-reveal-default-frag-style   'appear
        org-re-reveal-defaulttiming        nil
        org-re-reveal-fragmentinurl        t
        org-re-reveal-history              nil
        org-re-reveal-hlevel               2
        org-re-reveal-keyboard             t
        org-re-reveal-klipsify-src         t
        org-re-reveal-mousewheel           nil
        org-re-reveal-overview             t
        org-re-reveal-pdfseparatefragments nil
        org-re-reveal-progress             t
        org-re-reveal-rolling-links        nil
        org-re-reveal-title-slide          "%t"
        org-re-reveal-root
        "https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.5.0/reveal.js"))

(message "  ...org reveal...")

(defvar gpt-default-model "gpt-4-turbo-preview"
  "My preferred Open AI GPT model.")

(use-package! openai
  :defer t
  :config
  (setq openai-key (cr/keychain-api-token-for-host "api.openai.com"))
  (message "  ...openai..."))

(use-package! greader
  :defer t
  :config
  (message "  ...greader..."))

(use-package! whisper
  :defer t
  :commands (whisper-run)
  :config
  (setq whisper-install-directory
        (cr/mkdirp (expand-file-name "whisper" doom-cache-dir))
        whisper-model "small"
        whisper-language "en"
        whisper-translate nil)

  (when IS-MAC
    (let ((mic (cr/microphone-name
                (cl-some #'identity
                         (list (cr/re-find-microphone "rode")
                               (cr/re-find-microphone "mac"))))))
      (message (format " using microphone: %s" mic))
      (rk/select-default-audio-device mic))

    (when rk/default-audio-device
      (setq whisper--ffmpeg-input-device (format ":%s" rk/default-audio-device))))
  (message "  ...whisper..."))

(map! :desc "Whisper" "C-s-\\" #'whisper-run)

(use-package! gptel
  :defer t
  :commands (gptel)
  :init
  (setq gptel-model gpt-default-model)
  :config
  (require 'openai)
  (setq gptel-api-key openai-key
        gptel-default-mode 'org-mode)
  (add-hook 'gptel-post-response-hook 'gptel-end-of-response)
  (add-to-list 'gptel-directives
               '(executive-summary .
                 "You are a writing assistant preparing an executive summary. Summarize the main ideas from the text, focusing on strategic elements, impact, value, and metrics. Write professionally, simply, and with concision."))
  (message "  ...gptel..."))

(map! :desc "ChatGPT" "C-c C-|" #'gptel)
;; sends everything up to (point) or the active region
(map! :desc "Send to ChatGPT" "C->" #'gptel-send)

(use-package! codegpt
  :defer t
  :commands (codegpt codegpt-doc codegpt-explain codegpt-fix codegpt-improve)
  :config
  (require 'openai)
  (setq codegpt-tunnel 'chat
        codegpt-model  gpt-default-model))

(map!
   :prefix ("C-c M-h o" . "coding assistant")
   :desc "CodeGPT"        "g" #'codegpt
   :desc "Document code"  "d" #'codegpt-doc
   :desc "Explain code"   "e" #'codegpt-explain
   :desc "Fix code"       "f" #'codegpt-fix
   :desc "Improve code"   "i" #'codegpt-improve)
(message "  ...CodeGPT...")

(use-package! org-ai
  :defer t
  :hook (org-mode . org-ai-mode)
  :config
  (require 'whisper)
  (require 'org-ai-talk)
  (setq org-ai-image-directory (cr/mkdirp (expand-file-name "dall-e" org-directory))
        org-ai-default-completion-model gpt-default-model
        org-ai-default-chat-model gpt-default-model
        org-ai-talk-say-voice "Jamie"
        org-ai-talk-say-words-per-minute 160
        org-ai-default-chat-system-prompt
        "You are a helpful, succinct research and coding assistant running in Emacs.")
  (message "  ...org-ai..."))

(setq blink-matching-paren t
      show-paren-mode t
      show-paren-style 'parenthesis
      show-paren-delay 0)

(pcase-dolist (`(,open . ,close) '(("(" . ")")
                                     ("[" . "]")
                                     ("{" . "}")))
    ;; remove all default rules
    (sp-pair open close :post-handlers nil :unless nil)
    ;; add sole exception
    (sp-pair open close :unless '(:add sp-in-string-p)))

(remove-hook! 'doom-first-buffer-hook #'smartparens-global-mode)
(add-hook! 'doom-first-buffer-hook #'smartparens-global-strict-mode)

(message "  ...smartparens...")

(after! projectile
  (cr/mkdirp (expand-file-name "projectile" doom-cache-dir))

  (setq projectile-cache-file
        (expand-file-name "projectile/projectile.cache" doom-cache-dir)
        projectile-known-projects-file
        (expand-file-name "projectile/projectile.projects" doom-cache-dir))

  (pushnew! projectile-project-root-files "project.clj" "deps.edn"))

(message "  ...projectile...")

(after! magit
  (setq magit-revision-show-gravatars t
        forge-database-file
        (expand-file-name "forge/forge-database.sqlite" doom-cache-dir)
        magit-no-confirm '(stage-all-changes unstage-all-changes)))

(message "  ...magit...")

(use-package! clojure-mode
  :defer t
  :hook (clojure-mode . rainbow-delimiters-mode)
  :config
  (when (modulep! :tools lsp)
    (map! :map clojure-mode-map
          "C-c j d"    #'lsp-ui-doc-glance
          "C-c j i"    #'lsp-ui-imenu)
    (add-hook! '(clojure-mode-local-vars-hook
                 clojurec-mode-local-vars-hook
                 clojurescript-mode-local-vars-hook)
      (defun +clojure-disable-lsp-indentation-h ()
        (setq-local lsp-enable-indentation nil))
      #'lsp!)
    (after! lsp-clojure
      (dolist (m '(clojure-mode
                   clojurec-mode
                   clojurescript-mode
                   clojurex-mode))
        (add-to-list 'lsp-language-id-configuration (cons m "clojure")))
      (dolist (dir '("[/\\\\]\\.clj-kondo\\'"
                     "[/\\\\]\\.cp-cache\\'"
                     "[/\\\\]\\.lsp\\'"
                     "[/\\\\]\\.shadow-cljs\\'"
                     "[/\\\\]\\target\\'"))
        (add-to-list 'lsp-file-watch-ignored dir)))
    (setq lsp-lens-enable          t       ;; enable LSP code lens for inline reference counts
          lsp-file-watch-threshold 2000
          lsp-enable-snippet       t)))

(add-hook! 'clojure-mode-hook :append #'subword-mode)
;; these should be covered by global-smartparents-strict-mode
;;(add-hook! 'clojure-mode-hook #'turn-on-smartparens-strict-mode)
;;(add-hook! 'clojurescript-mode-hook #'turn-on-smartparens-strict-mode)
;;(add-hook! 'clojurec-mode-hook #'turn-on-smartparens-strict-mode)
;;(add-hook! 'clojurex-mode-hook #'turn-on-smartparens-strict-mode)

(message "  ...clojure editing...")

(defun +inf-clojure-run-tests ()
  "Run clojure.test suite for the current namespace."
  (interactive)
  (comint-proc-query (inf-clojure-proc)
                        "(clojure.test/run-tests)\n"))

(defun +inf-clojure-pretty-print ()
  "Pretty print the last repl output"
  (interactive)
  (comint-proc-query (inf-clojure-proc)
                     "(do \n(newline)\n(clojure.pprint/pprint *1))\n"))

(defun +inf-clojure-load-file ()
  "Send a load-file instruction to Clojure to load the current file.
Uses comint-proc-query instead of comint-send-string like
inf-clojure does by default, as that method breaks REPLs for me
with large files for some reason."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (comint-proc-query
     (inf-clojure-proc)
     (format "(do (load-file \"%s\") :loaded)\n" file-name))
    (message "inf-clojure :: Loaded file: %s" file-name)))

(defun +possible-project-file (relative-path)
  (if (not (string-blank-p (projectile-project-root)))
      (let ((path (expand-file-name (concat (projectile-project-root) relative-path))))
        (if (file-exists-p path) path nil))
    nil))

(defun +inf-clojure-socket-repl-connect ()
  (interactive)
  (message "inf-clojure-socket-repl-connect in project %s" (projectile-project-root))
  (let ((default-socket-repl-port 5555)
        (found-port-file (+possible-project-file ".shadow-cljs/socket-repl.port")))
    (cond
     ;; option 1: check for shadow-cljs ephemeral port file
     (found-port-file
      (let ((port (cr/read-file-as-string found-port-file)))
        (message "Connecting clojure socket REPL on ephemeral shadow port %s" port)
        (inf-clojure (cons "localhost" port))))

     ;; option 2: check default port
     ((cr/port-open-p default-socket-repl-port)
      (progn
        (message "Connecting clojure socket REPL on detected open port %d" default-socket-repl-port)
        (inf-clojure (cons "localhost" default-socket-repl-port))))

     ;; option 3: ask me
     (t
      (progn
        (message "Connecting clojure socket REPL interactively")
        (inf-clojure-connect))))))

(defun +inf-clojure-reconfigure ()
  (progn
    (message "Setting clojure completion mode to compliment")
    (inf-clojure-update-feature
     'clojure 'completion
     "(compliment.core/completions \"%s\")")))

(use-package! inf-clojure
  :defer t
  :after clojure
  :config
  (map! :map clojure-mode-map
        "C-c c p"    #'+inf-clojure-pretty-print
        "C-c r c"    #'+inf-clojure-socket-repl-connect
        "C-c j c"    #'inf-clojure
        "C-c j C"    #'inf-clojure-connect
        "C-c j D"    #'inf-clojure-show-var-documentation
        "C-c j e b"  #'inf-clojure-eval-buffer
        "C-c j e d"  #'inf-clojure-eval-defun
        "C-c j e D"  #'inf-clojure-eval-defun-and-go
        "C-c j e f"  #'inf-clojure-eval-last-sexp
        "C-c j e F"  #'inf-clojure-eval-form-and-next
        "C-c j e r"  #'inf-clojure-eval-region
        "C-c j e R"  #'inf-clojure-eval-region-and-go
        "C-c j a"    #'inf-clojure-apropos
        "C-c j l"    #'inf-clojure-arglists
        "C-c j m"    #'inf-clojure-macroexpand
        "C-c j r"    #'inf-clojure-reload
        "C-c j R"    #'inf-clojure-restart
        "C-c j v"    #'inf-clojure-show-ns-vars
        "C-c j t"    #'+inf-clojure-run-tests
        "C-c M-j"    #'+inf-clojure-socket-repl-connect
        "C-c C-q"    #'inf-clojure-quit
        "C-c M-n"    #'inf-clojure-set-ns
        "C-c M-p"    #'+inf-clojure-pretty-print
        "C-c C-e"    #'inf-clojure-eval-last-sexp
        "C-x C-e"    #'inf-clojure-eval-last-sexp
        "C-c C-z"    #'inf-clojure-switch-to-repl
        "C-c C-k"    #'+inf-clojure-load-file
        "C-c ,"      #'inf-clojure-clear-repl-buffer
        :map inf-clojure-mode-map
        "C-c ,"      #'inf-clojure-clear-repl-buffer
        "C-c j R"    #'inf-clojure-restart))

(add-hook! 'inf-clojure-mode-hook #'+inf-clojure-reconfigure)

(message "  ...clojure repl...")

(add-to-list 'auto-mode-alist (cons "\\.adoc\\'" 'adoc-mode))

(message "  ...global keybindings...")
(map! "<s-left>"  #'sp-forward-barf-sexp
      "<s-right>" #'sp-forward-slurp-sexp
      "C-'"       #'avy-goto-line
      "C-:"       #'avy-goto-char
      "C-M-%"     #'anzu-query-replace-regexp
      "C-c M-t"   #'transpose-sentences
      "C-c a"     #'org-agenda
      "C-c g"     #'google-this
      "C-e"       #'move-end-of-line
      "C-x M-s"   #'transpose-sexps
      "C-x M-t"   #'transpose-paragraphs
      "C-x P"     #'print-buffer
      "C-x \\"    #'align-regexp
      "C-x g"     #'magit-status
      "C-x r I"   #'string-insert-rectangle
      "M-%"       #'anzu-query-replace
      "M-/"       #'hippie-expand
      "M-SPC"     #'cr/just-one-space
      "M-\\"      #'cr/delete-horizontal-space
      "M-o"       #'other-window
      "M-p"       #'fill-paragraph)

(message "> Emacs initialization complete.")
