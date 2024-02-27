;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
;; ----------------------------------------------------------------------------------
;; Appearance
;; ----------------------------------------------------------------------------------
(package! pulsar :recipe (:host github :repo "protesilaos/pulsar"))

;; ----------------------------------------------------------------------------------
;; Languages
;; ----------------------------------------------------------------------------------
(package! adoc-mode)
(package! inf-clojure :pin "b153e5126419910c38691088aab569b7c281068c")
(when (modulep! :checkers syntax)
  (package! flycheck-clj-kondo :pin "ff7bed2315755cfe02ef471edf522e27b78cd5ca"))
(package! clojure-snippets)

;; ----------------------------------------------------------------------------------
;; AI
;; ----------------------------------------------------------------------------------
(package! ellama)  ;; general package for interacting with LLMs from Emacs
(package! greader) ;; for text-to-speech
(package! whisper :recipe (:host github :repo "natrys/whisper.el")) ;; speech-to-text
(package! copilot :recipe (:host github :repo "copilot-emacs/copilot.el" ;;coding
                            :files ("*.el" "dist")))
(package! org-ai)  ;; org-mode src blocks for ai

;; ----------------------------------------------------------------------------------
;; Org
;; ----------------------------------------------------------------------------------
(package! org-modern)
(package! brazilian-holidays)
(package! consult-org-roam :recipe(:host github :repo "jgru/consult-org-roam"))
(package! org-glossary :recipe (:host github :repo "tecosaur/org-glossary"))
(package! org-download)
(package! qrencode :recipe (:host github :repo "ruediger/qrencode-el"))
(package! graphviz-dot-mode) ;; graphviz diagrams
(package! ob-mermaid)        ;; even more diagrams

;; ----------------------------------------------------------------------------------
;; Utilities
;; ----------------------------------------------------------------------------------
(package! consult-company)
(package! consult-yasnippet)
(package! free-keys :recipe (:host github :repo "Fuco1/free-keys")) ;; find available
(package! google-this)
