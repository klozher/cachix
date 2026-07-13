{lib, osConfig, ...}:
let
    cfg = osConfig.klozher.tmpfs-on-root;
in {
    config = lib.mkIf cfg.enable {
        home.persistence."/persist" = {
            directories = [
                "Desktop"
                "Downloads"
                "Documents"
                "Games"
                "projects"
                ".steam"
                ".xwechat"
                ".local/share/Steam"
                ".ssh"
                ".mozilla"
                ".config/QQ"
                ".config/zsh"
                ".config/mozilla"
                ".config/git"
                ".config/fcitx5"
                ".config/kdeconnect"
                ".config/heroic"
                ".config/mpv"
                ".config/jellyfin-mpv-shim"
                ".config/openrazer"
                ".vscode"
                ".config/Code"
                ".local/share/applications"
                ".local/share/io.github.clash-verge-rev.clash-verge-rev"
                ".local/share/Anki2"
                ".local/share/umu"
                ".local/share/eden"
                ".local/state/wireplumber"
                ".config/dconf"
                ".config/pulse"
                ".local/share/waydroid"
            ];
            files = [
                ".config/yakuakerc"
                ".config/kwinoutputconfig.json"
                ".local/share/user-places.xbel"
                ".config/gnome-initial-setup-done"
            ];
        };
    };
}

