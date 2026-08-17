{ config, lib, pkgs, inputs, ... }:
let
    cfg = config.klozher.desktop;
in {
    config = lib.mkIf (cfg.enable && cfg.desktop == "plasma") {
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
    };
}

