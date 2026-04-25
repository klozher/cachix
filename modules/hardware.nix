{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.tmpfs-on-root;
in {
    imports = [ inputs.impermanence.nixosModules.impermanence ];
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
        environment.persistence."/persist" = {
            enable = true;
            hideMounts = true;
            directories = [
                "/etc/nixos"
                "/etc/NetworkManager/system-connections"
                "/var/log"
                "/var/lib/nixos"
                "/var/lib/alsa"
                "/var/lib/samba"
                "/var/lib/waydroid"
                "/var/lib/bluetooth"
                "/var/lib/libvirt"
            ];
            files = [
                "/etc/machine-id"
                "/etc/ssh/ssh_host_rsa_key"
                "/etc/ssh/ssh_host_rsa_key.pub"
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
            ];
        };
    };
}

