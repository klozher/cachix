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
        home-manager.sharedModules = ([ inputs.plasma-manager.homeModules.plasma-manager ]
          ++[({config, ...}: {
                programs.zsh = {
                    enable = true;
                    dotDir = "${config.xdg.configHome}/zsh";
                };
            })]
          ++(lib.lists.optional config.klozher.tmpfs-on-root.enable ({...}: {
                    home.persistence."/persist" = {
                        directories = [
                            "Desktop"
                            "Downloads"
                            "Documents"
                            "Games"
                            "projects"
                            ".steam"
                            ".local/share/Steam"
                            ".ssh"
                            ".mozilla"
                            ".config/zsh"
                            ".config/git"
                            ".config/fcitx5"
                            ".config/kdeconnect"
                            ".config/heroic"
                            ".config/mpv"
                            ".config/jellyfin-mpv-shim"
                            ".config/openrazer"
                            ".vscode"
                            ".config/Code"
                            ".local/share/io.github.clash-verge-rev.clash-verge-rev"
                            ".local/share/Anki2"
                            ".local/share/umu"
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
                }))
           ++  (lib.lists.optional config.klozher.desktop.enable ({...}: {
                    programs.mangohud = {
                        enable = true;
                        settings = {};
                    };
            })));
    };
}

