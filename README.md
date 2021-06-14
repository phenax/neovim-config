# My neovim config in lua

> Needs neovim 0.5.0+

### Whats in it?
  * Plugin manager: [packer.nvim](https://github.com/wbthomason/packer.nvim)
  * Intellisense: native lsp
  * File tree: [nvim-tree.lua](https://github.com/kyazdani42/nvim-tree.lua)
  * Fuzzy finder: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
  * Note taking: [vimwiki](https://github.com/vimwiki/vimwiki)
  * And a shit load of other things

### Install
  * Install `neovim` nightly build if you haven't already
  * `git clone https://github.com/phenax/peepeepoopoo-nvim-config.git ~/.config/nvim` to install it to your `nvim` config location
  * Run `nvim +PackerCompile +PackerInstall` to install plugins
  * Inside nvim, run `:checkhealth` and make everything green by installing the missing external dependencies

