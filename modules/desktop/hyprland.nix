{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    config = lib.mkIf (cfg.enable && cfg.desktop == "hyprland") {
        services.displayManager.ly = {
            enable = true;
        };
        programs.hyprland = {
            enable = true;
            withUWSM = true;
        };
        environment.systemPackages = with pkgs; [
            yazi
            kitty
            hyprlauncher
            hyprlock
            hypridle
        ];
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
                    modules.center = [ "SystemInfo" ];
                    modules.right = [ "Notifications" "Tray" "Settings" "Workspaces" "Tempo" ];
                };
            };
            services.kdeconnect = {
                enable = true;
                indicator = true;
            };
        })];
    };
}

