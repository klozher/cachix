{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.obsidian;
in {
    options.klozher.obsidian = {
        enable = lib.mkEnableOption "Enable obsidian";
    };
    config = lib.mkIf cfg.enable {
        nixpkgs.overlays = [ inputs.obsidian-extensions.overlays.default ];
        home-manager.sharedModules = [({config, lib, pkgs, ...}: {
            programs.obsidian = {
                enable = true;
                vaults."Documents/notes".enable = true;
                defaultSettings.app = {
                    legacyThirdPartyPlugins = true;
                    vimMode = true;
                };
                defaultSettings.hotkeys = {
                    "markdown:toggle-preview" = [];
                    "editor:delete-paragraph" = [];
                };
                defaultSettings.communityPlugins = [{
                    enable = true;
                    pkg = pkgs.obsidianPlugins.remotely-save;
                }];
            };
            age.secrets.obsidian-remotely-save.path = "Documents/notes/.obsidian/plugins/remotely-save/data.json";
        })];
    };
}

