;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; romney-light-theme.el - inspired by Ayu Light / doom-ayu-light
(require 'doom-themes)

;;; Variables
(defgroup romney-light-theme nil
  "Options for the `romney-light' theme."
  :group 'doom-themes)

(defcustom romney-light-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'romney-light-theme
  :type 'boolean)

(defcustom romney-light-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'romney-light-theme
  :type 'boolean)

(defcustom romney-light-comment-bg romney-light-brighter-comments
  "If non-nil, comments will have a subtle, darker background. Enhancing their
legibility."
  :group 'romney-light-theme
  :type 'boolean)

(defcustom romney-light-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'romney-light-theme
  :type '(choice integer boolean))

(defvar romney-light-color-red        "#e07875") ;
(defvar romney-light-color-orange     "#eb9250") ;
(defvar romney-light-color-green      "#8fb236") ;
(defvar romney-light-color-teal       "#6dbd9b") ;
(defvar romney-light-color-yellow     "#e8b15c") ;
(defvar romney-light-color-blue       "#46739E") ;
(defvar romney-light-color-dark-blue  "#005478") ;
(defvar romney-light-color-magenta    "#9d7cc7") ;
(defvar romney-light-color-violet     "#7b78b4") ;
(defvar romney-light-color-cyan       "#579ce0") ;
(defvar romney-light-color-dark-cyan  "#3295BE") ;
(defvar romney-light-color-dark-grey  "#63686C") ;

(def-doom-theme romney-light
  "A light theme inspired by Ayu Light."

  ;; name        default   256       16
  ((bg         '("#f8f9fa" "white"   "white"        ))
   (fg         '("#63686C" "#63686C" "black"        ))

   ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
   ;; but can also be useful as a basis for subtle highlights (e.g. for hl-line
   ;; or region), especially when paired with the `doom-darken', `doom-lighten',
   ;; and `doom-blend' helper functions.
   (bg-alt     '("#fcfcfc" "white"   "white"        ))
   (fg-alt     '("#c7c7c7" "#c7c7c7" "brightblack"  ))

   ;; These should represent a spectrum from bg to fg, where base0 is a starker
   ;; bg and base8 is a starker fg. For example, if bg is light grey and fg is
   ;; dark grey, base0 should be white and base8 should be black.
   (base0      '("#fcfcfc" "#f0f0f0" "white"        ))
   (base1      '("#e7e7e7" "#e7e7e7" "brightblack"  ))
   (base2      '("#dfdfdf" "#dfdfdf" "brightblack"  ))
   (base3      '("#c6c7c7" "#c6c7c7" "brightblack"  ))
   (base4      '("#9ca0a4" "#9ca0a4" "brightblack"  ))
   (base5      '("#383a42" "#424242" "brightblack"  ))
   (base6      '("#202328" "#2e2e2e" "brightblack"  ))
   (base7      '("#1c1f24" "#1e1e1e" "brightblack"  ))
   (base8      '("#1b2229" "black"   "black"        ))

   (grey       base4)
   (red        '("#e07875" "#e07875" "red"          ))
   (orange     '("#eb9250" "#eb9250" "brightred"    ))
   (yellow     '("#e8b15c" "#e8b15c" "yellow"       ))
   (green      '("#8fb236" "#8fb236" "green"        ))
   (teal       '("#6dbd9b" "#6dbd9b" "brightgreen"  ))
   (blue       '("#46739E" "#46739E" "brightblue"   ))
   (dark-blue  '("#005478" "#005478" "blue"         ))
   (cyan       '("#579CE0" "#579CE0" "brightcyan"   ))
   (dark-cyan  '("#3295BE" "#3295BE" "cyan"         ))
   (magenta    '("#9d7cc7" "#9d7cc7" "magenta"      ))
   (violet     '("#7b78b4" "#7b78b4" "brightmagenta"))

   ;; These are the "universal syntax classes" that doom-themes establishes.
   ;; These *must* be included in every doom themes, or your theme will throw an
   ;; error, as they are used in the base theme defined in doom-themes-base.
   (highlight      dark-blue)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      dark-blue)
   (comments       (if romney-light-brighter-comments base2 base4))
   (doc-comments   (doom-darken comments 0.15))
   (builtin        red)
   (constants      magenta)
   (keywords       orange)
   (operators      orange)
   (type           cyan)
   (functions      yellow)
   (methods        yellow)
   (strings        green)
   (numbers        magenta)
   (variables      fg)
   (region         `(,(doom-darken (car bg-alt) 0.1) ,@(doom-darken (cdr base0) 0.3)))
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; These are extra color variables used only in this theme; i.e. they aren't
   ;; mandatory for derived themes.
   (modeline-fg              fg)
   (modeline-fg-alt          (doom-blend
                              violet base4
                              (if romney-light-brighter-modeline 0.5 0.2)))
   (modeline-bg              (if romney-light-brighter-modeline
                               (doom-darken base3 0.05)
                               base3))
   (modeline-bg-alt          (if romney-light-brighter-modeline
                               (doom-darken base3 0.1)
                               base3))
   (modeline-bg-inactive     (doom-darken bg 0.1))
   (modeline-bg-alt-inactive `(,(doom-darken (car bg-alt) 0.05) ,@(cdr base2))) ;;

   (-modeline-pad
    (when romney-light-padded-modeline
      (if (integerp romney-light-padded-modeline) romney-light-padded-modeline 6))))

  ;;;; Base theme face overrides
  (((font-lock-comment-face &override)
    :background (if romney-light-brighter-comments base0 'unspecified))
   ((font-lock-doc-face &override) :slant 'italic)
   ((font-lock-escape-face &override) :foreground teal)
   ((line-number &override) :foreground (doom-lighten base4 0.15))
   ((line-number-current-line &override) :foreground base8)
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground (if romney-light-brighter-modeline base8 highlight))
   (shadow :foreground base4)
   (tooltip :background base1 :foreground fg)

   ;;;; centaur-tabs
   (centaur-tabs-unselected :background bg-alt :foreground base4)
   ;;;; css-mode <built-in> / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)
   ;;;; doom-modeline
   (doom-modeline-bar :background (if romney-light-brighter-modeline modeline-bg highlight))

   ;;;; dired
   ((dired-header &override)  :foreground orange :weight 'bold)
   ((dired-directory &override)  :foreground green)


   ;;;; ediff <built-in>
   (ediff-current-diff-A        :foreground red   :background (doom-lighten red 0.8))
   (ediff-current-diff-B        :foreground green :background (doom-lighten green 0.8))
   (ediff-current-diff-C        :foreground blue  :background (doom-lighten blue 0.8))
   (ediff-current-diff-Ancestor :foreground teal  :background (doom-lighten teal 0.8))
    ;; refined diff
   (ediff-fine-diff-A           :slant 'italic :foreground red   :background (doom-lighten red 0.8))
   (ediff-fine-diff-B           :slant 'italic :foreground green :background (doom-lighten green 0.8))
   (ediff-fine-diff-C           :slant 'italic :foreground blue  :background (doom-lighten blue 0.8))
   (ediff-fine-diff-Ancestor    :slant 'italic :foreground teal  :background (doom-lighten teal 0.8))
   ;;;; fringe
   ((fringe &override) :background bg)

   ;;;; helm
   (helm-candidate-number :background blue :foreground bg)
   ;;;; lsp-mode
   (lsp-ui-doc-background      :background base0)
   ;;;; magit
   (magit-blame-heading     :foreground orange :background bg-alt)
   (magit-diff-removed :foreground (doom-darken red 0.2) :background (doom-blend red bg 0.1))
   (magit-diff-removed-highlight :foreground red :background (doom-blend red bg 0.2) :bold bold)
   ;;;; markdown-mode
   (markdown-markup-face     :foreground base5)
   (markdown-header-face     :inherit 'bold :foreground red)
   ((markdown-code-face &override)       :background base1)
   (mmm-default-submode-face :background base1)

   ;;;; outline <built-in>
   ((outline-1 &override) :foreground orange)
   ((outline-2 &override) :foreground cyan)
   ((outline-3 &override) :foreground magenta)
   ((outline-4 &override) :foreground yellow)
   ((outline-5 &override) :foreground green)
   ((outline-6 &override) :foreground red)
   ((outline-7 &override) :foreground teal)
   ((outline-8 &override) :foreground dark-cyan)

   ;;;; org <built-in>
   ((org-agenda-date &override) :weight 'normal)
   ((org-agenda-date-today &override) :foreground red :slant 'italic :weight 'normal)
   ((org-agenda-date-weekend &override) :foreground green :weight 'normal)
   ((org-agenda-diary &override) :foreground green :weight 'bold)
   ((org-block &override) :background (doom-darken bg 0.02))
   ;((org-block-begin-line &override) :foreground fg :slant 'italic)
   (org-ellipsis :underline nil :background bg :foreground base3)
   ((org-quote &override) :background base1)
   ((org-modern-symbol &override) :family "Apple Symbols")
   ((org-modern-tag &override) :background magenta :weight 'normal)

   ;;; pulsar
   ((pulsar-red &override) :background (doom-lighten red 0.6))
   ((pulsar-blue &override) :background (doom-lighten blue 0.7))
   ((pulsar-cyan &override) :background (doom-lighten cyan 0.5))
   ((pulsar-green &override) :background (doom-lighten green 0.6))
   ((pulsar-yellow &override) :background (doom-lighten yellow 0.5))
   ((pulsar-magenta &override) :background (doom-lighten magenta 0.6))

   ;;;; posframe
   (ivy-posframe :background base0)
   ;;;; selectrum
   (selectrum-current-candidate :background base2)
   ;;;; vertico
   (vertico-current :background base2)
   ;;;; solaire-mode
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-alt-inactive
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt-inactive)))
   ;;;; web-mode
   (web-mode-current-element-highlight-face :background dark-blue :foreground bg)
   ;;;; wgrep <built-in>
   (wgrep-face :background base1)
   ;;;; whitespace
   ((whitespace-tab &override)         :background (if (not (default-value 'indent-tabs-mode)) base0 'unspecified))
   ((whitespace-indentation &override) :background (if (default-value 'indent-tabs-mode) base0 'unspecified)))

  ;;;; Base theme variable overrides-
  ()
  )

;;; romney-light-theme.el ends here
