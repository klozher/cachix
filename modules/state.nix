{ config, lib, pkgs, inputs, ... }:
{
    system.stateVersion = "25.11";
    nixpkgs.config.permittedInsecurePackages = [
        # TODO: wait for cherry-studio to upgrade
        "electron-40.10.5"
        "pnpm-10.29.2"
    ];
    home-manager.sharedModules = [({config, osConfig, ...}: {
        home.stateVersion = osConfig.system.stateVersion;
        programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
    })];
}

