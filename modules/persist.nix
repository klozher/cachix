{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.persist;
    persistSetup = osConfig: hmConfig: let
        hasPkg = (pkgName:
            builtins.elem pkgName
            (lib.lists.concatMap
                (pkg: if pkg ? pname then [pkg.pname] else [(builtins.parseDrvName pkg.name).name])
                ((osConfig.environment.systemPackages or []) ++ (hmConfig.home.packages or []))
            )
        );
        osOptOn = option: lib.attrByPath (option ++ ["enable"]) false osConfig;
        hmOptOn = option: lib.attrByPath (option ++ ["enable"]) false hmConfig;
    in [
        {
            condition = true;
            system.files = [];
            system.dirs = [];
            home.files = [];
            home.dirs = [];
        }
        {
            condition = true;
            system.files = [
                "/etc/machine-id"
                "/etc/ssh/ssh_host_rsa_key"
                "/etc/ssh/ssh_host_rsa_key.pub"
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
            ];
            system.dirs = [
                "/etc/nixos"
                "/etc/mihomo"
                "/etc/NetworkManager/system-connections"
                "/etc/coolercontrol"
                "/var/log"
                "/var/lib/kodi"
                "/var/lib/nixos"
                "/var/lib/alsa"
                "/var/lib/samba"
                "/var/lib/waydroid"
                "/var/lib/bluetooth"
                "/var/lib/containers"
                "/var/lib/libvirt"
            ];
            home.files = [];
            home.dirs = [
                "Desktop" "Downloads" "Documents" "Games"
                ".ssh" ".config/zsh" ".config/git"
                ".config/pulse" ".local/state/wireplumber"
                ".config/fcitx5"
                ".local/share/applications"
                "projects"
            ];
        }
        {
            condition = osOptOn ["programs" "dconf"];
            home.dirs = [".config/dconf"];
        }
        {
            condition = osOptOn ["programs" "steam"];
            home.dirs = [".steam" ".local/share/Steam"];
        }
        {
            condition = osOptOn ["virtualisation" "waydroid"];
            home.dirs = [".local/share/waydroid"];
        }
        {
            condition = osOptOn ["services" "desktopManager" "plasma6"];
            home.files = [".config/yakuakerc" ".config/kwinoutputconfig.json" ".local/share/user-places.xbel"];
            home.dirs = [];
        }
        {
            condition = osOptOn ["services" "desktopManager" "gnome"];
            home.files = [".config/gnome-initial-setup-done"];
        }
        {
            condition = osOptOn ["programs" "hyprland"];
            home.dirs = [".config/hypr"];
        }
        {
            condition = osOptOn ["programs" "niri"];
            home.dirs = [".config/niri"];
        }
        {
            condition = osOptOn ["programs" "kdeconnect"];
            home.dirs = [".config/kdeconnect"];
        }
        {
            condition = osOptOn ["programs" "coolercontrol"];
            home.dirs = [".config/org.coolercontrol.CoolerControl"];
        }
        {
            condition = osOptOn ["hardware" "openrazer"];
            home.dirs = [".config/openrazer"];
        }
        {
            condition = osOptOn ["programs" "clash-verge"];
            home.dirs = [".local/share/io.github.clash-verge-rev.clash-verge-rev"];
        }
        {
            condition = osOptOn ["services" "wivrn"];
            home.dirs = [".config/wivrn"];
        }
        {
            condition = osOptOn ["services" "fwupd"];
            system.dirs = ["/var/lib/fwupd"];
        }
        {
            condition = hmOptOn ["programs" "vscode"];
            home.dirs = [".vscode" ".config/Code"];
        }
        {
            condition = hmOptOn ["programs" "anki"];
            home.dirs = [".local/share/Anki2"];
        }
        {
            condition = hmOptOn ["programs" "aider-chat"];
            home.files = [".aider.conf.yml"];
            home.dirs = [".aider"];
        }
        {
            condition = hmOptOn ["programs" "obs-studio"];
            home.dirs = [".config/obs-studio"];
        }
        {
            condition = hmOptOn ["services" "podman"];
            home.dirs = [".local/share/containers"];
        }
        {
            condition = hasPkg "qq";
            home.dirs = [".config/QQ"];
        }
        {
            condition = hasPkg "wechat";
            home.dirs = [".xwechat"];
        }
        {
            condition = hasPkg "mpv";
            home.dirs = [".config/mpv"];
        }
        {
            condition = hasPkg "wayvr";
            home.dirs = [".config/wayvr"];
        }
        {
            condition = hasPkg "firefox";
            home.dirs = [".config/mozilla"];
        }
        {
            condition = hasPkg "heroic";
            home.dirs = [".config/heroic"];
        }
        {
            condition = hasPkg "jellyfin-mpv-shim";
            home.dirs = [".config/jellyfin-mpv-shim"];
        }
        {
            condition = hasPkg "eden";
            home.dirs = [".local/share/eden"];
        }
        {
            condition = hasPkg "umu-launcher";
            home.dirs = [".local/share/umu"];
        }
    ];
in {
    imports = [ inputs.impermanence.nixosModules.impermanence ];
    options.klozher.persist = {
        enable = lib.mkEnableOption "Enable Persistant Mount";
        persistPath = lib.mkOption {
            type = lib.types.str;
            default = "/persist";
            description = "location to store persist data";
        };
    };
    config = lib.mkIf cfg.enable {
        environment.persistence."${cfg.persistPath}" = {
            enable = true;
            hideMounts = true;
            files = lib.lists.concatMap (args:
                if args.condition then args.system.files or [] else []) (persistSetup config {});
            directories = lib.lists.concatMap (args:
                if args.condition then args.system.dirs or [] else []) (persistSetup config {});
        };
        home-manager.sharedModules = [({lib, config, osConfig, ...}: {
            home.persistence."${cfg.persistPath}" = {
                files = lib.lists.concatMap (args:
                    if args.condition then args.home.files or [] else []) (persistSetup osConfig config);
                directories = lib.lists.concatMap (args:
                    if args.condition then args.home.dirs or [] else []) (persistSetup osConfig config);
            };
        })];
    };
}

