{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    config = lib.mkIf (cfg.enable && cfg.desktop == "gnome") {
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
        fonts.enableDefaultPackages = false;
        fonts.packages = with pkgs; [ sarasa-gothic ];
        environment.systemPackages = with pkgs; [
            dconf-editor
            dconf2nix
            gnomeExtensions.kimpanel
        ];
        programs.dconf.profiles.user.databases = [{
            settings."org/gnome/shell".enabled-extensions = ["kimpanel@kde.org"];
        }];
        home-manager.sharedModules = [({lib, config, osConfig, pkgs, ...}: {
            services.kdeconnect = {
                enable = true;
                package = pkgs.gnomeExtensions.gsconnect;
            };
        })];
    };
}

