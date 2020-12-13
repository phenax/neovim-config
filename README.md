# My neovim config in lua

> Needs neovim 0.5.0+

### Dependencies
  * [fzf](https://github.com/junegunn/fzf)
  * [ag](https://github.com/ggreer/the_silver_searcher)
  * [ctags](https://ctags.io/)

### Whats in it?
  * Plugin manager: [packer.nvim](https://github.com/wbthomason/packer.nvim)
  * Intellisense: [coc.nvim](https://github.com/neoclide/coc.nvim)
  * Fuzzy finder: [fzf.vim](https://github.com/junegunn/fzf.vim)
  * Note taking: [vimwiki](https://github.com/vimwiki/vimwiki)
  * Interactive scratchpad: [codi.vim](https://github.com/metakirby5/codi.vim)
  * And a shit load of other things

### Install
  * Install the dependencies mentioned above
  * Install `neovim` nightly build if you haven't already
  * `git clone https://github.com/phenax/peepeepoopoo-nvim-config.git ~/.config/nvim` to install it to your `nvim` config location
  * Run `nvim +PackerCompile +PackerInstall` to install plugins
  * Inside nvim, run `:checkhealth` and make everything green by installing the missing external dependencies

