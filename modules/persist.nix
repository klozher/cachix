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
        isOptOn = cfg: option:
            (lib.attrByPath option false cfg) == true ||
            (lib.attrByPath (option ++ ["enable"]) false cfg);
        osOptOn = isOptOn osConfig;
        hmOptOn = isOptOn hmConfig;
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
            ];
            system.dirs = [
                "/etc/nixos"
                "/var/log"
                "/var/lib/nixos"
                "/var/lib/kodi"
                "/var/lib/containers"
                "/var/lib/systemd/timers"
            ];
            home.files = [];
            home.dirs = [
                "Desktop" "Downloads" "Documents" "Games"
                ".local/share/applications"
                "projects"
                "containers"
            ];
        }
        {
            condition = osOptOn ["services" "openssh"];
            system.files = [
                "/etc/ssh/ssh_host_rsa_key"
                "/etc/ssh/ssh_host_rsa_key.pub"
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
            ];
            home.dirs = [ ".ssh" ];
        }
        {
            condition = osOptOn ["hardware" "alsa" "enablePersistence"];
            system.dirs = [ "/var/lib/alsa" ];
        }
        {
            condition = osOptOn ["services" "pulseaudio"];
            home.dirs = [ ".config/pulse" ];
        }
        {
            condition = osOptOn ["services" "pipewire"];
            home.dirs = [ ".local/state/wireplumber" ];
        }
        {
            condition = osOptOn ["hardware" "bluetooth"];
            system.dirs = [ "/var/lib/bluetooth" ];
        }
        {
            condition = (osOptOn ["programs" "zsh"]) || (hmOptOn ["programs" "zsh"]);
            home.dirs = [ ".config/zsh" ];
        }
        {
            condition = osOptOn ["networking" "networkmanager"];
            system.dirs = [ "/etc/NetworkManager/system-connections" ];
        }
        {
            condition = osOptOn ["services" "samba"];
            system.dirs = [ "/var/lib/samba" ];
        }
        {
            condition = osOptOn ["virtualisation" "waydroid"];
            system.dirs = [ "/var/lib/waydroid" ];
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
            condition = osOptOn ["programs" "coolercontrol"];
            system.dirs = [ "/etc/coolercontrol" ];
            home.dirs = [".config/org.coolercontrol.CoolerControl"];
        }
        {
            condition = osOptOn ["hardware" "openrazer"];
            home.dirs = [".config/openrazer"];
        }
        {
            condition = osOptOn ["services" "mihomo"];
            system.dirs = [ "/etc/mihomo" ];
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
            condition = osOptOn ["services" "ollama"];
            system.dirs = ["/var/lib/private/ollama"];
        }
        {
            condition = osOptOn ["i18n" "inputMethod"];
            home.dirs = [".config/fcitx5"];
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
            home.dirs = [".config/aider"];
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
            condition = hmOptOn ["programs" "claude-code"];
            home.dirs = [".claude"];
        }
        {
            condition = hmOptOn ["services" "kdeconnect"];
            home.dirs = [".config/kdeconnect"];
        }
        {
            condition = hasPkg "git";
            home.dirs = [".config/git"];
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

