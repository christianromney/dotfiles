(if (or (doom-context-p 'init) (doom-context-p 'reload)) (doom-context-with 'modules (set 'doom-modules '#s(hash-table size 65 test equal rehash-size 1.5 rehash-threshold 0.8125 data ((:core) (:path "/Users/christian/.config/emacs/lisp/" :depth -110) (:user) (:path "/Users/christian/.config/doom/" :depth (-105 . 105)) (:config . use-package) (:path "/Users/christian/.config/emacs/modules/config/use-package" :depth -111) (:completion . company) (:path "/Users/christian/.config/emacs/modules/completion/company" :flags nil) (:completion . vertico) (:path "/Users/christian/.config/emacs/modules/completion/vertico" :flags (+icons)) (:ui . doom) (:path "/Users/christian/.config/emacs/modules/ui/doom" :flags nil) (:ui . emoji) (:path "/Users/christian/.config/emacs/modules/ui/emoji" :flags (+unicode)) (:ui . hl-todo) (:path "/Users/christian/.config/emacs/modules/ui/hl-todo" :flags nil) (:ui . modeline) (:path "/Users/christian/.config/emacs/modules/ui/modeline" :flags nil) (:ui . ophints) (:path "/Users/christian/.config/emacs/modules/ui/ophints" :flags nil) (:ui . popup) (:path "/Users/christian/.config/emacs/modules/ui/popup" :flags (+defaults)) (:ui . vc-gutter) (:path "/Users/christian/.config/emacs/modules/ui/vc-gutter" :flags (+pretty)) (:ui . vi-tilde-fringe) (:path "/Users/christian/.config/emacs/modules/ui/vi-tilde-fringe" :flags nil) (:ui . window-select) (:path "/Users/christian/.config/emacs/modules/ui/window-select" :flags nil) (:ui . workspaces) (:path "/Users/christian/.config/emacs/modules/ui/workspaces" :flags nil) (:editor . file-templates) (:path "/Users/christian/.config/emacs/modules/editor/file-templates" :flags nil) (:editor . fold) (:path "/Users/christian/.config/emacs/modules/editor/fold" :flags nil) (:editor . snippets) (:path "/Users/christian/.config/emacs/modules/editor/snippets" :flags nil) (:editor . word-wrap) (:path "/Users/christian/.config/emacs/modules/editor/word-wrap" :flags nil) (:emacs . dired) (:path "/Users/christian/.config/emacs/modules/emacs/dired" :flags nil) (:emacs . electric) (:path "/Users/christian/.config/emacs/modules/emacs/electric" :flags nil) (:emacs . ibuffer) (:path "/Users/christian/.config/emacs/modules/emacs/ibuffer" :flags nil) (:emacs . undo) (:path "/Users/christian/.config/emacs/modules/emacs/undo" :flags nil) (:emacs . vc) (:path "/Users/christian/.config/emacs/modules/emacs/vc" :flags nil) (:checkers . syntax) (:path "/Users/christian/.config/emacs/modules/checkers/syntax" :flags nil) (:checkers . spell) (:path "/Users/christian/.config/emacs/modules/checkers/spell" :flags (+aspell)) (:checkers . grammar) (:path "/Users/christian/.config/emacs/modules/checkers/grammar" :flags nil) (:tools . biblio) (:path "/Users/christian/.config/emacs/modules/tools/biblio" :flags nil) (:tools . debugger) (:path "/Users/christian/.config/emacs/modules/tools/debugger" :flags nil) (:tools . direnv) (:path "/Users/christian/.config/emacs/modules/tools/direnv" :flags nil) (:tools . eval) (:path "/Users/christian/.config/emacs/modules/tools/eval" :flags (+overlay)) (:tools . lookup) (:path "/Users/christian/.config/emacs/modules/tools/lookup" :flags nil) (:tools . lsp) (:path "/Users/christian/.config/emacs/modules/tools/lsp" :flags nil) (:tools . magit) (:path "/Users/christian/.config/emacs/modules/tools/magit" :flags (+forge)) (:tools . pdf) (:path "/Users/christian/.config/emacs/modules/tools/pdf" :flags nil) (:tools . rgb) (:path "/Users/christian/.config/emacs/modules/tools/rgb" :flags nil) (:tools . tree-sitter) (:path "/Users/christian/.config/emacs/modules/tools/tree-sitter" :flags nil) (:os . macos) (:path "/Users/christian/.config/emacs/modules/os/macos" :flags nil) (:lang . data) (:path "/Users/christian/.config/emacs/modules/lang/data" :flags nil) (:lang . emacs-lisp) (:path "/Users/christian/.config/emacs/modules/lang/emacs-lisp" :flags nil) (:lang . json) (:path "/Users/christian/.config/emacs/modules/lang/json" :flags (+lsp +tree-sitter)) (:lang . javascript) (:path "/Users/christian/.config/emacs/modules/lang/javascript" :flags (+lsp +tree-sitter)) (:lang . latex) (:path "/Users/christian/.config/emacs/modules/lang/latex" :flags nil) (:lang . markdown) (:path "/Users/christian/.config/emacs/modules/lang/markdown" :flags nil) (:lang . org) (:path "/Users/christian/.config/emacs/modules/lang/org" :flags (+gnuplot +pandoc +present +roam2)) (:lang . plantuml) (:path "/Users/christian/.config/emacs/modules/lang/plantuml" :flags nil) (:lang . python) (:path "/Users/christian/.config/emacs/modules/lang/python" :flags nil) (:lang . sh) (:path "/Users/christian/.config/emacs/modules/lang/sh" :flags (+fish +lsp)) (:lang . web) (:path "/Users/christian/.config/emacs/modules/lang/web" :flags (+tree-sitter)) (:lang . yaml) (:path "/Users/christian/.config/emacs/modules/lang/yaml" :flags nil) (:config . literate) (:path "/Users/christian/.config/emacs/modules/config/literate" :flags nil) (:config . default) (:path "/Users/christian/.config/emacs/modules/config/default" :flags (+bindings +smartparens))))) (set 'doom-disabled-packages 'nil) (setplist ':core '(nil [0 -110 -110 :core nil nil nil])) (setplist ':user '(nil [1 105 -105 :user nil nil nil])) (setplist ':completion '(company [3 0 0 :completion company nil nil] vertico [4 0 0 :completion vertico (+icons) nil])) (setplist ':ui '(doom [5 0 0 :ui doom nil nil] emoji [6 0 0 :ui emoji (+unicode) nil] hl-todo [7 0 0 :ui hl-todo nil nil] modeline [8 0 0 :ui modeline nil nil] ophints [9 0 0 :ui ophints nil nil] popup [10 0 0 :ui popup (+defaults) nil] vc-gutter [11 0 0 :ui vc-gutter (+pretty) nil] vi-tilde-fringe [12 0 0 :ui vi-tilde-fringe nil nil] window-select [13 0 0 :ui window-select nil nil] workspaces [14 0 0 :ui workspaces nil nil])) (setplist ':editor '(file-templates [15 0 0 :editor file-templates nil nil] fold [16 0 0 :editor fold nil nil] snippets [17 0 0 :editor snippets nil nil] word-wrap [18 0 0 :editor word-wrap nil nil])) (setplist ':emacs '(dired [19 0 0 :emacs dired nil nil] electric [20 0 0 :emacs electric nil nil] ibuffer [21 0 0 :emacs ibuffer nil nil] undo [22 0 0 :emacs undo nil nil] vc [23 0 0 :emacs vc nil nil])) (setplist ':checkers '(syntax [24 0 0 :checkers syntax nil nil] spell [25 0 0 :checkers spell (+aspell) nil] grammar [26 0 0 :checkers grammar nil nil])) (setplist ':tools '(biblio [27 0 0 :tools biblio nil nil] debugger [28 0 0 :tools debugger nil nil] direnv [29 0 0 :tools direnv nil nil] eval [30 0 0 :tools eval (+overlay) nil] lookup [31 0 0 :tools lookup nil nil] lsp [32 0 0 :tools lsp nil nil] magit [33 0 0 :tools magit (+forge) nil] pdf [34 0 0 :tools pdf nil nil] rgb [35 0 0 :tools rgb nil nil] tree-sitter [36 0 0 :tools tree-sitter nil nil])) (setplist ':os '(macos [37 0 0 :os macos nil nil])) (setplist ':lang '(data [38 0 0 :lang data nil nil] emacs-lisp [39 0 0 :lang emacs-lisp nil nil] json [40 0 0 :lang json (+lsp +tree-sitter) nil] javascript [41 0 0 :lang javascript (+lsp +tree-sitter) nil] latex [42 0 0 :lang latex nil nil] markdown [43 0 0 :lang markdown nil nil] org [44 0 0 :lang org (+gnuplot +pandoc +present +roam2) nil] plantuml [45 0 0 :lang plantuml nil nil] python [46 0 0 :lang python nil nil] sh [47 0 0 :lang sh (+fish +lsp) nil] web [48 0 0 :lang web (+tree-sitter) nil] yaml [49 0 0 :lang yaml nil nil])) (setplist ':config '(use-package [2 -111 -111 :config use-package nil nil] literate [50 0 0 :config literate nil nil] default [51 0 0 :config default (+bindings +smartparens) nil])) (let ((old-custom-file custom-file)) (let ((doom-module-context [2 -111 -111 :config use-package nil nil])) (doom-load "~/.config/emacs/modules/config/use-package/init")) (let ((doom-module-context [0 -110 -110 :core nil nil nil])) (doom-load "~/.config/emacs/lisp/init")) (doom-run-hooks 'doom-before-modules-init-hook) (doom-run-hooks 'doom-after-modules-init-hook) (doom-run-hooks 'doom-before-modules-config-hook) (let ((doom-module-context [3 0 0 :completion company nil nil])) (doom-load "~/.config/emacs/modules/completion/company/config")) (let ((doom-module-context [4 0 0 :completion vertico (+icons) nil])) (doom-load "~/.config/emacs/modules/completion/vertico/config")) (let ((doom-module-context [5 0 0 :ui doom nil nil])) (doom-load "~/.config/emacs/modules/ui/doom/config")) (let ((doom-module-context [6 0 0 :ui emoji (+unicode) nil])) (doom-load "~/.config/emacs/modules/ui/emoji/config")) (let ((doom-module-context [7 0 0 :ui hl-todo nil nil])) (doom-load "~/.config/emacs/modules/ui/hl-todo/config")) (let ((doom-module-context [8 0 0 :ui modeline nil nil])) (doom-load "~/.config/emacs/modules/ui/modeline/config")) (let ((doom-module-context [9 0 0 :ui ophints nil nil])) (doom-load "~/.config/emacs/modules/ui/ophints/config")) (let ((doom-module-context [10 0 0 :ui popup (+defaults) nil])) (doom-load "~/.config/emacs/modules/ui/popup/config")) (let ((doom-module-context [11 0 0 :ui vc-gutter (+pretty) nil])) (doom-load "~/.config/emacs/modules/ui/vc-gutter/config")) (let ((doom-module-context [13 0 0 :ui window-select nil nil])) (doom-load "~/.config/emacs/modules/ui/window-select/config")) (let ((doom-module-context [14 0 0 :ui workspaces nil nil])) (doom-load "~/.config/emacs/modules/ui/workspaces/config")) (let ((doom-module-context [15 0 0 :editor file-templates nil nil])) (doom-load "~/.config/emacs/modules/editor/file-templates/config")) (let ((doom-module-context [16 0 0 :editor fold nil nil])) (doom-load "~/.config/emacs/modules/editor/fold/config")) (let ((doom-module-context [17 0 0 :editor snippets nil nil])) (doom-load "~/.config/emacs/modules/editor/snippets/config")) (let ((doom-module-context [18 0 0 :editor word-wrap nil nil])) (doom-load "~/.config/emacs/modules/editor/word-wrap/config")) (let ((doom-module-context [19 0 0 :emacs dired nil nil])) (doom-load "~/.config/emacs/modules/emacs/dired/config")) (let ((doom-module-context [20 0 0 :emacs electric nil nil])) (doom-load "~/.config/emacs/modules/emacs/electric/config")) (let ((doom-module-context [21 0 0 :emacs ibuffer nil nil])) (doom-load "~/.config/emacs/modules/emacs/ibuffer/config")) (let ((doom-module-context [22 0 0 :emacs undo nil nil])) (doom-load "~/.config/emacs/modules/emacs/undo/config")) (let ((doom-module-context [23 0 0 :emacs vc nil nil])) (doom-load "~/.config/emacs/modules/emacs/vc/config")) (let ((doom-module-context [24 0 0 :checkers syntax nil nil])) (doom-load "~/.config/emacs/modules/checkers/syntax/config")) (let ((doom-module-context [25 0 0 :checkers spell (+aspell) nil])) (doom-load "~/.config/emacs/modules/checkers/spell/config")) (let ((doom-module-context [26 0 0 :checkers grammar nil nil])) (doom-load "~/.config/emacs/modules/checkers/grammar/config")) (let ((doom-module-context [27 0 0 :tools biblio nil nil])) (doom-load "~/.config/emacs/modules/tools/biblio/config")) (let ((doom-module-context [28 0 0 :tools debugger nil nil])) (doom-load "~/.config/emacs/modules/tools/debugger/config")) (let ((doom-module-context [29 0 0 :tools direnv nil nil])) (doom-load "~/.config/emacs/modules/tools/direnv/config")) (let ((doom-module-context [30 0 0 :tools eval (+overlay) nil])) (doom-load "~/.config/emacs/modules/tools/eval/config")) (let ((doom-module-context [31 0 0 :tools lookup nil nil])) (doom-load "~/.config/emacs/modules/tools/lookup/config")) (let ((doom-module-context [32 0 0 :tools lsp nil nil])) (doom-load "~/.config/emacs/modules/tools/lsp/config")) (let ((doom-module-context [33 0 0 :tools magit (+forge) nil])) (doom-load "~/.config/emacs/modules/tools/magit/config")) (let ((doom-module-context [34 0 0 :tools pdf nil nil])) (doom-load "~/.config/emacs/modules/tools/pdf/config")) (let ((doom-module-context [36 0 0 :tools tree-sitter nil nil])) (doom-load "~/.config/emacs/modules/tools/tree-sitter/config")) (let ((doom-module-context [37 0 0 :os macos nil nil])) (doom-load "~/.config/emacs/modules/os/macos/config")) (let ((doom-module-context [38 0 0 :lang data nil nil])) (doom-load "~/.config/emacs/modules/lang/data/config")) (let ((doom-module-context [39 0 0 :lang emacs-lisp nil nil])) (doom-load "~/.config/emacs/modules/lang/emacs-lisp/config")) (let ((doom-module-context [40 0 0 :lang json (+lsp +tree-sitter) nil])) (doom-load "~/.config/emacs/modules/lang/json/config")) (let ((doom-module-context [41 0 0 :lang javascript (+lsp +tree-sitter) nil])) (doom-load "~/.config/emacs/modules/lang/javascript/config")) (let ((doom-module-context [42 0 0 :lang latex nil nil])) (doom-load "~/.config/emacs/modules/lang/latex/config")) (let ((doom-module-context [43 0 0 :lang markdown nil nil])) (doom-load "~/.config/emacs/modules/lang/markdown/config")) (let ((doom-module-context [44 0 0 :lang org (+gnuplot +pandoc +present +roam2) nil])) (doom-load "~/.config/emacs/modules/lang/org/config")) (let ((doom-module-context [45 0 0 :lang plantuml nil nil])) (doom-load "~/.config/emacs/modules/lang/plantuml/config")) (let ((doom-module-context [46 0 0 :lang python nil nil])) (doom-load "~/.config/emacs/modules/lang/python/config")) (let ((doom-module-context [47 0 0 :lang sh (+fish +lsp) nil])) (doom-load "~/.config/emacs/modules/lang/sh/config")) (let ((doom-module-context [48 0 0 :lang web (+tree-sitter) nil])) (doom-load "~/.config/emacs/modules/lang/web/config")) (let ((doom-module-context [49 0 0 :lang yaml nil nil])) (doom-load "~/.config/emacs/modules/lang/yaml/config")) (let ((doom-module-context [51 0 0 :config default (+bindings +smartparens) nil])) (doom-load "~/.config/emacs/modules/config/default/config")) (doom-run-hooks 'doom-after-modules-config-hook) (let ((doom-module-context [1 105 -105 :user nil nil nil])) (doom-load "~/.config/doom/config")) (when (eq custom-file old-custom-file) (doom-load custom-file 'noerror)))))