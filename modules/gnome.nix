{ config, pkgs, lib, inputs, ... }:
{
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
    programs = {
        kdeconnect.enable = true;
        kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
        dconf.enable = true;
    };
    environment.gnome.excludePackages = with pkgs; [
        epiphany #browser
        gnome-contacts
        gnome-weather
        simple-scan #scanner
        geary #mail
    ];
    environment.systemPackages = with pkgs; [
        dconf-editor
        vulkan-tools
        mesa-demos
    ] ++ (with pkgs.gnomeExtensions; [
        caffeine
        screen-rotate
        app-grid-wizard
        forge
        battery-health-charging
    ]);
    i18n.inputMethod = {
        enable = true;
        type = "ibus";
        ibus.engines = with pkgs.ibus-engines; [
            libpinyin
            mozc
        ];
    };
    fonts.enableDefaultPackages = false;
    fonts.packages = with pkgs; [ sarasa-gothic ];
}

