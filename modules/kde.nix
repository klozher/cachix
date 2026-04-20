{ config, pkgs, lib, inputs, ... }:
{
    services.displayManager = {
        enable = true;
        plasma-login-manager.enable = true;
        defaultSession = "plasma";
    };
    services.desktopManager.plasma6.enable = true;
    programs = {
        kdeconnect.enable = true;
    };
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
    fonts.enableDefaultPackages = false;
    fonts.packages = with pkgs; [ sarasa-gothic ];
}
