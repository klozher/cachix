{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.neovim;
in {
    imports = [ inputs.nixvim.nixosModules.nixvim ];
    options.klozher.neovim = {
        enable = lib.mkEnableOption "Enable neovim";
    };
    config = lib.mkIf cfg.enable {
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        nixpkgs.useGlobalPackages = true;
        viAlias = true;
        vimAlias = true;
        colorscheme = "tokyonight";
        colorschemes.tokyonight = {
          enable = true;
        };
        opts = {
          shiftwidth = 4;
          softtabstop = -1;
          expandtab = true;
          list = true;
        };
        plugins = {
          lsp = {
            enable = true;
            servers = {
              bashls.enable = true;
              clangd.enable = true;
              nixd.enable = true;
              pylsp.enable = true;
            };
          };
          fidget.enable = true;
          trouble.enable = true;
          web-devicons.enable = true;
          treesitter = {
            enable = true;
            nixGrammars = true;
            settings = {
              highlight.enable = true;
              indent.enable = true;
            };
          };
          treesitter-context = {
            enable = true;
            settings = { max_lines = 2; };
          };
          rainbow-delimiters.enable = true;
        };
      };
    };
}

