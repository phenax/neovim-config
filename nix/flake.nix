{
  description = "Example neovim plugin configurations";

  inputs = {
    nvim-plugin-manager.url = "github:phenax/nvim-flake-plugin-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Neovim plugin sources
    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    nvim-tree = { url = "github:kyazdani42/nvim-tree.lua"; flake = false; };
    vim-autoread = { url = "github:djoshea/vim-autoread"; flake = false; };
    vim-bufkill = { url = "github:qpkorr/vim-bufkill"; flake = false; };

    material = { url = "github:kaicataldo/material.vim"; flake = false; };
  };

  outputs = sources@{ self, nixpkgs, flake-utils, home-manager, nvim-plugin-manager, ... }:
    let
      plugins = {
        telescope = {
          dependencies = [ "plenary" ];
          configModule = "_plugins.telescope";
        };
        nvim-tree = {
          configModule = "_plugins.nvim-tree";
        };
        vim-autoread = { };
        vim-bufkill = { lazy.commands = [ "BD" ]; };
        material = {
          configLua = ''
            vim.g.material_terminal_italics = 1
            vim.g.material_theme_style = 'ocean'
            vim.cmd 'colorscheme material'
          '';
        };
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
          extraModules = [ "_modules.buffers" ];
        };
      });
}
