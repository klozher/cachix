{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    options.klozher.desktop = {
        enable = lib.mkEnableOption "Enable desktop";
        desktop = lib.mkOption {
            type = lib.types.enum [ "plasma" "gnome" "tile" ];
        };
    };
    config = lib.mkIf cfg.enable (lib.mkMerge [
        {
            klozher.i18n.enable = true;
            fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
            networking.networkmanager.enable = true;
            programs.kdeconnect.enable = true;
            environment.systemPackages = with pkgs; [
                wl-clipboard
                xclip
            ];
        }
        (lib.mkIf (cfg.desktop == "plasma") {
            home-manager.sharedModules = [
                inputs.plasma-manager.homeModules.plasma-manager
            ];
            services.displayManager = {
                enable = true;
                plasma-login-manager.enable = true;
                defaultSession = "plasma";
            };
            services.desktopManager.plasma6.enable = true;
            fonts.enableDefaultPackages = false;
            fonts.packages = with pkgs; [ sarasa-gothic ];
            environment.systemPackages = [(
                pkgs.makeAutostartItem {
                    name = "org.kde.yakuake";
                    package = pkgs.kdePackages.yakuake;
                }
            ) pkgs.kdePackages.yakuake ];
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
            fonts.enableDefaultPackages = false;
            fonts.packages = with pkgs; [ sarasa-gothic ];
            programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
            environment.systemPackages = with pkgs; [
                dconf-editor
                dconf2nix
                gnomeExtensions.kimpanel
            ];
            programs.dconf.profiles.user.databases = [{
                settings."org/gnome/shell".enabled-extensions = ["kimpanel@kde.org"];
            }];
        })
        (lib.mkIf (cfg.desktop == "tile") {
            services.displayManager.ly = {
                enable = true;
            };
            programs.hyprland = {
                enable = true;
                withUWSM = true;
            };
            programs.niri = {
                enable = true;
            };
            environment.systemPackages = with pkgs; [
                yazi
                kitty
                fuzzel
                waybar
                hyprlauncher
            ];
        })
    ]);
}
