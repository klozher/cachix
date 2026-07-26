{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.tmpfs-on-root;
in {
    options.klozher.tmpfs-on-root = {
        enable = lib.mkEnableOption "Enable tmpfs on root";
        persistDev = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "persistDev mounted for /nix and /persist";
        };
    };
    config = lib.mkIf cfg.enable {
        fileSystems = {
            "/" = {
                device = "tmpfs";
                fsType = "tmpfs";
                options = [ "defaults" "mode=755" ];
            };
            "/nix" = cfg.persistDev // {
                options = cfg.persistDev.options ++ [ "X-mount.subdir=nix" ];
            };
            "/persist" = cfg.persistDev // {
                neededForBoot = true;
                options = cfg.persistDev.options ++ [ "X-mount.subdir=persist" ];
            };
        };
    };
}

