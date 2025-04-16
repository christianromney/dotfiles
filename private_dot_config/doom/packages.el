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
(package! gist :recipe (:host github :repo "KarimAziev/gist.el"))
;; (package! inf-clojure)
(when (modulep! :checkers syntax)
  (package! flycheck-clj-kondo))
(package! clojure-snippets)
;; ----------------------------------------------------------------------------------
;; AI
;; ----------------------------------------------------------------------------------
(package! ellama)  ;; general package for interacting with LLMs from Emacs
(package! greader) ;; for text-to-speech
(package! whisper :recipe (:host github :repo "natrys/whisper.el")) ;; speech-to-text
(package! aidermacs)

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
(package! ob-mermaid)
;; ----------------------------------------------------------------------------------
;; Utilities
;; ----------------------------------------------------------------------------------
(package! consult-company)
(package! consult-yasnippet)
(package! free-keys :recipe (:host github :repo "Fuco1/free-keys")) ;; find available
(package! google-this)
