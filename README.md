# My Neovim Configuration

This is mostly for backup purposes as my config is very disorganized and I don't
recommend anyone take influence from it.

![neovim](https://user-images.githubusercontent.com/55766287/222920744-73644efd-b7fa-4876-85f9-b1bec5706782.png)

## Prerequisites

- Install [vim-plug](https://github.com/junegunn/vim-plug)
- In Neovim run `:PlugInstall`
- _**Optional**_ Use a font that is patched with the
  [Nerd Fonts library](https://github.com/ryanoasis/nerd-fonts) for statusline,
  bufferline icons
- _**Optional**_ Install [ripgrep](https://github.com/BurntSushi/ripgrep) for
  fuzzy finding files with keyword search
- _**Optional**_ Install yarn (`npm i -g yarn`) for `markdown-preview.nvim`
- _**Optional**_ Install
  [Deno](https://deno.land/manual@v1.31.1/getting_started/installation) for code
  formatting via `deno fmt`
- _**Optional**_ Install `clang_format` via Mason for C, C++ formatting. Most
  other LSP's have formatting configured also but the default configuration of
  `clangd` is not extensible with `null-ls`
- _**Optional**_ Install
  [`wl-clipboard`](https://archlinux.org/packages/community/x86_64/wl-clipboard/)
  (or [build from source](https://github.com/bugaevc/wl-clipboard)) if using
  Wayland in order to support yanking to the system clipboard.

## Basic Usage

This configuration extends all of the core functionality of Neovim. I use
`Space` as the Leader key. All mappings in Normal mode unless specified
otherwise.

### Navigation

- Files
  - _**NOTE**_: Use `Enter` to switch to current file and `Tab` to open current
    file in new tab
  - Use `<leader>ff` to fuzzy Find Files
  - Use `<leader>gf` to fuzzy Find files in the Git index and working tree (I
    don't ever use this)
  - Use `<leader>sf` to Search for Files that contain a phrase (using ripgrep)
- Tabs
  - Use `Ctrl+n` and `Ctrl+p` to switch to one tab to the left or right,
    respectively
    - I chose these directions because they make more sense to me as `n` is on
      the left and `p` is on the right on a keyboard
  - Use `Ctrl+h` and `Ctrl+l` to move tabs to the left of right, respectively
- Git
  - Use `<leader>gk` and `<leader>gj` to move up and down Git changes,
    respectively
  - Use `<leader>gp` to Preview a Git change that the cursor is on
  - Use `<leader>gb` to Git-Blame the current line
- Diagnostics
  - Use `gd` to Go to Definition of current object
  - Use `gD` to Go to Definition of current object in a new tab (useful)
  - Use `ge` and `gE` to Go to next or previous Error, respectively
- Insert mode
  - Prepend `Ctrl` to `h`, `j`, `k`, `l` to navigate as in Normal mode
  - Can use `Meta+i` as an alternative to `Esc` to exit Insert mode

### Editing

- Use `Ctrl+/` to toggle comments
  - In Normal and Insert mode, toggles current line
  - In Visual mode, toggles selected lines (or text if only one line selected)
- Autocompletion
  - Use `Tab` to select current item, jump to next snippet position (VS Code
    functionality)
  - Use `Shift+Tab` to navigate to previous item, jump to previous snippet
    position
  - Use `Ctrl+n` and `Ctrl+p` to navigate to Next or Previous item, respectively
  - Use `Ctrl+e` to Exit autocompletion menu
  - Use `Ctrl+Space` to show full autocompletion menu
- EZ Semicolon
  - Implements EZ Semicolon (VS Code extension) functionality: inserting a
    semicolon anywhere will always place it at the end of the line followed by a
    new line. The only exceptions to this are if the line is a return statement
    (no new line will be inserted) or a for loop (no formatting will occur at
    all). This behavior can be overridden by using `Meta+;`.
- Use `Tab` and `Shift+Tab` to indent or remove indent, respectively
  - In Normal mode, this affects the current line. In Visual mode, this affects
    all selected lines.
- Miscellaneous useful Visual mode operations
  - Use `K` and `J` to move the selected lines up or down, respectively, smartly
    indenting if the lines move within the scope of, say, an if statement
  - Use `H` and `L` to move the _end_ of the selection left or right,
    respectively
  - Surround selection with brackets by pressing that bracket. Open bracket
    surrounds with spaces in-between and closed bracket surrounds without
    spaces.
    - Example (asterisks represent selection): `*surround* here` -> '(' pressed
      -> `( surround ) here`
    - _**NOTES**_
      - Works with all brackets and quotation marks, but square brackets must be
        escaped by being pressed twice, e.g. `]]`, as square brackets are mapped
        to other behavior in Vim
      - Surround with HTML-style tag using `T`
  - Use `Ctrl+y` and `Ctrl+x` to copy or cut to system clipboard, respectively
- Use `<leader>h` and `<leader>H` to search and replace instances of the hovered
  word, with and without smart adjustment for different cases (like camel case),
  respectively
