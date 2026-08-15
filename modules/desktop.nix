{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    options.klozher.desktop = {
        enable = lib.mkEnableOption "Enable desktop";
        desktop = lib.mkOption {
            type = lib.types.enum [ "plasma" "gnome" "hyprland" ];
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
        (lib.mkIf (cfg.desktop == "hyprland") {
            services.displayManager.ly = {
                enable = true;
            };
            programs.hyprland = {
                enable = true;
                withUWSM = true;
            };
            home-manager.sharedModules = [({lib, config, osConfig, ...}: {
                services.hypridle = {
                    enable = true;
                    settings = with pkgs; {
                        general = {
                            lock_cmd = "${procps}/bin/pidof hyprlock || ${hyprlock}/bin/hyprlock";
                            before_sleep_cmd = "${systemd}/bin/loginctl lock-session";
                            after_sleep_cmd = "${hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
                        };
                        listener = [{
                            timeout = 300;
                            on-timeout = "${systemd}/bin/loginctl lock-session";
                        } {
                            timeout = 330;
                            on-timeout = "${hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
                            on-resume = "${hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
                        }];
                    };
                };
                programs.ashell = {
                    enable = true;
                    systemd.enable = true;
                    settings = {
                        modules.left = [ "WindowTitle" ];
                        modules.center = [ "Notifications" ];
                        modules.right = [ "Tray" "Settings" "Workspaces" "Tempo" ];
                    };
                };
            })];
            environment.systemPackages = with pkgs; [
                yazi
                kitty
                hyprlauncher
                hyprlock
                hypridle
            ];
        })
    ]);
}
