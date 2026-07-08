{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.home-manager;
in {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    options.klozher.home-manager = {
        enable = lib.mkEnableOption "Enable home-manager";
        users = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "users config";
        };
    };
    config = lib.mkIf cfg.enable {
        home-manager.users = cfg.users;
        home-manager.useGlobalPkgs = true;
        home-manager.extraSpecialArgs = { osConfig = config; };
        home-manager.sharedModules = [
            inputs.plasma-manager.homeModules.plasma-manager
            ./persist.nix
            ./programs.nix
        ];
    };
}

