;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; ----------------------------------------------------------------------------------
;; Appearance
;; ----------------------------------------------------------------------------------

(package! pulsar :recipe (:host github :repo "protesilaos/pulsar"))
(package! rainbow-delimiters)

;; ----------------------------------------------------------------------------------
;; Programming Tools & Languages
;; ----------------------------------------------------------------------------------

(package! adoc-mode)
(package! magit-delta :recipe (:host github :repo "dandavison/magit-delta"))
(package! gist :recipe (:host github :repo "defunkt/gist.el"))
(when (modulep! :checkers syntax)
  (package! flycheck-clj-kondo))
(package! clojure-snippets)

;; ----------------------------------------------------------------------------------
;; AI
;; ----------------------------------------------------------------------------------

(package! greader) ;; for text-to-speech
(package! whisper :recipe (:host github :repo "natrys/whisper.el")) ;; speech-to-text
(package! claude-code :recipe (:host github :repo "stevemolitor/claude-code.el"
                                :branch "main" :files ("*.el" (:exclude "images/*"))))
(package! gptel-prompts :recipe (:host github :repo "jwiegley/gptel-prompts"))
(package! mcp :recipe (:host github :repo "lizqwerscott/mcp.el"))

;; ----------------------------------------------------------------------------------
;; Org
;; ----------------------------------------------------------------------------------

(package! org-modern)
(package! brazilian-holidays)
(package! consult-org-roam :recipe(:host github :repo "jgru/consult-org-roam"))
(package! org-glossary :recipe (:host github :repo "tecosaur/org-glossary"))
(package! qrencode :recipe (:host github :repo "ruediger/qrencode-el"))
(package! graphviz-dot-mode) ;; graphviz diagrams
(package! mermaid-mode) ;; even more diagrams
(package! ob-mermaid) ;; exportable

;; ----------------------------------------------------------------------------------
;; Utilities
;; ----------------------------------------------------------------------------------
(package! compile-angel)
(package! consult-company)
(package! consult-yasnippet)
(package! yasnippet-snippets)
(package! free-keys :recipe (:host github :repo "Fuco1/free-keys"))
(package! google-this)
(package! elfeed-tube :recipe (:host github :repo "karthink/elfeed-tube"))
(package! wttrin :recipe (:host github :repo "bcbcarl/emacs-wttrin"
                           :branch "master" :files ("*.el" (:exclude "*.png"))))
