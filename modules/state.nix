{ config, lib, pkgs, inputs, ... }:
{
    system.stateVersion = "25.11";
    home-manager.sharedModules = [({config, osConfig, ...}: {
        home.stateVersion = osConfig.system.stateVersion;
        programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
    })];
}

