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

    plenary = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    devicons = { url = "github:kyazdani42/nvim-web-devicons"; flake = false; };

    telescope = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    nvim-tree = { url = "github:kyazdani42/nvim-tree.lua"; flake = false; };
    lualine = { url = "github:nvim-lualine/lualine.nvim"; flake = false; };

    fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
    gitgutter = { url = "github:airblade/vim-gitgutter"; flake = false; };
    gitmessenger = { url = "github:rhysd/git-messenger.vim"; flake = false; };

    material = { url = "github:kaicataldo/material.vim"; flake = false; };

    codeium = { url = "github:Exafunction/codeium.vim"; flake = false; };
    rest-nvim = { url = "github:NTBBloodbath/rest.nvim"; flake = false; };
    vim-autoread = { url = "github:djoshea/vim-autoread"; flake = false; };
    vim-bufkill = { url = "github:qpkorr/vim-bufkill"; flake = false; };
    comment-nvim = { url = "github:numToStr/Comment.nvim"; flake = false; };
    leap = { url = "github:ggandor/leap.nvim"; flake = false; };
    vim-surround = { url = "github:tpope/vim-surround"; flake = false; };
    vim-autoclose = { url = "github:Townk/vim-autoclose"; flake = false; };
    targets-vim = { url = "github:wellle/targets.vim"; flake = false; };
    indent-blankline = { url = "github:lukas-reineke/indent-blankline.nvim"; flake = false; };
    nvim-colorizer = { url = "github:NvChad/nvim-colorizer.lua"; flake = false; };
  };

  outputs = sources@{ self, nixpkgs, flake-utils, home-manager, nvim-plugin-manager, ... }:
    let
      plugins = {
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

        codeium = {
          lazy.commands = [ "Codeium" "CodeiumEnable" ];
          configModule = "_plugins.codeium-ai";
        };
        rest-nvim = {
          lazy.exts = [ "*.http" ];
          dependencies = [ "plenary" ];
          configModule = "_plugins.rest-nvim";
        };

        vim-autoread = { };
        vim-bufkill = { lazy.commands = [ "BD" ]; };
        comment-nvim = { configModule = "_plugins.comment-nvim"; };
        leap = { configModule = "_plugins.leap"; };
        vim-surround = { };
        vim-autoclose = { };
        targets-vim = { };
        indent-blankline = { configModule = "_plugins.indent-blankline"; };
        nvim-colorizer = { configModule = "_plugins.nvim-colorizer"; };

        material = { configModule = "_plugins.material"; };

        # TODO: Enable after packer stuff is cleaned out
        # treesitter = {
        #   dependencies = [ "treesitter-context" ];
        #   configModule = "_plugins.treesitter";
        # };
        # treesitter-textobjects = { };
        # treesitter-playground = { dependencies = [ "treesitter" ]; };
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
          doCheck = false;
          extraModulesPre = [ "_modules.settings" ];
          extraModules = [ "_modules.theme" "_modules.basic-keybinds" ];
        };
      });
}
