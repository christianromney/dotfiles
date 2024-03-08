Structure
=========

This project contains my personal dotfiles collection. My primary machine is Mac
OS X, but most of this stuff should work equally well under Linux with a few
tweaks.

I use [Chezmoi](https://www.chezmoi.io/) to manage the symlinks in
this repository, and [Homebrew](https://brew.sh/) as my package manager.

Tools
=====
These are the tools I use most often:

- launcher: [raycast](https://www.raycast.com/)
- shell: [Fish](https://fishshell.com/) with [Fisher](https://github.com/jorgebucaran/fisher)
  - terminal emulator: [iTerm2](https://iterm2.com/)
  - prompt manager: [starship](https://starship.rs/)
  - project environment: [direnv](https://direnv.net/)
  - navigation: [zoxide](https://github.com/ajeetdsouza/zoxide) with [fzf](https://github.com/junegunn/fzf)
- editor: [emacs](https://www.gnu.org/software/emacs/) specifically, [emacs-plus](https://github.com/d12frosted/homebrew-emacs-plus) 
  - configuration framework: [Doom](https://github.com/doomemacs/doomemacs)
  - notes: [org-mode](https://orgmode.org/) and [org-roam](https://www.orgroam.com/)
    - reference manager: [BibDesk](https://bibdesk.sourceforge.io/) via [MacTeX](https://www.tug.org/mactex/)
- font: [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- programming languages: 
  - [clojure](https://clojure.org) (preferred)
  - [python](https://python.org)
    - environment ~miniconda~ `venv` via direnv stdlib `layout python3`
- local LLMs: [ollama](https://ollama.com/)
- containers: [orbstack](https://orbstack.dev/)

See the full list of installed [formulae](https://github.com/christianromney/dotfiles/blob/main/private_dot_config/homebrew/formulae.txt) and [casks](https://github.com/christianromney/dotfiles/blob/main/private_dot_config/homebrew/casks.txt).


License
=======

The MIT License

Copyright (c) 2010-2024 Christian Romney <christian.a.romney@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
