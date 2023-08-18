{
  description = "Example neovim plugin configurations";

  inputs = {
    nvim-plugin-manager.url = "github:phenax/nvim-flake-plugin-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Neovim plugin sources
    treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };
    treesitter-textobjects = { url = "github:nvim-treesitter/nvim-treesitter-textobjects"; flake = false; };
    treesitter-context = { url = "github:nvim-treesitter/nvim-treesitter-context"; flake = false; };
    treesitter-playground = { url = "github:nvim-treesitter/playground"; flake = false; };

    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    nvim-tree = { url = "github:kyazdani42/nvim-tree.lua"; flake = false; };
    lualine = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };
    devicons = { url = "github:kyazdani42/nvim-web-devicons"; flake = false; };

    fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
    gitgutter = { url = "github:airblade/vim-gitgutter"; flake = false; };
    gitmessenger = { url = "github:rhysd/git-messenger.vim"; flake = false; };

    material = { url = "github:kaicataldo/material.vim"; flake = false; };

    vim-autoread = { url = "github:djoshea/vim-autoread"; flake = false; };
    vim-bufkill = { url = "github:qpkorr/vim-bufkill"; flake = false; };
  };

  outputs = sources@{ self, nixpkgs, flake-utils, home-manager, nvim-plugin-manager, ... }:
    let
      plugins = {
        treesitter = {
          dependencies = [ "treesitter-textobjects" "treesitter-context" ];
          configModule = "_plugins.treesitter";
        };
        treesitter-playground = { };

        telescope = {
          dependencies = [ "plenary" ];
          configModule = "_plugins.telescope";
        };
        nvim-tree = {
          # TODO: Lazy load
          configModule = "_plugins.nvim-tree";
        };
        lualine = {
          dependencies = [ "devicons" ];
          configModule = "_plugins.lualine";
        };

        fugitive = { configModule = "_plugins.fugitive"; };
        gitgutter = { configModule = "_plugins.gitgutter"; };
        gitmessenger = { configModule = "_plugins.gitmessenger"; };

        vim-autoread = { };
        vim-bufkill = { lazy.commands = [ "BD" ]; };

        material = { configModule = "_plugins.material"; };
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = nvim-plugin-manager.lib.mkPlugins {
          inherit plugins sources pkgs;
          modulePath = ./.;
          doCheck = true;
          extraModulesPre = [ "_modules.settings" ];
          extraModules = [ "_modules.theme" "_modules.buffers" ];
        };
      });
}
