{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    options.klozher.desktop = {
        enable = lib.mkEnableOption "Enable desktop";
        desktop = lib.mkOption {
            type = lib.types.enum [ "plasma" "gnome" ];
        };
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
        {
            fonts.enableDefaultPackages = false;
            fonts.packages = with pkgs; [ sarasa-gothic ];
            programs.kdeconnect.enable = true;
            i18n.extraLocales = [
                "zh_CN.UTF-8/UTF-8"
                "zh_CN.GB18030/GB18030"
                "zh_CN.GBK/GBK"
                "ja_JP.UTF-8/UTF-8"
                "ja_JP.EUC-JP/EUC-JP"
            ];
        }
        (lib.mkIf (cfg.desktop == "plasma") {
            services.displayManager = {
                enable = true;
                plasma-login-manager.enable = true;
                defaultSession = "plasma";
            };
            services.desktopManager.plasma6.enable = true;
            i18n.inputMethod = {
                enable = true;
                type = "fcitx5";
                fcitx5 = {
                    waylandFrontend = true;
                    addons = with pkgs; [
                        qt6Packages.fcitx5-chinese-addons
                        fcitx5-mozc-ut
                        fcitx5-pinyin-zhwiki
                        fcitx5-pinyin-moegirl
                    ];
                };
            };
        })
        (lib.mkIf (cfg.desktop == "gnome") {
            services = {
                displayManager = {
                    enable = true;
                    gdm.enable = true;
                    defaultSession = "gnome";
                };
                desktopManager.gnome.enable = true;
                gnome = {
                    gnome-remote-desktop.enable = false;
                };
            };
            programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
            environment.systemPackages = with pkgs; [
                dconf-editor
                dconf2nix
            ];
            i18n.inputMethod = {
                enable = true;
                type = "ibus";
                ibus.engines = with pkgs.ibus-engines; [
                    libpinyin
                    mozc
                ];
            };
        })
    ]);
}
