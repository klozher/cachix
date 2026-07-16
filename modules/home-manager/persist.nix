{lib, osConfig, config, ...}:
let
    cfg = osConfig.klozher.tmpfs-on-root;
    hasPkg = (pkgName:
        builtins.elem pkgName
        (lib.lists.concatMap
         (pkg: if pkg ? pname then [pkg.pname] else [(builtins.parseDrvName pkg.name).name])
         (osConfig.environment.systemPackages ++ config.home.packages)
        )
    );
    persist-list = [
        [true
            []
            ["Desktop" "Downloads" "Documents" "Games"
             ".ssh" ".config/zsh" ".config/dconf" ".config/git"
             ".config/pulse" ".local/state/wireplumber"
             ".config/fcitx5"
             ".local/share/applications"
             "projects"
            ]
        ]
        [osConfig.programs.steam.enable [] [".steam" ".local/share/Steam"]]
        [osConfig.virtualisation.waydroid.enable [] [".local/share/waydroid"]]
        [osConfig.services.desktopManager.plasma6.enable
            [".config/yakuakerc" ".config/kwinoutputconfig.json" ".local/share/user-places.xbel"]
            []
        ]
        [osConfig.services.desktopManager.gnome.enable
            [".config/gnome-initial-setup-done"]
            []
        ]
        [osConfig.programs.hyprland.enable [] [".config/hypr"]]
        [osConfig.programs.niri.enable [] [".config/niri"]]
        [osConfig.programs.kdeconnect.enable [] [".config/kdeconnect"]]
        [osConfig.hardware.openrazer.enable [] [".config/openrazer"]]
        [osConfig.programs.clash-verge.enable [] [".local/share/io.github.clash-verge-rev.clash-verge-rev"]]
        [config.programs.vscode.enable [] [".vscode" ".config/Code"]]
        [config.programs.anki.enable [] [".local/share/Anki2"]]
        [config.services.podman.enable [] [".local/share/containers"]]
        [(hasPkg "qq") [] [".config/QQ"]]
        [(hasPkg "wechat") [] [".xwechat"]]
        [(hasPkg "mpv") [] [".config/mpv"]]
        [(hasPkg "firefox") [] [".mozilla" ".config/mozilla"]]
        [(hasPkg "heroic") [] [".config/heroic"]]
        [(hasPkg "jellyfin-mpv-shim") [] [".config/jellyfin-mpv-shim"]]
        [(hasPkg "eden") [] [".local/share/eden"]]
        [(hasPkg "umu-launcher") [] [".local/share/umu"]]
    ];
in {
    config = lib.mkIf cfg.enable {
        home.persistence."/persist" = {
            files = lib.lists.concatMap (args:
                if (builtins.elemAt args 0)
                then (builtins.elemAt args 1)
                else []
            ) persist-list;
            directories = lib.lists.concatMap (args:
                if (builtins.elemAt args 0)
                then (builtins.elemAt args 2)
                else []
            ) persist-list;
        };
    };
}

